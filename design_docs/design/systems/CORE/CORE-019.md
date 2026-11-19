# CORE-019 — Rest interruption and nearby threat query

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Provide purpose-specific threat information and explicit rest eligibility/interruption without conflating message text, shared enemy queries and authoritative rest advancement.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- NPC/COMBAT supply shared threat information; TIME rest rules decide blocking. Other callers declare purpose rather than automatically sharing rest-distance policy. Exact distances/perception remain owner review.
- Check restrictions before starting and at declared time-advance boundaries. Newly relevant threats/vetoes promptly interrupt further rest. Preserve committed elapsed time/recovery; neither rewind them nor award recovery for unelapsed time. TIME/CHAR define exact boundary order.
- Owner-scoped conditions return structured allowed/blocked results with reasons, not null/empty-text control flow. Multiple blockers use explicit explanation priority; subscriptions end with owning scopes. No specific legal/quest/status restriction is approved merely by allowing registration.

Second interview, confirmed by the user on 2026-11-05:

- Exclude dead/inactive/pacified/player-allied actors unless current behavior makes them genuine threats. Hostile eligibility uses proximity and owner-defined detection/pursuit, not constant line of sight alone. Brief occlusion does not automatically make rest safe; exact thresholds remain NPC/COMBAT scope.
- Count spawners only when currently eligible under encounter rules. Disabled/exhausted/ineligible spawners do not block solely through proximity. Whether eligible not-yet-triggered spawners block remains encounter/rest-policy scope.
- Failed required condition evaluation blocks start or stops further rest advancement, reports inability to verify conditions and permits retry. Exceptions are not permission. Optional extensions need declared fallback and must not silently become permanent blockers.

Third interview, confirmed by the user on 2026-11-05:

- Interruption stops further time advancement and presents one clear message. Resume ordinary gameplay only when its UI/suspension and other gates permit. Do not automatically restart rest when a blocker clears; require a fresh player request.
- Threat feedback is generic (for example Enemies are nearby) unless gameplay already reveals more. Do not expose hidden enemy names, positions or counts through rest checks. Other restrictions use owner-appropriate explanations.
- Revalidate immediately before each declared rest-advance segment commits and process relevant threat/encounter changes before the next segment. Caches require explicit scope/freshness; stale safety cannot authorize another session/location. TIME/NPC own exact segment size/event order.

## Inherited requirements and scope

