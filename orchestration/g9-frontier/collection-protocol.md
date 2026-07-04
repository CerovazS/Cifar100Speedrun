# Pending CINECA Job Collection Protocol

## Purpose

Collect the two already-launched Leonardo jobs exactly once after SSH authentication works again:

| Stream | Job | Run id | Mode | Remote checkout |
| --- | ---: | --- | --- | --- |
| G8-B official `ns3_mom93` | `48463506` | `g8b_ns3_mom93_official_20260704T003556Z` | `RECORD=1`, `VALIDATION_SOURCE=official`, `RUNS=30` | `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun-g8b-official-clean` |
| AirBench dev10 | `48463507` | `airbench_aug_pad2_alt_dev10_20260704T003552Z` | `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `RUNS=10` | `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun-airbench-transfer` |

This protocol is collection-only. It does not launch, cancel, resubmit, recompute, promote, kill, or interpret either run.

## Preconditions

- Leonardo SSH authentication is restored for the local alias `leonardo`, or pass another alias with `--host`.
- Run from the main repository root:

```bash
cd "/Users/lucacerovaz/Documents/Cifar100 Speedrun"
```

- Do not run `sbatch`, `scancel`, `rm`, `mv`, `git reset`, or any other remote mutation as part of collection.
- Do not resubmit either job unless `sacct` first proves the original job failed or was canceled and a new unique run id/output directory is pre-registered later.

## Usage

Validate the helper locally:

```bash
bash -n orchestration/g9-frontier/collect_pending_jobs.sh
```

Preview the collection plan. This is the default and does not call SSH:

```bash
bash orchestration/g9-frontier/collect_pending_jobs.sh
```

Collect both jobs after SSH works:

```bash
bash orchestration/g9-frontier/collect_pending_jobs.sh --execute
```

Collect only one stream if needed:

```bash
bash orchestration/g9-frontier/collect_pending_jobs.sh --execute --only g8
bash orchestration/g9-frontier/collect_pending_jobs.sh --execute --only airbench
```

Use a different SSH alias only if it points to the same Leonardo account and filesystem view:

```bash
bash orchestration/g9-frontier/collect_pending_jobs.sh --execute --host leonardo01
```

## What The Helper Runs

Remote commands are limited to non-mutating inspection and pull operations:

- `sacct` for scheduler state.
- `test` to check whether the expected remote output directory exists.
- `find` for output, scheduler-log, and checkout manifests.
- `stat` for remote file size/time metadata.
- `sha256sum` through `find -exec` when available on Leonardo.
- `rsync` pulls from remote to local timestamped collection directories.

The helper intentionally does not call `squeue`, `cat`, `tail`, `git`, `sbatch`, `scancel`, `rm`, `mv`, or any remote write command.

## Expected Local Outputs

Each execute-mode run writes a new timestamped collection folder under the existing runtime directory, so older artifacts are never overwritten.

G8-B official:

```text
orchestration/g8-b-muon/runtime-official-20260704T003556Z/collections/<timestamp>-pid<PID>-g8-48463506/
  metadata.env
  collection_status.md
  COLLECTION_COMPLETE.txt        # only when terminal state and pulls succeeded; COMPLETED also needs paired and raw per-run artifacts
  remote_checks/
    sacct-48463506.txt
    output-manifest.txt
    output-stat.tsv
    output-sha256.tsv
    scheduler-log-manifest.txt
    checkout-manifest.txt
  remote_outputs/g8b_ns3_mom93_official_20260704T003556Z/
  scheduler_logs/logs/paired-48463506.out
  scheduler_logs/logs/paired-48463506.err
  rsync_logs/
