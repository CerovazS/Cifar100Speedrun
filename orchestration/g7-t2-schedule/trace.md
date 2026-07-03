# G7-T2 One-Cycle Schedule Trace

## Claim

A one-cycle LR schedule can improve 14-epoch train-dev accuracy enough to make schedule compression viable, without touching validation semantics or timing boundaries.

## Hypothesis

The prior 14-epoch cosine schedule reached about `0.697` train-dev mean and scalar LR sweeps did not recover enough margin. A one-cycle schedule with a lower initial LR and late anneal may improve optimization at the same 14-epoch step count while preserving or slightly improving timed training.

## Decision Criterion

Run two predeclared schedule candidates as separate paired train-dev dev3 workstreams. Promote a candidate to dev10 only if all checks pass:

- job completed `0:0`;
- `record_mode=false`;
- `validation_source=train_dev`;
- `paired_seeds=3`;
- candidate differs only on declared schedule fields and optional LR fields;
- candidate mean train-dev accuracy `>= 0.700`;
- mean validation accuracy delta `>= +0.0025` against paired 14-epoch cosine control;
- mean time ratio `<= 1.03`.

Kill otherwise. No official validation from G7-T2 before dev10 and critic pass.

## Candidates

| Candidate | Run id | Env |
| --- | --- | --- |
| onecycle-default | `g7t2_onecycle_default_dev3_20260703T193834Z` | `C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0` |
| onecycle-highlr | `g7t2_onecycle_highlr_dev3_20260703T193834Z` | `C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0 C100_MUON_LR=0.045 C100_BIAS_LR=0.026` |

Both use `EPOCHS=14`, `RUNS=3`, `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `BASE_SEED=880000`.

## Implementation Status

- Trainer schedule knobs implemented locally:
  - `C100_LR_SCHEDULE=cosine|onecycle`
  - `C100_ONECYCLE_PCT_UP`
  - `C100_ONECYCLE_DIV_FACTOR`
- Default `cosine` keeps the previous formula.
- Paired wrapper support implemented locally for allowlist, env-to-field mapping, and compare fields.

## Commands

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
test ! -e outputs/cifar100_speedrun/g7t2_onecycle_default_dev3_20260703T193834Z
RUN_ID=g7t2_onecycle_default_dev3_20260703T193834Z \
RECORD=0 \
RUNS=3 \
EPOCHS=14 \
VALIDATION_SOURCE=train_dev \
BASE_SEED=880000 \
CANDIDATE_ENV='C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0' \
sbatch slurm/paired_compare.sh
```

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
test ! -e outputs/cifar100_speedrun/g7t2_onecycle_highlr_dev3_20260703T193834Z
RUN_ID=g7t2_onecycle_highlr_dev3_20260703T193834Z \
RECORD=0 \
RUNS=3 \
EPOCHS=14 \
VALIDATION_SOURCE=train_dev \
BASE_SEED=880000 \
CANDIDATE_ENV='C100_LR_SCHEDULE=onecycle C100_ONECYCLE_PCT_UP=0.30 C100_ONECYCLE_DIV_FACTOR=10.0 C100_MUON_LR=0.045 C100_BIAS_LR=0.026' \
sbatch slurm/paired_compare.sh
```

## Stop Conditions

Do not launch until trainer and wrapper patches are committed/synced to the remote scratch checkout, remote `bash -n` and trainer compile checks pass, output dirs are absent, and a critic approves the plan.
