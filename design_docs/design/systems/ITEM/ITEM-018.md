# ITEM-018 — Light source and lantern fuel

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Manage portable-light activation, retained fuel and checked refuelling without stale source references, lost fuel or unintended physical break effects.

## Intended player experience

Lights retain predictable remaining life through switching and saving. Refuelling preserves unused oil. Water and custody changes extinguish ordinary flames deliberately, while validated mods can add hand-held, waterproof, multiple or placed lights.

## Confirmed requirements

- **ITEM-018-D01:** One active carried portable light per actor by default. Activating another switches sources without destroying either; dousing retains fuel. Validate custody/access. Explicit mod multiple/placed lights supported.
- **ITEM-018-D02:** Profiles distinguish fuel from physical durability even when a classic adapter stores fuel in condition. Empty lanterns remain refillable; ordinary torches/candles are consumed at exhaustion by default. Fuel exhaustion cannot accidentally invoke generic equipment Breaks powers. Outcomes moddable.
- **ITEM-018-D03:** Partial refuelling transfers only what fits and retains unused source fuel. Validate compatibility and quantities before commit. No excess discard/whole-bottle consumption for partial fill unless explicitly declared by a supported profile.
- **ITEM-018-D04:** Baseline burns one fuel unit per 20 seconds of active unpaused gameplay. Preserve per-light fractional progress through dousing/switching/save; no toggle extension. Wait/travel burns no fuel absent explicit profile. Mod game-time burn profiles supported.
- **ITEM-018-D05:** Vanilla carried lights occupy no equipment hand slot. Mod free-hand/equipped-slot requirements use ITEM-010 validated conflicts; activation cannot silently displace weapons.
- **ITEM-018-D06:** Ordinary flames extinguish on actual light submersion, retaining fuel and not automatically relighting. Explicit waterproof/magical profiles may remain active. Actual light/actor water context governs, not swimming alone.
- **ITEM-018-D07:** Explicitly select destination light and compatible fuel source; shortcuts use declared deterministic selection without silent retargeting. Active compatible lantern refuelling is allowed without douse/relight/burn-progress reset.
- **ITEM-018-D08:** Remaining fuel is separate from container quantity. Partial use preserves container identity/remainder; stacked full containers split via ITEM-006 before changing one. Empty disposable oil unit consumed by default; reusable bottles explicit profile.
- **ITEM-018-D09:** Transferring active carried light out of actor inventory extinguishes it within checked transfer, preserving fuel/fraction. No automatic world burning/recipient activation; placed-light profiles explicitly coordinate transition.
- **ITEM-018-D10:** Profiles declare range/brightness/color/low-fuel warnings. Flicker is presentation-only, affecting neither burn accounting nor gameplay RNG. Feedback cannot activate enchantments or repeat consumption.
- **ITEM-018-D11:** Activate one unit, splitting via ITEM-006 if needed. Fuel/fraction become individual state; incompatible partially used lights cannot merge/reset it. Failed activation leaves original stack unchanged.
- **ITEM-018-D12:** Persist active identity/fuel/fraction/profile compatibility. Restore valid active source without fresh ignition cost/refill after custody/environment validation. No offline burn/duplicate depletion/old-session callback consumption; pending refuel follows supported save boundaries.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

Fourth interview confirmed D10–D12 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem`: positive-condition light toggle; oil selects nonquest carried lantern and refuels only if whole oil amount fits, then removes a unit.
- `Game/EnablePlayerTorch.cs#Update`: item-light setting uses PlayerEntity.LightSource, consumes one condition after >20 accumulated unpaused update seconds, resets buffer, sets range from template capacityOrTarget and gutters at condition <3. Depletion clears source, keeps lanterns and removes other lights. Alternative non-item setting enables contextual automatic illumination.
- `Game/Entities/PlayerEntity.cs#LightSource`: stores active reference. Reference behavior does not establish complete custody validation or target clock semantics.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; source unchanged.

## Existing approved constraints

