# G8-B ns3_mom93 Official Clean-Checkout Trace

## Active Objective And Success Criteria

Pre-register, launch, babysit, and collect the G8-B `ns3_mom93` official 30-run paired comparison from a real clean Leonardo Git checkout, without mutating Flywheel or Linear.

Success requires:

- Remote clean checkout path: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun-g8b-official-clean`.
- Commit: `4ba08a7b3fea1652411a3adcabddc33fb2821ffe`.
- Run id: `g8b_ns3_mom93_official_20260704T003556Z`.
- Output root absent before launch and never reused.
- Preflight passes: `bash -n slurm/paired_compare.sh`, `python3 -m py_compile cifar100-benchmark/train_cifar100_resnet_muon.py`, official split tensors exist with train `50000` and test `10000`, wrapper supports `BASELINE_ENV`, `CANDIDATE_ENV`, and G8-B knobs.
- Launch uses `sbatch --qos=boost_qos_lprod --time=01:30:00` with `RECORD=1`, `VALIDATION_SOURCE=official`, `RUNS=30`, `EPOCHS=13`, `BASE_SEED=894000`.
- Pull `paired_summary.json`, `paired_order.csv`, stdout/stderr, sacct, and raw per-run config/summary/metrics/warmup/repro metadata/git_diff.patch if any.
- Recompute metrics from raw artifacts and verify official config semantics.

## Pre-Registered Claim

Claim: `13ep-onecycle-longwarm + C100_NS_STEPS=3 + C100_MUON_MOMENTUM=0.93` preserves official CIFAR-100 validation accuracy while reducing timed training versus the 13-epoch one-cycle longwarm baseline, under official `RECORD=1`, `VALIDATION_SOURCE=official`, `RUNS=30`, same-pod paired seeds, no TTA/adaptation.

Hypothesis: reducing Newton-Schulz steps from the default `5` to `3` and Muon momentum from `0.95` to `0.93` lowers per-step optimizer cost enough to reduce paired timed training while retaining the accuracy margin established by the longwarm one-cycle baseline.

Decision criterion: candidate passes if official paired evidence over 30 same-pod seeds shows candidate mean official validation accuracy at least baseline mean minus `0.002`, candidate mean official validation accuracy remains above `0.700`, and candidate mean time ratio is below `0.95`. If accuracy falls below either threshold or official config/reproducibility gates fail, do not promote.

Metric/evidence: `paired_summary.json` plus recomputed raw `metrics.csv` per seed, per-run configs, official train/test sizes, record metadata, and scheduler/accounting logs.

## Launch Configuration

Baseline env:

```text
C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0
```

Candidate env:

```text
C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93
```

Wrapper env:

```text
RECORD=1 VALIDATION_SOURCE=official RUNS=30 EPOCHS=13 BASE_SEED=894000 RUN_ID=g8b_ns3_mom93_official_20260704T003556Z
```

SBATCH override:

```text
sbatch --qos=boost_qos_lprod --time=01:30:00 slurm/paired_compare.sh
```

## Delegation Plan

- Main orchestrator: create clean remote checkout, run preflight, submit one official batch job, babysit to terminal state, mirror artifacts, recompute metrics, reconcile status.
- Scientific critic: read-only pre-launch and result audit using `critical-scientific-audit`; must report issues, allowed/downgraded claims, reruns/checks, and unresolved risks. No Flywheel or Linear mutation.
- Housekeeper: existing 20-minute housekeeping automation remains the local organization guard; no experiment launch or logging authority.

## Execution DAG

1. `D0-register`: write this trace and update `program.md`; output `trace.md`; owner main; gate is claim/hypothesis/criterion visible before launch.
2. `D1-clean-checkout`: bundle local commit, copy to Leonardo, clone/fetch into the clean path, checkout commit; output remote clean-status transcript; owner main; gate is `git rev-parse HEAD` exact match and clean `git status --short` except documented ignored/copied data.
3. `D2-data-preflight`: copy prepared CIFAR files from existing remote data checkout if missing, verify train/test tensor shapes; output `remote-preflight.txt`; owner main; gate is train `50000`, test `10000`.
4. `D3-code-preflight`: run syntax/compile checks and wrapper env support check; output `remote-preflight.txt`; owner main; gate is all checks pass.
5. `D4-submit`: submit exactly one official paired job with explicit `sbatch --qos=boost_qos_lprod --time=01:30:00`; output `submit.txt`; owner main; gate is job id recorded.
6. `D5-babysit`: poll `squeue/sacct` until terminal state; output `job-watch.txt` and `sacct-<job>.txt`; owner main; gate is terminal scheduler state.
7. `D6-collect`: mirror required raw artifacts to local runtime directory; owner main; gate is raw artifacts present or failure logs captured.
8. `D7-verify`: recompute metrics and config gates from raw artifacts; output `verification.json` and `metrics-table.tsv`; owner main; gate is no mismatch between raw artifacts and summary.
9. `D8-critic`: independent read-only result critic; output `critic.md`; owner scientific critic; gate is claim strength and residual risks clear.

## Trace Log

- `20260704T003556Z`: Local run id allocated and pre-registration trace created before remote launch.
- `20260704T003853Z`: Remote preflight passed from clean checkout: exact commit `4ba08a7b3fea1652411a3adcabddc33fb2821ffe`, clean source status, ignored copied CIFAR tensors only, output root absent, `bash -n` pass, `py_compile` pass, official split shapes train `50000` and test `10000`.
- `20260704T0040xxZ`: Submitted Slurm job `48463506` with the exact command captured in `submit.txt`.
- `20260704T004004Z`: Babysit loop observed job `48463506` running on `lrdn0042`; early stdout confirmed official train/test tensors and seed `894000` baseline start; stderr empty.
- `20260704T0043xxZ`: SSH babysit connection dropped with `Operation timed out`; subsequent reconnect attempts to `leonardo`, `leonardo01`, and `leonardo02` were rejected by the gateway (`Permission denied`) while offering the configured local key. No resubmission or remote mutation performed.
- `20260704T013853Z`: Longer reconnect backoff still failed with `Permission denied (publickey,gssapi-keyex,gssapi-with-mic)`. Job `48463506` terminal state and artifacts remain uncollected because remote authentication is blocked.
