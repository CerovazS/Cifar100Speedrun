# G4 Paired Timing Pilot Summary

## Objective

Validate the same-allocation paired comparison runner before launching parallel train-dev search. This pilot was a no-op baseline/candidate comparison intended to test order control, artifact layout, and train-derived validation behavior, not to claim a model improvement.

## Run

- SLURM job: `48405474`
- State: `COMPLETED`, exit code `0:0`
- Elapsed: `00:05:15`
- Account: `IscrC_SIMP`
- Node: `lrdn2161`
- GPU: `1x NVIDIA A100-SXM-64GB`
- Commit: `eb4f1a5`
- Run directory: `outputs/cifar100_speedrun/paired_noop_g4_20260703_162639_eb4f1a5/`
- Validation source: `train_dev`
- Record mode: `false`
- Paired seeds: `4`
- Epochs: `0.25`
- Candidate env: empty no-op

## Result

- Mean candidate/baseline time ratio: `1.001836`
- Mean time delta: `0.000684s`
- Mean validation-accuracy delta: `-0.000950`
- Orders alternated by seed:
  - `880000`: baseline/candidate
  - `880001`: candidate/baseline
  - `880002`: baseline/candidate
  - `880003`: candidate/baseline

The no-op ratio is close to `1.0`, and the runner produced `paired_order.csv`, per-seed method directories, per-run metrics/config/metadata, `paired_summary.json`, and copied stdout/stderr logs.

## Gate Interpretation

G4 validates the paired runner as a pilot-grade same-allocation control on `train_dev`. It is sufficient to start G5 train-dev trajectory search, with the caveat that final G6 record evidence still requires `RECORD=1`, official validation, exactly 30 paired seeds, and pre-registration/audit.

## Evidence Files

- `outputs/cifar100_speedrun/paired_noop_g4_20260703_162639_eb4f1a5/paired_summary.json`
- `outputs/cifar100_speedrun/paired_noop_g4_20260703_162639_eb4f1a5/paired_order.csv`
- per-seed `config.json`, `metrics.csv`, `summary.json`, `warmup.json`, and `repro_metadata.json`
- `outputs/cifar100_speedrun/paired_noop_g4_20260703_162639_eb4f1a5/stdout.log`
- `outputs/cifar100_speedrun/paired_noop_g4_20260703_162639_eb4f1a5/stderr.log`
- `orchestration/g4-paired-pilot/paired-48405474.out`
- `orchestration/g4-paired-pilot/paired-48405474.err`

## Next Gate

Run an independent G4 audit. If accepted, unblock G5 train-dev search trajectories while keeping official-test record attempts blocked.
