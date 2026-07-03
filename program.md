# CIFAR-100 Speedrun Program

## Active Request

Win the CIFAR-100 A100 speedrun rooted at Flywheel node `R01 CIFAR-100 A100 Speedrun Challenge` (`83c2d2f5-2ac3-5ee5-85f1-2d5bb87ef299`) using `IscrC_SIMP` on CINECA Leonardo. The objective is to beat the current baseline under the repository contract: official CIFAR-100 train images only, frozen plain validation on the official test split, target `mean(val_acc) > 70%`, 30 official runs, single A100, timed training only, and same-pod paired comparison for record claims.

## Current Phase

Post-G5b control hardening and redesign pause. G1 controls, G2 interactive smoke, G3 official baseline, G4 paired no-op pilot, first G5 train-dev search, and G5b train-dev search are complete. Official record attempts remain blocked until finalists are pre-registered, audited, and run with `RECORD=1` over exactly 30 paired official seeds.

## Subagent Delegation Plan

- Main orchestrator: maintain global gates, reconcile subagent evidence, prevent official-validation leakage, and launch only audited follow-up trajectories.
- `research-orchestrator` T1 Schedule compression: complete; kill recommendation after dev3 epoch/LR pilots.
- `research-orchestrator` T2 Muon mechanics: complete; kill recommendation after dev3 LR pilots.
- `research-orchestrator` T3 Architecture Pareto: complete; kill narrow/basewidth, keep `shallow122` only as a possible combined follow-up candidate.
- `scientific-critic` G5 Batch Reviewer: required before any next G5 expansion or finalist promotion.
- `research-orchestrator` G5b-T4 Shallow recovery: complete; KILL after paired train-dev dev3.
- `scientific-implementer` G5b-T5 Cheap regularization knobs/run: complete; KILL after cutout8 paired train-dev dev3.
- `experiment-architect` G5b-T6 Batch/schedule design/run: complete; KILL after paired train-dev dev3 batch-1536 pilot.
- Main orchestrator: harden paired wrapper and quarantine blocked G6 launch surface before any new GPU job.
- `paper-explorer` Reader: active AirBench / fast-CIFAR source sweep.
- `paper-explorer` PaperScout: active Muon / optimizer source sweep.
- `paper-explorer` Scholar: active augmentation / regularization source sweep.
- `experiment-architect` Planner: active trajectory design after P0 gates.
- Housekeeper: Codex cron automation `cifar100-speedrun-housekeeper-20m` is active every 20 minutes. It must not launch jobs or mutate Flywheel/Linear.

## Checklist

- [x] Subagent delegation plan written before launch: see `orchestration/g5-search/assignments.md`.
- [x] Claim, hypothesis, decision criterion, and metric/evidence recorded before launch: each G5 track has its own trace under `orchestration/g5-t*/`.
- [x] Planning artifacts complete for first gate: see `program/01-literature-plan.md`, `program/04-execution-dag.md`, and `program/05-plan-audit.md`.
- [x] Critical audit completed for G1-G4 and per-track G5 pilots: see `orchestration/g5-t1-schedule/summary.md`, `orchestration/g5-t2-muon/summary.md`, and `orchestration/g5-t3-arch/summary.md`.
- [x] Objective completed for first G5 batch: T1/T2 killed; T3 only leaves `shallow122` as a possible combined follow-up, not a finalist.
- [x] Independent G5 batch audit completed: see `orchestration/g5-batch-audit/summary.md`; verdict blocks dev10, paired train-dev, official validation, and record mode from current evidence.
- [x] Flywheel logging delegated or ruled out for the first G5 batch: ruled out for now because all first-batch pilots are negative screening evidence and no record/finalist claim exists.
- [x] G5b objective completed: T4 shallow recovery, T5 cutout8, and T6 batch-1536 all killed on train-dev evidence. No candidate is promotable.
- [x] Post-G5b control hardening completed: paired wrapper now sanitizes baseline env, validates declared candidate diffs, refuses train-dev pilots while official/record/G6 jobs are active, and the remote G6 script path is quarantined.

## Immediate Backlog

1. Design the next batch around a more substantive mechanism; current simple compression, scalar LR, shallow architecture, batch-size, and cutout8 paths are killed.
2. Before any new GPU launch, write a new trace with allowed config differences and train-dev-only gates.
3. Keep official validation blocked until a named finalist passes train-dev evidence and critic audit.
4. If a future train-dev candidate clears a predeclared dev3 gate, run dev10 only after a new critic pass, then paired train-dev before any official finalist nomination.
5. Keep official validation reserved for pre-registered finalists only.

## Active Assumptions And Ambiguities

- Challenge contract and Flywheel root require `IscrC_SIMP`; local `ssh leonardo` also resolves `$WORK=/leonardo_work/IscrC_SIMP`, `$FAST=/leonardo_scratch/fast/IscrC_SIMP`, and `$SCRATCH=/leonardo_scratch/large/userexternal/lcerovaz`.
- The prompt also mentioned YENDRI/PDR. Treat that as an ambiguity for storage/account only: do not launch PDR/YENDRI record jobs unless explicitly reconciled with the SIMP challenge contract.
- Operational repository path while `$WORK` is full is `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`; old PAERLE/YENDRI/absolute WORK launch paths must remain removed from active scripts.
- Incident `48410752`/`48410889`: an external old-path official-candidate script under `$WORK` attempted 30-run official candidate comparisons from a PAERLE/YENDRI checkout. Job `48410889` was canceled after 1m52s allocation and is not scientific evidence. See `orchestration/control-incidents/2026-07-03-official-candidate-cancel.md`.
- Incident `48412222`: an unexpected G6 official-validation job was found pending from a remote untracked `orchestration/g6-official-retrain/` script and canceled before allocation. See `orchestration/control-incidents/2026-07-03-g6-official-cancel.md`.
- Incident `48412394`: the same prohibited G6 official-validation script was retried, ran for `00:04:22`, touched official validation for seed `880000`, and was canceled. Partial official metrics are not accepted evidence. See `orchestration/control-incidents/2026-07-03-g6-official-retry-cancel.md`.
- Remote quarantine: `orchestration/g6-official-retrain/run_g6_official_preregistered.sh` was reversibly renamed to `run_g6_official_preregistered.sh.BLOCKED_BY_MAIN_20260703` on the scratch checkout so it cannot be resubmitted by the same path.

## No-Run Gates

- No record/search GPU spend before P0 controls in `program/05-plan-audit.md` are fixed or explicitly accepted.
- No official-test search loops; use train-derived dev validation for exploratory selection.
- No validation path edits, no validation-time adaptation, no TTA, no ensembles, no timing-boundary changes for record claims.
- No output directory reuse; every run gets a unique run id.
- No Flywheel mutation until curated evidence, critic audit, reproducibility notes, and commit metadata exist.