ITEM-001–017 preserve identity/custody/state/quantity and explicit use/commit rules. ITEM-013 distinguishes resource exhaustion and physical breakage; ITEM-015 owns explicit actions/UI handoff. COMBAT/ITEM-010 govern hands if required; TIME/CORE own clocks/suspension and MOVE actual water/activity context. Light profiles do not implicitly activate enchanted Used powers or reveal hidden properties.

## Detailed rules and behaviors

### Activation and custody

Toggle light and Refuel are explicit ITEM-015 actions with shared actor/item/session/access validation. Baseline actor has one active carried portable-light source; switching douses the previous source without destroying it, while explicit dousing preserves fuel and fractional progress. Required fuel/eligibility/profile must validate before a switch mutates the previous source.

Activate exactly one unit. Stack separation uses type-aware ITEM-006 identity/state/resource rules, and the full activation/split plan validates before commitment. Failed activation leaves the original stack and active arrangement unchanged. Individual burn progress is meaningful state for ITEM-005 matching; merge cannot erase partial use. Equipment and active-light bindings are references to one inventory-owned possession, not additional custody/weight.

Vanilla carried lights require no hand slot. Mod free-hand/equipped-slot profiles use ITEM-010/011 complete conflict/permission rules; activation cannot silently displace a weapon. Explicit multiple/placed-light profiles are supported with their own source identities and owner lifecycle, not automatic expansion of vanilla active slots.

Transfer out of the actor's carried inventory extinguishes the carried source as part of ITEM-007 checked movement, preserving fuel/progress. Failed transfer leaves the source intact; no stale reference can continue burning another owner's item. Recipient/world burning requires explicit profile transition rather than automatic activation. Destruction/expiry/source loss uses compatible owner cleanup; active UI selection cannot bypass custody.

### Fuel and clocks

Profiles distinguish burnable fuel, physical durability and magic charges. Classic condition storage is an adapter convention, not universal semantics. Initial baseline consumes one fuel unit per 20 seconds of active unpaused gameplay while the valid light is active. Preserve each source's sub-interval progress across dousing, switching, refuelling and save/load. Process eligible elapsed intervals without discarding excess frame time; never charge the same interval twice.

Pause/loading/nonadvancing gameplay do not burn baseline fuel. Waiting/travel/calendar jumps do not burn absent an explicit profile; wall-clock time while closed grants no depletion. Mod game-time burn profiles declare units, elapsed-time handling and interruption/restore behavior through TIME/CORE. Source-specific capacity/rate data must be complete before support is claimed; no unverified universal torch/lantern total lifetime is adopted.

At empty fuel, extinguish once. Ordinary empty lantern remains refillable; ordinary torches/candles are consumed/retired at exhaustion. Profiles may override these outcomes. Fuel depletion does not automatically invoke ITEM-013 physical break/Breaks powers. Physical damage or magic-resource exhaustion remains separate and requires explicit compatible profiles. Feedback/cleanup cannot repeat depletion.

### Water and eligibility

Ordinary flame extinguishes when the actual light is submerged, retaining remaining fuel/progress. Swimming alone does not prove submersion; the no-hand baseline still requires a declared logical light placement/context for environmental checks. Do not automatically relight after leaving water. Explicit waterproof/magical profiles may remain active where supported.

Eligibility checks use current actor/source/custody/environment, including deferred activation and native restore. No new blanket extinguish-on-paralysis, climbing or spellcasting rule is introduced. Additional environmental/access requirements are validated owner profiles.

### Refuelling and containers

Requests explicitly identify destination and compatible fuel source. A supported shortcut uses declared deterministic selection, never an unchecked first lantern or same-name replacement. Revalidate source/destination access, quantities, capacity, profile compatibility and session before commitment. No default exemption for quest/cursed items; protected interactions require their owner contracts.

