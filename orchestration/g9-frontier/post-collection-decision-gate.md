# G9 Post-Collection Decision Gate

## Purpose

This gate turns the two pending collection outcomes into one next action. It is
not permission to launch every branch. It is a deterministic routing rule for the
main orchestrator and workstream orchestrators after Leonardo SSH access returns,
the collector finishes, raw paired metrics are recomputed, and an independent
critic reviews each stream.

Pending streams and collection evidence:

| Stream | Job | Run id | Required collection status |
| --- | ---: | --- | --- |
| G8-B official `ns3_mom93` | `48463506` | `g8b_ns3_mom93_official_20260704T003556Z` | terminal `sacct`, scheduler logs, remote manifest, and `COLLECTION_COMPLETE.txt` or explicit incomplete/failure collection status |
| AirBench dev10 | `48463507` | `airbench_aug_pad2_alt_dev10_20260704T003552Z` | terminal `sacct`, scheduler logs, remote manifest, and `COLLECTION_COMPLETE.txt` or explicit incomplete/failure collection status |

No duplicate, replacement, or dependent job may be launched while either terminal
state is unknown. If a pending job failed or was canceled, preserve the failure
evidence first; any rerun requires a new run id, new output directory, and new
pre-registration trace.

For routing, each stream must receive exactly one critic classification:

- `pass`: terminal completed job, required raw artifacts present, recompute PASS,
  and result critic PASS for the predeclared criterion.
- `fail`: terminal job evidence exists, and the result failed the predeclared
  criterion, failed rule/provenance checks, or failed/canceled at scheduler level.
- `inconclusive`: terminal evidence exists but artifacts, logs, provenance, or
  recomputation are insufficient to support either pass or fail.

Only `pass` can promote a stream. `fail` and `inconclusive` both block dependent
promotion; `inconclusive` may justify a later rerun only after the preserved
terminal evidence and critic review are written up.

## Common Gates Before Any New Launch

- Run collection only with `bash orchestration/g9-frontier/collect_pending_jobs.sh --execute` after SSH authentication works.
- Run `orchestration/g9-frontier/recompute_paired_metrics.py` on the collected raw artifact root when raw paired artifacts exist. Scheduler-level failed/canceled streams without raw paired artifacts require terminal `sacct`, logs/manifest, and critic classification instead.
- Attach a separate `scientific-critic` review for each collected result before promote/hold/kill.
- Keep follow-up runs exploratory unless explicitly promoted later:
  - `RECORD=0`
  - `VALIDATION_SOURCE=train_dev`
  - `C100_DEV_PER_CLASS=50`
  - `C100_DEV_SPLIT_SEED=20260703`
- Official validation is reserved for a later pre-registered finalist only. Do not use official validation to choose among branches.
- Every new run must have a unique `RUN_ID`, absent output directory, recorded claim, hypothesis, decision criterion, validation mode, expected config diff, and owner.
- Before any CINECA launch, apply the SLURM/run-isolation gates from
  `orchestration/g9-frontier/trajectory-plan.md`:
  - account is `IscrC_SIMP`;
  - A100 jobs use `boost_usr_prod` with the established QoS pattern only after
    the branch is approved;
  - datasets and checkpoints are not stored under `$WORK`;
  - outputs stay under the established scratch root
    `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/`;
  - `test ! -e outputs/cifar100_speedrun/${RUN_ID}` passes remotely;
  - `bash -n slurm/paired_compare.sh` passes;
  - `python3 -m py_compile cifar100-benchmark/train_cifar100_resnet_muon.py`
    passes or the current repository-equivalent compile check is recorded;
  - active jobs are checked to avoid duplicate work on the same run id or branch.

## Branch A: G8-B Official Passes, AirBench Dev10 Passes

Interpretation: `ns3_mom93` is the active speed substrate, and AirBench
translate2/alternating-flip is a train-dev reserve candidate.

Next launch: exactly one paired train-dev dev3 additive test.

Claim: adding AirBench train-only augmentation to the official-passing
`longwarm + ns3_mom93` substrate preserves accuracy while retaining the optimizer
mechanics speed gain.

Hypothesis: the optimizer-cost gain and train-only augmentation reserve are mostly
independent.

Decision criterion:

- candidate mean train-dev accuracy `>= control mean - 0.001`;
- candidate minimum train-dev accuracy `>= 0.697`;
- mean time ratio `<= 1.01` versus the `longwarm + ns3_mom93` control;
- raw config diff contains only `C100_TRANSLATE_PAD=2` and
  `C100_FLIP_MODE=alternating` on the candidate side;
- recompute PASS and critic PASS.

Template run metadata:

```text
RUN_ID=g9_add_ns3_mom93_airbench_dev3_<UTC>
RUNS=3
RECORD=0
VALIDATION_SOURCE=train_dev
BASE_SEED=<fresh predeclared seed block>
CONTROL_ENV=C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93
CANDIDATE_ENV=<CONTROL_ENV> C100_TRANSLATE_PAD=2 C100_FLIP_MODE=alternating
```

Promotion: dev10 train-dev only after dev3 PASS and critic approval. Official
finalist only after dev10 PASS, new pre-registration, and a separate official
critic gate.

## Branch B: G8-B Official Passes, AirBench Dev10 Fails

Interpretation: `ns3_mom93` remains the active speed substrate, but AirBench is
not accepted as reserve.

Deterministic next action:

1. If the G8-B official critic says the official accuracy margin is sufficient
   for a record claim and no 12-epoch compression is being attempted next, launch
   nothing; prepare a logging handoff for the official G8-B result.
2. Otherwise launch exactly one G8-C color-jitter dev3 screen on the
   `longwarm + ns3_mom93` substrate.
3. If the G8-B critic marks the official result `pass` but flags unresolved
   provenance/config issues, launch nothing until those issues are resolved.

