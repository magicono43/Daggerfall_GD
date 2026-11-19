# MOVE-025 — Mod and component activation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Let custom content participate predictably in interaction without double primary actions, name-based identity errors, stale callbacks or unsafe fallback after mutation. Provider resolution, scope and durable state are explicit and reviewable.

## Confirmed requirements

MOVE-025-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. MOVE-018 dispatch/preview, DATA-003 configuration lock, RULE-004 provider/failure principles and CORE scope/readiness remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths relative to reference `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/PlayerActivate.cs#RegisterCustomActivation` accepts model ID or flat texture archive/record, provider, callback and distance, deriving scene-object names for lookup.
- `HandleRegisterCustomActivation` compares provider load priority and replaces dictionary entries. This is not a fully validated staged registration contract.
- `Update` normalizes hit object name, invokes matched callback within registered reach, then independently calls hit-transform `IPlayerActivable.Activate`. Both can execute on one hit.
- `IPlayerActivable` receives Unity `RaycastHit` and returns void; it does not itself declare primary consumption, pure preview or persistence semantics.

Target replaces incidental naming/double callbacks with shared explicit contracts; no Unity API compatibility layer is approved implicitly.

## Detailed rules and behaviors

### Identity, context and roles

Support stable model/flat/content identity and explicit instance-specific components. Display names/node names are not authoritative registration identity. Resolve collider ownership to a declared interaction target rather than assuming the hit child object owns the whole action.

Components and registrations share MOVE-018 roles: primary replacement or result observation. They cannot independently execute two primary effects because both matched. Instance-specific primary precedes broad content-type primary. Applicable quest overrides retain MOVE-018 routing; exact quest-versus-mod cross-priority still requires its declared owner contract.

Pass validated context containing stable target, selected mode/action, acting player, hit location, distance and operation identity. Declare supported modes/reach and honor obstruction/context gates. Attaching a component cannot bypass Info safety, target eligibility or primary consumption.

### Selection and configuration

For replacement conflicts within the same scope/key select the last valid provider in resolved enabled-mod order. Retain candidates/winner provenance for diagnostics; no arrival-order or separate hidden priority scheme. Validate registrations before actual main-menu entry and lock provider membership/selection for the application run under DATA-003/MOD rules.

Invalid contributions require explicit recovery rather than silent omission. If safe omission/reconfiguration is offered, use approved RULE-004/MOD contribution/dependency validation and restart rules; do not publish partial registration state or imply executable unloading is safe.

Instance binding/unbinding to existing validated definitions is distinct from changing locked providers. Application-level definitions must not capture ended-session objects. Teardown invalidates instance bindings, callbacks and prompts; destroyed targets cannot redirect work to later replacements. No live mod-provider switching is introduced.

### Invocation, fallback and observers

Primary handlers return Not applicable, Handled, Blocked or Deferred under MOVE-018. Only explicit effect-free Not applicable permits routing fallback. A throwing/invalid primary stops the affected operation and enters owner recovery without trying another provider or built-in action after possible mutation. Recovery cannot assume rollback or safe callback replay.

Observers use declared stable order once per registration/outcome. Duplicate binding cannot multiply effects. Required gameplay observers have checked domain contracts; optional presentation observer failure cannot replay primary effects. Exact observer ordering inventory and requiredness are declared before hook exposure, not accidental scene traversal.

Recursive activation requires an explicit bounded domain contract rather than automatic re-entry. Intentional mechanism/quest chains use their owner identities/schedules under MOVE-021/QUEST; deduplication must not suppress legitimate later activations. No generic all-callback chain or global event bus is mandated.

### Preview and persistence

Provide a separate explicitly pure query for supported descriptions, availability and optional presentation. Never invoke activation as a preview. No random draws, item/quest mutations or discoveries. Custom indicators remain Off by default under MOVE-018; availability estimates are not commit-time permission.

Persist only validated versioned custom state with stable provider/target identity, not executable callbacks, closures or engine objects. Restored deferred actions revalidate target/context and completion before continuation. Missing required provider/state uses compatibility/recovery rather than silent fallback. Unsupported in-flight custom actions declare save restriction/reason. No arbitrary mod-code serialization is promised.

## Relevant formulas and parameters

