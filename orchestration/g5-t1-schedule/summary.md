# G5-T1 Schedule Compression Trace

## Objective

Run the bounded step-budget / schedule-compression trajectory on CINECA SIMP using only train-derived validation. This phase is exploratory and cannot support official validation or record claims.

## Claim, Hypothesis, Decision Criterion

- Claim under test: the current 16-epoch baseline may have step-budget slack, so shorter schedules can approach or clear the train-dev `0.7000` target with lower timed training.
- Hypothesis: among `10`, `12`, and `14` epochs with default Muon/bias LRs, at least one schedule will produce dev3 evidence strong enough to justify a narrow LR sweep.
- Decision criterion: expand only if the best dev3 epoch has train-dev mean `val_acc >= 0.6950`; select the highest-mean epoch, breaking ties by lower mean time. Kill if all dev3 means are below `0.6950`. Do not expand to dev10 without main approval.
- Evidence: SLURM job states, exact env vars, unique output dirs under `outputs/cifar100_speedrun`, `config.json`, `metrics.csv`, `summary.json`, scheduler logs, and GPU accounting.

## Planned Jobs

1. Dev3 epoch discovery:
   - `RUN_ID_PREFIX=g5t1_20260703_164215_dev3_default`
   - `RUNS=3`
   - `EPOCHS_LIST="10 12 14"`
   - `TARGET=0.70`
   - `BATCH=1024`
   - `SEED_BASE=880000`
   - wrapper: `slurm/discovery.sh`
   - validation: forced by wrapper as `C100_VALIDATION_SOURCE=train_dev`
2. Conditional dev3 LR sweep:
   - same wrapper and validation source
   - `RUNS=3`
   - `EPOCHS_LIST=<selected_epoch>`
   - `MUON_LR=0.030,0.040,0.045`
   - unique `RUN_ID_PREFIX` per LR
   - the same seed triplet for every LR value to avoid seed-block confounding

## Remote Context

- Checkout root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Account: `IscrC_SIMP`
- Submit directory: checkout root only
- Allowed write surface: run outputs/logs plus this trace; no trainer or shared wrapper edits planned.

## Status

- Pre-launch trace created.
- Pre-launch critic delegated.
- Dev3 discovery submitted as SLURM job `48407198`.

## Commands Submitted

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
export RUN_ID_PREFIX=g5t1_20260703_164215_dev3_default
export RUNS=3
export EPOCHS_LIST="10 12 14"
export TARGET=0.70
export BATCH=1024
export SEED_BASE=880000
export VALIDATION_SOURCE=train_dev
sbatch --parsable slurm/discovery.sh
```

## Job IDs

- Dev3 epoch discovery: `48407198`

## Interim Discovery Result

Dev3 epoch discovery completed successfully (`COMPLETED`, exit `0:0`, elapsed `00:04:26`, node `lrdn2161`).

| Epochs | Runs | Train-dev mean val_acc | Hit count | Mean train time |
| --- | ---: | ---: | ---: | ---: |
| 10 | 3 | `0.672067` | `0/3` | `14.767372s` |
| 12 | 3 | `0.684067` | `0/3` | `17.637787s` |
| 14 | 3 | `0.697133` | `1/3` | `20.647957s` |

Epoch `14` met the predeclared `>=0.6950` LR-sweep gate. The LR sweep must keep seeds `880000..880002` fixed across LR values.

## LR Sweep Submission Note

An attempted three-job LR sweep submission hit `QOSMaxSubmitJobPerUserLimit`. No intended `g5t1_20260703_164215_dev3_ep14_muonlr*` output directory was created during the failed attempt. Concurrent `c100-discovery` jobs visible in `squeue` are external to G5-T1 (`g5_t2` / `g5_t3` outputs) and must not be counted as G5-T1 evidence.

To avoid repeated partial submissions under the debug-QOS limit, the LR sweep will be submitted as one G5-T1-only trace launcher: `orchestration/g5-t1-schedule/run_lr_sweep.sh`. It does not edit trainer or shared wrappers; it invokes the existing trainer with the approved env knobs and copies shared scheduler logs into each G5-T1 LR output directory.

Submitted single-job LR sweep:

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
export RUN_ID_STEM=g5t1_20260703_164215_dev3_ep14
export RUNS=3
export EPOCHS=14
export TARGET=0.70
export BATCH=1024
export SEED_BASE=880000
export LR_LIST="0.030:0030 0.040:0040 0.045:0045"
sbatch --parsable orchestration/g5-t1-schedule/run_lr_sweep.sh
```

