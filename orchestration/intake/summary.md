# Intake Orchestration Summary

## Scope

Set up a scientific automation pipeline for the CIFAR-100 A100 speedrun under the Flywheel root `R01 CIFAR-100 A100 Speedrun Challenge`.

## Decisions

- Use the linked Flywheel node from `.env` as the canonical root, but do not mutate Flywheel until evidence exists.
- Treat CINECA `SLURM.md` as mandatory: validate interactively before batch jobs.
- Block broad GPU search until the current-default baseline, dev split, paired runner, and artifact standard are in place.
- Launch bounded source sweeps in parallel while local control patches are planned.

## Active Agents

- AirBench / fast-CIFAR paper explorer.
- Muon / optimizer paper explorer.
- Augmentation / regularization paper explorer.
- Experiment trajectory architect.

## Housekeeper

Cron automation has been requested/proposed for 20-minute housekeeping checks. If it is not saved by the app, assign a sidecar housekeeper agent during active implementation/runs.