No new gameplay formula applies. Hook reach and mode domains must be validated against the applicable declared action contract; extended reach is not permission to ignore solid blockers. Same-scope replacement selection follows resolved mod order; instance scope precedes content scope. Numeric domains, version format and recursion budget remain explicit owner dependencies.

## Required data

Stable content/instance/provider/hook identities, validated role/scope/mode/reach, resolved mod order/candidates/winner, current scope binding, interaction context/outcome, observer order/requiredness, completion and custom schema/version. Concrete key encoding and APIs remain engineering work.

## Inputs, outputs and events

Inputs: staged registrations, validated configuration, instance bind/unbind, pure query, authorized activation/outcome and native restore. Outputs: selected handler, checked result/observation, pure description, diagnostics or explicit recovery/save restriction. API names unselected. Registration alone cannot authorize gameplay execution.

## Cross-system interactions

MOVE-018/019 dispatch/Info, MOVE-021 bounded authored chains and other MOVE domains own consequences. MOD/DATA own identities, enabled order, schemas and activation; RULE-004 guides provider validation/failure; CORE scopes/readiness; QUEST required reactions; ITEM/MAGIC/LAW checked mutations; UI pure presentation and SAVE custom compatibility. No hook grants blanket access to otherwise unsupported domain mechanics.

## Edge cases and failure conditions

Test same-scope conflict, broad plus instance match, collider children, duplicate binding, ended scene callbacks, target replacement and error after partial mutation. No double primary invocation or fallback replay. Preview failure cannot execute primary. Same provider local IDs in another session cannot revive a stale prompt. Required saved-state mismatch cannot silently select an earlier provider. Bounded explicit recursion must preserve legitimate scheduled events while rejecting malformed self-activation loops.

## Configuration and balancing options

Supported target bindings/roles, hook reach/modes, pure presentation and versioned custom state are extensible through validated contracts. Provider set remains run-locked. No silent hot reload, arbitrary callback stacking, default indicator activation or automatic error fallback is introduced.

## Save/load considerations

Serialize durable custom state/provenance and required completion, reconstruct instance bindings only after valid geometry/content/provider readiness. Never serialize raw callback/object authority. Unsupported required state follows compatibility/recovery or declared save restrictions, not quiet omission. Exact transaction/checkpoint boundaries remain domain/SAVE contracts and cannot duplicate committed effects.

## Technical constraints

Target: Godot 4.7.2. Separate registration resolution, instance lifetime, pure preview and checked execution. Public typed interfaces/key schemas, Godot node/signal choices and validation machinery remain unselected. Concrete implementation requires scope and failure fixtures. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Stable content/instance identity resolves declared collider owner independently of names.
2. Instance and broad registrations share role/outcome semantics with instance primary precedence and no double primary effects.
3. Context/mode/reach/obstruction validation applies equally to components and registered handlers.
4. Same-scope conflicts choose resolved-order winner with diagnostics; invalid contributions cannot silently publish and providers stay run-locked.
5. Instance teardown rejects stale callbacks/prompts without switching providers or redirecting targets.
6. Only effect-free Not applicable permits fallback; errors/invalid outcomes enter checked recovery without replay.
7. Observers have stable once-per-registration/outcome semantics and explicit bounded recursion/required-work contracts.
8. Preview is pure, indicators remain Off by default, and saved custom state is versioned data rather than executable/engine references.
9. Restore revalidates state/context/completion; missing required providers and unsupported in-flight state have explicit recovery/save policy.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-018/019/021, RULE-004, DATA-003 and CORE scope principles. No direct contradiction identified. Definition lock permits scoped instance reconstruction without live provider changes. Instance precedence is scope selection, not uncontrolled callback order. Required versus optional observers retain domain failure semantics. Generic Not applicable fallback never authorizes replay after mutation. Exact quest/mod cross-priority remains explicit dependency from MOVE-018.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: hook/key inventory, scope specificity/collider ownership, quest/mod cross-priority, observer order/requiredness, recursion bounds, provider omission/activation safety, context signatures, native schemas and fault/lifetime fixtures. These do not waive validated selection, pure preview or no duplicate primary effects.

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under MOVE-025-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented hook, provider, lifetime, persistence and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
