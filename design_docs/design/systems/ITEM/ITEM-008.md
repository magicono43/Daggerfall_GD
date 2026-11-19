# ITEM-008 — Carry and wagon capacity

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Control weighted inventory admission and wagon availability without losing existing possessions or bypassing custody/access restrictions.

## Intended player experience

Players can predict how much fits from accurate displayed weights, including 0.1 kg and 0.15 kg items. Capacity changes preserve possessions. Wagon access is convenient in vanilla and extensible to physical-wagon mods without duplicating or hiding storage.

## Confirmed requirements

- **ITEM-008-D01:** Reject positive-weight intake that would exceed capacity. Capacity reduction may leave existing possessions overweight without deletion or forced dropping. Ordinary movement retains approved no-penalty encumbrance baseline.
- **ITEM-008-D02:** Genuinely zero-effective-weight items may enter at/above weight capacity, subject to access, quantity, entry limits and other restrictions. No-encumbrance status is explicit validated data, not inferred from appearance/category names.
- **ITEM-008-D03:** Initial wagon capacity is 750 kg with validated configurable profiles. Wagon contents are separate from carried weight. Storage access alone moves nothing and does not transfer ownership.
- **ITEM-008-D04:** Initial player base capacity is floor(live Strength × 1.5) kg, with validated overrides. Capacity bonuses are explicit source-owned CHAR/MAGIC modifiers; display/recalculation cannot duplicate contributions.
- **ITEM-008-D05:** Count carried items including equipment exactly once using effective weight × quantity. Physical carried gold contributes weight even when balance-represented; wagon contents and nonphysical financial balances do not. Detailed gold representation remains ITEM-009.
- **ITEM-008-D06:** Initial accounting baseline is the classic 2.5 g unit, with explicit nearest-even rounding at defined conversion boundaries and integer arithmetic afterward. Positive-weight content cannot silently round into weightlessness: reject or use an explicitly supported finer-precision profile. Genuine zero weight remains valid. Decimal kilogram weights including 0.1 kg and 0.15 kg are required; these examples fit the baseline exactly. Validated finer-precision profiles remain supported, without selecting a particular sub-gram quantum.
- **ITEM-008-D07:** Use validated accounting precision sufficient for configured content, converting all participating item weights, loads and capacities consistently. Avoid inconsistent per-transfer conversion.
- **ITEM-008-D08:** Display enough decimal places to distinguish meaningful weights. Capacity checks use authoritative accounting values rather than rounded UI text.
- **ITEM-008-D09:** Baseline owned wagon storage is accessible in ordinary exteriors without simulating physical parking. Ordinary building interiors deny access unless an explicitly supported interaction permits it. Access is moddable, including physical-wagon models with explicit location/reach/availability rules; no specific physical simulation is mandated for vanilla.
- **ITEM-008-D10:** Dungeon access initially within 5 metres of a valid exit, with cart ownership/original exit/context revalidated and configurable distance. MOVE-022 Access wagon / Leave dungeon / Cancel remains binding.
- **ITEM-008-D11:** Revalidate wagon ownership/access at transfer commitment. Lost access blocks further moves with clear feedback, without losing stored contents, retargeting containers or automatically moving items.
- **ITEM-008-D12:** Calculate maximum whole fitting quantity, allowing exact-capacity fills. Explicit quantity transfers remain all-or-nothing; explicit take-what-fits may take the maximum, leaving remainder with clear feedback.
- **ITEM-008-D13:** Recompute admission from current load/capacity at commitment. Capacity loss never deletes possessions; overweight owners may remove items and accept genuine weightless items but not additional positive-weight intake. Zero capacity is valid; negative/malformed capacity requires explicit failure.
- **ITEM-008-D14:** Save authoritative contents, ownership and required capacity/access modifier state; reconstruct load/access without moving items or duplicating bonuses. Physical-wagon mods define persistent wagon identity/location and missing-provider recovery. Unavailable access is not empty storage.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview: user confirmed D04/D05 and D06 with the addition: “it would be nice to support finer weight denominations, say 0.1, or 0.15, that kind of thing.” Third interview clarified “kg in this case” and confirmed consistent accounting and meaningful display precision with “2. Yes / 3. Yes”.

Fourth interview confirmed exterior/building access with required moddability including a physical wagon, and confirmed dungeon/commit-time revalidation rules.

