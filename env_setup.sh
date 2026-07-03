#!/bin/bash
set -euo pipefail
module purge >/dev/null 2>&1 || true
module load profile/deeplrn >/dev/null 2>&1 || true
module load python/3.11.7 >/dev/null 2>&1 || true
module load cuda/12.6 >/dev/null 2>&1 || true
export CIFAR100_ROOT=/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun
export CIFAR100_VENV=/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/envs/venv311
export PIP_CACHE_DIR=/leonardo_work/IscrC_SIMP/lcerovaz/.cache/pip
export TORCH_HOME=/leonardo_work/IscrC_SIMP/lcerovaz/.cache/torch
export TORCHINDUCTOR_CACHE_DIR=/leonardo_work/IscrC_SIMP/lcerovaz/.cache/torchinductor
export TRITON_CACHE_DIR=/leonardo_work/IscrC_SIMP/lcerovaz/.cache/triton
cd "$CIFAR100_ROOT/cifar100-benchmark"
if [[ ! -f "$CIFAR100_VENV/bin/activate" ]]; then
  echo "[env_setup] missing $CIFAR100_VENV; run 'UV_PROJECT_ENVIRONMENT=$CIFAR100_VENV UV_LINK_MODE=copy uv sync --python 3.11' from $CIFAR100_ROOT first" >&2
  exit 2
fi
source "$CIFAR100_VENV/bin/activate"
echo "[env_setup] cifar100 ready (python=$(python --version))"
