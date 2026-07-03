# G8-A One-Cycle Longwarm Dev10 Result

## Verdict

`13ep-onecycle-longwarm` passes paired train-dev dev10. Do not promote to official validation from this result alone; official validation requires a separate critic pass and pre-registration.

## Run Scope

- Validation: `train_dev`
- Record mode: `false`
- Runs: `10` paired seeds
- Seeds: `890000` through `890009`
- Baseline: `EPOCHS=14`
- Candidate: `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0`
- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Remote commit: `2c3edb7`
- Job: `48447004`, `COMPLETED`, exit `0:0`, elapsed `00:15:53`, node `lrdn2543`

## Metrics

| Metric | Value |
| --- | ---: |
| baseline mean train-dev accuracy | `0.695640` |
| candidate mean train-dev accuracy | `0.706500` |
| mean train-dev accuracy delta | `+0.010860` |
| mean time ratio | `0.929460` |
| mean time delta | `-1.430557s` |
| target hits | `10/10` |
| positive deltas | `10/10` |
| minimum candidate train-dev accuracy | `0.700600` |
| maximum per-seed time ratio | `0.935288` |

Predeclared sanity gate passed: candidate mean train-dev accuracy `>=0.700`, mean accuracy delta `>=+0.0025`, mean time ratio `<=0.95`, `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `RUNS=10`.

## Per-Seed Results

| Seed | Order | Baseline acc | Candidate acc | Acc delta | Baseline time | Candidate time | Time ratio |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `890000` | `baseline/candidate` | `0.6976` | `0.7080` | `+0.0104` | `20.2566` | `18.8221` | `0.9292` |
| `890001` | `candidate/baseline` | `0.6980` | `0.7076` | `+0.0096` | `20.2840` | `18.8594` | `0.9298` |
| `890002` | `baseline/candidate` | `0.7016` | `0.7106` | `+0.0090` | `20.2663` | `18.8414` | `0.9297` |
| `890003` | `candidate/baseline` | `0.6978` | `0.7100` | `+0.0122` | `20.2823` | `18.8339` | `0.9286` |
| `890004` | `baseline/candidate` | `0.6972` | `0.7018` | `+0.0046` | `20.2919` | `18.8487` | `0.9289` |
| `890005` | `candidate/baseline` | `0.6914` | `0.7038` | `+0.0124` | `20.2555` | `18.9448` | `0.9353` |
| `890006` | `baseline/candidate` | `0.6890` | `0.7006` | `+0.0116` | `20.2577` | `18.8449` | `0.9303` |
| `890007` | `candidate/baseline` | `0.6910` | `0.7038` | `+0.0128` | `20.3297` | `18.8716` | `0.9283` |
| `890008` | `baseline/candidate` | `0.6976` | `0.7118` | `+0.0142` | `20.2539` | `18.8361` | `0.9300` |
| `890009` | `candidate/baseline` | `0.6952` | `0.7070` | `+0.0118` | `20.3180` | `18.7873` | `0.9247` |

## Command

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
test ! -e outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z
RUN_ID=g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z \
RECORD=0 \
RUNS=10 \
EPOCHS=14 \
VALIDATION_SOURCE=train_dev \
BASE_SEED=890000 \
CANDIDATE_ENV='C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0' \
sbatch slurm/paired_compare.sh
```

## Outputs

- Remote output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev10_20260703T215530Z`
- Curated local mirror: `orchestration/g8-a-schedule/remote-artifacts/dev10-longwarm/`
- Local trace: `orchestration/g8-a-schedule/dev10-trace.md`
- Accounting: `orchestration/g8-a-schedule/sacct-48447004.txt`

## Risks

- This is train-dev exploratory evidence only, not official validation or a record claim.
- Official promotion requires independent critic review and pre-registration.
- Remote checkout retained unrelated untracked `orchestration/g6-official-retrain/`; no code, validation, timing, or G8-B Muon changes were synced for this run.
