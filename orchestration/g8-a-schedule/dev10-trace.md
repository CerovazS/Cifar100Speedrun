# G8-A One-Cycle Longwarm Dev10 Trace

## Objective

Launch and babysit paired train-dev dev10 for `13ep-onecycle-longwarm` only, after independent critic PASS. This is exploratory train-dev evidence only. No code edits, remote sync, official validation, or G8-B Muon patch contamination is allowed.

## Claim

The 13-epoch one-cycle long-warmup schedule that passed G8-A dev3 can preserve the train-dev accuracy margin over the 14-epoch baseline while reducing timed training by at least 5% over 10 paired seeds.

## Hypothesis

Dev3 longwarm had candidate mean train-dev accuracy `0.708733`, mean delta `+0.012800`, and mean time ratio `0.931130`, with all three candidate seeds above `0.70`. If this is not a small-sample artifact, dev10 should retain candidate mean train-dev accuracy `>=0.700`, mean accuracy delta `>=+0.0025`, and mean time ratio `<=0.95`.

## Decision Criterion

This workstream reports the dev10 result only. It must not promote to official validation. A later official/finalist step requires separate critic and pre-registration.

Dev10 sanity gate:

- SLURM job completed with exit `0:0`.
- `record_mode=false`.
- `validation_source=train_dev`.
- `paired_seeds=10`.
- Baseline uses `EPOCHS=14`.
- Candidate differs only on declared `C100_EPOCHS`, `C100_LR_SCHEDULE`, `C100_ONECYCLE_PCT_UP`, and `C100_ONECYCLE_DIV_FACTOR`.
- Candidate mean train-dev accuracy `>=0.700`.
- Mean train-dev accuracy delta `>=+0.0025`.
- Mean time ratio `<=0.95`.

## Preflight

- Local write scope: `orchestration/g8-a-schedule/` only.
- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`.
- Remote commit before launch: `2c3edb7`.
- Remote dirty state before launch: untracked `orchestration/g6-official-retrain/` only.
- No remote sync performed; the new local G8-B Muon patch was intentionally not synced.
- Remote `bash -n slurm/paired_compare.sh`: passed.
- Remote `source env_setup.sh >/dev/null && python -m py_compile train_cifar100_resnet_muon.py`: passed.
- `squeue -u $USER`: no active jobs listed before launch.

## Launch Metadata

- Run id: `g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z`
- Remote output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z`
- `RECORD=0`
- `VALIDATION_SOURCE=train_dev`
- `RUNS=10`
- `EPOCHS=14`
- `BASE_SEED=890000`
- Candidate env: `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0`

## Command

```bash
ssh leonardo 'cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun && test ! -e outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z && RUN_ID=g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z RECORD=0 RUNS=10 EPOCHS=14 VALIDATION_SOURCE=train_dev BASE_SEED=890000 CANDIDATE_ENV="C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0" sbatch slurm/paired_compare.sh'
```

## Stop Conditions

Do not launch or relaunch into the same run id if the output path exists, queue has an active conflicting job, wrapper checks fail, validation source is not `train_dev`, record mode is enabled, candidate config differs on undeclared fields, or any code/validation/timing change is needed.

## Submission

- Output path absence check passed immediately before submit.
- Submitted SLURM job: `48447004`.
- Initial state: `PENDING`, then `RUNNING` on `lrdn2543`.

## Completion

`sacct`:

| Job | State | Exit | Elapsed | Node |
| --- | --- | --- | --- | --- |
| `48447004` | `COMPLETED` | `0:0` | `00:15:53` | `lrdn2543` |

Wrapper summary:

| Field | Value |
| --- | ---: |
| `record_mode` | `false` |
| `validation_source` | `train_dev` |
| `paired_seeds` | `10` |
| baseline mean train-dev acc | `0.695640` |
| candidate mean train-dev acc | `0.706500` |
| mean train-dev acc delta | `+0.010860` |
| mean time ratio | `0.929460` |
| mean time delta | `-1.430557s` |
| target hits | `10/10` |
| positive deltas | `10/10` |
| minimum candidate train-dev acc | `0.700600` |
| maximum per-seed time ratio | `0.935288` |

The dev10 train-dev sanity gate passes. This does not promote the candidate to official validation; that requires separate critic and pre-registration.

## Remote Artifacts

- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z/paired_summary.json`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z/paired_order.csv`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z/stdout.log`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z/stderr.log`

Curated local mirrors:

- `orchestration/g8-a-schedule/remote-artifacts/dev10-longwarm/paired_summary.json`
- `orchestration/g8-a-schedule/remote-artifacts/dev10-longwarm/paired_order.csv`
- `orchestration/g8-a-schedule/remote-artifacts/dev10-longwarm/stdout.log`
- `orchestration/g8-a-schedule/remote-artifacts/dev10-longwarm/stderr.log`
- `orchestration/g8-a-schedule/paired-48447004.out`
- `orchestration/g8-a-schedule/paired-48447004.err`
- `orchestration/g8-a-schedule/sacct-48447004.txt`
