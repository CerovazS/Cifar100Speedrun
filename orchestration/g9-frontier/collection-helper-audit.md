# G9 Collection Helper Re-Audit

## Verdict: PASS

The corrected helper passes this local/static audit for safely collecting already-launched CINECA jobs `48463506` and `48463507` once SSH works. I found no remaining material instance of the prior BLOCK findings. I did not run `--execute` and did not SSH.

## Findings

### PASS: `COMPLETED` marker now requires paired artifacts and raw per-run evidence

- Severity: resolved prior blocker.
- Path: `orchestration/g9-frontier/collect_pending_jobs.sh:390-407`, `orchestration/g9-frontier/collection-protocol.md:123-129`.
- Evidence: for `state == "COMPLETED"`, the helper requires `paired_summary.json`, `paired_order.csv`, and at least `2 * RUNS` each of `config.json`, `metrics.csv`, `summary.json`, `warmup.json`, and `repro_metadata.json` before allowing `COLLECTION_COMPLETE.txt`.
- Consequence: a completed job cannot be marked collected from wrapper summaries alone; the raw artifacts needed for recomputation and critic review must be present locally.
- Proposed fix: none.

### PASS: same-second duplicate collection attempts no longer overwrite the same local directory

- Severity: resolved prior blocker.
- Path: `orchestration/g9-frontier/collect_pending_jobs.sh:53-55`, `271-285`, `orchestration/g9-frontier/collection-protocol.md:131-133`.
- Evidence: collection directory names include UTC timestamp plus `pid$$`, and execute mode creates the collection directory with `mkdir "$collection_dir"` rather than `mkdir -p "$collection_dir"`. If the exact directory already exists, the script aborts under `set -e`.
- Consequence: duplicate same-second attempts from separate invocations get distinct PID-stamped directories; exact-path reuse fails instead of overwriting metadata, logs, status, or pulled artifacts.
- Proposed fix: none.

### PASS: completion marker records rsync status and raw counts

- Severity: resolved prior blocker.
- Path: `orchestration/g9-frontier/collect_pending_jobs.sh:410-426`.
- Evidence: `COLLECTION_COMPLETE.txt` includes `REMOTE_OUTPUT_PRESENT`, `REMOTE_OUTPUT_RSYNC`, `SCHEDULER_LOG_RSYNC`, `EXPECTED_RAW_PER_RUN_COUNT`, `CONFIG_COUNT`, `METRICS_COUNT`, `SUMMARY_COUNT`, `WARMUP_COUNT`, and `REPRO_METADATA_COUNT`.
- Consequence: downstream auditors can tell whether output/log pulls succeeded and whether raw artifact counts met the expected paired-run threshold.
- Proposed fix: none.

### PASS: no launch/cancel/resubmission/delete/move/reset command path found

- Severity: no issue found.
- Path: `orchestration/g9-frontier/collect_pending_jobs.sh`.
- Evidence: targeted `rg` found `sbatch`, `scancel`, `rm`, `mv`, and `git reset` only in the final prose note at line 473. Executable remote command strings are limited to `sacct`, `test -d`, `find`, `stat`, and `sha256sum`; transfer commands are `rsync -av` pulls from remote paths into new local collection directories.
- Consequence: the helper does not launch, cancel, resubmit, delete, move, reset git state, or mutate remote state in the inspected command surface.
- Proposed fix: none.

## Missing Evidence Or Reproduction Gaps

- I did not run `--execute` and did not SSH, per audit requirements.
- Actual `sacct` state and remote artifacts for jobs `48463506` and `48463507` remain unverified.
- No pulled local output tree exists yet, so metric recomputation, config validation, commit validation, and result interpretation remain future critic work after collection.

## Claims

Safe to claim:

- The helper is dry-run by default and the dry-run does not call SSH.
- The helper is collection-only with respect to CINECA: no launch, cancel, resubmission, remote deletion, remote move, or remote git reset path was found.
- For `COMPLETED` jobs, `COLLECTION_COMPLETE.txt` is gated on paired summary/order plus raw config/metrics/summary/warmup/repro metadata counts of at least `2 * RUNS`.
- Execute-mode collection directories are unique per timestamp, PID, stream, and job id, and exact directory collisions fail instead of overwriting.
- The completion marker records output/log rsync status and raw artifact counts.