CORE-016 distinguishes ordinary paused simulation from explicit TIME advancement and keeps UI responsive. CORE-017 does not automatically replay all simulation steps for calendar rest. CORE-005/015 require scope-safe ownership and committed state; CORE-018 shortcuts cannot bypass rest-owner eligibility. CORE-009 stays deferred and CORE-014 outside scope. This feature sets query/rest-guard contracts, not full rest healing, encounters, legal policy or time advancement formulas.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/GameManager.cs`, GetPreventedRestMessage/RegisterPreventRestCondition/UnregisterPreventRestCondition aggregate delegates using message presence to represent veto; null messages normalize to empty. AreEnemiesNearby checks active hostile enemy perception/classic-spawn eligibility and spawner distance; rest excludes enemies not actively seeing the player beyond 12 Unity units. Pacified/player-allied enemies are excluded by default.

`Assets/Scripts/Game/UserInterfaceWindows/DaggerfallRestWindow.cs`, TickRest checks spawn interruption/registered vetoes, explicitly advances calendar/quests and checks threats/vetoes around its rest boundaries. Other query callers include UI/travel entry, PlayerEntity and MobilePersonMotor, so query purpose is broader than rest alone.

Baseline: local DFU 1.1.1 Release; exact commit unavailable per repository overview. Static inspection only; source remains unchanged. Exact numeric thresholds and caller behavior are not adopted by implication.

## Detailed query and rest rules

NPC/COMBAT expose threat observations and authoritative eligibility with explicit query purpose/context. TIME aggregates rest-specific threat policy and registered restrictions. Travel, civilian behavior or other callers declare their own purposes rather than automatically inheriting rest radius/awareness rules. Querying eligibility must not advance time, consume rewards or perform the requested rest activity.

Use structured decisions distinguishing allowed, blocked and failed verification. Include owner/reason identity and player-safe explanation metadata; text presence alone is never the control signal. Empty/missing localized text cannot turn a blocker into permission. Choose a player-facing reason through explicit stable priority and tie-breaking rules defined by owners rather than incidental callback/dictionary order. Diagnose failures independently of whether file logging works.

Conditions/registering extensions have explicit scope, ownership and required/optional failure policy. Remove them at teardown under CORE-005; stale callbacks must not veto another session. Required evaluation failure blocks starting/rest continuation, reports verification failure and offers retry. Optional extension failure uses only a declared safe fallback; absence of such a contract is not permission to invent an allow result or a permanent silent veto.

Hostile threat eligibility considers current actor state, proximity and detection/pursuit under NPC/COMBAT definitions. Dead, inactive, pacified and allied actors normally do not count unless their actual current behavior makes them genuine threats. Do not require an enemy to maintain continuous line of sight: brief occlusion alone must not permit rest. Precise distances, awareness/memory expiry and geometry-accessibility rules are deferred to NPC/COMBAT, not copied from DFU's Unity-unit thresholds.

Spawner observations include current encounter eligibility. Disabled/exhausted/ineligible spawners do not block merely by proximity. The policy for eligible but untriggered spawners remains explicitly open with encounter/rest owners. A newly relevant encounter/spawn must be processed before another rest segment can advance; this does not itself define encounter odds or guarantee safe rest until an enemy is visible.

Before rest starts, evaluate fresh applicable restrictions and threats. Before each declared calendar-advance segment commits, revalidate in the current session/location/rest context. TIME/CHAR define boundary ordering for healing, quest deadlines and encounter consequences; do not grant an extra segment after a known blocker. Query caches require explicit validity and invalidation for actor/hostility/perception/spawner/location changes. A previous-location/session safe answer cannot be reused as authorization.

During rest, newly relevant threats, owner vetoes or required-check failures stop further advancement promptly at the applicable boundary. Retain already committed time/recovery and state changes; do not rewind them or award future recovery. If a threat arises within a committed segment, its exact effective boundary and recovery order must follow the future TIME/CHAR/NPC contract, not an invented retrospective rollback.

Show one clear interruption message. Threat explanations do not disclose hidden identity/location/count; generic nearby-enemy feedback is sufficient unless normal gameplay already authorizes more. Required-check failure explains inability to verify rather than falsely claiming a particular enemy exists. Resume ordinary play only after relevant UI and all other suspension/readiness gates permit. Rest does not auto-restart when a blocker disappears; a new player request gets fresh eligibility checks.

## Relevant formulas and parameters

No numerical threat radius, distance unit conversion, timer, rest-segment length or encounter probability is approved. Policy requires current scope, explicit purpose, structured results and stable reason priority. Exact thresholds and eligible-untriggered-spawner blocking remain design dependencies. Already committed elapsed time/recovery remains committed; no recovery is awarded for unelapsed time.

## Required data

Session/location/rest-operation identity; query purpose; actor state/hostility/alliance/pacification; relevant perception/pursuit/proximity; spawner eligibility; owner-scoped restriction registrations with requiredness/priority/reason; evaluation outcome and cache validity. TIME supplies rest-mode/boundary context and committed advancement state. UI receives player-safe reasons rather than unrestricted hidden-actor details.

## Inputs, outputs and events

Inputs: start/continue-rest check, current threat observations, encounter/state changes, registered condition results, declared boundary and retry/new-rest requests. Outputs: allowed/blocked/verification-failed outcome, prioritized safe explanation, rest-start denial or interruption of further advancement. APIs/signals remain deferred. Query results do not directly rewrite lifecycle, resume all simulation or perform healing.

## Cross-system interactions

TIME owns rest advancement/restriction aggregation and boundary policy; CHAR owns recovery consequences. NPC/COMBAT supply current threat eligibility/awareness and WORLD/LOC valid scope/geometry context. Encounter owners report spawner readiness/changes; QUEST/LAW/status owners may later declare concrete vetoes. MOD defines supported extension contracts. UI presents denial/interruption/retry and CORE-016 owns suspension handoff. CORE-018 shortcut entry reuses the same checks. CORE-005/015 ensure scope safety/committed context; CORE-017 cadence does not imply replaying ordinary AI steps for every elapsed rest-calendar unit.

## Edge cases and failure conditions

- A hostile actor briefly behind a wall is not automatically safe; a pacified actor is not automatically a threat merely because its prefab is an enemy. Owners define actual eligibility.
- Missing required perception/condition data cannot be treated as safe by catching an exception. Verification failure blocks/stops and permits retry.
- A spawner object near the player is insufficient evidence of danger when disabled/exhausted. Untriggered eligible policy remains open, not assumed safe or blocked.
- Multiple blockers use deterministic prioritized explanation. A missing translation/message cannot erase a real blocked result; text fallback mechanics are UI implementation scope.
- Actor death, pacification expiry, pursuit changes, spawn activation or location transition can invalidate cached results. Revalidate before committing another segment.
- An encounter generated by explicit rest/calendar logic must affect eligibility before the next segment, even when ordinary world simulation is paused for rest UI.
- Interruption cannot rewind already committed elapsed time/healing or award another hour just because UI still shows remaining duration. Exact simultaneous-event ordering remains TIME/CHAR scope.
- Repeated failed checks during one interrupted flow must not repeatedly pop messages or silently resume rest. A fresh retry/new request performs new checks.
- Ended-scope conditions and late callbacks cannot block another character/location. Optional extensions cannot become hidden permanent vetoes after failure.
- Rest feedback cannot be used as an exact hidden-enemy radar. The existence of a generic warning is intentional; names, coordinates and counts are not revealed by this interface.

This feature introduces no specific legal/status restriction, healing formula, rest duration, encounter probability or optimization index.

## Configuration and balancing options

Owners define rest-threat distances, perception/pursuit rules, boundary length/order, blocker priorities and encounter spawner policy. Data-driven tuning may be chosen later without approving arbitrary player bypass of required checks. Exact legal, quest and status vetoes require their own review. Shared queries permit different purpose-specific policies rather than one universal enemy-near boolean.

## Save/load considerations

Raw condition delegates, caches and scene references are transient and reconstructed under scope ownership. Supported saved rest/activity state follows SAVE/TIME contracts; loading/rest resumption requires fresh eligibility rather than a persisted safe boolean. Preserve committed elapsed state according to its owner; no automatic rollback/save or rest restart is approved here. CORE-013 restoration must not silently abandon required activities, but whether saving mid-rest is supported remains its owner contract.

## Technical constraints

Target engine: Godot 4.7.2. Separate observation/query policy from time advancement and UI. Use structured results and explicit owner priorities with scope-safe registrations. Do not assume Unity distance units, classic spawn heuristic or dictionary iteration order defines intended gameplay. A simple scan is acceptable until performance evidence supports indexing; no particular optimization or extension API is selected.

## Acceptance criteria

1. Rest uses NPC/COMBAT threat data through TIME policy; other callers declare purpose and do not automatically reuse rest distances.
2. Structured allowed/blocked/failed results control eligibility independently of message text. Multiple blockers use explicit stable priority; scoped registrations disappear at teardown.
3. Eligibility evaluates current actor behavior, proximity and pursuit/perception; brief LOS loss alone does not allow rest. Dead/inactive/pacified/allied actors are excluded unless genuine current threats under owner rules.
4. Disabled/exhausted/ineligible spawners do not block by proximity. Eligible-untriggered policy is explicitly resolved by its owners before claiming full coverage.
5. Check before rest and immediately before each declared advancement commit; process relevant threat/encounter changes before another segment. Caches cannot authorize stale session/location safety.
6. Interruption/required-check failure stops further advance, retains committed time/recovery and awards no unelapsed recovery. Required-check failure explains verification error with retry; optional failure uses declared fallback.
7. One clear interruption message does not expose hidden enemy identity/position/count. Other reasons use owner-safe explanations.
8. Gameplay resumes only as UI/suspension/readiness permit. Clearing the blocker never automatically restarts rest; a fresh request rechecks.
9. Time/quest encounter processing during explicit rest can invalidate rest despite ordinary simulation pause. Detailed healing/event order remains TIME/CHAR-defined without invented rollback.
10. Stale registrations/callbacks/results do not affect later sessions. Save/load reconstructs query state and rechecks eligibility rather than restoring a stale allowed flag.

These are future verification criteria. No implementation/runtime tests or gameplay threshold tuning have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001–008, CORE-010–013 and CORE-015–018 v1, CORE-009 deferral, CORE-014 exclusion, decision log, CORE catalog and CORE architecture review. All nine interview decisions are represented. No conflict identified: explicit TIME advancement remains distinct from ordinary pause, interruption releases only its UI's suspension, shortcuts honor owner checks and query work remains scoped. Exact TIME/NPC/encounter balance contracts remain open rather than adopted from DFU.

## Outstanding questions and approval

Before implementation is considered complete, owners must define threat distances/units, perception/pursuit/accessibility policy, rest segment/event/recovery order, eligible-untriggered spawner treatment, concrete vetoes/priority and optional extension fallback contracts. These are explicit design dependencies, not assumed defaults. No further blocking query-policy choice is identified for draft review.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-019. This document is finalized v1. Approval reference: CORE-019-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Exact thresholds, segment/event order, eligible-untriggered-spawner policy and other owner contracts remain open as documented. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
