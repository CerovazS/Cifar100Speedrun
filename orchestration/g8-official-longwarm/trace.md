# G8 Official 13-Epoch Longwarm Trace

## Claim

The 13-epoch one-cycle long-warmup candidate can beat the official 16-epoch cosine CIFAR-100 speedrun baseline while preserving the official validation target.

## Hypothesis

G8-A train-dev dev10 showed that `13ep-onecycle-longwarm` had candidate mean train-dev accuracy `0.706500`, mean delta `+0.010860`, `10/10` candidate target hits, and mean time ratio `0.929460` against a 14-epoch cosine control. If that train-derived signal transfers to official validation, the candidate should clear the `0.70` official validation target while reducing timed training relative to the default 16-epoch cosine baseline.

## Pre-Registration

- Candidate: `13ep-onecycle-longwarm`
- Baseline: default `SimpleResNet`/Muon, `16` epochs, cosine schedule
- Candidate env: `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0`
- Validation: official CIFAR-100 test split as fixed plain validation
- Record mode: `RECORD=1`
- Runs: exactly `30` paired seeds
- Base seed: `880000`
- Output run id: `g8official_13ep_onecycle_longwarm_20260703T221900Z`
- Remote code commit: `2c3edb798dc27d512109a7c49eb8ede82b84c023`
- Output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8official_13ep_onecycle_longwarm_20260703T221900Z`

## Decision Criterion

Claim a candidate only if all checks pass:

- job completes `0:0`;
- `paired_summary.json` exists;
- `record_mode=true`;
- `validation_source=official`;
- `paired_seeds=30`;
- official split prep includes `train,test`;
- baseline config has `epochs=16`, `lr_schedule=cosine`;
- candidate config has `epochs=13`, `lr_schedule=onecycle`, `onecycle_pct_up=0.40`, `onecycle_div_factor=10.0`;
- candidate mean official `val_acc > 0.700`;
- candidate target hits are not catastrophically fragile;
- candidate mean paired time ratio `< 1.0`;
- no validation path, timing boundary, TTA, adaptation, or output reuse violation.

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

## Stop Conditions

Do not launch unless the remote wrapper syntax check, trainer py_compile through `env_setup.sh`, output absence, and queue checks pass. Do not cancel or interrupt other compliant workstreams.

## Preflight And Submission

- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Remote code commit: `2c3edb798dc27d512109a7c49eb8ede82b84c023`
- Remote dirty state: unrelated untracked quarantined `orchestration/g6-official-retrain/`
- Output absence check: passed
- `bash -n slurm/paired_compare.sh`: passed
- `source env_setup.sh >/dev/null && python -m py_compile train_cifar100_resnet_muon.py`: passed
- Queue before launch: empty
- Submitted batch job: `48449520`
- Initial state: `PENDING`

## Completion

- Job `48449520` completed `0:0` on `lrdn2334` in `00:50:42`.
- Output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8official_13ep_onecycle_longwarm_20260703T221900Z`
- Local curated artifacts:
  - `orchestration/g8-official-longwarm/paired_summary.json`
  - `orchestration/g8-official-longwarm/paired_order.csv`
  - `orchestration/g8-official-longwarm/paired-48449520.out`
  - `orchestration/g8-official-longwarm/paired-48449520.err`
  - `orchestration/g8-official-longwarm/sacct-48449520.txt`
- Raw local mirror: `orchestration/g8-official-longwarm/remote-artifacts/`

## Final Metrics Before Critic

| Metric | Value |
| --- | ---: |
| candidate mean official val acc | `0.713153` |
| baseline mean official val acc | `0.708000` |
| mean official val acc delta | `+0.005153` |
| candidate min official val acc | `0.706600` |
| baseline min official val acc | `0.703900` |
| candidate target hits | `30/30` |
| baseline target hits | `30/30` |
| candidate mean timed seconds | `21.720387` |
| baseline mean timed seconds | `27.021371` |
| mean time delta | `-5.300984s` |
| mean time ratio | `0.804245` |
| max pair time ratio | `0.823594` |
| positive accuracy-delta pairs | `25/30` |
| negative accuracy-delta pairs | `5/30` |

Independent critic status: PASS. The result is valid official finalist evidence and ready for Flywheel logging.
