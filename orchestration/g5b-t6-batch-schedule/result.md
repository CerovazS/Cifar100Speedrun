# G5b-T6 Batch 1536 Result

## Verdict

KILL. The candidate was faster than the default control, but it failed every predeclared accuracy gate.

## Claim, Hypothesis, Gate

- Claim: `C100_BATCH=1536` at 16 epochs can reduce timed training while preserving enough train-dev accuracy.
- Candidate: `C100_BATCH=1536 C100_MUON_LR=0.040 C100_BIAS_LR=0.024`.
- Control: default `C100_BATCH=1024 C100_MUON_LR=0.035 C100_BIAS_LR=0.02`.
- Pass gate: `mean_time_ratio <= 0.78`, `mean_val_acc_delta >= -0.0030`, candidate mean train-dev `val_acc >= 0.7000`, and candidate hits `>=2/3`.

## Job

- Job id: `48412311`
- State: `COMPLETED`
- Exit: `0:0`
- Elapsed: `00:04:53`
- Validation: `train_dev`
- Record mode: `false`
- Run id: `g5b_t6_b1536_sqrtlr_dev3_20260703T153931Z_7a5ea61`

The prep stage printed only `cifar100/train.pt`; it did not print or inspect `test.pt`.

## Metrics

| Seed | Baseline acc | Candidate acc | Acc delta | Baseline time | Candidate time | Time ratio |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `882600` | `0.6940` | `0.6826` | `-0.0114` | `23.156951s` | `20.736074s` | `0.895458` |
| `882601` | `0.6948` | `0.6836` | `-0.0112` | `23.153174s` | `20.773395s` | `0.897216` |
| `882602` | `0.7020` | `0.6908` | `-0.0112` | `23.129025s` | `20.643336s` | `0.892529` |

Summary:

- paired seeds: `3`
- mean candidate/baseline time ratio: `0.895068`
- mean time delta: `-2.428782s`
- mean train-dev accuracy delta: `-0.011267`
- candidate hits: `0/3`
- candidate mean train-dev accuracy: `0.685667`

## Decision

Do not expand this batch-1536 candidate to dev10, paired promotion, official validation, or record mode. The speed reduction is too small for the accuracy loss: it misses the time-ratio gate (`0.895068 > 0.78`) and loses more than one full accuracy point on train-dev.

## Evidence

- Remote output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5b_t6_b1536_sqrtlr_dev3_20260703T153931Z_7a5ea61/`
- Local mirror: `orchestration/g5b-t6-batch-schedule/remote-artifacts/g5b_t6_b1536_sqrtlr_dev3_20260703T153931Z_7a5ea61/`
- Accounting: `orchestration/g5b-t6-batch-schedule/sacct-48412311.txt`
