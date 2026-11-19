# MAGIC-027 — Object utility, soul capture and dispelling

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose and intended player experience

Provide explicit magical operations for locks, item knowledge, temporary equipment, soul capture, active-effect removal and banishment. Each operation has its own eligibility and commitment rather than treating every utility spell as damage. Preserve selected DFU gameplay defaults while supporting data-driven mod alternatives and reliable native persistence.

## Confirmed requirements

MAGIC-027-D01–D24 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record eight interviews, each confirmed with three “Yes” answers. The complete specification is approved under MAGIC-027-A01. MAGIC-003–010/016, MOVE-018–021, COMBAT-008/020–021, CHAR and CORE/SAVE owner contracts remain binding. Identify's deferred debit is an explicitly approved exception to ordinary release payment.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths relative to reference `Assets/Scripts/`:

- `Game/MagicAndEffects/Effects/Mysticism/Open.cs`/`Lock.cs` maintain one forced remaining round until triggered/canceled, with empty compatible `AddState`. `Game/PlayerActivate.cs` dispatches later door activations. Open uses custom chance, bypasses that roll for item origin and checks door lock versus current actor level. Skeleton Key is recognized through artifact/texture properties and bypasses interior lock levels; exterior Open still checks player level. Lock sets level difficulty only if unlocked and requests closing.
- `Effects/Thaumaturgy/Identify.cs` refunds its calculated effect cost (minimum 5) before opening spell-mode trade UI. `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#DoModeAction` charges once per nonempty batch, rolls independently for unidentified items and permits successive batches. The target uses direct deferred accounting rather than the source refund sequence.
- `Effects/Mysticism/CreateItem.cs` opens an uncancellable equipment picker, creates a selected inventory item, sets `TimeForItemToDisappear` from current game minutes plus duration and ends the casting effect. `Game/Items/ItemCollection.cs` handles expiry/stack comparisons. Cancellation in the target is an approved divergence.
- `Effects/Mysticism/SoulTrap.cs` overrides cast chance success, uses duration and accepts enemy monsters rather than classes/civilians. Same-kind marks extend duration. `Game/Entities/EnemyEntity.cs#AttemptSoulTrap` rolls at a lethal health outcome: success fills an empty trap, or leaves health 1 when none is empty; failed capture permits death. `FillEmptyTrapItem` prefers an empty Azura's Star then ordinary traps in player inventory. `DaggerfallEntityBehaviour.cs` separately handles equipped Star automatic monster capture. Target caster-specific access/arbitration prevents shared-player lookup and duplicate capture.
- `Effects/Mysticism/DispelMagic.cs` opens a paid cancellable picker of icon-bearing Spell/HeldMagicItem bundles; self-cast removal succeeds, others roll. Source comments permit item effects to return on later recast or re-equip. Target eligibility is explicit data independent of icons.
- `Effects/Mysticism/DispelUndead.cs`/`DispelDaedra.cs` query nearby matching actors and roll per actor, destroying successful objects without death/loot. Comments warn of quest breakage. `Internal/PlayerGPS.cs#GetNearbyObjects` defaults to strict distance <14 reference units without a line-of-sight filter. Target uses durable banishment and explicit quest protection instead of raw scene destruction.

Static inspection only; no runtime/classic-parity verification. Templates alone do not establish universal container/NPC compatibility. Source global lookups, texture identity, transient callbacks and refund mechanics are not approved architecture.

## Detailed rules and behaviors

### Shared admission and commitment

Use normal authorized casting, source validity, captured release power, payment/practice/history and recovery unless a family explicitly overrides a stage below. Ordinary cast payment remains committed on later interaction cancellation/failure. Prepare required delivery before release under MAGIC-004; construction/preview cannot mutate world or inventory. Later operations revalidate selected identity, access and current owner state before committing.

Keep cast release, effect acceptance, utility interaction and completed owner operation distinct. Stable operation/session identities prevent duplicated notifications from producing extra unlocks, items, rolls, souls or rewards. Technical partial failure retains already committed facts for explicit recovery; do not replay a whole mixed spell or refund while leaving effects active. Ordinary chance failure is not technical failure.

### Open and Lock preparation

Default paid self-casts prepare one later eligible-door interaction. Preparation chance is resolved once through the family's declared admission policy, not again on load or each activation. Open's chance is custom as needed for item exceptions; do not also roll a generic duplicate chance. Prepared power is effective caster level captured at release, not recalculated after equipment/level changes while waiting.

