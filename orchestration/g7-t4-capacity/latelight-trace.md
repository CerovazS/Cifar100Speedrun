# G7-T4 late-light Capacity Trace

## Claim

Removing one late-stage block at full 16 epochs can reduce timed training while keeping train-dev accuracy close enough to the default architecture to justify a dev10 follow-up.

## Hypothesis

`C100_BLOCKS=2,2,1` preserves the early and mid-depth default structure and removes only one final-stage block, so it should be less accuracy-destructive than the killed `shallow122` first-stage removal while still reducing step cost.

## Decision Criterion

Promote only if all checks pass:

- `record_mode=false`
- `validation_source=train_dev`
- `paired_seeds=3`
- candidate differs only on `blocks`
- mean paired time ratio `<= 0.90`
- mean paired validation accuracy delta `>= -0.0025`
- candidate mean train-dev accuracy `>= 0.695`

Kill otherwise. No official validation from this workstream before dev10 and critic pass.

## Launch Metadata

- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Account: `IscrC_SIMP`
- Run id: `g7t4_latelight_dev3_20260703T191437Z`
- Output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7t4_latelight_dev3_20260703T191437Z`
- Validation mode: `RECORD=0`, `VALIDATION_SOURCE=train_dev`
- Runs/seeds: `RUNS=3`, `BASE_SEED=880000`
- Epochs: `EPOCHS=16`
- Candidate env: `C100_BLOCKS=2,2,1`

## Command

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
test ! -e outputs/cifar100_speedrun/g7t4_latelight_dev3_20260703T191437Z
RUN_ID=g7t4_latelight_dev3_20260703T191437Z \
RECORD=0 \
RUNS=3 \
EPOCHS=16 \
VALIDATION_SOURCE=train_dev \
BASE_SEED=880000 \
CANDIDATE_ENV='C100_BLOCKS=2,2,1' \
sbatch slurm/paired_compare.sh
```

## Stop Conditions

Stop and do not relaunch into the same run id if the job uses official validation, wrong account, wrong checkout, reused output path, nonzero wrapper guard from real config mismatch, or modified validation/timing semantics.

## Submission

- Submitted batch job: `48431371`
- Initial state: `RUNNING` on `lrdn2692`
- Final state: `COMPLETED`, exit `0:0`, elapsed `00:06:47`
- Result: KILL. Mean time ratio `0.895986` passes speed gate, but mean validation accuracy delta `-0.019800` and candidate mean train-dev accuracy `0.676733` fail the accuracy gates.
