# G9 Recompute Helper Audit

## Verdict

PASS. The local recompute verifier is safe to use as a non-remote recomputation and validation tool for future paired artifact collections from jobs `48463506` and `48463507`, provided callers pass the expected validation source, expected record mode, and expected paired seed count for the collection being checked.

## Findings

### No Blocking Findings

No blocker was found in the inspected script, protocol, or fixture behavior.

### Confirmed: Local-only, stdlib-only implementation

- Severity: pass
- Artifact: `orchestration/g9-frontier/recompute_paired_metrics.py`
- Evidence: imports are limited to `__future__`, `argparse`, `csv`, `dataclasses`, `json`, `math`, `pathlib`, `re`, `shutil`, `statistics`, `sys`, and `typing`; all resolve to the Python standard library or built-ins. `python3 -m py_compile` passed.
- Evidence: text search found no `ssh`, `rsync`, `scp`, `sftp`, `subprocess`, `os.system`, `Popen`, `paramiko`, `fabric`, `requests`, `urllib`, `socket`, or HTTP/network call surface in the verifier. The only `remote` mentions are protocol/path language.
- Consequence: the helper does not launch jobs, call Leonardo, pull artifacts, mutate remote state, or depend on non-stdlib packages.
- Proposed fix: none.

### Confirmed: Recomputes metrics from raw per-run `metrics.csv`

- Severity: pass
- Artifact: `orchestration/g9-frontier/recompute_paired_metrics.py`
- Evidence: `load_metrics()` requires exactly one CSV row and required values for `seed`, `val_acc`, `target_hit`, and `time_seconds`; `RunArtifact` properties read these values from `metrics.csv`; pair deltas, ratios, and summaries are recomputed from those per-run values. `paired_summary.json` is loaded only after recomputation and compared against recomputed values.
- Evidence: tampering only `paired_summary.json` in a `/tmp` copy failed with `paired_summary mean_time_ratio=999.0 does not match recomputed 0.9319536432175068` and `paired_summary seed 893600 baseline_val_acc=999.0 does not match recomputed 0.7008`.
- Consequence: a stale or edited `paired_summary.json` cannot silently drive the recomputed metric outputs.
- Proposed fix: none.

### Confirmed: Required raw artifacts are enforced

- Severity: pass
- Artifact: `orchestration/g9-frontier/recompute_paired_metrics.py`
- Evidence: `REQUIRED_RUN_FILES` requires `metrics.csv`, `config.json`, `summary.json`, `warmup.json`, and `repro_metadata.json` for each run directory. Removing `seed0001_A_baseline/metrics.csv` in a `/tmp` fixture copy produced status `fail`, return code `1`, and failures for the missing raw artifact, incomplete pair, missing paired order entry, reduced recomputed paired seed count, and summary mismatches.
- Consequence: incomplete collections do not pass.
- Proposed fix: none.

### Confirmed: Expected validation source, record mode, and paired count checks are meaningful

- Severity: pass with one caveat
- Artifact: `orchestration/g9-frontier/recompute_paired_metrics.py`
- Evidence: expected validation source is checked against per-run `config.json` values and per-run `repro_metadata.json` environment value `C100_VALIDATION_SOURCE`; wrong expected validation source failed on both channels and on `paired_summary.json`.
- Evidence: expected paired seed count is checked against recomputed pair count and, when present, `paired_summary.json`; wrong expected count failed on both.
- Evidence: expected record mode is checked for presence and value in `paired_summary.json`; wrong expected record mode failed.
- Caveat: in the inspected fixtures, `record_mode` is present only in `paired_summary.json`; no per-run `config.json` or `repro_metadata.json` record-mode key was available for an independent raw-artifact cross-check. This is acceptable for the verifier's current role as a recompute helper, but a final record audit should still require wrapper/provenance evidence or future per-run `RECORD` metadata if record-mode provenance becomes contested.
- Proposed fix: optional future hardening only: write `RECORD` or equivalent mode metadata into each run's `repro_metadata.json` and have the verifier cross-check it.

### Confirmed: Fixture success paths pass cleanly

- Severity: pass
- Artifacts:
  - `orchestration/g8-official-longwarm/remote-artifacts`
  - `orchestration/g8-b-muon/runtime-dev10-20260704T000009Z/remote-artifacts`
- Evidence: official fixture command passed with zero failures and zero warnings. Output summary: paired seeds `30`, mean validation accuracy delta `0.005153333333333328`, mean time ratio `0.8042445679385675`, and `30` TSV rows.
- Evidence: train-dev fixture command passed with zero failures and zero warnings. Output summary: paired seeds `10`, mean validation accuracy delta `0.005379999999999996`, mean time ratio `0.9319536432175068`, and `10` TSV rows.
- Consequence: the documented protocol commands work on both supplied fixture collections without warnings.
- Proposed fix: none.

### Confirmed: Existing output directories fail unless explicitly forced

