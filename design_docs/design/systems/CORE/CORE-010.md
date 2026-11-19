# CORE-010 — Fresh-session reset

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Establish a clean baseline for a replacement character without retaining previous-character state or erasing newly restored data. CORE-005 releases the old scope; this feature initializes the replacement baseline.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Establish a clean session for new characters and supported save/import routes. New characters receive declared starting defaults; loads restore over a clean baseline. Reset must not erase newly restored values.
- Clear previous-character gameplay state, including quests, memberships, discoveries, property/ship state and transient UI. Preserve application preferences, installed content, existing saves and reusable content caches containing no character state. Feature owners identify data categories.
- Each gameplay owner initializes its own baseline through an ordered lifecycle contract. Essential resets must not depend on unspecified subscriber order of a broad new-game event. Publish baseline readiness only after required initialization succeeds; keep gameplay suspended until full entry completes.

Second interview, confirmed by the user on 2026-11-05:

- Initialize replacement-session identity allocation without collisions with restored objects. Loads preserve durable identities and establish safe allocation afterward. SAVE/DATA own the precise scheme; DFU's counter reset is not required.
- Separate the empty baseline from new-character grants. Starting equipment/spells/opening quests run only through appropriate new-character initialization, not on save load. Missing required save data uses SAVE compatibility/recovery rather than silently starting a fresh character.
- Required baseline failure stops entry, cleans incomplete replacement state and uses CORE-005/007 recovery. Retry constructs a clean replacement with fresh validation rather than continuing over partial reset. Do not report baseline readiness or resume gameplay on required-owner failure.

Third interview, confirmed by the user on 2026-11-05:

- Initialize the baseline once per replacement session. Duplicate initialization must not clear restored state, reset identities or repeat rewards. Intentional retry constructs a clean replacement.
- Baseline readiness is a notification, not a hook for additional essential resets. Required initialization belongs to the ordered owner contract. New-character grants and restored-session completion are distinct later milestones.
- Retain only caches whose owners establish they contain no previous-character state/references. Clear/rebuild session-dependent caches. Separate reusable content from mixed character data before retention; otherwise clear the entire mixed cache.

## Inherited requirements and deferrals

