# MOVE-018 — Targeting and dispatch order

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Resolve deliberate activation to the intended visible target and execute one primary interaction, with explicitly composed quest/mod reactions. Avoid through-wall interaction, stale prompts and duplicate effects while retaining interaction-specific feedback and optional modded presentation.

## Confirmed requirements

MOVE-018-D01–D11 in [the decision log](../../GAMEPLAY_DECISIONS.md) record four interviews across 2026-11-07/08. D09/D10 supersede the proposed default actionable-target indicator: proactive indicators are off by default; existing interaction-specific attempted responses remain. MOVE-001/003 input cancellation, camera/cursor targeting and CORE context ownership remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths below are relative to reference `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/PlayerActivate.cs#Update` uses `ActionComplete(ActivateCenterObject)` and a ray from active gameplay cursor or camera forward. It excludes activation over the large HUD and applies readied-spell/click-delay gates.
- Non-person quest resource click handling precedes building, static/action door, action mechanism, loot, board, NPC/enemy and furniture checks. Several checks are independent; returns in some paths alter composition.
- Registered model/flat callbacks and hit-object `IPlayerActivable` can both run when reached. `RegisterCustomActivation`/`HandleRegisterCustomActivation` retain custom distance/provider data; scene names identify source matches.
- Default/door/treasure reach is 128 classic units, corpse 150 and NPC 256; `MeshReader.GlobalScale` 0.025 yields reference 3.2/3.75/6.4. The long ray distance is separate from execution reach. Source touch-spell gating excludes some mobile interactions rather than defining a complete target arbitration contract.

Target rules do not copy callback order, scene-name identity or unrestricted multiple primary effects by implication.

## Detailed rules and behaviors

### Input and target acquisition

Activate on deliberate release, resolving the target at release rather than retaining a press-time target. Menu/focus/load/disconnect cancellation is distinct from release and cannot activate anything. Use MOVE-003 center ray in captured look or cursor-position ray in gameplay cursor mode, with HUD consumption and actual-facing consistency.

Select the nearest relevant collision along the ray. A nearer solid obstruction blocks interaction behind it even when the obstruction has no action. Do not search through a wall for the next interactable. Explicit nonblocking decorative geometry needs validated classification; exact collision masks/owner resolution remain engineering contracts.

Resolve stable target identity, selected action/mode and hit context before primary execution. Category reach baselines are moddable: ordinary objects/doors/treasure 3.2, corpses 3.75, NPCs 6.4 reference units. Validate reach before primary effects or quest attempt notifications. Exact world-scale conversion, Info reach and owner-specific availability remain separate contracts; no universal long-distance action is authorized by ray length.

### Dispatch and consumption

Handlers report explicit Not applicable, Handled, Blocked or Deferred outcomes. Handled/Blocked/Deferred consume the primary interaction, preventing competing primary handlers. Not applicable means no effects were committed and routing may continue; it cannot conceal partial execution or an error.

Applicable explicit quest overrides precede ordinary built-ins. Quest observation instead registers as a separate notification with declared attempt versus successful-result timing. Neither a quest component nor an observation automatically replaces a door/loot/dialogue action.

Mods declare primary replacement or result observation. Resolve replacement conflicts through validated provider order with diagnostics; do not execute every matching replacement. Built-in fallback is allowed only on explicit effect-free Not applicable, never after failure or partial execution. Exact quest-versus-mod override precedence and per-target built-in order must be declared before implementation, not left to callback registration order. RULE-004 governs provider identity/validation/failure where applicable.

Observers cannot turn the activation into a second primary action or repeat the completed one. Required gameplay reactions use explicit checked quest/domain contracts; optional UI/audio observer failures cannot replay primary effects. This does not forbid intentional quest progression from an interaction, but requires its own once-only outcome/commit semantics. No generic rollback of partially executed gameplay is promised.

### Spells and deferred actions

A non-touch readied spell owns activation input, preventing ordinary fall-through. For a readied touch spell, MAGIC gets first refusal on an eligible entity in touch range; otherwise permitted environmental actions may proceed. One input cannot cast and interact. Exact touch eligibility and accepted/blocked spell consumption are MAGIC contracts, not inferred from component presence.

Deferred prompts retain stable target and intended action. On confirmation revalidate existence, range, obstruction, access and current context. Invalid intent cancels with explanation without retargeting or replaying earlier effects. Door/loot/dialogue policies stay with their owners. Context/session invalidation rejects stale confirmations even if a numeric target identifier is reused.

### Communication and preview purity

Proactive indicators/highlights/hover labels are off by default. Retain existing interaction-specific attempted responses such as too-far or locked-door explanations; introduce no generic blocked-popup layer. Mods can customize communication by interaction type through validated policies. Exact existing-response inventory and UI wording remain owner review, not a blanket promise of source-perfect text.

