# G7-T4 mid-heavy late-light Capacity Trace

## Claim

Moving some final-stage width into the mid stage while removing one final-stage block can reduce timed training with smaller accuracy loss than simple shallow or narrow variants.

## Hypothesis

`C100_WIDTHS=64,160,224 C100_BLOCKS=2,2,1` keeps full early depth, strengthens mid-level representation, and reduces the expensive final-stage depth/width combination.

## Decision Criterion

Promote only if all checks pass:

- `record_mode=false`
- `validation_source=train_dev`
- `paired_seeds=3`
- candidate differs only on `widths` and `blocks`
- mean paired time ratio `<= 0.90`
- mean paired validation accuracy delta `>= -0.0025`
- candidate mean train-dev accuracy `>= 0.695`

Kill otherwise. No official validation from this workstream before dev10 and critic pass.

## Launch Metadata

- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Account: `IscrC_SIMP`
- Run id: `g7t4_midheavy_latelight_dev3_20260703T191437Z`
- Output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7t4_midheavy_latelight_dev3_20260703T191437Z`
- Validation mode: `RECORD=0`, `VALIDATION_SOURCE=train_dev`
- Runs/seeds: `RUNS=3`, `BASE_SEED=880000`
- Epochs: `EPOCHS=16`
- Candidate env: `C100_WIDTHS=64,160,224 C100_BLOCKS=2,2,1`

## Command

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
test ! -e outputs/cifar100_speedrun/g7t4_midheavy_latelight_dev3_20260703T191437Z
RUN_ID=g7t4_midheavy_latelight_dev3_20260703T191437Z \
RECORD=0 \
RUNS=3 \
EPOCHS=16 \
VALIDATION_SOURCE=train_dev \
BASE_SEED=880000 \
CANDIDATE_ENV='C100_WIDTHS=64,160,224 C100_BLOCKS=2,2,1' \
sbatch slurm/paired_compare.sh
```

## Stop Conditions

Stop and do not relaunch into the same run id if the job uses official validation, wrong account, wrong checkout, reused output path, nonzero wrapper guard from real config mismatch, or modified validation/timing semantics.

## Submission

- Submitted batch job: `48431372`
- Initial state: `RUNNING` on `lrdn2731`
- Final state: `COMPLETED`, exit `0:0`, elapsed `00:06:58`
- Result: KILL. Mean time ratio `1.013883`, mean validation accuracy delta `-0.015733`, and candidate mean train-dev accuracy `0.681400` all fail the promotion gate.
