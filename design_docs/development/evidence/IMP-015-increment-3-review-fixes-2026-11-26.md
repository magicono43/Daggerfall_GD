# IMP-015 increment 3 — Human-review navigation fixes

**Accepted, 2026-11-26:** All nine human checks are reported PASS and the user
explicitly accepts increment 3. See [acceptance](IMP-015-INCREMENT-3-ACCEPTANCE-2026-11-26.md).
Earlier pending language below is historical; increment 4 and remaining gates
are not accepted or closed by this statement.

Start: **2026-11-26 15:16:59 EST (UTC−05:00)**. The user reported a French
Mage biography question, unreachable cancellation controls and Escape leaving
them at Pause with no usable return to creation. This is a corrective follow-up
to the original machine-qualified increment; human acceptance remains pending.
Qualification completed: **2026-11-26 15:33:56 EST (UTC−05:00)**.

## Changes

- `tests/creation_setup.gd`: the loose French/CJK biography override now runs
  only in automated `creation-draft` qualification. Interactive `creation-review`
  uses unmodified source English. Mechanics/source bytes are unchanged.
- `scripts/char/creation_view.gd`: Back/Restart/Exit controls appear before the
  large artwork page, keeping them reachable without scrolling past it.
  Escape from biography returns to method selection, retaining the draft.
  Creation intercepts Escape through the existing physical-key quarantine:
  repeats cannot escape again, discard the draft or reach global Pause handlers
  during the same press. Other existing creation cancellation rules remain.
- `tests/creation_biography_ui_cases.gd`: the test now presses the real Back
  button instead of calling `action("back")` directly. Seven added assertions
  check method/layer, visible navigation placement, real Escape/held input,
  retained answers/outcomes and unchanged entropy acquisition count.
- `tests/creation_review.gd`, `tools/review_creation.ps1`: biography review smoke
  verifies source English/no localized override (six smoke assertions).
- `tests/creation_inventory.json`: exact maintained inventories are now
  **3,332 headless / 3,365 rendered**. Review instructions and owner/progress
  records describe the corrected behavior.

The original 26,712-assertion delivery audit records the earlier source version,
not the corrected workspace. Its compact source archives/evidence remain intact.
The follow-up results and source hashes are recorded separately below.

## Verification

Headless creation passes 3,332 checks:
`main_project/tests/.runs/verification-headless-6cf0f4d9a7ba43c09f3162539ba77413/report.json`.
Rendered creation passes 3,365 checks in
`verification-rendered-d2dc1132b4434436b8c7914fd6ccc12c/report.json`; the same
launcher passes six interactive-review opening checks in its
`project/tests/.runs/scenario-1/human-review/result.json`, with
`human_pass=false`. Three actual new captures (biography, attributes, summary)
were inspected and retained with hashes in
`imp015-increment3-review-fixes/reviewed-captures.json`. The biography capture
intentionally shows the automated French stress fixture with navigation visible;
the separate interactive smoke checks verify that fixture is absent.

Windows debug export passes 3,332 headless / 3,365 rendered in
`export-e8261265597547a0986d162299bc5d25/result.json`. Windows release also
passes both inventories in `export-329b13521d9c452a9862f44cb1bf59d2/result.json`.
Headless session passes 263 checks in
`verification-headless-890ec619f4ae4550b5949ca2a32fdd52/report.json`; rendered
session passes 265 in `verification-rendered-c9b64989a7994b4d837f6a4ec3cdc279/report.json`.
The follow-up totals **20,625 passing assertions / 9 child results**. This includes
identified repeated executions of the same creation inventories, not 20,625
unique assertions. No controlled later-stage provider substitutes for biography
or starting-roll behavior. Physical controller/IME observations and explicit
human acceptance remain pending.

The full rendered composition observed 38.186941 s to menu, biography preparation
48.120 ms (18 templates / 250 texts / 90 books), 1,000 point queries 19.331 ms,
and revisit 1.917 ms. Eleven art decodes took 127.811 ms with unchanged retained
RGBA bytes. These are measurements on this machine, not new budgets.
Original actor/formula/faction owner implementations are
unchanged; their prior passing evidence remains scoped to that delivery.

No live grants, actor creation, native SAVE, playable entry, increment-4 delivery
or milestone acceptance is claimed. All work remains uncommitted.

## Audit and retention

The [follow-up machine audit](IMP-015-increment-3-review-fixes-2026-11-26.audit.json)
verifies 20,625 typed assertions / nine children, 2,208 before/after source-hash
checks, six nonempty source archives, current tool hashes, three inspected
captures and unchanged native DLL hashes. All executed runtime files match the
corrected source; no fixture-source exception was needed in this follow-up.
`git diff --check` passes.

After all owned jobs returned, six inactive builds were compacted with checked
containment, template-junction handling and retained-evidence hashes: 11,648
files / 1,928,874,469 bytes removed. Shader cleanup removed another 198 files /
5,495,652 bytes. No full build from this follow-up remains; the launcher rebuilds.
Final logical retention is 8,915,072,949 bytes (8.30281 GiB), excluding reparse
targets. The above-8-GiB review identified prior human-review and other-task roots
as the largest remaining outputs; those roots remain protected. Journals and the
final sample are in `main_project/tests/.runs/imp015-increment3-review-fixes/`.

Re-run the existing biography review launcher and retry the Mage question,
Back/Escape and Restart. Interactive text should be English; Back and Escape
should retain partial answers at method selection. Formal increment acceptance
still awaits the user's review results and explicit decision.
