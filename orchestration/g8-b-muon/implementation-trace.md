# G8-B Muon Mechanics Implementation Trace

## Scope

Write scope was limited to:

- `cifar100-benchmark/train_cifar100_resnet_muon.py`
- `slurm/paired_compare.sh`
- `orchestration/g8-b-muon/`

No launch was performed. No Flywheel mutation was performed.

## Claim And Hypothesis

Claim: schedule compression may combine with Muon update mechanics to recover more accuracy at 13-14 epochs without increasing timed training.

Hypothesis: exposing Muon Newton-Schulz steps, Muon momentum, Muon weight decay, and SGD momentum as declared environment knobs will allow controlled paired train-dev screens while preserving the existing default trainer behavior when the variables are unset.

Decision criterion for this implementation-only pass: static checks pass, defaults match previous literals, and `paired_compare.sh` rejects undeclared candidate env keys while mapping the four new keys to tracked config fields.

## Changes

- Added `C100_NS_STEPS`, default `5`, as the Newton-Schulz iteration count used inside `Muon.step()`.
- Added `C100_MUON_MOMENTUM`, default `0.95`, passed to `Muon`.
- Added `C100_MUON_WEIGHT_DECAY`, default `2e-4`, passed to `Muon`.
- Added `C100_SGD_MOMENTUM`, default `0.9`, passed to the SGD optimizer for non-matrix parameters.
- Recorded all four fields in trainer `config.json` and the trainer stdout config line.
- Added all four fields to paired wrapper env cleanup, candidate allowlist, env-to-config mapping, and tracked config diff validation.

## Critic Block Follow-Up

Independent critic verdict: blocked because the first implementation exposed mechanics knobs with insufficient bounds. In particular, momentum accepted values `>= 1`, Newton-Schulz steps were only positive rather than practically bounded, and weight decay had no upper bound.

Fix:

- `C100_NS_STEPS`: integer in `[1, 8]`, default `5`.
- `C100_MUON_MOMENTUM`: finite float in `[0.0, 1.0)`, default `0.95`.
- `C100_MUON_WEIGHT_DECAY`: finite float in `[0.0, 0.01]`, default `2e-4`.
- `C100_SGD_MOMENTUM`: finite float in `[0.0, 1.0)`, default `0.9`.

## Verification Results

- `python3 -m py_compile cifar100-benchmark/train_cifar100_resnet_muon.py`
  - Result: passed.
- `bash -n slurm/paired_compare.sh`
  - Result: passed.
- static/default-preservation check for previous literals and wrapper mapping
  - Result: passed; source markers confirm defaults `5`, `0.95`, `2e-4`, and `0.9`, plus wrapper cleanup, allowlist, run defaults, env-to-config mapping, and diff fields.
- AST `train_once` call arity check
  - Result: passed; warmup supplies the optional validation flag and measured runs use the default while passing all four new mechanics values.

Follow-up verification after critic block fix:

- `python3 -m py_compile cifar100-benchmark/train_cifar100_resnet_muon.py`
  - Result: passed.
- `bash -n slurm/paired_compare.sh`
  - Result: passed.
- `git diff --check -- cifar100-benchmark/train_cifar100_resnet_muon.py slurm/paired_compare.sh orchestration/g8-b-muon/implementation-trace.md`
  - Result: passed.
- static bounds/default marker check
  - Result: passed; source markers confirm exact defaults and bounds for `C100_NS_STEPS`, `C100_MUON_MOMENTUM`, `C100_MUON_WEIGHT_DECAY`, and `C100_SGD_MOMENTUM`, plus wrapper defaults and config-diff mappings.

## Risks

- This pass does not execute training and therefore does not verify runtime optimizer effects or accuracy/time behavior.
- Bounds are static/syntax verified only. Scientific candidate values still need critic approval before launch.
