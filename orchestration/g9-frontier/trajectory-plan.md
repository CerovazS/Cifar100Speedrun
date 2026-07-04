# G9 Frontier Trajectory Plan

## Objective And Hypothesis

Objective: choose the next credible optimization trajectories for the CIFAR-100 A100
speedrun after the current official best `13ep-onecycle-longwarm`, without turning
official validation into a search loop.

Current official best:

- Candidate: `13ep-onecycle-longwarm`
- Config: `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0`
- Official 30-run result: mean val acc `0.713153`, min val acc `0.706600`,
  target hits `30/30`, mean timed seconds `21.720387`, mean time ratio `0.804245`
  versus the 16-epoch cosine baseline.

Primary hypothesis: the remaining winning path is not another broad architecture or
schedule search. It is a small sequence of evidence-gated combinations:

1. collect the two already-launched jobs exactly once;
2. if G8-B optimizer mechanics transfers to official validation, use it as the new
   speed substrate;
3. if AirBench-style train-only augmentation transfers to dev10, use it as accuracy
   reserve;
4. spend new GPU time only on additive train-dev tests that either preserve the faster
   substrate or justify one more epoch reduction.

Falsification criterion for this G9 plan: if the uncollected G8-B official job fails
the pre-registered official criterion and the AirBench dev10 job fails or is
inconclusive, do not promote any combination or official finalist. Fall back to a
single train-only data-path screen or a critic-approved front-end architecture pilot.

## Recommended Immediate Queue

The first two rows are collection gates, not new launches. They must happen before any
resubmission or new GPU spend that could duplicate `48463506` or `48463507`.

