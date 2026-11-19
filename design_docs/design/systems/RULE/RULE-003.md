# RULE-003 — Shared state and reseeding

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Give random sources explicit purposes and lifetimes, preventing unrelated generation, presentation and initialization from changing gameplay sequences through shared-state reseeding.

## Intended player experience

Gameplay chances follow their owning rules without luck resets caused by menus, rendering or location changes. Loading successfully permits fresh unresolved gameplay rolls. Saved facts and retained rewards stay fixed. Developer inspection does not change the outcomes being investigated.

## Confirmed requirements

RULE-003-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish purpose-separated gameplay streams, normal advancement without per-call reseeding, isolated initialization, fresh gameplay sources after successful loads, retained resolved outcomes, retry reuse, isolated diagnostics, transition continuity and protected load/content boundaries.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#BonusPool` calls UnityEngine.Random.InitState(Time.frameCount), then draws an inclusive 4–6 pool through Range(4,7).
- `FormulaHelper#CalculateHitPointsPerLevelUp` sets DFRandom.Seed from Time.renderedFrameCount before drawing health. `RollMaxHealth` invokes it repeatedly in a synchronous loop. Unchanged frame count and inputs repeat the same initial draw; actual runtime frequency remains unverified.
- `Game/Questing/QuestMachine.cs#ParseQuest` calls UnityEngine.Random.InitState(internalSeed.Next()); internalSeed is a separate System.Random instance.
- `Game/Utility/Dice100.cs` draws from Unity's shared random source. `API/DFRandom.cs` maintains separate static classic state and one SaveSeed/RestoreSeed slot. `FormulaHelper#GenerateBuildingName` reseeds that classic source.

These inspected paths confirm shared-state mutations; effects on unrelated outcomes depend on actual caller order. No comprehensive DFU save-state audit or runtime sequence test was performed. Baseline is the local DFU 1.1.1 Release snapshot; exact commit is unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source remains unchanged.

## Detailed rules and behaviors

### Purpose and ownership

Use explicitly owned gameplay sources separated by declared purpose, including combat, progression, loot and quest generation. A draw or source initialization for one purpose cannot advance or reseed another purpose's source. Supply the appropriate source to calculations rather than using an engine-global random source implicitly.

The exact stream inventory and any finer actor/encounter subdivision remain owner/engineering contracts. This specification does not require a separate stream per actor, item or action. Within one declared stream, its authorized draws advance in their actual approved order; purpose separation does not promise identical outcomes after gameplay inputs, scheduling or draw counts change.

Keep presentation, previews and diagnostic test generation separate from gameplay sources. Classic compatibility operations retain their independently owned RULE-002 state and explicit deterministic seeds. Declaring a quest/loot gameplay purpose does not override a feature's explicit deterministic-generation or persistent-assignment policy.

### Initialization and normal advancement

Initialize a source at its declared session or generation-operation boundary. Thereafter let it advance normally throughout that lifetime. Do not reseed per calculation, frame or action. A newly authorized deterministic operation can initialize its own source once from its approved seed; do not reset an existing session stream to accomplish this.

Seed allocation must not consume another purpose's draws. Exact entropy acquisition, seed derivation, stream keys and nonclassic algorithm remain engineering choices. Frame/render counts cannot determine per-call resets. Fresh initialization does not guarantee unique seeds, differing rolls or better outcomes.

New games establish fresh session gameplay sources. Pauses, menus, ordinary scene changes and interior/exterior transitions preserve those sources and their current state. Ending the session releases its sources and outstanding work under CORE-005; a later character cannot inherit them.

Preserving state through pause does not authorize automatic simulation while paused. CORE eligibility remains binding. Explicitly approved UI-driven generation or simulated activity uses its own owner's authorization; drawing is not globally forbidden merely because ordinary simulation is suspended.

### Successful and unsuccessful loads

Every successful load establishes fresh session gameplay streams, including combat, progression, loot and quest generation, before new checks run. Ordinary saves do not force replay-identical continuation of these streams. Fresh initialization affects future unresolved outcomes, permitting reload-to-reroll play without promising a different result.