Transfer only the compatible amount fitting capacity, preserving unused source fuel. Remaining liquid is distinct from container count: separate one full container from a stack through ITEM-006 before mutating its contents. Partial use preserves that container identity/remainder; empty disposable oil unit is consumed by default, reusable bottles require an explicit profile. Preserve fuel compatibility, quantity and meaningful state; partial bottles cannot merge into full ones by discarding differences.

Active compatible lanterns may be refuelled without dousing/relighting or resetting burn progress. Full/incompatible targets transfer nothing; distinguish legitimate no-space from invalid/provider failures. No excess discard or whole-bottle partial-fill cost unless an explicit supported policy declares it. Exact fuel units/capacity and any non-1:1 conversion are required profile decisions, not implicit arithmetic.

Validate the whole transfer/split/container admission plan before mutation. Ordinary rejection leaves both ends unchanged. Actual partial technical commitment retains completed facts and recovery obligations without blind retry, refill duplication or losing the original container. No generalized transaction framework is mandated.

### Presentation and notifications

Profiles specify supported range, brightness, color and warning behavior. Low-fuel guttering/flicker uses presentation-only randomness, not gameplay RNG or burn accounting. Cosmetic settings cannot change fuel capacity/rate, identify hidden powers or activate Used enchantments. No new default numeric brightness/range/warning threshold is selected from the reference implementation.

Report activation/douse/refuel/depletion facts with stable source/operation context. Warnings and exhaustion notifications cannot consume again or replay generic break callbacks. Repeated delivery of one request does not create another ignition/refuel. Display remaining fuel/progress truthfully under item knowledge rules.

## Relevant formulas and parameters

Baseline interval = 20 active unpaused gameplay seconds per fuel unit. For eligible accumulated time a, completed burn intervals = floor(a/20), with residual time retained for a surviving fueled source. Apply depletion only up to available fuel and extinguish at exhaustion; no negative fuel or excess elapsed charge after extinguishing. Equivalent continuous/fixed-point representations are allowed if they preserve these semantics.

For same-unit compatible refuelling, transfer = min(source fuel, destination capacity − destination fuel), using checked nonnegative supported units. Profiles using different units must explicitly define compatible conversion/conservation. No total fuel capacities, ignition fees, physical durability, light intensity/range values or warning thresholds are approved here. Genuine remaining fuel plus fractional progress determines remaining burn life; resetting the fraction cannot extend it.

## Required data

Stable actor/light/container/profile/session/operation identities; authoritative custody and optional equipment/placed bindings; active state, remaining fuel/capacity, retained burn fraction and clock/rate; fuel compatibility/units; container quantity/disposition; environmental/water eligibility and logical source placement; visual/warning profile; committed activation/refuel/depletion facts and provider compatibility. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: explicit toggle/refuel/switch, eligible elapsed time, environmental/custody changes, owner cleanup and native restore. Outputs: committed active/doused/refuelled/exhausted source and fuel/container outcomes, unchanged rejection or explicit recovery, presentation-only light/warnings. Query/hover/feedback is not fuel expenditure or enchantment activation. Concrete APIs/signals remain unselected.

## Cross-system interactions

ITEM-001–008 govern identity/state/stack/split/custody/admission, ITEM-010/011 optional hand restrictions, ITEM-013 physical break separation and ITEM-015 explicit actions. MAGIC owns enchanted/charged light powers; AV renders light using declared source properties. MOVE/WORLD/LOC supply actual environmental/submersion and placed-source context; TIME/CORE govern eligible clocks/suspension. QUEST protects items and SAVE restores coherent source/fuel facts. Future placed-light/world simulation is not finalized automatically.

## Edge cases and failure conditions

- Switching/toggling/loading repeatedly: no free fuel through fraction reset.
- Large active frame interval: retain/process elapsed intervals, not only one debit/reset-to-zero.
- Empty source: no illumination or repeated depletion/Breaks events; retain lantern or consume ordinary torch/candle under profile.
- Swim with light above water versus actual submersion: environmental predicate distinguishes them; no auto-relight.
- Active source transferred: extinguish within checked move, no orphan/recipient activation.
- Partial oil fill/full target/stacked containers: conserve source remainder/identity and destination capacity without excess discard.
- Hand-requiring mod source: validated conflicts, no silent weapon displacement.
- Missing provider/invalid fuel units/overflow: explicit rejection/recovery, not default refill or generic light.

