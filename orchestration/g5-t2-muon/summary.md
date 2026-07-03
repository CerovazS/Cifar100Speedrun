# G5-T2 Muon Optimizer Mechanics Trace

## Objective

Run train-dev-only Muon learning-rate pilots for the CIFAR-100 A100 speedrun on CINECA Leonardo under `IscrC_SIMP`.

## Claim, Hypothesis, And Decision Criterion

- Claim under test: changing only the Muon learning rate can improve the train-dev trajectory at a 14-epoch budget relative to the current default Muon LR `0.035`, without touching official validation.
- Hypothesis: at least one of `MUON_LR in {0.025, 0.032, 0.040}` with default `BIAS_LR=0.02` and `EPOCHS=14` improves dev validation accuracy/time tradeoff enough to justify a small epoch cross-check.
- Decision criterion: expand only if a pilot has `RUNS=3`, `VALIDATION_SOURCE=train_dev`, no hard errors, unique output directory, and either higher mean train-dev `val_acc` at comparable mean timed training or comparable `val_acc` with lower mean timed training against the default baseline expectation. Stop before any `dev10` or official validation.
- Evidence metric: `summary.json`, `metrics.csv`, copied `stdout.log`/`stderr.log`, scheduler accounting, and remote `config.json` showing `validation_source=train_dev`.

## Planned Jobs

| LR | RUN_ID prefix | Expected output directory |
| --- | --- | --- |
| `0.025` | `g5_t2_muon_20260703_164216_lr0025_dev3` | `outputs/cifar100_speedrun/g5_t2_muon_20260703_164216_lr0025_dev3_epochs14/` |
| `0.032` | `g5_t2_muon_20260703_164216_lr0032_dev3` | `outputs/cifar100_speedrun/g5_t2_muon_20260703_164216_lr0032_dev3_epochs14/` |
| `0.040` | `g5_t2_muon_20260703_164216_lr0040_dev3` | `outputs/cifar100_speedrun/g5_t2_muon_20260703_164216_lr0040_dev3_epochs14/` |

## Launch Constraints

- Submit from remote checkout root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`.
- Account: `IscrC_SIMP`.
- Validation: `train_dev` only through `slurm/discovery.sh`; no official validation.
- Allowed knobs: `RUNS=3`, `EPOCHS_LIST=14`, `MUON_LR`, default `BIAS_LR=0.02`, `TARGET=0.70`.
- No code or shared SLURM wrapper edits for the pilot.

## Status

- Pre-launch trace created locally.
- Pre-launch critic verdict: pass with caveats. Required launch fix: use `EPOCHS_LIST=14`, not `EPOCHS=14`; preserve discovery scheduler logs manually because `slurm/discovery.sh` does not copy them into each run directory.
- Submitted LR `0.025` as SLURM job `48407258`.
- Concurrent submission of LR `0.032` was rejected by CINECA with `QOSMaxSubmitJobPerUserLimit`; remaining LR jobs will be submitted sequentially after active debug slots clear.
- LR `0.025` completed successfully; scheduler logs copied into its output directory.
- LR `0.032` completed successfully; scheduler logs copied into its output directory.
- Submitted LR `0.040` as SLURM job `48409231`.
- LR `0.040` completed successfully; scheduler logs copied into its output directory.
- Planned dev3 sweep complete. No official validation evaluation was launched.

## Commands

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
export CIFAR100_ROOT="$(pwd -P)"
sbatch --export=ALL,RUNS=3,EPOCHS_LIST=14,MUON_LR=0.025,BIAS_LR=0.02,TARGET=0.70,VALIDATION_SOURCE=train_dev,RUN_ID_PREFIX=g5_t2_muon_20260703_164216_lr0025_dev3 slurm/discovery.sh
sbatch --export=ALL,RUNS=3,EPOCHS_LIST=14,MUON_LR=0.032,BIAS_LR=0.02,TARGET=0.70,VALIDATION_SOURCE=train_dev,RUN_ID_PREFIX=g5_t2_muon_20260703_164216_lr0032_dev3 slurm/discovery.sh
sbatch --export=ALL,RUNS=3,EPOCHS_LIST=14,MUON_LR=0.040,BIAS_LR=0.02,TARGET=0.70,VALIDATION_SOURCE=train_dev,RUN_ID_PREFIX=g5_t2_muon_20260703_164216_lr0040_dev3 slurm/discovery.sh
```

