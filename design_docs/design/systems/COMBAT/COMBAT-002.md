# COMBAT-002 — Equipped hand and attack presentation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Let the player deliberately choose an equipped weapon or unarmed hand, with matching presentation and predictable preparation delays. Preserve shield defense independently of attack-hand selection. Support future modded dual wielding and shield bashing without adding those attacks to the baseline game.

## Confirmed requirements

COMBAT-002-D01–D19 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record six interviews and the shield-selection clarification. D04 permits initial shield-equip selection without continuously forcing it. D10 makes optional left-hand bows an exception to default two-handed exclusion. D17–D19 explicitly qualify saved-hand/delay preservation when current settings require equipment reconciliation. The complete specification is approved under COMBAT-002-A01.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; classic parity and runtime behavior remain unverified. Source unchanged. Paths are relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#UpdateHands` reads equipped slots. A left shield continually forces right selection and is excluded from the left attack source. `ToggleHand` refuses switching to that shield hand. The intended target deliberately differs.
- `ApplyWeapon`, `SetMelee` and `SetWeapon` map selected equipment to one FPSWeapon, using unarmed presentation for empty hands and an explicit racial-effect presentation override. Weapon presentation includes type, material, handedness, item identity and sounds.
- `Update` accepts SwitchHand on release when no weapon attack is active, subject to earlier cooldown/movement/spell gates. `ToggleHand` normally switches immediately; BowLeftHandWithSwitching adds a computed delay using both equipped weapons and divisor 1.7. This extra default penalty is not adopted.
- `Game/Items/ItemEquipTable.cs#GetItemHands` classifies bows as Both or optional LeftOnly; equipping a two-handed item removes conflicting hand equipment. `UpdateRightHandGfxCache` prepares unarmed left presentation for a right two-handed weapon.
- `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#SetEquipDelayTime` adds outgoing/incoming item times for changed slots. `WeaponManager.UpdateHands` reduces hand countdowns at 980 units per second. The target uses eligible gameplay time, not incidental rendered updates.

## Detailed rules and behaviors

### Attack source and hand selection

Baseline attacks use one selected hand, with no automatic alternation or simultaneous dual attacks. An empty selected hand uses unarmed combat even if the other holds a weapon. A selected shield hand likewise uses an unarmed attack source by default: the shield is not passed as an ordinary weapon merely because it occupies that slot.

Equipping a shield initially selects the opposite hand, whether armed or empty. This happens on the actual equip transition, not every refresh, load or presentation rebuild. Subsequent manual shield-hand selection remains allowed. Selecting that hand does not unequip the shield or remove its normal defensive benefits.

Ignore switching during active attacks without queuing; require a fresh request afterward. COMBAT-001 additionally blocks switching during bow cooldown, paralysis and climbing. Other spell/context eligibility remains with COMBAT-001/MAGIC/MOVE. Accepted ordinary switching is immediate and retains drawn/sheathed intent; it cannot bypass the destination's remaining equipment delay or automatically attack. Selecting a shield or empty hand does not itself authorize a strike.

### Equipment restrictions and bows

Default two-handed equipment excludes another equipped weapon/shield, but the other hand remains selectable for unarmed attacks. ITEM owns validation and inventory transfers. Equipment hand restrictions are moddable.

Bows default to two-handed. Provide an application settings option allowing a left-hand bow with another weapon equipped. It adds no default switching delay; mods may add one. The option can change only with no active character/play session, including no paused active session. Exiting to a no-session menu suffices; full application restart is not required. Loading cannot overwrite the current application preference. Mod content/policy activation still follows approved DATA/MOD lock rules.

### Equipment preparation

For an admitted equipment change, add outgoing item's unequip duration plus incoming item's equip duration to the affected hand's remaining delay. Ordinary switching between already-equipped hands adds no default delay. ITEM must define the authoritative equipment-change boundary so refreshes or duplicate delivery do not repeat charges.

Each hand progresses independently during eligible gameplay, even when unselected. Switching cannot reset or bypass remaining preparation. Pause/loading contributes zero progress. COMBAT-001 permits ready/sheath intent changes during delay but hides the selected weapon and blocks attacks until readiness and all other gates permit.

Removing/breaking/replacing the active weapon cancels an active attack under COMBAT-001; do not substitute the new item into that attack or rewrite captured timing. Equipment changes remain subject to ITEM admission. Exact nonweapon/shield preparation durations and multi-step equipment transaction semantics require ITEM integration rather than indexing a weapon table with arbitrary item data.

### Presentation and extensibility