| Rank | Trajectory / action | Claim and hypothesis | Decision criterion | Validation mode | Expected new GPU-hours | Owner | Upside / risk |
| ---: | --- | --- | --- | --- | ---: | --- | --- |
| 0A | Collect G8-B official job `48463506` for `g8b_ns3_mom93_official_20260704T003556Z` | Claim: `longwarm + C100_NS_STEPS=3 + C100_MUON_MOMENTUM=0.93` preserves official accuracy while reducing timed training versus `13ep-onecycle-longwarm`. Hypothesis: fewer Newton-Schulz steps and slightly lower Muon momentum cut optimizer cost without losing the longwarm accuracy margin. | Use the pre-registered criterion only: official candidate mean acc `>= baseline mean - 0.002`, candidate mean acc `> 0.700`, mean time ratio `< 0.95`, complete official configs/artifacts, and independent critic PASS. Do not resubmit unless `sacct` proves failed/canceled and a new unique run id is chosen. | Already-launched official finalist, `RECORD=1`, `VALIDATION_SOURCE=official`, `RUNS=30`. No new official launch proposed. | `0.0` if collected; about `0.9` only if confirmed failed/canceled and explicitly relaunched later. | Main G8-B orchestrator, then `scientific-critic`. | Highest immediate upside: train-dev dev10 suggested time ratio `0.931954`, which would move the official longwarm time from about `21.72s` toward about `20.25s` if it transfers. Main risk is train-dev to official mismatch or incomplete artifacts after SSH outage. |
| 0B | Collect AirBench dev10 job `48463507` for `airbench_aug_pad2_alt_dev10_20260704T003552Z` | Claim: train-only `C100_TRANSLATE_PAD=2 C100_FLIP_MODE=alternating` provides accuracy reserve at neutral training time. Hypothesis: smaller translation and deterministic flip cadence reduce augmentation noise and improve early CIFAR-100 convergence without touching validation. | Recompute dev10 paired metrics from raw artifacts. Promote only if candidate differs solely by declared train-only augmentation knobs, mean train-dev acc is at least baseline mean, mean time ratio is near neutral (`<= 1.01`), no candidate instability, and result critic PASS. Do not use as official evidence. | Already-launched train-dev, `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `RUNS=10`. | `0.0` if collected; about `0.3` only if confirmed failed/canceled and explicitly relaunched later. | AirBench-transfer worktree orchestrator, then `scientific-critic`. | Upside is accuracy reserve rather than direct speed: dev3 gave `+0.0070` train-dev accuracy at time ratio `0.99927`. Risk is dev3 noise, train-dev overfit, and overlap with G8-C color jitter. |
| 1 | Additive leader candidate: `ns3_mom93 + AirBench translate2/alternating flip` | Claim: combine G8-B speed mechanics with AirBench train-only accuracy reserve to beat `13ep-onecycle-longwarm` in time while protecting official target margin. Hypothesis: the optimizer-cost gain and train-only augmentation gain are mostly independent. | Launch only after 0A/0B are collected. First run paired train-dev dev3. If G8-B official passes, control is `longwarm + ns3_mom93` and candidate adds AirBench augmentation. If G8-B official fails but AirBench dev10 passes, control is `longwarm` and candidate is the best train-only augmentation plus a separately justified `ns3_mom93` combination. Promote to dev10 only if mean acc `>= control mean - 0.001`, min acc `>= 0.697`, mean time ratio `<= 1.01` versus the speed substrate, all config diffs declared, and critic PASS. Official validation only after dev10 and pre-registration. | Train-dev only: `RECORD=0`, `VALIDATION_SOURCE=train_dev`, dev3 then dev10 if passed. | Dev3 about `0.12`; dev10 follow-up about `0.30`; official finalist about `0.9` only after critic approval. | Main/G8-B orchestrator owns if G8-B official passes; AirBench worktree owns augmentation evidence; critic arbitrates. | Best credible path to win if both in-flight signals hold: keeps the possible `~7%` G8-B speedup and adds accuracy reserve. Risk is interaction: augmentation may erase timing gain or fail to transfer to the speed substrate. |
| 2 | G8-C low-magnitude train-only color jitter on the active leader | Claim: small GPU-side brightness/contrast jitter improves accuracy reserve without changing validation or materially increasing training time. Hypothesis: low-magnitude train-only photometric variation is cheaper and less disruptive than mixup/CutMix and may protect the 70% target for faster schedules. | Do not run before SSH restoration and collection of 0A/0B. Use the existing default-off implementation only after remote preflight. If AirBench dev10 passes strongly, hold color jitter unless extra reserve is needed for rank 3. If AirBench dev10 fails or is inconclusive, run one paired train-dev dev3: candidate `C100_COLOR_JITTER=1 C100_COLOR_BRIGHTNESS=0.08 C100_COLOR_CONTRAST=0.08` on the active leader substrate. Promote only if mean acc `>= control mean - 0.001`, min acc `>= 0.697`, time ratio `<= 1.03`, and critic confirms train-only behavior. | Train-dev only: `RECORD=0`, `VALIDATION_SOURCE=train_dev`, dev3 then optional dev10. | Dev3 about `0.12`; dev10 about `0.30`. | Data-path worktree orchestrator. | Medium upside: plausible `+0.002` to `+0.005` reserve with small time cost. Risk is duplicating AirBench augmentation, over-regularization, or hidden overhead. |
| 3 | Reserve-backed 12-epoch one-cycle compression | Claim: once an accuracy-reserve candidate is established, one more epoch can be removed while staying above the target. Hypothesis: `13ep-onecycle-longwarm` has official accuracy margin; a reserve mechanism from AirBench/color jitter plus optional `ns3_mom93` can convert that margin into another speed gain. | Do not run naive 12-epoch alone. Launch only after rank 1 or rank 2 passes dev10. Single candidate, predeclared: `C100_EPOCHS=12 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0` plus the best passed reserve and, only if 0A passed, `C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93`. Dev3 promote gate: mean train-dev acc `>= 0.704` or `>= control mean - 0.002`, min acc `>= 0.697`, and time ratio `<= 0.92` versus the 13-epoch leader. Dev10 must preserve mean `>= 0.703` before any official finalist review. | Train-dev only until pre-registered finalist. | Dev3 about `0.11`; dev10 about `0.28`; official finalist about `0.85` to `0.9` only after critic approval. | Schedule/main orchestrator with whichever worktree owns the passed reserve. | High upside: another epoch is roughly a `7-8%` timed-training reduction before optimizer mechanics. High risk: prior simple compression often lost accuracy, so it is only credible with demonstrated reserve. |
| 4 | AirBench train-derived front-end / compact ConvGroup pilot, critic-first | Claim: a single AirBench-style front-end architecture may produce a better time/accuracy frontier than the current SimpleResNet/Muon substrate. Hypothesis: train-derived whitening plus a compact ConvGroup/GELU body can reduce optimization cost enough to offset CIFAR-100 difficulty, while validation remains a plain model forward with no TTA/adaptation. | No implementation or launch until an independent critic approves the whitening/model-front-end interpretation and license/copying scope. One train-dev dev3 candidate only. Promote only if mean acc `>= 0.703` with time ratio `<= 0.90` versus `13ep-onecycle-longwarm`, or mean acc `>= 0.710` with time ratio `<= 1.00`. Kill on validation-preprocessing ambiguity, underfit below `0.697` min acc, or timing overhead. | Train-dev only: `RECORD=0`, `VALIDATION_SOURCE=train_dev`, dev3 first. | Critic: `0.0`; dev3 about `0.12`; dev10 about `0.30` only if surprising pass. | AirBench-transfer worktree plus `scientific-critic` before `scientific-implementer`. | Large but uncertain upside: possible step-change if compact body transfers. Main risk is rule ambiguity around whitening, implementation surface, and CIFAR-10 to CIFAR-100 underfit. |
| 5 | Smaller/scheduled cutout only as a last train-only reserve test | Claim: a gentler cutout variant may add reserve where `C100_CUTOUT_SIZE=8` was too strong. Hypothesis: size 4 or late-only masking could regularize without the dev3 accuracy loss seen for size 8. | Do not run before ranks 1-4 are resolved or blocked. Fixed size `C100_CUTOUT_SIZE=4` is the only acceptable first candidate; scheduled cutout requires a separate critic because it changes epoch-dependent training dynamics. Promote only if mean acc `>= control mean - 0.001`, time ratio `<= 1.01`, and no seed falls below `0.697`. | Train-dev only. | Dev3 about `0.12`; dev10 about `0.30` if passed. | Data-path worktree. | Low-to-medium upside. Risk is low implementation complexity but weak prior: cutout8 was clearly negative. This is not an immediate launch unless cleaner reserve paths fail. |

## Execution Plan

1. Wait for Leonardo SSH restoration. Do not submit any new CINECA job while the
   terminal state and artifacts for `48463506` and `48463507` are unknown.
2. Collect `48463506` exactly once:
   - run `sacct -j 48463506`;
   - pull `paired_summary.json`, `paired_order.csv`, stdout/stderr, final `sacct`,
     raw per-run configs/metrics/summaries/warmups/repro metadata, and clean Git
     metadata from the clean checkout;
   - recompute paired official metrics from raw files;
   - delegate independent result critic.
3. Collect `48463507` exactly once with the same discipline:
   - run `sacct -j 48463507`;
   - pull all paired artifacts and the worktree diff hash;
   - recompute dev10 train-dev metrics;
   - delegate independent result critic.
4. Choose the first new launch from the table:
   - if both 0A and 0B pass, run rank 1 first;
   - if 0A passes and 0B fails, run rank 2 only if more reserve is needed for rank 3;
   - if 0A fails and 0B passes, use AirBench augmentation as reserve and decide whether
     rank 1 is still meaningful as a train-dev repair test;
   - if both fail, skip combinations and run only rank 2 or critic-first rank 4.
5. Keep every new run train-dev until a dev10 result and critic review justify a
   pre-registered official finalist.

## Expected Artifacts Per New Run

Use the existing output convention:

```text
outputs/cifar100_speedrun/<unique_run_id>/
  paired_summary.json
  paired_order.csv
  seed*_A_*/config.json
  seed*_A_*/metrics.csv
  seed*_A_*/summary.json
  seed*_A_*/warmup.json
  seed*_A_*/repro_metadata.json
  seed*_B_*/...