Restore already generated loot, accepted quests, assigned names, prepared rewards and other saved facts as facts. Do not reconstruct them by making new rolls or reapply their consequences. An operation whose result was already retained under another approved specification remains retained even though a fresh source will serve future requests.

Prepare candidate load sources independently of a surviving session. Activate them only at successful session handoff. Failed/cancelled loads cannot consume, reseed or replace surviving-session sources. This does not promise that every load failure can recover the previous session; CORE entry/restore recovery still controls whether it survives at all.

### Resolved results, retries and ordering

Once a random result has resolved, technical delivery/application retries within that session reuse it rather than rerolling. Do not apply consequences twice. Owner-defined attempt identity and result lifetime distinguish retries from genuine new attempts; no universal event-history schema is selected here.

This rule is not permission to retry partially applied mutations blindly. Owners retain explicit application/commit state and use safe recovery where exact retry is unavailable. Nor does it require global rollback of every consumed draw when an operation fails: preserve resolved results when retrying, and define any pre-resolution failure behavior through the owner.

CORE-017's explicit stable consumer ordering and completed-consumer tracking remain binding. Any asynchronous consumers sharing a purpose source must define their draw order or use explicit owner-approved subdivisions; accidental callback races cannot stand in for a declared ordering contract. Exact scheduling/subdivision belongs to those owners.

### Diagnostics and configuration boundaries

Ordinary inspection, result queries, logging, preview refresh and rendering never advance or reseed live gameplay sources. Reproducing a problem may use isolated seeded test sources with captured inputs/draw order. This is developer support, not a promise that an ordinary save alone reproduces the prior session's future rolls or that every live draw is logged.

Ordinary settings changes cannot reset sources. Content/mod refreshes cannot silently replace/reseed active streams or bypass DATA-003's content lock. Any future supported source/algorithm/content change requires an explicit approved lifecycle boundary and retained-outcome policy. No runtime mod-refresh feature or player seed control is introduced here.

## Relevant formulas and parameters

For purpose p with state S_p, a valid draw advances only S_p according to its selected algorithm. Drawing/initializing purpose q, q different from p, leaves S_p unchanged. Initialization may derive sources independently from shared initialization material, provided it does not advance another purpose's source; the concrete derivation is unselected.

RULE-001 defines integer percentile mapping, one logical draw including guaranteed checks and diagnostic fields. RULE-002 defines opt-in classic transitions, seed/range domains and compatibility mapping. This feature selects no new numeric constants, seed widths for nonclassic sources, probability corrections or gameplay formulas.

## Required data

Declared purpose and lifetime; owning session/operation identity; valid source and current private state; initialization context; algorithm/version information sufficient for diagnostics and any required deterministic reconstruction; and owner-required attempt identity, resolved result and application status. Concrete schemas and full stream inventory remain dependencies. Persist only the outcomes/reconstruction information required by owning specifications; session RNG continuation is not made a normal-save requirement.

## Inputs, outputs and events

Inputs: authorized new-session/load/operation initialization, source requests, gameplay draws, retained-result delivery/retry and session termination. Outputs: explicitly scoped sources, resolved results, or explicit lifecycle/source errors. Only declared boundaries activate replacements. Event/API names and a universal RNG service interface are not selected. Random source ownership alone does not authorize gameplay mutations.

## Cross-system interactions

RULE-001 owns percentile semantics/fresh-load checks; RULE-002 owns classic operation sequences. COMBAT, CHAR progression, ITEM/loot, QUEST and other consumers define stream purpose, request order and attempt/result lifetimes. CHAR-006/008/015 retain creation/prepared reward outcomes. DATA-015/016/017 isolate previews/text refresh and preserve assigned values. CORE-005/007 and SAVE coordinate ownership/readiness/handoff/recovery; CORE-015/016/017 govern eligibility and ordered execution. DATA-003 retains content locks. DEV/UI/AV observe without modifying gameplay randomness.

## Edge cases and failure conditions

