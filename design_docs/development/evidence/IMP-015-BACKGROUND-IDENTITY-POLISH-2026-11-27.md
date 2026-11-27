# IMP-015 background and identity presentation — 2026-11-27

User-authorized fast-ui-polish iteration, following the earlier combined UI
checkpoint. Started 11:56:14 AM EST. Changes remain uncommitted; earlier checkpoint
work is preserved. This does not change increment, human acceptance or live-entry gates.

## Delivered behavior

- Biography method selection immediately generates or initializes the existing
  owner biography. Manual questions use BIOG00I0.IMG, the classic bitmap font and
  native two-column answer hit areas; answering advances immediately.
- Both completion paths show the five reputation directions from accepted intent
  before advancing to Name. Automatic summary overlays the original method screen;
  manual summary overlays the final question. Review/history remains accessible.
- Name uses CHAR00I0.IMG, transparent validated name entry, native Random and OK.
  Unicode/IME policy and unsupported-font recovery remain on the existing path.
- Faces use CHAR01I0.IMG with original-size centered portraits and native Previous,
  Next and OK. A displayed initial face changes no owner state until explicit input.
- Appropriate deliberate actions play the existing UI click. No new audio assets,
  codecs or dependencies were introduced. Native art absence has readable controls.

## Sources and duplicate portrait

Original external classic files remain read-only; artwork is decoded on demand
through the existing licensed/provenance-tracked media adapter. DFU FacePicker.cs
is reference evidence for original framing and raw-record traversal.
FACE12I0.CIF records 0 and 1 are both 29×35 and decode to SHA-256
`a7e4adf58581281edd6b8d529b621bc4d4e6662f13e89ce330a57a79dea21fa8`.
Independent raw traversal finds ten records; these are duplicate source pixels,
not a lost decoder frame. Browsing skips identical consecutive resolved portraits;
all 160 original IDs and media replacement precedence remain valid. Distinct mod
art at the duplicate target becomes browsable automatically. Fingerprints are
cached per realized image, without catalog-wide queries or source mutation.

## Verification

Final rendered run `verification-rendered-e45326f8339e4a5aacb9830b3f775932`:
**688 checks passed**, including automatic/manual twelve-question flow, directions,
native Name/face handlers, all original portrait IDs and identity owner/UI checks.
Controlled presentation seams check Unicode recovery without draft mutation and
distinct replacement pixels at the duplicate target; these are not package
publication qualification. Captures live under that root's
`project/tests/.runs/preview/storage/`, including background-question-1.png,
background-manual-reputation.png, name-generated.png and face-selected.png.

Open-window shutdown checks passed for automatic reputation summary, focused Name
field and manual questions, without resource-leak diagnostics. Full creation suites,
specialized biography localization/package fixtures and debug/release exports are
deferred to the next batch checkpoint; earlier checkpoint exports do not qualify
these new changes. Development failures remain recorded as failed, not passing.

## Reproduction

Run PowerShell 7 at
`C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe`
with `-NoProfile -File C:/Godot/Projects/Daggerfall_GD/main_project/tools/preview_creation_gender.ps1 -PostClass`.
Use `-ManualBiography`, `-NamePage` or `-FacePage` instead for direct review.
Add `-SmokeTest -IdentityChecks` for the targeted automated qualification.

## Artifact retention

Successful previews automatically compact copied projects after engine shutdown.
Four known inactive failed development copies are compacted with source archives,
failed reports, logs and captures retained. Compaction receipts preserve exact
removed-byte counts. No historical or uncertain roots are selected for cleanup.
An accidental authoritative editor import generated untracked UID/import sidecars;
only task-created sidecars are removed after path/time checks, retaining their
contents and hashes in `tests/.runs/imp015-background-identity-2026-11-27/generated-sidecars-removed.json`.
External editor settings were denied by the host and were not changed; subsequent
engines used disposable storage.

Completed 12:29:30 PM EST (33 minutes 16 seconds). Four failed copied builds removed 839,542,765 bytes; successful previews were also automatically compacted. All three open-window shutdown reports passed. Generated sidecar cleanup removed 158 files with restorable evidence retained. Final git diff --check passed.

Follow-up navigation fix: Back from Name after automatic biography returns to the method chooser while retaining generated outcomes; manual Back retains question navigation. Focused rendered run verification-rendered-81c3b43c3d4947aebff377fe825e61a7 passed, including both route assertions and automatic resume. Successful build compacted; failed pre-review import copy archived and compacted (209,890,971 bytes removed). Full suites/exports remain deferred.
