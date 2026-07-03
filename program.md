# CIFAR-100 Speedrun Program

## Active Request

Win the CIFAR-100 A100 speedrun rooted at Flywheel node `R01 CIFAR-100 A100 Speedrun Challenge` (`83c2d2f5-2ac3-5ee5-85f1-2d5bb87ef299`) using `IscrC_SIMP` on CINECA Leonardo. The objective is to beat the current baseline under the repository contract: official CIFAR-100 train images only, frozen plain validation on the official test split, target `mean(val_acc) > 70%`, 30 official runs, single A100, timed training only, and same-pod paired comparison for record claims.

## Current Phase

G1 control patch verification and G2 CINECA interactive validation. Static local checks pass, and the main remaining pre-spend gates are subagent audit reconciliation, remote environment setup, one interactive GPU smoke, and the current-default 30-run baseline.

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
- [ ] Objective completed: static G1 checks pass; blocked until subagent audits, interactive smoke, official baseline, paired pilot, and finalist searches complete.
- [ ] Flywheel logging delegated: not yet; logging starts only after evidence exists. Destination is the `.env` root above.

## Immediate Backlog

1. Reconcile current subagent audits against the non-committed G1 patch.
2. Validate CINECA environment interactively before `sbatch`.
3. Run current-default 30-run official baseline if interactive smoke passes.
4. Run same-allocation paired no-op or tiny-candidate pilot to validate AB/BA timing.
5. Assign parallel trajectory orchestrators only after G2-G4 controls pass.

## Active Assumptions And Ambiguities

- Challenge contract and Flywheel root require `IscrC_SIMP`; local `ssh leonardo` also resolves `$WORK=/leonardo_work/IscrC_SIMP` and `$FAST=/leonardo_scratch/fast/IscrC_SIMP`.
- The prompt also mentioned YENDRI/PDR. Treat that as an ambiguity for storage/account only: do not launch PDR/YENDRI record jobs unless explicitly reconciled with the SIMP challenge contract.
- Repository path for this user is `/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun`; old PAERLE/YENDRI launch paths must remain removed from active scripts.

## No-Run Gates

- No record/search GPU spend before P0 controls in `program/05-plan-audit.md` are fixed or explicitly accepted.
- No official-test search loops; use train-derived dev validation for exploratory selection.
- No validation path edits, no validation-time adaptation, no TTA, no ensembles, no timing-boundary changes for record claims.
- No output directory reuse; every run gets a unique run id.
- No Flywheel mutation until curated evidence, critic audit, reproducibility notes, and commit metadata exist.
