# G9 Post-Auth Handoff Audit

## Verdict

PASS.

The independent `scientific-critic` reviewed the SSH diagnostic and post-auth
collection handoff and found no required changes before commit.

## Findings

No blocking findings.

The critic confirmed:

- the SSH authentication failure is recorded as an operational collection blocker,
  not scientific run evidence;
- no resubmission, cancellation, replacement, dependent launch, promotion, record
  claim, Flywheel mutation, or Linear mutation is allowed before terminal
  evidence and critic classification;
- recomputation is required only when raw paired artifacts exist;
- the G8-B official and AirBench dev10 critic prompts classify only
  `pass`/`fail`/`inconclusive` and do not choose a branch;
- exploratory follow-ups remain on `train_dev`;
- official validation remains reserved for a pre-registered finalist/record;
- future record/logging remains under Flywheel root
  `83c2d2f5-2ac3-5ee5-85f1-2d5bb87ef299`;
- no conflict was found with the CINECA/SLURM guidance.

## Claims Allowed

- Leonardo SSH authentication is currently an operational collection blocker,
  not evidence of run success or failure.
- After authentication returns, collection must occur before resubmission,
  cancellation, dependent launch, promotion, record claim, or logging.
- Recomputed metrics and critic classifications are required before routing.

## Claims Not Allowed

- Neither pending job may be called passed, failed scientifically, promotable,
  record-supporting, or loggable as empirical evidence until terminal evidence,
  artifacts where available, recomputation where possible, and critic
  classification exist.

## Trace

Critic agent: `019f2b05-8b18-72d3-a789-153960816f89`.

Commands run by critic:

- `sed`
- `nl -ba`
- `rg`

Files read by critic:

- `/Users/lucacerovaz/.codex/skills/critical-scientific-audit/SKILL.md`
- `/Users/lucacerovaz/projects/agent-config/codex/SLURM.md`
- `program.md`
- `orchestration/g9-frontier/ssh-auth-diagnostic-20260704.md`
- `orchestration/g9-frontier/post-auth-collection-handoff.md`
- `orchestration/g9-frontier/post-collection-decision-gate.md`
- `orchestration/g9-frontier/collection-protocol.md`
- `orchestration/g9-frontier/recompute-protocol.md`
- `orchestration/g9-frontier/collect_pending_jobs.sh`
- `orchestration/g9-frontier/recompute_paired_metrics.py`

Files touched by critic: none.

Remote commands: none.

Unresolved risk: terminal `sacct`, remote artifacts, scheduler logs, and
recomputed metrics remain unavailable until SSH authentication is restored.
