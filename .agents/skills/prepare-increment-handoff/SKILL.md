---
name: prepare-increment-handoff
description: Prepare a self-contained assignment for the next increment of an Implementation task by checking delivered prerequisites, scope, authority and verification obligations. Use when writing a prompt or handoff for a fresh chat; preparing the handoff does not start implementation or accept unfinished work.
---

# Prepare increment handoff

Produce an assignment another agent can execute without the current conversation.
This precedes implementation; a completion report describes delivered work instead.
Follow the project's existing handoff format where one exists.

## Establish the next assignment

Read the named task, issued increment plan, relevant approved specifications and
decisions, and the latest delivery/acceptance evidence. Follow links only as needed
to resolve the actual scope. Planning READY is not proof that a prerequisite has
been delivered. Distinguish implemented, verified, user-accepted and still pending.

Use current repository state and existing evidence to identify the next increment.
Do not advance to it merely because its number follows the previous one. If a
required prerequisite is missing, explain the concrete dependency and prepare an
appropriately conditional handoff rather than claiming readiness.

Extract durable user decisions from the available conversation, including intentional
differences, deferred presentation/integration work and verification cadence. Label
proposals and unresolved questions separately from approved requirements. Resolve
routine engineering choices with project guidance; ask only about a material gap.

## Write a compact, self-contained prompt

Include the information needed to execute and judge this increment:

- Task/increment identity, objective and the specific authorized deliverables.
- Required authority documents, prerequisite delivery evidence and useful entry
  points/callers. Include exact paths; do not make the next agent rediscover them.
- Owner/interface constraints, supported data/mod paths and relevant user decisions.
- Explicit exclusions and later integration obligations that could be mistaken
  for requirements of this increment.
- Observable acceptance criteria, targeted verification and the broader checks
  deferred to the Implementation checkpoint. Carry forward the existing ledger;
  do not reset it or automatically demand full suites and both exports again.
- Expected completion evidence, a focused human review if appropriate, cleanup
  obligations and the user's Git/acceptance workflow.

Prefer links plus concise decisions over copied design catalogs. Do not rely on
phrases such as "as discussed above" or inaccessible temporary build paths. Include
a reproducible command when it matters, checking its current suite/fixture names
against maintained launchers rather than copying an unverified old invocation.

Read the prompt as a fresh agent: can it tell what to build, what must already work,
what it may change, how to check success, and what it must leave open? If several
increments are possible, explain the dependency-based recommendation rather than
silently reordering approved work.

## Delivery and authorization

Return a copyable prompt. Save it to the established handoff location when requested
or required by the project's handoff workflow. Preparing an assignment does not
authorize its implementation, start another agent/chat, send a message, accept a
prior increment, mark the parent task complete, or commit/push changes.

Do not alter existing acceptance history to make the handoff look ready. State any
remaining prerequisite or user decision plainly. Refer to the available
implement-increment workflow for delivery and proportionate verification, without
requiring unrelated skills to be loaded.

## Daggerfall_GD context

Use AGENTS.md, design_docs/development/tasks/IMP-NNN.md and the relevant approved
feature/architecture decisions. Check actual delivery records alongside roadmap
and readiness entries. Preserve IMP/feature IDs and existing approval history.
Describe controlled fixtures and real-provider, IMP-036, SAVE or milestone gates
accurately; mention only those relevant to this assignment.
