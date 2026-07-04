# G8-B ns3_mom93 Dev10 Train-Dev Follow-up Result

## Active Objective And Success Criteria

Launch and babysit one bounded G8-B `ns3_mom93` dev10 train-dev follow-up from the main CIFAR-100 speedrun worktree after the prior critic PASS, without Flywheel or Linear mutation.

Success criteria: sync the committed `fdb65d9` launch surface to the Leonardo checkout, verify remote preflight, launch with `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `RUNS=10`, `C100_DEV_PER_CLASS=50`, `C100_DEV_SPLIT_SEED=20260703`, a unique `RUN_ID`, no official validation, no output reuse, babysit to completion/failure, mirror raw artifacts locally, recompute metrics from raw files, and make a promote/hold/kill recommendation.

## Run Identity

- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Local committed base: `fdb65d9183193648a95f36980ec1875069a153c3`
- Remote branch/head during launch: `codex/cifar100-speedrun-control` / `2c3edb798dc27d512109a7c49eb8ede82b84c023`
- Run ID: `g8b_ns3_mom93_longwarm_dev10_20260704T000009Z`
- Job ID: `48460378`
- State: `COMPLETED`, exit `0:0`, elapsed `00:15:39`, node `lrdn2086`
- Base seed: `893600`
- Output root: `outputs/cifar100_speedrun/g8b_ns3_mom93_longwarm_dev10_20260704T000009Z`

## Launch Configuration

Baseline env:

```text
C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0
```

Candidate env:

```text
C100_EPOCHS=13 C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.40 C100_ONECYCLE_DIV_FACTOR=10.0 C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93
```

Explicit wrapper exports: `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `RUNS=10`, `C100_DEV_PER_CLASS=50`, `C100_DEV_SPLIT_SEED=20260703`, `EPOCHS=13`, `TARGET=0.70`.

## Preflight

- Synced tracked files from local commit `fdb65d9` to the remote checkout with `git archive ... | ssh ... tar -xf -`.
- Verified remote hashes for `slurm/paired_compare.sh`, `cifar100-benchmark/train_cifar100_resnet_muon.py`, `cifar100-benchmark/prepare_cifar100_hf.py`, `env_setup.sh`, `pyproject.toml`, and `uv.lock` matched local `fdb65d9` blobs.
- Verified output root was absent before launch.
- Verified no active jobs for `lcerovaz`.
- Ran `bash -n slurm/paired_compare.sh`.
- Ran `python3 -m py_compile train_cifar100_resnet_muon.py` inside the remote venv after `source env_setup.sh`.

Full preflight record: `remote-preflight.txt`.

## Metrics

| Metric | Baseline | Candidate | Delta / Ratio |
|---|---:|---:|---:|
| Paired seeds | 10 | 10 | - |
| Target hits | 7/10 | 10/10 | +3 hits |
| Mean train-dev accuracy | 0.704320 | 0.709700 | +0.005380 |
| Mean timed train seconds | 18.991114 | 17.698636 | -1.292478 |
| Mean time ratio | - | - | 0.931954 |
| Median time ratio | - | - | 0.929719 |

Decision criterion recorded before launch: promote if candidate mean train-dev accuracy is at least baseline mean minus `0.002` and candidate mean time ratio is below `0.95` over 10 paired seeds.

The candidate passes this criterion: `0.709700 >= 0.704320 - 0.002` and `0.931954 < 0.95`.

## Recommendation

Promote `g8b_ns3_mom93_longwarm_dev10_20260704T000009Z` as the next train-dev G8-B candidate. It is faster on every paired seed, hits the train-dev target on all 10 candidate seeds, and improves mean train-dev accuracy over the baseline in this sample.

Do not treat this as official validation, finalist, or record evidence. Official validation is not approved for this run.

## Evidence

- Recomputed verification: `verification.json`
- Per-seed table: `metrics-table.tsv`
- Wrapper summary mirror: `paired_summary.json`
- Order mirror: `paired_order.csv`
- Scheduler accounting and remote dirty status: `sacct-48460378.txt`
- SLURM stdout/stderr: `paired-48460378.out`, `paired-48460378.err`
- Full mirrored run artifacts: `remote-artifacts/`
- SLURM log mirrors: `slurm-logs/`
- Babysitting trace: `job-watch.txt`
- Submission command: `submit.txt`
- Independent result critic: `critic.md`

## Remote Dirty Status

After artifact pull, the remote checkout remained dirty relative to remote head `2c3edb7`. Tracked dirty files reported by `git status --short` were:

```text
 M cifar100-benchmark/train_cifar100_resnet_muon.py
 M orchestration/g7-official-onecycle/trace.md
 M program.md
 M slurm/paired_compare.sh
```

There were also unrelated untracked orchestration and top-level files. This was expected because the run synced the local committed `fdb65d9` tracked snapshot over a remote checkout whose branch head was older. Relevant launch-file hashes were verified against `fdb65d9` before launch.

## Residual Risks

- This is still train-dev search evidence only and may not transfer to official CIFAR-100 test validation.
- The 10-seed sample is stronger than dev3 but still not final record evidence.
- Remote checkout dirtiness is controlled for launch files by hash verification, but the checkout is not a clean Git checkout of `fdb65d9`.
- The paired wrapper is pilot-grade and alternates separate trainer invocations per method/seed, not a final optimized official runner.

## Critic Verdict

Independent result audit passed for the train-dev promote/hold/kill decision. The allowed claim is limited to exploratory train-dev promotion. The audit specifically rejects official validation, finalist, record, or test-set claims from this run.