## Configuration and balancing options

Required supported profiles include different fuel rates/clocks/capacities, exhaustion dispositions, waterproof/magical eligibility, hand requirements, multiple/placed lights, compatible refuel/container behavior and visual warnings. Concrete gameplay profiles need explicit compatible owner rules. Vanilla retains one carried slot, no hand requirement and 20-second active clock. No automatic no-item infinite-light setting, placed-light physics, relight, fire propagation or weather extinguishing is introduced.

## Save/load considerations

Persist active source identity, fuel/container state, per-light fractional burn progress, clock/profile compatibility and committed operation facts. Restore a valid saved active source without new ignition cost/refill after custody/environment/layout validation. Ordinary submerged source is not restored as burning; invalid required state needs explicit recovery, not fallback ownership or replacement fuel.

No closed-game burn, repeated depletion/refuel, fraction reset or old-session callback consumption. Game-time mod profiles retain declared compatible clock context rather than inheriting baseline active-time behavior. Pending refuelling uses supported coherent/partial snapshots under ITEM-002/015 or explained temporary save blocking. Changed required units/profiles/providers require migration/recovery, not silent conversion/free refill. Exact native schemas remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate logical light/fuel state, authoritative owner operations, eligible clock, environment and visual rendering. Burn cannot depend on rendered-frame count, light-node existence or shared presentation RNG. Use stable source IDs rather than unchecked global-player references. Checked fuel/conversion/progress representation is required without mandating a particular framework. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Vanilla one active carried source switches/douses safely, preserving items/fuel/fraction and custody.
2. Exactly one stacked unit activates via safe split; incompatible partial state cannot merge/reset; rejection unchanged.
3. Fuel/durability/charges remain distinct, empty lantern retained and ordinary torch/candle consumed once by default with mod exceptions.
4. Baseline burns one unit/20 eligible active seconds retaining progress across toggles/refuel/save, no wait/travel/offline burn absent explicit profile.
5. No vanilla hand slot; mod hand/multiple/placed profiles validate conflicts and ownership without silent weapon displacement.
6. Actual flame submersion extinguishes with fuel retained/no auto-relight; explicit waterproof exceptions work.
7. Explicit/deterministic refuel selection conserves compatible fuel/source remainder/container identities and permits active refuel without progress reset.
8. Checked active-source custody transfer extinguishes without automatic world/recipient activation or failed-transfer mutation.
9. Profile-driven presentation/flicker/warnings alter neither accounting nor gameplay RNG and cannot trigger powers/duplicate depletion.
10. Native restore retains source/state/fraction without refill/re-ignition cost/offline loss/replay; current eligibility and required-provider compatibility validated.

## Contradiction review

Reviewed against approved ITEM-001–017 and TIME/CORE/MOVE owner boundaries established in prior specifications. No direct contradiction identified. Fuel exhaustion is distinct from ITEM-013 break, preserving empty lantern refillability. Part-used containers and active-light splits retain ITEM-005/006 state conservation. Hand profiles use ITEM-010 rather than bypassing conflicts. Active-time burn explicitly excludes baseline calendar jumps; mod clocks require declared integration. ITEM-015 prevents light/refuel actions from implicitly invoking enchantments.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: concrete light/fuel/container capacities/units and conversion schemas; retained fraction/elapsed-time bounds; submersion/logical-placement predicates; hand/multiple/placed profiles and custody transitions; visual/knowledge/warning values; refuel/depletion receipts and native migration fixtures. Concrete unresolved gameplay profiles require explicit owner decisions before support is claimed. These cannot waive fuel conservation, clock continuity or safe source custody.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-018-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented fuel/container schemas, clock bounds, environmental predicates, hand/multiple/placed profiles, presentation values, operation receipts and native migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
