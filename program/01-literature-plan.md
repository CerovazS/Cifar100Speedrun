# Literature Plan: Fast CIFAR-100 Speedrun Directions

## Scope

Bounded source sweep for ideas likely to reduce timed training seconds to `mean(val_acc) > 70%` on CIFAR-100 under the challenge contract. All ideas must train only on official train images, use train-derived dev validation for search, and avoid validation-time adaptation, TTA, ensembling, or official-test tuning.

## Ranked Ideas

| Rank | Idea | Evidence Basis | Test Under Contract |
| --- | --- | --- | --- |
| 1 | AirBench train-only transplant: train-derived patch whitening, Dirac/identity init, compact body, BN/LR tuning | AirBench paper and `KellerJordan/cifar10-airbench`; CIFAR-100 transfer is suggestive but not under this exact validation contract | Composite dev5 vs current baseline, then ablate whitening/init/body only if composite wins |
| 2 | 1cycle / triangular LR schedule | Super-Convergence, Page fast CIFAR/DAWNBench recipes | Dev pilots over 8/10/12/14/16 epochs, then dev10 paired vs baseline |
| 3 | Muon update mechanics | Muon writeup plus AirBench/Hiverge code patterns | Sweep Muon LR, momentum, weight decay, Newton-Schulz steps, and parameter grouping at compressed epoch budgets |
| 4 | Small cutout / cheap train-time regularization | Cutout evidence; CIFAR-100 likely favors smaller masks than CIFAR-10 | Dev3 over mask sizes 0/8/16 and label smoothing interactions; expand only if time cost is small |
| 5 | Architecture capacity Pareto search | Wide ResNet and fast CIFAR practice: shallow/wide can be efficient | Width/block grid around `(64,128,256)x(2,2,2)`, lighter variants, and AirBench-like `(64,256,256)` |
| 6 | Batch-size and step-count tradeoff | DAWNBench/Page recipes use 512-1024; A100 may shift the optimum | Batch 512/768/1024/1536 with LR scaling on train-dev only |
| 7 | Label smoothing / mixup margin tools | Mixup and Bag-of-Tricks improve CIFAR-100 accuracy but can need longer training | Use only when finalists are close to 70 and need margin; stop if time-to-target worsens |
| 8 | Cheap GPU-side color jitter | Hiverge CIFAR-10 speedrun reports brightness/contrast gains | Low-priority dev pilot after higher-leverage tracks |

## Reject Or Defer

- Validation-time augmentation, TTA, selective TTA, confidence-triggered evaluation, ensembling, or validation-time adaptation: rule violations.
- Official-test-tuned selection: rule violation; use `C100_VALIDATION_SOURCE=train_dev`.
- Pure compile/kernel/vectorization changes as record claims: infrastructure, not algorithmic training wins, unless tied to a semantic training-loop change.
- Heavy AutoAugment/RandAugment policy search: likely too expensive and dev-overfit-prone for a 70% timed target.
- Data filtering based on model confidence: high leakage/complexity risk unless entirely train-only and pre-registered.

## Implications For Trajectories

- Prioritize T1 schedule compression and T3 AirBench/architecture transfer once controls pass.
- Keep Muon mechanics as a parallel track because it can combine with schedule compression.
- Treat regularization as a margin-rescue track, not the first time-reduction bet.
- Any official finalist must be pre-registered after train-dev evidence and audited before official-test evaluation.

## Trace

PaperScout read local context and performed bounded web/source lookup over AirBench, Super-Convergence, Page fast CIFAR/DAWNBench, Muon, Hiverge, Wide ResNet, Cutout, mixup, and Bag of Tricks. No files were changed by the literature subagent.
