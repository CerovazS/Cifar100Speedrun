#!/bin/bash
#SBATCH --job-name=c100-g5t1-lr
#SBATCH --account=IscrC_SIMP
#SBATCH --partition=boost_usr_prod
#SBATCH --qos=boost_qos_dbg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=64G
#SBATCH --time=00:30:00
#SBATCH --output=logs/g5t1-lr-sweep-%j.out
#SBATCH --error=logs/g5t1-lr-sweep-%j.err
set -euo pipefail

if [[ "${SLURM_JOB_ACCOUNT:-}" != "iscrc_simp" && "${SLURM_JOB_ACCOUNT:-}" != "IscrC_SIMP" ]]; then
  echo "Refusing to run outside IscrC_SIMP." >&2
  exit 2
fi

if [[ -z "${CIFAR100_ROOT:-}" ]]; then
  if [[ -n "${SLURM_SUBMIT_DIR:-}" && -d "$SLURM_SUBMIT_DIR/cifar100-benchmark" ]]; then
    CIFAR100_ROOT=$(cd "$SLURM_SUBMIT_DIR" && pwd -P)
  else
    CIFAR100_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)
  fi
fi
export CIFAR100_ROOT
cd "$CIFAR100_ROOT"
mkdir -p logs outputs/cifar100_speedrun
source "$CIFAR100_ROOT/env_setup.sh"

RUN_ID_STEM=${RUN_ID_STEM:-g5t1_20260703_164215_dev3_ep14}
RUNS=${RUNS:-3}
EPOCHS=${EPOCHS:-14}
TARGET=${TARGET:-0.70}
BATCH=${BATCH:-1024}
SEED_BASE=${SEED_BASE:-880000}
LR_LIST=${LR_LIST:-"0.030:0030 0.040:0040 0.045:0045"}
OUT_DIRS=()

copy_logs() {
  local log_out="$CIFAR100_ROOT/logs/g5t1-lr-sweep-${SLURM_JOB_ID}.out"
  local log_err="$CIFAR100_ROOT/logs/g5t1-lr-sweep-${SLURM_JOB_ID}.err"
  for out_dir in "${OUT_DIRS[@]}"; do
    [[ -d "$out_dir" && -f "$log_out" ]] && cp "$log_out" "$out_dir/stdout.log" || true
    [[ -d "$out_dir" && -f "$log_err" ]] && cp "$log_err" "$out_dir/stderr.log" || true
  done
}
trap copy_logs EXIT

echo "==> $(date) job=${SLURM_JOB_ID:-N/A} node=$(hostname)"
nvidia-smi --query-gpu=index,uuid,name,memory.total,driver_version --format=csv
python prepare_cifar100_hf.py

for spec in $LR_LIST; do
  lr=${spec%%:*}
  tag=${spec##*:}
  run_id="${RUN_ID_STEM}_muonlr${tag}_epochs${EPOCHS}"
  out_dir="$CIFAR100_ROOT/outputs/cifar100_speedrun/${run_id}"
  if [[ -e "$out_dir" ]]; then
    echo "Refusing to reuse output directory: $out_dir" >&2
    exit 3
  fi
  mkdir -p "$out_dir"
  OUT_DIRS+=("$out_dir")
  echo "===== G5-T1 LR sweep lr=${lr} epochs=${EPOCHS} runs=${RUNS} target=${TARGET} validation_source=train_dev ====="
  C100_RUNS=$RUNS \
  C100_EPOCHS=$EPOCHS \
  C100_TARGET=$TARGET \
  C100_VALIDATION_SOURCE=train_dev \
  C100_COMPILE=1 \
  C100_COMPILE_MODE=default \
  C100_BATCH=$BATCH \
  C100_SEED_BASE=$SEED_BASE \
  C100_MUON_LR=$lr \
  C100_BIAS_LR=${BIAS_LR:-0.02} \
  C100_SLEEP_CYCLES=1000000000 \
  C100_OUTPUT_DIR="$out_dir" \
  python train_cifar100_resnet_muon.py
  echo
done

echo "==> done $(date)"
