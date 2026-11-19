# ITEM-002 — Custom item types and use hooks

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Support added items and distinctive use behavior while preserving item identity, saved state and explicit failure handling.

## Intended player experience

Supported added items behave consistently wherever use is requested. Special actions cannot accidentally consume or activate another behavior after rejection, cancellation or failure. Saved custom items retain their meaningful state; incompatible content produces explicit recovery.

## Confirmed requirements

- **ITEM-002-D01:** Allow data-only item additions when supported existing behaviors suffice. Special items explicitly select a validated behavior provider using a stable key independent of a programming class name.
- **ITEM-002-D02:** Resolve one authoritative use behavior per item. Combined behaviors must be explicitly declared and ordered. Competing registrations follow validated replacement rules or report a conflict; registration timing cannot silently select the winner.
- **ITEM-002-D03:** Distinguish handled, not applicable, blocked and failed use outcomes. Only not applicable permits continuing to the next declared behavior. Blocked/failed special actions cannot accidentally fall through to consumption, equipment or another built-in action.
- **ITEM-002-D04:** Validate access and quest restrictions before custom behavior executes. Quest interception versus ordinary use is explicitly declared per interaction; handler ordering cannot bypass quest protection. Detailed quest responses remain QUEST-owned.
- **ITEM-002-D05:** Target pickers, menus and confirmations create pending interactions that stop further use-handler dispatch. Revalidate item identity, custody/access, active session, eligibility and required resources before commitment. Cancellation obeys the action's approved cost rules, including retention of already committed magic costs where applicable.
- **ITEM-002-D06:** Distinguish rejection before mutation from failure after partial commitment. Preserve completed effects/costs and recover explicitly without blind retry, fallthrough or unsupported refund. Providers declare commitment and recovery rules.
- **ITEM-002-D07:** Preserve gameplay-relevant custom state in versioned provider-owned item data, including applicable charges, modes, cooldowns and resolved random properties. Unsupported versions require migration or explicit failure without silent reset.
- **ITEM-002-D08:** Inventory, hotkeys, controller and scripted requests share authoritative use validation with explicit actor/item/context. Selection/preview cannot activate an item. Caller-specific permissions must be declared.
- **ITEM-002-D09:** Save only at coherent boundaries. An action may explicitly support saving pending state; otherwise temporarily block saving with an explanation until completion/cancellation. Load cannot auto-confirm, double-spend, replay effects or accept old-session callbacks. Existing action-specific save rules remain binding.

The user confirmed each of three interviews with “1. Yes / 2. Yes / 3. Yes”. See [the decision log](../../GAMEPLAY_DECISIONS.md).

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Items/ItemHelper.cs#RegisterCustomItem` registers template/group and optional item class; the class name is registered for reconstruction through ItemCollection. `RegisterItemUseHandler` assigns a template-index handler, replacing a previous dictionary entry for that index.
- `Game/Items/DaggerfallUnityItem.cs#UseItem` offers a virtual item hook.
- `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem` checks the item hook, quest handling, registered handler and built-in actions in that order. Boolean handled results govern continuation.
- `Game/Items/ItemCollection.cs#DeserializeItems` reconstructs a registered class from saved className and restores item data; unavailable classes fall back to a base item.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; source unchanged.

## Existing approved constraints

DATA-010 requires stable definition identity, data-only additions where supported, validated required providers and explicit compatibility/migration failure rather than generic fallback. DATA-003 supplies validated content operations and deterministic precedence; executable-provider lifecycle remains MOD-owned. ITEM-001 preserves item identities and custody, prevents silent reference redirection and requires active session validation. MAGIC owns item-power costs/effects under its approved specifications; this feature does not replace those rules.

## Detailed rules and behaviors

### Added items and behavior resolution

Use existing supported behaviors for data-only additions. Special behavior explicitly references a validated stable provider key; programming class names and runtime object handles do not define saved behavior identity. Templates and instances retain DATA-010/ITEM-001 identity rules. This does not mandate inheritance, components or a particular scripting language.

Resolve one authoritative use behavior per item. A composite behavior may dispatch explicitly declared ordered steps; it is not an uncontrolled chain of independently registered callbacks. Competing registrations require supported validated replacement or explicit conflict failure. Registration timing cannot silently determine behavior. DATA-003 governs content resolution; executable discovery/activation and lifecycle remain MOD dependencies, including its constraints on pre-menu configuration rebuilds.

