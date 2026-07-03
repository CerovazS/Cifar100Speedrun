# G8 Parallel Search Assignments

## Context

G7 produced a valid official finalist: 14-epoch one-cycle schedule, mean official validation accuracy `0.713300`, mean time ratio `0.870868` versus the 16-epoch cosine baseline. G8 starts from that result but returns to exploratory `train_dev` evidence. No G8 workstream may use official validation unless it is separately pre-registered and critic-approved.

## Shared Gates

- `RECORD=0`
- `VALIDATION_SOURCE=train_dev`
- unique `RUN_ID` per launch
- no output directory reuse
- no validation path edits
- no TTA, validation-time adaptation, ensembles, or timing-boundary changes
- baseline/candidate diffs must be declared and validated by `slurm/paired_compare.sh`
- promote only after paired artifacts, `sacct`, and independent critic audit

## Workstream A: One-Cycle Compression Frontier

Role: `research-orchestrator`

Claim: one-cycle may support fewer than 14 epochs or a slightly more aggressive schedule while preserving the `train_dev` target.

Immediate candidates:

- `13ep-onecycle-default`: `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0`
- `13ep-onecycle-longwarm`: `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0`
- optional only if first two are inconclusive: `12ep-onecycle-default`

Gate: paired dev3 versus the 14-epoch cosine control first. Promote to dev10 only if candidate mean `train_dev` accuracy `>=0.700`, mean accuracy delta `>=+0.0025`, and mean time ratio `<=0.95`.

## Workstream B: Muon Mechanics

Role: `scientific-implementer` followed by `scientific-critic`

Claim: schedule compression may combine with Muon update mechanics to recover more accuracy at 13-14 epochs without increasing timed training.

Implementation scope:

- add env knobs only for optimizer mechanics already used by the trainer:
  - `C100_NS_STEPS`
  - `C100_MUON_MOMENTUM`
  - `C100_MUON_WEIGHT_DECAY`
  - `C100_SGD_MOMENTUM`
- update paired wrapper allowlist and declared config diff mapping.
- do not edit validation, split loading, evaluation, warmup, or timing boundaries.

Gate: static critic before any launch, then paired dev3 `train_dev` against the current 14-epoch one-cycle candidate or the local train-dev control selected by the orchestrator.

## Workstream C: Train-Only Data Path / AirBench-Style Feasibility

Role: `repo-cartographer` then `experiment-architect`

Claim: repo-compatible train-only data/augmentation improvements may offer a larger accuracy reserve than schedule-only tuning, but they are higher risk for rule violations.

Initial task: map the trainer's data path and identify only compliant train-only changes. Produce a launchable plan or a kill recommendation. Do not edit code until a critic approves the proposal.

Gate: no official validation, no use of official labels beyond fixed validation for later pre-registered evidence, no test-time augmentation, no validation-time adaptation.

## Logging

The official G7 result is being logged separately. G8 negative exploratory screens should remain local until a curated synthesis is useful.