Fifth interview confirmed partial fitting, capacity-change and persistence rules with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#CanCarryAmount`, `WagonCanHoldAmount`, `ComputeCanHoldAmount`: uses effective unit weight, capacity/load rounded to 1/400 kg and available quantity to compute fitting amount.
- `CheckWagonAccess`, `DungeonWagonAccessProximityCheck`: dungeon path checks cart ownership and distance <5 Unity units from an exit; another branch uses retained allowDungeonWagonAccess state.
- `Game/Items/ItemHelper.cs#WagonKgLimit`: 750 kg default.
- `Game/Items/DaggerfallUnityItem.cs#EffectiveUnitWeightInKg`: template hasNoEncumbrance returns zero. Comments list horses, carts, arrows and maps as baseline examples, not an exhaustive verified template audit.
- `Game/Entities/DaggerfallEntity.cs#GetMaxEncumbrance`: live Strength formula plus positive IncreasedWeightAllowanceMultiplier contribution.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Runtime/parity not verified; source unchanged.

## Existing approved constraints

MOVE-005 establishes inventory-only vanilla encumbrance with no movement penalty, while supporting explicit mod consequences. MOVE-022 requires owned/context-validated wagon access and capacity-respecting maximum eligible arrow-only corpse pickup. ITEM-005–007 require whole-plan admission, state/quantity/custody preservation and explicit partial/atomic outcomes. CHAR/MAGIC own live attributes and source-owned capacity modifiers.

## Detailed rules and behaviors

### Load and capacity

Count all carried item quantities, including equipped inventory items exactly once, using effective weight. Equipment references do not add a second copy. Physical gold contributes carried weight even if represented as a numeric balance; nonphysical bank/financial balances and wagon contents do not. ITEM-009 defines representation/conversion without double-counting physical coins.

Base player capacity is floor(live Strength × 1.5) kg, consistent with approved RULE-005. Validated overrides and source-owned CHAR/MAGIC contributions may alter effective capacity. Display/rebuild cannot duplicate contributions; exact contribution composition remains the approved owner profile, not a new universal multiplier rule here. Initial wagon capacity is 750 kg, configurable through validated profiles.

Positive-weight admission must not exceed current destination capacity. Exact fills are allowed. Capacity loss or legitimate weight changes may leave retained possessions overweight without deletion/forced drop. Ordinary movement keeps MOVE-005's no-penalty baseline; supported mod movement consequences remain explicit owner contributions. Removing possessions remains possible, subject to other access/quest rules and destination admission. Additional positive-weight intake is blocked while overweight, even if a larger compound swap could reduce total weight; no netting exception is approved here.

Genuinely zero-effective-weight items may enter at/above weight capacity, including zero capacity, while all nonweight restrictions remain enforced. No-encumbrance is explicit validated content; no category-name or appearance inference. Reference comments identify horses/carts/arrows/maps as examples, but the exact shipped exemption inventory requires template verification rather than automatic adoption of an unverified list. Negative, nonfinite or malformed required capacity/weight inputs fail explicitly. A legitimate effective zero is distinct from invalid data.

### Precision and presentation

Initial accounting uses 1/400 kg = 2.5 g units. Convert at declared boundaries with nearest-even rounding, then use checked integer accounting. 0.1 kg = 40 baseline units and 0.15 kg = 60 units; both are represented exactly. Do not constrain weights to whole kilograms or quarter-kilogram display increments.

Support validated finer accounting profiles sufficient for configured content, consistently applied to all participating item weights, loads and capacities. No particular finer quantum is selected. Positive weights cannot silently round to zero; reject incompatible precision or select an explicitly supported finer profile. Genuine zero/no-encumbrance remains valid. Exact conversion boundary and aggregation schemas must prevent transfer-direction or repeated conversion exploits; do not independently re-round the same value on each move.

Display enough decimal places for meaningful configured weights and fitting outcomes. Admission uses authoritative accounting, never rounded UI text. UI may format units without changing stored quantities or mechanically treating a displayed zero as weightless.

### Fitting quantity and transfer modes

Compute maximum whole quantity from current availability, effective unit weight and remaining capacity. Exact-capacity equality is allowed. Return a nonnegative fitting amount, including zero; no negative available quantity when overloaded. For genuine zero effective weight, weight admission permits all available units, with caps/entry/access/custody and other checks still applied.

Explicit quantity transfer either moves the requested valid quantity or rejects unchanged under ITEM-007. Take-what-fits is an explicit mode and may select the maximum fitting whole amount; leave remainder with clear feedback. MOVE-022 arrow-only corpse collection uses its approved maximum-eligible-fitting rule. Do not silently convert an explicit all-or-nothing request to partial success.

