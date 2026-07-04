# Blocked State: Remote Authentication

The official G8-B `ns3_mom93` run was pre-registered, preflighted, submitted once, and observed running, but collection is blocked by Leonardo SSH authentication failure.

## Completed Before Block

- Clean remote Git checkout created at `/leonardo_scratch/large/userexternal/lcerovaz/cifar100_speedrun/Cifar100Speedrun-g8b-official-clean`.
- Remote `HEAD` verified as `4ba08a7b3fea1652411a3adcabddc33fb2821ffe`.
- Remote source status verified clean before launch; copied CIFAR tensors are ignored under `cifar100-benchmark/cifar100/`.
- Output root verified absent before launch.
- `bash -n slurm/paired_compare.sh` passed.
- `python -m py_compile train_cifar100_resnet_muon.py` passed in the Leonardo venv.
- Official tensor shapes verified: train `50000`, test `10000`.
- Exact submit command captured in `submit.txt`.
- Slurm accepted job `48463506`.
- Early stdout confirmed A100 node `lrdn0042`, official train/test tensors, and seed `894000` baseline start.

## Block

The SSH babysit connection dropped with:

```text
Read from remote host login.leonardo.cineca.it: Operation timed out
client_loop: send disconnect: Broken pipe
```

Subsequent reconnect attempts to `leonardo`, `leonardo01`, and `leonardo02` failed with:

```text
Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

Verbose SSH showed the local ED25519 key was offered and rejected by the gateway. Reloading the key and bypassing the agent did not resolve it. No Kerberos ticket was available.

## Not Yet Collected

- Terminal Slurm state for job `48463506`.
- `paired_summary.json`.
- `paired_order.csv`.
- Complete stdout/stderr.
- `sacct` final record.
- Raw per-run `config.json`, `summary.json`, `metrics.csv`, `warmup.json`, `repro_metadata.json`, and any `git_diff.patch`.
- Recomputed metrics and config verification.
- Independent result critic.

## Rule

Do not resubmit this run unless the current job is first verified failed/canceled and a new unique run id/output directory is chosen.