Preparation persists until used or explicitly canceled, without ordinary duration expiry. Recasting the same effect does not accumulate charges. Same-family power/refresh behavior beyond this no-extra-charge rule must follow an explicit compatible family policy; it cannot silently create an extra use. Open and Lock may coexist, but activating a door requires explicit operation choice when both apply rather than silently performing both. UI details remain an integration dependency.

Invalid interactions preserve preparation. A genuine eligible door attempt consumes it even when the lock operation fails, including insufficient Open power or Lock encountering an existing lock. Requests ignored under door-motion/interaction rules are not automatically genuine attempts. Define the checked admission boundary through MOVE-018/019/021 before implementation.

Default Open unlocks difficulty d when d<=captured level L; Lock assigns d=L only to an unlocked door. Lock does not strengthen/weaken an already locked door. Magical and quest protections use explicit eligibility/override rules rather than arbitrary numeric shortcuts. Successful Open requests opening; Lock requests closing through door authority. Logical lock change, motion and building entry remain separate outcomes. A committed unlock cannot be replayed/refunded because motion or entry later fails.

Follow MOVE-020 retained explicit exterior unlock state and MOVE-021 ordinary door collision/occupancy behavior. No magic crushing, pushing, collision bypass or unrelated transition fallback. Unlocking grants no permission to enter and suppresses no applicable LAW incident. Default support is eligible doors; container/direct-target/projectile/NPC alternatives require supported adapters, not automatic support inferred from descriptions mentioning chests.

Item-origin Open bypasses its preparation chance but ordinarily retains level restrictions. Skeleton Key additionally bypasses interior magical/level locks; exterior entrances retain the level check. Quest-protected locks require an explicit override. Declare artifact capabilities by stable identity/data, not a texture number. Mod profiles may replace exceptions, formulas, activation-time power, lifetimes, charges and targeting while retaining owner validation.

### Identify

Identify is a selection-first, deferred per-batch debit exception. Opening/canceling the picker costs no Identify magicka; other effects bundled with it retain normal payment. Implement an explicit cost allocation/quote instead of deducting then refunding a minimum that can exceed actual payment. Free/item routes must not generate magicka; their separate source costs remain MAGIC-016. Exact mixed-bundle cost allocation, divisor/minimum reconciliation and payment-mode APIs are required dependencies, not permission to use unsafe refund arithmetic.

Default selection contains eligible unidentified items in the caster's currently accessible carried inventory. Revalidate access, item identity, unresolved knowledge and affordability before debit/roll/mutation. Already identified or empty selections cause no Identify charge or roll. Do not temporarily transfer item ownership into a trade collection merely to represent UI selection. Wagon/container/remote access requires explicit policy.

Charge the declared Identify cost once per nonempty eligible batch, with independent chance rolls for each selected item. Failed identification still pays; success updates item knowledge durably. Later genuine paid batches may retry failures. Retain partial batch outcomes so recovery cannot reroll successes/failures or double debit. Batch amount, chance, retry policy, cost and custom-property disclosure are moddable. Knowledge changes do not repair, recharge, duplicate, alter ownership or implicitly reveal unrelated properties.

Ordinary spell-release practice/history remain casting-owned; batching itself grants no invented extra practice. Unpaid selection/cancel must not counterfeit a second release. Exact owner coupling of the already approved release event to this deferred payment exception must be explicit and tested.

### Create Item

Default paid cast opens a cancelable post-cast picker. Cancel retains committed cost and creates nothing. Confirmation prepares one selected result, validates its inventory destination and inserts once. No automatic equip or silent substitute. Technical failure requires truthful recovery preserving insertion facts; do not create another copy on retry.

Default choices follow inspected DFU equipment: leather/chain/steel armor slots, steel buckler/dagger/longsword/staff/battle axe, short bow, arrows and robes. Exact stable template/quantity/body-fit mappings require ITEM/DATA fixtures. Choices, materials, quantities and custom properties are data-driven/moddable rather than locked to enum ordinals.

Items are temporary, with item-owned lifetime starting at successful creation and based on captured spell duration under MAGIC-008. Picker suspension consumes no duration. Ending the casting effect does not remove or perpetuate the created item. Transfer, drop, trade, stacking, splitting, equipping, saving and revisiting cannot reset lifetime or make it ordinary permanent property. ITEM/WORLD must retain expiry wherever supported ownership places it, including unloaded containers, without duplicating units or resetting timer during reconstruction.

