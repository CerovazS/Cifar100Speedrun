#!/bin/bash
#SBATCH --job-name=c100-paired
#SBATCH --account=IscrC_SIMP
#SBATCH --partition=boost_usr_prod
#SBATCH --qos=boost_qos_dbg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=64G
#SBATCH --time=01:00:00
#SBATCH --output=logs/paired-%j.out
#SBATCH --error=logs/paired-%j.err
set -euo pipefail
if [[ "${SLURM_JOB_ACCOUNT:-}" != "iscrc_simp" && "${SLURM_JOB_ACCOUNT:-}" != "IscrC_SIMP" ]]; then
  echo "Refusing to run outside IscrC_SIMP." >&2
  exit 2
fi
if [[ -z "${CIFAR100_ROOT:-}" ]]; then
  if [[ -n "${SLURM_SUBMIT_DIR:-}" && -d "$SLURM_SUBMIT_DIR/cifar100-benchmark" ]]; then
    CIFAR100_ROOT=$(cd "$SLURM_SUBMIT_DIR" && pwd -P)
  else
    CIFAR100_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
  fi
fi
export CIFAR100_ROOT
cd "$CIFAR100_ROOT"
mkdir -p logs outputs/cifar100_speedrun
source "$CIFAR100_ROOT/env_setup.sh"
echo "==> $(date) job=${SLURM_JOB_ID:-N/A} node=$(hostname)"
nvidia-smi --query-gpu=index,uuid,name,memory.total,driver_version --format=csv
python prepare_cifar100_hf.py

RECORD=${RECORD:-0}
TARGET=${TARGET:-0.70}
EPOCHS=${EPOCHS:-16}
if [[ "$RECORD" == "1" ]]; then
  RUNS=${RUNS:-30}
  VALIDATION_SOURCE=${VALIDATION_SOURCE:-official}
else
  RUNS=${RUNS:-10}
  VALIDATION_SOURCE=${VALIDATION_SOURCE:-train_dev}
fi
BASE_SEED=${BASE_SEED:-880000}
RUN_ID=${RUN_ID:-paired_${SLURM_JOB_ID}_$(git rev-parse --short HEAD 2>/dev/null || echo unknown)}
OUT_ROOT="$CIFAR100_ROOT/outputs/cifar100_speedrun/${RUN_ID}"
if [[ "$RECORD" == "1" && "$VALIDATION_SOURCE" != "official" ]]; then
  echo "Refusing RECORD=1 without VALIDATION_SOURCE=official." >&2
  echo "Record evidence must use the frozen official validation split." >&2
  exit 5
fi
if [[ "$RECORD" == "1" && "$RUNS" != "30" ]]; then
  echo "Refusing RECORD=1 with RUNS=$RUNS; official record mode requires exactly 30 paired seeds." >&2
  echo "Use RECORD=0 VALIDATION_SOURCE=train_dev for underpowered pilots." >&2
  exit 6
fi
if [[ "$VALIDATION_SOURCE" == "official" && "$RECORD" != "1" ]]; then
  echo "Refusing official validation in paired_compare.sh without RECORD=1." >&2
  echo "Default paired pilots use VALIDATION_SOURCE=train_dev; official is only for pre-registered record evidence." >&2
  exit 4
fi
if [[ -e "$OUT_ROOT" ]]; then
  echo "Refusing to reuse output directory: $OUT_ROOT" >&2
  exit 3
fi
mkdir -p "$OUT_ROOT"
ORDER_FILE="$OUT_ROOT/paired_order.csv"
printf "pair_index,seed,first,second\n" > "$ORDER_FILE"

run_method() {
  local label="$1"
  local order="$2"
  local seed="$3"
  local pair_index="$4"
  local out_dir
  out_dir=$(printf "%s/seed%04d_%s_%s" "$OUT_ROOT" "$pair_index" "$order" "$label")
  mkdir -p "$out_dir"
  echo "===== seed=${seed} pair_index=${pair_index} order=${order} label=${label} epochs=${EPOCHS} target=${TARGET} validation_source=${VALIDATION_SOURCE} ====="
  C100_RUNS=1 \
  C100_EPOCHS=$EPOCHS \
  C100_TARGET=$TARGET \
  C100_SEED_BASE=$seed \
  C100_VALIDATION_SOURCE=$VALIDATION_SOURCE \
  C100_COMPILE=${C100_COMPILE:-1} \
  C100_COMPILE_MODE=${C100_COMPILE_MODE:-default} \
  C100_BATCH=${C100_BATCH:-${BATCH:-1024}} \
  C100_MUON_LR=${C100_MUON_LR:-${MUON_LR:-0.035}} \
  C100_BIAS_LR=${C100_BIAS_LR:-${BIAS_LR:-0.02}} \
  C100_SLEEP_CYCLES=${C100_SLEEP_CYCLES:-1000000000} \
  C100_OUTPUT_DIR="$out_dir" \
  python train_cifar100_resnet_muon.py
}

