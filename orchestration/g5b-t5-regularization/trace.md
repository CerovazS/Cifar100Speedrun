# G5b-T5 Cheap Regularization Trace

## Active Objective

Run exactly one train-dev dev3 paired pilot for cheap regularization as a 14-epoch margin-rescue test on Leonardo A100.

## Claim, Hypothesis, Gate

- Claim: small train-time cutout may recover enough accuracy for the near-miss 14-epoch default schedule with tolerable time overhead.
- Hypothesis: at `EPOCHS=14`, candidate `C100_CUTOUT_SIZE=8 C100_LABEL_SMOOTHING=0.05` improves mean train-dev accuracy over the 14-epoch default enough to clear target while adding little time.
- Decision criterion: PASS only if all hold: `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `paired_seeds=3`, candidate mean train-dev `val_acc >= 0.7000`, candidate hits `>= 2/3`, `mean_val_acc_delta >= +0.0020`, and `mean_time_ratio <= 1.06`. KILL otherwise.
- No dev10, official validation, record mode, Flywheel, or Linear from this pilot.

## Run Identity

- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Required branch: `codex/cifar100-speedrun-control`
- Required commit gate: `7a5ea61` or descendant
- Observed remote commit before launch: `7a5ea619f1ee4f94c1824eff7c4ae4421ddef9c9`
- Initial blocked run id reserved but not submitted: `g5b_t5_cutout8_ep14_dev3_20260703T154040Z_7a5ea61`
- Submitted run id: `g5b_t5_cutout8_ep14_dev3_20260703T154512Z_7a5ea61`
- Output root: `outputs/cifar100_speedrun/g5b_t5_cutout8_ep14_dev3_20260703T154512Z_7a5ea61`

## Pre-Launch Checks

- Required context read: `program.md`, `orchestration/g5b-search/assignments.md`, `cifar100-benchmark/train_cifar100_resnet_muon.py`, `slurm/paired_compare.sh`, `orchestration/g5-t1-schedule/summary.md`, `/Users/lucacerovaz/projects/agent-config/codex/SLURM.md`.
- Remote branch observed: `codex/cifar100-speedrun-control`.
- Remote commit gate passed: `7a5ea61` is an ancestor of `HEAD`.
- Remote dirty state before launch: untracked `orchestration/g6-official-retrain/`; no code modifications observed by `git status --porcelain`.
- Scheduler state before launch: job `48412311 c100-g5b-t6-b1536` pending; no official or record job observed in `squeue`.
- Prep path check: `slurm/paired_compare.sh` sources `env_setup.sh`, which changes directory to `cifar100-benchmark`; `C100_PREP_SPLITS=train python prepare_cifar100_hf.py` should prepare only train in non-record mode.

## Submission Command

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
unset BATCH MUON_LR BIAS_LR C100_BATCH C100_MUON_LR C100_BIAS_LR C100_CUTOUT_SIZE C100_LABEL_SMOOTHING
export RECORD=0
export RUNS=3
export EPOCHS=14
export TARGET=0.70
export BASE_SEED=883400
export VALIDATION_SOURCE=train_dev
export RUN_ID=g5b_t5_cutout8_ep14_dev3_20260703T154512Z_7a5ea61
export CANDIDATE_ENV='C100_CUTOUT_SIZE=8 C100_LABEL_SMOOTHING=0.05'
sbatch --parsable slurm/paired_compare.sh
```

## Status

- Pre-launch trace created.
- First guarded submission attempt did not call `sbatch`: the pre-submit `squeue` check found a running job named `c100-user-official`, so the launcher exited before submitting T5.
- After a later fresh gate check showed no official/record job and no existing T5 output directory, T5 was submitted as Slurm job `48412962`.
- State at submission: `PENDING (Priority)`.
- Final Slurm state: `COMPLETED`, exit `0:0`, elapsed `00:06:42`, node `lrdn0192`.

## Submission Block

```text
c100-user-official RUNNING
refusing_submit: official/record job present in squeue
```

## Pre-Launch Critic

Verdict: blocked.

- Blocker: `squeue` contains official-validation job `48412394 c100-user-official`, violating the required no official/record precondition.
- High risk: existing G5b-T6 job `48412311 c100-g5b-t6-b1536` was also running; if T5 is intended as the only concurrent pilot, wait or document acceptance before launch.
- High risk: baseline contamination prevention depends on the submit shell unsetting `BATCH`, LR, cutout, and label-smoothing variables before `CANDIDATE_ENV`; keep the exact unset line in the submit command.
- Medium risk: because trainer default label smoothing is already `0.05`, the candidate claim should be cutout8 on top of default label smoothing, not a label-smoothing benefit.
- Medium risk: `paired_summary.json` does not emit the full PASS/KILL verdict directly; post-run gate must compute candidate mean/hits from metrics and summary artifacts.

## Trace Requirements

Return job id, exact commands, output paths, metrics table, scheduler accounting, PASS/KILL recommendation, files touched, and unresolved risks.

## Final Metrics

| Seed | Order | Baseline val_acc | Candidate val_acc | Delta | Baseline time | Candidate time | Time ratio |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `883400` | baseline/candidate | `0.6922` | `0.6844` | `-0.0078` | `20.653777` | `20.581893` | `0.996520` |
| `883401` | candidate/baseline | `0.6950` | `0.6914` | `-0.0036` | `20.685385` | `20.673563` | `0.999428` |
| `883402` | baseline/candidate | `0.6910` | `0.6868` | `-0.0042` | `20.716840` | `20.844148` | `1.006145` |

Aggregate:

- Baseline mean train-dev `val_acc`: `0.692733`.
- Candidate mean train-dev `val_acc`: `0.687533`.
- Candidate hits: `0/3`.
- Mean train-dev `val_acc` delta: `-0.005200`.
- Mean time ratio: `1.000697727`.
- Candidate env: `C100_CUTOUT_SIZE=8 C100_LABEL_SMOOTHING=0.05`.

## Gate Verdict

KILL.

The pilot satisfies the run-shape gates (`RECORD=0`, `VALIDATION_SOURCE=train_dev`, `paired_seeds=3`) but fails the accuracy gates:

- Candidate mean train-dev `val_acc` is `0.687533`, below required `0.7000`.
- Candidate hits are `0/3`, below required `>=2/3`.
- Mean `val_acc` delta is `-0.005200`, below required `+0.0020`.
- Mean time ratio is `1.000697727`, which is within `<=1.06` but neutral/slower and cannot rescue the failed accuracy criteria.

No dev10, official validation, record mode, rerun, Flywheel, or Linear action is supported.

## Final Verification

- Prep stdout mentions only `cifar100/train.pt`; no `cifar100/test.pt` mention was found.
- All six configs record `validation_source=train_dev`, `epochs=14.0`, `target=0.7`, commit `7a5ea619f1ee4f94c1824eff7c4ae4421ddef9c9`.
- Baseline configs have `cutout_size=0`, `label_smoothing=0.05`.
- Candidate configs have `cutout_size=8`, `label_smoothing=0.05`.
- Output root contains `paired_order.csv`, `paired_summary.json`, six per-method `config.json`, `metrics.csv`, `summary.json`, `warmup.json`, `repro_metadata.json`, plus copied `stdout.log` and `stderr.log`.
