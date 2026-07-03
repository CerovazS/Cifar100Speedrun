# Reproducibility

## Repository

- Repository URL: `https://github.com/MarioPaerle/Cifar100Speedrun`
- Branch used on Leonardo: `codex/cifar100-speedrun-control`
- Run code commit recorded in configs: `2c3edb798dc27d512109a7c49eb8ede82b84c023`
- Local curation base before this run: `33767af`

## Environment

- System: CINECA Leonardo
- Account: `IscrC_SIMP`
- Node for official run: `lrdn2334`
- GPU: `NVIDIA A100-SXM-64GB`
- Python from launch log: `Python 3.11.15`
- Checkout path: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Runtime working directory after setup: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/cifar100-benchmark`

## Files

- `env_setup.sh`: activates the Leonardo runtime and changes into `cifar100-benchmark`.
- `prepare_cifar100_hf.py`: prepares cached CIFAR-100 tensor split files.
- `train_cifar100_resnet_muon.py`: trains/evaluates one run of the SimpleResNet/Muon speedrun model.
- `slurm/paired_compare.sh`: launches paired baseline/candidate runs, validates official/record gates, alternates AB/BA order, and writes `paired_summary.json`.
- `orchestration/g8-official-longwarm/paired_summary.json`: aggregate official paired result.
- `orchestration/g8-official-longwarm/paired_order.csv`: paired seed/order file.
- `orchestration/g8-official-longwarm/paired-48449520.out`: SLURM stdout with split, GPU, config, and per-pair logs.
- `orchestration/g8-official-longwarm/paired-48449520.err`: SLURM stderr; empty for this run.

## Command

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
test ! -e outputs/cifar100_speedrun/g8official_13ep_onecycle_longwarm_20260703T221900Z
RUN_ID=g8official_13ep_onecycle_longwarm_20260703T221900Z \
RECORD=1 \
RUNS=30 \
EPOCHS=16 \
VALIDATION_SOURCE=official \
BASE_SEED=880000 \
CANDIDATE_ENV='C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0' \
sbatch --qos=boost_qos_lprod --time=01:30:00 slurm/paired_compare.sh
```

## Data And Splits

The launch log records:

- `cifar100/train.pt: exists images=(50000, 32, 32, 3) labels=(50000,)`
- `cifar100/test.pt: exists images=(10000, 32, 32, 3) labels=(10000,)`

The official run used `record_mode=true`, `validation_source=official`, and 30 paired seeds. The candidate and baseline both evaluated the official validation target without TTA.

## Non-Default Hyperparameters

Shared baseline defaults:

- batch size: `1024`
- architecture widths: `[64, 128, 256]`
- blocks: `[2, 2, 2]`
- label smoothing: `0.05`
- cutout size: `0`
- Muon LR: `0.035`
- bias LR: `0.02`
- compile: enabled, mode `default`
- target: `0.70`
- base seed: `880000`

Baseline:

- epochs: `16`
- schedule: `cosine`

Candidate:

- epochs: `13`
- schedule: `onecycle`
- one-cycle `pct_up`: `0.40`
- one-cycle `div_factor`: `10.0`

## Hardware And Scheduler

- Scheduler job id: `48449520`
- QoS: `boost_qos_lprod`
- Walltime requested: `01:30:00`
- Actual elapsed: `00:50:42`
- Nodes: `1`
- GPU count: `1` A100

## Expected Output

The run writes to:

```text
outputs/cifar100_speedrun/g8official_13ep_onecycle_longwarm_20260703T221900Z/
```

Expected key files:

- `paired_summary.json`
- `paired_order.csv`
- one directory per seed/method pair, each containing `config.json`, `metrics.csv`, `summary.json`, `warmup.json`, and `repro_metadata.json`

The reproduced result should be close to:

- candidate mean official validation accuracy: `0.713153`
- baseline mean official validation accuracy: `0.708000`
- candidate mean timed seconds: `21.720387`
- baseline mean timed seconds: `27.021371`
- mean time ratio: `0.804245`
