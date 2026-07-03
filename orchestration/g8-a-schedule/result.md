# G8-A One-Cycle Compression Dev3 Result

## Verdict

PROMOTE `13ep-onecycle-longwarm` to independent result audit for dev10. HOLD `13ep-onecycle-default`.

No official validation was used. These are exploratory `train_dev` screens and cannot support a record claim.

## Run Scope

- Validation: `train_dev`
- Record mode: `false`
- Runs: 3 paired seeds per candidate
- Seeds: `890000`, `890001`, `890002`
- Baseline epochs: `14`
- Candidate epochs: `13`
- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`

## Results

| Candidate | Job | Candidate mean acc | Baseline mean acc | Mean acc delta | Mean time ratio | Target hits | Gate result |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| `13ep-onecycle-default` | `48445735` | `0.701400` | `0.696467` | `+0.004933` | `0.928871` | `2/3` | HOLD, fragile |
| `13ep-onecycle-longwarm` | `48445734` | `0.708733` | `0.695933` | `+0.012800` | `0.931130` | `3/3` | PROMOTE |

Predeclared promotion gate:

- job completed `0:0`;
- `record_mode=false`;
- `validation_source=train_dev`;
- `paired_seeds=3`;
- baseline uses `EPOCHS=14`;
- candidate differs only on declared schedule/epoch fields;
- candidate mean train-dev accuracy `>= 0.700`;
- mean train-dev accuracy delta `>= +0.0025`;
- mean time ratio `<= 0.95`.

Both candidates pass the numeric mean gate, but `13ep-onecycle-default` is held because it has one candidate seed below `0.70` and one negative accuracy delta. `13ep-onecycle-longwarm` is the clean candidate: all three deltas are positive and all three candidate seeds clear `0.70`.

## Artifact Locations

- Local mirror: `orchestration/g8-a-schedule/remote-artifacts/`
- SLURM logs:
  - `orchestration/g8-a-schedule/paired-48445734.out`
  - `orchestration/g8-a-schedule/paired-48445734.err`
  - `orchestration/g8-a-schedule/paired-48445735.out`
  - `orchestration/g8-a-schedule/paired-48445735.err`
- Accounting: `orchestration/g8-a-schedule/sacct-48445734-48445735.txt`
- Remote roots:
  - `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_default_dev3_20260703T213903Z`
  - `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev3_20260703T213903Z`

## Next Step

Run independent critic on G8-A dev3 artifacts. If the critic passes, launch only `13ep-onecycle-longwarm` as paired train-dev dev10. Do not use official validation.
