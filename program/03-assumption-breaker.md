# Assumption Breaker

## Core Assumptions

| Assumption | Status | Risk | Fastest Falsifier |
| --- | --- | --- | --- |
| The current baseline clears 70% over 30 runs with `C100_COMPILE_MODE=default`. | Untested | The challenge target may be miscalibrated. | Current-default 30-run baseline. |
| One historical 16-epoch seed generalizes. | Weakly supported | A lucky seed can drive wrong budget decisions. | 30-run mean and lower confidence bound. |
| Official test validation can be used safely during search. | Contradicted | Repeated search overfits the public validation gate. | Switch search to train-derived dev split. |
| Timing differences are algorithmic. | Untested | Node/cache/order effects can dominate small speedups. | Same-pod paired AB/BA pilot. |
| HF and torchvision CIFAR-100 data are equivalent. | Untested | Dataset mismatch invalidates reproducibility. | Hash/count/equality check. |
| External CIFAR-10 venv is stable enough. | Weakly supported | Hidden dependency drift. | Record module list and freeze environment. |

## Brittle Reasoning To Avoid

- Treating a one-seed pass as a robust 70% baseline.
- Optimizing for the official test split during exploratory search.
- Calling compile/cache changes algorithmic wins.
- Comparing candidate and baseline across different nodes or allocations.
- Retrying only architecture variants while ignoring measurement controls.

## Alternatives That Could Make The Hypothesis False

- The baseline is already near the Pareto frontier for 70% under this architecture family.
- The apparent speed gains from smaller models are offset by higher epoch count or lower accuracy margin.
- Strong augmentations improve accuracy but cost too much in the timed loop.
- Muon hyperparameters are already tuned enough that schedule changes produce variance, not real gains.
- Most gains come from cache/compile treatment rather than training algorithm.

## Proposed Discriminating Tests

1. Baseline calibration:
   - Question: does current default clear 70% robustly?
   - Minimal intervention: run 30 baseline seeds unchanged.
   - Signal if true: mean `val_acc > 0.702` preferred and all artifacts complete.
   - Kill criterion: mean <= 0.700 or confidence interval crosses below target too strongly.
   - Cost: <1 GPU hour expected.

2. Paired timing pilot:
   - Question: are paired speed ratios stable under same allocation?
   - Minimal intervention: 10 seeds baseline/candidate no-op or tiny candidate, AB/BA order.
   - Signal if true: order-adjusted ratio stable.
   - Kill criterion: order/cache effect comparable to candidate effect.
   - Cost: <1 GPU hour.

3. Dev split search gate:
   - Question: can exploratory tuning avoid official-test overfitting?
   - Minimal intervention: fixed train-derived dev split with official train subset for training.
   - Signal if true: dev gains predict official final on pre-registered candidates.
   - Kill criterion: dev-selected candidates regress on official final.
   - Cost: small local implementation plus short GPU pilots.

4. Dataset equivalence:
   - Question: do HF and torchvision prep produce equivalent tensors and labels?
   - Minimal intervention: compare shapes, label counts, class ordering, and sample hashes.
   - Signal if true: identical or explainable differences.
   - Kill criterion: unexplained tensor/label mismatch.
   - Cost: CPU/read-only.

## Ranked Plan

1. Highest-leverage assumption to attack: baseline robustness.
2. Fastest disconfirming experiment: current-default 30-run baseline after environment/control fixes.
3. Most important control: train-derived dev validation for search plus paired same-pod final comparison.
4. Path not to retry yet: broad official-test hyperparameter search.
5. Ambiguity that changes next step: whether CINECA SIMP can write/read the current YENDRI staging path reliably.

