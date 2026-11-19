# ITEM-017 — Potions, drugs and recipe items

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Route potion/drug consumption and recipe reading to checked owners without wrong-unit removal, content replacement or unintended learning/brewing.

## Intended player experience

Each deliberate use consumes the selected dose once under clear access rules. Unknown consumables can be used without preview revealing their contents. Recipes remain reusable instructions rather than automatic potions or permanent learning rewards.

## Confirmed requirements

- **ITEM-017-D01:** Inventory/quick-use share the checked MAGIC-014 operation. Consume the exact selected potion unit once; technical invalidity preserves it, valid no-benefit use consumes. No whole-stack removal or rebuilding contents from changed recipes.
- **ITEM-017-D02:** Consume one authorized drug dose through stable explicit drug/effect profiles, not numeric template offsets. Profiles declare eligibility/defenses/effect-consumption commitment under MAGIC-020. Unsupported content fails without item loss. No default addiction mechanic introduced.
- **ITEM-017-D03:** Explicit Read recipe shows known instructions and supports selecting a possessed accessible recipe in MAGIC-013 mixing. Reading does not consume, brew, grant ingredients or teach permanent recipe knowledge. Explicit mod alternatives supported.
- **ITEM-017-D04:** Baseline potion/drug use requires selected unit in actor's carried inventory. Direct wagon/container use needs explicit supported access/ownership policy; opening a container alone grants no consumption permission.
- **ITEM-017-D05:** Valid unidentified potions/drugs may be deliberately used without prior hidden-content disclosure. Feedback/discovery follow declared rules; no automatic full identification. Mod identification requirements/confirmations supported.
- **ITEM-017-D06:** Valid committed drug doses consume one even if immunity/resistance/same-type effects prevent change. Blocked eligibility/missing content preserves unit; partial technical failure retains exact facts/recovery. Drug timing/defenses are explicit, not inherited potion permissions.
- **ITEM-017-D07:** Lost recipe-item access removes possessed selection without erasing permitted knowledge. Staged mixing revalidates required recipe access before commit; explicit learned-recipe mods may use durable knowledge. Reading grants neither entitlement nor ingredients.
- **ITEM-017-D08:** Mod animations/cooldowns/confirmations declare consumption point and interruption rules; cosmetic animation alone changes no timing. Revalidate original selected unit at commitment, without same-name substitution.
- **ITEM-017-D09:** Preserve actual contents/potency policy/dose-use state/discovery and committed consumption-effect facts. No load quantity refill/potency replacement/repeated exposure/recipe knowledge grant. Existing pending save/cancel rules bind; old-session callbacks cannot consume again.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem`: calls DrinkPotion then RemoveOne without checked success; recipe branch reports cannot-use; drug branch converts template index to poison ID and removes the item entry.
- `Game/MagicAndEffects/EntityEffectManager.cs#DrinkPotion`: looks up current recipe, constructs primary/secondary entries using shared recipe settings, assigns self-targeted Potion bundle bypassing saving throws/chance, then plays feedback.
- `Game/Formulas/FormulaHelper.cs#InflictPoison`: referenced drug exposure path; detailed lifecycle belongs to MAGIC-020.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/parity verification; source unchanged.

## Existing approved constraints

MAGIC-014 owns saved potion payload/potency, use restrictions, one-unit consumption, valid no-benefit versus technical failure and practice/history. MAGIC-013 owns possessed recipes, mixing, knowledge and output. MAGIC-020 owns poison/drug lifecycle. ITEM-001–016 preserve identity/custody/contents/quantity, explicit actions and knowledge; ITEM-004 recipe retention does not authorize brewing. This feature integrates item actions without reopening approved effect rules.

## Detailed rules and behaviors

### Shared item action and access

Use explicit ITEM-015 Drink, drug-dose or Read recipe actions through ITEM-002 shared authority. Inventory and quick-use reference actual actor/item/unit/context, not current UI order or a same-name substitute. Baseline drinking/drug use requires the unit in the actor's carried inventory. Direct wagon/container consumption requires an explicit validated profile with current access/ownership checks; merely opening storage is insufficient.

Revalidate custody, quantity, original identity, actor eligibility, quest restrictions, providers and session at commitment. Retired/merged references cannot silently redirect under ITEM-001. Known missing/blocked actions reject without consumption; technical failures cannot masquerade as valid no-benefit uses.

### Potions

