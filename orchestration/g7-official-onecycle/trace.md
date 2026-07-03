# G7 Official One-Cycle Finalist Trace

## Claim

The `onecycle-default` candidate can beat the current official baseline speed while clearing the official CIFAR-100 validation target.

## Hypothesis

Train-dev dev10 showed the 14-epoch one-cycle schedule improves accuracy over the 14-epoch cosine control with no time penalty. Against the record baseline, the candidate should run at 14 epochs instead of the default 16 while preserving enough official validation accuracy to keep `mean(val_acc) > 0.70`.

## Pre-Registration

- Candidate: `onecycle-default`
- Baseline: default `SimpleResNet`/Muon, `16` epochs, cosine schedule
- Candidate env: `C100_EPOCHS=14 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0`
- Validation: official CIFAR-100 test split as fixed plain validation
- Record mode: `RECORD=1`
- Runs: exactly `30` paired seeds
- Base seed: `880000`
- Output run id: `g7official_onecycle_default_20260703T203139Z`
- Output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7official_onecycle_default_20260703T203139Z`

## Decision Criterion

Claim a candidate only if all checks pass:

- job completes `0:0`;
- `paired_summary.json` exists;
- `record_mode=true`;
- `validation_source=official`;
- `paired_seeds=30`;
- official split prep includes `train,test`;
- baseline config has `epochs=16`;
- candidate config has `epochs=14`, `lr_schedule=onecycle`, `onecycle_pct_up=0.30`, `onecycle_div_factor=10.0`;
- candidate mean official `val_acc > 0.700`;
- candidate mean paired time ratio `< 1.0`;
- no validation path, timing boundary, TTA, adaptation, or output reuse violation.

## Walltime Fix

The default `slurm/paired_compare.sh` debug settings are insufficient for official `RUNS=30`: dev10 took `00:16:43`, so 30 pairs are estimated at about `50` minutes. Submit with command-line overrides:

- `--qos=boost_qos_lprod`
- `--time=01:30:00`

## Command

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
test ! -e outputs/cifar100_speedrun/g7official_onecycle_default_20260703T203139Z
RUN_ID=g7official_onecycle_default_20260703T203139Z \
RECORD=1 \
RUNS=30 \
EPOCHS=16 \
VALIDATION_SOURCE=official \
BASE_SEED=880000 \
CANDIDATE_ENV='C100_EPOCHS=14 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0' \
sbatch --qos=boost_qos_lprod --time=01:30:00 slurm/paired_compare.sh
```

## Stop Conditions

Do not launch unless local patch, remote patch, remote `bash -n`, output absence, and queue checks pass. Do not cancel or interrupt other compliant workstreams.

## Submission Attempts

- Attempt with `--qos=boost_qos_bprod --time=01:30:00` failed before allocation with `QOSMinCpuNotSatisfied`; no output directory was created.
- `boost_qos_lprod` was selected for retry because it has a `04:00:00` max walltime and no single-job MinCPU requirement in `sacctmgr`.
- Submitted with `--qos=boost_qos_lprod --time=01:30:00`: job `48439897`, initial state `PENDING (Priority)`.

## Completion

- Job `48439897` completed `0:0` on `lrdn2463` in `00:48:54`.
- Output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7official_onecycle_default_20260703T203139Z`
- Local curated artifacts:
  - `orchestration/g7-official-onecycle/paired_summary.json`
  - `orchestration/g7-official-onecycle/paired_order.csv`
  - `orchestration/g7-official-onecycle/paired-48439897.out`
  - `orchestration/g7-official-onecycle/paired-48439897.err`
  - `orchestration/g7-official-onecycle/sacct-48439897.txt`
- Raw local mirror, not intended as the curated commit surface: `orchestration/g7-official-onecycle/remote-artifacts/`

## Final Checks Before Critic

- `record_mode=true`
- `validation_source=official`
- `paired_seeds=30`
- Split files printed at launch:
  - `cifar100/train.pt: exists images=(50000, 32, 32, 3) labels=(50000,)`
  - `cifar100/test.pt: exists images=(10000, 32, 32, 3) labels=(10000,)`
- 60 per-seed config files were checked locally:
  - all baseline configs: `epochs=16.0`, `lr_schedule=cosine`, `validation_source=official`, `no_tta=true`
  - all candidate configs: `epochs=14.0`, `lr_schedule=onecycle`, `onecycle_pct_up=0.3`, `onecycle_div_factor=10.0`, `validation_source=official`, `no_tta=true`
- SLURM stderr is empty.

## Final Metrics

| Metric | Value |
| --- | ---: |
| candidate mean official val acc | `0.713300` |
| baseline mean official val acc | `0.708300` |
| mean official val acc delta | `+0.005000` |
| candidate min official val acc | `0.708600` |
| baseline min official val acc | `0.701800` |
| candidate target hits | `30/30` |
| baseline target hits | `30/30` |
| candidate mean timed seconds | `22.911267` |
| baseline mean timed seconds | `26.326719` |
| mean time delta | `-3.415452s` |
| mean time ratio | `0.870868` |
| max pair time ratio | `0.880533` |
| negative accuracy-delta pairs | `3/30` |

Independent critic status: PASS. The result is valid official finalist evidence and ready for Flywheel logging.