CORE-007 requires validated prepared input and discard consent before destructive replacement; failed preflight preserves the old session. CORE-005 requires safe teardown, explicit ownership and stale-work rejection. CORE-008 distinguishes session-end/menu return from new-game events. CORE-001–006 application storage/settings/logging/preferences remain intact. CORE-009 is deferred; no worldless behavior is approved here. Supporting a reset route does not approve classic import itself.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/Utility/StartGameBehaviour.cs`, NewCharacterCleanup: reset UID generation, quests, UI stack, scene-state cache, memberships, discovery and ship state, raise OnNewGame, then reset weapons. New character and classic import call it; classic import does so before validating its index/opening input. OnNewGame subscribers include player/entity state, movement, magic, dialogue, automaps and HUD components, so essential effects extend beyond the method body.

`Assets/Scripts/DaggerfallUnity.cs`, ResetUID resets the numeric allocator to its starting value. This observation does not approve allocator semantics for the recreation.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per repository overview. Static inspection only; source remains unchanged.

## Detailed rules and lifecycle

CORE-007 preflight and required discard consent complete before destructive replacement. CORE-005 safely tears down old scopes; CORE-010 establishes the replacement's baseline through explicit owner initialization. These may be phases of one coordinated operation, not competing reset systems. Do not clear the old session during request validation or run baseline reset on ordinary location changes, settings application or menu presentation.

Each owner declares its baseline state, dependencies and initialization result. Initialize required owners in dependency-safe order rather than using subscriber order as authority. Feature-specific baseline values are not invented here. An owner must not reuse authoritative previous-character state merely because a manager object persists for application lifetime.

For new characters, apply declared initial character/world data and starting grants only through the appropriate later entry features. For supported loads/imports, apply validated prepared data over a clean baseline and preserve restored authoritative identities. Never run a generic reset after restoration to compensate for incomplete ownership. Missing required save data invokes SAVE compatibility/recovery rules; baseline defaults do not silently replace required missing history.

Identity initialization must avoid both collision with restored objects and stale references from old scopes. A local numeric value may recur only under the identity contract defined by SAVE/DATA and scope rules; this specification neither requires a global never-reused sequence nor authorizes treating old scene handles as durable IDs. Restore identifiers and establish safe subsequent allocation before creating new persistent objects under the restored identity scheme.

Track baseline initialization per replacement session. Repeated entry for an already-initialized session cannot clear subsequently restored state. Duplicate work while initialization is underway must not execute a second reset. Failed initialization follows cleanup/retry rather than attempting to continue over a partially initialized baseline. A fresh retry has a fresh replacement context and repeats required preflight under CORE-007.

Publish baseline readiness only after required owner initialization succeeds and observers can see consistent baseline state. It is an intermediate milestone, not session-entry success, new-character creation or load completion. Observers cannot supply hidden essential reset steps after the notification. Gameplay remains gated until all later placement/grants/restoration/readiness requirements finish through the owning entry operation.

## Relevant formulas and parameters

No gameplay formulas or balance values apply. Baseline initialization runs once per replacement-session context. Precise default values, UID width/allocation algorithm, migration rules and starting rewards remain feature-owned. Cache retention is conditional on verified absence of previous-character state/references, not on a global retention timer.

## Required data

Replacement session/operation identity, entry kind (new or supported restore/import), owner dependency/initialization declarations, baseline phase/result, cache classification and durable identity/allocation context. Prepared restore data belongs to SAVE; initial character data/grants belong to their owners. Track enough progress to detect duplicates and clean incomplete construction, not to resume failed partial initialization as success.

## Inputs, outputs and events

Inputs: validated coordinator entry context, completed safe teardown, owner baseline contracts/results, new-character or prepared restore intent and reset failures. Outputs: clean initialized baseline, truthful baseline-ready notification or failed initialization with cleanup/recovery. Public event/API names remain deferred. Notifications carry originating context so callbacks cannot reset another session. A baseline-ready notification does not emit menu-return, character-created or load-complete outcomes.

## Cross-system interactions

CORE-005 owns scope disposal, explicit bindings and stale-work rejection; CORE-007 owns preflight, consent, conflict handling, terminal outcomes and retry. QUEST, FACT, WORLD, ECON, ITEM, MAGIC, CHAR, COMBAT, UI and SAVE owners initialize their own session state. Examples include quests, membership, discovery, property/ship data, effects and transient presentation, without defining their actual initial gameplay values here. SAVE/DATA own identity and required restore-section semantics. CORE-011 and later entry features own placement/grants; supporting a baseline route does not approve classic import. CORE-001–006 application preferences/storage/logging remain intact. CORE-008 menu return remains teardown rather than new-game initialization; CORE-009 stays deferred.

## Edge cases and failure conditions

- The prior character may have memberships, discovery, ship/property, active effects, queued UI actions or cached local state. None may leak into another character through an application-persistent owner or cache.
- A mixed cache is not safe merely because most entries are immutable content. Separate session state/references or clear it entirely. Shared definitions may remain, but mutable per-character data must not be stored on retained shared definitions.
- A duplicate reset after restoration must not wipe quests, memberships or newly restored references. It must not restart the identity allocator or trigger grants.
- Essential owner failure prevents baseline readiness. Keep gameplay suspended, clean partial state and use CORE-005/007 recovery. Unsafe cleanup blocks new entry with Retry Cleanup/Quit; safe retries reconstruct rather than resume partial reset.
- A missing optional capability uses only its approved owner fallback under CORE-005. Do not relabel required initialization optional to proceed.
- Restored identities may differ from freshly allocated identities. Do not reset an allocator after restore or create colliding persistent objects before restore context is established.
- Event listeners and late work from the old session must not mutate the new baseline. Required reset order cannot depend on arbitrary subscriber registration order.
- Retaining logs/settings/saves/content does not authorize retaining old-character mutable gameplay state. Clearing runtime state does not delete existing save files or alter original ARENA2 data.

No numerical balance changes, rewards, penalties or autosave policy are introduced. The main risks are cross-character leakage, repeated grants, erased restored data and identifier collisions.

## Configuration and balancing options

Owners define baseline defaults and classify data/caches. Safe reset boundaries, once-per-session behavior and required readiness checks are fixed policies rather than player options. This feature chooses no starting equipment, spells, affiliations, map knowledge, property or quest list. No worldless-mode exception is approved.

## Save/load considerations

Existing save files are preserved. Restoration consumes validated SAVE input over a clean baseline; restored values remain authoritative according to SAVE compatibility rules. Baseline initialization markers, scene references and old callbacks are transient and must not become saved character identities. Do not restore a serialized initialized flag as permission to skip construction of a new runtime scope. Required missing data cannot quietly inherit previous-character state or become new-character defaults. Detailed optional-field migration/fallback remains SAVE/domain scope.

## Technical constraints

Target project engine: Godot 4.7.2. Use explicit owner initialization and dependency order, not Unity-specific globals or OnNewGame subscription side effects. Fresh construction may establish the baseline without manually zeroing every field; the approved outcome matters. Reused containers must establish equivalent isolation. Keep ownership, cache policy and identity contracts auditable. Exact APIs, owner inventory/order, baseline flag representation and allocator design remain deferred.

## Acceptance criteria

1. Fresh new-character and supported restore/import routes establish a clean replacement baseline after preflight/consent and safe teardown. Failed preflight leaves the old session intact.
2. Previous-character quests, affiliations, discoveries, property/ship and transient UI/gameplay state do not leak into a new replacement. Feature owners supply declared baseline values.
3. Application preferences, storage/logging lifetime, installed content, original data and existing saves remain intact. Retained caches contain no old-character state/references; unseparated mixed caches clear.
4. Required owners initialize in declared dependency-safe order. Essential reset work does not depend on broad event subscriber order or occur as hidden work after baseline-ready notification.
5. New-character grants are distinct from baseline creation and do not execute on save load. Restore data is applied after baseline and never erased by a later generic reset.
6. Restored durable identities remain intact, new allocation avoids collisions and stale old-scope references cannot bind to replacement objects.
7. Duplicate initialization for the same context cannot rerun reset, clear restored state, reset allocation or repeat grants, including duplicate calls while initialization is underway.
8. Required-owner failure prevents readiness/gameplay, cleans incomplete state and follows CORE-005/007 recovery. Retry validates again and constructs a clean replacement; unsafe cleanup blocks entry.
9. Baseline-ready observers see consistent initialized baseline state, but full entry still gates gameplay and character/load completion remains a separate milestone.
10. Required missing save data invokes SAVE compatibility/recovery without silent fresh-character replacement. Ordinary location changes, menu presentation and preference application do not trigger this reset.

These are future verification criteria. No implementation or runtime tests have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001 through CORE-008 v1, CORE-009's deferral, the decision log, CORE catalog and CORE architecture review. All nine CORE-010 interview decisions are represented. No conflict identified: preflight precedes destruction, safe teardown remains CORE-005-owned, baseline readiness does not release full entry gates, and return-to-menu does not emit new-game initialization. Identity details and particular entry modes remain unapproved beyond these constraints.

## Outstanding questions and approval

No blocking baseline-policy choice is currently identified. Deferred contracts include domain-specific baseline values, required owner/dependency inventory, cache classification, identity allocation, SAVE compatibility and later entry grants/placement. These dependencies must be resolved in their owning specifications before implementation can be considered complete; this document does not invent them.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-010. This document is finalized v1. Approval reference: CORE-010-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented deferrals remain deferred. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