Not safe to claim yet:

- That either job completed, failed, or produced valid artifacts.
- That collected metrics support promotion, killing, record claims, or Flywheel logging.
- That raw configs and metadata match the intended official/train-dev semantics; this must be audited after collection.

## Trace

Commands run:

```bash
sed -n '1,240p' /Users/lucacerovaz/.codex/skills/critical-scientific-audit/SKILL.md
sed -n '1,260p' /Users/lucacerovaz/projects/agent-config/codex/SLURM.md
rg --files -g 'AGENTS.md' -g 'CLAUDE.md' -g 'DEV.md' -g 'CLUSTER.md' -g 'README.md' -g 'program.md'
sed -n '1,220p' README.md
sed -n '1,220p' program.md
sed -n '1,260p' orchestration/g9-frontier/collect_pending_jobs.sh
sed -n '261,520p' orchestration/g9-frontier/collect_pending_jobs.sh
sed -n '1,260p' orchestration/g9-frontier/collection-protocol.md
sed -n '1,260p' orchestration/g9-frontier/collection-helper-audit.md
nl -ba orchestration/g9-frontier/collect_pending_jobs.sh | sed -n '1,520p'
nl -ba orchestration/g9-frontier/collection-protocol.md | sed -n '1,220p'
bash -n orchestration/g9-frontier/collect_pending_jobs.sh
rg -n '\b(sbatch|scancel|rm|mv|git reset)\b' orchestration/g9-frontier/collect_pending_jobs.sh orchestration/g9-frontier/collection-protocol.md orchestration/g9-frontier/collection-helper-audit.md
rg -n '\b(ssh|rsync|sacct|squeue|find|stat|sha256sum|test|mkdir|cat|tee|cp|touch|chmod|chown|sed|awk)\b|>|>>' orchestration/g9-frontier/collect_pending_jobs.sh
rg -n 'COLLECTION_COMPLETE|completed_required_artifacts|expected_raw_count|CONFIG_COUNT|METRICS_COUNT|SUMMARY_COUNT|WARMUP_COUNT|REPRO_METADATA_COUNT|REMOTE_OUTPUT_RSYNC|SCHEDULER_LOG_RSYNC|mkdir "\$collection_dir"|COLLECTION_STAMP|pid\$\$' orchestration/g9-frontier/collect_pending_jobs.sh orchestration/g9-frontier/collection-protocol.md
bash orchestration/g9-frontier/collect_pending_jobs.sh
find orchestration/g8-b-muon/runtime-official-20260704T003556Z/collections orchestration/airbench-transfer/runtime-dev10-20260704T003552Z/collections -maxdepth 2 -type d -name '*pid62473*' -print
git status --short -- orchestration/g9-frontier/collect_pending_jobs.sh orchestration/g9-frontier/collection-protocol.md orchestration/g9-frontier/collection-helper-audit.md
rg -n 'sbatch|scancel|git reset|\brm\b|\bmv\b' orchestration/g9-frontier/collect_pending_jobs.sh
find orchestration -path '*collections/*pid62473*' -print
git diff -- orchestration/g9-frontier/collect_pending_jobs.sh orchestration/g9-frontier/collection-protocol.md orchestration/g9-frontier/collection-helper-audit.md
```

Files touched:

- Replaced `orchestration/g9-frontier/collection-helper-audit.md`.
- Did not edit `orchestration/g9-frontier/collect_pending_jobs.sh`.
- Did not edit `orchestration/g9-frontier/collection-protocol.md`.

Outputs produced:

- This re-audit report: `orchestration/g9-frontier/collection-helper-audit.md`.

Unresolved risks:

- SSH authentication and remote CINECA state were intentionally not tested.
- `COLLECTION_COMPLETE.txt` for failed/canceled terminal states still means terminal evidence collection, not successful run evidence; downstream logic must keep that distinction.
- Scientific interpretation remains blocked until artifacts are pulled and independently audited.
