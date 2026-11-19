# COMBAT-008 — Arrow use and recovery

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Select and consume ammunition predictably, preserve fired arrow properties and permit contact-based recovery without duplication. Readily support custom arrow types and optional multishot/piercing policies through mods while keeping the vanilla attack one arrow.

## Confirmed requirements

COMBAT-008-D01–D17 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record six interviews. D13–D15 explicitly extend COMBAT-004/007's single-arrow baseline to modded volleys: one attack fatigue/cooldown, ammo and release practice per successfully released ammunition-bearing arrow unless explicitly overridden. The complete specification is approved under COMBAT-008-A01. ITEM owns concrete custom ammunition definitions; COMBAT-009 owns projectile collision/attribution.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths below are relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#Update` chooses an arrow at release with GetItem(...allowQuestItem:false,priorityToConjured:true), removes one, and records IsSummoned on the missile. It does not reserve a unit during draw.
- `Game/Items/ItemCollection.cs#GetItem` prioritizes summoned matching items with shortest TimeForItemToDisappear; other selection depends on collection enumeration. Target uses explicit stable tie-breaking.
- `WeaponManager.WeaponDamage` inserts one generic nonsummoned arrow into enemy inventory on arrow contact before health removal, including zero-damage outcomes. Fired type/properties are not fully preserved by this replacement path.
- `Game/EnemyAttack.cs#BowDamage` applies damage to its current target then inserts one generic arrow. `Game/DaggerfallMissile.cs#AssignBowDamageToTarget` routes impacts using caster/target/weapon manager state. Target attribution and inventory destination must instead follow the actual shot/contact contract, finalized in COMBAT-009.

## Detailed rules and behaviors

### Eligibility, source and selection

Automatic player selection uses carried inventory only, excluding wagon, nearby containers and companions. Quest-marked arrows are excluded. Prioritize eligible summoned arrows, then ordinary arrows. Within summoned tier prefer shortest remaining lifetime, then stable item identity; within ordinary configured priority tier use stable item identity. No automatic best-damage selection. Eligibility, type priorities and alternate supply policies are moddable.

Support modded arrow types readily through explicit ITEM definition/compatibility and COMBAT payload/recovery contracts, rather than hard-coding all arrows to one template. ITEM/MOD must define concrete types, stacking, bow compatibility, payloads and validation. A manual selector is not approved by this feature; mods may explicitly require a selected type through a supported policy.

Start admission checks enough currently eligible ammunition under COMBAT-007 and configured shot policy. Drawing consumes/reserves/transfers nothing. At release select again from current eligible carried inventory; it may differ from draw-start type. Revalidate quest/summoned/availability/compatibility then, not using stale inventory references. A mod requiring a chosen type must enforce that requirement explicitly rather than silently substitute another.

### Release and conservation

Vanilla successful shot consumes exactly one ammo unit and captures a per-arrow record containing definition, summoned status, relevant payload and recovery properties. Later inventory/equipment changes cannot rewrite that arrow. A unit split from a stack must have correct quantity and identity/provenance under ITEM; copying a stack record cannot multiply its quantity or retain a duplicate inventory unit.

Validate ammo and prepare projectile resources before committing consumption. Retain one authoritative shot/volley outcome shared by inventory, projectile activation, fatigue and practice. Missing/invalid ammo at release follows COMBAT-004/007 cancellation without projectile/ammo/fatigue/practice but with captured cooldown. Before-start rejection has no started attack/cooldown.

Technical failure after any part commits requires same-operation completion/reconciliation retaining completed facts, not automatic refund or a new replacement shot. Do not claim universal rollback of already active projectiles or impact effects. Release records must identify actual successful projectiles and their consumed units so retries cannot duplicate ammo, fatigue, practice or projectiles. Exact preparation/publication boundary and recovery representation remain ITEM/COMBAT/SAVE dependencies.

### Actor-contact recovery

A nonsummoned arrow contacting a valid living combat actor becomes recoverable in that actor's inventory even if accuracy fails or physical damage resolves to zero. Eligibility is based on actual valid contact, not merely a projectile candidate list. Same policy applies to enemy arrows contacting player or other combat actors. Summoned arrows leave no recoverable item.

Recover the fired type and relevant remaining persistent properties, not a generic arrow. Explicit ITEM/MAGIC poison/enchantment consumption rules apply: recovery cannot restore spent poison/charges or duplicate an impact payload. This feature does not select a new poison/charge-consumption trigger. Summoned status is retained per arrow and cannot become ordinary/recoverable merely through later inventory changes.

Each actual arrow yields at most one recovered unit despite duplicate/multiple colliders or repeated callbacks. A piercing mod must explicitly define which contact receives that unit; several damage contacts do not imply several recovered arrows. Magical item generation or alternative recovery quantities require a declared mod rule rather than accidental copying.

For a lethal contact, coordinate with death/corpse inventory transfer so the arrow remains recoverable through the resulting corpse exactly once. Actor and corpse must not each receive a copy. This is distinct from hitting an already-dead actor/corpse, which yields no recovered item by default. Living combat actor eligibility and corpse handling are moddable; ordinary noncombat civilian inventory recovery is not implicitly approved.

