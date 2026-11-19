# CORE-005 — Scene services and manager lifetime

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Provide valid scene/service dependencies across application and session lifetimes, with reliable transitions and no stale state leaking between characters.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Separate application and session lifetimes. Storage, settings and logging survive for the application. Player/world gameplay services belong to the current session. Ending a session releases its services and subscriptions so a later character cannot inherit stale state.
- Explicitly bind and check required services before enabling simulation or player gameplay input. Missing or duplicate required services fail initialization with an actionable error; do not arbitrarily select one or silently create a replacement. Menu/error-screen input remains available.
- Absence is supported only for services whose owning feature defines a fallback. Disable the affected optional capability with a warning. Required systems such as player control or save restoration must not be treated as optional.

Second interview, confirmed by the user on 2026-11-05:

- If session initialization fails, disable gameplay, clean up the incomplete session and show Retry, Return to Main Menu and Quit using independent error UI. Do not report successful character start/load. Recovery of a previously running session remains session-entry scope.
- End a session by stopping simulation/gameplay input, canceling outstanding session work, disconnecting subscriptions, then releasing services/scene objects. Application settings/logging remain available. Do not start another session until teardown completes.
- Reject callbacks/work from ended sessions rather than applying them to a new character. Record a diagnostic without repeatedly interrupting the player. If a required current-session service disappears, suspend gameplay and show a recovery error rather than continuing partially functioning gameplay.

Third interview, confirmed by the user on 2026-11-05:

- Keep character/session services alive across location changes while replacing location-specific objects/references. Entering a building/dungeon does not create a new character session. Validate new location bindings before resuming its gameplay.
- If teardown cannot complete safely, block new sessions and offer Retry Cleanup or Quit. Do not resume a playable session or start another character while old work/subscriptions may remain active.
- Announce session/location readiness only after required bindings and initialization complete. Observers see a consistent ready state. Readiness alone does not resume gameplay while loading, menus or other systems still require suspension.

Fourth interview, confirmed by the user on 2026-11-05:

- Each service has one declared owner and an application, session or location lifetime. Bind through explicit references or registration rather than global object-name/tag searches. Access must not silently create services.
- Duplicate optional providers disable the affected capability with a warning unless its feature explicitly supports multiple providers and defines selection rules. Do not arbitrarily select a provider. Duplicate required services fail initialization.
- Preserve CORE-001–003's specific application-service recovery rules. Other required application-service initialization failures block gameplay with independent error UI. Offer Retry only after safe cleanup; otherwise Quit. If such a service disappears during play, suspend gameplay and require safe recovery or application restart. Optional failures use approved fallbacks.

## Inherited approved requirements

CORE-001 owns storage-root lifetime and exclusive use. CORE-002 logging is application-scoped and optional on file failure. CORE-003 supplies validated settings independently of logging success. CORE-004 routes through mandatory checks to the main menu and requires independent error UI with Retry/Return to Setup/Quit for failed main-menu transitions. These approvals do not establish every gameplay service's lifetime or a complete pause policy.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/GameManager.cs`: Instance finds or creates the singleton; Awake calls SetupSingleton, which persists the first manager and destroys duplicates during play. Typed properties cache lookups by component type, object name or tag. Required lookup helpers throw on missing objects/components; some optional lookups return null. Start caches initial shadow distance and starts paused; eager GetProperties binding is commented out.

Baseline: local DFU 1.1.1 Release snapshot, exact commit unavailable per repository overview. Observations are static source inspection; scene lifetime risks are not demonstrated runtime defects. Source remains unchanged.

## Detailed lifecycle rules

Declare ownership, lifetime, dependencies and required/optional status before binding. Required/optional status is contextual: a service needed for session restoration may be unnecessary in a standalone startup screen. Requiredness must not be downgraded merely to bypass validation. An optional service needs a feature-defined fallback before its absence can be accepted.

Application services exist independently of a character session and survive returning to the menu. Session services belong to a character session; location services belong to the active local scene/context. A location change does not end that session. Rebind references affected by location replacement and validate required bindings before enabling the new location's gameplay. Retaining a session does not mean every streamed object must remain alive.