Baseline presents one selected weapon/unarmed attack source. Match weapon type, material, handedness, identity and relevant sounds. Support explicit racial/form and modded presentation overrides, including future dual-wield/shield-bash visuals. A visual-only override cannot change source identity, damage or shield defense; those require explicit gameplay policies.

Keep hand identity, equipment occupancy, attack source, attack instance and presentation distinct. Do not build damage routing around a permanent assumption that one global displayed weapon is the only possible attack source. Mods must be able to add dual-wield selection/attack policies and shield-bash sources through supported validated contracts. Baseline shield-hand behavior and equipment restrictions must be replaceable. Mods may explicitly alter shield defense during bash phases and add switching delays. Exact APIs, concurrency rules, timing/cost policies and assets remain MOD/COMBAT integration work; no vanilla dual-wield/bashing formula is invented here. Existing RULE hooks, owner boundaries and COMBAT-001 commitment rules remain binding unless explicitly overridden through a supported contract.

## Relevant formulas and parameters

For an ordinary changed hand: new remaining delay = prior remaining delay + outgoing duration + incoming duration, with absent item contributing zero. Eligible elapsed gameplay time reduces remaining delay to a minimum of zero. Do not apply this ordinary change charge to the explicit load-compatibility adjustment below.

Source weapon durations below are ticks at 980 ticks/second. Retain these baseline weapon-type equip/unequip durations, made moddable; use explicit type definitions instead of assuming group indices are safe for every item.

| Weapon | Ticks | Weapon | Ticks |
| --- | ---: | --- | ---: |
| Dagger | 500 | Tanto | 700 |
| Staff | 1200 | Shortsword | 900 |
| Wakazashi | 900 | Broadsword | 1800 |
| Saber | 1600 | Longsword | 1700 |
| Katana | 1700 | Claymore | 3000 |
| Dai-Katana | 3400 | Mace | 2000 |
| Flail | 2200 | Warhammer | 2000 |
| Battle Axe | 2200 | War Axe | 2000 |
| Short Bow | 4000 | Long Bow | 5000 |

No default hand-switch cost, handedness damage bonus or new reach formula is added. RULE-015 continues to govern captured attack timing. Validate modded durations as finite, nonnegative and within supported arithmetic/storage bounds; exact maxima and units adapters remain engineering contracts.

## Required data

Stable equipment/item identities and hand occupancy; item hand restrictions and preparation durations; selected hand; weapon versus shield versus unarmed attack source; drawn intent; per-hand remaining preparation and sufficient associated item/recovery provenance; active bow policy; captured attack identity/timing; presentation resources/override provider; session scope and reconciliation outcome. Raw scene references are not durable identity.

## Inputs, outputs and events

Inputs: eligible switch requests, admitted equipment mutations, item breakage, owner restrictions, eligible elapsed time, no-session setting change, native load and validated mod/racial policies. Outputs: selected source, readiness/presentation state, preparation changes, COMBAT-001 cancellation, checked inventory reconciliation and post-load notice. Concrete API/signal names remain unselected; presentation refresh cannot itself equip items, reapply delays or trigger attacks.

## Cross-system interactions

COMBAT-001 owns readiness/interruption/cooldown; COMBAT-003/004 attack initiation/commitment/practice; RULE-012–016 combat resolution/timing; ITEM equipment validity/identity/transfer; CHAR unarmed skill and racial context; MAGIC forms/casting; MOVE logical input/context; CORE settings/suspension/load orchestration; SAVE durable hand/delay state; AV assets/audio and MOD validated extensions. This feature does not finalize equipment menus, shield coverage formulas, bow projectile persistence or dual-wield balance.

## Save/load considerations

Ordinarily retain selected hand and both remaining preparation delays. Do not charge equipment changes or repeat shield-equip initial selection merely because equipment is reconstructed. Rebuild presentation after required equipment/policy validation. COMBAT-001 cancels unfinished attacks and preserves applicable cooldown/committed results; fresh attack input is required.

If current bow setting conflicts with saved equipment, reconcile before gameplay readiness rather than reject solely for this supported mismatch or override the setting. Converting a saved left bow plus right weapon to two-handed mode moves the bow to the right slot and unequips the conflicting weapon into player inventory. Reverse conversion moves the bow left without automatically equipping another weapon. Select the bow's new hand when its slot changes.

Preserve every item's identity, condition, enchantments and quest state. Never drop/delete items. Adjustment adds no new preparation cost; preserve existing remaining delays associated with items and move the bow's delay with it. Unequipping a displaced item cannot erase outstanding recovery for later re-equipping. Exact handling/representation of combined per-hand and displaced-item recovery provenance requires ITEM/SAVE design before implementation; it cannot silently clear delay or invent a new penalty.

