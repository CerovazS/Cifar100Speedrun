# G3 Official Baseline Summary

## Objective

Establish the current-default official 30-run baseline for the CIFAR-100 A100 speedrun before any candidate search or record claim.

## Run

- SLURM job: `48402781`
- State: `COMPLETED`, exit code `0:0`
- Elapsed: `00:16:00`
- Account: `IscrC_SIMP`
- Node: `lrdn2988`
- GPU: `1x NVIDIA A100-SXM-64GB`
- Commit: `27eb750`
- Run directory: `outputs/cifar100_speedrun/baseline_48402781_27eb750/`
- Validation source: `official`
- Runs: `30`
- Epochs: `16`
- Batch size: `1024`
- Compile: `torch.compile`, `C100_COMPILE_MODE=default`

## Result

- Mean official validation accuracy: `0.707603`
- Validation std: `0.002416` sample std from analyzer, `0.002375` population std from `summary.json`
- Min/max official validation accuracy: `0.701800` / `0.712900`
- Target hit count: `30/30`
- Mean timed training: `25.773360s`
- Time std: `0.015059s` sample std from analyzer, `0.014814s` population std from `summary.json`
- Min/max timed training: `25.737700s` / `25.803500s`
- Analyzer one-sided normal approximation for `mean <= 0.7000`: `6.70621e-67`

## Gate Interpretation

The current-default baseline clears the `mean(val_acc) > 70%` target with a large margin for this 30-run measurement. This closes the baseline-robustness blocker for starting train-dev candidate search and paired timing pilots, pending independent result audit.

This is not a record candidate; it is the reference baseline for relative same-pod comparisons.

## Evidence Files

- `outputs/cifar100_speedrun/baseline_48402781_27eb750/config.json`
- `outputs/cifar100_speedrun/baseline_48402781_27eb750/metrics.csv`
- `outputs/cifar100_speedrun/baseline_48402781_27eb750/summary.json`
- `outputs/cifar100_speedrun/baseline_48402781_27eb750/analysis.txt`
- `outputs/cifar100_speedrun/baseline_48402781_27eb750/repro_metadata.json`
- `outputs/cifar100_speedrun/baseline_48402781_27eb750/warmup.json`
- `outputs/cifar100_speedrun/baseline_48402781_27eb750/stdout.log`
- `outputs/cifar100_speedrun/baseline_48402781_27eb750/stderr.log`
- `orchestration/g3-official-baseline/baseline-48402781.out`
- `orchestration/g3-official-baseline/baseline-48402781.err`

## Next Gate

Run G4 same-allocation paired no-op or tiny-candidate pilot on `train_dev` to validate AB/BA timing control before launching parallel trajectory searches.
