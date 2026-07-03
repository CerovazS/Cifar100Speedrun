# G8 Official 13-Epoch Longwarm Result

## Verdict

PASS after independent result critic.

The 13-epoch one-cycle long-warmup candidate beat the 16-epoch cosine baseline on official 30-run paired evidence while keeping every candidate seed above the `0.70` official validation target.

## Run Scope

- Job: `48449520`
- State: `COMPLETED`, exit `0:0`
- Node: `lrdn2334`
- Elapsed: `00:50:42`
- Account: `IscrC_SIMP`
- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Run id: `g8official_13ep_onecycle_longwarm_20260703T221900Z`
- Record mode: `true`
- Validation: official CIFAR-100 test split as fixed plain validation
- Paired seeds: `30`, base seed `880000`
- Candidate env: `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0`

## Results

| Metric | Candidate | Baseline | Delta/ratio |
| --- | ---: | ---: | ---: |
| mean official val acc | `0.713153` | `0.708000` | `+0.005153` |
| min official val acc | `0.706600` | `0.703900` | n/a |
| target hits | `30/30` | `30/30` | n/a |
| mean timed seconds | `21.720387` | `27.021371` | `-5.300984s` |
| mean time ratio | n/a | n/a | `0.804245` |
| max pair time ratio | n/a | n/a | `0.823594` |

Accuracy delta was positive on `25/30` pairs and negative on `5/30` pairs. The candidate mean official validation accuracy stayed above both the challenge target and the paired baseline mean, and every candidate seed cleared the target.

## Gate Check

- job completed `0:0`: pass
- `paired_summary.json` exists: pass
- `record_mode=true`: pass
- `validation_source=official`: pass
- `paired_seeds=30`: pass
- split prep includes official `train.pt` and `test.pt`: pass
- baseline config is 16-epoch cosine: pass
- candidate config is 13-epoch one-cycle with declared knobs: pass
- candidate mean official `val_acc > 0.700`: pass
- candidate target hits `30/30`: pass
- candidate mean paired time ratio `< 1.0`: pass
- SLURM stderr empty: pass
- no validation-path, TTA, adaptation, timing-boundary, or output-reuse violation observed in artifacts: pass after independent critic confirmation

## Artifact Locations

- Curated local summary: `orchestration/g8-official-longwarm/paired_summary.json`
- Curated local order file: `orchestration/g8-official-longwarm/paired_order.csv`
- SLURM stdout: `orchestration/g8-official-longwarm/paired-48449520.out`
- SLURM stderr: `orchestration/g8-official-longwarm/paired-48449520.err`
- Accounting: `orchestration/g8-official-longwarm/sacct-48449520.txt`
- Raw local mirror: `orchestration/g8-official-longwarm/remote-artifacts/`
- Remote output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8official_13ep_onecycle_longwarm_20260703T221900Z`

## Next Step

Delegate Flywheel logging with `$flywheel-log` for a new empirical record/finalist node.