Show a brief equipment-adjustment notice after successful load. If required transfer/identity preservation is unsafe under inventory rules, use explicit CORE/SAVE recovery rather than lose items or expose partially restored equipment. Preflight the adjustment before replacing a running session under CORE-013. Repeated reconstruction cannot duplicate items/costs/notices within one load. A later separate load may truthfully report its own adjustment. Missing required definitions or incompatible mod policies still follow CORE/SAVE validation; this is not a general repair rule for corrupt saves.

## Edge cases and failure conditions

Shield-equip auto-selection cannot become continuous forced selection or occur again after load. A shield replacing an active attack item must honor COMBAT-001 cancellation before further hits. Manual shield attacks remain unarmed unless an explicit mod selects shield bash.

Handle selected empty hand, two-handed weapon with other unarmed selection, unselected-hand preparation, item loss/breakage, simultaneous switch/equip/attack requests and stale callbacks with explicit authoritative ordering. Do not let visuals retain a removed weapon as a gameplay source. Missing presentation resources require AV/DATA failure handling without silently selecting another attack item; concrete fallback presentation policy remains an owner dependency.

Load reconciliation must handle destination conflicts, inventory admission and recovery provenance without item loss or delay bypass. General modded multi-hand layouts/invalid configurations need declared compatible policies, not arbitrary slot swapping.

## Configuration and balancing options

Bow-hand option defaults to two-handed and is editable only outside a session. Equipment durations/restrictions, shield attack behavior, switching delay and future dual-wield/presentation policies are moddable as confirmed. Exact settings IDs, extension schemas/provider precedence and supported numeric domains remain implementation dependencies under CORE/DATA/MOD/RULE validation. No optional shield-defense penalty or vanilla dual-wield attack is introduced.

## Technical constraints

Target Godot 4.7.2. Separate equipped items, selected attack source, readiness timers and presentation; use stable identities and checked mutation boundaries. Preserve COMBAT-001 and RULE-015 timing/cancellation semantics across source changes. Reconciliation must validate transfers before commitment and reject stale work. Engine classes, scheduler and save schema remain engineering choices. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Either hand can be selected; empty/shield selection uses unarmed while the other weapon remains equipped. No baseline simultaneous/alternating dual attack occurs.
2. Shield equip selects opposite hand once; manual shield-hand selection then works, retaining normal defense. Load/refresh does not repeat initial selection.
3. Active attack/cooldown/paralysis/climbing rejects switching without queueing. Accepted switching is immediate, respects destination delay and never attacks automatically.
4. Two-handed weapons exclude another weapon/shield while permitting other-hand unarmed selection. Optional left bow permits another weapon without a default switching penalty.
5. Bow setting cannot change during an active or paused session; no-session changes are allowed and loading does not restore historical preferences.
6. Equipment change adds outgoing/incoming durations once. Both hand timers progress while unselected, stop during pause/loading and survive switching/load without bypass.
7. Active source mutation cancels attacks under COMBAT-001; presentation overrides alone cannot change gameplay source/damage/defense.
8. Loads ordinarily restore selected hand/delays; bow-mode reconciliation relocates bow, preserves all items/recovery, selects new bow hand, adds no new delay and reports adjustment.
9. Failed reconciliation uses recovery without partial playable state or lost/duplicated items. Duplicate reconstruction cannot repeat gameplay mutations.
10. Validated extension contracts permit alternate shield attack/presentation, switching delays and future multi-source attack policies without requiring baseline single-hand assumptions throughout combat resolution. Exact mod fixtures depend on finalized APIs.

## Contradiction review

Reviewed against approved COMBAT-001, MOVE-001/002, CORE-003/006/013/016/017 and RULE-015, plus COMBAT catalog/architecture and inspected equipment source. No direct contradiction identified. Outside-session preference changes remain separate from saved character state. Explicit load reconciliation preserves current preferences while providing owner-defined safe handling under CORE-013. D19 qualifies selected-hand preservation only when bow relocation is required. Shield-hand unarmed behavior intentionally differs from inspected DFU. Broader combat architecture proposals remain Proposed. Future modded dual wielding must explicitly reconcile concurrency/commitment policies rather than silently bypass approved baseline rules.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: finalize ITEM mutation boundaries/nonweapon preparation durations, displaced recovery provenance, general mod-layout compatibility, setting/schema IDs, provider APIs/precedence, simultaneous-event order, presentation-resource recovery and native save migration/validation fixtures. These dependencies cannot waive item preservation, confirmed hand behavior or recovery retention. Classic Daggerfall parity remains unverified.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-002-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
