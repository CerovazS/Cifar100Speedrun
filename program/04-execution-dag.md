# Execution DAG

## Critical Path

### G0: Housekeeping Substrate

- Objective: create local planning and trace files.
- Inputs: user request, repo docs, skills, CINECA rules.
- Outputs: `program.md`, `program/*.md`, `orchestration/intake/*`.
- Owner: main orchestrator.
- Verification: files exist and checklist is current.
- Status: complete for planning.

### G1: Control Patch

- Objective: fix known script bugs and artifact gaps without changing benchmark semantics.
- Dependencies: G0.
- Write scope: `train_cifar100_resnet_muon.py`, SLURM wrappers, analyzer/artifact helpers, docs.
- Verification: `bash -n`, `python3` AST parse, local no-CUDA import-safe checks where possible.
- Logging gate: trace patch and tests in `orchestration/implementation/`.

### G2: CINECA Interactive Validation

- Objective: verify remote path, account, modules, imports, data prep, and one tiny GPU run.
- Dependencies: G1.
- Resource: one interactive `srun` session, 1 A100, <=20 min.
- Verification: captured stdout/stderr and metadata under a unique `outputs/control/<run_id>/`.
- Stop condition: any missing dependency/path/GPU/account mismatch.

### G3: Current-Default Official Baseline

- Objective: establish baseline mean accuracy/time for current defaults.
- Dependencies: G2.
- Claim: the current default baseline clears 70% over 30 runs.
- Hypothesis: 16 epochs with default compile clears `mean(val_acc)>0.70`.
- Decision criterion: mean `val_acc>0.70`; prefer margin >=0.002; complete metrics and metadata.
- Resource: 1 A100, expected <1 GPU hour.
- Verification: analyzer success, metrics CSV/JSON, logs, commit metadata.

### G4: Dev Split And Paired Runner

- Objective: enable safe search and record-grade paired comparison.
- Dependencies: G1-G3.
- Write scope: new search/dev-split mode and paired runner; validation function semantics unchanged for official mode.
- Verification: unit/static checks, one tiny dev run, one tiny paired no-op run.
- Stop condition: any official validation path mutation or unclear split boundary.

### G5: Parallel Research Trajectory Pilots

- Objective: run small dev-split pilots in isolated branches/worktrees after controls pass.
- Dependencies: G4 and literature/trajectory outputs.
- Parallel tracks:
  - T1 architecture capacity/speed: widths, blocks, stem/head, downsampling.
  - T2 epoch/batch/LR schedule: total steps, cosine variants, warmup, batch size.
  - T3 optimizer: Muon LR, momentum, Newton-Schulz steps, grouping, SGD/bias settings.
  - T4 timed augmentations/regularization: label smoothing, cutout/mixup-like variants only if cheap.
  - T5 compile-neutral kernel/code cleanup: only if semantics and warmup/cache policy remain fixed.
- Resource: start with <=5 seeds per candidate on dev split; expand only if promising.
- Verification: per-run metrics, plots, summaries, kill criteria.

### G6: Final Candidate Official Runs

- Objective: pre-register 1-3 finalists and run official 30-run candidates plus paired baseline.
- Dependencies: G5 result audit.
- Decision criterion: official `mean(val_acc)>0.70` and paired time ratio <1 with stable order control.
- Resource: expected <10 GPU hours for finalists; reserve rest only for rechecks.
- Logging gate: result audit then `research-logger` with `$flywheel-log`.

## Parallelization Strategy

- Use separate worktrees for code-changing trajectory owners.
- Use unique run ids: `YYYYMMDD-HHMMSS_<track>_<variant>_<seedspan>`.
- Keep official-test evaluation touches scarce and pre-registered.
- Orchestrators may launch concurrent SLURM jobs only after G1-G4 pass and each run has a registered claim, hypothesis, criterion, and output directory.

## Blocked Tasks

- Interactive sessions and SLURM jobs are blocked until G1 control patch and remote validation.
- Flywheel logging is blocked until evidence exists and result audit passes.

