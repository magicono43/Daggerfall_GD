# ITEM-006 — Stack splitting and one-unit removal

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Separate or consume quantities while preserving meaningful state, authoritative custody and item identity without loss or duplication.

## Intended player experience

Players can separate possessions and consume units predictably. Splitting retains appearance, knowledge, contents and remaining lifetime without free charges or lost items. Retries and saves cannot repeat consumption or rewards.

## Confirmed requirements

- **ITEM-006-D01:** A standalone partial split creates a separate entry in the same collection. A full-count request returns the existing entry without custody change. Moving it elsewhere requires transfer; splitting alone cannot leave it unowned.
- **ITEM-006-D02:** Type-aware splitting preserves actual contents, provider behavior, condition, knowledge, dye, expiry and provenance as applicable. Mutable state cannot accidentally be shared between stacks. Unsupported special-state splitting rejects unchanged rather than creating a generic copy.
- **ITEM-006-D03:** Validate access, available quantity, destination entry capacity, caps and required state handling before reducing source quantity. Failed separated-entry creation leaves the original unchanged. Return explicit quantities and original/new identities.
- **ITEM-006-D04:** Consumption differs from extraction for transfer. Consumption reduces quantity and retires identity only at the last unit; extraction preserves contents through split/transfer rules. Quantity removal alone does not cast, reward or invoke item-use effects.
- **ITEM-006-D05:** The owning action coordinates consumption with its effect/projectile/payment/reward. Repeated callbacks cannot consume or grant twice. Pre-commit failure leaves quantity unchanged; partial-commit failure retains completed facts and explicit recovery under approved action rules.
- **ITEM-006-D06:** Splitting cannot duplicate finite charge pools, stored souls, unique entitlements or other stack-wide resources. Such types need explicit conserving allocation rules or reject splitting. Ordinary per-unit properties may be retained on both results without multiplying independently limited resources.
- **ITEM-006-D07:** Valid full-quantity requests, including singletons, return the existing entry unchanged even when stacking is ineligible. Partial splitting needs a supported representation. Returning an entry grants no use/transfer permission.
- **ITEM-006-D08:** Ordinary interchangeable stacks require no unit selector. Supported heterogeneous types declare deterministic selection/allocation, honoring explicit unit requests where supported. Split/consumption cannot silently select a more valuable unit or reroll properties.
- **ITEM-006-D09:** Save coherent completed operations or explicitly supported pending progress; otherwise explain temporary save blocking. Load preserves quantities, identities, resource allocation and completed effects without replay. Old-session callbacks cannot consume again; action-specific save rules remain binding.

User confirmed each of three interviews with “1. Yes / 2. Yes / 3. Yes”. See [the decision log](../../GAMEPLAY_DECISIONS.md).

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Items/ItemCollection.cs#SplitStack` checks stack/membership/amount, returns original on full count, otherwise constructs a base DaggerfallUnityItem copy, adds without merging and reduces original count.
- `RemoveOne` checks UID membership, decrements count and removes the entry at count <= 0, returning void.
- `Game/Items/DaggerfallUnityItem.cs` copy constructor allocates a new UID and `FromItem` copies selected fields and enchantment arrays. This path does not reconstruct a custom subclass or explicitly copy every possible state field.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/classic-parity verification; reference source unchanged.

## Existing approved constraints

ITEM-001 requires new identity for partial splits, original identity for full movement, original references retained on split and retirement after final consumption. ITEM-005 requires positive whole quantities, complete state preservation, cap/admission validation and whole-operation rejection without partial mutation. ITEM-002–004 require provider/content/resource preservation and explicit recovery; RULE-025 eligibility alone does not establish safe special-state split semantics. COMBAT/MAGIC owners authorize ammo/consumable use and effects.

## Detailed rules and behaviors

### Admission and full-quantity requests

Resolve the actual authoritative item using stable identity and current custody/session context, not merely a supplied object with a matching ID. Validate access and positive whole requested quantity within availability and supported numeric bounds under ITEM-005. Invalid requests fail without mutation. Expiry, quest and other action restrictions remain owner checks; identity alone grants no permission.

A valid full-count request returns the existing entry, including a singleton or nonstackable item. No new identity, entry or custody change occurs. This result is not consumption, transfer, equip or use authorization. A partial split needs a supported state representation and valid resulting entries; eligibility alone does not establish that support.

### Standalone partial split

Create a separate entry in the same collection without automatically merging it back. Preserve the original identity on the remainder and allocate a fresh identity to the separated quantity under ITEM-001. Existing references stay on the original. Transfer elsewhere is a separate owner-authorized operation under ITEM-007; splitting cannot leave an unowned result.