- LR sweep job: `48409232`

## Final Results

All counted runs used `validation_source=train_dev`, `runs=3`, `seed_base=880000`, `batch=1024`, `bias_lr=0.02`, `target=0.70`, and `compile_mode=default`.

| Config | Epochs | Muon LR | Mean train-dev val_acc | Hit count | Mean train time |
| --- | ---: | ---: | ---: | ---: | ---: |
| default | 10 | `0.035` | `0.672067` | `0/3` | `14.767372s` |
| default | 12 | `0.035` | `0.684067` | `0/3` | `17.637787s` |
| default | 14 | `0.035` | `0.697133` | `1/3` | `20.647957s` |
| LR sweep | 14 | `0.030` | `0.692733` | `0/3` | `20.621870s` |
| LR sweep | 14 | `0.040` | `0.694000` | `0/3` | `20.536423s` |
| LR sweep | 14 | `0.045` | `0.694467` | `0/3` | `20.597969s` |

Machine-readable result table: `orchestration/g5-t1-schedule/results.csv` and `orchestration/g5-t1-schedule/results.json`.

Visual artifact: `orchestration/g5-t1-schedule/g5t1_schedule_lr_summary.svg`.

Reproducibility artifacts copied locally after result audit:

- `orchestration/g5-t1-schedule/remote-artifacts/**/repro_metadata.json`
- `orchestration/g5-t1-schedule/remote-artifacts/**/warmup.json`
- `orchestration/g5-t1-schedule/remote-artifacts/**/git_diff.patch`
- `orchestration/g5-t1-schedule/sacct-48407198-48409232.txt`

## Accounting

- Discovery job `48407198`: `COMPLETED`, exit `0:0`, elapsed `00:04:26`, `1x A100`.
- LR sweep job `48409232`: `COMPLETED`, exit `0:0`, elapsed `00:06:48`, `1x A100`.
- Counted G5-T1 GPU allocation: `00:11:14` = about `0.187` A100-hours.
- Failed LR-sweep submission consumed no counted GPU allocation.
- External `g5_t2` / `g5_t3` jobs observed in queue were not counted.

## Recommendation

Kill G5-T1 schedule compression here. The best pilot remains default LR at 14 epochs with train-dev mean `0.697133`, below the `0.7000` target and with only `1/3` hits. The approved LR sweep did not improve over default: all three LR variants were below default on the same seed triplet and had `0/3` hits. Do not expand this trajectory to dev10 and do not touch official validation from this evidence.

## Result Audit

Post-run critic verdict: pass with caveats.

- Confirmed all counted G5-T1 runs used `train_dev`, not official validation.
- Confirmed six unique output directories and reuse guards.
- Confirmed job accounting for `48407198` and `48409232`.
- Confirmed kill/no-dev10 recommendation is supported within pilot scope.
- Caveat: remote run state was dirty at commit `eb4f1a5`; rerun requires the copied `git_diff.patch` files and the trace-scoped LR launcher, not just commit checkout.
- Caveat: this is dev3 train-dev evidence only. It supports a pilot kill decision, not official, record, finalist, or broad impossibility claims.

## Pre-Launch Critic

Verdict: conditional pass. Required fixes before LR sweep:

- Use a numeric expansion gate instead of subjective "close enough"; set here to best dev3 mean `val_acc >= 0.6950`.
- Use the same seed triplet for every LR value; vary only `RUN_ID_PREFIX` and `MUON_LR`.
- Record or copy shared scheduler logs because `discovery.sh` does not copy them into each per-epoch output directory.