- Repeated same-frame calls advance normally rather than repeating a frame-seeded first draw. Coincidentally equal outputs remain valid.
- Missing/duplicate required sources, undeclared purpose or stale-session requests fail explicitly under owner/CORE recovery; do not silently create a global replacement or borrow combat's source.
- Candidate load initialization cannot touch surviving state. Source activation cannot publish a partially restored playable session.
- A retry after a resolved result uses that result; duplicate delivery cannot grant rewards or apply damage twice. A new legitimate attempt may draw again under its owner rules.
- Accepted/generated saved content does not reroll on load; future unresolved content requests may use fresh session randomness unless explicitly deterministic.
- Scene destruction/rebinding, pauses and settings changes cannot accidentally reinitialize session sources.
- Source/entropy initialization failure blocks required gameplay readiness with explicit recovery rather than fabricated random outcomes or a hidden fixed-seed fallback.

## Configuration and balancing options

Purpose names, supported subdivision and algorithms require explicit owner/engineering contracts. No user luck reset, seed slider, hidden streak correction or universal RNG mod hook is approved. Validated mods may influence owner-approved gameplay rules without obtaining implicit permission to reseed unrelated sources. Deterministic generation/retained-outcome changes follow their existing version/migration contracts.

## Save/load considerations

Successful loads start fresh session gameplay streams; exact continuation state is not required for ordinary saves. Persist resolved facts and any explicitly retained pending results/application metadata needed to avoid reroll or duplicate application under owner/SAVE rules. A save from before an unresolved attempt can yield a new roll after loading; a save containing an already retained result restores it unchanged. Classic persistent reconstruction retains sufficient versioned inputs under RULE-002 rather than taking fresh gameplay randomness. Concrete resumable-operation/save-atomicity policies remain SAVE/owner dependencies.

## Technical constraints

Target: Godot 4.7.2. Avoid engine-global implicit gameplay RNG, frame-dependent reseeding and global seed swapping. Bind sources to declared session/operation lifetimes, reject stale work and keep candidate load state isolated. Select nonclassic algorithms, seed allocation, concurrency strategy and serialization only within these constraints. No implementation, RNG framework or coding tasks are authorized by this draft.

## Acceptance criteria

1. Extra draws/initialization in one declared purpose leave other purposes' sequences unchanged when their own inputs/draw schedules remain fixed.
2. Repeated same-frame requests advance their owned source without reseeding; deterministic operations initialize once from their explicit seeds.
3. New games and every successful load establish fresh session gameplay streams before gameplay; verification observes initialization rather than requiring random results to differ.
4. Pauses, menus, ordinary scene/location changes and settings changes preserve session stream state. Eligibility still governs whether an operation may draw.
5. Failed/cancelled loads leave any surviving session's sources untouched; incomplete candidate sources never become active gameplay state.
6. Saved assigned/generated facts and retained rewards restore unchanged. Technical retries reuse resolved results and do not duplicate consequences.
7. Inspection, logging, rendering and previews consume no live gameplay draws; seeded diagnostic reproduction runs on isolated sources.
8. Ended-session callbacks cannot use replacement-session sources. Required source failures invoke explicit safe recovery without global/fixed-seed fallback.
9. Approved content locks, classic operation isolation and stable consumer ordering remain intact. Shared-source asynchronous ordering is explicitly defined before integration.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this design interview.

## Consistency review

No direct contradiction identified with reviewed RULE-001/002, CORE-005/015/016/017, DATA-003/015/016/017 and CHAR-006/008/015. Fresh gameplay streams preserve reload-to-reroll while retained results remain fixed; independent classic operations retain their explicit seed behavior. Location continuity matches session ownership; suspension preserves state without permitting automatic simulation. Stable within-stream order remains relevant despite purpose separation. DATA-003's content lock is not relaxed. RULE-AR-01/GAD-06 proposals are not approved wholesale; exact algorithms/topology/serialization remain dependencies.

## Outstanding questions and approval

No blocking gameplay policy question remains for this ownership/lifecycle feature. Before implementation: establish full purpose inventory and subdivisions, nonclassic algorithms/seed allocation, source/error interfaces, shared-stream ordering, attempt/result retention and application contracts, and load activation/save recovery integration. These cannot waive purpose isolation, fresh successful-load initialization, retained outcomes or declared reset boundaries.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-003-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
