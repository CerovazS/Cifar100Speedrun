# G8-C Train-Only Data Path Feasibility Map

## Orientation

G8-C is a read-only feasibility pass for CIFAR-100 train-only data/augmentation changes. The active contract is:

- Exploratory G8 work must use `RECORD=0` and `VALIDATION_SOURCE=train_dev`.
- Official validation is allowed only for separately pre-registered finalist/record evidence, with `RECORD=1`, `VALIDATION_SOURCE=official`, `RUNS=30`, and fixed plain validation.
- Forbidden for both search and record claims: validation path edits, test-time augmentation, validation-time adaptation, ensembles, timing-boundary changes, or any use of official validation images/labels in training decisions.

Primary implementation surface is script-first, not package-first:

- Trainer: `cifar100-benchmark/train_cifar100_resnet_muon.py`
- HF data prep: `cifar100-benchmark/prepare_cifar100_hf.py`
- Torchvision data prep fallback: `cifar100-benchmark/prepare_cifar100.py`
- Paired search wrapper: `slurm/paired_compare.sh`
- Smoke/discovery wrappers: `slurm/smoke.sh`, `slurm/discovery.sh`
- Official baseline wrapper: `slurm/official_baseline.sh`

## Execution Map

### Data Prep

- `env_setup.sh:25` changes into `$CIFAR100_ROOT/cifar100-benchmark`, so trainer/prep relative paths resolve under `cifar100-benchmark/`.
- `prepare_cifar100_hf.py:11-15` defines `cifar100/train.pt` and `cifar100/test.pt` from the HuggingFace `uoft-cs/cifar100` train/test parquet URLs.
- `prepare_cifar100_hf.py:24-48` converts each selected split into a `torch.save` payload with `images`, `labels`, and `classes`.
- `prepare_cifar100_hf.py:53-59` honors `C100_PREP_SPLITS`; non-record paired/smoke/discovery wrappers set `train` only, while record/official modes prepare train+test.
- `prepare_cifar100.py:5-13` is a torchvision fallback that writes the same logical `train.pt` / `test.pt` files.

Current prep path is compliant for G8 search when wrappers use `C100_PREP_SPLITS=train`: the official test split is not needed because `train_dev` validation is carved from official train.

### Trainer Load And Split

- `train_cifar100_resnet_muon.py:40-45` loads a named split from `cifar100/<name>.pt`, moves it to CUDA, converts images to FP16 `[N,C,H,W]`, scales to `[0,1]`, and keeps labels as `long`.
- `train_cifar100_resnet_muon.py:48-63` creates the exploratory train/dev split from the official train split only. It samples `C100_DEV_PER_CLASS` examples per class with fixed `C100_DEV_SPLIT_SEED`.
- `train_cifar100_resnet_muon.py:441-468` selects validation source:
  - `official`: train on `train.pt`, evaluate on `test.pt`.
  - `train_dev`: load only `train.pt`, then split into train subset and held-out train-derived dev subset.
- `train_cifar100_resnet_muon.py:489-493` records validation source, split seed/count, and effective train/eval example counts in `config.json`.

### Train-Only Transform Path

Current train-time transforms are all inside the timed training region:

- `normalize`: fixed channel mean/std in `train_cifar100_resnet_muon.py:66-68`.
- `random_crop_flip`: reflect-pad by 4, random crop back to 32x32, random horizontal flip in `train_cifar100_resnet_muon.py:71-83`.
- `random_cutout`: optional zero mask of fixed size in `train_cifar100_resnet_muon.py:86-102`.
- `train_once`: applies `normalize(random_crop_flip(x))`, then optional `random_cutout`, then cross-entropy with label smoothing in `train_cifar100_resnet_muon.py:378-385`.
- Existing env knobs: `C100_LABEL_SMOOTHING` and `C100_CUTOUT_SIZE` are parsed in `train_cifar100_resnet_muon.py:453-458` and logged in `train_cifar100_resnet_muon.py:500-501`.

Important implemented detail: cutout currently runs after normalization, so masked pixels become normalized-space `0.0`, not dataset-mean pixels. That is still train-only, but it is a semantic detail to audit before stronger cutout variants.

### Validation/Test-Time Path

Validation is plain and separate:

- `evaluate` in `train_cifar100_resnet_muon.py:205-219` sets `model.eval()`, normalizes each batch, performs one forward pass, and computes argmax accuracy.
- It does not apply crop, flip, cutout, color jitter, mixup, confidence branching, BN adaptation, EMA selection, or ensembling.
- Training timer starts at `train_cifar100_resnet_muon.py:376` and stops at `train_cifar100_resnet_muon.py:396`; validation happens after the timed boundary.
- Warmup calls `train_once(..., evaluate_validation=False)` in `train_cifar100_resnet_muon.py:518-535`, so warmup does not evaluate validation.

### Wrapper Gates And Outputs

