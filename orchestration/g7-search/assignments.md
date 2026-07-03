# G7 Search Assignments

## Objective

Resume the CIFAR-100 A100 speedrun pipeline under the corrected validation policy. The goal is to find credible candidates that beat the official 30-run baseline while preserving the repository contract.

## Validation Policy

- Exploratory workstreams: `RECORD=0`, `VALIDATION_SOURCE=train_dev`, train-only prep.
- Record/finalist workstreams: `RECORD=1`, `VALIDATION_SOURCE=official`, `RUNS=30`, `C100_PREP_SPLITS=train,test`.
- Do not interrupt distinct compliant workstream runs merely because they are concurrent or use official validation correctly.

## Active Workstreams

| Workstream | Role | Scope | Validation | Status |
| --- | --- | --- | --- | --- |
| G7-C0 official reference | research-orchestrator | Clean official 30-run reference or paired default control if needed | official | pending remote-state audit |
| G7-T2 schedule | scientific-implementer | Add predeclared one-cycle/schedule knobs without validation edits | train_dev first | pending implementation |
| G7-T3 Muon mechanics | scientific-implementer | Add `C100_NS_STEPS`, momentum, weight decay knobs with logging | train_dev first | pending implementation |
| G7-T4 capacity | research-orchestrator | Run paired train-dev capacity reallocation variants using existing knobs | train_dev | ready after critic |
| G7-T5 margin rescue | experiment-architect | Use label smoothing/mixup only after a fast near-finalist exists | train_dev | blocked |

## Baseline To Beat

Official baseline job `48402781`: mean official validation accuracy `0.7076033353805542`, mean timed training `25.77336s`, 30/30 hits, 16 epochs, batch 1024.

## Immediate G7-T4 Capacity Candidates

These are intentionally not repeats of killed variants:

| Candidate | Env | Rationale |
| --- | --- | --- |
| late-light | `C100_BLOCKS=2,2,1` | Remove one expensive late stage block while keeping early/default capacity; tests whether late depth is less accuracy-critical than the first-block removal that failed. |
| mid-heavy-late-light | `C100_WIDTHS=64,160,224 C100_BLOCKS=2,2,1` | Reallocate some late-stage width into the mid stage to preserve representation while reducing final-stage cost. |
| mid-light-full-late | `C100_WIDTHS=64,112,256 C100_BLOCKS=2,2,2` | Reduce mid-stage width only, preserving final capacity and depth; tests a different cost location than prior final-width reduction. |

Each G7-T4 candidate must be launched as a separate `RUN_ID`, with `RUNS=3`, `EPOCHS=16`, `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `BASE_SEED=880000`, and `slurm/paired_compare.sh`.

## G7-T4 Gate

Promote to dev10 only if all are true:

- job completed `0:0`;
- `paired_summary.json` exists and reports `record_mode=false`, `validation_source=train_dev`, `paired_seeds=3`;
- candidate config differs only on declared `C100_WIDTHS`/`C100_BLOCKS`;
- paired mean time ratio `<= 0.90`;
- paired mean validation accuracy delta `>= -0.0025`;
- candidate mean train-dev accuracy `>= 0.695`.

Kill otherwise. No official validation from G7-T4 until dev10 and critic pass.
