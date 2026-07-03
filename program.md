# CIFAR-100 Speedrun Program

## Active Request

Win the CIFAR-100 A100 speedrun rooted at Flywheel node `R01 CIFAR-100 A100 Speedrun Challenge` (`83c2d2f5-2ac3-5ee5-85f1-2d5bb87ef299`) using `IscrC_SIMP` on CINECA Leonardo. The objective is to beat the current baseline under the repository contract: official CIFAR-100 train images only, frozen plain validation on the official test split, target `mean(val_acc) > 70%`, 30 official runs, single A100, timed training only, and same-pod paired comparison for record claims.

## Current Phase

G3 current-default official baseline. G1 controls and G2 interactive CINECA smoke are complete at commit `4a59bcf`; broad search and record attempts remain blocked until the 30-run baseline and paired pilot gates complete.

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
- [ ] Objective completed: G1 controls and G2 smoke pass; blocked until official baseline, paired pilot, trajectory searches, finalists, and logging complete.
- [ ] Flywheel logging delegated: not yet; logging starts only after evidence exists. Destination is the `.env` root above.

## Immediate Backlog

1. Run current-default 30-run official baseline from commit `4a59bcf`.
2. Audit baseline artifacts and decide whether the 70% target is robust enough.
3. Run same-allocation paired no-op or tiny-candidate pilot to validate AB/BA timing.
4. Assign parallel trajectory orchestrators only after G3-G4 controls pass.
5. Prepare Flywheel logger handoff after baseline evidence exists.

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
