# G5-T3 Architecture Pareto Pilot

## Objective

Run bounded train-dev architecture pilots for the CIFAR-100 Speedrun on CINECA SIMP. This phase is exploratory only: it uses `C100_VALIDATION_SOURCE=train_dev`, does not touch official validation, and makes no record claims.

## Claim, Hypothesis, Decision Criterion

- Claim under test: among the three planned smaller or reshaped `SimpleResNet` variants, at least one can produce a useful train-dev time/accuracy follow-up candidate without using official validation.
- Hypothesis: at `EPOCHS=14`, at least one of the planned variants keeps train-dev mean validation accuracy close enough to the 70% target to justify a bounded follow-up while reducing mean timed training seconds.
- Decision criterion: run dev3 for each planned variant. Expand only if a variant has complete artifacts, uses train-dev validation, preserves timing/validation boundaries, and either reaches mean train-dev validation accuracy close enough to the 70% target for a plausible 16-epoch follow-up or offers a clear time reduction with recoverable accuracy. Kill variants with hard errors, output reuse, official validation, or clearly inferior accuracy/time.
- Metric/evidence: per-variant `summary.json`, `metrics.csv`, `config.json`, Slurm stdout/stderr, and GPU accounting from `sacct`.

## Planned Runs

All runs submit from `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun` under `IscrC_SIMP`, with outputs under `outputs/cifar100_speedrun/`.

| Variant | RUN_ID prefix | Env | Runs | Epochs | Validation |
| --- | --- | --- | --- | --- | --- |
| narrow222 | `g5_t3_arch_narrow222_20260703T144336Z` | `C100_WIDTHS=48,96,192 C100_BLOCKS=2,2,2` | 3 | 14 | train_dev |
| basewidth222 | `g5_t3_arch_basewidth222_20260703T144336Z` | `C100_WIDTHS=64,128,192 C100_BLOCKS=2,2,2` | 3 | 14 | train_dev |
| shallow122 | `g5_t3_arch_shallow122_20260703T144336Z` | `C100_WIDTHS=64,128,256 C100_BLOCKS=1,2,2` | 3 | 14 | train_dev |

## Code Gate

Needed minimal trainer patch because architecture was hard-coded as `SimpleResNet()`:

- added `C100_WIDTHS` and `C100_BLOCKS` parsing as three comma-separated positive integers;
- preserved defaults `(64,128,256)` and `(2,2,2)`;
- recorded selected widths/blocks in `config.json`;
- did not edit validation code, timing boundaries, Slurm wrappers, or shared runner semantics.

Local verification: `python3 -m py_compile cifar100-benchmark/train_cifar100_resnet_muon.py`.

## Status

- Patch status: applied locally and remotely as an uncommitted trainer diff. Remote trainer syntax check passed.
- Remote status: Leonardo checkout `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`, branch `codex/cifar100-speedrun-control`, commit `eb4f1a5954c045390a1644a643c182beac17747d`, dirty only for the architecture env-knob patch.
- Jobs: completed successfully, all `C100_VALIDATION_SOURCE=train_dev`, all `0:0` exit.
- Critic gate: implementation audit returned conditional pass; result audit returned pass with caveats.
- Flywheel logging: ruled out for this turn because the requested stop condition was to stop after train-dev pilots and return evidence. This is exploratory evidence, not a record claim; the local trace is retained for a later logger handoff if requested.

## Results

| Variant | Job | Widths | Blocks | Mean train-dev acc | Hits | Mean timed train | Slurm elapsed | Node |
| --- | --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| narrow222 | `48407776` | `48,96,192` | `2,2,2` | `0.671267` | `0/3` | `17.574507s` | `00:04:48` | `lrdn0055` |
| basewidth222 | `48407854` | `64,128,192` | `2,2,2` | `0.683400` | `0/3` | `19.807051s` | `00:04:14` | `lrdn0055` |
| shallow122 | `48408536` | `64,128,256` | `1,2,2` | `0.689267` | `0/3` | `17.119659s` | `00:04:07` | `lrdn0668` |

All configs verified:

- `validation_source=train_dev`
- `runs=3`
- `epochs=14.0`
- `train_examples=45000`
- `eval_examples=5000`
- `compile_mode=default`

Slurm stderr files were empty for all three jobs. Warmup skipped validation in all logs. No official validation was used.

GPU allocation spent: `00:13:09` on one A100 total (`789s`, about `0.219` A100-hours). The earlier rejected submissions failed before job allocation and did not spend GPU time.

## Audit

Final scientific-critic verdict: pass with caveats.

- This artifact supports only an exploratory train-dev summary.
- No matched default-architecture train-dev control was run in this G5-T3 phase, so this does not establish a Pareto improvement over the default architecture.
- The artifacts are audit-sufficient for this pilot but not Flywheel/publication-complete: no plot, `reproducibility.md`, or `commit.txt` was prepared.
- Local `program.md` may be stale because other trajectory work was active; this does not invalidate the G5-T3 run artifacts.

## Recommendation

Kill `narrow222` and `basewidth222` as configured at 14 epochs. Treat `shallow122` as the best observed among the three tested variants and only as a possible follow-up if the next approved question is whether its faster 14-epoch timing can recover enough accuracy at 16 epochs or with schedule/LR changes. Do not expand to dev10 or official validation without main approval.
