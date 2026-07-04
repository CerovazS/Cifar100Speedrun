# Leonardo Auth Recovery Runbook

## Purpose

The CIFAR-100 speedrun pipeline is waiting on Leonardo authentication, not on a
scientific decision. Jobs `48463506` and `48463507` must be collected before any
replacement, dependent launch, promotion, record claim, or logging.

## Current Local Evidence

Non-mutating probes from the local machine show:

- `ssh leonardo`, `ssh leonardo01`, and `ssh leonardo02` all fail with
  `Permission denied (publickey,gssapi-keyex,gssapi-with-mic)`.
- `ssh -o IdentitiesOnly=yes -i ~/.ssh/id_ed25519 leonardo 'true'` also fails
  with the same message.
- `ssh -o PreferredAuthentications=gssapi-with-mic -o GSSAPIAuthentication=yes
  leonardo 'true'` also fails.
- `klist` reports no local Kerberos ticket cache.
- The local SSH agent offers ED25519 key SHA256
  `4ZAKU38KLP9Xtk5M0VUTh22vUn8DJZW6GmfND49ubx8`, which Leonardo rejects.
- Direct `login03-ext.leonardo.cineca.it` and
  `login04-ext.leonardo.cineca.it` names do not resolve from this local network
  session.

## User-Side Recovery Checks

These checks require account credentials or portal access and should be done by
the user, not by the orchestration agent.

1. Verify the accepted CINECA public key.

```bash
cat ~/.ssh/id_ed25519.pub
ssh-add -l -E sha256
```

Expected local fingerprint currently offered by the agent:

```text
SHA256:4ZAKU38KLP9Xtk5M0VUTh22vUn8DJZW6GmfND49ubx8
```

Confirm that the corresponding public key is registered for the CINECA Leonardo
account `lcerovaz`. If CINECA expects a different key, update local SSH config or
the portal registration deliberately; do not edit experiment artifacts.

2. If the account uses Kerberos/GSSAPI, obtain a ticket using the site-approved
method, then verify:

```bash
klist
ssh -o BatchMode=yes -o ConnectTimeout=8 -o GSSAPIAuthentication=yes leonardo 'hostname'
```

3. Verify public-key SSH after portal/key repair:

```bash
ssh -o BatchMode=yes -o ConnectTimeout=8 leonardo 'hostname'
```

4. Do not run `sbatch`, `scancel`, or any cleanup command as part of auth repair.

## Immediate Command After Auth Works

From the main local repository:

```bash
cd "/Users/lucacerovaz/Documents/Cifar100 Speedrun"
bash orchestration/g9-frontier/collect_pending_jobs.sh --execute
```

Then follow:

```text
orchestration/g9-frontier/post-auth-collection-handoff.md
orchestration/g9-frontier/post-collection-decision-gate.md
```

## Why The Pipeline Should Not Continue Without This

The next scientific decision depends on terminal scheduler evidence and artifacts
for:

- G8-B official job `48463506`
- AirBench dev10 job `48463507`

Without `sacct`, scheduler logs, manifests, and available raw artifacts, any new
G9 run would risk duplicating live work, turning official validation into a
search loop, or making a promotion decision from missing evidence.

## Stop Conditions

- Do not resubmit either pending job before terminal evidence proves failure or
  cancellation.
- Do not cancel either job from this recovery path.
- Do not launch G8-C, additive AirBench, 12-epoch, or front-end pilots while the
  two pending streams are unclassified.
- Do not create Flywheel or Linear records from the pending streams until result
  evidence and critic classification exist.
