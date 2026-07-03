#!/bin/bash
#SBATCH --job-name=c100-smoke
#SBATCH --account=IscrC_SIMP
#SBATCH --partition=boost_usr_prod
#SBATCH --qos=boost_qos_dbg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --mem=64G
#SBATCH --time=00:10:00
#SBATCH --output=/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun/logs/smoke-%j.out
#SBATCH --error=/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun/logs/smoke-%j.err
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
RUN_ID=${RUN_ID:-smoke_${SLURM_JOB_ID}_$(git rev-parse --short HEAD 2>/dev/null || echo unknown)}
OUT_DIR=/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun/outputs/cifar100_speedrun/${RUN_ID}
if [[ -e "$OUT_DIR" ]]; then
  echo "Refusing to reuse output directory: $OUT_DIR" >&2
  exit 3
fi
mkdir -p "$OUT_DIR"
C100_RUNS=1 C100_EPOCHS=0.05 C100_TARGET=0.01 C100_VALIDATION_SOURCE=train_dev C100_COMPILE=1 C100_COMPILE_MODE=default C100_BATCH=1024 C100_SEED_BASE=880000 C100_MUON_LR=0.035 C100_BIAS_LR=0.02 C100_SLEEP_CYCLES=0 C100_OUTPUT_DIR="$OUT_DIR" python train_cifar100_resnet_muon.py
echo "==> smoke done $(date)"
