# CIFAR-100 Speedrun Program

## Active Request

Win the CIFAR-100 A100 speedrun rooted at Flywheel node `R01 CIFAR-100 A100 Speedrun Challenge` (`83c2d2f5-2ac3-5ee5-85f1-2d5bb87ef299`) using `IscrC_SIMP` on CINECA Leonardo. The objective is to beat the current baseline under the repository contract: official CIFAR-100 train images only, frozen plain validation on the official test split, target `mean(val_acc) > 70%`, 30 official runs, single A100, timed training only, and same-pod paired comparison for record claims.

## Current Phase

G8-B `ns3_mom93` official clean-checkout comparison and AirBench dev10 confirmation are blocked during collection, not canceled. The official G8-B paired 30-run comparison was pre-registered and launched from a clean Leonardo checkout at commit `4ba08a7b3fea1652411a3adcabddc33fb2821ffe`: `RECORD=1`, `VALIDATION_SOURCE=official`, `RUNS=30`, `EPOCHS=13`, `BASE_SEED=894000`, unique `RUN_ID=g8b_ns3_mom93_official_20260704T003556Z`, no validation path edits, no TTA/adaptation, no dirty execution checkout, and no output directory reuse. Job `48463506` was observed running on `lrdn0042`, but final state and artifacts are unavailable until Leonardo SSH authentication is restored.

AirBench dev10 job `48463507` was also submitted from the isolated `airbench-transfer` worktree with `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `RUNS=10`, and unique `RUN_ID=airbench_aug_pad2_alt_dev10_20260704T003552Z`; it was observed running on `lrdn1864` and is likewise uncollected due SSH authentication failure. No resubmission is allowed before `sacct` proves the original job failed or was canceled.

Validation-compliance audit is complete in `orchestration/validation-compliance/current-audit.md`: accepted record/finalist evidence uses official validation, train-dev is used only for exploratory search, and prior cancellations were governance/rule-compliance interventions rather than interruptions of compliant independent workstreams. G9 frontier planning is complete in `orchestration/g9-frontier/trajectory-plan.md`; the immediate queue is collect `48463506`, collect `48463507`, then test additive combinations only if the collected evidence and critics justify them.

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
- Main orchestrator G8-B `ns3_mom93` Dev10 Follow-up: active; sync committed launch files, run remote preflight, submit one paired train-dev dev10 job, babysit to completion/failure, mirror artifacts under `orchestration/g8-b-muon/runtime-dev10-20260704T000009Z/`, recompute metrics, and recommend promote/hold/kill.
- `scientific-critic` G8-B Pre-Launch/Result Auditor: active; read-only audit of launch constraints and final evidence.
- Main orchestrator G8-B `ns3_mom93` Official Clean Checkout: blocked during collection; preflight and single official submission completed from clean checkout, but terminal state/artifacts cannot be collected until Leonardo SSH authentication is restored.
- `scientific-critic` G8-B Official Result Auditor: pending; independently audit final configs, metrics, and claim strength after artifact collection.
- `repo-cartographer` G8-C Train-Only Data Path: complete; recommends low-magnitude train-only color jitter as cleanest next data-path candidate.
- `repo-cartographer` Validation Compliance Current Audit: complete; see `orchestration/validation-compliance/current-audit.md`.
- `experiment-architect` G9 Frontier Planner: complete; see `orchestration/g9-frontier/trajectory-plan.md`.
- `research-orchestrator` G8-C Data-Path Worktree: complete local default-off color-jitter implementation on `/Users/lucacerovaz/Documents/Cifar100 Speedrun-worktrees/data-path`, commit `b9a8e1a1819e865ae065e7a9b6fea353add78e00`; no CINECA job launched.
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
- [x] G8-B `ns3_mom93` dev10 objective completed: claim is that `C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93` preserves train-dev accuracy while reducing timed training versus the 13-epoch one-cycle longwarm baseline. Evidence path: `orchestration/g8-b-muon/runtime-dev10-20260704T000009Z/`. Output path: remote `outputs/cifar100_speedrun/g8b_ns3_mom93_longwarm_dev10_20260704T000009Z/`. Job `48460378` completed `0:0`; recomputation found candidate mean accuracy `0.709700` vs baseline `0.704320`, mean time ratio `0.931954`, and independent critic PASS. Recommendation: promote for train-dev follow-up only.
- [x] G8-B dev10 Flywheel logging delegated or ruled out: ruled out for this execution request because user explicitly said executor/orchestrator only and no Flywheel/Linear mutation.
- [ ] G8-B `ns3_mom93` official clean-checkout objective completed: job `48463506` launched from a clean checkout but is blocked during collection because Leonardo SSH authentication failed. Evidence path: `orchestration/g8-b-muon/runtime-official-20260704T003556Z/`. Remote output path: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun-g8b-official-clean/outputs/cifar100_speedrun/g8b_ns3_mom93_official_20260704T003556Z/`. Required next evidence: terminal `sacct`, `paired_summary.json`, raw configs/metrics, clean git metadata, recomputed paired metrics, and independent result critic.
- [ ] AirBench dev10 objective completed: job `48463507` launched from the isolated AirBench worktree but is blocked during collection because Leonardo SSH authentication failed. Required next evidence: terminal `sacct`, paired artifacts, raw configs/metrics, provenance/diff-hash verification, recomputed train-dev metrics, and independent result critic.
- [x] Validation-compliance audit completed: see `orchestration/validation-compliance/current-audit.md`.
- [x] G9 trajectory plan completed: see `orchestration/g9-frontier/trajectory-plan.md`.
- [x] G8-C data-path local implementation completed: see worktree `/Users/lucacerovaz/Documents/Cifar100 Speedrun-worktrees/data-path`, commit `b9a8e1a1819e865ae065e7a9b6fea353add78e00`; run remains blocked behind collection gates.

## Immediate Backlog

1. Restore Leonardo SSH authentication, check `sacct -j 48463506,48463507`, and pull each job's artifacts exactly once. Do not resubmit either run before verifying the original job failed/canceled.
2. Recompute G8-B official metrics from raw official artifacts, verify `RECORD=1`, `VALIDATION_SOURCE=official`, official train/test split shapes, exact config diffs, and delegate independent result critic.
3. Recompute AirBench dev10 metrics from raw train-dev artifacts, verify `RECORD=0`, `VALIDATION_SOURCE=train_dev`, fixed dev split, exact pad/flip config diffs, provenance hash, and delegate independent result critic.
4. If G8-B official and AirBench dev10 both pass, launch one train-dev dev3 additive candidate only after a new predeclared trace: `ns3_mom93 + C100_TRANSLATE_PAD=2 C100_FLIP_MODE=alternating`. If one fails, follow the branch logic in `orchestration/g9-frontier/trajectory-plan.md`.
5. Keep G8-C color jitter as the next fallback accuracy-reserve train-dev screen; do not run it before the collection gates above.
6. Keep exploratory follow-ups on `train_dev`; use official validation only for pre-registered finalist/record evidence.

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
