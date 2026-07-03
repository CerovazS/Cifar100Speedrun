# G6 Official Job Cancellation Incident

## Summary

On 2026-07-03, an unexpected official-validation job was found pending on Leonardo:

- job: `48412222`
- name: `c100-g6-official`
- state at discovery: `PENDING`
- command: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/orchestration/g6-official-retrain/run_g6_official_preregistered.sh`
- workdir: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`

The job was canceled before allocation:

```text
48412222|c100-g6-official|CANCELLED by 132794|0:0|00:00:00|
```

## Why It Was Invalid

The job attempted a G6 official-validation retrain before the active program gates allowed it:

- no current G5 or G5b candidate had passed dev3 and critic gates;
- `ep14_default` and `shallow122_ep16` were already negative or underpowered train-dev evidence, not finalists;
- no dev10 or paired train-dev promotion existed;
- no main-orchestrator pre-registration or result audit authorized official validation.

## Corrective Action

- Canceled `48412222` before GPU allocation.
- Do not use the remote untracked `orchestration/g6-official-retrain/` script as evidence or active launch surface.
- Future side chats/subagents must not launch official-validation or record-mode jobs unless `program.md` explicitly marks G6 unblocked and names the finalist.