Validate the complete plan, including source quantity, access, current state, caps, entry admission and construction/provider support before reducing the source. A failed separated-entry creation leaves the source and collection unchanged. Standalone separation cannot bypass entry limits simply because total weight is unchanged. Split-plus-transfer callers must coordinate their complete operation without relying on an unowned temporary item; exact staged transfer design remains ITEM-007 integration.

Use ITEM-005 no-stack/cap rules for separated entries. An oversized or otherwise unsupported saved stack requires approved migration rather than using ordinary split as a hidden compatibility fix. Successful ordinary partial split conserves total quantity; it is not a new item grant or copy reward.

### Contents and resource allocation

Preserve provider behavior, actual potion/enchantment contents, condition, knowledge, material/style/dye, expiry and provenance as applicable. Type-aware state handling must preserve all required fields, not downgrade to a base item or omit unknown custom state. Independently mutable state must not alias accidentally across results; sharing immutable definitions or explicitly owned shared resources is distinct from accidental mutable sharing.

Splitting cannot refill resources, reroll properties, restart expiry or duplicate a stored soul/unique entitlement. Distinguish genuine per-unit properties from stack-wide finite resources. Per-unit condition/payload copied to the resulting homogeneous stacks represents the same units, not a grant of extra units. Stack-wide resources require explicit conserving allocation and owner-reference rules; unsupported allocation rejects unchanged. This feature does not approve stacking souls, artifacts or other restricted types by implication.

Ordinary interchangeable stacks need no persistent individual-unit identity. Supported heterogeneous representations declare deterministic unit selection/allocation and supported explicit selectors. Never infer selection from UI sorting, silently choose a more valuable unit or reroll. Preserve COMBAT-008 per-shot payload/provenance and other owner attribution requirements.

### Consumption versus extraction

Extraction preserves a unit's contents through split/transfer without treating it as destroyed. Consumption permanently removes the authorized quantity; one-unit removal reduces count by one. If units remain, retain the stack identity and relevant state. Final-unit consumption removes the entry and retires its identity, without leaving a zero-count live stack. Unsupported/invalid quantity or access fails unchanged.

Quantity mutation alone does not cast, activate, equip, reward or execute arbitrary provider use hooks. The owning action coordinates consumption with its effects, projectile, payment or reward. Retain operation identity and completed phases so repeated confirmations/callbacks cannot consume or grant twice. Pre-commit rejection leaves quantity unchanged; partial action commitment preserves completed facts and explicit recovery under ITEM-002 and applicable COMBAT/MAGIC contracts. Do not promise a universal refund or assume quantity/effect settlement can always roll back.

### Outcomes and notifications

Report full-count unchanged, split completed, unit consumed or rejected, with source/result identities, quantities and resource allocation as applicable. Final consumption explicitly reports retirement; no silent reference redirection to another stack. Failures distinguish invalid quantity, stale/missing identity, access/admission, unsupported state and required technical recovery. Concrete result types are unselected.

Notifications describe committed facts, not permission for observers to repeat use effects, removals or grants. A returned entry/reference alone cannot bypass further current-state validation.

## Relevant formulas and parameters

For partial split amount n from count Q: 0 < n < Q; resulting counts sum to Q, with original remainder Q − n. Full request n = Q returns the existing entry unchanged. One-unit consumption requires Q >= 1 and produces Q − 1 surviving units, retiring the entry when Q = 1. All live counts are positive integers within supported bounds. Shared finite-resource allocation conserves that resource except separately authorized committed expenditures; no universal allocation formula, ID width or unit-priority rule is selected.

## Required data

Stable item/template/provider and active session/operation identities; authoritative collection/custody; quantity/request mode; eligibility/split representation and cap/admission rules; actual per-unit/stack-wide state, resource ownership and allocation; optional declared unit selector; source/result identities, retired identities and completed action/recovery facts. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: owner-authorized split/extraction/consumption request, explicit quantity/context and optional supported unit selection; authoritative item/collection state; validated provider/allocation rules and action results. Outputs: unchanged full-count reference, committed split/consumption outcomes or explicit rejection/recovery, with relevant identities/counts/state allocation. Splitting is not an item-created reward or item-used trigger. Concrete APIs/signals and receipt schemas remain open.

## Cross-system interactions

