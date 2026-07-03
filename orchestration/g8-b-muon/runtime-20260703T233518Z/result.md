# G8-B Muon Mechanics Train-Dev Pilot Result

## Active Objective And Success Criteria

Execute three exploratory paired train-dev G8-B Muon mechanics pilots on Leonardo without Flywheel mutation.

Success criteria: `RECORD=0`, `VALIDATION_SOURCE=train_dev`, `RUNS=3`, explicit `C100_DEV_PER_CLASS=50`, explicit `C100_DEV_SPLIT_SEED=20260703`, unique run IDs, no output reuse, all jobs complete, configs verify the fixed 13-epoch one-cycle longwarm baseline, and the decision gate can choose promote / hold / kill.

## Jobs

| Candidate | Job ID | RUN_ID | BASE_SEED | State |
|---|---:|---|---:|---|
| `ns4` | `48457399` | `g8b_ns4_longwarm_dev3_20260703T233518Z` | 893520 | completed |
| `ns3` | `48457400` | `g8b_ns3_longwarm_dev3_20260703T233518Z` | 893530 | completed |
| `ns3_mom93` | `48458063` | `g8b_ns3_mom93_longwarm_dev3_20260703T233518Z` | 893540 | completed |

## Metrics

| Candidate | Candidate hits | Baseline hits | Candidate mean acc | Baseline mean acc | Acc delta | Candidate mean time | Baseline mean time | Time delta | Time ratio |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `ns4` | 3/3 | 3/3 | 0.703400 | 0.706067 | -0.002667 | 18.596384 | 19.247712 | -0.651327 | 0.966171 |
| `ns3` | 3/3 | 2/3 | 0.705400 | 0.704933 | +0.000467 | 17.544117 | 18.802412 | -1.258295 | 0.933079 |
| `ns3_mom93` | 3/3 | 2/3 | 0.709867 | 0.704867 | +0.005000 | 17.613634 | 19.024153 | -1.410519 | 0.925927 |

## Verdict

Promote `ns3_mom93` to dev10 train-dev only. It has 3/3 train-dev target hits, no accuracy collapse, the best mean accuracy, and the best paired time ratio. Hold `ns3` as a backup mechanics candidate. Kill `ns4` because the time gain is smaller and the mean accuracy delta is negative.

Do not treat this as official validation or record evidence.

## Evidence

- Artifact root: `orchestration/g8-b-muon/runtime-20260703T233518Z/remote-artifacts/`
- Machine verification: `orchestration/g8-b-muon/runtime-20260703T233518Z/verification.json`
- Metrics table: `orchestration/g8-b-muon/runtime-20260703T233518Z/metrics-table.tsv`
- Scheduler accounting: `orchestration/g8-b-muon/runtime-20260703T233518Z/sacct-all.txt`

## Risks

- Only dev3 train-dev evidence; statistical uncertainty remains high.
- Remote checkout remained dirty by controlled file sync rather than exact remote commit checkout.
- Independent result critic passed this runtime for exploratory train-dev promotion only.
