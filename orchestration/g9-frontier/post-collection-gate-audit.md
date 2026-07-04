# G9 Post-Collection Gate Audit

## Verdict

PASS.

The independent `scientific-critic` reviewed
`orchestration/g9-frontier/post-collection-decision-gate.md` after the requested
fixes and found no remaining blocker.

## Critic Summary

The initial review gave a conditional pass because the draft:

- conflated terminal collection with result pass/fail status;
- left Branches B/C/D too open for a deterministic router;
- underspecified Branch C launch metadata and seed-stability checks;
- inherited CINECA launch constraints instead of making them visible in the gate;
- used overly strong timing wording for a `<= 1.03` threshold.

The draft was revised to:

- classify each stream as exactly one of `pass`, `fail`, or `inconclusive`;
- require terminal `sacct`, logs, manifests, and critic classification for failed
  or canceled scheduler-level evidence;
- require metric recomputation only when raw paired artifacts exist;
- define deterministic priority rules for Branches B/C/D;
- add Branch C template metadata and a minimum accuracy guard;
- inline the relevant `IscrC_SIMP`, `boost_usr_prod`, scratch-root, no-`$WORK`,
  static-check, absent-output, and duplicate-job preflights;
- downgrade AirBench to a train-dev reserve candidate and replace broad timing
  wording with the predeclared time-ratio threshold.

Final critic check:

```text
Verdict: pass
Prior remaining blocker: resolved.
New blocker: none.
```

## Claims Allowed

- The gate is a deterministic router after both pending jobs have terminal
  evidence and critic classification.
- Only `pass` can promote a stream; `fail` and `inconclusive` block dependent
  promotion.
- Follow-up selection remains exploratory on `train_dev`.
- Official validation is reserved for a later pre-registered finalist/record.
- Failed official `ns3_mom93` knobs cannot be reused in Branch C without a new
  plan and critic approval.
- Future official record/logging remains under Flywheel root
  `83c2d2f5-2ac3-5ee5-85f1-2d5bb87ef299`.

## Trace

Critic agent: `019f2afc-0768-75f1-b4a4-d14818acac35`.

Files read by critic:

- `/Users/lucacerovaz/.codex/skills/critical-scientific-audit/SKILL.md`
- `/Users/lucacerovaz/projects/agent-config/codex/SLURM.md`
- `program.md`
- `orchestration/g9-frontier/post-collection-decision-gate.md`
- `orchestration/g9-frontier/trajectory-plan.md`
- `orchestration/validation-compliance/current-audit.md`
- `orchestration/g9-frontier/collection-protocol.md`
- `orchestration/g9-frontier/recompute-protocol.md`

Files touched by critic: none.

Remote commands: none.
