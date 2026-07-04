# G8-B ns3_mom93 Dev10 Result Audit

## Verdict

Pass.

The G8-B `ns3_mom93` dev10 train-dev artifacts support the reported `promote` recommendation as train-dev search evidence. No blocker was found.

## Issues

- Low: remote Git state was dirty and run configs record remote head `2c3edb7`, not a clean checkout of synced local commit `fdb65d9`. Reproducibility should cite the dirty remote head plus verified launch-file hashes, not imply a clean `fdb65d9` checkout. For any official rerun, launch from a clean checkout or record an archive/tree SHA and exact per-file hashes as the executable surface.
- Low: `remote-preflight.txt` contains an initial failed `bash -n slurm/paired_compare.sh` from the wrong directory, then a corrected pass. This has no launch impact because the corrected syntax and py_compile checks passed before submission.

## Claims Allowed

- Unique isolated run: `g8b_ns3_mom93_longwarm_dev10_20260704T000009Z`.
- Scheduler completed cleanly: job `48460378`, `COMPLETED`, exit `0:0`, elapsed `00:15:39`.
- `RECORD=0`, `validation_source=train_dev`, `RUNS=10`.
- All 20 raw configs use `validation_source=train_dev`, `dev_per_class=50`, `dev_split_seed=20260703`, `train_examples=45000`, and `eval_examples=5000`.
- Baseline and candidate configs match the requested envs.
- Recomputed metrics support `promote`: baseline mean acc `0.70432`, candidate `0.70970`, delta `+0.00538`; mean time ratio `0.93195`; candidate faster on `10/10`; candidate hit target on `10/10` versus baseline `7/10`.

## Claims Requiring Downgrade

- Do not call this official validation, finalist evidence, record evidence, or test-set evidence.
- Do not claim generalization to CIFAR-100 official test validation.
- Do not claim statistically definitive superiority beyond this 10-seed train-dev sample.
- Do not describe the remote run as a clean Git checkout of `fdb65d9`; say the relevant launch-file hashes matched `fdb65d9`.

## Required Reruns Or Checks

None required for the train-dev promote/hold/kill decision.

Before official/finalist claims: clean pre-registered official validation with `RECORD=1`, `VALIDATION_SOURCE=official`, sufficient paired seeds/runs, and a clean reproducibility bundle.

## Trace

Read-only audit. No edits, jobs, Flywheel, or Linear mutations.
