# G5 Train-Dev Search Assignments

## Gate State

G5 train-dev search is unblocked after:

- G2 interactive smoke passed on Leonardo/SIMP.
- G3 official baseline passed: `mean(val_acc)=0.707603`, `30/30` hits, `mean(time)=25.77336s`.
- G4 paired no-op pilot passed: `train_dev`, `record_mode=false`, 4 paired seeds, mean ratio `1.001836`.

G6 official record attempts remain blocked until finalists are pre-registered, audited, and run with `RECORD=1`, official validation, and exactly 30 paired seeds.

## Active Orchestrators

| Track | Agent | Scope | First Gate |
| --- | --- | --- | --- |
| T1 Schedule compression | `019f286c-e3a5-73a1-9d23-0a48aee9c5ac` | env-only epoch/LR pilots on `train_dev` | dev3 over 10/12/14 epochs |
| T2 Muon mechanics | `019f286d-20f5-7b62-a219-3020d3f192cc` | env-only Muon/Bias LR pilots on `train_dev` | dev3 at 14 epochs |
| T3 Architecture Pareto | `019f286d-679d-7323-b380-fd50b05b5b60` | minimal architecture env knobs if needed; no validation/timing changes | code-gate then dev3 variants |

## Shared Constraints

- No official validation during G5.
- Unique run ids under `outputs/cifar100_speedrun/`.
- Submit from `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`.
- Use `IscrC_SIMP`.
- Each orchestrator must return job ids, commands, output dirs, metrics, kill/expand recommendation, and unresolved risks.
- Main orchestrator must run an independent critic before any finalist promotion.