Expiry removes the relevant units and safely reconciles equipment/capabilities through ITEM/COMBAT. Do not replace a lost weapon mid-attack or replay source rewards. Default summoned arrows retain COMBAT-008 nonrecoverable actor-impact policy; released-arrow lifetime remains its explicit COMBAT/MAGIC contract, not an inferred second inventory copy. Mod permanent-creation, expiry and item behavior policies must declare their outcomes. Trading availability/value remains ITEM/ECON policy; this feature does not authorize an unrestricted money-generation shortcut.

### Soul Trap admission and marks

Default timed Soul Trap marks eligible enemy monsters; enemy classes/civilians are ineligible. Data/mod profiles may add soul-bearing actors, resolved soul properties and compatible containers. Applicable initial defenses/save remain distinct from the deferred capture-chance roll. Do not roll the capture chance both at marking and at lethal resolution.

Compatible same-caster marks extend duration retaining incumbent power under MAGIC-009. Different casters' marks remain independent and resolve in stable application order, preserved across load; exact stable tie identity must be documented. Use captured power for the retained mark's chance formula rather than an absent-caster fallback level.

### Soul Trap lethal resolution and inventory

At a genuine lethal outcome, inspect currently eligible unexpired claims in order. A dead or genuinely unavailable caster's claim is skipped; remaining claims or ordinary death proceed. Merely unloaded but persistently accessible caster inventory is not automatically unavailable. Access authority must distinguish unavailable, valid empty and technical failure; technical failure invokes recovery rather than a false empty result.

For each eligible claim, resolve its capture chance once for this lethal attempt. Failure permits the next claim to try. Success fills one eligible empty container in the marking caster's accessible carried inventory, preferring an empty Azura's Star before ordinary empty soul traps, then allows the confirmed death. Container priority/capacity/access and soul eligibility are moddable. Stable ties within a priority require deterministic inventory identity/order. No implicit player-inventory fallback.

If a successful roll finds no eligible empty container, prevent that lethal outcome, leave target at 1 health, report the reason and stop this attempt. Later genuinely new lethal attempts may check again. Mods may instead allow ordinary death without capture. This is an explicit death-prevention rule requiring CHAR/COMBAT ordering, not an already-confirmed death followed by silent resurrection.

Only one soul can be captured per death. Equipped Azura's Star's automatic eligible-monster capture uses the same resolution/claim ledger, not an independent callback that can duplicate a trapped soul. Its automatic-capture capability remains explicit item data; exact ordering relative to marked claims must be fixed before implementation while respecting stable mark order and no double award. This feature does not infer that every source of death qualifies for automatic artifact capture.

Duplicate callbacks, technical retries and native load reuse resolved lethal-attempt rolls/container commitments. A no-container attempt that leaves health 1 must remain distinguishable from a later new hit. Settle protection prevention, capture, container mutation and death confirmation through explicit once-only owner boundaries; never retain a soul from an outcome that did not actually qualify for capture/death. Required ordering with other CHAR death-prevention effects remains an integration dependency.

### Dispel Magic

Default self Dispel opens a paid cancelable picker for one eligible active bundle. Cancellation, empty eligibility and failed chance retain committed cast payment. Revalidate selected stable bundle/contributions before applying; stale UI indexes cannot remove another effect.

Caster's own ordinary spells dispel automatically. Eligible externally cast effects use one declared dispel chance, with explicit saved provenance even if original caster is unloaded/dead. Do not add an unintended second generic chance before the selected-bundle chance. Dispelling selects the bundle's surviving eligible effects; mixed protected/dispellable entries require eligibility-aware cleanup and truthful disclosure rather than ignoring per-effect protections.

Dispellability is explicit data independent of HUD icon visibility. Disease, poison, curses, permanent NPC relationships and other special states are not automatically ordinary removable spells; their owners may explicitly permit removal. Past damage/lost pools or permanent consequences are not undone. Removing modifiers/capabilities invokes MAGIC-009/CHAR/MOVE coherent cleanup, preserving independent sources and current hazard transitions.

Eligible item effects may be dispelled without destroying or disenchanting the item. Record suppression of removed continuous contributions until declared reactivation, normally a fresh unequip/equip cycle. Per-frame rebuild, native restore or scene recreation cannot reactivate them. Genuine later use/recast may create a fresh effect. Item slot/power/source identity and suppression lifecycle must distinguish unrelated powers so one removal does not clear another source. Eligibility/reactivation, multi/individual-effect dispel and other-target modes are moddable.

### Dispel Undead and Daedra: banishment

