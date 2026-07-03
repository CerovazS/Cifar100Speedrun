# G5b-T5 Cutout8 Result

## Verdict

KILL. `C100_CUTOUT_SIZE=8` at 14 epochs reduced train-dev accuracy and did not improve paired training time.

## Claim, Hypothesis, Gate

- Claim: small train-time cutout may recover enough accuracy for the near-miss 14-epoch default schedule.
- Candidate: `C100_CUTOUT_SIZE=8 C100_LABEL_SMOOTHING=0.05`.
- Control: default 14-epoch baseline with `C100_CUTOUT_SIZE=0 C100_LABEL_SMOOTHING=0.05`.
- Pass gate: candidate mean train-dev `val_acc >= 0.7000`, candidate hits `>=2/3`, mean accuracy delta `>= +0.0020`, and mean time ratio `<=1.06`.

## Job

- Job id: `48412962`
- State: `COMPLETED`
- Exit: `0:0`
- Elapsed: `00:06:42`
- Validation: `train_dev`
- Record mode: `false`
- Run id: `g5b_t5_cutout8_ep14_dev3_20260703T154512Z_7a5ea61`

The prep stage printed only `cifar100/train.pt`; it did not print or inspect `test.pt`.

## Metrics

| Seed | Baseline acc | Candidate acc | Acc delta | Baseline time | Candidate time | Time ratio |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `883400` | `0.6922` | `0.6844` | `-0.0078` | `20.653777s` | `20.581893s` | `0.996520` |
| `883401` | `0.6950` | `0.6914` | `-0.0036` | `20.685385s` | `20.673563s` | `0.999428` |
| `883402` | `0.6910` | `0.6868` | `-0.0042` | `20.716840s` | `20.844148s` | `1.006145` |

Summary:

- paired seeds: `3`
- mean candidate/baseline time ratio: `1.000698`
- mean time delta: `+0.014534s`
- mean train-dev accuracy delta: `-0.005200`
- candidate hits: `0/3`
- candidate mean train-dev accuracy: `0.687533`

## Decision

Do not expand cutout8 at 14 epochs to dev10, paired promotion, official validation, or record mode. It misses the accuracy target by a wide margin and is not faster in paired mean time.

## Evidence

- Remote output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5b_t5_cutout8_ep14_dev3_20260703T154512Z_7a5ea61/`
- Local mirror: `orchestration/g5b-t5-regularization/remote-artifacts/g5b_t5_cutout8_ep14_dev3_20260703T154512Z_7a5ea61/`
- Accounting: `orchestration/g5b-t5-regularization/sacct-48412962.txt`
