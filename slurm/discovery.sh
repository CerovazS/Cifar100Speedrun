#!/bin/bash
#SBATCH --job-name=c100-discovery
#SBATCH --account=IscrC_SIMP
#SBATCH --partition=boost_usr_prod
#SBATCH --qos=boost_qos_dbg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=64G
#SBATCH --time=00:30:00
#SBATCH --output=/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun/logs/discovery-%j.out
#SBATCH --error=/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun/logs/discovery-%j.err
set -euo pipefail
if [[ "${SLURM_JOB_ACCOUNT:-}" != "iscrc_simp" && "${SLURM_JOB_ACCOUNT:-}" != "IscrC_SIMP" ]]; then
  echo "Refusing to run outside IscrC_SIMP." >&2
  exit 2
fi
cd /leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun
source env_setup.sh
echo "==> $(date) job=${SLURM_JOB_ID:-N/A} node=$(hostname)"
nvidia-smi --query-gpu=index,name,memory.total,driver_version --format=csv
python prepare_cifar100_hf.py
RUNS=${RUNS:-5}
TARGET=${TARGET:-0.70}
for EPOCHS in ${EPOCHS_LIST:-4 8 12 16 20}; do
  echo "===== CIFAR100 discovery epochs=${EPOCHS} runs=${RUNS} target=${TARGET} ====="
  RUN_ID=${RUN_ID_PREFIX:-discovery_${SLURM_JOB_ID}_$(git rev-parse --short HEAD 2>/dev/null || echo unknown)}_epochs${EPOCHS}
  OUT_DIR=/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun/outputs/cifar100_speedrun/${RUN_ID}
  if [[ -e "$OUT_DIR" ]]; then
    echo "Refusing to reuse output directory: $OUT_DIR" >&2
    exit 3
  fi
  mkdir -p "$OUT_DIR"
  C100_RUNS=$RUNS C100_EPOCHS=$EPOCHS C100_TARGET=$TARGET C100_VALIDATION_SOURCE=train_dev C100_COMPILE=1 C100_COMPILE_MODE=default C100_BATCH=${BATCH:-1024} C100_SEED_BASE=${SEED_BASE:-880000} C100_MUON_LR=${MUON_LR:-0.035} C100_BIAS_LR=${BIAS_LR:-0.02} C100_SLEEP_CYCLES=1000000000 C100_OUTPUT_DIR="$OUT_DIR" python train_cifar100_resnet_muon.py
  echo
 done
echo "==> done $(date)"
