# G7 Validation Policy Reset

## Trigger

The user correctly challenged the previous orchestration posture: this repository defines the official CIFAR-100 test split as the fixed plain validation set for record evidence, and official split prep must be requested for record work. The prior local wording made official validation sound broadly blocked rather than reserved for explicit record/finalist evidence.

## Corrected Policy

- Exploratory candidate search remains `RECORD=0` with `VALIDATION_SOURCE=train_dev`; it cannot establish a record.
- Pre-registered record/finalist work must use `RECORD=1`, `VALIDATION_SOURCE=official`, exactly `RUNS=30`, and `C100_PREP_SPLITS=train,test`.
- Official validation is not forbidden. It is mandatory for record evidence when the candidate is explicitly named and the run is auditable.
- Distinct compliant workstream runs should not be interrupted merely because another workstream is active or because they use official validation correctly.
- Intervention is reserved for wrong account/path, output reuse, validation semantics changes, timing-boundary changes, unreviewed launch scripts, or explicit user instruction.

## Immediate Code/Plan Changes

- Removed the conservative `paired_compare.sh` guard that refused train-dev pilots while official/record/G6 job names were present in the queue.
- Updated `program.md` to state the corrected official-validation policy and the non-interruption rule for compliant concurrent workstreams.
- Updated `README.md` to point to the completed 30-run official baseline instead of saying the baseline is unrun.

## Current Baseline To Beat

Job `48402781`, `IscrC_SIMP`, official validation, 30 runs, default 16 epochs:

- Mean official validation accuracy: `0.7076033353805542`
- Mean timed training: `25.77336s`
- Target: `mean(val_acc) > 0.70`

## Why The Previous Official Runs Were Interrupted

The canceled G6 jobs were stopped because they came from an unreviewed/untracked launch surface and old-path governance risk, not because official validation is disallowed by the challenge. Partial official metrics from the canceled attempt remain non-evidence because the run did not complete as an audited pre-registered workstream.

## Next Gate

Before launching G7:

- finish repo-rule, CINECA-state, and trajectory-design subagent audits;
- write one trace per selected workstream with claim, hypothesis, criterion, validation mode, run id, output root, and allowed config/code differences;
- run a critic pass before any official record/finalist job.