Validate the entire cumulative ITEM-005/007 insertion plan against current load/capacity at commitment, not only an old UI quote or per-item checks. Splitting/stacking does not compress weight or bypass entry limits. Bulk mixed-item selection remains a declared ITEM-007 profile dependency; this feature defines single-item fitting, not an optimal packing algorithm.

### Wagon access and extension

Vanilla owned wagon storage is accessible in ordinary exterior contexts without simulated physical parking. Ordinary building interiors deny access unless an explicit supported interaction allows it. Opening/access alone transfers no contents or ownership. Dungeon access requires an owned cart and valid exit context, initially within 5 metres with configurable distance. MOVE-022 Access wagon / Leave dungeon / Cancel remain separate outcomes; storage access never implicitly exits.

Revalidate original wagon/exit identity, ownership, location/context and relevant access predicates at commitment. Lost access blocks further transfers with clear feedback, preserving contents and references; never retarget another container or present unavailable storage as empty. Opening UI is not a durable permission token. Exact distance metric, equality boundary and door reference point require explicit spatial schema/fixtures before support is complete.

Access policies are moddable, including physical wagons with explicit placement, reach, availability and persistent identity/location. Such profiles must retain custody, ownership, capacity and commit-time revalidation guarantees. This authorizes extension support, not vanilla wagon physics, pathfinding, theft/destruction, remote recall or unrestricted access. Those behaviors require their own owner policies. Executable/data lifecycle follows DATA/MOD rules rather than implicit live provider replacement.

## Relevant formulas and parameters

- Initial player base capacity B = floor(1.5 × live Strength) kg; source-owned modifiers produce validated effective capacity C.
- Initial wagon capacity = 750 kg; initial dungeon access distance = 5 metres, both validated configurable values.
- Homogeneous effective load L = sum(quantity × effective unit weight), plus physical gold where not already represented by inventory entries. Capacity is not compared against a double-counted equipment/gold total.
- For positive accounting unit weight w and valid available quantity Q, weight-only fitting amount = min(Q, max(0, floor((C − L) / w))). All arithmetic uses consistent accounting units and checked bounds.
- For genuine w = 0, weight-only fitting amount = Q. Other admission restrictions can reduce/reject actual transfer.
- Baseline accounting conversion = nearestEven(weightKg × 400); finer profiles declare consistent scale/conversion. Exact unit-input/aggregation boundaries are schema dependencies, not permission for repeated lossy conversion.

No default movement penalty, fractional item quantities, negative-capacity clamp, special-container weight compression or new capacity-modifier formula is approved.

## Required data

Authoritative carried/wagon contents and quantities; effective weights and explicit exemptions; physical-gold representation; stable inventory/wagon/exit/session identities and custody/ownership; live capacity inputs/source contributions; accounting profile/units and conversion provenance; configured access predicates/location; requested transfer mode, fitting amount and cumulative plan; retained operation/save compatibility facts. Exact numeric, spatial and provider schemas remain dependencies.

## Inputs, outputs and events

Inputs: pure load/capacity/fitting queries; current content/attributes/modifiers; explicit wagon-access request/context; authorized transfer plan; restored state. Outputs: authoritative load/capacity/max fitting quantity, accessible/inaccessible with reason, distinct invalid/unavailable errors and committed owner transfer results. Queries/opening do not move items, grant ownership, mutate modifiers or clean up storage. Concrete APIs/signals remain unselected.

## Cross-system interactions

RULE-005/CHAR supply live Strength/base capacity and source-owned attributes; MAGIC supplies approved capacity effects. MOVE-005 retains vanilla no movement penalty and optional mod consequences; MOVE-022 owns property/exit prompts and arrow-only shortcut. ITEM-001–007 preserve identity/state/custody and checked plan commitment; ITEM-009 owns gold representation. WORLD/LOC provide valid exit/location/physical-wagon context; QUEST/LAW/ECON own access/legal/payment restrictions. UI presents meaningful precision and outcomes; DATA/MOD validate definitions/providers and SAVE/CORE reconstruct coherent state.

## Edge cases and failure conditions

