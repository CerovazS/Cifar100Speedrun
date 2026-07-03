# G5b-T6 Batch/Schedule Pilot Design

## Objective

Design exactly one next train-dev dev3 pilot for the CIFAR-100 A100 speedrun that tests batch/step-count mechanics rather than repeating scalar epoch or Muon-LR sweeps. This is a plan only: no job has been launched.

## Claim, Hypothesis, Decision Criterion

- Claim under test: increasing the training batch from `1024` to `1536` at the full `16` epoch data-pass budget can reduce timed training enough to be a viable speedrun candidate while preserving train-dev accuracy close to the default.
- Hypothesis: at fixed `EPOCHS=16`, `C100_BATCH=1536` cuts optimizer updates from `688` to `464` on the 45k train-dev training split. A single sqrt-scaled LR setting, `C100_MUON_LR=0.040` and `C100_BIAS_LR=0.024`, should partially compensate for the larger batch without turning this into another LR sweep.
- Pass gate: all artifacts complete, `record_mode=false`, `validation_source=train_dev`, `paired_seeds=3`, candidate config has `batch_size=1536`, and the candidate satisfies all four numeric checks:
  - `mean_time_ratio <= 0.78`
  - `mean_val_acc_delta >= -0.0030`
  - candidate mean train-dev `val_acc >= 0.7000`
  - candidate `target_hit_count >= 2/3`
- Fail/kill gate: any missing artifact, official validation use, output reuse, nonzero job exit, candidate/control config mismatch outside the declared knobs, or failure of any numeric pass check. A failed pilot must not expand to dev10, paired train-dev promotion, official validation, or record mode.

## Recommended Pilot

Use `slurm/paired_compare.sh` so the default control and candidate run in the same allocation, on the same seed triplet, with AB/BA order recorded in `paired_order.csv`.

Candidate env:

```bash
C100_BATCH=1536 C100_MUON_LR=0.040 C100_BIAS_LR=0.024
```

Control env:

```bash
# implicit paired_compare.sh defaults
C100_BATCH=1024 C100_MUON_LR=0.035 C100_BIAS_LR=0.02
```

Launch shape for later main-review approval:

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
export CIFAR100_ROOT="$(pwd -P)"
unset BATCH MUON_LR BIAS_LR C100_BATCH C100_MUON_LR C100_BIAS_LR
export RUN_ID="g5b_t6_b1536_sqrtlr_dev3_$(date -u +%Y%m%dT%H%M%SZ)_$(git rev-parse --short HEAD)"
export RECORD=0
export RUNS=3
export EPOCHS=16
export TARGET=0.70
export BASE_SEED=882600
export VALIDATION_SOURCE=train_dev
export CANDIDATE_ENV="C100_BATCH=1536 C100_MUON_LR=0.040 C100_BIAS_LR=0.024"
sbatch --parsable --job-name=c100-g5b-t6-b1536 --export=ALL slurm/paired_compare.sh
```

Expected output root:

```text
outputs/cifar100_speedrun/g5b_t6_b1536_sqrtlr_dev3_<UTC>_<shortsha>/
```

Expected artifacts:

- `paired_order.csv`
- `paired_summary.json`
- per-seed baseline/candidate `config.json`, `metrics.csv`, `summary.json`, `warmup.json`, `repro_metadata.json`
- copied `stdout.log` and `stderr.log`
- scheduler accounting from `sacct`

## Resource Needs And Kill Criteria

- Hardware/account: one Leonardo A100 under `IscrC_SIMP`.
- Submit location: scratch checkout only, `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`.
- Validation: `RECORD=0`, `VALIDATION_SOURCE=train_dev`; `paired_compare.sh` prepares only `train` in non-record mode.
- Expected cost: one debug-QOS job, about `8-15` wall minutes; hard SLURM cap `00:30:00`, so worst-case allocation is `0.5` A100-hours. Expected allocation is about `0.15-0.25` A100-hours.
- Kill immediately if the run leaves the scratch checkout, uses an account other than `IscrC_SIMP`, touches official validation, reuses an output directory, or reports a candidate config that does not differ from baseline on `batch_size`, `muon_lr`, and `bias_lr`.

## Rejected Alternatives

- Batch sweep over `{768,1024,1536,2048}`: rejected because T6 is constrained to exactly one pilot and broad sweeps would add multiple comparisons.
- `EPOCHS=10/12/14` variants: rejected because T1 already tested scalar epoch compression and T1/T2 covered 14-epoch LR variants.
- Muon LR-only at batch `1024`: rejected because T2 already killed scalar Muon LR-only exploration.
- `C100_BATCH=2048`: rejected for this next step because it cuts train-dev updates to `336` at 16 epochs, likely a harsher under-training regime than the current evidence justifies.
- `C100_BATCH=512` or `768`: rejected because they increase optimizer steps and likely training time; they are accuracy-rescue probes, not the next speedrun reduction probe.
- New schedule code knob such as 1cycle, warmup, or cosine floor: deferred because an existing batch/step-count knob can test the mechanism first without code changes.

## Pre-Launch Critic

Verdict: conditional pass.

- Scientific validity: the claim is narrow and paired against a matched default control, so the run can support a dev3 screen for a batch/step-count candidate. It cannot support a finalist or record claim.
- Reproducibility: command shape, seed base, run id pattern, output root, and numeric gates are predeclared.
- Main blocker before launch: main reviewer must confirm the active scratch checkout is the intended audited state and that no global `C100_*`, `BATCH`, `MUON_LR`, or `BIAS_LR` variables leak into the baseline.

## Trace

- Files read: `program.md`, `orchestration/g5b-search/assignments.md`, `orchestration/g5-t1-schedule/summary.md`, `orchestration/g5-t2-muon/summary.md`, `orchestration/g5-t3-arch/summary.md`, `cifar100-benchmark/train_cifar100_resnet_muon.py`, `slurm/paired_compare.sh`, `slurm/discovery.sh`, plus repo guidance summaries.
- Files touched: `orchestration/g5b-t6-batch-schedule/summary.md`.
- Jobs launched: none.
- Outputs produced: this trace summary only.
- Unresolved risks: dev3 is noisy; larger batch may lose too much accuracy despite LR scaling; paired runner is pilot-grade and pays repeated warmup/compile overhead.