Construct/bind dependencies explicitly and validate initialization results before publishing readiness. Missing or ambiguous required bindings produce failure rather than arbitrary selection, fallback object discovery or service creation on access. Readiness means this scope's requirements are satisfied; it is not a command to resume every suspended system. Menus/error UI retain their own input.

When ending a scope, prevent further authoritative gameplay work, cancel outstanding work, disconnect its subscriptions and release owned services/objects in dependency-safe order. Application services must not retain callbacks or references that can mutate an ended session. Outstanding callbacks may arrive after cancellation, so reject work belonging to a no-longer-active session or location rather than attaching it to a replacement. Safe teardown must be established before another session begins.

Initialization failure stops gameplay and cleans incomplete state before offering a retry or returning to the menu. If cleanup is unsafe/incomplete, the stricter Retry Cleanup/Quit policy takes precedence; do not enable a new session. Failure UI must not depend on the failed gameplay scope. This document does not promise rollback to a previously running session or decide when a new/load operation replaces that session; later session-entry specifications own those choices.

If a required service disappears during active play, suspend affected gameplay and present a recovery error. Do not use a replacement instance opportunistically. Safe recovery must revalidate the required scope; when safety cannot be established, require restart/quit rather than continuing partial gameplay. Specific recovery choices for current-session loss remain subject to the applicable feature's operation contract and safe-cleanup rules.

## Relevant formulas and parameters

No gameplay formulas or balance values apply. Lifetime categories are application, session and location. The default for a service role is one unambiguous owned provider; explicitly supported multi-provider roles follow their owning feature's selection rules. This is not a limit on ordinary world actors, cameras or other objects that are not unique service providers.

## Required data

Service role, owner, lifetime, required/optional status, dependencies, bound provider, initialization/disposal result and any approved optional fallback. Scope context needs current session/location identity, readiness/teardown status and sufficient provenance to reject stale work. Exact ID representation and registration schema are implementation details. Application preferences and saved gameplay data remain owned by their existing systems.

## Inputs, outputs and events

Inputs: application initialization, session creation/end, location replacement, explicit provider bindings/registration, initialization outcomes, provider loss, cancellation/completion callbacks and recovery choices. Outputs: validated references, ready/failed/ending/ended outcomes, optional-capability availability, cleanup results and actionable diagnostics/error UI. These are conceptual outcomes; public API/event names are not selected here.

Publish readiness only after the complete required state is visible. Reject late callbacks using their originating scope, not merely whichever scope is currently active. A failure notification must not recursively depend on the missing service. Diagnostics follow CORE-002 and must remain optional for correctness.

## Cross-system interactions

CORE-001 retains application storage/exclusive-use ownership, CORE-002 logging and CORE-003 validated settings. CORE-004 handles startup/menu routing, including its existing failed-menu transition choices. UI provides independent menus/error presentation and input while gameplay is gated. Player, world, movement, SAVE and AV owners declare what their scopes require. SAVE reconstructs durable data; CORE-005 manages runtime binding/readiness, not save schema. Session entry/load and location transition owners coordinate operations using these constraints. Detailed pause ownership and resume sequencing remain later CORE scope.

## Edge cases and failure conditions

- Duplicate required roles fail even when one candidate appears usable. Duplicate optional roles disable that capability unless explicitly supported selection rules exist.
- Expected release of an old location is not unexpected service loss, provided gameplay is gated, old bindings invalidated and the new scope validated before use.
- Canceled work may still complete. Neither its result nor a stale signal can mutate a later session/location. Diagnose rejected stale work without repeated player interruptions.
- Initialization may fail after only some services exist. Release only initialized/owned resources safely; incomplete cleanup blocks further sessions.
- Retrying cleanup must not double-dispose resources or accidentally release application services shared with error UI.
- Required service loss and teardown failure cannot be concealed as optional degradation. Optional fallback must itself be supported and safe.
- Suspended gameplay must not prevent error/menu input. Readiness cannot override another owner's load/menu suspension.
- File-logging failure follows CORE-002 rather than generic required-service failure. Runtime settings/storage failures retain CORE-001/003 policies; these specific approved rules take precedence.

