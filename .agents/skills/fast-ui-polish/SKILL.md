---
name: fast-ui-polish
description: Iterate quickly on an existing UI from screenshots and user feedback, using focused rendered previews and interaction checks while batching broader regressions and exports. Use for presentation polish, not initial feature qualification or gameplay, persistence, or architecture changes.
---

# Fast UI polish

Keep the feedback loop small: implement one screen or a few related visual
changes, show the actual result, and let the user judge the direction before
spreading it across the product. Screenshots and reference images describe the
desired appearance; they do not authorize unrelated functional changes.

## Per visual iteration

- Inspect the affected controls and relevant local instructions. Preserve the
  functional baseline and existing user changes. Reuse established fonts, sprite
  decoding, styling and owner interfaces.
- For spacing, sizing, colors, fonts and sprite presentation, default to a
  focused rendered preview and the affected interaction checks. Exercise actual
  handlers where relevant: confirmation/cancel, keyboard focus, scrolling and
  clipping. Inspect the screenshot before handing it over.
- Use current code in disposable preview storage. Label any controlled preview
  state; do not confuse it with completed gameplay or human acceptance. Reuse
  prepared assets only when their source/configuration freshness is verified.
- Prefer a direct launcher for the affected screen. A launcher that first runs
  thousands of assertions is not a fast preview. If none exists, add a narrowly
  scoped preview path when it materially shortens the requested iteration;
  preserve the normal verification entry points.
- Do not automatically run full creation suites, Windows debug/release exports,
  broad regressions, or whole-history artifact scans for every visual adjustment.
  Keep a short record of what changed, what was checked and which checks are
  deferred to the batch checkpoint.
- Aim for roughly 5–15 minutes for ordinary tweaks, often less for simple edits.
  This is a feedback-loop target, not a guarantee. Explain material extra work
  when the change turns out to require new infrastructure or functional repair.

## Broader verification

After the user approves several related pieces, run the relevant regression
suite once for the combined batch. At a presentation checkpoint or final
delivery, run the required exports and comprehensive acceptance checks.

Expand verification sooner when a change affects validation, authoritative
state, input ownership, publication/mod precedence, persistence, startup,
resource lifetime or other owner boundaries. Choose checks for the actual risk;
touching a shared file alone does not justify every unrelated suite. A discovered
functional defect needs appropriate maintained boundary coverage.

This workflow changes verification cadence; it does not waive named acceptance
gates or permit weaker assertions. Never report deferred or unavailable checks
as passing, claim physical-device testing from simulated input, or self-accept
the user's visual result. Respect any more specific current user requirement.

## Handoff

Show an authentic current screenshot and provide a reproducible focused preview
command. Say briefly what was checked and what remains for the batch checkpoint.
Ask for feedback on the specific appearance being iterated. Leave changes
uncommitted unless the user requests otherwise. Clean understood inactive preview
outputs within existing authorization, preserving compact evidence and unique
inputs; protect active or uncertain roots.

## Daggerfall_GD project context

When working in that repository, follow its AGENTS.md and approved owner/mod
boundaries. Original game assets stay external and read-only. The reusable race
popup is `main_project/scripts/ui/creation_popup.gd`; its supporting font/image
paths and the focused review are described in
`design_docs/development/evidence/IMP-015-RACE-POPUP-POLISH-2026-11-26.md`.

At this skill's creation, `review_creation_race_popup.ps1` still runs the full
rendered suite before opening the preview. Do not describe it as a fast launcher
without inspecting/updating that behavior. On Kirk's machine, give full script
paths and the PowerShell 7 executable path from the project evidence, since pwsh
is not on PATH and the terminal may start outside the repository.
