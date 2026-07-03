# CIFAR-100 Speedrun Program

## Active Request

Win the CIFAR-100 A100 speedrun rooted at Flywheel node `R01 CIFAR-100 A100 Speedrun Challenge` (`83c2d2f5-2ac3-5ee5-85f1-2d5bb87ef299`) using `IscrC_SIMP` on CINECA Leonardo. The objective is to beat the current baseline under the repository contract: official CIFAR-100 train images only, frozen plain validation on the official test split, target `mean(val_acc) > 70%`, 30 official runs, single A100, timed training only, and same-pod paired comparison for record claims.

## Current Phase

G5 train-dev trajectory search. G1 controls, G2 interactive smoke, G3 official baseline, and G4 paired no-op pilot are complete; official record attempts remain blocked until finalists are pre-registered, audited, and run with `RECORD=1` over exactly 30 paired official seeds.

## Subagent Delegation Plan

- `repo-cartographer` Mapper: completed read-only repo/control map.
- `scientific-critic` Reviewer: completed pre-spend audit; verdict blocked for GPU-hour spending until P0 controls are fixed.
- `paper-explorer` Reader: active AirBench / fast-CIFAR source sweep.
- `paper-explorer` PaperScout: active Muon / optimizer source sweep.
- `paper-explorer` Scholar: active augmentation / regularization source sweep.
- `experiment-architect` Planner: active trajectory design after P0 gates.
- Housekeeper: Codex cron automation `cifar100-speedrun-housekeeper-20m` is active every 20 minutes. It must not launch jobs or mutate Flywheel/Linear.

## Checklist

- [x] Subagent delegation plan written before launch: see this section and `orchestration/intake/agent-trace.jsonl`.
- [x] Claim, hypothesis, decision criterion, and metric/evidence recorded before launch: see `program/00-adversarial-framing.md`.
- [x] Planning artifacts complete for first gate: see `program/02-repo-control.md`, `program/03-assumption-breaker.md`, `program/04-execution-dag.md`, and `program/05-plan-audit.md`.
- [x] Critical audit completed: Reviewer returned blocked-for-spend verdict; P0 fixes were required before GPU search.
- [ ] Objective completed: G1-G4 gates pass; blocked until trajectory searches, finalists, official paired record evidence, and logging complete.
- [ ] Flywheel logging delegated: not yet; logging starts only after evidence exists. Destination is the `.env` root above.

## Immediate Backlog

1. Assign parallel train-dev trajectory orchestrators with disjoint write scopes.
2. Each trajectory must start with dev pilots only, use unique run ids, and return kill/expand evidence.
3. Audit each trajectory before combining or promoting a finalist.
4. Prepare logger handoff for G2-G4 while searches run.
5. Keep official validation reserved for pre-registered finalists only.

## Active Assumptions And Ambiguities

- Challenge contract and Flywheel root require `IscrC_SIMP`; local `ssh leonardo` also resolves `$WORK=/leonardo_work/IscrC_SIMP`, `$FAST=/leonardo_scratch/fast/IscrC_SIMP`, and `$SCRATCH=/leonardo_scratch/large/userexternal/lcerovaz`.
- The prompt also mentioned YENDRI/PDR. Treat that as an ambiguity for storage/account only: do not launch PDR/YENDRI record jobs unless explicitly reconciled with the SIMP challenge contract.
- Operational repository path while `$WORK` is full is `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`; old PAERLE/YENDRI/absolute WORK launch paths must remain removed from active scripts.

## No-Run Gates

- No record/search GPU spend before P0 controls in `program/05-plan-audit.md` are fixed or explicitly accepted.
- No official-test search loops; use train-derived dev validation for exploratory selection.
- No validation path edits, no validation-time adaptation, no TTA, no ensembles, no timing-boundary changes for record claims.
- No output directory reuse; every run gets a unique run id.
- No Flywheel mutation until curated evidence, critic audit, reproducibility notes, and commit metadata exist.