Claim for optional color-jitter dev3: low-magnitude train-only brightness/contrast
jitter adds reserve on top of `longwarm + ns3_mom93` within the predeclared
time-ratio threshold.

Decision criterion:

- candidate mean train-dev accuracy `>= control mean - 0.001`;
- candidate minimum train-dev accuracy `>= 0.697`;
- mean time ratio `<= 1.03`;
- candidate-only diff is exactly `C100_COLOR_JITTER=1`,
  `C100_COLOR_BRIGHTNESS=0.08`, `C100_COLOR_CONTRAST=0.08`;
- recompute PASS and critic PASS.

Template run metadata:

```text
RUN_ID=g9_g8c_jitter_ns3_mom93_dev3_<UTC>
RUNS=3
RECORD=0
VALIDATION_SOURCE=train_dev
BASE_SEED=<fresh predeclared seed block>
CONTROL_ENV=C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93
CANDIDATE_ENV=<CONTROL_ENV> C100_COLOR_JITTER=1 C100_COLOR_BRIGHTNESS=0.08 C100_COLOR_CONTRAST=0.08
```

## Branch C: G8-B Official Fails, AirBench Dev10 Passes

Interpretation: AirBench remains a reserve candidate, but `ns3_mom93` cannot be
treated as an official speed substrate.

Deterministic next action:

1. Keep the active official leader as `13ep-onecycle-longwarm`.
2. If the AirBench dev10 critic marks the result as strong enough to provide
   reserve for compression, run one reserve-backed 12-epoch train-dev dev3 test
   on longwarm plus AirBench only.
3. If the AirBench dev10 critic marks the result pass but not strong enough for
   compression, run one AirBench-on-longwarm dev3 confirmation.
4. Do not include failed official `ns3_mom93` knobs in either launch. Any future
   `ns3_mom93` repair test requires a new plan artifact and critic approval.

AirBench-on-longwarm decision criterion:

- candidate mean train-dev accuracy `>= control mean`;
- candidate minimum train-dev accuracy `>= 0.697`;
- mean time ratio `<= 1.01`;
- candidate-only diff is exactly `C100_TRANSLATE_PAD=2` and
  `C100_FLIP_MODE=alternating`;
- no validation path edits or validation-time changes;
- recompute PASS and critic PASS.

AirBench-on-longwarm template run metadata:

```text
RUN_ID=g9_airbench_longwarm_confirm_dev3_<UTC>
RUNS=3
RECORD=0
VALIDATION_SOURCE=train_dev
C100_DEV_PER_CLASS=50
C100_DEV_SPLIT_SEED=20260703
BASE_SEED=<fresh predeclared seed block>
CONTROL_ENV=C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0
CANDIDATE_ENV=<CONTROL_ENV> C100_TRANSLATE_PAD=2 C100_FLIP_MODE=alternating
```

Reserve-backed 12-epoch decision criterion:

- candidate mean train-dev accuracy `>= 0.704` or `>= control mean - 0.002`;
- candidate minimum train-dev accuracy `>= 0.697`;
- mean time ratio `<= 0.92` versus 13-epoch longwarm;
- candidate-only diff contains `C100_EPOCHS=12`, the established reserve knobs,
  and no failed official optimizer-mechanics knobs.

Reserve-backed 12-epoch template run metadata:

```text
RUN_ID=g9_airbench_12ep_longwarm_dev3_<UTC>
RUNS=3
RECORD=0
VALIDATION_SOURCE=train_dev
C100_DEV_PER_CLASS=50
C100_DEV_SPLIT_SEED=20260703
BASE_SEED=<fresh predeclared seed block>
CONTROL_ENV=C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0
CANDIDATE_ENV=C100_EPOCHS=12 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_TRANSLATE_PAD=2 C100_FLIP_MODE=alternating
```

## Branch D: Both Pending Streams Fail Or Are Inconclusive

Interpretation: no additive candidate is justified.

Deterministic next action: skip combinations, then apply this priority order.

1. If at least one pending stream has complete terminal failure evidence and the
   critics identify no artifact/provenance blocker, pause GPU spending and
   prepare a failure insight/logging handoff for the failed branches.
2. If both streams are `inconclusive` because artifacts are missing or corrupted,
   launch nothing; write a rerun pre-registration only after the missing evidence
   and non-overwrite guarantee are documented.
3. If critics explicitly say more train-only reserve screening is still useful,
   run one G8-C low-magnitude color-jitter train-dev dev3 screen on
   `13ep-onecycle-longwarm`.
4. Otherwise do not launch. Request a critic-first AirBench front-end architecture
   review; that review is read-only and cannot implement or submit a job.

Do not run 12-epoch compression in this branch.

## Official Finalist Gate

An official finalist can be proposed only after:

- a train-dev dev10 result passes its predeclared criterion;
- an independent critic confirms the result is not using official validation for
  search;
- the finalist is pre-registered with `RECORD=1`, `VALIDATION_SOURCE=official`,
  `RUNS=30`, fixed plain CIFAR-100 test validation, same-pod paired comparison,
  no validation-time adaptation, no TTA, no ensembles, no timing-boundary change,
  and an absent output directory;
- the Flywheel target remains the existing root
  `83c2d2f5-2ac3-5ee5-85f1-2d5bb87ef299`; do not create a new root for the
  record.

## Trace Requirements

Each branch execution trace must record:

- terminal `sacct` evidence for prerequisite jobs;
- collection directory paths;
- recompute command and output paths;
- critic agent/thread id and verdict;
- run id, output directory, commit SHA, branch, and expected config diff;
- exact launch command if a launch occurs;
- babysitting notes through terminal scheduler state;
- local artifact mirror path and verification outputs;
- unresolved risks.
