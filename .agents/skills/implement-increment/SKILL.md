---
name: implement-increment
description: Deliver an increment within a larger Implementation task using targeted verification, fresh evidence reuse, and an explicit deferred-check ledger. Use for incremental delivery and its final checkpoint, alongside project-specific engineering instructions.
---

# Implement increment

Deliver a usable increment without repeatedly qualifying the entire Implementation.
This records the user's preferred verification cadence: targeted checks for each
increment, combined regression and export checks at the end of the Implementation.
It does not reduce the increment's required functionality or allow building later
work on an unverified prerequisite.

## Establish scope and the finish line

Read the assigned increment/handoff, the task's relevant specifications, approved
decisions and prerequisite delivery evidence. Use existing project instructions
for architecture, ownership, coding, timing, Git and acceptance rules; do not
duplicate the whole project catalog in the working context.

Identify the increment's deliverables, affected interfaces and acceptance checks.
Determine whether this is an intermediate increment or the final Implementation
checkpoint. Use existing records before asking the user; do not mistake a final
increment for permission to accept the parent task on the user's behalf.

## Verify the increment proportionately

- During development, run checks for the changed behavior and its affected callers.
  Prefer maintained owner/interface tests, focused renders or interaction checks
  as appropriate. An initial implementation needs functional qualification even
  when later presentation changes can use a smaller preview loop.
- At handoff, verify the increment's success, rejection and relevant interruption
  or retry behavior through its real interfaces. Clearly identify controlled
  providers and unavailable real integrations. Keep assertions meaningful.
- Default to deferring broad cross-system regressions.
  An increment number, shared filename or handoff template alone is not a reason
  to repeat the entire suite or rebuild every platform artifact.
- Expand checks earlier when a concrete dependency or risk warrants it: shared
  startup/publication, persistence or restore, native/build changes, input or
  resource lifetime, cross-owner commitment, or a platform result needed before
  the next increment can safely proceed. Select the relevant boundary checks;
  this still does not automatically require every unrelated suite and export.
- Preserve explicitly named earlier gates and checks needed to establish delivered
  prerequisites. General regression/export boilerplate should use this cadence;
  a concrete required earlier gate must not be silently deferred. Explain the
  particular requirement or risk when it causes broader work, rather than adding
  a blanket permission request or treating every old template as a conflict.

Do not skip a failing relevant check because a final checkpoint is planned. Fix
the defect or report the actual limitation. Never weaken an assertion to avoid
testing the behavior the increment is supposed to establish.

## Reuse evidence and preparation carefully

Before repeating expensive work, identify what changed since the relevant prior
result: implementation, affected callers, fixtures, source data, dependencies,
configuration or export target. Reuse preparation only within a verified fresh
scope. A prior passing result is evidence for that version, not a pass for later
changes. An existing build is reusable only when its inputs and required outputs
still match; otherwise rebuild the affected artifact.

Maintain a compact verification ledger in the task's existing progress/evidence
record. Add a separate small record only if none exists. Capture:

| Check or scope | Code/input identity and result | Remaining obligation |
| --- | --- | --- |
| Targeted increment checks | Command/report reference; passed, failed or unavailable | Affected follow-up, if any |
| Reused preparation/evidence | What matches and why reuse is valid | Freshness limits |

Use commits plus relevant working-tree/input hashes where needed. Keep this light:
no mandatory whole-history artifact scan, exhaustive repository audit or separate
framework for each increment. Avoid overlapping ledgers with contradictory status.

## Handoff, cleanup and acceptance

State what changed, what passed, what remains deferred and whether the next
increment can use this delivery as a prerequisite. Provide a short human review
focused on this increment's behavior; distinguish simulated input from physical
device testing. Use an available UI-polish workflow for small visual iterations.

Distinguish implemented, targeted-verified, combined-checkpoint-verified and
user-accepted status. Intermediate increments may be accepted in their documented
scope while combined verification remains deferred. Parent completion requires
its applicable final checks and the project's user-acceptance process.

Preserve compact reports, source identities and necessary reviewed captures; clean
understood inactive copied projects, exports, dependency copies and caches under
the project's existing cleanup rules and authorization. Prefer deleting disposable
builds over retaining them speculatively; retain a build only for a concrete active
review/debugging need with an expiry. Protect unique inputs, active/uncertain roots,
external data and user work.

Leave commits and pushes to the user unless explicitly authorized. This skill
adds no permission gate: proceed with already-authorized implementation, targeted
checks, routine fixes and cleanup. Respect host-enforced permissions; request
user input only for a concrete missing requirement, material design conflict or
authorization that is actually absent.

## Daggerfall_GD context

Follow AGENTS.md and design_docs/development/tasks/IMP-NNN.md plus the issued
increment handoff. Keep the existing owner/mod boundaries and Windows-first
requirements. Record deferred regressions and exports in the task evidence, and
use the repository fast-ui-polish skill for suitable presentation iterations.
Do not claim playable entry, native SAVE, parent acceptance or milestone readiness
from a controlled fixture or an intermediate increment's passing checks.
