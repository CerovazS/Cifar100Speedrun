# G5b Train-Dev Search Assignments

## Gate State

G5 first batch produced no promotable candidate. Current evidence blocks dev10, paired-train-dev promotion, official validation, and record mode. G5b may run only train-dev dev3 pilots with unique run IDs, numeric gates, and no official validation.

The active scratch checkout is `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun` at commit `b09cd6e`.

## Tracks

| Track | Role | Scope | First Gate |
| --- | --- | --- | --- |
| T4 Shallow recovery | `research-orchestrator` | Existing committed env knobs only: `C100_BLOCKS=1,2,2`, 16 epochs, paired train-dev dev3 vs default | Candidate mean train-dev acc `>=0.697` and paired time ratio `<=0.90`; no official validation |
| T5 Cheap regularization | `scientific-implementer` then critic | Default-preserving trainer knobs for label smoothing and cutout; no validation/timing edits | Static tests and critic pass before any GPU job |
| T6 Batch/schedule | `experiment-architect` | Non-redundant batch/schedule pilot design beyond scalar Muon LR | Numeric dev3 gate plus matched default control; no launch without main approval |

## Shared Constraints

- Submit only from the scratch checkout path above.
- Use `IscrC_SIMP`; no old `$WORK` / PAERLE / YENDRI launch scripts.
- `RECORD=0` and `VALIDATION_SOURCE=train_dev` for all G5b runs.
- Future train-dev wrappers must use `C100_PREP_SPLITS=train` and must not print or inspect `test.pt`.
- Every run gets a unique output directory under `outputs/cifar100_speedrun/`.
- Each subagent must return job IDs, commands, output paths, metrics, GPU accounting, files touched, and unresolved risks.
