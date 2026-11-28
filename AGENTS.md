# Coding agent instructions

## Timing for significant tasks

- For substantial implementation, debugging, investigation, verification or
  multi-step deliverable work, state the current start time in **EST (UTC−05:00)**
  at the beginning. After a brief scope inspection, give a rough elapsed-time
  estimate, preferably a range. Use judgment: work expected to take roughly
  15 minutes or more generally qualifies, as does substantive coding or debugging.
- Use a reliable current clock; do not invent timestamps. Update the estimate
  if findings materially change it. At completion, report the actual end time
  in EST. If stopping with work unfinished, label it a stop time and state what
  remains rather than implying completion.
- Omit timing boilerplate for simple questions, acknowledgments, routine status
  replies and trivial edits. Report timing once per substantial work session,
  not again for every short follow-up within the same task.

## Objective and target

Build the approved Daggerfall-style RPG in **Godot 4.7.2**, progressing through playable vertical slices in [the roadmap](design_docs/development/ROADMAP.md). Verify Windows first and preserve the approved platform adapter boundaries.

- Keep `reference_material/` (including `reference_material/daggerfall-unity-1.1.1-cve-2025/`), `base_data_files/`, and external classic data read-only. Use DFU as evidence for specified behavior.
- Create recreation code in `main_project/`, which contains `project.godot` and is the game directory for IMP-001. Repository-relative documentation paths start at this repository root; Godot `res://` paths start at `main_project/`.
- Use **GDScript** for the main game, UI and tools, and **C++ GDExtensions** for native adapters, as approved by the user on 2026-11-18. Follow existing project conventions within that split. Approved mod languages are Luau for restricted scripts and GDScript for trusted scripts. Native media/runtime adapters follow the linked contracts.

## Standing data-source and correction policy

**User clarification, 2026-11-21:** Modding is the highest overall priority.
Exact vanilla Daggerfall values and bug-for-bug fidelity are not project goals;
baseline values are expected to be changed or replaced through mods.

- Choose whichever source makes the most sense for the assigned work: original
  Daggerfall data, DFU packaged data, DFU corrections, or an explicitly documented
  combination. DFU data and corrections are allowed, not merely reference-only.
  Prefer a coherent, usable and moddable baseline that is reasonably consistent
  with related Daggerfall content over unnecessary exact-original parity.
- Use engineering judgment to adopt sensible source data and routine corrections
  within the authorized task. Do not ask for separate permission merely because
  a value/correction comes from DFU, differs from vanilla, or lacks an original
  executable comparison. Explain the choice, check relevant consistency and
  references, and record provenance, licensing and intentional differences.
- Keep baseline choices and corrections explicit and replaceable. Preserve stable
  identities, deterministic publication, correction provenance and later mod/loose
  override precedence. Match a correction's intended input so it does not overwrite
  externally modified values accidentally. Never bake vanilla values into owners
  where the approved data/mod interfaces should supply them.
- This standing authorization supersedes older blanket reference-only wording and
  per-correction approval requirements for routine data/compatibility choices.
  It does not authorize unrelated tasks, material changes to explicitly approved
  gameplay/architecture, unsupported behavior, source-file mutation or false
  readiness claims. Ask only when a concrete material conflict or design choice
  remains; ordinary source selection and consistency fixes should proceed.

See `PROJECT-DATA-D01` in
[GAMEPLAY_DECISIONS.md](design_docs/design/GAMEPLAY_DECISIONS.md). Historical
approvals and execution evidence describe what was adopted at the time; they are
not a standing ban on adopting further DFU data or corrections.

### Unknown classic action records

**User clarification, 2026-11-23:** Unknown action codes in vanilla data must
not by themselves prevent structural import. Retain their original code,
parameters, target address, source identity and provenance as explicitly
non-executing metadata; ignore them for action dispatch and outgoing executable
links. Do not guess behavior, silently turn them into a known action or discard
their records. Keep unknown-action/gameplay-owner readiness pending and expose
the retained records to diagnostics and future mod/owner qualification. Apply
this consistently across the pinned classic corpus, including Privateer's Hold,
and verify the inventory. Known actions retain their required-link checks;
malformed bytes, invalid resources and missing required bindings still fail.
This policy does not automatically permit unknown authored
mod actions to execute or establish gameplay, SAVE or milestone readiness.

