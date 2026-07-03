# Adversarial Framing: CIFAR-100 A100 Speedrun

## Objective

Find algorithmic training-loop changes that reduce mean timed training seconds while still clearing `mean(val_acc) > 70%` over 30 official runs on a single Leonardo A100. A record claim also requires paired same-pod comparison against the baseline or last record using the same seed list.

## Primary Claim

A candidate training recipe can beat the current `simple_resnet_muon` baseline by lowering paired mean training time without violating the frozen validation contract.

## Hypothesis

The current baseline has exploitable slack in architecture width/depth, optimizer schedule, augmentation strength, batch/epoch tradeoff, and training-loop regularization. A controlled candidate can reach the 70% accuracy threshold faster than the current 16-epoch Muon ResNet.

## Decision Criterion

For a final candidate:

- Official metric: 30-run mean official validation accuracy must be greater than `0.7000`.
- Safety margin: prefer lower confidence bound above `0.7000` or at least a pre-registered mean margin of `>= 0.0020` before calling it robust.
- Speed metric: paired same-pod mean `candidate_time / baseline_time < 1.0` on the same seeds, with AB/BA order or equivalent order control.
- Validity: no validation-path changes, no validation labels/images in training decisions, no infrastructure-only speedups.

## Evidence That Would Change The Plan

- If the current-default 30-run baseline fails to clear 70% robustly, stop record search and first re-establish the target/baseline.
- If a 10-seed paired pilot shows candidate speed ratio depends on run order/cache state, stop speed claims and fix paired runner/cache policy.
- If dev-validation gains do not transfer to a pre-registered official final run, downgrade that trajectory and reduce official-test touches.
- If HF and torchvision CIFAR-100 tensors differ unexpectedly, stop official claims until dataset source is resolved.

## Smallest Decisive Experiments

1. CINECA interactive smoke: prove current environment, data prep, imports, and one tiny GPU run work in the intended account/session.
2. Current-default 30-run baseline: establish absolute baseline mean accuracy/time for `C100_COMPILE_MODE=default`.
3. Paired AB/BA 10-seed pilot: prove same-pod paired timing is stable enough for record comparison.
4. Dev split sanity: use a train-derived validation split for search and reserve official test for pre-registered candidates.

## Assumptions

- Supported: validation is plain no-TTA and timing stops before validation in current code.
- Untested: current-default 30-run baseline clears 70%.
- Weakly supported: 16 epochs is enough margin; evidence is one historical seed under `reduce-overhead`.
- Untested: shared TorchInductor/Triton caches do not bias paired timing.
- Untested: HF parquet and torchvision CIFAR-100 preparations are bit/label equivalent.
- Contradicted by repo policy: current environment is not repo-local or `uv`-managed.

## Phase Selection

Necessary now:

- Repo control, assumption breaker, execution DAG, and plan audit.
- Narrow literature review over fast-CIFAR, Muon, and fast augmentations.
- Implementation of controls before broad scientific search.

Deferred:

- Flywheel logging until evidence exists.
- Large hyperparameter sweeps until baseline, dev split, paired runner, and artifact schema pass.

