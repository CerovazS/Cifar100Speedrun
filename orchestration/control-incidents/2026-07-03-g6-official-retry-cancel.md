# G6 Official Retry Cancellation Incident

## Summary

On 2026-07-03, the blocked G6 official-validation script was retried as job `48412394`:

- job name: `c100-user-official`
- command: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/orchestration/g6-official-retrain/run_g6_official_preregistered.sh`
- run id: `g6_official_preregistered_retry_20260703_1740_d765cc7`
- state after intervention: `CANCELLED by 132794`
- elapsed allocation: `00:04:22`

## Why It Was Invalid

The job used official validation before the active program gates allowed G6:

- no G5b candidate had passed dev3 gates;
- no dev10 or paired train-dev promotion existed;
- no main-orchestrator official finalist approval existed;
- the script evaluated candidates already killed or underpowered in train-dev.

The job touched the official CIFAR-100 test artifact and completed partial official metrics for seed `880000` before cancellation:

- baseline 16 epochs: official `val_acc=0.7047`
- default 14 epochs: official `val_acc=0.6989`
- `shallow122_ep16`: started but was canceled before a metric row completed

These partial metrics are not accepted evidence and must not be used for selection, promotion, record claims, or logging.

## Corrective Action

- Canceled job `48412394`.
- Confirmed this was a retry of the same prohibited `orchestration/g6-official-retrain/` launch surface documented in `2026-07-03-g6-official-cancel.md`.
- Reversibly quarantined the remote scratch-checkout script by renaming `orchestration/g6-official-retrain/run_g6_official_preregistered.sh` to `run_g6_official_preregistered.sh.BLOCKED_BY_MAIN_20260703`.
- Future official-validation jobs remain blocked until `program.md` explicitly names a finalist and G6 is unblocked after train-dev evidence plus critic audit.

## Accounting

```text
48412394|c100-user-official|CANCELLED by 132794|0:0|00:04:22|billing=8,cpu=8,gres/gpu=1,mem=64G,node=1
```
