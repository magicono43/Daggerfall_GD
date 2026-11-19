# CORE-012 — Starting grants and opening quests

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Complete a new character's initial resources and opening content before playable entry, preserving player choice in the optional tutorial.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Preserve the DFU baseline of class-dependent equipment/spells plus biography-derived effects/rewards. ITEM, MAGIC and CHAR own exact tables/formulas; this does not approve every quantity or class rule.
- Retain the standard tutorial and main-story opening represented by _TUTOR__ and _BRISIEN. The vanilla tutorial is optional: its quest can offer continuation and the player may accept or decline. Initializing the tutorial offer does not make participation mandatory. Exterior start still initializes required opening content; tutorial steps must respect intentional exterior placement, with exact adaptation owned by QUEST.
- Apply biography effects before starting grants; capture progression baseline after all starting skill changes. Initialize required economic/regional/weather state and opening quests before revealing the scene or releasing entry-owned suspension. Required failure uses safe-entry recovery.

Second interview, confirmed by the user on 2026-11-05:

- Quests execute/initialize through their own running logic. After new-character content is loaded and ready, present tutorial and main-quest opening before granting player control. Do not interpret required pre-entry initialization as completing whole quests or running every delayed quest action while loading. The exact initial-presentation handoff and authored delays require clarification with QUEST.
- Missing required biography effects, grant definitions or main-story initialization fail entry. Tutorial initialization failure warns once and continues without the optional tutorial. A class legitimately entitled to no starting spells is a valid result.
- Track successful startup steps within new-session context to prevent duplicate gold/items/spells/opening quests on repeated callbacks. Failed-entry retry constructs clean replacement under CORE-007 rather than retaining partial awards. Save loading restores state without rerunning fresh-character grants.

Third interview, confirmed by the user on 2026-11-05:

- Gate control only for immediate opening presentations. Later timers, letters and main-quest events retain authored triggers; do not wait for future events or fast-forward time to reach them during startup.
- Present opening popups sequentially through a queue: dismissing one exposes the next. Use a defined order preserving intended DFU sequence after verification. Keep control gated through immediate messages/acknowledgments and tutorial accept/decline. Declining tutorial does not skip main-story opening. The user identified DFU popup queuing as the intended interaction model, not a request for overlapping windows.
- Later startup-quest registration may declare dependencies and required/optional failure policy. Do not make every mod startup quest mandatory or bypass readiness/duplicate protection. QUEST/MOD own exact registration and ordering contracts.

## Inherited requirements

