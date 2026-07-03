# G7-T2 One-Cycle Schedule Result

## Verdict

PROMOTE `onecycle-default` to official/finalist audit after paired train-dev dev10 result audit. KILL `onecycle-highlr`.

No official validation was used. Both runs are exploratory `train_dev` screens and cannot support a record claim.

## Run Scope

- Validation: `train_dev`
- Record mode: `false`
- Runs: 3 paired seeds per candidate
- Seeds: `880000`, `880001`, `880002`
- Epochs: `14`
- Account: `IscrC_SIMP`
- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Local commit: `72322f2`
- Remote applied commit: `c807984`

## Results

| Candidate | Job | Env | Mean candidate acc | Mean baseline acc | Mean acc delta | Mean time ratio | Gate result |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| onecycle-default | `48433759` | `C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0` | `0.707867` | `0.691600` | `+0.016267` | `1.000786` | PASS |
| onecycle-highlr | `48433762` | `C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0 C100_MUON_LR=0.045 C100_BIAS_LR=0.026` | `0.705067` | `0.696867` | `+0.008200` | `1.010100` | PASS numeric gate, but dominated |

Predeclared promotion gate:

- job completed `0:0`;
- `record_mode=false`;
- `validation_source=train_dev`;
- `paired_seeds=3`;
- candidate differs only on declared schedule fields and optional LR fields;
- candidate mean train-dev accuracy `>= 0.700`;
- mean validation accuracy delta `>= +0.0025`;
- mean time ratio `<= 1.03`.

Both candidates pass the numeric gate. `onecycle-highlr` is killed because it is dominated by `onecycle-default` under the predeclared dev3 paired gate metrics: lower candidate accuracy, smaller accuracy delta, and worse time ratio.

## Interpretation

The default-LR one-cycle schedule passed the dev3 screen and then passed paired train-dev dev10 with a large accuracy gain and no time penalty relative to the 14-epoch cosine control.

## Dev10 Result

Job `48436515`, run id `g7t2_onecycle_default_dev10_20260703T200606Z`, completed `0:0`.

| Metric | Value |
| --- | ---: |
| paired seeds | `10` |
| validation source | `train_dev` |
| record mode | `false` |
| candidate mean train-dev accuracy | `0.705820` |
| baseline mean train-dev accuracy | `0.693100` |
| mean accuracy delta | `+0.012720` |
| mean time ratio | `0.994283` |
| mean time delta | `-0.117681s` |

Dev10 promotion-to-official gate was candidate mean train-dev accuracy `>= 0.703`, mean accuracy delta `>= +0.006`, mean time ratio `<= 1.03`, complete artifacts, and result audit. The numeric gates pass.

## Next Step

Run a critical result audit on dev10. If it passes, pre-register `onecycle-default` for official 30-run paired evidence with `RECORD=1`, `RUNS=30`, `VALIDATION_SOURCE=official`, and `C100_PREP_SPLITS=train,test`.

## Artifact Locations

- Local mirror: `orchestration/g7-t2-schedule/remote-artifacts/`
- Remote roots:
  - `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7t2_onecycle_default_dev3_20260703T193834Z`
  - `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7t2_onecycle_highlr_dev3_20260703T193834Z`
  - `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g7t2_onecycle_default_dev10_20260703T200606Z`

## Accounting

Both jobs completed `0:0`:

- `48433759`: `00:06:37`, node `lrdn1177`
- `48433762`: `00:06:31`, node `lrdn2963`

Approximate GPU time: `13m08s`, about `0.219` A100-hours.

Dev10 job:

- `48436515`: `00:16:43`, node `lrdn1794`, about `0.279` A100-hours.
