# CORE-013 — Native save session entry

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Restore a selected save created by this Godot implementation, with truthful completion and safe recovery rather than compatibility work on other games' save formats.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Focus on saves functioning with this Godot Daggerfall implementation. DFU and classic Daggerfall save compatibility are outside current scope and must not distract this work. Naming CORE-014 in reference documentation does not authorize classic-import work.
- Restore saved character, world location, time and supported ongoing activities without rerunning tutorial/opening initialization or starting grants. Preserve application preferences separately. Publish distinct Session Restored notification only after required restoration/readiness.
- Native-load preflight failure preserves the current session and offers error/retry/choose-another-save recovery. After replacement begins, use safe cleanup and independent error UI. Never silently choose another save or report false success.

Second interview, confirmed by the user on 2026-11-05:

- Use explicit native save-format versions. Validate supported migrations before replacing the current session. Reject unsupported newer/older versions without supported migration with an explanation; do not silently default incompatible character data.
- Reject missing/invalid required character/world/quest data. Rebuild explicitly disposable data such as visual caches. Other optional-data recovery requires an owner-defined policy and disclosure before proceeding.
- Check required content/mod dependencies before replacement. Missing required definitions block load with explanation. Optional differences require owner-defined safe handling; no silent substitution of unrelated items/quests/locations. SAVE/MOD own precise package rules.

Third interview, confirmed by the user on 2026-11-05:

- Restore saved location/pose/movement context after geometry/collision readiness. Validate contextually: airborne/swimming saves need not have a floor immediately beneath them. Only MOVE/LOC-defined bounded corrections are permitted; invalid restoration fails safely rather than teleporting to unrelated locations.
- Restore authoritative activity/quest state through owner contracts and rebuild supported UI from it, not serialized window objects. SAVE/owners define save eligibility and resume behavior. Unsupported required activity state fails validation rather than abandoning obligations or repeating transactions.
- Keep loading coverage/gameplay suspension through required restoration, reference linking, derived-state rebuilding and supported UI restoration. Reveal, clear stale load-trigger input and emit Session Restored once. Release only load-owned suspension; restored modals/other owners may still block gameplay. Show loaded only after actual success.

## Inherited requirements

