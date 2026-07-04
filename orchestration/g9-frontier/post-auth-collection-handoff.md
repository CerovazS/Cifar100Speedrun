# G9 Post-Auth Collection Handoff

## Purpose

This handoff is the first action list after Leonardo SSH authentication is
restored. It exists to shorten the critical path without changing the scientific
gate: collect the two already-launched jobs, classify them, and only then route
through the post-collection decision gate.

This file is not a launch plan. It does not authorize new GPU jobs.

## Preconditions

- SSH authentication to Leonardo works for the same user/account view used to
  launch the jobs.
- Local cwd is the main repository:

```bash
cd "/Users/lucacerovaz/Documents/Cifar100 Speedrun"
```

- No replacement job has been submitted for `48463506` or `48463507`.
- No workstream has been canceled or closed to force this handoff.

## Static Readiness Checks Already Run Locally

These checks were local-only and non-mutating:

```bash
bash -n orchestration/g9-frontier/collect_pending_jobs.sh
python3 -c 'import ast, pathlib; ast.parse(pathlib.Path("orchestration/g9-frontier/recompute_paired_metrics.py").read_text()); print("ast-parse ok")'
```

Observed result: shell syntax check passed; Python AST parse printed
`ast-parse ok`.

## Required Post-Auth Order

1. Collect terminal evidence and available artifacts exactly once:

```bash
bash orchestration/g9-frontier/collect_pending_jobs.sh --execute
```

2. For each stream with raw paired artifacts, recompute metrics from raw
   per-seed `metrics.csv` files. Do not rely on wrapper summaries alone.

G8-B official:

```bash
python3 orchestration/g9-frontier/recompute_paired_metrics.py \
  --run-root <collection_dir>/remote_outputs/g8b_ns3_mom93_official_20260704T003556Z \
  --out-dir <collection_dir>/verification \
  --expected-validation-source official \
  --expected-record-mode true \
  --expected-paired-seeds 30
```

AirBench dev10:

```bash
python3 orchestration/g9-frontier/recompute_paired_metrics.py \
  --run-root <collection_dir>/remote_outputs/airbench_aug_pad2_alt_dev10_20260704T003552Z \
  --out-dir <collection_dir>/verification \
  --expected-validation-source train_dev \
  --expected-record-mode false \
  --expected-paired-seeds 10
```

3. If a stream is scheduler-level failed/canceled and has no raw paired artifact
   root, skip recompute for that stream and preserve terminal `sacct`, scheduler
   logs, manifests, and collection status.
4. Delegate separate critic classifications for G8-B official and AirBench dev10.
   Each stream must be classified as exactly one of `pass`, `fail`, or
   `inconclusive`.
5. Route only through
   `orchestration/g9-frontier/post-collection-decision-gate.md`.

## G8-B Official Critic Prompt

```text
Objective:
Classify the collected G8-B official ns3_mom93 stream as pass, fail, or inconclusive.

Relevant skill(s) to read:
- /Users/lucacerovaz/.codex/skills/critical-scientific-audit/SKILL.md

Context files to read:
- program.md
- orchestration/g9-frontier/post-collection-decision-gate.md
- orchestration/g9-frontier/collection-protocol.md
- orchestration/g9-frontier/recompute-protocol.md
- orchestration/g8-b-muon/runtime-official-20260704T003556Z/trace.md
- orchestration/g8-b-muon/runtime-official-20260704T003556Z/blocked.md
- <collection_dir>/collection_status.md
- <collection_dir>/remote_checks/sacct-48463506.txt
- <collection_dir>/remote_checks/output-manifest.txt
- <collection_dir>/remote_outputs/g8b_ns3_mom93_official_20260704T003556Z/paired_summary.json, if present
- <collection_dir>/verification/verification.json, if recompute was possible

Decision criteria:
- pass only if terminal completed official 30-run evidence exists, raw artifacts
  are complete, recompute PASS exists, RECORD=1, VALIDATION_SOURCE=official,
  official train/test split sizes are verified, clean checkout commit is
  4ba08a7b3fea1652411a3adcabddc33fb2821ffe, no validation path edits/TTA/adaptation
  are present, candidate-only diff is exactly C100_NS_STEPS=3 and
  C100_MUON_MOMENTUM=0.93, and the predeclared metric criterion passes.
- fail if terminal scheduler failure/cancelation exists, rule/provenance checks
  fail, raw metrics recompute fails, or the predeclared metric criterion fails.
- inconclusive if terminal evidence exists but artifacts/provenance are
  insufficient to support pass or fail.

Required output:
1. Classification: pass / fail / inconclusive.
2. Evidence paths.
3. Metrics if available.
4. Rule-compliance findings.
5. Whether this stream can promote ns3_mom93 as the active speed substrate.
6. Commands run, files read, files touched, unresolved risks.

Stop conditions:
Do not launch, cancel, resubmit, mutate Flywheel/Linear, or choose a G9 branch.
```

