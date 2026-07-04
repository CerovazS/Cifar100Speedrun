# Leonardo SSH Auth Diagnostic 2026-07-04

## Status

Leonardo access is blocked at SSH authentication. This is an operational access
blocker, not evidence about the scientific runs.

Affected pending jobs:

| Job | Stream | Expected action after auth returns |
| ---: | --- | --- |
| `48463506` | G8-B official `ns3_mom93` | collect terminal `sacct`, logs, raw official paired artifacts, recompute if artifacts exist, then critic classify |
| `48463507` | AirBench dev10 | collect terminal `sacct`, logs, raw train-dev paired artifacts, recompute if artifacts exist, then critic classify |

No resubmission, cancellation, dependent launch, or Flywheel mutation is allowed
while these jobs lack terminal evidence and critic classification.

## Commands Run

All commands were non-mutating local or SSH-auth probes.

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 leonardo 'hostname'
ssh -o BatchMode=yes -o ConnectTimeout=8 leonardo01 'hostname'
ssh -o BatchMode=yes -o ConnectTimeout=8 leonardo02 'hostname'
ssh -G leonardo
ssh -G leonardo01
ssh -G leonardo02
klist
ssh -vvv -o BatchMode=yes -o ConnectTimeout=8 leonardo 'true'
ssh-add -l -E sha256
stat -f '%N %Sp %Su %Sg %Sm' ~/.ssh/config ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub
```

## Observed Evidence

- `ssh leonardo` resolves to `lcerovaz@login.leonardo.cineca.it`.
- `ssh leonardo01` resolves to `lcerovaz@login01-ext.leonardo.cineca.it`.
- `ssh leonardo02` resolves to `lcerovaz@login02-ext.leonardo.cineca.it`.
- All three aliases fail with:

```text
Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

- The resolved config has `GSSAPIAuthentication no`.
- `klist` reports no local Kerberos ticket cache.
- The SSH agent offers ED25519 key SHA256
  `4ZAKU38KLP9Xtk5M0VUTh22vUn8DJZW6GmfND49ubx8`.
- The server rejects the offered public key and continues to advertise
  `publickey,gssapi-keyex,gssapi-with-mic`.
- Local permissions for `~/.ssh/config`, `~/.ssh/id_ed25519`, and
  `~/.ssh/id_ed25519.pub` are compatible with OpenSSH use.

## Interpretation

The failure is consistent with missing/invalid Leonardo authentication material:
either the offered public key is not currently accepted by CINECA for user
`lcerovaz`, or access requires a valid GSSAPI/Kerberos path that is not present in
the current local session. It is not specific to the `leonardo` aggregate alias,
because direct login-node aliases fail the same way.

## Safe Recovery Procedure

After authentication is restored, run collection before any other remote action:

```bash
cd "/Users/lucacerovaz/Documents/Cifar100 Speedrun"
bash orchestration/g9-frontier/collect_pending_jobs.sh --execute
```

Then route outcomes through:

```text
orchestration/g9-frontier/post-collection-decision-gate.md
```

Required post-auth order:

1. Collect `48463506` and `48463507` terminal scheduler evidence and artifacts
   exactly once.
2. Classify each stream as `pass`, `fail`, or `inconclusive` with a critic.
3. Recompute paired metrics only when raw paired artifacts exist.
4. Use the post-collection decision gate to choose exactly one next action.
5. Keep exploratory follow-ups on `train_dev`; reserve official validation for a
   pre-registered finalist only.

## Stop Conditions

- Do not run `sbatch`, `scancel`, `srun`, `rm`, `mv`, or any remote mutation
  while authentication is blocked.
- Do not launch replacement jobs for `48463506` or `48463507` until terminal
  evidence proves failure/cancellation and a new unique run id is pre-registered.
- Do not claim either pending stream as scientific evidence until artifacts and
  critic classification exist.