```

Curated local orchestration mirrors should include:

- `result.md` or `summary.md`;
- `verification.json`;
- `metrics-table.tsv`;
- `paired-<job>.out` and `paired-<job>.err`;
- `sacct-<job>.txt`;
- full raw artifact mirror or manifest;
- independent `critic.md`.

## Deferred / Killed

- Do not naively repeat PreAct. `C100_BLOCK_TYPE=preact` was killed: it was slightly
  more accurate on dev3 but consistently slower, with mean time ratio `1.037760`.
- Do not repeat killed width/depth/capacity variants: `narrow222`, `basewidth222`,
  `shallow122`, `shallow122@16`, `late-light`, `mid-heavy late-light`, and
  `mid-light full-late`.
- Do not repeat G5b killed regularization or batch variants as standalone candidates:
  `C100_CUTOUT_SIZE=8`, shallow recovery, and batch-1536.
- Do not run a naive `12ep-onecycle` screen without an established reserve. It becomes
  credible only as rank 3 after AirBench/color-jitter reserve evidence.
- Do not launch ConvMixer, ConvNeXt, RepVGG, or a broad architecture grid now. They are
  lower-priority than the single AirBench front-end pilot and would be a wish list.
- Do not implement or launch AirBench whitening/front-end until an independent critic
  approves validation semantics and source/license handling.
- Do not perform official-test search loops. Official validation is allowed only for a
  pre-registered finalist after train-dev evidence, complete artifacts, and critic
  approval.
- Do not cancel, close, or replace active workstream runs. The only allowed action on
  `48463506` and `48463507` is collection/verification after SSH returns.

## SLURM / Run Isolation Gates

- CINECA source of truth: use Leonardo with account `IscrC_SIMP`; A100 work belongs on
  `boost_usr_prod`. Official finalist jobs may use the already established
  `--qos=boost_qos_lprod` pattern after pre-registration.
- Do not store datasets or checkpoints under `$WORK`. Continue using the established
  scratch checkout/output roots under
  `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/`, with reusable
  datasets kept persistent according to the project's existing CINECA setup.
- Before every launch:
  - choose a unique `RUN_ID`;
  - verify `test ! -e outputs/cifar100_speedrun/${RUN_ID}`;
  - run `bash -n slurm/paired_compare.sh`;
  - run `python3 -m py_compile cifar100-benchmark/train_cifar100_resnet_muon.py`
    or the current repository-equivalent static check;
  - verify the active checkout, commit/diff, and worktree-specific ownership;
  - verify no unrelated active jobs would be duplicated.
- For train-dev pilots:
  - set `RECORD=0`;
  - set `VALIDATION_SOURCE=train_dev`;
  - set `C100_DEV_PER_CLASS=50`;
  - set `C100_DEV_SPLIT_SEED=20260703`;
  - prepare/read only the official train split for search;
  - keep paired AB/BA ordering and raw per-seed artifacts.
- For official finalists only:
  - use `RECORD=1`;
  - use `VALIDATION_SOURCE=official`;
  - use `RUNS=30`;
  - use fixed plain validation on official CIFAR-100 test;
  - keep same-pod paired comparison;
  - no validation-path edits, TTA, validation adaptation, ensembles, timing-boundary
    changes, or output reuse.
- After every run, do not interpret results until artifacts are mirrored locally,
  metrics are recomputed from raw files, scheduler state is captured with `sacct`, and
  a separate critic has reviewed claim strength and rule compliance.

## Verification Gates

- Plan gate: this G9 queue must be treated as a ranked execution plan, not approval to
  submit all rows. Each new launch still needs a predeclared claim, hypothesis,
  decision criterion, validation mode, run id, output root, and owner.
- Collection gate: `48463506` and `48463507` must be terminal and collected before any
  duplicate or dependent run.
- Critic gate: every promotion from dev3 to dev10, and every promotion from dev10 to
  official finalist, needs an independent `scientific-critic` pass.
- Analysis gate: paired summaries must be recomputed from raw `metrics.csv`, not trusted
  blindly from wrapper output.
- Logging gate: no Flywheel/Linear mutation is proposed by this artifact. If a future
  official finalist completes, delegate `$flywheel-log` only after curated plots,
  metrics, summaries, `reproducibility.md`, and `commit.txt` exist.

## Trace

Commands/tools run:

- Read `/Users/lucacerovaz/.codex/skills/scientific-automation-pipeline/SKILL.md`.
- Read `/Users/lucacerovaz/projects/agent-config/codex/SLURM.md`.
- Read main context: `program.md`,
  `orchestration/g8-official-longwarm/result.md`,
  `orchestration/g8-b-muon/runtime-dev10-20260704T000009Z/result.md`,
  `orchestration/g8-c-data-path/summary.md`,
  `orchestration/g8-a-schedule/dev10-result.md`,
  and `orchestration/g8-search/assignments.md`.
- Read G8-B official blocked/launch traces:
  `orchestration/g8-b-muon/runtime-official-20260704T003556Z/trace.md`,
  `blocked.md`, and `submit.txt`.
- Read architecture worktree context:
  `/Users/lucacerovaz/Documents/Cifar100 Speedrun-worktrees/arch-frontier/program.md`,
  `orchestration/arch-frontier/result.md`, and
  `orchestration/arch-frontier/architecture-plan.md`.
- Read AirBench worktree context:
  `/Users/lucacerovaz/Documents/Cifar100 Speedrun-worktrees/airbench-transfer/program.md`,
  `orchestration/airbench-transfer/runtime-dev3-20260704T000804Z/result.md`,
  `orchestration/airbench-transfer/ranked_transfer_plan.md`, and
  `orchestration/airbench-transfer/plan_audit.md`.
- Read data-path worktree context:
  `/Users/lucacerovaz/Documents/Cifar100 Speedrun-worktrees/data-path/program.md`,
  `orchestration/data-path/plan.md`, and
  `orchestration/data-path/critic.md`.
- Ran local discovery/status commands: `find orchestration -maxdepth 2 -type f`,
  `git status --short`, and targeted `rg`.

Files touched:

- Created directory `orchestration/g9-frontier/`.
- Created this file: `orchestration/g9-frontier/trajectory-plan.md`.

Outputs produced:

- This ranked G9 frontier trajectory plan.

Unresolved risks:

- Leonardo SSH is still the blocking external condition for collection.
- `48463506` and `48463507` terminal states are unknown.
- G8-B train-dev to official transfer is unknown until `48463506` artifacts are
  collected and critiqued.
- AirBench augmentation dev3 may not survive dev10.
- G8-C color jitter is implemented locally but has no runtime evidence.
- AirBench whitening/front-end remains validation-semantics sensitive and critic-blocked.
