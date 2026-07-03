# G7 Official One-Cycle Finalist Result

## Verdict

PASS after independent result critic.

The 14-epoch one-cycle candidate beat the 16-epoch cosine baseline on official 30-run paired evidence while keeping every candidate seed above the `0.70` official validation target.

## Run Scope

- Job: `48439897`
- State: `COMPLETED`, exit `0:0`
- Node: `lrdn2463`
- Elapsed: `00:48:54`
- Account: `IscrC_SIMP`
- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Run id: `g7official_onecycle_default_20260703T203139Z`
- Record mode: `true`
- Validation: official CIFAR-100 test split as fixed plain validation
- Paired seeds: `30`, base seed `880000`
- Candidate env: `C100_EPOCHS=14 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0`

## Results

| Metric | Candidate | Baseline | Delta/ratio |
| --- | ---: | ---: | ---: |
| mean official val acc | `0.713300` | `0.708300` | `+0.005000` |
| min official val acc | `0.708600` | `0.701800` | n/a |
| target hits | `30/30` | `30/30` | n/a |
| mean timed seconds | `22.911267` | `26.326719` | `-3.415452s` |
| mean time ratio | n/a | n/a | `0.870868` |
| max pair time ratio | n/a | n/a | `0.880533` |

Accuracy delta was positive on `27/30` pairs and negative on `3/30` pairs, but the candidate's mean official validation accuracy stayed above both the challenge target and the paired baseline mean.

## Gate Check

- job completed `0:0`: pass
- `paired_summary.json` exists: pass
- `record_mode=true`: pass
- `validation_source=official`: pass
- `paired_seeds=30`: pass
- split prep includes official `train.pt` and `test.pt`: pass
- baseline config is 16-epoch cosine: pass
- candidate config is 14-epoch one-cycle with declared knobs: pass
- candidate mean official `val_acc > 0.700`: pass
- candidate mean paired time ratio `< 1.0`: pass
- SLURM stderr empty: pass
- no validation-path, TTA, adaptation, timing-boundary, or output-reuse violation observed in artifacts: pass after independent critic confirmation

## Artifact Locations

- Visual evidence: `orchestration/g7-official-onecycle/plots/official_onecycle_result.png`
- Main Markdown summary: `orchestration/g7-official-onecycle/summary.md`
- Curated local summary: `orchestration/g7-official-onecycle/paired_summary.json`
- Curated local order file: `orchestration/g7-official-onecycle/paired_order.csv`
- SLURM stdout: `orchestration/g7-official-onecycle/paired-48439897.out`
- SLURM stderr: `orchestration/g7-official-onecycle/paired-48439897.err`
- Accounting: `orchestration/g7-official-onecycle/sacct-48439897.txt`
- Raw artifact manifest: `orchestration/g7-official-onecycle/remote_artifacts_manifest.tsv`
- Reproducibility: `orchestration/g7-official-onecycle/reproducibility.md`
- Commit metadata: `orchestration/g7-official-onecycle/commit.txt`
- Raw local mirror: `orchestration/g7-official-onecycle/remote-artifacts/`
- Remote output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7official_onecycle_default_20260703T203139Z`

Recommended upload order:

1. `plots/official_onecycle_result.png`
2. `summary.md`
3. `paired_summary.json`, `paired_order.csv`
4. `paired-48439897.out`, `paired-48439897.err`, `sacct-48439897.txt`, `remote_artifacts_manifest.tsv`
5. `reproducibility.md`
6. `commit.txt`

## Next Step

Delegate Flywheel logging to a `research-logger` using `$flywheel-log`, including the official record claim, reproducibility notes, command, commit metadata, and curated artifact list.
