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

- `--qos=boost_qos_bprod`
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
sbatch --qos=boost_qos_bprod --time=01:30:00 slurm/paired_compare.sh
```

## Stop Conditions

Do not launch unless local patch, remote patch, remote `bash -n`, output absence, and queue checks pass. Do not cancel or interrupt other compliant workstreams.