## AirBench Dev10 Critic Prompt

```text
Objective:
Classify the collected AirBench dev10 train-dev stream as pass, fail, or inconclusive.

Relevant skill(s) to read:
- /Users/lucacerovaz/.codex/skills/critical-scientific-audit/SKILL.md

Context files to read:
- program.md
- orchestration/g9-frontier/post-collection-decision-gate.md
- orchestration/g9-frontier/collection-protocol.md
- orchestration/g9-frontier/recompute-protocol.md
- orchestration/airbench-transfer/runtime-dev10-20260704T003552Z/trace.md
- /Users/lucacerovaz/Documents/Cifar100 Speedrun-worktrees/airbench-transfer/orchestration/airbench-transfer/runtime-dev10-20260704T003552Z/trace.md
- <collection_dir>/collection_status.md
- <collection_dir>/remote_checks/sacct-48463507.txt
- <collection_dir>/remote_checks/output-manifest.txt
- <collection_dir>/remote_outputs/airbench_aug_pad2_alt_dev10_20260704T003552Z/paired_summary.json, if present
- <collection_dir>/verification/verification.json, if recompute was possible

Decision criteria:
- pass only if terminal completed train-dev 10-run evidence exists, raw artifacts
  are complete, recompute PASS exists, RECORD=0, VALIDATION_SOURCE=train_dev,
  C100_DEV_PER_CLASS=50, C100_DEV_SPLIT_SEED=20260703, no official validation is
  used, candidate-only diff is exactly C100_TRANSLATE_PAD=2 and
  C100_FLIP_MODE=alternating, mean train-dev accuracy is at least baseline mean,
  mean time ratio is <= 1.01, and no instability blocker appears.
- fail if terminal scheduler failure/cancelation exists, rule/provenance checks
  fail, raw metrics recompute fails, or the predeclared metric criterion fails.
- inconclusive if terminal evidence exists but artifacts/provenance are
  insufficient to support pass or fail.

Required output:
1. Classification: pass / fail / inconclusive.
2. Evidence paths.
3. Metrics if available.
4. Rule-compliance findings.
5. Whether this stream can be used as a train-dev reserve candidate.
6. Commands run, files read, files touched, unresolved risks.

Stop conditions:
Do not launch, cancel, resubmit, mutate Flywheel/Linear, or choose a G9 branch.
```

## Forbidden While SSH Is Still Blocked

- No launching, canceling, resubmitting, or replacing jobs `48463506` or
  `48463507`.
- No G9 additive, G8-C, 12-epoch, or AirBench front-end run.
- No official-validation search loop.
- No promotion, kill, finalist, record, Flywheel, or Linear claim based on
  uncollected pending jobs.

## Trace

Prepared after read-only orchestration review by `research-orchestrator`
`019f2b01-91a1-7f51-a543-8767aeece2a0`.

Files read by main before writing:

- `/Users/lucacerovaz/.codex/skills/scientific-automation-pipeline/SKILL.md`
- `/Users/lucacerovaz/projects/agent-config/codex/SLURM.md`
- `program.md`
- `orchestration/g9-frontier/post-collection-decision-gate.md`
- `orchestration/g9-frontier/trajectory-plan.md`
- `orchestration/g9-frontier/collection-protocol.md`
- `orchestration/g9-frontier/recompute-protocol.md`

Files touched:

- `orchestration/g9-frontier/post-auth-collection-handoff.md`
