# G5-T1 Logger Handoff

## Objective

G5-T1 tested CIFAR-100 train-dev schedule compression for the A100 speedrun, using epoch budgets `10`, `12`, and `14`, then a bounded epoch-14 Muon LR sweep.

## Claim And Decision

Claim tested: shorter schedules might retain enough train-dev accuracy to justify schedule compression before any official-validation finalist.

Decision: kill this trajectory. Epoch 14 default LR reached train-dev mean `0.697133` with `1/3` hits; the LR sweep did not improve over default and all LR variants had `0/3` hits. This is not official validation and not record evidence.

## Runs

- Job `48407198`: default LR discovery, `COMPLETED`, exit `0:0`, elapsed `00:04:26`, one A100.
- Job `48409232`: G5-T1 LR sweep, `COMPLETED`, exit `0:0`, elapsed `00:06:48`, one A100.
- Total counted allocation: `00:11:14`, about `0.187` A100-hours.

## Output Directories

- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5t1_20260703_164215_dev3_default_epochs10`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5t1_20260703_164215_dev3_default_epochs12`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5t1_20260703_164215_dev3_default_epochs14`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5t1_20260703_164215_dev3_ep14_muonlr0030_epochs14`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5t1_20260703_164215_dev3_ep14_muonlr0040_epochs14`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5t1_20260703_164215_dev3_ep14_muonlr0045_epochs14`

## Local Audit Artifacts

- `orchestration/g5-t1-schedule/results.csv`
- `orchestration/g5-t1-schedule/results.json`
- `orchestration/g5-t1-schedule/g5t1_schedule_lr_summary.svg`
- `orchestration/g5-t1-schedule/remote-artifacts/`
- `orchestration/g5-t1-schedule/agent-trace.jsonl`

## Caveats

- All validation is train-derived `train_dev`; official validation was not used.
- Runs are dev3 pilot filters only, not robust finalist or record evidence.
- Remote execution checkout was `eb4f1a5`; local `c82ba2d` only adds documentation/trace artifacts and does not change trainer, SLURM wrappers, environment, or dependency files relative to `eb4f1a5`.
- A failed attempt to submit three separate LR jobs hit `QOSMaxSubmitJobPerUserLimit`; it produced no counted G5-T1 output directories.
