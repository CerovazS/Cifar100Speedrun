# G2 Interactive Smoke Summary

## Objective

Validate the CINECA `IscrC_SIMP` runtime on a single Leonardo A100 before any official baseline, paired pilot, or search spend.

## Environment

- Checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Branch: `codex/cifar100-speedrun-control`
- Commit: `4a59bcf`
- Account: `IscrC_SIMP`
- GPU node for passing smoke: `lrdn0992.leonardo.local`
- GPU: `NVIDIA A100-SXM-64GB`, driver `535.274.02`
- Validation source: `train_dev`
- Target: `0.01`

## Attempts

| Job | Result | Notes |
| --- | --- | --- |
| `48401141` | failed before benchmark | `srun --pty` task launch failed with `Communication connection failure` on `lrdn1721`; no benchmark code ran. |
| `48401256` | failed before benchmark | command quoting caused `bash: slurm/smoke.sh: No such file or directory`; no benchmark code ran. |
| `48401374` | failed during compile | reached A100 on `lrdn2606`, but `torch.compile` failed because Triton/setuptools were missing from the uv environment. |
| `48402049` | passed | after adding `triton==3.0.0` and `setuptools>=82.0.1`, the smoke completed on `lrdn0992`. |

## Passing Result

Run directory copied locally:

`outputs/cifar100_speedrun/smoke_48402049_4a59bcf/`

Key metrics:

- warmup validation: skipped
- warmup compile/training time: `55.1285s`
- run validation accuracy: `0.0136` on `train_dev`
- target hit count: `1/1`
- timed training: `0.104731s`

## Evidence Files

- `orchestration/g2-interactive-smoke/srun_20260703_155942_triton.log`
- `outputs/cifar100_speedrun/smoke_48402049_4a59bcf/config.json`
- `outputs/cifar100_speedrun/smoke_48402049_4a59bcf/metrics.csv`
- `outputs/cifar100_speedrun/smoke_48402049_4a59bcf/summary.json`
- `outputs/cifar100_speedrun/smoke_48402049_4a59bcf/warmup.json`
- `outputs/cifar100_speedrun/smoke_48402049_4a59bcf/repro_metadata.json`

## Gate Decision

G2 is complete. The CINECA runtime, data path, uv environment, GPU allocation, `torch.compile`, train-derived validation smoke, artifact writing, and scratch checkout path are validated. Proceed to G3 current-default 30-run official baseline only from commit `4a59bcf` or a later audited commit.
