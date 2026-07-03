# Control Patch Trace

## Objective

Close the first benchmark-control gaps before any CINECA GPU search:

- fix eager `C100_COMPILE=0` config-print crash
- propagate `TARGET` to the trainer as `C100_TARGET`
- stop masking official-baseline analyzer failures
- add optional machine-readable run artifacts
- add train-derived dev validation for search
- add a same-allocation paired comparison runner
- fix stale smoke documentation

## Files Touched

- `cifar100-benchmark/train_cifar100_resnet_muon.py`
- `slurm/discovery.sh`
- `slurm/official_baseline.sh`
- `slurm/paired_compare.sh`
- `README.md`
- `SMOKE_RESULT.md`
- `.gitignore`
- `program.md`
- `program/*.md`
- `orchestration/intake/*`
- `orchestration/implementation-control-patch/summary.md`

## Verification

Run after patch on 2026-07-03:

```bash
bash -n env_setup.sh
bash -n slurm/smoke.sh
bash -n slurm/discovery.sh
bash -n slurm/official_baseline.sh
bash -n slurm/paired_compare.sh
python3 - <<'PY'
import ast
from pathlib import Path
for p in sorted(Path("cifar100-benchmark").glob("*.py")):
    ast.parse(p.read_text(), filename=str(p))
    print(f"ast ok {p}")
PY
```

Result: all shell syntax checks passed; AST parsing passed for `analyze_cifar100.py`, `prepare_cifar100.py`, `prepare_cifar100_hf.py`, and `train_cifar100_resnet_muon.py`.

Read-only CINECA reachability check:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 leonardo 'hostname; whoami; pwd; printf "WORK=%s\nFAST=%s\nSCRATCH=%s\n" "$WORK" "$FAST" "$SCRATCH"'
```

Observed: `login01.leonardo.local`, user `lcerovaz`, `WORK=/leonardo_work/IscrC_SIMP`, `FAST=/leonardo_scratch/fast/IscrC_SIMP`, `SCRATCH=/leonardo_scratch/large/userexternal/lcerovaz`.

## Remaining Gates

- Run a critic audit on this implementation.
- Validate the CINECA environment interactively.
- Run current-default 30-run baseline only after the interactive smoke passes.

## G1b Control Patch Update

Implemented on 2026-07-03 without launching CINECA jobs.

### Files Touched In This Update

- `cifar100-benchmark/train_cifar100_resnet_muon.py`
- `slurm/paired_compare.sh`
- `README.md`
- `program/05-plan-audit.md`
- `orchestration/implementation-control-patch/summary.md`

### Controls Closed Or Downgraded

- Warmup official-test contamination: closed locally. Warmup calls `train_once(..., evaluate_validation=False)`, writes `warmup.json`, and is not appended to `metrics.csv`.
- Machine-readable reproducibility metadata: closed locally for G3 needs. Trainer writes `repro_metadata.json` with git SHA, branch, dirty status, tracked diff hash/path, repo URL when available, safe env/cache variables, Slurm env vars, and GPU metadata from torch plus `nvidia-smi` when available.
- Paired default official validation hazard: closed locally. `slurm/paired_compare.sh` defaults to `train_dev` and refuses `VALIDATION_SOURCE=official` unless `RECORD=1`.
- Candidate override loss: closed locally. Candidate invocations preserve `C100_*` overrides supplied through `CANDIDATE_ENV`; the summarizer exits if a non-empty candidate env leaves tracked training config identical to baseline.
- Block A/B/B/A order: downgraded for G4 pilot. The runner alternates AB/BA per seed and records `paired_order.csv`; remaining G6 limitation is that this invokes the trainer once per method/seed and may need a more efficient pre-registered final runner.

### Verification Commands

```bash
for f in $(rg --files -g '*.sh'); do bash -n "$f"; echo "bash -n ok $f"; done
python3 - <<'PY'
import ast
from pathlib import Path
for p in sorted(Path('cifar100-benchmark').glob('*.py')):
    ast.parse(p.read_text(), filename=str(p))
    print(f'ast ok {p}')
PY
python3 - <<'PY'
from pathlib import Path
train = Path('cifar100-benchmark/train_cifar100_resnet_muon.py').read_text()
paired = Path('slurm/paired_compare.sh').read_text()
checks = {
    'warmup validation skipped': 'evaluate_validation=False' in train,
    'warmup kept out of metrics csv': 'write_json(output_dir / "warmup.json", warmup)' in train and 'append_metrics(output_dir / "metrics.csv", warmup)' not in train,
    'repro metadata writer present': 'def write_repro_metadata' in train and 'repro_metadata.json' in train and 'git_diff.patch' in train,
    'metadata includes safe hf/cache env': 'HF_' in train and 'TRANSFORMERS_CACHE' in train and '<redacted>' in train,
    'paired default train_dev': 'VALIDATION_SOURCE=${VALIDATION_SOURCE:-train_dev}' in paired,
    'paired official record gate': 'VALIDATION_SOURCE" == "official"' in paired and 'RECORD" != "1"' in paired,
    'candidate c100 override preserved': 'C100_MUON_LR=${C100_MUON_LR:-${MUON_LR:-0.035}}' in paired,
    'per-seed order file': 'paired_order.csv' in paired and 'for ((i = 0; i < RUNS; i++))' in paired,
    'candidate equality failure': 'candidate config matches baseline' in paired,
}
failed = [name for name, ok in checks.items() if not ok]
for name, ok in checks.items():
    print(f'{"ok" if ok else "FAIL"}: {name}')
if failed:
    raise SystemExit('failed checks: ' + ', '.join(failed))
PY
python3 - <<'PY'
import subprocess, tempfile, textwrap
sample = textwrap.dedent('''
|  warmup  |   eval  |     0.1234  |    skipped  |      skipped  |      1.0000  |
|       1  |   eval  |     0.9000  |   0.7100  |       1.0000  |      25.0000  |
|       2  |   eval  |     0.9100  |   0.7050  |       1.0000  |      26.0000  |
''')
with tempfile.NamedTemporaryFile('w', delete=False) as f:
    f.write(sample)
    name = f.name
result = subprocess.run(['python3', 'cifar100-benchmark/analyze_cifar100.py', name, '--target', '0.70'], text=True, capture_output=True)
print('returncode', result.returncode)
print(result.stdout, end='')
print(result.stderr, end='')
raise SystemExit(result.returncode)
PY
```

Results: all shell syntax checks passed; AST parsing passed for all benchmark scripts; targeted static checks passed; analyzer compatibility with skipped warmup plus two real rows passed.

### Outputs Produced

No run outputs were produced. Only source/docs/trace files were edited.

## G1b Audit Follow-up Update

Implemented on 2026-07-03 without launching jobs.

### Files Touched In This Update

- `slurm/smoke.sh`
- `slurm/paired_compare.sh`
- `README.md`
- `program/05-plan-audit.md`
- `orchestration/implementation-control-patch/summary.md`

### Controls Closed

- G2 smoke now uses `C100_VALIDATION_SOURCE=train_dev`, so environment smoke avoids official validation exposure.
- `slurm/paired_compare.sh` keeps non-record pilots at `VALIDATION_SOURCE=train_dev RUNS=10`, but `RECORD=1` now defaults to `VALIDATION_SOURCE=official RUNS=30` and refuses any other record-mode run count.
- README and the plan audit now state that G6 cannot be interpreted as a 10-run record.

### Verification Commands

```bash
for f in $(rg --files -g '*.sh'); do bash -n "$f"; echo "bash -n ok $f"; done
git diff --check
```

Results: all shell syntax checks passed for every `.sh` file; `git diff --check` passed.