Delegate effect application and consumption to one checked MAGIC-014 operation. Consume exactly one selected unit per distinct committed use, not the entire entry. Use the bottle's retained validated ordered contents, independent per-effect settings and saved potency/scaling policy from MAGIC-013/014 and ITEM-004; changed recipe lookup cannot replace crafted contents or apply crafting bonuses again.

MAGIC-014 ordinary use requires no spellbook/magicka and allows silence, climbing, paralysis and underwater use while retaining dead-actor/item-access restrictions. Default immediate use adds no spellcasting wind-up/recovery/cooldown. Its Potion-origin chance/save bypass, hard-immunity handling and absence of ordinary spell interception remain independently declared permissions, not blanket bypass authority. This feature preserves these approved rules without extending them to drugs.

A valid committed potion consumes even when full resources, immunity, valid suppression or inapplicability means no benefit. Blocked/technically invalid use preserves the item; real partial mutation retains completed facts for explicit same-use recovery. No refund with active effects, repeated application or whole-stack retry. Ordinary use grants no magic-school practice and does not change last-spell history under MAGIC-014; explicit progression mods need owner-authorized once-only grants.

### Drugs and doses

Stable explicit drug profiles identify actual payloads and source provenance under MAGIC-020, replacing template-number offsets. Consume one authorized dose, retaining effect attribution after the unit disappears. Eligibility, exposure defenses, onset, duration, same-type redundancy, positive/negative contributions and cleanup follow the declared poison/drug profile.

Valid committed doses consume even when immunity/resistance or an existing same-type effect prevents change. Blocked eligibility/missing providers preserve the unit; partial technical failures retain exact phases and recovery. Drug permissions/timing cannot be inferred from potion defaults. No universal level-one immunity, addiction, overdose, tolerance or permanent reward is introduced. Explicit validated extensions may define additional mechanics through their owners.

### Knowledge and feedback

Allow deliberate valid unidentified potion/drug use without disclosing hidden contents first. Display known information and actual permitted discovery under profile rules, not hidden effects/immunities through previews. Use does not automatically identify every property. Mods may explicitly require identification or confirmation.

Report committed use even without a benefit; an absent effect icon is not evidence of failed consumption. Missing-content/blocked feedback distinguishes unchanged rejection from completed no-effect use. Optional sound/animation failure cannot reverse or replay committed gameplay.

### Recipe items

Read recipe shows known instructions and may select the possessed accessible recipe in MAGIC-013's mixing interface. Reading is reusable/unconsumed and does not brew, grant ingredients or automatically teach durable recipe entitlement. Existing MAGIC-013 experimentation/ingredient-knowledge rules remain binding.

Losing recipe access removes it from possessed selection without erasing separately permitted knowledge. Staged mixing revalidates required item access before commitment; explicitly supported learned-recipe mods may rely on their durable knowledge instead. Missing recipe content/provider fails explicitly rather than inventing ingredients or changing the staged recipe. Detailed brewing/station/output rules remain MAGIC-013, not a second implementation in item use.

### Deferred actions and recovery

Any mod timing/animation/cooldown/confirmation declares commitment/consumption/interruption rules. Cosmetic animation alone changes no timing. Duplicate callbacks cannot consume twice; deferred work validates the same source, actual current state and active session. Composites and quest interception retain ITEM-015 explicit outcomes and no-fallthrough rules.

Coordinate quantity removal/effects through checked owners. Pre-commit rejection leaves state unchanged; partial committed effects or consumption retain truthful facts and recovery, not automatic full retry/refund. Exact receipts/APIs remain design dependencies; no generalized transaction framework is mandated.

## Relevant formulas and parameters

Committed baseline potion/drug use consumes one authorized unit. Read recipe consumes zero. Potion cost/timing/scaling follows MAGIC-014; drug exposure/ticks follow MAGIC-020 and supported profiles. No new potency equation, drug timing default, alchemy yield, addiction chance or recipe learning formula is selected. Quantity/state arithmetic and split handling follow ITEM-005/006.

## Required data

Stable actor/item/unit/profile/provider/recipe/session/use identities; actual saved effect contents and potency policy; available quantity/custody/access; required exposure permissions and captured context; dose/timing/cooldown/commit state where applicable; discovery/known recipe and possessed access; per-phase effect/consumption/recovery facts. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: deliberate inventory/quick-use/recipe-read, explicit actor/unit/context; validated effects and provider state; deferred confirmations/interruption; mixing access and native restore. Outputs: committed one-dose effect/consumption with actual outcomes, reusable recipe presentation/selection, blocked/invalid unchanged rejection or explicit partial recovery. Query/hover/feedback does not consume or apply effects. Concrete APIs/signals remain unselected.

