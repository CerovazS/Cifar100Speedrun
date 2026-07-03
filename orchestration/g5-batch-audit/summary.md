# G5 First Batch Audit

## Verdict

PASS for the negative first-batch decisions and for planning another train-dev-only batch.

BLOCK for any dev10, paired train-dev promotion, official validation, or record-mode run from the current evidence.

## Evidence Checked

- T1 schedule compression: best pilot was default 14 epochs at train-dev mean `0.697133`, `1/3` hits.
- T1 LR sweep: Muon LR `0.030`, `0.040`, and `0.045` were all below default on the same three seeds.
- T2 Muon scalar LR sweep: best pilot was LR `0.025` at train-dev mean `0.696600`, `0/3` hits.
- T3 architecture pilot: best variant was `shallow122` at train-dev mean `0.689267`, `0/3` hits.
- Incident `48410889`: old-path official-candidate job was canceled after `00:01:52`, before completing accepted metrics.

## Required Fixes Before Next Launch

- Mirror T2 remote artifacts locally or mark T2 as summary-only screening evidence.
- Ensure future train-dev search does not prepare or inspect the official test artifact.
- Keep old `$WORK` / PAERLE / YENDRI launch surfaces out of the active pipeline.
- Ensure the active remote checkout contains the architecture env knobs as a commit, not only as a dirty patch.

## Permitted Next Actions

- Launch a new train-dev dev3 batch only after a predeclared numeric gate and unique run IDs are recorded.
- Use matched default controls where a comparison claim is intended.
- Treat `shallow122` only as a possible combined follow-up, not a finalist.
- Focus on more substantive mechanisms than scalar epoch/LR sweeps: architecture recovery, augmentation/regularization, or optimizer changes beyond a single Muon LR scalar.

## Unsafe Claims

- No G5 candidate is a finalist.
- No current result justifies dev10, paired train-dev, official validation, or record mode.
- `shallow122` is not established as Pareto-superior to the default architecture.
- T2 does not establish an optimizer conclusion beyond a conservative no-expand decision.
