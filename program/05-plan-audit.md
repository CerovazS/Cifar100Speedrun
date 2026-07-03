# Plan Audit

## Verdict

Blocked for GPU-hour spending on parallel search or record attempts. Conditional pass only for control patches, local/static verification, remote read-only environment checks, and one interactive smoke.

## P0 Issues

1. Official baseline is not established under current defaults.
   - Impact: the 70% target may be based on one lucky historical seed and older compile mode.
   - Required fix: run current-default 30-run baseline after control patch and interactive validation.

2. Official test split is currently the only validation/search gate.
   - Impact: parallel search can overfit the public validation gate.
   - Required fix: add train-derived dev validation for exploratory search; official test only for pre-registered finalists.

3. Paired same-pod comparison is required but not implemented.
   - Impact: speedups can be node/cache/order artifacts.
   - Required fix: implement paired baseline/candidate runner with same seed list and AB/BA order.

4. No isolated machine-readable artifact standard exists.
   - Impact: partial or failed runs can look usable; records are hard to audit.
   - Required fix: unique output directories with metrics CSV/JSON, logs, environment metadata, config, commit, and summary.

## P1 Issues

- Environment is not repo-local and depends on an external CIFAR-10 venv.
- Compile/cache behavior must be frozen and paired consistently.
- Dataset source equivalence is unverified.
- The 70% decision rule needs a pre-registered margin or lower-bound rule.

## P2 Issues

- Stale `50-run` wording in `SMOKE_RESULT.md`.
- `C100_COMPILE=0` undefined `off` bug.
- Prior wrapper issues around `TARGET` propagation and masked official-baseline analyzer failures are fixed locally; keep them covered by static checks.

## Claims Allowed Now

- The smoke path has previously executed end to end.
- One historical compiled `reduce-overhead` 16-epoch seed reached 70.58%.
- The current code intends plain no-TTA validation and stops timing before validation.

## Claims Not Allowed Yet

- The baseline clears 70% over 30 runs.
- The default compiled baseline is validated.
- Any speedup is algorithmic rather than infrastructure.
- A candidate is a record.
- Parallel search is safe from validation overfitting.

## Required Checks Before Launch

- Local shell/static checks after patch.
- Remote CINECA environment validation in `IscrC_SIMP`.
- Interactive GPU smoke before `sbatch`.
- Audit of G1 implementation before G3/G5 spend.

## G1b Control Patch Status

Implemented locally, pending independent scientific-critic audit before GPU spend.

- Official-mode warmup no longer evaluates the official validation split and is excluded from `metrics.csv`; warmup metadata is isolated in `warmup.json`.
- Trainer writes `repro_metadata.json` with git commit, branch, dirty status, tracked diff hash/path, repo URL when available, safe environment/cache variables, Slurm variables, and GPU metadata.
- `slurm/paired_compare.sh` defaults to `VALIDATION_SOURCE=train_dev`; `RECORD=1` requires official validation and exactly 30 paired seeds, so a 10-run G6 pilot cannot be labeled a record.
- Candidate `C100_*` overrides are preserved for candidate invocations, and the paired summarizer fails if non-empty `CANDIDATE_ENV` leaves tracked candidate config equal to baseline.
- Paired comparison is now per-seed alternating AB/BA with `paired_order.csv`; this is pilot-grade for G4, while a more efficient pre-registered G6 runner may still be needed.

## G1c Scratch Checkout Launch Patch Status

Implemented locally on 2026-07-03 without launching jobs.

- `env_setup.sh` no longer requires `/leonardo_work`; it defaults `CIFAR100_ROOT` from the current checkout when possible, otherwise from `${SCRATCH}/cifar100_speedrun/Cifar100Speedrun`.
- SLURM wrappers resolve `CIFAR100_ROOT`, `cd` to the checkout, source `env_setup.sh`, and write outputs under `$CIFAR100_ROOT/outputs/cifar100_speedrun`.
- Scheduler stdout/stderr directives are relative `logs/...`; submit from the checkout root with `logs/` present.
- Account guard, validation-source gates, run counts, targets, and paired comparison semantics are unchanged.