```

AirBench dev10:

```text
orchestration/airbench-transfer/runtime-dev10-20260704T003552Z/collections/<timestamp>-pid<PID>-airbench-48463507/
  metadata.env
  collection_status.md
  COLLECTION_COMPLETE.txt        # only when terminal state and pulls succeeded; COMPLETED also needs paired and raw per-run artifacts
  remote_checks/
    sacct-48463507.txt
    output-manifest.txt
    output-stat.tsv
    output-sha256.tsv
    scheduler-log-manifest.txt
    checkout-manifest.txt
  remote_outputs/airbench_aug_pad2_alt_dev10_20260704T003552Z/
  scheduler_logs/logs/paired-48463507.out
  scheduler_logs/logs/paired-48463507.err
  rsync_logs/
```

The status file should make one of these states obvious:

- job still running or pending;
- job failed, canceled, timed out, or otherwise terminal;
- job completed but required artifacts are missing;
- job completed and required artifacts were pulled.

For `COMPLETED` jobs, the helper writes `COLLECTION_COMPLETE.txt` only after the
remote output pull includes both `paired_summary.json` and `paired_order.csv`, plus
at least `2 * RUNS` each of `config.json`, `metrics.csv`, `summary.json`,
`warmup.json`, and `repro_metadata.json`. Terminal failed/canceled jobs may still
receive a completion marker when the terminal scheduler evidence and available logs
were collected, because that is complete failure evidence and should be preserved
before any later rerun decision.

Collection directory names include a UTC timestamp and local process id. Execute mode
uses a non-overwriting `mkdir` for the collection folder, so a same-second accidental
duplicate fails instead of overwriting prior local collection files.

## Expected Raw Artifacts

When present remotely, the pulled run output should include:

- `paired_summary.json`
- `paired_order.csv`
- `stdout.log`
- `stderr.log`
- per-run `config.json`
- per-run `metrics.csv`
- per-run `summary.json`
- per-run `warmup.json`
- per-run `repro_metadata.json`
- per-run `git_diff.patch` where generated

Scheduler logs are also pulled from:

- `logs/paired-48463506.out`
- `logs/paired-48463506.err`
- `logs/paired-48463507.out`
- `logs/paired-48463507.err`

## No-Resubmission Rule

These jobs were already launched and observed running:

- `48463506` on `lrdn0042`
- `48463507` on `lrdn1864`

Do not launch a replacement, cancel either job, or clean remote outputs during collection. If `sacct` shows a failed/canceled terminal state, preserve the failure evidence first. Any future rerun requires a separate pre-registration with a new run id and a new output directory.

## Next Steps After Collection

After `COLLECTION_COMPLETE.txt` exists for a stream:

1. Recompute paired metrics from raw `metrics.csv` files. Do not trust wrapper summaries alone.
2. Verify config semantics from raw `config.json` and `repro_metadata.json`.
3. For G8-B official, verify `RECORD=1`, `VALIDATION_SOURCE=official`, official train/test split sizes, clean checkout commit `4ba08a7b3fea1652411a3adcabddc33fb2821ffe`, no validation path edits, no TTA/adaptation, and candidate-only `C100_NS_STEPS=3 C100_MUON_MOMENTUM=0.93`.
4. For AirBench dev10, verify `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `C100_DEV_PER_CLASS=50`, `C100_DEV_SPLIT_SEED=20260703`, common longwarm schedule, candidate-only `C100_TRANSLATE_PAD=2 C100_FLIP_MODE=alternating`, and provenance hash consistency.
5. Delegate an independent result critic before any promote, kill, additive launch, official claim, Flywheel logging, or Linear logging decision.

## Trace

This protocol was prepared from:

- `program.md`
- `orchestration/g9-frontier/trajectory-plan.md`
- `orchestration/g8-b-muon/runtime-official-20260704T003556Z/trace.md`
- `orchestration/g8-b-muon/runtime-official-20260704T003556Z/blocked.md`
- `orchestration/airbench-transfer/runtime-dev10-20260704T003552Z/trace.md`
- `/Users/lucacerovaz/Documents/Cifar100 Speedrun-worktrees/airbench-transfer/orchestration/airbench-transfer/runtime-dev10-20260704T003552Z/trace.md`
- `/Users/lucacerovaz/projects/agent-config/codex/SLURM.md`
