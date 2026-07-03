# G5b-T4 Shallow16 Trace

## Objective

Run exactly one train-dev dev3 paired pilot for `shallow122` recovery at 16 epochs.

## Claim, Hypothesis, Decision Criterion

- Claim: `shallow122` at 16 epochs may recover enough train-dev accuracy while remaining materially faster than the default architecture.
- Hypothesis: `C100_BLOCKS=1,2,2` with default widths `(64,128,256)`, default optimizer, `EPOCHS=16`, `RUNS=3`, same seeds, has candidate mean train-dev accuracy `>= 0.697` and paired mean time ratio `<= 0.90` against default.
- Decision criterion: expand only if both gates hold; kill otherwise. No dev10, no official validation, no record claim.

## Launch Constraints

- Remote checkout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun`
- Branch: `codex/cifar100-speedrun-control`
- Verified commit: `d765cc7a16eb98b3b0fc21a0bd805866a9cf07cc`
- Minimum required commit: `b09cd6e`; ancestry check passed.
- Run id: `g5b_t4_shallow16_20260703_1728_d765cc7`
- Output path: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5b_t4_shallow16_20260703_1728_d765cc7`
- Source edits: none planned.
- Flywheel/Linear: explicitly out of scope.

## Required Command

```bash
cd /leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun
RUN_ID=g5b_t4_shallow16_20260703_1728_d765cc7 \
RECORD=0 \
RUNS=3 \
EPOCHS=16 \
VALIDATION_SOURCE=train_dev \
BASE_SEED=880000 \
CANDIDATE_ENV='C100_BLOCKS=1,2,2' \
sbatch slurm/paired_compare.sh
```

## Result

SLURM job `48411710` ran all six trainer invocations, then failed in paired post-processing because the wrapper's candidate guard did not yet include architecture fields (`widths`, `blocks`) in its tracked comparison list. The metrics are complete and sufficient for a conservative kill decision, but the job is recorded as `FAILED`, not as a clean successful pilot.

Scheduler accounting:

```text
48411710|c100-paired|FAILED|1:0|00:04:31|billing=8,cpu=8,gres/gpu=1,mem=64G,node=1
```

The prep stage printed only `cifar100/train.pt`; it did not print or inspect `test.pt`.

## Metrics

| Metric | Baseline | Candidate `blocks=1,2,2` |
| --- | ---: | ---: |
| Mean train-dev accuracy | `0.696733` | `0.691933` |
| Target hits | `0/3` | `0/3` |
| Mean timed training | `23.374349s` | `19.199722s` |
| Mean candidate/baseline time ratio | | `0.821418` |
| Mean accuracy delta | | `-0.004800` |

Per-seed paired results:

| Seed | Baseline acc | Candidate acc | Acc delta | Baseline time | Candidate time | Time ratio |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `880000` | `0.6946` | `0.6886` | `-0.0060` | `23.173885s` | `19.140896s` | `0.825968` |
| `880001` | `0.6970` | `0.6940` | `-0.0030` | `23.427930s` | `19.147023s` | `0.817273` |
| `880002` | `0.6986` | `0.6932` | `-0.0054` | `23.521232s` | `19.311246s` | `0.821013` |

## Decision

KILL `shallow122` recovery as tested. The candidate passes the speed gate (`0.821418 <= 0.90`) but fails the accuracy gate (`0.691933 < 0.697`) and has `0/3` target hits. Do not expand to dev10, paired promotion, official validation, or record mode.

## Corrective Action

Patch `slurm/paired_compare.sh` before the next paired job so candidate-vs-baseline guard fields include `widths`, `blocks`, `label_smoothing`, and `cutout_size`.

## Evidence Paths

- Remote output root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5b_t4_shallow16_20260703_1728_d765cc7/`
- Local mirror: `orchestration/g5b-t4-shallow16/remote-artifacts/g5b_t4_shallow16_20260703_1728_d765cc7/`
- Logs: `orchestration/g5b-t4-shallow16/paired-48411710.out`, `orchestration/g5b-t4-shallow16/paired-48411710.err`
- Accounting: `orchestration/g5b-t4-shallow16/sacct-48411710.txt`