These are dedicated nearby-area banishment operations, not Dispel Magic bundle selection. Default query selects current-location matching Undead/Daedra actors at strict distance <14 reference units through walls, independently of detection buffs. Each eligible actor receives an independent retained chance roll in stable query order. No implicit unreviewed cap may drop actors; exact collection/work-budget and scale fixtures remain required.

Default query path does not automatically add ordinary per-target spell defenses; banishment profiles explicitly declare any required resistance/defense stages. Range, obstruction, group eligibility and resistance are moddable. Quest-required actors are protected unless their quest provides an explicit supported banishment outcome. Banishment must not fabricate a kill or silently remove an actor required for progression.

Success establishes durable banished actor state and stops its ordinary gameplay representation without damage, confirmed death, corpse, loot, soul capture or ordinary kill credit. Revisit/load cannot regenerate that same actor. Remove only its own threat/targeting/source obligations through NPC/LOC owners; independent released payloads follow their declared lifetime, not automatic deletion. Required quest banishment progress uses its own acknowledged once-only outcome. Mods may explicitly define rewards/death-like outcomes through owners, not scene-destruction side effects.

## Relevant formulas and parameters

Open default eligibility d<=L; Lock unlocked difficulty d=L; L captured at release. Prepared use count 1, default lifetime until use/cancel. Identify one declared cost per nonempty eligible batch with independent per-item chance; exact mixed-bundle allocation required. Created-item duration uses captured effect formula and MAGIC-008 profile starting at creation. Soul Trap capture uses retained chance settings at lethal attempt; successful capture without container leaves health 1. Banishment radius 14 reference units with strict boundary; chance per eligible actor. All chance/rounding domains use RULE/MAGIC contracts, not fresh per-frame RNG.

## Required data

Stable cast/session/operation/source/recipient identities; utility family/profile and captured power/settings; prepared state/charge/choice; door lock/motion/access identity and artifact capabilities; Identify batch item/access/cost/roll/knowledge outcomes; created-item template/properties/quantity/provenance and expiry clock; Soul Trap claims/caster/soul/container access/priority and lethal-attempt rolls/commit ledger; dispel bundle provenance/eligible contributions and item suppression/reactivation state; banishment actor/query/quest permission/result; provider/schema versions and recovery obligations. Concrete storage/APIs remain dependencies.

## Inputs, outputs and events

Inputs: authorized release, current target/access/owner state, utility choices/cancel, eligible-door activation, identification confirmation, lethal attempts, current containers, selected dispel bundle, banishment query, elapsed time and restore. Outputs: preparation or consumed attempt, changed lock/motion request, knowledge update/debit, temporary item creation/expiry, capture/prevented lethal/ordinary death handoff, scoped effect removal/suppression, durable banishment and optional feedback. Each stage reports actual completion rather than treating UI close/scene destruction as universal success.

## Cross-system interactions

MAGIC-003–010 casting, power, admission, timing/source cleanup/native restore; MAGIC-015/016 item powers; MOVE-018–021 action arbitration/access/door state; ITEM/ECON knowledge, inventory, soul containers, temporary property transfer/value/expiry; COMBAT-008 summoned ammo, COMBAT-015–021 attacks/death/corpse and CHAR death prevention; NPC/QUEST actor banishment and relationship exclusions; LAW incidents independent of unlock; WORLD/LOC stable current/unloaded ownership; CORE/SAVE scope/readiness/recovery/UI suspension; DATA/MOD explicit stable capabilities and policy versions.

## Edge cases and failure conditions

Cover simultaneous Open/Lock, moving/ineligible/already locked door, insufficient lock power, quest/magical protection, blocked closure and failed entry after unlock. Cover Identify no eligible items, free/item casts, mixed bundles, removed items and partially completed batches. Cover picker cancel, overflow/unsupported destination, item splitting/trading/unloaded expiry and equipped expiry. Cover competing Soul Trap casters, inaccessible versus empty inventories, full Star, automatic artifact claim, repeated lethal attempts, other death prevention and banishment exclusion. Cover hidden/protected mixed dispel entries, absent original caster and suppressed equipment restore. Required technical errors are not ordinary failed rolls or permission to lose state.

## Configuration and balancing options

Explicit per-family profiles cover door targeting/formulas/lifetime/charges/artifact exceptions; identification batch/cost/chance/access/property knowledge; created-item choices/properties/lifetime; soul actors/capacity/access/priority/arbitration/no-container policy; dispel eligibility/targets/suppression/reactivation; banishment range/obstruction/groups/resistance/quest outcomes. Selector precedence/numeric limits/schemas must be validated. Presentation/UI mods cannot independently mutate authoritative operations or bypass protected owner state.