Missing required definitions/providers fail explicitly during readiness or restore as appropriate. Do not downgrade to a generic item. Stable provider identity alone does not prove version/payload compatibility. Data-only additions cannot request behavior the current system does not support.

### Admission and quest interaction

All supported callers submit explicit actor, item and context to authoritative validation. Validate current identity, access/custody, session, eligibility and applicable resource requirements. UI previews and selection are not use commitments; scripts do not obtain undeclared permission to bypass checks.

Validate quest restrictions before executing custom behavior. The interaction explicitly declares quest interception versus ordinary use and any permitted continuation. Handler position cannot bypass protection. QUEST owns detailed resource bindings, responses and overrides; no universal quest action priority beyond these safeguards is approved.

### Dispatch outcomes and pending work

Distinguish handled, not applicable, blocked and failed. Only not applicable permits advancing to the next explicitly declared behavior. It cannot serve as a failure result after committing an action. Handled does not necessarily mean an item was consumed or a gameplay effect succeeded; detailed action outcomes remain explicit.

Blocked/failed requests stop dispatch without triggering unrelated built-in use. A deferred picker, menu or confirmation owns a pending interaction and stops dispatch while unresolved. Concrete representation of pending versus terminal outcomes is unselected. Before later commitment, revalidate item, access, session, eligibility and resources rather than trusting the original UI selection. ITEM-001 prohibits silently redirecting retired/merged identities.

### Costs, commitment and recovery

Each provider declares eligibility, commitment, costs, outputs and recovery rules. Distinguish pre-mutation rejection from failure after committed effects/costs. Retain completed facts and recover explicitly without blind replay, unintended fallthrough or unsupported refund. Operation identity and phase tracking must prevent a repeated callback/retry from repeating committed rewards or costs; concrete APIs remain open.

Cancellation follows the action's approved rules. No universal free-cancellation or refund rule supersedes MAGIC-003/004/016/027/030 or other owner contracts. ITEM coordinates use and item-state changes; MAGIC, COMBAT, QUEST and other owners authorize their own effects. This feature does not grant arbitrary handlers permission to mutate those systems directly outside their contracts.

## Relevant formulas and parameters

No new item price, resource cost, cooldown, stack limit, provider limit or timing constant is selected. Existing approved action-specific formulas remain binding. Behavior/state version identifiers require explicit compatibility interpretation, not an assumed numeric comparison rule.

## Required data

Stable template/item/provider identities; provider/state schema versions and compatibility metadata; explicitly resolved use behavior and ordered composition where applicable; caller/actor/context and declared permissions; quest constraints; applicable custom state; pending operation/session identity, selections, costs and completed phases; truthful outcomes/recovery facts. Exact registry, payload and serialization schemas remain dependencies.

## Inputs, outputs and events

Inputs: validated content/provider registrations; explicit actor/item/context use requests; pending selection/confirmation/cancellation; owner results; save/restore and migration requests. Outputs: resolved behavior, not-applicable/blocked/handled/failed outcomes, pending interaction, committed owner results and explicit compatibility/recovery information. Notifications report completed facts and cannot independently repeat authoritative mutations. Concrete signals, result types and callback protocol remain unselected.

## Cross-system interactions

- DATA-003/010 own stable definition resolution, validation and required-provider references; MOD owns executable lifecycle and supported replacement/registration semantics.
- ITEM-001 owns identity, custody, retired references and scoped sessions. ITEM-005/006 must preserve custom state and behavior where split/merge is allowed; ITEM-025/SAVE integrate reconstruction.
- QUEST owns restrictions/interception and linked resource responses. UI supplies explicit requests and displays pending/recovery states.
- MAGIC-016 retains source identity, charge/condition costs, trigger lifecycle and no-replay reconstruction. MAGIC-027 retains deferred selection/revalidation and its action-specific accounting. MAGIC-030 retains artifact-specific commitment/reward rules.
- CORE-013/SAVE own coherent restore/admission and recovery. Use outside inventory follows the same authority without asserting that every caller supports every action.

## Edge cases and failure conditions

