# G7-T4 Capacity Reallocation Result

## Verdict

KILL all three G7-T4 capacity candidates. None passes the predeclared dev3 gate, and none should move to dev10, official validation, or record mode.

## Run Scope

- Validation: `train_dev`
- Record mode: `false`
- Runs: 3 paired seeds per candidate
- Seeds: `880000`, `880001`, `880002`
- Account: `IscrC_SIMP`
- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Remote code commit during jobs: `dd1d179` on `codex/cifar100-speedrun-control`

No official validation was used. Prep logs mention `cifar100/train.pt`; `test.pt` was not prepared or inspected by these exploratory jobs.

## Results

| Candidate | Job | Env | Mean candidate acc | Mean baseline acc | Mean acc delta | Mean time ratio | Gate result |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| late-light | `48431371` | `C100_BLOCKS=2,2,1` | `0.676733` | `0.696533` | `-0.019800` | `0.895986` | FAIL accuracy |
| mid-heavy late-light | `48431372` | `C100_WIDTHS=64,160,224 C100_BLOCKS=2,2,1` | `0.681400` | `0.697133` | `-0.015733` | `1.013883` | FAIL time and accuracy |
| mid-light full-late | `48432417` | `C100_WIDTHS=64,112,256` | `0.694333` | `0.697400` | `-0.003067` | `0.977084` | FAIL time, accuracy-delta, and candidate-accuracy gates |

Predeclared promotion gate required:

- job completed `0:0`;
- `record_mode=false`;
- `validation_source=train_dev`;
- `paired_seeds=3`;
- only declared config differences;
- mean time ratio `<= 0.90`;
- mean validation accuracy delta `>= -0.0025`;
- candidate mean train-dev accuracy `>= 0.695`.

## Interpretation

The late-stage block removal path is not viable: it barely meets the speed gate but loses about two accuracy points. The mid-heavy variant is dominated because it is slower and less accurate. The mid-light full-late variant is the most informative near miss: it preserves most accuracy but only saves about `2.3%` time, far below the required `10%` screen and with one unstable seed causing the mean delta to miss the accuracy-delta gate.

## Decision

Do not expand these G7-T4 candidates. The next work should shift to a non-architecture-only mechanism:

- complete paired-wrapper support for the already implemented one-cycle schedule knobs, then run a bounded train-dev schedule workstream;
- implement Muon mechanics knobs from the read-only spec only after wrapper allowlist/config-diff support is planned;
- keep official validation for pre-registered record/finalist evidence only.

## Artifact Locations

- Local mirror: `orchestration/g7-t4-capacity/remote-artifacts/`
- Remote roots:
  - `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7t4_latelight_dev3_20260703T191437Z`
  - `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7t4_midheavy_latelight_dev3_20260703T191437Z`
  - `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7t4_midlight_fulllate_dev3_20260703T191437Z`

## Accounting

All jobs completed `0:0`:

- `48431371`: `00:06:47`, node `lrdn2692`
- `48431372`: `00:06:58`, node `lrdn2731`
- `48432417`: `00:07:04`, node `lrdn0571`

Approximate GPU time: `20m49s`, about `0.347` A100-hours.