## Save/load considerations

Save coherent completed state: prepared Open/Lock and captured power; durable locks/knowledge; temporary item lifetime wherever owned; Soul Trap sources/stable claim order/lethal results; item-dispel suppression and banished actor/quest records. Temporarily block saving with clear reason during unresolved utility pickers and partially committed operations. Native load does not reopen pickers, reroll preparation/identification/capture, create items/souls or reactivate suppressed powers. Rebuild derived displays/capabilities without grants. Timed mod profiles follow MAGIC-008 clocks/migration; required missing providers/identities require supported migration/recovery rather than invented replacement items/actors.

## Technical constraints

Target Godot 4.7.2. Separate utility interactions from owner operations; no mutation during preview/construction. Use stable identities and idempotent commitment facts across async UI, world loading and death processing. Do not require a general transaction framework by implication; each boundary must nevertheless prevent duplicated/lost outcomes. Avoid global-player inventory fallback, texture-based artifact identity and unchecked UI indexes. No implementation/coding tasks authorized.

## Acceptance criteria

1. Paid persistent Open/Lock prepares one use; invalid interactions preserve it, genuine attempts consume; coexistence requires explicit operation choice.
2. Captured level controls default lock operations; existing locks are unchanged by Lock; explicit stable item/quest exceptions apply without double chance.
3. Door motion/access/legal owners retain authority; unlock persists despite later entry failure and collision safety is preserved.
4. Identify defers its own debit directly, charges once per eligible batch, rolls independently, and cannot generate refund magicka or alter bundled-other-effect costs.
5. Identify knowledge/access/retries are revalidated; empty/already known items do not charge/roll; partial recovery cannot duplicate outcomes.
6. Create Item confirms once from moddable data, permits paid cancellation, does not auto-equip and starts item-owned lifetime at creation.
7. Temporary items retain lifetime through transfer/save/split/unloaded ownership and expire safely without becoming permanent or duplicating summoned-arrow recovery.
8. Soul Trap marks use separate admission and lethal capture chance; same-caster extension/different-caster stable claims preserve captured power.
9. Failed capture permits next claim; one successful container claim yields one soul; successful no-container roll leaves health 1 and stops that lethal attempt.
10. Dead/unavailable caster claims skip; unloaded access is owner-checked; technical failure is not fake empty inventory; artifact capture cannot duplicate a soul.
11. Dispel Magic paid selection removes eligible surviving contributions, automatically for own ordinary spells and by chance for external effects, without undoing past damage.
12. Dispelling item effects preserves item and durable suppression until explicit reactivation; hidden icons do not determine eligibility.
13. Nearby Undead/Daedra banishment uses independent retained rolls and quest protection, creates no default death/loot/soul/kill reward and persists actor removal.
14. Native restore preserves prepared states, item expiry, claims/suppression/banishment without replay; unresolved picker/partial operations clearly restrict saving.
15. Declared mod alternatives retain validation, attribution, source cleanup and explicit owner consequences.

These are future verification criteria; no implementation/runtime tests performed.

## Consistency review

Reviewed against MAGIC-004/008–010/016, MOVE-020/021 and COMBAT-008/020. Identify is a deliberate deferred-payment exception, not an automatic refund permission for other effects. Open separates unlock from entry/permission; Lock respects noncrushing ordinary-door policy. Item lifetimes and suppressed powers cannot reset through load/rebuild. Soul Trap no-container protection occurs before death confirmation, preserving COMBAT's finality after confirmed death. Banishment is not death and therefore cannot emit normal corpse/kill/soul outcomes. Source-owned dispel cleanup preserves independent contributions and movement hazard transitions.

## Outstanding questions and approval

No further blocking player-policy question identified. Required dependencies: exact preparation recast-power policy and action-choice UI; mixed-bundle Identify cost allocation/payment-mode coupling; complete created-item templates/quantities and unloaded expiry/commerce contracts; Soul Trap versus other death prevention/artifact priority and caster-access fixtures; mixed-bundle dispellability/item suppression schemas; banishment quest acknowledgment/current-world queries; native migrations/commit recovery. These do not waive confirmed payment, single-soul, protected-quest or no-replay rules. Material gameplay changes discovered during integration return for explicit review.

The user explicitly approved the complete Draft v1 on 2026-11-10 with “I approve”. This specification is finalized v1 under MAGIC-027-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented integration and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
