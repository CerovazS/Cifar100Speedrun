# G8-A One-Cycle Compression Frontier Trace

## Objective

Run the G8-A one-cycle compression frontier as exploratory paired train-dev dev3 only. This workstream owns only `orchestration/g8-a-schedule/` locally and does not edit validation path, timing code, or repository source files.

## Claim

A 13-epoch one-cycle candidate may preserve the train-dev accuracy margin discovered by the 14-epoch one-cycle G7 finalist while reducing timed training enough to justify dev10 promotion.

## Hypothesis

The G7 14-epoch one-cycle schedule improved train-dev accuracy over the 14-epoch cosine control and cleared official finalist evidence. If the one-cycle schedule concentrates useful optimization earlier, a 13-epoch candidate with either default warmup (`pct_up=0.30`) or longer warmup (`pct_up=0.40`) can stay above `0.700` train-dev mean accuracy, beat the paired 14-epoch baseline by at least `+0.0025`, and run at no more than `0.95x` the baseline time.

## Decision Criterion

Promote a candidate to train-dev dev10 only if all checks pass:

- SLURM job completed with exit `0:0`.
- `record_mode=false`.
- `validation_source=train_dev`.
- `paired_seeds=3`.
- Baseline uses `EPOCHS=14`.
- Candidate differs only on declared `C100_EPOCHS`, `C100_LR_SCHEDULE`, `C100_ONECYCLE_PCT_UP`, and `C100_ONECYCLE_DIV_FACTOR`.
- Candidate mean train-dev accuracy `>= 0.700`.
- Mean train-dev accuracy delta `>= +0.0025`.
- Mean time ratio `<= 0.95`.

Kill otherwise. This is exploratory evidence only and cannot support a record claim.

## Preflight

- Required local context read: `program.md`, `orchestration/g8-search/assignments.md`, `/Users/lucacerovaz/.codex/skills/research-housekeeping/SKILL.md`, `/Users/lucacerovaz/projects/agent-config/codex/SLURM.md`, `README.md`, `BASELINE_PROBES.md`, `SMOKE_RESULT.md`, `.env`.
- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`.
- Remote commit before launch: `2c3edb7`.
- Remote dirty state before launch: untracked `orchestration/g6-official-retrain/` only.
- Account-compatible wrapper: `slurm/paired_compare.sh` uses `#SBATCH --account=IscrC_SIMP`, `boost_usr_prod`, `boost_qos_dbg`, `--gres=gpu:1`, `--time=00:30:00`.
- Remote `bash -n slurm/paired_compare.sh`: passed.
- Remote `source env_setup.sh >/dev/null && python -m py_compile train_cifar100_resnet_muon.py`: passed.
- Remote static wrapper inspection confirms `C100_EPOCHS`, `C100_LR_SCHEDULE`, `C100_ONECYCLE_PCT_UP`, and `C100_ONECYCLE_DIV_FACTOR` are allowlisted and mapped to config diff fields.
- Leonardo `squeue -u $USER`: no jobs listed before launch.
- `python` is not available before `env_setup.sh`; py_compile must be interpreted only after sourcing the wrapper environment.

## Launch Metadata

| Candidate | Run id | Output root | Candidate env |
| --- | --- | --- | --- |
| `13ep-onecycle-default` | `g8a_13ep_onecycle_default_dev3_20260703T213903Z` | `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_default_dev3_20260703T213903Z` | `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0` |
| `13ep-onecycle-longwarm` | `g8a_13ep_onecycle_longwarm_dev3_20260703T213903Z` | `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev3_20260703T213903Z` | `C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0` |

Shared launch environment:

- `RECORD=0`
- `VALIDATION_SOURCE=train_dev`
- `RUNS=3`
- `EPOCHS=14`
- `BASE_SEED=890000`
- remote submit directory: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`

## Commands

```bash
ssh leonardo 'cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun && test ! -e outputs/cifar100_speedrun/g8a_13ep_onecycle_default_dev3_20260703T213903Z && RUN_ID=g8a_13ep_onecycle_default_dev3_20260703T213903Z RECORD=0 RUNS=3 EPOCHS=14 VALIDATION_SOURCE=train_dev BASE_SEED=890000 CANDIDATE_ENV="C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0" sbatch slurm/paired_compare.sh'
```

```bash
ssh leonardo 'cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun && test ! -e outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev3_20260703T213903Z && RUN_ID=g8a_13ep_onecycle_longwarm_dev3_20260703T213903Z RECORD=0 RUNS=3 EPOCHS=14 VALIDATION_SOURCE=train_dev BASE_SEED=890000 CANDIDATE_ENV="C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0" sbatch slurm/paired_compare.sh'
```

## Stop Conditions

Do not launch or relaunch into the same run id if output paths exist, wrapper guards fail, validation source is not `train_dev`, record mode is enabled, candidate config differs on undeclared fields, SLURM account is not `IscrC_SIMP`, or any code/validation/timing file changes are required.

## Submission

- `13ep-onecycle-default`: output path was absent immediately before submit; submitted as SLURM job `48445735`.
- `13ep-onecycle-longwarm`: output path was absent immediately before submit; submitted as SLURM job `48445734`.
- Both jobs ran concurrently on Leonardo A100 nodes.

## Completion

`sacct`:

| Job | Candidate | State | Exit | Elapsed | Node |
| --- | --- | --- | --- | --- | --- |
| `48445735` | `13ep-onecycle-default` | `COMPLETED` | `0:0` | `00:06:29` | `lrdn3112` |
| `48445734` | `13ep-onecycle-longwarm` | `COMPLETED` | `0:0` | `00:06:28` | `lrdn1557` |

Wrapper summaries:

| Candidate | Run id | Record mode | Validation | Seeds | Candidate mean acc | Baseline mean acc | Mean acc delta | Mean time ratio | Gate |
| --- | --- | --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| `13ep-onecycle-default` | `g8a_13ep_onecycle_default_dev3_20260703T213903Z` | `false` | `train_dev` | `3` | `0.701400` | `0.696467` | `+0.004933` | `0.928871` | PASS |
| `13ep-onecycle-longwarm` | `g8a_13ep_onecycle_longwarm_dev3_20260703T213903Z` | `false` | `train_dev` | `3` | `0.708733` | `0.695933` | `+0.012800` | `0.931130` | PASS |

Per-seed evidence:

| Candidate | Seed | Order | Baseline acc | Candidate acc | Acc delta | Baseline time | Candidate time | Time ratio |
| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `13ep-onecycle-default` | `890000` | `baseline/candidate` | `0.6898` | `0.7048` | `+0.0150` | `20.7028` | `19.0409` | `0.9197` |
| `13ep-onecycle-default` | `890001` | `candidate/baseline` | `0.6980` | `0.7046` | `+0.0066` | `20.2824` | `18.8731` | `0.9305` |
| `13ep-onecycle-default` | `890002` | `baseline/candidate` | `0.7016` | `0.6948` | `-0.0068` | `20.3418` | `19.0474` | `0.9364` |
| `13ep-onecycle-longwarm` | `890000` | `baseline/candidate` | `0.6898` | `0.7080` | `+0.0182` | `20.2222` | `18.8279` | `0.9311` |
| `13ep-onecycle-longwarm` | `890001` | `candidate/baseline` | `0.6980` | `0.7076` | `+0.0096` | `20.2121` | `18.7985` | `0.9301` |
| `13ep-onecycle-longwarm` | `890002` | `baseline/candidate` | `0.7000` | `0.7106` | `+0.0106` | `20.2536` | `18.8819` | `0.9323` |

Both candidates satisfy the predeclared dev3 promotion gate. Prefer `13ep-onecycle-longwarm` for any dev10 follow-up because it has materially higher candidate mean train-dev accuracy and mean accuracy delta with nearly the same time ratio. No dev10 or official validation was launched in this workstream.

## Remote Artifacts

- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_default_dev3_20260703T213903Z/paired_summary.json`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_default_dev3_20260703T213903Z/stdout.log`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_default_dev3_20260703T213903Z/stderr.log`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev3_20260703T213903Z/paired_summary.json`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev3_20260703T213903Z/stdout.log`
- `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g8a_13ep_onecycle_longwarm_dev3_20260703T213903Z/stderr.log`

Only small curated summaries, order files, SLURM logs, and accounting were mirrored locally under `orchestration/g8-a-schedule/`; raw per-seed run directories remain on Leonardo.