- Conflicting registration: report invalid replacement/conflict rather than silently accepting the last registration.
- Required provider missing or custom data incompatible: migration or explicit failure; no generic fallback/state reset.
- Custom action blocked/failed: no accidental default drinking/equipping/consumption.
- Quest-protected item: custom ordering cannot bypass restriction; exact quest outcome is owner-defined.
- Item moved, consumed, merged or changed during a picker: revalidate, reject or recover under declared action rules; no silent redirection.
- Repeated confirmation or stale callback: no repeated reward/spend; old-session callbacks cannot affect restored items.
- Failure after committed cost/reward: preserve completed results and recovery facts rather than retrying the whole action.
- Save during unsupported pending work: explain temporary restriction; supported snapshots retain coherent facts without auto-confirmation.

## Configuration and balancing options

Validated data-only additions, provider selections and declared ordered composites are supported. Costs, cooldowns, modes, eligibility and cancellation rules remain configurable only through their owner-approved profiles. No setting for silent conflict resolution, required-provider downgrade or bypass of identity/quest validation is approved.

## Save/load considerations

Persist provider-owned gameplay state with explicit versions, retaining applicable charges, modes, cooldowns and resolved random properties. Unsupported versions require migration or explicit failure. Changing class names alone must not redefine provider identity; provider/key migration still needs explicit compatibility.

Save at coherent boundaries. Pending-state saving requires explicit action support and a defined reconstruction policy; otherwise explain temporary save blocking until completion/cancellation. This does not universally approve resuming or canceling every saved picker. Preserve committed facts without replay, auto-confirmation, double-spend or random reroll. Apply existing action-specific restrictions and native-load cancellation rules. Reconstruct item behavior without treating restore as a fresh use/equip/strike/break event. Classic/DFU save import is not specified here.

## Technical constraints

Target Godot 4.7.2. Separate resolved definitions/providers, mutable item state, authoritative operations and UI presentation. Concrete inheritance/component design, provider execution boundary, registry format, pending-state protocol and serialization remain engineering dependencies. No generic scripting framework, executable hot-unload or unrestricted handler chaining is mandated. Reference source remains unchanged; no implementation or coding tasks authorized.

## Acceptance criteria

1. Supported data-only additions use existing behavior; special items resolve validated stable providers independent of programming class names.
2. Competing registrations resolve only through declared validated replacement or explicit conflict. Ordered composites have deterministic declared dispatch.
3. Only not applicable advances dispatch; blocked/failed/pending use cannot accidentally activate built-in behavior.
4. Access/quest restrictions apply before custom execution; caller ordering cannot bypass them.
5. Deferred commitment revalidates identity, custody/access, active session, eligibility and resources; cancellation respects approved action costs.
6. Repeated callbacks/recovery cannot duplicate committed effects or costs. Partial failure preserves completed facts and explicit recovery.
7. Versioned custom state survives native save/load; unsupported providers/versions require migration or explicit failure without downgrade/reset/reroll.
8. Inventory/hotkey/controller/script callers share authoritative validation with declared permissions; preview/selection does not activate behavior.
9. Unsupported pending saves are temporarily blocked with explanation; supported snapshots restore coherently without auto-confirmation, old-session callbacks or replayed effects.

## Contradiction review

Reviewed against approved ITEM-001 and DATA-003/010, and the MAGIC-016/027/030 contracts reviewed during this feature sequence. No direct contradiction identified. Stable keys refine DATA-010 without choosing executable lifecycle. Declared quest handling replaces automatic adoption of DFU ordering. Action-specific cost/save rules override generic assumptions; custom-state restore does not replay MAGIC triggers. This draft does not approve broader ITEM architecture proposals or finalize future QUEST/MOD/ITEM features.

## Outstanding questions

No further blocking player-policy choice is identified. Before implementation is complete: provider identity/registry and executable activation contracts; validated replacement/composition schemas; quest-use arbitration; outcome/pending operation and commitment/recovery protocols; versioned custom payload/migration and split/copy preservation rules; caller permissions and action-specific pending-save reconstruction; native fixtures. These dependencies cannot waive confirmed dispatch, validation, state preservation or failure rules.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-002-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented provider/registry lifecycle, composition, quest arbitration, pending/commit/recovery, custom-state migration, caller permissions and native persistence dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