- `slurm/paired_compare.sh:33-47` defaults non-record pilots to `RUNS=10`, `VALIDATION_SOURCE=train_dev`, and prepares train only; record mode defaults to official validation.
- `slurm/paired_compare.sh:51-64` refuses `RECORD=1` without official validation, refuses non-30-run record mode, and refuses official validation unless `RECORD=1`.
- `slurm/paired_compare.sh:66-72` refuses output directory reuse and records paired order.
- `slurm/paired_compare.sh:74-82` clears known training env overrides for each method.
- `slurm/paired_compare.sh:84-99` allowlists candidate env keys. Current data/regularization allowlist includes only `C100_LABEL_SMOOTHING` and `C100_CUTOUT_SIZE`; any new augmentation knob needs wrapper allowlist and config-diff mapping before launch.
- `slurm/paired_compare.sh:188-219` maps candidate env keys to config fields and rejects undeclared candidate/baseline differences.
- `slurm/smoke.sh:32-40` and `slurm/discovery.sh:32-44` prepare train only and use `train_dev`.
- `slurm/official_baseline.sh:32-41` prepares train+test and runs official validation.

Outputs are under `$CIFAR100_ROOT/outputs/cifar100_speedrun/<RUN_ID>/`, with per-method paired subdirectories, `config.json`, `metrics.csv`, `summary.json`, `warmup.json`, `repro_metadata.json`, and paired summary/order artifacts.

## Current Augmentations

Train-only, currently active:

- Random reflected crop with `pad=4`.
- Random horizontal flip with `p=0.5`.
- Dataset normalization using fixed CIFAR-100 mean/std.
- Label smoothing, default `0.05`.

Train-only, implemented but default off:

- Cutout via `C100_CUTOUT_SIZE`; default `0`. Prior G5b evidence killed `C100_CUTOUT_SIZE=8` at 14 epochs: mean train-dev accuracy delta `-0.005200`, candidate mean `0.687533`, mean time ratio `1.000698`.

Validation/test-time:

- Plain normalization and one forward pass only.
- No validation/test-time augmentation is currently implemented in the trainer.

## Compliant Candidate Changes

Ranked by expected value versus rule and implementation risk:

1. **Train-only GPU color jitter, low magnitude**
   - Candidate: add batch-wise train-only brightness/contrast, optionally saturation-like channel scaling, inside `train_once` before `normalize` or immediately after crop/flip with clearly documented semantics.
   - Expected value: medium. Literature plan already marked cheap GPU-side color jitter as plausible but low-priority; it may add accuracy reserve with minimal model/schedule disruption.
   - Risk: medium. Must be strictly training-only and must not be selected using official validation. Implementation must avoid CPU/PIL transforms and keep cost inside timed training.
   - Audit gate: prove `evaluate` is unchanged; config must log jitter enable/magnitude; paired wrapper must allow and diff-check new `C100_*` jitter keys.

2. **Cutout retest with smaller or later/conditional strength, not `size=8` as already killed**
   - Candidate: `C100_CUTOUT_SIZE=4`, or an epoch-progress/ramp variant that activates only after early fitting.
   - Expected value: low-to-medium. CIFAR-100 may benefit from small occlusion, but G5b `size=8` was clearly negative at 14 epochs.
   - Risk: low for fixed-size cutout, medium for scheduled cutout because it adds new logic and config fields.
   - Audit gate: keep mask generation inside training loop only; record whether masks are applied in normalized or pre-normalized pixel space; do not promote without paired train-dev evidence.

3. **Train-only mixup or CutMix micro-pilot**
   - Candidate: implement a simple in-batch mixup/CutMix path using only current train batches and train labels, with env knobs for alpha/probability.
   - Expected value: medium for accuracy reserve, but uncertain under 13-14 epoch speed constraints.
   - Risk: high. It changes loss semantics, label handling, and may need longer training. It must never use dev/official labels outside the held-out eval computation.
   - Audit gate: static critic must verify only batch-local train tensors and labels are used; metrics/config must distinguish soft-label training; paired wrapper must validate all new knobs.

4. **AirBench-style train-derived patch whitening or input preprocessing**
   - Candidate: compute a fixed whitening/patch transform from official train images only and apply it in the training path, with a separately audited decision on whether the identical fixed transform is allowed for validation as model preprocessing.
   - Expected value: potentially high if transferred well from AirBench, but uncertain for this existing ResNet/Muon substrate.
   - Risk: high. If the transform is applied to validation it changes the validation preprocessing path; if fitted using anything outside official train it is forbidden. It may also affect the timing boundary and data-staging contract.
   - Audit gate: do not implement until the contract is clarified. A strictly train-only whitening augmentation is safer; a model-input transform used at validation needs explicit critic approval because it touches validation preprocessing even if fitted on train.