The user also authorized DFU's north-facing opening as a documented baseline
difference; do not claim that facing was verified against the original executable.

**User clarification, 2026-11-23 (axis follow-up):** Vanilla dungeon blocks must
not be rejected merely because an action's raw axis lies outside the known enum.
Keep the recognized action, original parameters and required graph-link checks.
Retain exceptional-axis interpretation/provenance separately with gameplay-owner
readiness pending; document applicable DFU defaults and special cases rather than
guessing motion or discarding the action. Verify the complete pinned RDB corpus
and preserve existing identities. Structural import does not certify action
execution, geometry resources, connections, actor placement or SAVE. This does
not waive malformed-data checks or authorize unknown authored action semantics.

## Read the relevant documents

Start with the assigned `design_docs/development/tasks/IMP-NNN.md`. Read its linked feature specifications, applicable approved GAD decisions, prerequisites and supporting contracts. Inspect the affected implementation and callers. Expand into adjacent owners or source analysis when a dependency, ambiguity or failure requires it. Avoid loading the entire design catalog for each task.

- Gameplay authority lives in `design_docs/design/systems/<SYSTEM>/<FEATURE>.md` and [GAMEPLAY_DECISIONS.md](design_docs/design/GAMEPLAY_DECISIONS.md).
- Architecture authority is the **approved decisions** in [ARCHITECTURAL_DECISIONS.md](design_docs/analysis/architecture/ARCHITECTURAL_DECISIONS.md). Individual review proposals retain their recorded status.
- Delivery order and acceptance gates live in [TASK_BACKLOG.md](design_docs/development/TASK_BACKLOG.md), [DEPENDENCY_GRAPH.md](design_docs/development/DEPENDENCY_GRAPH.md), [MILESTONES.md](design_docs/development/MILESTONES.md), and [IMPLEMENTATION_READINESS.md](design_docs/development/IMPLEMENTATION_READINESS.md).
- [The second audit](design_docs/development/PRE_IMPLEMENTATION_AUDIT_2.md) records current planning readiness. The first audit is historical. Relevant development contracts refine approved task choices.

## Architecture and ownership

- Give each authoritative fact one domain owner. Use validated owner requests and read-only projections across boundaries.
- CORE owns session lifetime and requester-scoped gates. DATA owns resolved definitions. MOVE owns physical pose, WORLD geography/residency, and LOC layouts.
- CHAR owns actor/vital state, ITEM possessions/custody, MAGIC effects, QUEST runtime facts, FACT standing/politics, LAW legal state, and ECON settlement.
- SAVE coordinates owner-defined snapshots and restore. UI/AV present owner results. Preserve stable identity, scoped callbacks, ordered commitment, and retained outcomes on retry/load.
- Follow task-specific clock, RNG, content publication, settlement and persistence contracts. Never silently redesign approved mechanics or treat reference-source behavior as automatic approval.

## Implementation and dependencies

1. Confirm implementation authorization and delivered prerequisites. READY describes planning status. It does not establish completed prerequisites.
2. Implement the assigned increment through normal entry points. Reuse existing logic and keep changes focused. Preserve user work and unrelated behavior.
3. Use descriptive names, explicit interfaces and readable Godot conventions. Document units, ownership and non-obvious ordering. Avoid speculative frameworks, unrelated refactors and formatting churn.
4. Reuse shared validators and owner contracts. Follow verified dependency waves instead of numeric IMP order. Keep named joint checks open until real providers pass.
5. Pin new libraries, build options and relevant licenses/provenance. Verify Windows export compatibility where required. Preserve approved media/mod runtime selections. Explain a material dependency or toolchain change before adopting it.

### Integration and performance checks

