# Coding agent instructions

## Objective and target

Build the approved Daggerfall-style RPG in **Godot 4.7.2**, progressing through playable vertical slices in [the roadmap](design_docs/development/ROADMAP.md). Verify Windows first and preserve the approved platform adapter boundaries.

- Keep `reference_material/` (including `reference_material/daggerfall-unity-1.1.1-cve-2025/`), `base_data_files/`, and external classic data read-only. Use DFU as evidence for specified behavior.
- Create recreation code in `main_project/`, which contains `project.godot` and is the game directory for IMP-001. Repository-relative documentation paths start at this repository root; Godot `res://` paths start at `main_project/`.
- Use **GDScript** for the main game, UI and tools, and **C++ GDExtensions** for native adapters, as approved by the user on 2026-11-18. Follow existing project conventions within that split. Approved mod languages are Luau for restricted scripts and GDScript for trusted scripts. Native media/runtime adapters follow the linked contracts.

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

## Git workflow

- The user reviews changes, creates commits, and pushes through GitHub Desktop. Leave changes uncommitted unless explicitly instructed otherwise.
- Use Git status, diffs, and history to understand existing work and verify your changes.
- Do not commit, push, switch branches, merge, rebase, or change remotes without explicit authorization.
- Preserve existing user changes. Never discard or overwrite unrelated work.
- Keep classic data, reference material, generated caches, credentials, and machine-specific files out of commits.
- Report changed files, validation results, and remaining issues for the user's review.

## Verification and completion

- Run the task's automated and manual checks through production interfaces with disposable storage. Control seed, clock and input where relevant.
- Use independent headless and rendered commands under IMP-003/DEV-014. Run the rendered suite for frame, presentation or playback behavior and exported checks where the task requires them.
- Assert rejected, interrupted, repeated and restored outcomes as specified. Record fixture/build identity, expected/actual results, and unavailable or skipped checks.
- Controlled providers verify interfaces. Milestone acceptance requires the named real integrations. Never mark unverified functionality complete or count an unavailable required check as passing.
- Report implemented scope, verification evidence, remaining integration obligations and blockers.
- Keep `.runs` small: after verification, preserve compact reports/logs and necessary reviewed captures, then remove disposable copied projects, exports, dependency copies and caches. A report reference does not justify retaining its entire build. Retain a full build only for an active, concrete debugging/review need, with a recorded expiry; review total retention above 2 GiB. Follow [RUN_ARTIFACT_CLEANUP.md](design_docs/development/RUN_ARTIFACT_CLEANUP.md), protect unique inputs and active roots, and record cleanup.

## Documentation and clarification

Update the task's execution/progress evidence, affected contracts and prerequisite links with the implementation. Preserve stable feature/IMP IDs and approval history. Synchronize backlog/readiness or milestone records when their status changes.

Resolve routine engineering details within approved contracts and record them alongside code and fixtures. Stop the affected work and request clarification when requirements materially conflict, essential behavior is unspecified, a change would alter approved gameplay/architecture or scope, a required dependency cannot satisfy its contract, or verification requires unavailable essential inputs. State the concrete gap and proposed options. Continue independent authorized work where possible.
