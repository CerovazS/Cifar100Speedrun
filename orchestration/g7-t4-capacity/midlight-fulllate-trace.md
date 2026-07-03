# G7-T4 mid-light full-late Capacity Trace

## Claim

Reducing only mid-stage width while preserving final-stage width and depth can cut compute with less accuracy loss than prior final-width or shallow variants.

## Hypothesis

`C100_WIDTHS=64,112,256 C100_BLOCKS=2,2,2` leaves the final representation capacity untouched and tests whether the mid stage is an over-provisioned cost center.

## Decision Criterion

Promote only if all checks pass:

- `record_mode=false`
- `validation_source=train_dev`
- `paired_seeds=3`
- candidate differs only on `widths`
- mean paired time ratio `<= 0.90`
- mean paired validation accuracy delta `>= -0.0025`
- candidate mean train-dev accuracy `>= 0.695`

Kill otherwise. No official validation from this workstream before dev10 and critic pass.

## Launch Metadata

- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Account: `IscrC_SIMP`
- Run id: `g7t4_midlight_fulllate_dev3_20260703T191437Z`
- Output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7t4_midlight_fulllate_dev3_20260703T191437Z`
- Validation mode: `RECORD=0`, `VALIDATION_SOURCE=train_dev`
- Runs/seeds: `RUNS=3`, `BASE_SEED=880000`
- Epochs: `EPOCHS=16`
- Candidate env: `C100_WIDTHS=64,112,256`

## Command

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
test ! -e outputs/cifar100_speedrun/g7t4_midlight_fulllate_dev3_20260703T191437Z
RUN_ID=g7t4_midlight_fulllate_dev3_20260703T191437Z \
RECORD=0 \
RUNS=3 \
EPOCHS=16 \
VALIDATION_SOURCE=train_dev \
BASE_SEED=880000 \
CANDIDATE_ENV='C100_WIDTHS=64,112,256' \
sbatch slurm/paired_compare.sh
```

## Stop Conditions

Stop and do not relaunch into the same run id if the job uses official validation, wrong account, wrong checkout, reused output path, nonzero wrapper guard from real config mismatch, or modified validation/timing semantics.

## Submission

- Initial `sbatch` attempt after jobs `48431371` and `48431372` failed before allocation with `QOSMaxSubmitJobPerUserLimit`.
- This is a scheduler submission limit, not a scientific rejection. Submit this run id after one active debug-QOS slot is free.
- Submitted batch job after slots freed: `48432417`
- Initial state: `PENDING (Priority)`
- Final state: `COMPLETED`, exit `0:0`, elapsed `00:07:04`
- Result: KILL. Candidate mean train-dev accuracy `0.694333` is close but below the `0.695` gate, mean validation accuracy delta `-0.003067` misses the `-0.0025` gate, and mean time ratio `0.977084` is far above the `0.90` speed gate.
