# IMP-015 — Custom-class Help menu

Started November 27, 2026 at 9:19:04 AM EST using fast-ui-polish.
Scope: the existing custom sheet's Help control, topic picker and information
messages. No class evaluation, completion rules or owner state changes.

## Source and implementation

Read-only DFU `CreateCharCustomClass.cs` supplies the eight topic mappings:
Attributes 2402, Class Name 2401, General 2400, Reputations 2406,
Skill Advancement 2407, Skills 2403, Special Advantages 2404 and
Special Disadvantages 2405. Text is read from external TEXT.RSC; no original
asset or DFU source copy is added. Existing classic font, picker and parchment
resources retain their existing provenance/licensing.

`creation_help.gd` uses structured-text lookup: normal catalog precedence for
collection `creation`, keys `help.custom.attributes`, `help.custom.class-name`,
`help.custom.general`, `help.custom.reputations`, `help.custom.skill-advancement`,
`help.custom.skills`, `help.custom.advantages`, `help.custom.disadvantages`,
then the explicit classic mapping. The first line is the centered title; the
remaining text is left aligned. Classic per-line indentation is stripped to
avoid reproducing renderer-specific padding. A small per-draft, per-locale
cache avoids repeated record reads; it clears with draft teardown.

Help uses the existing silent selection/activation picker. Confirming replaces
the picker with its message. Click-anywhere, Escape and Back return to the
custom sheet. Eight topics fit without a draggable scrollbar thumb. The shared
popup's optional heading leaves existing title-less notices/confirmations intact.

## Verification

Focused rendered launcher: `main_project/tools/preview_creation_gender.ps1
-HelpMenu -SmokeTest`. Interactive review omits `-SmokeTest`; `-CloseTest`
exercises shutdown with a live Help message. The maintained fixture covers all
eight real source records, selection versus confirmation, text alignment and
fit, dismissal and preservation of custom data. Full creator regressions and
exports are deferred to the presentation checkpoint; human appearance approval
is pending. Run results and compact evidence are recorded below after execution.

- Rendered smoke: **87 checks passed**, root
  `main_project/tests/.runs/verification-rendered-6667f6841bf9474d8645bd662ee42eda`.
  Inspected current picker, Attributes and General captures; all eight bodies
  passed fit/alignment checks. Existing startup race/gender checks also passed.
- Live-message shutdown: **34 checks passed**, root
  `main_project/tests/.runs/verification-rendered-54e6461b5f304d90a776c85755f06f2b`.
  No unexpected diagnostics or ObjectDB/resource leaks. Original asset hashes
  unchanged in both passing runs. `git diff --check` passed.
- Development runs `3fa5efe962ce427ab4fb4f33ce9c2a5a` (wrong fixture picker marker)
  and `39c3775936e445e9a49de53ba60d9c05` (three clipped Help bodies) retain their
  failed reports. Both defects were corrected before the passing run.
- Compacted all four owned inactive copied builds, removing **849,583,151 bytes**;
  verified source archives, reports, logs and captures remain. Exact failed-run
  receipts are `DEVELOPMENT-COMPACTION.json`; successful runs have the launcher's
  compaction receipts. No external originals or authoritative files were removed.

Completed at **9:31 AM EST** on November 27, 2026 (about 12 minutes).