ITEM-001 owns identity/custody/reference retirement; ITEM-005 owns quantity/cap/no-stack admission and state compatibility; ITEM-002 owns provider/commit/recovery safeguards; ITEM-003/004 supply retained equipment and magic/consumable contents. RULE-025 eligibility does not authorize unsupported splitting. ITEM-007 coordinates transfers and destination admission. COMBAT-008 owns ammo release/recovery, MAGIC owns effect costs and consumable/source lifecycle, QUEST protects bindings, UI supplies explicit requests and SAVE/CORE coordinate native reconstruction. Their action-specific rules remain binding.

## Edge cases and failure conditions

- Zero/negative/fractional/over-available/out-of-range amount: reject unchanged.
- Singleton/nonstackable full-count request: return original after validation, without new permission or custody change.
- Partial split lacking custom-state/allocation support: reject rather than generic-copy or duplicate charges/souls.
- Collection entry limit or separated-entry creation failure: no source reduction or orphan result.
- Same-session repeated callback or old-session completion: no repeated consumption/grant.
- Expired/moved/merged source during deferred action: revalidate current context; no silent destination alias.
- Final-unit consumption: remove/retire once, preserve historical released-action attribution where required.
- Mutable provider state: independent results cannot accidentally mutate one another; intentionally shared ownership requires explicit rules.

## Configuration and balancing options

Supported custom split representations, deterministic unit selection and conserving resource-allocation profiles are extensible through validated contracts. Caps and eligibility follow ITEM-005/RULE-025. No default split fee, consuming effect, automatic transfer, universal resource division or new special-item stacking permission is approved. Declared selection cannot use rerolls or value-based substitution implicitly.

## Save/load considerations

Persist coherent completed quantities, original/new/retired identities, contents, knowledge, expiry and resource allocation. Supported pending owner operations retain completed facts and recovery without repeating consumption or effects. Otherwise temporarily block saving with a clear reason until a supported boundary; existing action-specific restrictions/cancellation rules remain binding.

Native restore cannot repeat split, allocate duplicate possessions, consume again, refill resources or restart expiry. Required provider/state incompatibility follows explicit migration/recovery under DATA-010/ITEM-001–005/CORE-013. New session context invalidates old callbacks even when saved IDs match. Exact save schemas, migration and pending-operation reconstruction remain integration work.

## Technical constraints

Target Godot 4.7.2. Separate split planning, provider state allocation, authoritative collection changes and action-level effect settlement. No dependence on base-class copying, runtime class names or engine object identity for persistent behavior. Safe commitment must prevent partial standalone split mutation, while retaining truthful partial external action facts. No generalized transaction framework is mandated. Reference source remains unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Full-count requests including singleton/ineligible items return the validated original unchanged; no new identity/custody/use permission.
2. Partial splits create separate same-collection entries, retaining original identity/references on remainder and assigning fresh result identity.
3. Successful splits conserve quantity and preserve actual provider/content/appearance/knowledge/expiry/provenance state without accidental mutable aliasing.
4. Invalid amount, access, capacity, cap or required state/creation failure leaves the entire standalone split unchanged.
5. Finite stack-wide resources are conserved through explicit allocation or splitting rejects; no free souls/charges/entitlements.
6. Supported heterogeneous units follow declared deterministic/explicit selectors without value substitution or reroll.
7. Consumption differs from extraction; one-unit consumption decrements once, retires the last-unit entry and causes no independent use/reward trigger.
8. Repeated callbacks cannot double-consume/grant; partial owner failures retain facts/recovery without unsupported refunds.
9. Results report identities/counts/allocation/retirement truthfully; notifications cannot repeat authoritative changes.
10. Native load/save preserves coherent state or supported pending progress without replay/refill/expiry reset; unsupported pending saves explain blocking and stale callbacks fail safely.

## Contradiction review

Reviewed against approved ITEM-001–005, RULE-025 and COMBAT-008/MAGIC owner boundaries established in prior reviews. No direct contradiction identified. Full-count return is an identity-preserving reference operation rather than new stacking permission. Per-unit state preservation does not duplicate stack-wide resources. Standalone same-collection splitting complements ITEM-005 insertion planning without overriding ITEM-007 transfer design. Action-specific consumption/cost/save rules remain binding; allocation profiles do not implicitly enable restricted special-item stacks.

## Outstanding questions

No further blocking player-policy choice identified. Before implementation is complete: per-type copy/split and conserving allocation schemas; heterogeneous selection contracts; cap/entry/custody checks and split-plus-transfer staging; explicit result/operation/recovery receipts; action-level consumption/effect coordination; native pending-save/migration and resource-conservation fixtures. These cannot waive identity/state/quantity preservation or once-only settlement.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-006-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented type-aware split/allocation schemas, unit selection, admission/transfer staging, operation/recovery receipts, consumption/effect coordination and native persistence/migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