- Exact fill succeeds; positive-weight intake exceeding limit rejects or explicitly takes fitting quantity in partial mode.
- Already overweight/zero capacity: retain possessions, allow removal and genuine weightless intake subject to other rules; positive-weight intake blocked.
- Small positive weight rounds to zero: reject incompatible profile or use supported finer precision, never accidental exemption.
- Invalid negative/nonfinite weights/capacity or overflow: explicit failure, no silent clamp/admission.
- Equipped inventory and balance-represented physical coins: count exactly once.
- Old capacity quote or lost wagon access before confirm: revalidate, preserve collections on rejected transfer.
- Physical wagon unloaded/provider unavailable: explicit access/recovery result, no fake empty storage or replacement wagon.
- Capacity/source change during coherent equip transition: owner batching prevents duplicate/transient modifier replay; retained possessions are not discarded.

## Configuration and balancing options

Validated base capacity overrides, source-owned capacity modifiers, wagon capacity, accounting precision, weight exemptions and access/distance profiles are supported. Physical-wagon extensions may define location/reach/availability with persistence contracts. Movement consequences remain opt-in explicit MOVE profiles, disabled in vanilla. No universal entry limit, shared multi-wagon pooling, ownership-loss disposal or finer quantum is selected.

## Save/load considerations

Save authoritative contents, quantities, identity/custody/ownership and required capacity/access source state. Recompute load and access consistently without moving items, duplicating bonuses or opening storage automatically. Preserve overweight possessions; loading does not force-drop/delete/rebalance them. Accounting/profile/content changes require explicit compatibility/migration rather than silently making positive items weightless or discarding quantities.

Physical-wagon profiles persist required identity/location and define missing-provider recovery. Unavailable storage is not empty storage. Transfer progress follows ITEM-007 coherent or explicitly supported pending persistence, with explained temporary blocking otherwise. Old-session callbacks cannot apply stale capacity/access decisions. Exact native schemas/migrations and provider recovery remain integration work.

## Technical constraints

Target Godot 4.7.2. Separate authoritative load/capacity/access queries, owner admission and UI formatting. Use consistent checked accounting and explicit world-unit conversion for the 5-metre profile. Avoid cached UI-only permission or current-player/global-container inference. No particular fixed-point width or physical-wagon simulation is mandated. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Baseline player base capacity is floor(live Strength×1.5) kg; source contributions apply once. Wagon starts at 750 kg with validated overrides.
2. Carried/equipped/physical-gold weight counts once; wagon/nonphysical finances remain separate.
3. Exact fills work; maximum whole fitting quantity matches consistent accounting and explicit partial/all-or-nothing modes.
4. Capacity loss retains possessions without vanilla movement penalty; overweight removal/weightless intake works subject to other rules, positive-weight intake does not.
5. 0.1/0.15 kg weights remain exact at baseline; supported finer profiles use consistent accounting. Positive weight never becomes accidentally weightless.
6. UI precision distinguishes meaningful weights while checks use authoritative values; invalid input/overflow fails explicitly.
7. Exterior/building/dungeon baseline access follows explicit policies and original wagon/exit ownership/context is revalidated at commitment.
8. Lost access blocks further moves with feedback without losing/retargeting contents or implying exit.
9. Physical-wagon access profiles support validated location/reach/identity/persistence without bypassing custody/capacity restrictions.
10. Native load reconstructs contents/load/access/modifiers without transfer replay, duplicate bonuses, forced disposal or fake empty unavailable storage.

## Contradiction review

Reviewed against approved ITEM-001–007, MOVE-005/022 and RULE-005, with CHAR/MAGIC source-owned modifier and CORE restore boundaries. No direct contradiction identified. Overweight retention preserves inventory-only vanilla encumbrance. Fitting quantity does not override explicit ITEM-007 atomic requests or invent mixed-batch packing. Supported physical wagons extend access profiles without changing vanilla requirements. Decimal kg support refines presentation/accounting rather than replacing ITEM-003 material-weight rounding; resulting equipment weights still enter the shared accounting profile.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: effective-weight/exemption inventory and physical-gold schema; capacity modifier composition/numeric bounds; accounting conversion/aggregation/finer-profile migration and display fixtures; wagon/exit spatial boundary and ownership/access schemas; physical-wagon provider/location lifecycle; transfer admission and native persistence/recovery fixtures. These dependencies cannot waive meaningful precision, retained possessions, access revalidation or no-duplication guarantees.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-008-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented weight/gold schemas, modifier composition, accounting precision/conversion/migration, spatial access boundaries, physical-wagon lifecycle and native admission/persistence dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
