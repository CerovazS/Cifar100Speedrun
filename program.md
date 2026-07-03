# CIFAR-100 Speedrun Program

## Active Request

Win the CIFAR-100 A100 speedrun rooted at Flywheel node `R01 CIFAR-100 A100 Speedrun Challenge` (`83c2d2f5-2ac3-5ee5-85f1-2d5bb87ef299`) using `IscrC_SIMP` on CINECA Leonardo. The objective is to beat the current baseline under the repository contract: official CIFAR-100 train images only, frozen plain validation on the official test split, target `mean(val_acc) > 70%`, 30 official runs, single A100, timed training only, and same-pod paired comparison for record claims.

## Current Phase

G8-B Muon mechanics train-dev pilot completed. G1 controls, G2 interactive smoke, G3 official baseline, G4 paired no-op pilot, first G5 train-dev search, G5b train-dev search, and G7-T4 capacity screens are complete. G7-T2 one-cycle passed official evidence and is logged to Flywheel. G8-A `13ep-onecycle-longwarm` passed dev10 train-dev, completed official 30-run evidence, and is logged to Flywheel node `c184a66e-6cdd-4b6b-9c23-197b0b58dd47`. The G8-B evidence is exploratory only: `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `RUNS=3`, `C100_DEV_PER_CLASS=50`, `C100_DEV_SPLIT_SEED=20260703`, unique `RUN_ID`/`BASE_SEED`, no official validation, no validation path edits, no TTA/adaptation, and no output directory reuse. Flywheel mutation is explicitly out of scope for this pilot.

## Subagent Delegation Plan

- Main orchestrator: maintain global gates, reconcile subagent evidence, keep exploratory and official evidence labeled correctly, and launch only audited follow-up trajectories.
- `research-orchestrator` T1 Schedule compression: complete; kill recommendation after dev3 epoch/LR pilots.
- `research-orchestrator` T2 Muon mechanics: complete; kill recommendation after dev3 LR pilots.
- `research-orchestrator` T3 Architecture Pareto: complete; kill narrow/basewidth, keep `shallow122` only as a possible combined follow-up candidate.
- `scientific-critic` G5 Batch Reviewer: required before any next G5 expansion or finalist promotion.
- `research-orchestrator` G5b-T4 Shallow recovery: complete; KILL after paired train-dev dev3.
- `scientific-implementer` G5b-T5 Cheap regularization knobs/run: complete; KILL after cutout8 paired train-dev dev3.
- `experiment-architect` G5b-T6 Batch/schedule design/run: complete; KILL after paired train-dev dev3 batch-1536 pilot.
- `repo-cartographer` Validation Rule Audit: active; verify authoritative repo split/record semantics and stale program language.
- `experiment-architect` G7 Trajectory Planner: active; design credible accuracy-preserving speedup workstreams after failed simple-compression pilots.
- `research-orchestrator` CINECA State Audit: active; verify remote scratch checkout, official split availability, sync status, and safe launch handoffs without allocating GPU.
- `scientific-critic` G7 Plan Critic: conditional pass for G7-T4 train-dev dev3 after exact traces, remote sync, output-dir checks, and remote `bash -n`.
- `research-logger` G7 Official Logger: complete; Flywheel node `c4048ac9-9762-5a64-a87e-4c6360af75d2`.
- `research-orchestrator` G8-A One-Cycle Compression Frontier: official 30-run evidence complete, critic-approved, and logged to Flywheel node `c184a66e-6cdd-4b6b-9c23-197b0b58dd47`.
- Main orchestrator G8-B Muon Mechanics Train-Dev Pilot: complete; synced bounded mechanics knobs to Leonardo, ran three paired train-dev dev3 pilots, babysat jobs, pulled evidence, and made promote/hold/kill decision without Flywheel mutation.
- `scientific-critic` G8-B Pre-Launch/Result Auditor: active; read-only audit of launch constraints and final evidence.
- `repo-cartographer` G8-C Train-Only Data Path: complete; recommends low-magnitude train-only color jitter as cleanest next data-path candidate.
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
- [x] Post-G5b control hardening completed: paired wrapper now sanitizes baseline env, validates declared candidate diffs, and the remote G6 script path is quarantined.
- [x] Validation policy corrected after user review: official validation is required for pre-registered record evidence and must use official `train,test` split prep; exploratory search remains `train_dev`.
- [x] G7 trajectories selected for immediate launch: see `orchestration/g7-search/assignments.md` and `orchestration/g7-t4-capacity/*-trace.md`.
- [x] G7 critical audit completed for T4 train-dev dev3 only: conditional pass; no official/finalist launch is approved yet.
- [x] G7-T4 capacity objective completed: three train-dev paired candidates all killed; see `orchestration/g7-t4-capacity/result.md`.
- [x] G7-T2 schedule dev3/dev10 completed: one-cycle default promoted to official/finalist audit pending result critic; high-LR killed. See `orchestration/g7-t2-schedule/result.md`.
- [x] G7 official/finalist objective completed: pre-registration, official 30-run paired evidence, and independent result critic are complete. See `orchestration/g7-official-onecycle/result.md`.
- [x] Flywheel logging delegated and completed: official one-cycle finalist logged as Flywheel node `c4048ac9-9762-5a64-a87e-4c6360af75d2`.
- [x] G8 delegation plan written before launch: see `orchestration/g8-search/assignments.md`.
- [x] G8-A one-cycle compression dev3 completed and independently audited; promote `13ep-onecycle-longwarm` only.
- [x] G8-B Muon mechanics implementation/audit completed; commit/sync before any runtime pilot.
- [x] G8-C train-only data path feasibility completed; see `orchestration/g8-c-data-path/summary.md`.
- [x] G8-A `13ep-onecycle-longwarm` dev10 completed and audited.
- [x] G8 official `13ep-onecycle-longwarm` completed and audited.
- [x] G8-B train-dev pilot completed: initial runtime `orchestration/g8-b-muon/runtime-20260703T232332Z/` canceled because split identity was not explicitly pinned in launch env; restarted runtime `orchestration/g8-b-muon/runtime-20260703T233518Z/` completed with jobs `48457399`, `48457400`, `48458063`. Result: promote `g8b_ns3_mom93_longwarm_dev3` to dev10 train-dev only.
- [x] G8 official Flywheel logging delegated/completed: Flywheel node `c184a66e-6cdd-4b6b-9c23-197b0b58dd47`.

## Immediate Backlog

1. Run G8-B `ns3_mom93` dev10 train-dev follow-up only if prioritizing Muon mechanics after G8 official logging.
2. Convert G8-C data-path map into one train-only implementation plan, likely low-magnitude color jitter, after G8 official decision.
3. Keep exploratory follow-ups on `train_dev`; use official validation only for pre-registered finalist/record evidence.

## Active Assumptions And Ambiguities

- Challenge contract and Flywheel root require `IscrC_SIMP`; local `ssh leonardo` also resolves `$WORK=/leonardo_work/IscrC_SIMP`, `$FAST=/leonardo_scratch/fast/IscrC_SIMP`, and `$SCRATCH=/leonardo_scratch/large/userexternal/lcerovaz`.
- The prompt also mentioned YENDRI/PDR. Treat that as an ambiguity for storage/account only: do not launch PDR/YENDRI record jobs unless explicitly reconciled with the SIMP challenge contract.
- Operational repository path while `$WORK` is full is `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`; old PAERLE/YENDRI/absolute WORK launch paths must remain removed from active scripts.
- Incident `48410752`/`48410889`: an external old-path official-candidate script under `$WORK` attempted 30-run official candidate comparisons from a PAERLE/YENDRI checkout. Job `48410889` was canceled after 1m52s allocation and is not scientific evidence. See `orchestration/control-incidents/2026-07-03-official-candidate-cancel.md`.
- Incident `48412222`: an unreviewed G6 official-validation job was found pending from a remote untracked `orchestration/g6-official-retrain/` script and canceled before allocation. See `orchestration/control-incidents/2026-07-03-g6-official-cancel.md`.
- Incident `48412394`: the same unreviewed G6 official-validation script was retried, ran for `00:04:22`, touched official validation for seed `880000`, and was canceled. The cancellation reason was unreviewed launch surface/path governance, not a blanket ban on official validation. See `orchestration/control-incidents/2026-07-03-g6-official-retry-cancel.md`.
- Remote quarantine: `orchestration/g6-official-retrain/run_g6_official_preregistered.sh` was reversibly renamed to `run_g6_official_preregistered.sh.BLOCKED_BY_MAIN_20260703` on the scratch checkout so it cannot be resubmitted by the same unreviewed path.

## No-Run Gates

- No unlabeled GPU spend: every run must name claim, hypothesis, criterion, validation mode, run id, and output path before launch.
- No official-test search loops; use train-derived dev validation for exploratory selection, and use official validation only for pre-registered record/finalist workstreams.
- No validation path edits, no validation-time adaptation, no TTA, no ensembles, no timing-boundary changes for record claims.
- No output directory reuse; every run gets a unique run id.
- No Flywheel mutation until curated evidence, critic audit, reproducibility notes, and commit metadata exist.
