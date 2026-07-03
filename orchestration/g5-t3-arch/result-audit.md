# G5-T3 Result Audit

## Verdict

Pass with caveats. The completed artifacts support a train-dev-only exploratory summary and the `narrow222`/`basewidth222` kill recommendation. They do not support official validation, record, or default-baseline Pareto claims.

## Issues

1. No direct default-architecture control was run in this G5-T3 evidence. Phrase results as best among the three tested variants unless citing a matched default train-dev run.
2. Artifacts are audit-sufficient for the pilot but not publication/Flywheel-complete: no plot, `reproducibility.md`, or `commit.txt`.
3. Local `program.md` may be stale because other trajectory work was active.

## Allowed Claims

- All three jobs used `C100_VALIDATION_SOURCE=train_dev` with `45000` train examples and `5000` dev examples.
- Official validation was not used.
- Reported metrics match remote artifacts:
  - `narrow222`: mean acc `0.671267`, mean timed train `17.574507s`, `0/3`.
  - `basewidth222`: mean acc `0.683400`, mean timed train `19.807051s`, `0/3`.
  - `shallow122`: mean acc `0.689267`, mean timed train `17.119659s`, `0/3`.
- Slurm accounting: jobs `48407776`, `48407854`, `48408536` completed `0:0`; elapsed raw seconds `288 + 254 + 247 = 789`, about `0.219` A100-hours.
- Warmup skipped validation in all three runs.

## Downgraded Claims

- Do not claim architecture Pareto improvement relative to default.
- Do not claim `shallow122` can recover enough accuracy; only say it is the plausible follow-up among these three.
- Do not make official validation, leaderboard, record, or 30-run stability claims.