CORE-007 coordinates all session changes including quickload: stable selected identity, consistent prepared input, discard consent for living sessions, preflight cancellation, busy rejection and truthful terminal outcomes. CORE-010 initializes clean baseline before restore without wiping restored values. CORE-005 controls scope/readiness/cleanup; unsafe cleanup blocks new sessions. CORE-001–006 application storage/settings/preferences remain independent. CORE-008 death return does not auto-load. CORE-009 is deferred. CORE-011/012 new-character placement/grants do not rerun on native load.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/Utility/StartGameBehaviour.cs`, LoadDaggerfallUnitySave ignores index -1, enumerates saves and calls SaveLoadManager.Load. SaveLoadManager_OnLoad may consume optional LaunchQuest. `Assets/Scripts/Game/Serialization/SaveLoadManager.cs`, Load starts a coroutine and shows gameLoaded at initiation. LoadGame resets current gameplay before file reads, reconstructs state and mod data, clears loadInProgress and emits OnLoad near completion. `Assets/Scripts/Game/StateManager.cs`, SaveLoadManager_OnLoadHandler emits OnStartNewGame then selects Game.

These observations do not adopt DFU's format, mod hooks or error policies. Baseline is local DFU 1.1.1 Release; exact commit unavailable per repository overview. Static inspection only; source remains unchanged.

## Detailed rules and behaviors

Native means saves of this Godot implementation. This specification does not approve reading DFU or classic Daggerfall formats, translating their records or reproducing their save-layout conventions. CORE-014's existence in the analysis catalog is not authorization for compatibility work.

All load sources, including main menu and quickload, submit stable selected-save requests through CORE-007. Bind each request to a stable identity. The 2026-11-17 [SAVE-005 amendment](../SAVE/SAVE-005.md) requires cancellable preflight first, then discard confirmation by default for a living session. Validated mod policy can suppress that prompt independently for manual loads and quickloads. Disclose player-visible supported recovery before replacement. Conflicting requests, repeated identities and retry follow CORE-007. No automatic save occurs.

SAVE prepares a consistent validated generation before destructive replacement. Check version/migration support, required records, durable references/definitions, required content/mod dependencies and owner-supported activity state. Migrations and optional recovery must validate before replacement. Unsupported format or required-data/dependency failures leave the running session intact and explain the problem with retry/choose-another-save recovery. Optional recovery needs an owner-defined safe policy disclosed before proceeding; this does not approve arbitrary data loss or unrelated replacement content.

After successful preflight/consent, use safe teardown and a clean replacement baseline under CORE-005/010. Restore through SAVE and domain owners: establish world/time/identity context, reconstruct authoritative state and link references, ready required geometry/collision, place the player in the saved context, rebuild derived state and supported activity UI. This is a dependency constraint, not approval of one exhaustive serializer order; SAVE/domain contracts must specify exact phases and readiness checks.

Keep saved durable identities and establish collision-free subsequent allocation. Never run fresh-character biography/grants/tutorial offers/opening quest initialization over restored state. Ongoing saved tutorial/story quests resume as saved; that is distinct from starting them anew. Do not consume a generic fresh-start LaunchQuest override merely because a load completed.

Restore the saved pose, orientation and supported movement context using the saved world's coordinate semantics. Geometry/collision must be available before final validation. Grounded, airborne, swimming and other supported contexts use their own eligibility rules. Only declared bounded corrections are allowed; do not silently relocate to an entrance, town or new-character spawn. Preflight may validate structural placement inputs, but final physics/readiness failures can still occur after replacement and require safe recovery.

Restore supported activities from authoritative state, rebuilding views rather than raw UI objects/callbacks. Eligibility/resume rules belong to SAVE and the activity owner, especially for transactions, rest/travel, dialogs and timers. This document does not approve saving in every modal flow. Required unsupported states fail preflight where detectable; late required restore failure fails entry. Restoration must not replay committed payment/reward operations or abandon required obligations silently.

Keep loading coverage and prevent gameplay simulation/input until required restoration, links, derived state and supported UI are ready. Reveal the restored session, clear stale load-trigger actions and publish one Session Restored notification with committed state visible. Show loaded only on actual success, never on asynchronous initiation. Release only load-owned suspension; a restored modal or independent pause reason may legitimately leave gameplay suspended. Exact reveal/notification implementation must not permit a playable partial frame or input click-through.

Post-replacement failure invokes safe cleanup and independent error UI under CORE-005/007. Safe cleanup permits retry/menu/quit; unsafe cleanup permits Retry Cleanup/Quit and blocks new entry. Retry uses original selected intent with a new request identity and fresh validation over clean replacement, not a partial restore checkpoint. No full old-session rollback is promised. Busy flags and terminal outcomes must clear consistently without overriding safety gates.

## Relevant formulas and parameters

No gameplay formulas, fallback coordinates, generic timeout or save-slot numbering scheme are approved. Format version/migration compatibility is explicit. Required/optional section and dependency policy is owner-declared. Pose correction bounds are MOVE/LOC parameters; swimming/airborne context cannot be reduced to a universal supporting-floor test. Readiness requires all declared mandatory restore phases, not a guessed completion percentage.

## Required data

Stable save identity/generation, format version, compatible migration plan, required/optional section metadata, durable object/reference data, content/package dependencies, saved world/location/time/pose/movement context and supported activity state. Runtime load state includes request/session identity, preparation result, recovery disclosures, restore-phase readiness, cleanup status and terminal result. Application preferences remain outside restored character state.

## Inputs, outputs and events

Inputs: selected native save request, consent/cancel, consistent prepared SAVE data, validation/migration/content checks, owner restore results and recovery choices. Outputs: intact old session on preflight rejection, restored replacement with one Session Restored notification, truthful success/failure/cancel outcome, optional-recovery disclosure or actionable error UI. Public APIs/signals and exact recovery wording remain deferred. Diagnostics use CORE-002 privacy rules rather than dumping save contents.

## Cross-system interactions

CORE-007 owns admission/consent/preflight/cancel/outcomes; CORE-005 owns runtime lifetime/cleanup; CORE-010 supplies clean baseline. SAVE owns format, generations, migrations, required sections and owner restore coordination. CHAR/ITEM/MAGIC/QUEST/FACT/ECON/LAW and other durable owners restore their state and validate references. WORLD/LOC/MOVE provide coordinates/geometry/pose contexts, TIME calendar/tracking and UI supported presentation. MOD/DATA validate required definitions and dependency compatibility. CORE-001 root selection and CORE-003/006 application preferences do not change because of a character load. CORE-002 logging remains optional. CORE-008 does not automatically load after death, and CORE-009 remains deferred.

## Edge cases and failure conditions

- Missing, changed or unreadable selected saves cannot redirect to another slot. Consistent preparation follows CORE-007; failed preflight preserves the old session.
- Unsupported versions, required corrupt/missing sections and missing definitions block rather than silently defaulting character history. Disposable visual caches may rebuild; other recovery requires declared safe handling/disclosure.
- Mod presence alone does not prove definitions or versions are compatible. SAVE/MOD must define actual validation; unrelated replacements are not a recovery policy.
- Valid file structure does not guarantee every runtime binding/pose will succeed. Late required failure is entry failure, not partial success.
- An airborne/swimming pose is not invalid solely for lacking nearby floor. A pose penetrating unavailable geometry is not rescued by silently teleporting elsewhere.
- Recreated UI must not replay payments, rewards or duplicate quest startup. Saved activity contracts define supported pause/resume behavior; no universal modal saving promise is made.
- Old gameplay input, death fades and stale callbacks cannot carry into a newly restored character. Only load-trigger stale actions are cleared without disabling legitimate restored modal input.
- A restore event must not invoke new-character grants, reset already-restored values or publish new-game notifications. Duplicate callbacks do not produce duplicate outcomes.
- Cleanup failure may outlive the operation's busy flag; the safety gate still blocks another session. File-logging failure cannot conceal or manufacture load success.

No new balance effects, automatic saves, alternate-slot fallback or cross-game compatibility are approved.

## Configuration and balancing options

Native compatibility and restoration policy are fixed safety rules. Format/schema choices, supported migrations, optional-section policies, activity saving/resume and content compatibility are owner-defined. Players select a save and can retry/choose another after preflight failure. Current application preferences remain effective; loading does not restore historical display/input settings or activate pending restart preferences. No player option bypasses required save validation.

## Save/load considerations

Loading does not overwrite the source save, automatically migrate it on disk or create a new save under this feature. SAVE separately defines publication/backups and any explicit migration persistence policy. Prepared migrations apply to the restoration candidate without authorizing destructive source rewrite. Restore persistent identities/state while rebuilding transient scene handles, callbacks and caches. Unsupported required activity state cannot silently become fresh idle state. Successful restoration can legitimately remain paused by restored UI or another owner.

## Technical constraints

Project target: Godot 4.7.2. Use this implementation's own versioned save contract, not Unity serializers or DFU data classes by assumption. Validate/decode consistently before teardown, await actual asynchronous completion and report truthful results. Scope-safe callbacks, explicit owner dependencies and context-aware placement follow approved rules. Serializer, schema, package manifest, staged input ownership, checksums and concrete API names remain deferred to SAVE/MOD/DATA.

## Acceptance criteria

1. Native load handles this Godot implementation's saves only. No DFU/classic import work or format compatibility is required or implied.
2. All native entry and quickload requests follow CORE-007 stable selection and single-operation rules, plus SAVE-005 preflight, prompt policy and disclosure. Cancellation preserves the existing session before replacement. No automatic alternate save is loaded.
3. Preflight checks version/migration, required character/world/quest data, definitions/dependencies and supported required activity state before teardown. Failure preserves current session and provides actionable retry/another-save recovery.
4. Optional recovery occurs only under an owner-defined policy disclosed before proceeding. Disposable caches may rebuild; required incompatible history is not silently defaulted.
5. Restoration uses clean baseline and preserves saved durable identities, location/time/state and collision-safe allocation. No fresh-character resources/tutorial/opening quests are rerun; saved active quests resume as state.
6. Geometry/collision precede final pose validation. Saved movement context is respected, with only declared bounded corrections and no unrelated-location teleport fallback.
7. Supported activity UI rebuilds from authoritative state without repeating transactions/obligations. Unsupported required states fail instead of being silently abandoned.
8. Loading coverage/suspension remains through required restore, linking, derived state and supported UI readiness. No partial playable frame is exposed.
9. One distinct Session Restored notification and any loaded message follow actual success with committed state visible. Clear stale load-trigger input and release only load-owned suspension, retaining restored modal/other gates.
10. Late/duplicate callbacks cannot alter another session, duplicate notifications or reset restored values. Post-replacement failure uses safe cleanup/recovery and never claims full old-session rollback.
11. Retry constructs clean state with new identity/fresh validation. Unsafe cleanup continues to block new entry despite busy-state release.
12. Source saves, application storage root/preferences and active ARENA2 source are not rewritten/switched by this load flow. Logging availability does not determine correctness.

These are future verification criteria. No implementation, schema migration or runtime tests were performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001–008 and CORE-010–012 v1, CORE-009 deferral, decision log, CORE catalog and CORE architecture review. All nine CORE-013 interview decisions are represented. No conflict identified: preflight preserves old state, baseline precedes restore, new-character grants remain separate, and successful restored modals may retain suspension. User explicitly excludes DFU/classic save compatibility from current scope; existing analysis of those formats does not authorize implementation.

## Outstanding questions and approval

No further blocking native-entry player-policy choice is currently identified. SAVE/domain specifications must define exact version/schema/migrations, required sections, optional recovery, coherent preparation, reference restore order and supported activity resume. MOD/DATA must define content compatibility; MOVE/LOC must define pose tolerances/contexts. These dependencies remain open and do not waive acceptance criteria. Classic/DFU import is outside current scope.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-013. This document is finalized v1. Approval reference: CORE-013-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented owner contracts and deferrals remain open. DFU/classic save compatibility remains outside current scope. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