- Severity: pass
- Artifact: `orchestration/g9-frontier/recompute_paired_metrics.py`
- Evidence: running with an existing `/tmp` output directory and no `--force` returned code `2` and printed `ERROR: output directory already exists`.
- Consequence: accidental output reuse is prevented by default.
- Proposed fix: none.

### Confirmed: No promotion or record-result claims are emitted

- Severity: pass
- Artifact: `orchestration/g9-frontier/recompute_paired_metrics.py`, `orchestration/g9-frontier/recompute-protocol.md`
- Evidence: search found no promotion language and no winner/beat/claim language in the verifier. The only record-related surface is the expected `record_mode` validation argument and recorded expected value.
- Consequence: the helper validates and recomputes artifacts but does not promote candidates, declare records, or make scientific conclusions beyond pass/fail verification.
- Proposed fix: none.

## Missing Evidence Or Reproduction Gaps

- The actual future collections from jobs `48463506` and `48463507` were not available in this audit; only the supplied fixture directories were exercised.
- `record_mode` is not independently recoverable from per-run raw metadata in the inspected fixtures. Treat it as collection-level metadata until the training wrapper writes a per-run record flag.
- I did not test `--force`, because the requested safety property was default failure on existing output directories.

## Safe And Unsafe Claims

Safe claims:
- The verifier is local-only and stdlib-only.
- It recomputes paired metrics from raw per-run `metrics.csv`.
- It checks required raw per-run files before accepting a collection.
- It fails on wrong expected validation source, wrong expected record mode, wrong expected paired seed count, missing required raw files, tampered paired summary values, and default output directory reuse.
- The two supplied fixture collections pass with zero warnings and zero failures.

Unsafe claims:
- Do not claim the helper alone proves a new record or promotion decision.
- Do not claim `record_mode` is independently verified from per-run raw artifacts in the current fixture schema.
- Do not claim jobs `48463506` or `48463507` pass until their actual collected artifacts are run through the verifier and independently audited.

## Trace

Commands run:
- `sed -n '1,240p' /Users/lucacerovaz/.codex/skills/critical-scientific-audit/SKILL.md`
- `sed -n '1,260p' /Users/lucacerovaz/.codex/skills/scientific-automation-pipeline/SKILL.md`
- `sed -n '1,260p' orchestration/g9-frontier/recompute_paired_metrics.py`
- `sed -n '261,620p' orchestration/g9-frontier/recompute_paired_metrics.py`
- `sed -n '1,260p' orchestration/g9-frontier/recompute-protocol.md`
- `rg --files -g '*.md' -g '!orchestration/g9-frontier/recompute-helper-audit.md'`
- `sed -n '1,220p' README.md`
- `sed -n '1,220p' program.md`
- `rg -n "ssh|rsync|scp|sftp|subprocess|os\\.system|Popen|paramiko|fabric|requests|urllib|socket|http|remote|promotion|promote|record|paired_summary|metrics\\.csv|validation|expected|warnings|failures" orchestration/g9-frontier/recompute_paired_metrics.py orchestration/g9-frontier/recompute-protocol.md`
- `python3 -m py_compile orchestration/g9-frontier/recompute_paired_metrics.py`
- `find .../remote-artifacts -maxdepth 2 -type f`
- Python AST/import-origin inspection for verifier imports.
- Official fixture verifier run into `/tmp/c100-recompute-audit-official.RPMY3h/out`.
- Train-dev fixture verifier run into `/tmp/c100-recompute-audit-dev10.TAGCTp/out`.
- Existing output directory negative test under `/tmp/c100-recompute-audit-existing-out.Zl5ZwJ`.
- Wrong expected metadata/count negative test under `/tmp/c100-recompute-audit-wrong-expected.eyH7T2/out`.
- Missing raw artifact negative test under `/tmp/c100-recompute-audit-missing-raw.5FXSUN/out`.
- Tampered `paired_summary.json` negative test under `/tmp/c100-recompute-audit-tampered-summary.10Jh1x/out`.
- `rg -n "record claim|record|promot|promote|promotion|claim|winner|beat" orchestration/g9-frontier/recompute_paired_metrics.py orchestration/g9-frontier/recompute-protocol.md`
- `git status --short`

Files touched:
- Added `orchestration/g9-frontier/recompute-helper-audit.md`.
- Temporary copies and verifier outputs were created only under `/tmp`.

Outputs produced:
- This audit report.
- `/tmp` verifier outputs listed above, including `verification.json` and `metrics-table.tsv` for success and negative-control runs.

Unresolved risks:
- Future job artifacts can still fail for collection/provenance reasons outside this verifier's scope, such as wrong remote path, incomplete copy, stale Slurm logs, dirty checkout, or missing final scheduler evidence.
- A final record-facing result still needs a separate scientific result audit over actual artifacts, configs, raw metrics, provenance, and claim wording.
