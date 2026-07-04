# Validation Compliance Current Audit

## Findings

- **No blocker found:** local evidence reviewed does not show any accepted record/finalist claim using `train_dev`.
- **Open risk:** G8-B official job `48463506` was correctly pre-registered and observed running, but terminal scheduler state and artifacts are uncollected because Leonardo SSH authentication failed. It is not yet result evidence.
- **Governance finding:** documented cancellations were for rule-compliance/governance failures: old/wrong launch paths, unreviewed launch surfaces, missing finalist gates, or unpinned split identity. The policy reset explicitly says compliant official workstreams should not be interrupted merely because they use official validation.

## Authoritative Evidence

- Repository policy: `README.md:68-70` requires exploratory search to use `C100_VALIDATION_SOURCE=train_dev` and record evidence to use default `C100_VALIDATION_SOURCE=official`.
- Hard validation rules: `README.md:78-82` fixes official CIFAR-100 test as validation for records, forbids validation images/labels in training control, requires one plain forward pass, and excludes validation from timing.
- Prep behavior: `prepare_cifar100_hf.py:53-59` honors `C100_PREP_SPLITS`; `paired_compare.sh:33-38` runs `C100_PREP_SPLITS=train,test` only for `RECORD=1`, otherwise train only.
- Trainer split behavior: `train_cifar100_resnet_muon.py:480-504` defaults to `official`, loads `test` for official validation, and constructs a train-derived dev split for `train_dev`; `train_cifar100_resnet_muon.py:526-529` records dev metadata only for `train_dev` and logs train/eval sizes.
- Wrapper guardrails: `paired_compare.sh:51-64` refuses `RECORD=1` without official validation, refuses `RECORD=1` unless `RUNS=30`, and refuses official validation unless `RECORD=1`.
- Official completed evidence:
  - G3 baseline job `48402781`: `orchestration/g7-validation-policy-reset/summary.md:23-27` records official validation, 30 runs, mean official validation accuracy `0.7076033353805542`.
  - G7 official one-cycle job `48439897`: `orchestration/g7-official-onecycle/result.md:11-21` records completed official 30-run paired evidence; `result.md:38-43` passes `record_mode=true`, `validation_source=official`, `paired_seeds=30`, and official train/test split prep.
  - G8 official longwarm job `48449520`: `orchestration/g8-official-longwarm/result.md:11-21` records completed official 30-run paired evidence; `result.md:38-43` passes `record_mode=true`, `validation_source=official`, `paired_seeds=30`, and official train/test split prep.
- G8-B official clean checkout:
  - Pre-registration: `orchestration/g8-b-muon/runtime-official-20260704T003556Z/trace.md:18-26`.
  - Launch env: `trace.md:42-52` and `submit.txt:1-2` show `RECORD=1 VALIDATION_SOURCE=official RUNS=30` and job `48463506`.
  - Preflight: `trace.md:74-77` and `blocked.md:7-17` show clean commit, absent output root, syntax/compile checks, train `50000` and test `10000`, and early official train/test stdout.
  - Block: `blocked.md:35-48` lists missing terminal `sacct`, summary/order files, raw configs/metrics, recomputation, and critic; do not resubmit before verifying failed/canceled.
- `train_dev` evidence:
  - README rationale: `README.md:68` says `train_dev` is a fixed train-derived holdout with `C100_DEV_PER_CLASS=50` and `C100_DEV_SPLIT_SEED=20260703`, for candidate search only.
  - G8-B dev10 job `48460378`: `orchestration/g8-b-muon/runtime-dev10-20260704T000009Z/result.md:5-8` and `result.md:34` explicitly require `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `RUNS=10`, fixed dev split settings, no official validation.
  - Same result explicitly rejects official/record use: `result.md:64-67` and `critic.md:18,34`.
  - Local paired summary sweep found completed official summaries with `record_mode=true`, `validation_source=official`, `paired_seeds=30`, while train-dev summaries are `record_mode=false`.
- Cancellations/interruption:
  - Job `48410889` canceled after `00:01:52`; job `48410752` failed after `00:00:03`; invalid because it used an old PAERLE/YENDRI path, attempted 30-run official comparisons without finalist preregistration/critic approval, touched official test during search, and bypassed active wrapper controls (`orchestration/control-incidents/2026-07-03-official-candidate-cancel.md:5-28,32-37`).
  - Job `48412222` canceled before allocation because an unreviewed G6 official-validation retrain was pending before active program gates allowed it (`orchestration/control-incidents/2026-07-03-g6-official-cancel.md:5-17,19-32`).
  - Job `48412394` canceled after `00:04:22`; it touched official validation for seed `880000`, but partial metrics are explicitly non-evidence and not usable for selection/promotion/record/logging (`orchestration/control-incidents/2026-07-03-g6-official-retry-cancel.md:5-12,13-28,30-40`).
  - G8-B initial train-dev runtime canceled jobs `48456772` and `48456777` after stricter split-identity requirements; restarted with explicit `C100_DEV_PER_CLASS=50` and `C100_DEV_SPLIT_SEED=20260703` (`orchestration/g8-b-muon/runtime-20260703T232332Z/summary.md:60-61`; `agent-trace.jsonl:4`).
  - Policy reset clarifies cancellations were governance-based, not a ban on official validation: `orchestration/g7-validation-policy-reset/summary.md:9-13,29-31`.

## Recommended Orchestrator Wording

The repository is now compliant on the validation split distinction. Exploratory work used `train_dev` by design, as a fixed holdout from CIFAR-100 train, and those runs are consistently labeled non-record. Accepted finalist/record evidence uses `RECORD=1`, `VALIDATION_SOURCE=official`, exactly 30 paired seeds, and official `train,test` prep. The only unresolved official workstream is G8-B job `48463506`: launch/preflight were compliant, but result collection is blocked by Leonardo SSH auth, so it must not be claimed until terminal `sacct`, artifacts, recomputation, and critic review are complete. Prior cancellations were justified by governance and rule compliance, not by closing independent compliant workstreams.

## Trace

Commands run:

- `sed -n` / `nl -ba` on the requested skill, SLURM guidance, README, program, prep script, trainer, paired wrapper, policy reset, official results/traces, G8-B traces/results, blocked state, submit/job-watch logs, and incident files.
- `rg --files -g '*.md'`
- `rg -n` over README, program, `orchestration/`, `slurm/`, and `cifar100-benchmark/` for validation/split/record/cancellation terms.
- `find orchestration -name paired_summary.json -print0 | xargs -0 rg -n '"record_mode"|"validation_source"|"paired_seeds"'`
- `find orchestration -path '*config.json' -print0 | xargs -0 rg -n '"validation_source": "official"|"validation_source": "train_dev"'`
- `git status --short`

Files touched:

- `orchestration/validation-compliance/current-audit.md`

Outputs produced:

- This audit file.

Unresolved risks:

- No remote query was performed and Flywheel was not queried, per user stop conditions.
- G8-B official job `48463506` terminal state and artifacts remain uncollected.
- The local config sweep is evidence over currently mirrored local artifacts only; it cannot prove anything about remote artifacts not yet collected.
