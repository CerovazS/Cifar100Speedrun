# Official-Candidate Job Cancellation Incident

## Summary

On 2026-07-03, an unexpected `c100-paired` SLURM job was found running on Leonardo:

- job `48410752`: failed after `00:00:03`
- job `48410889`: canceled by the main orchestrator after `00:01:52`

The running job used:

- command: `/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun_runs/scripts/run_paired_job.sh`
- output: `/leonardo_work/IscrC_SIMP/lcerovaz/Cifar100Speedrun_runs/slurm/c100-paired-48410889.out`
- hard-coded repo root: `/leonardo_work/IscrC_YENDRI/paerle/Cifar100Speedrun`
- run id: `c100_official_candidates_20260703T171501+0200`
- account: `IscrC_SIMP`
- partition/qos: `boost_usr_prod` / `boost_qos_lprod`

## Why It Was Invalid

The job violated the active program gates:

- it used an old PAERLE/YENDRI path instead of the active scratch checkout;
- it attempted 30-run official candidate comparisons without finalist preregistration or critic approval;
- it touched the official CIFAR-100 test artifact during a search phase;
- it was outside the active `slurm/paired_compare.sh` control surface and its `RECORD=1` gate.

The job was canceled before completing the first condition. It produced no accepted metrics and must not be used as scientific evidence.

## Evidence

Scheduler accounting:

```text
48410752|c100-paired|FAILED|2:0|00:00:03|billing=8,cpu=8,gres/gpu=1,mem=64G,node=1
48410889|c100-paired|CANCELLED by 132794|0:0|00:01:52|billing=8,cpu=8,gres/gpu=1,mem=64G,node=1
```

Observed stdout before cancellation:

```text
==> run_id=c100_official_candidates_20260703T171501+0200 job=48410889 node=lrdn0396.leonardo.local start=Fri Jul  3 17:15:51 CEST 2026
cifar100/train.pt: exists images=(50000, 32, 32, 3) labels=(50000,)
cifar100/test.pt: exists images=(10000, 32, 32, 3) labels=(10000,)
===== condition=epochs16_baseline epochs=16 runs=30 target=0.70 seed_base=880000 compile_mode=default =====
```

## Corrective Actions

- Canceled job `48410889`.
- Confirmed `squeue` is empty afterward.
- Recorded this incident in `program.md` so subsequent orchestration treats `$WORK` old-path scripts as forbidden.
- Next jobs must submit only from `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun` using repo-controlled SLURM wrappers.