If there is no valid receiving/retaining inventory destination, lose the arrow by default without creating a world pickup or forcing insertion. Technical transfer failure is an explicit recovery/error case, not false normal ineligibility. If an actor dies/disappears during impact processing, use the declared actor/corpse destination contract rather than choosing another nearby inventory.

### Scenery, misses and world pickups

Scenery impacts, existing corpse impacts and expiration without eligible actor contact lose the arrow by default. No baseline world pickup is created. Mods may provide world recovery/fallbacks through explicit placement, identity, ownership, lifetime and persistence policies. Visibility of a projectile model alone cannot make a loot item or replenish inventory.

### Modded multishot

Support multiple projectiles/units per bow attack, including multishot/trishot. Normal modded volley consumes one eligible unit per arrow and captures separate payload/recovery records. Each arrow can produce at most one recovered unit. Magical extra projectiles/different consumption require explicit policies; no free ammunition is inferred.

One volley attack normally uses one attack-level fatigue charge and cooldown, with release practice per successfully released ammunition-bearing arrow: e.g. three ordinary arrows grant +3 Archery/+3 Critical Strike under COMBAT-004. These cost/practice/recovery policies are moddable. This is an explicit extension of the approved single-arrow baseline, not vanilla auto-repeat or several independently admitted attacks.

Require full configured ammunition count at start and release, rejecting/canceling rather than silently downsizing. Mods may explicitly permit partial volleys. Full validation does not promise technical all-or-nothing activation: if failure occurs after some arrows release, retain those projectiles, their consumed ammo/practice and already committed attack cost. Reconcile unresolved portions without replaying the volley. Exact failure phase/finish/cooldown handoff must preserve COMBAT-001/007 timing and avoid duplicate fatigue or recovery restart.

Enemy ammunition supply/consumption and encounter initialization remain NPC/COMBAT owners; same recovery rules do not implicitly grant infinite NPC shots or require player inventory admission for all NPCs. Enemy shot records still need valid ammo provenance/policy before recovered units can be created. COMBAT-017 must settle that supply contract.

## Relevant formulas and parameters

Vanilla required ammo N=1. Normal configured volley requires N eligible units and consumes one per successfully released ammunition-bearing arrow. Per-arrow recovered units ≤1; default scenery/miss/summoned recovery=0. Explicit item-generation mods must declare any departure.

For K successfully released ammunition-bearing arrows in one attack, default release reports are +K Archery and +K Critical Strike under CHAR-012's raw counter/cap rules. Fatigue remains one captured COMBAT-004 drain (vanilla 11 internal units), cooldown one captured COMBAT-007 recovery. Impact awards no second release practice. No random recovery percentage or extra damage/accuracy modifier is introduced here.

## Required data

Attack/volley and per-arrow identity; source/actual target; validated ammo definition/compatibility/provider; selected unit/stack provenance, summoned lifetime/status and payload; quantity consumption/completion; projectile preparation/publication; post-impact remaining properties; recovery eligibility/destination and once-only transfer state; actor/corpse association; unresolved failure obligations. Stable definitions and ITEM identities replace raw stack/collider references.

## Inputs, outputs and events

Inputs: admitted bow start/release, inventory eligibility/quantity, configured volley policy, projectile preparation, actual actor/scenery/expiry outcome, payload consumption and death/corpse transfer. Outputs: rejected admission/canceled release, consumed unit records, per-arrow payloads, successful release/practice reports, one recovery transfer or declared loss, and partial-operation recovery. Exact APIs/signals remain unselected. Preview, sorting and UI inspection cannot consume ammunition or create recovered items.

## Cross-system interactions

Confirmed enemy supply integration: COMBAT-017-D02/D07 set finite own-inventory eligible arrows as ordinary NPC baseline, with explicitly moddable generated/unlimited supply and release-time consumption. Reuse summoned/quest/tie selection and per-arrow recovery contracts without importing player fatigue/practice. See [COMBAT-017](COMBAT-017.md) for separate approval status, ranged intent/cadence and NPC loadout dependencies.

COMBAT-001 cancellation/load, COMBAT-004 fatigue/practice/release ordering, COMBAT-007 start/hold/release/cooldown, COMBAT-009 collision/attribution, COMBAT-017 enemy shot supply and COMBAT-020/021 death/corpse transfer. ITEM definitions/stacking/admission/identity; MAGIC summoned/poison/enchantment lifetime and consumption; CHAR-012 practice; NPC actual inventories; CORE/SAVE consistent release and recovery boundaries; MOD/DATA schemas, compatibility and validation. Bow aim/timing/damage formulas are not redefined by ammo recovery.

## Edge cases and failure conditions

Test quest exclusion, summoned expiry before release, equal-life summoned stacks, custom types, inventory mutation during drawing, last-arrow use and changed selection between start/release. Expired/ineligible units cannot be consumed through stale references. Per-shot summoned status/payload persists; exact in-flight summoned projectile lifetime remains MAGIC/COMBAT-009 integration, not a new expiry rule here.