There are no numerical balance effects. The main correctness risks are stale mutations, duplicate ownership, incomplete cleanup and gameplay advancing before required services are usable.

## Configuration and balancing options

Service roles/lifetimes/fallbacks are engineering configuration, not player difficulty options. No player setting disables required validation or permits duplicate required providers. Exact service inventory is feature-owned. This specification approves no general dependency-injection framework, universal service locator or automatic fallback discovery system.

## Save/load considerations

Scene handles, runtime service instances, subscriptions and pending callbacks are not durable character-save references. Reconstruct and bind runtime services around restored domain data; do not restore stale references from an earlier process/session. Save schemas and ordering of domain restoration belong to SAVE and session-entry contracts. Saving is not safe merely because services exist; feature-specific save gates still apply. Ending a session neither implies autosave nor authorizes discarding unsaved progress without the applicable exit policy.

## Technical constraints

Project target: Godot 4.7.2. Explicit references or registration may use native scene wiring and ordinary ownership constructs; no particular autoload, framework or container is required. Service access has no creation side effects. Validate dependencies and reference lifetime at scope boundaries. Teardown and callback rejection must remain reliable under delayed/asynchronous work. Error UI cannot require the gameplay services whose failure it reports. Specific APIs, disposal strategy and scope-identity representation are deferred.

## Acceptance criteria

1. Storage/settings/logging retain application lifetime across session teardown, subject to their existing approved availability policies.
2. Session end releases session-owned services/subscriptions; starting another character does not inherit stale player/world state.
3. Missing/duplicate required bindings prevent readiness and gameplay simulation/input, produce actionable errors and do not silently create or select replacements. Error/menu input remains usable.
4. Supported optional absence uses the owning feature's fallback and warning. Duplicate optional providers disable the capability unless explicit multi-provider rules resolve them.
5. Session initialization failure does not announce successful start/load. It cleans partial state and offers Retry/Main Menu/Quit only where cleanup is safe; otherwise Retry Cleanup/Quit applies.
6. Teardown stops gameplay work, cancels work, disconnects subscriptions and releases owned resources. A new session cannot start until safe completion. Retry does not double-release resources.
7. Delayed callbacks from ended sessions or replaced locations do not mutate the current character/location. Diagnostics do not repeatedly interrupt the player.
8. Location transitions retain session services, replace location bindings and validate new dependencies before local gameplay resumes. Entering a building/dungeon does not create a new character session.
9. Readiness observers see fully initialized required state. Readiness alone does not release loading/menu/other suspension requirements.
10. Required current-service loss suspends gameplay and exposes independent recovery UI; unsafe recovery cannot resume partial gameplay. Application-service failures preserve CORE-001–003 exceptions and require safe retry or restart/quit otherwise.
11. Services have explicit owners/lifetimes, are bound by references/registration and are not silently instantiated on access. Scope teardown does not destroy services owned by another still-active scope.

These are future verification criteria; no implementation or runtime tests have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001 through CORE-004 v1, the decision log, CORE catalog and CORE architecture review. All 12 interview decisions are represented. No conflict identified: specific storage/settings/logging recovery is preserved, startup/menu errors remain independent, and cleanup gating takes precedence when a menu/retry cannot safely start. Broader architectural proposals remain Proposed beyond these explicitly accepted rules. There is no approval of rollback, autosave, full pause architecture or scene-loading implementation by implication.

## Outstanding questions and approval

No blocking player-policy question is currently identified. Deferred details include per-feature service inventory and dependencies, optional fallback definitions, registration/API shape, dependency initialization order, scope IDs and cleanup mechanics. Session-entry and location features must define their concrete recovery/rollback choices within these safety constraints. Detailed pause/input ownership remains later scope.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-005. This document is finalized v1. Approval reference: CORE-005-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented deferrals remain deferred. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