The second command failed at submission due to the user/job QoS limit; no LR `0.032` output directory was created by that failed submission.
The LR `0.032` command was resubmitted after slots cleared and accepted as job `48408602`.

## Interim Result

| LR | Job | State | Validation | Epochs | Runs | Mean dev acc | Mean timed train |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `0.025` | `48407258` | `COMPLETED` | `train_dev` | `14.0` | `3` | `0.696600` | `20.406874s` |
| `0.032` | `48408602` | `COMPLETED` | `train_dev` | `14.0` | `3` | `0.692667` | `20.260923s` |
| `0.040` | `48409231` | `COMPLETED` | `train_dev` | `14.0` | `3` | `0.694600` | `20.261660s` |

All three pilots had `target_hit_count=0/3` against the exploratory train-dev target `0.70`. The training metrics came from the train-derived 45k/5k split (`train_examples=45000`, `eval_examples=5000`).

## Scheduler Accounting

| Job | LR | State | Exit | Elapsed | GPU allocation |
| --- | --- | --- | --- | --- | --- |
| `48407258` | `0.025` | `COMPLETED` | `0:0` | `00:05:15` | `1x A100` |
| `48408602` | `0.032` | `COMPLETED` | `0:0` | `00:04:01` | `1x A100` |
| `48409231` | `0.040` | `COMPLETED` | `0:0` | `00:01:32` | `1x A100` |

Total A100 elapsed allocation: `00:10:48`, approximately `0.18` GPU-hours. `sacct` reports `billing=8`, so billing-equivalent TRES-hours are approximately `1.44`. The failed QoS-limited submission consumed no GPU allocation.

## Decision

Do not expand to a dev3 epoch cross-check and do not promote to dev10. LR `0.025` was best on mean dev accuracy but still missed the 0.70 exploratory target on all three seeds and was slower than the higher LR settings. LR `0.032` and LR `0.040` were faster but had lower mean dev accuracy. Because there is no same-run default `MUON_LR=0.035` train-dev reference, the result supports only a screening decision: this Muon LR sweep does not justify additional CINECA spend without a separately approved default reference or a broader optimizer plan.

## Evidence Paths

- Remote output: `outputs/cifar100_speedrun/g5_t2_muon_20260703_164216_lr0025_dev3_epochs14/`
- Remote output: `outputs/cifar100_speedrun/g5_t2_muon_20260703_164216_lr0032_dev3_epochs14/`
- Remote output: `outputs/cifar100_speedrun/g5_t2_muon_20260703_164216_lr0040_dev3_epochs14/`
- Each output directory contains `config.json`, `metrics.csv`, `summary.json`, `warmup.json`, `repro_metadata.json`, `git_diff.patch`, copied `stdout.log`, and copied `stderr.log`.

## Reproducibility Caveat

The remote checkout used commit `eb4f1a5954c045390a1644a643c182beac17747d` on branch `codex/cifar100-speedrun-control`, but it was dirty with an existing default-preserving `C100_WIDTHS`/`C100_BLOCKS` patch in `cifar100-benchmark/train_cifar100_resnet_muon.py`. The pilot did not set those env vars, and each `config.json` recorded default `widths=[64,128,256]` and `blocks=[2,2,2]`. Treat the run as reproducible from commit plus the per-run `git_diff.patch`, not from commit alone.

## Post-Run Audit

Critic verdict: no rerun required for the no-expand decision.

- Medium caveat: `slurm/discovery.sh` runs `prepare_cifar100_hf.py`, whose stdout reports `cifar100/test.pt: exists`. The official test artifact was therefore inspected during data prep, although trainer configs and metrics confirm `validation_source=train_dev`, `eval_examples=5000`, and no official validation evaluation. Future train-dev wrappers should use a train-only prep path if the strict operational rule is interpreted as no official-test file access.
- Low caveat: top-level `program.md` may be stale relative to this G5-T2 trace; this trace is the current record for the Muon sweep.
- Required before any positive optimizer claim: same-run default `MUON_LR=0.035` train-dev reference, preferably paired on the same seeds.

## Logging Gate

Flywheel logging is explicitly ruled out for this pilot result at this point because the user requested a bounded pilot summary, not a graph mutation, and the result is a negative screening decision with no record claim. This trace is sufficient handoff material if the series is later curated into Flywheel.