# Candidate overrides are passed through CANDIDATE_ENV, for example:
# CANDIDATE_ENV='C100_MUON_LR=0.032 C100_BIAS_LR=0.018'
run_candidate() {
  local order="$1"
  local seed="$2"
  local pair_index="$3"
  if [[ -n "${CANDIDATE_ENV:-}" ]]; then
    env ${CANDIDATE_ENV} bash -c "$(declare -f run_method); EPOCHS='$EPOCHS' TARGET='$TARGET' VALIDATION_SOURCE='$VALIDATION_SOURCE' OUT_ROOT='$OUT_ROOT'; run_method candidate '$order' '$seed' '$pair_index'"
  else
    run_method candidate "$order" "$seed" "$pair_index"
  fi
}

for ((i = 0; i < RUNS; i++)); do
  seed=$((BASE_SEED + i))
  pair_index=$((i + 1))
  if (( i % 2 == 0 )); then
    printf "%d,%d,baseline,candidate\n" "$pair_index" "$seed" >> "$ORDER_FILE"
    run_method baseline A "$seed" "$pair_index"
    run_candidate B "$seed" "$pair_index"
  else
    printf "%d,%d,candidate,baseline\n" "$pair_index" "$seed" >> "$ORDER_FILE"
    run_candidate A "$seed" "$pair_index"
    run_method baseline B "$seed" "$pair_index"
  fi
done

python - <<'PY' "$OUT_ROOT" "${CANDIDATE_ENV:-}" "$VALIDATION_SOURCE" "$RECORD"
import csv, json, statistics, sys
from pathlib import Path

root = Path(sys.argv[1])
candidate_env = sys.argv[2].strip()
validation_source = sys.argv[3]
record = sys.argv[4] == "1"

def rows(path):
    with path.open() as f:
        return list(csv.DictReader(f))

def by_seed(label):
    out = {}
    for metrics in sorted(root.glob(f"*_{label}/metrics.csv")):
        for row in rows(metrics):
            seed = int(row["seed"])
            out.setdefault(seed, []).append(row)
    return out

def first_config(label):
    configs = sorted(root.glob(f"*_{label}/config.json"))
    if not configs:
        return None
    return json.loads(configs[0].read_text())

def order_by_seed():
    path = root / "paired_order.csv"
    with path.open() as f:
        return {int(row["seed"]): row for row in csv.DictReader(f)}

baseline_config = first_config("baseline")
candidate_config = first_config("candidate")
compare_fields = [
    "epochs",
    "batch_size",
    "target",
    "validation_source",
    "dev_per_class",
    "dev_split_seed",
    "compile",
    "compile_mode",
    "muon_lr",
    "bias_lr",
]
if candidate_env and baseline_config and candidate_config:
    if all(baseline_config.get(field) == candidate_config.get(field) for field in compare_fields):
        raise SystemExit("CANDIDATE_ENV was set, but candidate config matches baseline on all tracked training fields.")

baseline = by_seed("baseline")
candidate = by_seed("candidate")
orders = order_by_seed()
common = sorted(set(baseline) & set(candidate))
pairs = []
for seed in common:
    b_time = statistics.fmean(float(r["time_seconds"]) for r in baseline[seed])
    c_time = statistics.fmean(float(r["time_seconds"]) for r in candidate[seed])
    b_acc = statistics.fmean(float(r["val_acc"]) for r in baseline[seed])
    c_acc = statistics.fmean(float(r["val_acc"]) for r in candidate[seed])
    pairs.append({
        "seed": seed,
        "order": f'{orders.get(seed, {}).get("first")}/{orders.get(seed, {}).get("second")}',
        "baseline_time": b_time,
        "candidate_time": c_time,
        "time_ratio": c_time / b_time if b_time else float("nan"),
        "baseline_val_acc": b_acc,
        "candidate_val_acc": c_acc,
        "val_acc_delta": c_acc - b_acc,
    })

summary = {
    "paired_seeds": len(pairs),
    "validation_source": validation_source,
    "record_mode": record,
    "candidate_env": candidate_env,
    "order_file": "paired_order.csv",
    "counterbalance": "per-seed alternating AB/BA; pilot-grade, with one trainer invocation per method per seed",
    "mean_time_ratio": statistics.fmean(p["time_ratio"] for p in pairs) if pairs else None,
    "mean_time_delta": statistics.fmean(p["candidate_time"] - p["baseline_time"] for p in pairs) if pairs else None,
    "mean_val_acc_delta": statistics.fmean(p["val_acc_delta"] for p in pairs) if pairs else None,
    "pairs": pairs,
}
(root / "paired_summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True) + "\n")
print(json.dumps(summary, indent=2, sort_keys=True))
PY

LOG_OUT="$CIFAR100_ROOT/logs/paired-${SLURM_JOB_ID}.out"
LOG_ERR="$CIFAR100_ROOT/logs/paired-${SLURM_JOB_ID}.err"
cp "$LOG_OUT" "$OUT_ROOT/stdout.log"
if [[ -f "$LOG_ERR" ]]; then
  cp "$LOG_ERR" "$OUT_ROOT/stderr.log"
fi
echo "==> done $(date)"