## Cross-system interactions

MAGIC-013 owns mixing/recipe knowledge, MAGIC-014 drinking and MAGIC-020 drug/poison lifecycle; other effect owners handle actual resource/modifier changes. ITEM-001–006 preserve identity/contents/quantity and split resources; ITEM-007/008 govern custody/access/capacity; ITEM-015 routes explicit actions. QUEST protects item use; UI presents known outcomes; DATA/MOD validate profiles/providers and SAVE/CORE preserve coherent scoped state. No new detailed drug content is finalized here.

## Edge cases and failure conditions

- Unidentified valid unit: deliberate use allowed without automatic full identification.
- Full-health potion/resisted or redundant valid dose: consume once despite no benefit.
- Missing recipe/effect/provider: unchanged technical rejection, not consumed ineffective use.
- Selected source moved/merged/consumed before commit: revalidate, no same-name substitution.
- Stack use: one unit, retained correct payload/provenance; no whole-entry removal.
- Lost possessed recipe during staging: required access fails without erasing legitimate knowledge.
- Repeated confirmation or partial technical failure: retained phases prevent double dose/reward or unsafe refund.

## Configuration and balancing options

Validated direct-container use, identification/confirmation requirements, timing/cooldown/interruption and explicit drug profiles are supported. Recipe learning/consumption alternatives need supported owner rules. Potion permissions/costs remain independently moddable under MAGIC-014. No automatic extension of permissive potion restrictions to drugs, hidden-content disclosure or addiction baseline is introduced.

## Save/load considerations

Persist actual contents/potency policy, relevant dose/use state, knowledge and committed effect/consumption phases. Retain MAGIC-020 exposure/onset/progression facts without a fresh dose; MAGIC-014 scaling context must not overwrite creation-resolved potency. Recipe knowledge remains separate from physical possession.

Load cannot refill quantities, replace payloads, repeat exposure, grant recipe entitlement or replay progression. Supported pending snapshots and cancellations follow ITEM-002/015 and action-specific MAGIC rules; otherwise explain temporary save restrictions. Missing required provider/state needs explicit migration/recovery rather than generic contents. New session rejects old callbacks. Exact native schemas and receipts remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate item authorization, retained payload, owner effect application, quantity settlement and feedback. Use stable drug/recipe/profile keys rather than numeric offsets or current recipe reconstruction. No global-player fallback, UI-driven second removal or mandated generic transaction framework. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Inventory/quick-use share checked selected-unit potion execution and consume once with saved contents/potency.
2. Valid no-benefit potion/drug outcomes consume; blocked/missing-content cases preserve items and partial failures retain recovery facts.
3. Drug doses use explicit stable profiles and MAGIC-020 lifecycle, not numeric offsets/potion permission inference or whole-stack deletion.
4. Baseline carried-source access and explicit direct-container extensions enforce current access/ownership/quest restrictions.
5. Unidentified use and feedback preserve declared knowledge boundaries; mod requirements are explicit.
6. Read recipe is reusable, shows known instructions/selects accessible possessed recipes without brewing/grants/permanent entitlement.
7. Recipe access loss revalidates staging without erasing legitimate knowledge; learned-recipe extensions use explicit durable authority.
8. Delayed timing/interruption/consumption points are declared; cosmetic animation cannot change mechanics or substitute another unit.
9. Native restore/retry preserves quantities/contents/knowledge/phases without re-exposure/refill/reward or old-session mutation.

## Contradiction review

Reviewed against approved MAGIC-013/014/020 and ITEM-001–016. No direct contradiction identified. This integrates consumption rather than reopening saved-potency, valid-no-benefit or potion activity permissions. Carried-only baseline refines MAGIC-014's deferred ITEM access policy; direct-container mods remain explicit. Recipe reading grants no automatic knowledge, consistent with MAGIC-013 possessed access and ITEM-004. Drug profiles remain distinct from Potion origin. Future detailed recipe/drug/mod profiles remain owner dependencies.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: payload/unit/compatibility schemas; drug eligibility/timing/defense/classic dose fixtures; direct-source access and knowledge policies; recipe reading/mixing selection integration; delayed-action commitment/interruption receipts; native snapshot/migration/recovery fixtures. Concrete unresolved gameplay profiles require explicit owner decisions before support is claimed. These cannot waive selected-unit settlement, preserved contents, knowledge boundaries or no-replay guarantees.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-017-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented payload/unit schemas, drug profiles/fixtures, source access/knowledge policies, recipe integration, deferred commitment and native recovery/migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
