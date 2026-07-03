# G8-B Muon Mechanics Runtime Trace

## Objective

Restart the bounded G8-B Muon mechanics train-dev pilot with train-dev split identity explicitly pinned in launch env. No Flywheel mutation.

## Claim, Hypothesis, And Criterion

Claim: reducing Newton-Schulz steps or Muon momentum can materially reduce 13-epoch longwarm paired training time without collapsing train-dev accuracy.

Hypothesis: at equal 13-epoch one-cycle longwarm schedule and fixed train-dev split (`C100_DEV_PER_CLASS=50`, `C100_DEV_SPLIT_SEED=20260703`), `C100_NS_STEPS=4`, `C100_NS_STEPS=3`, or `C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93` will preserve `candidate_target_hits=3/3` and mean train-dev accuracy in the existing longwarm range while improving mean time.

Decision gate: promote only if a candidate has train-dev `candidate_target_hits=3/3`, mean candidate accuracy at least comparable to the 13-epoch longwarm dev3/dev10 range or no obvious collapse, and mean time improves materially over the paired 13-epoch longwarm baseline. Otherwise hold or kill.

## Launch Constraints

- `RECORD=0`
- `VALIDATION_SOURCE=train_dev`
- `RUNS=3`
- `C100_DEV_PER_CLASS=50`
- `C100_DEV_SPLIT_SEED=20260703`
- unique `BASE_SEED` and timestamped `RUN_ID` per candidate
- no official validation, no `RECORD=1`, no validation path edits, no TTA/adaptation
- no output directory reuse
- one A100 SLURM jobs on IscrC_SIMP/Leonardo
- do not mutate Flywheel

## Candidates

Shared baseline env:

`C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0`

Shared split env:

`C100_DEV_PER_CLASS=50 C100_DEV_SPLIT_SEED=20260703`

| Candidate | RUN_ID | BASE_SEED | Candidate env |
|---|---:|---:|---|
| g8b_ns4_longwarm_dev3 | g8b_ns4_longwarm_dev3_20260703T233518Z | 893520 | `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=4` |
| g8b_ns3_longwarm_dev3 | g8b_ns3_longwarm_dev3_20260703T233518Z | 893530 | `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=3` |
| g8b_ns3_mom93_longwarm_dev3 | g8b_ns3_mom93_longwarm_dev3_20260703T233518Z | 893540 | `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93` |

## Exact Launch Commands

Run from remote checkout `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`:

```bash
C100_DEV_PER_CLASS=50 C100_DEV_SPLIT_SEED=20260703 BASELINE_ENV='C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0' CANDIDATE_ENV='C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=4' RECORD=0 VALIDATION_SOURCE=train_dev RUNS=3 BASE_SEED=893520 RUN_ID=g8b_ns4_longwarm_dev3_20260703T233518Z EPOCHS=13 TARGET=0.70 sbatch --parsable --export=ALL,C100_DEV_PER_CLASS,C100_DEV_SPLIT_SEED,BASELINE_ENV,CANDIDATE_ENV,RECORD,VALIDATION_SOURCE,RUNS,BASE_SEED,RUN_ID,EPOCHS,TARGET slurm/paired_compare.sh
C100_DEV_PER_CLASS=50 C100_DEV_SPLIT_SEED=20260703 BASELINE_ENV='C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0' CANDIDATE_ENV='C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=3' RECORD=0 VALIDATION_SOURCE=train_dev RUNS=3 BASE_SEED=893530 RUN_ID=g8b_ns3_longwarm_dev3_20260703T233518Z EPOCHS=13 TARGET=0.70 sbatch --parsable --export=ALL,C100_DEV_PER_CLASS,C100_DEV_SPLIT_SEED,BASELINE_ENV,CANDIDATE_ENV,RECORD,VALIDATION_SOURCE,RUNS,BASE_SEED,RUN_ID,EPOCHS,TARGET slurm/paired_compare.sh
C100_DEV_PER_CLASS=50 C100_DEV_SPLIT_SEED=20260703 BASELINE_ENV='C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0' CANDIDATE_ENV='C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93' RECORD=0 VALIDATION_SOURCE=train_dev RUNS=3 BASE_SEED=893540 RUN_ID=g8b_ns3_mom93_longwarm_dev3_20260703T233518Z EPOCHS=13 TARGET=0.70 sbatch --parsable --export=ALL,C100_DEV_PER_CLASS,C100_DEV_SPLIT_SEED,BASELINE_ENV,CANDIDATE_ENV,RECORD,VALIDATION_SOURCE,RUNS,BASE_SEED,RUN_ID,EPOCHS,TARGET slurm/paired_compare.sh
```

## Status

- Previous runtime canceled because split identity was not explicitly pinned in launch env.
- Restart trace created.
- Remote output-dir checks passed.
- Jobs completed: `48457399`, `48457400`, `48458063`.
- Artifacts pulled under `remote-artifacts/`.
- Verification found no config violations; see `verification.json` and `metrics-table.tsv`.
- Verdict: promote `g8b_ns3_mom93_longwarm_dev3` to dev10 train-dev only; hold `ns3`; kill `ns4` as lower-value.

## Metrics

| Candidate | Job | Hits | Candidate mean acc | Baseline mean acc | Acc delta | Candidate mean time | Baseline mean time | Time delta | Time ratio |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `ns4` | `48457399` | 3/3 | 0.703400 | 0.706067 | -0.002667 | 18.596384 | 19.247712 | -0.651327 | 0.966171 |
| `ns3` | `48457400` | 3/3 | 0.705400 | 0.704933 | +0.000467 | 17.544117 | 18.802412 | -1.258295 | 0.933079 |
| `ns3_mom93` | `48458063` | 3/3 | 0.709867 | 0.704867 | +0.005000 | 17.613634 | 19.024153 | -1.410519 | 0.925927 |

## Audit Notes

- All final configs verified `validation_source=train_dev`, `dev_per_class=50`, `dev_split_seed=20260703`.
- Baseline configs verified the 13-epoch one-cycle longwarm reference: `C100_EPOCHS=13`, `C100_LR_SCHEDULE=onecycle`, `C100_ONECYCLE_PCT_UP=0.40`, `C100_ONECYCLE_DIV_FACTOR=10.0`, default `ns_steps=5`, default `muon_momentum=0.95`.
- Candidate diffs matched the intended mechanics fields.
- No official validation and no `RECORD=1` were used.
- Final result audit used a direct-review exception because a fresh critic spawn was blocked by the agent thread limit.

## Trace

Commands, files, outputs, job IDs, and risks will be appended in `agent-trace.jsonl` and summarized after completion.