Test zero-damage/failed-accuracy contact, lethal hit before/after inventory transfer, existing corpses, player/enemy recipients and no valid destination. Multi-collider/duplicate collision or death callbacks cannot duplicate an arrow. Preserve consumed payload state and reject invalid custom item definitions rather than downgrade to a generic arrow.

For multishot, validate full count without selecting the same physical unit twice. Partial technical failure retains successful releases and does not award practice for unreleased units. Piercing requires one declared recovery recipient. Technical inventory failure cannot be disguised as ordinary ammo loss or retried as a new impact. Modded world pickups require explicit collision-safe placement and no duplicate actor/pickup recovery.

## Configuration and balancing options

Moddable arrow types, selection tiers/eligibility, alternate sources, recovery conditions/fallbacks, world pickups, piercing recipient policy, multishot quantities, partial-volley admission and explicit generation/cost/practice policies. Vanilla stays one arrow, summoned-first, quest-excluded, carried-only and contact-based recovery. Exact schema/provider precedence, quantity limits and payload persistence/stack compatibility are engineering/ITEM dependencies; this feature approves no automatic best-arrow chooser or manual selector UI.

## Save/load considerations

Persist actual inventory changes, resulting recovered items and consumed payload properties through ITEM/SAVE. COMBAT-001 cancels unfinished attacks without replaying consumption/practice; COMBAT-007 restores applicable captured cooldown. Pending required release/recovery/corpse obligations need coherent save boundaries or sufficient completion records, not rerunning impact callbacks on load.

In-flight projectile persistence remains COMBAT-009/SAVE. This feature does not decide whether a flying arrow survives loading; any later policy must reconcile ammo/recovery without refunds or duplicates. Partial volleys, pending actor-to-corpse transfer and modded pickups require explicit owner schemas and validation. Native load cannot regenerate recovered items already present, restore spent poison/charges or reroll completed recovery policy outcomes.

## Technical constraints

Target Godot 4.7.2. Separate attack, volley, projectile, ammo unit and recovery-item identity. Use stable per-arrow payloads and checked ITEM transfers with scoped idempotency. Avoid mutable current-ammo/current-target lookups at impact. Prepare before mutation where possible and record partial commitment truthfully; no generalized transaction framework is mandated. Exact APIs, numeric bounds, native item serialization and failure fixtures remain dependencies. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Automatic player selection is carried-only, summoned-first and quest-excluded; shortest summoned lifetime/stable identity resolves ordering without accidental collection-order dependence.
2. Start checks availability but reserves/consumes nothing. Release reselects/revalidates and captures actual payload, allowing a different eligible type than at draw start.
3. Successful baseline release consumes one unit once; later inventory changes cannot alter fired type/status/payload. Invalid ammo cancels under approved cost/cooldown rules.
4. Eligible nonsummoned combat-actor contact yields one matching remaining-property arrow even on zero damage/failed accuracy, for player and enemy shots alike. Summoned/scenery/miss/existing-corpse contacts yield none by default.
5. Lethal-contact recovery survives into the correct corpse once, with no duplicate actor/corpse item. No valid destination follows declared loss policy; technical failure uses recovery.
6. Duplicate/multi-collider and piercing contacts cannot generate extra units. Spent poison/enchantment properties cannot be restored on recovery.
7. Validated mod policies support custom arrow definitions and multishot without hard-coded single-projectile identity throughout the system.
8. Normal volleys consume one unit per arrow, use one attack fatigue/cooldown and award practice per released ammunition-bearing arrow; full ammo count is required unless explicitly overridden.
9. Partial technical release/transfer failures preserve completed facts and reconcile same-operation work without duplicated release, costs, practice, refunds or items.
10. Save/load does not replay consumed ammo/recovery/payload state; projectile persistence and unresolved owner boundaries remain explicit.

## Contradiction review

Reviewed against approved COMBAT-001/002/004/007, CHAR-012, RULE-003 and COMBAT catalog/architecture plus inspected inventory/missile/enemy source. No direct contradiction identified. D13–D15 explicitly extend single-arrow practice/cost language for optional modded volleys; baseline remains unchanged. Ammo reselects at release because COMBAT-007 reserves nothing. Zero-damage recovery is independent of RULE damage-conditioned poison/wear triggers; property consumption stays with its approved owner rather than being inferred from recovery. Corpse-safe recovery is an obligation for later death features, not their wholesale approval. Architecture recommendations remain Proposed outside confirmed contracts.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: custom ITEM definitions/compatibility/stack schemas; stable quantity identities; payload consumption and summoned in-flight lifetime; release/volley partial-failure boundaries; actor/corpse destination transfer; enemy supply; piercing/world-pickup mod contracts; native save migration/projectile persistence. These cannot silently duplicate ammunition, downgrade custom arrows, restore spent properties or turn recovery into a second practice award.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-008-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented ITEM/payload schemas, release and recovery boundaries, enemy supply, mod contracts and projectile/save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
