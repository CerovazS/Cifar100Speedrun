# G9 Paired Metrics Recompute Protocol

## Purpose

`recompute_paired_metrics.py` is a local-only verifier for already-collected paired
CIFAR-100 speedrun artifacts. It recomputes accuracy, timing, deltas, ratios, target
hits, and pair counts from raw per-run `metrics.csv` files, then validates local
artifact presence and expected mode metadata. It does not call SSH, inspect Slurm, or
mutate remote state.

## Expected Input

Point `--run-root` at a local artifact directory containing:

```text
paired_summary.json          # optional, compared when present
paired_order.csv             # used for order validation when present
seed0001_A_baseline/
seed0001_B_candidate/
seed0002_A_candidate/
seed0002_B_baseline/
...
```

Each per-run directory must contain:

```text
metrics.csv
config.json
summary.json
warmup.json
repro_metadata.json
```

The verifier fails if required per-run raw artifacts are missing, if baseline/candidate
pairs are incomplete, if supplied expected values mismatch, or if `paired_summary.json`
disagrees with recomputed raw metrics.

## Usage

Official 30-run fixture:

```bash
python3 orchestration/g9-frontier/recompute_paired_metrics.py \
  --run-root orchestration/g8-official-longwarm/remote-artifacts \
  --out-dir /tmp/cifar100-verify-official \
  --expected-validation-source official \
  --expected-record-mode true \
  --expected-paired-seeds 30
```

Train-dev 10-run fixture:

```bash
python3 orchestration/g9-frontier/recompute_paired_metrics.py \
  --run-root orchestration/g8-b-muon/runtime-dev10-20260704T000009Z/remote-artifacts \
  --out-dir /tmp/cifar100-verify-dev10 \
  --expected-validation-source train_dev \
  --expected-record-mode false \
  --expected-paired-seeds 10
```

Use `--force` only to overwrite verifier outputs in an existing `--out-dir`. The
script never deletes or rewrites files under `--run-root`.

## Outputs

The output directory receives:

- `verification.json`: status, failures, warnings, expected values, recomputed summary,
  summary comparison, and per-pair rows.
- `metrics-table.tsv`: one tab-separated row per paired seed, using raw metrics values.

`status` is `pass` only when there are no failures. Warnings are recorded for
non-decisive anomalies such as absent optional `paired_summary.json` or absent
`paired_order.csv`.
