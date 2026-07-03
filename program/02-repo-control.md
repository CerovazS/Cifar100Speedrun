# Repo Control Plan

## Context Summary

The repository is a small script-first CIFAR-100 benchmark. It now has `pyproject.toml` and `uv.lock` for dependency control, but still has no `src/`, Hydra config, Lightning trainer, tests, or committed `outputs/` tree. This is a deliberate micro-benchmark surface, but it conflicts with the shared stack expectations and needs a narrow local exception or staged cleanup.

Current branch: `main` at `626cd93`. The worktree is clean except untracked `.env`, which contains the Flywheel root mapping and must not be committed or exposed.

## Entry Points

- Training: `cifar100-benchmark/train_cifar100_resnet_muon.py`
- Data prep from HF parquet: `cifar100-benchmark/prepare_cifar100_hf.py`
- Data prep from torchvision: `cifar100-benchmark/prepare_cifar100.py`
- Log analysis: `cifar100-benchmark/analyze_cifar100.py`
- SLURM smoke: `slurm/smoke.sh`
- SLURM discovery: `slurm/discovery.sh`
- SLURM official baseline: `slurm/official_baseline.sh`
- Environment: `env_setup.sh`

## Benchmark Contract

Valid optimization surfaces:

- model architecture
- optimizer
- training hyperparameters inside the timed training loop

Invalid optimization surfaces for records:

- validation data, labels, preprocessing, evaluation function, validation batch behavior
- validation-time augmentation/adaptation/ensembling/confidence branches
- timing boundary, compile/warmup treatment, cache tricks, data staging tricks, logging tricks

## Current Risks

- `C100_COMPILE=0` crashes because `off` is unquoted in the trainer config print.
- `TARGET` in `slurm/discovery.sh` and `slurm/official_baseline.sh` is not passed as `C100_TARGET`.
- `official_baseline.sh` ignores analyzer failures with `|| true`.
- `SMOKE_RESULT.md` has stale `50-run` wording.
- `env_setup.sh` activates the CIFAR-100-specific `uv` environment at `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/envs/venv311`.
- SLURM scripts bill `IscrC_SIMP` and must stage under `/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun`.
- No machine-readable metrics, unique run directory, plots, reproducibility notes, or paired runner exist.
- Search currently risks repeated official-test exposure because the official test split is the validation gate.

## Verification Sequence

Local before CINECA:

```bash
bash -n env_setup.sh
bash -n slurm/smoke.sh
bash -n slurm/discovery.sh
bash -n slurm/official_baseline.sh
python3 - <<'PY'
import ast
from pathlib import Path
for p in sorted(Path("cifar100-benchmark").glob("*.py")):
    ast.parse(p.read_text(), filename=str(p))
    print(f"ast ok {p}")
PY
```

Remote read-only CINECA check:

```bash
cd /leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun
source env_setup.sh
python --version
python - <<'PY'
import torch, torchvision, numpy, pyarrow, PIL
print("torch", torch.__version__, "cuda", torch.version.cuda, "available", torch.cuda.is_available())
PY
mkdir -p logs
python prepare_cifar100_hf.py
ls -lh cifar100/train.pt cifar100/test.pt
```

Interactive GPU smoke before batch:

```bash
srun -p boost_usr_prod -A IscrC_SIMP --gres=gpu:1 --cpus-per-task=8 --mem=64G --time=00:20:00 --pty bash
cd /leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun
source env_setup.sh
python prepare_cifar100_hf.py
C100_RUNS=1 C100_EPOCHS=0.05 C100_TARGET=0.01 C100_SLEEP_CYCLES=0 python train_cifar100_resnet_muon.py
```

## No-Run Gates

- Confirm remote path, log directory, account/storage split, modules, venv, imports, and GPU availability.
- Fix P0/P1 script bugs before non-default target, eager ablation, or official baseline.
- Add isolated output and paired runner before record claims.
- Use train-derived dev validation for search, not official test.