Preview queries cannot run quest scripts, consume randomness, discover content or mutate state. No mandatory empty-space activation message. Optional presentation failure cannot re-run dispatch or alter reach/access. Required diagnostic/recovery information remains governed by CORE rather than hidden by indicator settings.

## Relevant formulas and parameters

Category reach values are 3.2/3.75/6.4 reference units as above, with explicit scale conversion. Check target hit distance against the applicable validated reach before execution; exact distance reference and collider/parent ownership require consistent fixtures. No input-repeat duration, ray thickness, global priority number or Info-mode range is selected. Provider/notification order is a declared contract, not numeric scene traversal accident.

## Required data

Activation identity and eligible release; session/context/mode; cursor/camera ray; hit/obstruction and stable target ownership; category reach; handler/provider roles/order; outcome/consumption and completion state; deferred target/action/revalidation requirements; per-type communication policy. Exact schema and API remain implementation dependencies.

## Inputs, outputs and events

Inputs: deliberate release, active context/mode/readied spell, hit/target data, handler results and prompt confirmation/cancellation. Outputs: one consumed primary result or effect-free continuation, checked quest/domain notifications, deferred intent and owner-specific feedback. API names remain unselected. Polling/preview is not an authorized interaction or notification attempt.

## Cross-system interactions

MOVE-001/003 input/view/cursor; MOVE-019 modes; MOVE-020–025 doors, objects, actors and custom activation; MAGIC spell arbitration; QUEST override/observation; ITEM/NPC/LAW/LOC access and consequences; MOD/RULE provider contracts; DATA stable identities; UI prompts/communication; CORE scope/readiness and SAVE restored activities. Dispatch does not absorb those domains' action formulas or permissions.

## Edge cases and failure conditions

Test overlapping handlers, quest-tagged doors, mod replacements, decorative masks, solid blockers and cursor/HUD boundaries. Blocked nearer targets cannot reveal a farther actionable target by automatic fallback. A handler failing after mutation cannot silently use a second provider/default. Repeated release/delivery/confirmation cannot duplicate primary effects.

Targets moving or disappearing during prompts must fail current revalidation without reassignment. Spell completion input cannot fall through into world action. Disabled indicators cannot hide required recovery or change gameplay. Exact behavior when required quest work fails after primary commitment needs owner recovery, not replay.

## Configuration and balancing options

Validated reach, provider/handler roles and per-type communication policies support customization. Proactive feedback defaults Off. Built-in interaction-specific attempts retain their responses unless explicitly overridden. Mod replacements remain single selected primary behavior; no arbitrary all-callback execution or through-wall reach bypass is approved.

## Save/load considerations

Raw press/release queues, ray hits and object references are transient and cannot replay after load. Supported restored prompts/activities require stable target/action and fresh revalidation under UI/SAVE owners before continuation. Persist required committed gameplay facts rather than observer/audio state. Exact save eligibility and partial-operation boundaries remain domain/SAVE contracts.

## Technical constraints

Target: Godot 4.7.2. Separate pure targeting/preview, eligibility, checked primary dispatch, notifications and deferred confirmation. Use scope-safe stable identity and explicit consumption rather than implicit callback order or scene names alone. Physics masks, target ownership, provider signatures and failure recovery require fixtures. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Only deliberate eligible release activates, using release-time target and approved cursor/center ray; cancelled input/HUD clicks do not fall through.
2. Nearest solid obstruction blocks farther actions; nonblocking exceptions are explicitly classified.
3. Category reach is validated before primary/quest attempt execution; long ray length is not action permission.
4. Handled/Blocked/Deferred consume primary routing; effect-free Not applicable alone permits fallback.
5. Explicit quest overrides precede built-ins; quest observation has declared timing without replacing actions implicitly.
6. Mod replacement conflicts resolve one provider with diagnostics; errors/partial execution cannot trigger default replay.
7. Required gameplay observers have checked once-only contracts; optional observers cannot repeat actions.
8. Readied-spell arbitration permits at most casting or interaction from one input.
9. Deferred confirmation revalidates target/range/obstruction/access/context and never retargets silently.
10. Proactive indicators are Off by default, per-type feedback is moddable, and preview/empty-space queries cause no gameplay side effects.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-001/003, CORE context/scope requirements, RULE-004 provider principles and MOVE catalog/architecture. No direct contradiction identified. Notifications preserve intentional composition while preventing a second primary action. Release activation remains distinct from cancellation. D10 explicitly clarifies D09's off-by-default preference as proactive indicators, preserving attempted owner responses. Quest/mod cross-priority and concrete handler inventory remain explicit dependencies, not invented approval of DFU's entire sequence.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Before implementation is complete resolve target/collider ownership and masks, quest-versus-mod override precedence, built-in ordering, notification timing/failure boundaries, Info reach, spell consumption, per-type response inventory, hook schemas and deferred/save identity fixtures. These do not waive solid blocking, one-primary consumption or pure preview.

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under MOVE-018-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented routing, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