- When changing shared startup, publication or query paths, assess their cost with the complete current adapter composition and realistic data volumes. Small fixtures alone do not establish acceptable scaling.
- Avoid whole-catalog copying or repeated graph construction for point queries. Prefer owner-maintained, validated lookup indexes and narrowly scoped detached projections. Preserve ownership, atomic publication, candidate tickets and content locking.
- Before repeating expensive preparation, identify what could have changed since the previous validation. Reuse preparation only within a verified scope that preserves freshness and failure handling.
- For preference UI changes, verify the actual stock control handler through its owner interface. Check application outcome independently from persistence, including rejection, failed saving and fresh-process relaunch.
- When an integration defect or performance problem escapes existing tests, add maintained coverage at the boundary that missed it. Record before/after measurements without inventing budgets or weakening assertions.

## Git workflow

- The user reviews changes, creates commits, and pushes through GitHub Desktop. Leave changes uncommitted unless explicitly instructed otherwise.
- Use Git status, diffs, and history to understand existing work and verify your changes.
- Do not commit, push, switch branches, merge, rebase, or change remotes without explicit authorization.
- Preserve existing user changes. Never discard or overwrite unrelated work.
- Keep classic data, reference material, generated caches, credentials, and machine-specific files out of commits.
- Report changed files, validation results, and remaining issues for the user's review.

## Verification and completion

### Iterative UI polish — user preference, 2026-11-26

For small presentation iterations, use the repository's
[fast-ui-polish skill](.agents/skills/fast-ui-polish/SKILL.md). Default to a focused
rendered preview and affected control/focus/scrolling checks. Batch broader
regressions after several approved changes; run exports/comprehensive checks at
presentation checkpoints. This refines the per-iteration headless/rendered cadence
below for visual-only changes. Functional/owner-boundary changes need appropriate
targeted verification, and named acceptance gates remain required at their actual
checkpoint. Record deferred checks accurately. Do not rerun the full creator and
both exports, or scan all historical artifacts, for every spacing/color tweak.

- Select checks for the changed behavior and its affected callers; unrelated IMP
  work does not automatically require the dungeon stress suite. Run heavy suites
  and exports one at a time to reduce desktop hitches (user preference discussed
  2026-11-23). Parallelize lightweight independent inspection where useful.
- Run the task's automated and manual checks through production interfaces with disposable storage. Control seed, clock and input where relevant.
- Use independent headless and rendered commands under IMP-003/DEV-014. Run the rendered suite for frame, presentation or playback behavior and exported checks where the task requires them.
- Assert rejected, interrupted, repeated and restored outcomes as specified. Record fixture/build identity, expected/actual results, and unavailable or skipped checks.
- Controlled providers verify interfaces. Milestone acceptance requires the named real integrations. Never mark unverified functionality complete or count an unavailable required check as passing.
- Report implemented scope, verification evidence, remaining integration obligations and blockers.
- Keep `.runs` small: after verification, preserve compact reports/logs and necessary reviewed captures, then remove disposable copied projects, exports, dependency copies and caches. A report reference does not justify retaining its entire build. Retain a full build only for an active, concrete debugging/review need, with a recorded expiry. Follow [RUN_ARTIFACT_CLEANUP.md](design_docs/development/RUN_ARTIFACT_CLEANUP.md), protect unique inputs and active roots, and record cleanup.
- **Standing cleanup authorization:** Routine cleanup of understood, inactive, reproducible outputs inside `main_project/tests/.runs/` is already authorized as part of verification. Do not ask for a new task-level confirmation for each cleanup batch or chat. Apply the cleanup guide's path, activity and evidence-preservation checks. Prefer ordinary workspace access and reliable non-elevated activity evidence; do not introduce an elevated process-query dependency when adequate evidence is already available. Defer uncertain targets and report them instead of requesting permission to delete them blindly. This authorization excludes unique inputs, required evidence, authoritative files, installed tools and external data; it does not override host-enforced permissions or authorize changing security settings.

## Documentation and clarification

Update the task's execution/progress evidence, affected contracts and prerequisite links with the implementation. Preserve stable feature/IMP IDs and approval history. Synchronize backlog/readiness or milestone records when their status changes.

Resolve routine engineering details within approved contracts and record them alongside code and fixtures. Stop the affected work and request clarification when requirements materially conflict, essential behavior is unspecified, a change would alter approved gameplay/architecture or scope, a required dependency cannot satisfy its contract, or verification requires unavailable essential inputs. State the concrete gap and proposed options. Continue independent authorized work where possible.