CORE-010 separates baseline construction from new-character grants and prevents duplicate initialization/rewards. CORE-011 defines validated interior/exterior placement, initial time and no gameplay advancement before required startup completes. CORE-007 coordinates stable requests, outcomes and safe retry; CORE-005 owns scope safety. CORE-001–006 and CORE-008 remain unchanged; CORE-009 stays deferred. Save-load routes must not execute new-character grants as if they were fresh starts.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/Utility/StartGameBehaviour.cs`, StartNewCharacter: biography effects, replaceable gear/spell delegates, skill baseline capture, account/house/region/weather initialization, unpause/fade, then _TUTOR__, _BRISIEN, optional LaunchQuest and InitAtGameStartQuests. SetStartingSpells chooses class sets and uses a Spellsword set for custom classes with qualifying primary/major magic skills; unresolved spells log and skip.

`Assets/Scripts/Game/Items/ItemHelper.cs`, AssignStartingGear: clothes, spellbook, class weapon(s), gold and conditional lights. `Assets/Scripts/Game/Questing/QuestListsManager.cs`, InitAtGameStartQuests starts loadable registered quests and skips failed loads. Tutorial participation behavior resides in `Assets/StreamingAssets/Quests/_TUTOR__.txt` rather than being inferred from its startup invocation alone.

Baseline: local DFU 1.1.1 Release; exact commit unavailable per repository overview. Static inspection only; source remains unchanged. Exact original content rules are not adopted by implication.

## Detailed rules and behaviors

Execute this feature only for fresh-character entry after CORE-010 baseline construction, with validated character/start inputs and CORE-011 placement readiness coordinated by CORE-007. Loads restore previously saved state rather than invoking fresh grants. Stable session/operation context must prevent repeated callbacks from granting resources or starting opening quests twice.

Apply biography effects before starting equipment/spell grants. Character creation must define which biography effects have already been reflected in the character document so effects are not applied twice. CHAR, ITEM and MAGIC specify exact effects, grant tables, eligibility and quantities, using the DFU baseline as agreed. A valid empty spell grant is different from an unresolved required spell definition. Capture the progression baseline after all starting skill changes so initialization is not counted as earned advancement.

Owner-initialize required accounts/property, regional and climate/weather context for this character without copying previous-character state. ECON, FACT/WORLD and TIME/AV owners define actual values. This does not grant a house/ship by implication or invent starting reputation/weather distributions. Verify required definitions and startup contracts in preflight where possible; required application/initialization failure after replacement invokes safe cleanup/retry rather than accepting a partial playable character.

Register/initialize the standard _TUTOR__ and _BRISIEN opening content and any approved registered startup entries. Distinguish registration/preparation from running whole quest scripts to completion. Required main-story initialization must succeed; tutorial content initialization may fail with one warning and allow play without tutorial. Tutorial optionality means both a legitimate player decline and a supported content-failure bypass, not omission of its offer on every successful start.

Once world/character/resources and required initialization are loaded and ready, allow quest-owned immediate presentation logic to produce the opening content through UI's ordered popup queue. Preserve the intended original sequence once verified rather than assuming the order of StartQuest calls proves visible message order. Show one popup at a time; dismissal/answer advances the queue. Keep player control withheld while the immediate opening batch is being presented. Declining the initial tutorial offer ends participation but does not suppress required main-story presentation. The tutorial's later authored continuation/end choices remain QUEST-owned.

Define the immediate batch's completion explicitly between QUEST and UI: temporary queue emptiness before a pending opening callback arrives is not proof of completion. Conversely, a quest waiting on a later timer, letter, location trigger or other normal-play event must not keep startup waiting. Prepare immediate logic without advancing gameplay time, enabling movement/falling or allowing AI attacks, consistent with CORE-011. Do not fast-forward clocks to generate future quest events. Exact quest stepping/API is deferred; the contract must avoid deadlock with suspended gameplay.

Loading coverage protects incomplete world construction. When scene/required initialization is ready, reveal enough to present the opening popups while retaining control suspension. Full playable-entry completion requires the immediate batch to have finished and the tutorial offer answered or bypassed on initialization failure. Release only entry-owned suspension afterward; other modal/pause owners retain authority. Required startup success, popup interaction and playable-session readiness are distinct milestones, not one optimistic OnStartGame notification.

Additional startup quests follow a declared deterministic dependency/order contract under QUEST/MOD. Optional failure warns/diagnoses according to that contract; required failure prevents entry. A package cannot become mandatory merely because it registers a startup entry. Validate conflicting dependencies/definitions instead of relying on incidental subscriber order. No arbitrary LaunchQuest override or mod API is approved solely because DFU exposes one.

## Relevant formulas and parameters

No new numerical balance formulas are approved here. Required ordering: biography effects before grants; progression baseline after initial skill changes; required initialization before scene reveal/presentation and playable control. Exact grant quantities, spell tables, initial economics/region/weather values and quest timers belong to their owners. Popup presentation is sequential; immediate startup content is finite and distinct from future authored events. This specification adds no generic quest-start timeout or automatic time advance.

## Required data

Validated character/biography inputs, class/custom-class information, grant definitions/eligibility, initialized skill baseline, economic/regional/weather initialization results, opening quest identities/dependencies/requiredness and per-session completed-step results. Presentation requires originating context, immediate-batch completion state, ordered popup requests and tutorial accept/decline/bypass status. Exact schemas and quest identifiers outside the standard opening remain deferred.

## Inputs, outputs and events

Inputs: fresh entry context, biography/grant data, owner initialization outcomes, quest registration/execution outcomes, popup acknowledgment and tutorial choice. Outputs: granted resources/effects, initialized progression/economic/regional/weather state, running opening quests, sequential presentation, tutorial participation result, and startup-ready or failure outcome. API/signal names remain deferred. No save-load-complete signal should invoke this feature's fresh rewards. Diagnostics follow CORE-002 privacy rules.

## Cross-system interactions

CHAR owns biography semantics, skill baselines and progression; ITEM owns equipment creation/equip rules; MAGIC owns spell definitions/grants. ECON owns accounts/property initialization, FACT/WORLD regional context and TIME/WORLD/AV weather/time ownership as later specified. QUEST owns authored startup logic, tutorial choice and later events. UI owns popup queue/focus and acknowledgments. MOD/QUEST define later startup registration. CORE-011 provides ready placement/loading coverage; CORE-007 coordinates operation result; CORE-005 lifecycle safety and CORE-010 baseline/idempotence remain mandatory. CORE-009 stays deferred.

## Edge cases and failure conditions

- A class with no starting spells succeeds; a required grant referencing missing content fails rather than silently awarding a different resource.
- Biography effects must not be duplicated between character-document construction and startup application. Starting skill changes must precede progression baseline capture.
- Duplicate grant/quest callbacks must not multiply gold, equipment, spells or quest instances. Failed-entry retry clears partial replacement and reconstructs; it does not keep partial awards or restart completed steps on the same live session.
- Tutorial decline is a valid player outcome. Missing/failed tutorial initialization warns once and permits entry; required main-story failure does not silently continue as a storyless start.
- Exterior start preserves required opening content while avoiding tutorial assumptions about being deep inside the dungeon. QUEST must define exact adaptation; no invented replacement instructions are approved here.
- Popup queue completion must account for in-flight immediate producers and avoid both premature control release and waiting forever for future quest timers. Later messages retain authored scheduling during normal play.
- Startup presentation must not require gameplay-time advancement blocked by CORE-011. Failure to initialize immediate quest logic is reported under its required/optional policy, not hidden by enabling combat early.
- Ending/replacing a session invalidates queued old-session popup requests and callbacks. They cannot award resources or present an old tutorial over a new character.
- Mod dependency/order conflicts and mandatory/optional status require explicit contracts, not incidental load order. Exact conflict-resolution rules remain QUEST/MOD scope.

The feature approves no additional rewards, automatic saves, tutorial completion requirement or gameplay-time fast-forward. Main risks are duplicate grants, progression distortion, tutorial/story coupling and premature player control.

## Configuration and balancing options

Use DFU's starting-resource baseline, with exact balance content reviewed under CHAR/ITEM/MAGIC. Tutorial participation is a quest offer, not a mandatory prerequisite for playing. CORE-011's exterior preference is retained. Later mods may register startup content through a defined contract; this does not approve exact mod precedence, replacement tables or alternate-start narrative. Runtime preference application remains CORE-006 scope.

## Save/load considerations

Existing saves are not modified by starting a new character. This feature performs no automatic save. SAVE later captures actual granted inventory/spells/effects, progression baseline, economic/regional/weather state and active quest/tutorial state through their owners. Save loading restores these instead of rerunning fresh grants or reoffering the initial tutorial indiscriminately. Resuming saved modal/tutorial presentation is UI/QUEST/SAVE scope and is not fully specified here. Per-entry execution markers and popup handles are not universal durable character identities.

## Technical constraints

Target project engine: Godot 4.7.2. Use explicit owner operations and dependency ordering with truthful results rather than arbitrary callback ordering. Maintain session-safe grant/quest identities and independent UI processing while gameplay is gated. The UI queue and quest scheduler are separate concerns; queued windows do not alone prove quest startup complete. Concrete APIs, item/spell definitions, initialization schema, original visible popup order and quest stepping mechanism remain verification/implementation dependencies.

## Acceptance criteria

1. Fresh new characters receive class/biography baseline resources under owner-approved rules. Exact quantity/table approval remains separate; valid no-spell eligibility succeeds.
2. Biography effects apply once before grants, and progression baseline captures all starting skill changes without treating them as earned advancement.
3. Required account/property/regional/weather initialization succeeds before startup presentation/control, without inheriting old-character state or implying new property rewards.
4. Standard tutorial/main-story opening initializes. Tutorial offer permits acceptance/decline and later authored choices; declining does not skip main-story content.
5. New-character content and placement are ready before opening presentation; player control stays gated through the immediate opening batch. Movement/falling/AI attacks/gameplay-time advancement do not occur during initialization.
6. Popups present sequentially in the verified intended order. Completion accounts for in-flight immediate producers; a momentarily empty queue does not release control prematurely.
7. Later tutorial timers, letters and story triggers retain authored behavior. Startup neither waits for future events nor fast-forwards time to reach them.
8. Required biography/grant/main-story startup failure invokes safe entry recovery. Tutorial initialization failure warns once and continues without tutorial.
9. Duplicate callbacks cannot repeat grants or opening quest instances. Retry uses clean replacement/fresh validation; loads restore state without rerunning fresh-character rewards.
10. Exterior start still initializes required story content and uses QUEST-defined tutorial adaptation rather than treating it as an unintended missing-dungeon failure.
11. Later startup registration declares dependencies/order/requiredness and respects readiness/idempotence. Not all mod entries are implicitly mandatory.
12. Full entry success and release of entry-owned suspension occur only after required startup and immediate presentation finish; other pause/modal owners remain respected. Stale old-session popups/results are rejected.

These are future verification criteria. No implementation/runtime tests or full original visible-popup-order verification have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001–008 and CORE-010–011 v1, CORE-009 deferral, decision log, CORE catalog and CORE architecture review. All nine CORE-012 interview decisions are represented. No conflict identified: CORE-011's loading gate covers required construction/initialization, then immediate presentation occurs in the ready scene while control remains gated. Quests may run presentation logic without advancing gameplay time; later authored events remain normal-play work. Tutorial optionality is preserved and main-story requiredness is distinct. Exact balance and QUEST/MOD APIs are not approved by implication.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Owner specifications must establish exact biography/grant values, initial economics/region/weather, original visible opening order, immediate-batch completion signaling, exterior tutorial adaptation and startup registration/conflict rules. These dependencies must be resolved before implementation is considered complete; no assumed popup or scheduler API replaces them.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-012. This document is finalized v1. Approval reference: CORE-012-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented dependencies and deferrals remain open, including exact grant tables, original visible popup order and exterior tutorial adaptation. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