5. **Normalization/statistics audit, not tuning**
   - Candidate: verify current mean/std match the prepared train tensor and decide whether constants should remain fixed.
   - Expected value: low as an accuracy lever.
   - Risk: medium as a contract surface. Changing normalization for validation is a validation preprocessing change; recomputing constants is safe only if treated as a fixed train-derived model preprocessing decision and pre-approved.
   - Audit gate: no official-validation-driven normalization choice; no per-run or per-candidate normalization selected from dev/official outcomes.

## Forbidden Ideas

Forbidden for G8 search and record claims:

- Any official validation/test label use for augmentation, preprocessing selection, data filtering, schedule selection, early stopping, or candidate promotion outside the pre-registered finalist gate.
- Official validation in G8 exploratory pilots (`VALIDATION_SOURCE=official` with `RECORD=0`), which the paired wrapper already refuses.
- Test-time augmentation: validation flips, crops, multi-crop averaging, or stochastic validation views.
- Validation-time adaptation: BN recalibration on eval images, test-time training, confidence-triggered branches, calibration on validation labels, or per-example validation control flow.
- Ensembles, EMA/model selection using validation outcomes, or checkpoint selection by official validation.
- Timing-boundary changes: moving augmentation/preprocessing/warmup/compile work outside the measured training region to create a speed claim.
- Data expansion beyond official CIFAR-100 train images for training, including external images, pretrained features, synthetic images from external models, or unofficial labels.
- Data filtering/curriculum based on validation/test performance or model confidence on validation/test images.

## Next Implementation And Audit Gates

1. Static plan gate:
   - Choose exactly one candidate family.
   - Write claim, hypothesis, falsification criterion, metric, run id pattern, output root, and allowed `C100_*` knobs before any code change.
   - Keep `RECORD=0`, `VALIDATION_SOURCE=train_dev`, unique `RUN_ID`, and no output reuse.

2. Code-scope gate:
   - Edits must be limited to train-only transform/loss logic, config logging, and paired wrapper allowlist/diff mapping.
   - Forbidden edit zones for G8-C: `evaluate`, official split loading behavior, wrapper official-validation gates, warmup validation flag, and timer start/stop boundaries.

3. Static verification gate:
   - Run shell syntax checks for touched wrappers.
   - Parse Python files with `ast`.
   - Diff audit must show no validation/test-time transform changes and no new path reading `test.pt` in non-record mode.

4. Paired search gate:
   - First launch must be paired dev3 train-dev only, against the current G8-selected control.
   - Required artifacts: paired order, paired summary, per-method config/metrics/summary/warmup/repro metadata, Slurm stdout/stderr, and `sacct`.
   - Promote only after independent critic audit confirms train-only behavior and positive paired evidence.

5. Official gate:
   - Official validation is only for a pre-registered finalist after train-dev evidence and critic approval.
   - Official run must use `RECORD=1`, `VALIDATION_SOURCE=official`, `RUNS=30`, `C100_PREP_SPLITS=train,test`, paired same-pod comparison, and unchanged plain validation.

## Maintainability Notes

- The repo is script-first and has no `src/` package, Hydra config, Lightning trainer, or tests. That is workable for a micro-benchmark but makes validation-boundary regressions easy to introduce.
- New augmentations should not accumulate as untracked ad-hoc branches in `train_once`; each new train-only behavior needs explicit config fields and wrapper diff validation.
- `analyze_cifar100.py` still names the printed hit column `tta` in its regex fields; that is stale naming and could confuse future audits, although it does not change trainer behavior.
- Existing wrapper gates are a strong control surface. Any new candidate env key that bypasses them should be treated as invalid.

## Trace

Commands/tools run:

- Read skill: `/Users/lucacerovaz/.codex/skills/repo-control-plan/SKILL.md`.
- Read active docs: `program.md`, `orchestration/g8-search/assignments.md`, `README.md`, `program/02-repo-control.md`, `program/01-literature-plan.md`, `program/04-execution-dag.md`.
- Inspected files with `sed`, `nl`, `find`, `rg`, and `git status --short`.
- Mapped code: `cifar100-benchmark/train_cifar100_resnet_muon.py`, `prepare_cifar100_hf.py`, `prepare_cifar100.py`, `analyze_cifar100.py`, `env_setup.sh`, `slurm/paired_compare.sh`, `slurm/smoke.sh`, `slurm/discovery.sh`, `slurm/official_baseline.sh`, `pyproject.toml`, `requirements.txt`.
- Read prior cutout evidence: `orchestration/g5b-t5-regularization/result.md` and `trace.md`.

Files touched:

- Created `orchestration/g8-c-data-path/summary.md`.
- Created directory `orchestration/g8-c-data-path/`.

Outputs produced:

- This read-only feasibility summary.

Unresolved risks:

- No runtime checks or GPU jobs were run by design.
- No official validation or Flywheel mutation was performed.
- Candidate expected values are engineering estimates from repo/literature context, not new empirical evidence.
- AirBench-style whitening needs explicit contract review before implementation because it may blur train-derived model preprocessing and validation preprocessing boundaries.
