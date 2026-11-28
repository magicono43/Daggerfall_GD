---
name: trace-dfu-behavior
description: Investigate a specific Daggerfall Unity behavior and trace its callers, assets, data, timing and state changes into an evidence-backed recreation plan. Use for focused DFU research supporting UI or gameplay work; investigation alone does not authorize implementation or adopting DFU mechanics as project design.
---

# Trace DFU behavior

Answer a concrete behavior question with source evidence and an appropriate mapping
to this project's interfaces. Avoid an open-ended audit of DFU or the design catalog.

## Follow the behavior

Identify the trigger and expected outcome from the request, screenshots or bug
report. Inspect the pinned local DFU implementation first when available. Search
for the relevant window/component, callback, resource name or domain function,
then follow the actual caller-to-result path far enough to explain the behavior.

Separate presentation and runtime mechanics: input dispatch, UI state, optional
sound/animation, authoritative edits, data lookup and persistent/live effects may
have different owners. Read the relevant helper rather than assuming its behavior
from its name. Inspect cancellation, repetition and completion paths when they
affect the requested result.

For assets/data, establish the exact resource selector and its meaning: logical
identity, record/index, archive ordinal, frame, palette and transparency where
relevant. For timing, identify units, frame/clock dependence and lifecycle. Trace
lookup tables and validated source data rather than inferring values from screenshots.

Keep reference_material, base_data_files and external classic data read-only.
If byte inspection or runtime observation is useful, use bounded readers and
disposable outputs. Do not install a new tool, widen a native adapter or build a
general decoder merely to avoid explaining an unresolved investigation boundary.
Use available tools proportionately and preserve source provenance/licensing.

## Establish what the evidence proves

Distinguish source-observed behavior, runtime-observed behavior, inference and
unknowns. Code inspection alone does not prove original-executable parity or
qualify a malformed/unknown data interpretation. Record the source version and
exact file/function or resource identities so another agent can reproduce the trace.

Where visual evidence and code disagree, investigate the relevant setting,
fallback, platform or source variant. Do not quietly choose whichever result is
easiest to implement. State a remaining material ambiguity and the smallest useful
follow-up observation; do not ask the user to perform tests answerable from source.

## Map into the recreation

Inspect the existing implementation and approved contracts for the affected feature.
Identify which owner validates each fact and which UI/AV consumer presents it.
Explain how original resources and behavior fit the existing data/mod replacement
paths, stable identities, lifecycle and timing interfaces. Prefer reuse over a
parallel source of authority or a speculative framework.

DFU is evidence, not automatic approval of gameplay or architecture. Apply the
project's standing source/correction policy: routine permitted data choices do
not require separate approval, while a material design conflict still needs a
decision. Keep intentional differences explicit and replaceable.

Deliver a concise trace: trigger and call path; key assets/data/timing; completion
and cancellation behavior; source evidence; proposed project mapping; and remaining
unknowns. Include only findings that help the requested work. If implementation
was requested too, continue within that authorization and verify the changed
behavior using the appropriate increment or UI-polish cadence. Otherwise stop at
the explanation/plan; do not mutate production code or send work to another agent.
