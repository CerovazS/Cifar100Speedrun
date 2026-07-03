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

## Submission

- Job id: `48411710`
- Node: `lrdn0263`
- Submitted once from the scratch checkout root.
- Stdout prep confirmed train-only data preparation: `cifar100/train.pt: exists ...`; no `test.pt` prep line appeared.
- SLURM state: `FAILED`, exit code `1:0`, elapsed `00:04:31`.
- Failure cause: post-run wrapper guard printed `CANDIDATE_ENV was set, but candidate config matches baseline on all tracked training fields.` The completed configs show this is a wrapper validation false alarm for architecture-only changes: baseline `blocks=[2,2,2]`, candidate `blocks=[1,2,2]`, while the guard's tracked fields omit architecture fields.

## Metrics

| seed | order | baseline acc | candidate acc | acc delta | baseline time s | candidate time s | time ratio |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 880000 | baseline/candidate | 0.6946 | 0.6886 | -0.0060 | 23.1739 | 19.1409 | 0.8260 |
| 880001 | candidate/baseline | 0.6970 | 0.6940 | -0.0030 | 23.4279 | 19.1470 | 0.8173 |
| 880002 | baseline/candidate | 0.6986 | 0.6932 | -0.0054 | 23.5212 | 19.3112 | 0.8210 |

| metric | baseline | candidate | gate |
| --- | ---: | ---: | ---: |
| mean train-dev acc | 0.696733 | 0.691933 | candidate >= 0.697 |
| mean time s | 23.374349 | 19.199722 | lower is better |
| paired mean time ratio | 1.000000 | 0.821418 | candidate <= 0.900 |
| mean acc delta | 0.000000 | -0.004800 | higher is better |
| target hits | 0/3 | 0/3 | none required for this gate |

## Recommendation

KILL. The candidate passes the speed gate but fails the predeclared accuracy gate: `0.691933 < 0.697`. Because the decision criterion requires both gates, this should not expand to dev10, official validation, or record mode.

## Remote Artifacts

- Run root: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/outputs/cifar100_speedrun/g5b_t4_shallow16_20260703_1728_d765cc7`
- Stdout: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/logs/paired-48411710.out`
- Stderr: `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun/logs/paired-48411710.err`
- Local mirror: `orchestration/g5b-t4-shallow16/remote-artifacts/g5b_t4_shallow16_20260703_1728_d765cc7/`
- Curated metrics: `orchestration/g5b-t4-shallow16/metrics.csv`
- Missing expected wrapper summary: `paired_summary.json` was not written because the post-run guard exited with status 1.

## Accounting

```text
JobID|JobName|Partition|Account|State|ExitCode|Elapsed|AllocTRES|MaxRSS|NodeList
48411710|c100-paired|boost_usr_prod|iscrc_simp|FAILED|1:0|00:04:31|billing=8,cpu=8,gres/gpu=1,mem=64G,node=1||lrdn0263
48411710.batch|batch||iscrc_simp|FAILED|1:0|00:04:31|cpu=8,gres/gpu=1,mem=64G,node=1|1631132K|lrdn0263
48411710.extern|extern||iscrc_simp|COMPLETED|0:0|00:04:31|billing=8,cpu=8,gres/gpu=1,mem=64G,node=1|8K|lrdn0263
```

## Corrective Action

Patch `slurm/paired_compare.sh` before the next paired job so candidate-vs-baseline guard fields include `widths`, `blocks`, `label_smoothing`, and `cutout_size`.
