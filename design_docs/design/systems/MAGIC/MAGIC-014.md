# MAGIC-014 — Potion consumption

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Consume one authorized potion unit and apply its retained contents through checked effect admission without duplicate item loss, unintended casting restrictions or altered crafted potency.

## Intended player experience

Ordinary drinking is immediate, costs no magicka and works while silenced, climbing, paralyzed or underwater. It consumes a valid bottle even if healing is unnecessary or an effect cannot apply normally. Blocked/technically invalid uses preserve it. Mods can change activity restrictions, timing, defenses, potency context and explicit potion-use progression.

## Confirmed requirements

MAGIC-014-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm saved bottle bundles, separate defense permissions, once-only consumption, permissive moddable access defaults, immediate/moddable timing, explicit potency policy, no default practice/recast changes, shared checked use and truthful feedback/native restore. The complete specification is approved under MAGIC-014-A01.

MAGIC-013 generated-potion contents, MAGIC-006 admission, MAGIC-007 defense separation, MAGIC-008/009 lifetime/stacking and MAGIC-010 restoration remain binding. ITEM owns access/quantities; drinking does not authorize throwing poisons, feeding NPCs or inventing other delivery modes.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full recipe/effect scaling and runtime failure behavior unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/`.

- `MagicAndEffects/EntityEffectManager.cs#DrinkPotion` looks up current recipe/main effect by PotionRecipeKey, builds primary/secondary entries with shared recipe settings, creates a Potion/caster-only bundle and calls AssignBundle with BypassSavingThrows|BypassChance. It plays player casting sound afterward.
- `UserInterfaceWindows/DaggerfallInventoryWindow.cs` and `DaggerfallUseMagicItemWindow.cs` invoke DrinkPotion then remove one item without a returned success outcome. Required recipe/provider failure therefore is not represented by an explicit checked consumption result in this path.
- Hard immunity remains a separate AssignBundle gate. Spell interception is conditional on spell bundle classification, distinct from potion bundle.

These observations do not approve regenerating generated bottle contents from changed recipes or item loss after a technical failure.

## Detailed rules and behaviors

### Bottle payload and potency

Use the bottle's saved validated ordered effect bundle with independent per-effect settings, stable identity and profile/provenance. Do not rebuild from current recipe merely to drink. Retain dynamic MAGIC-013 arrangements without fixed recipe/slot assumptions; required provider/version compatibility still validates.

Each bottle/profile explicitly records scaling policy: supported DFU-style recipes default to drinker level at consumption, while dynamic alchemy may retain creation-resolved potency. Capture required consumption-time inputs once for that use. Do not recompute crafted fixed potency or apply crafting bonuses twice. Later recipe changes cannot silently replace the saved policy/settings.

Exact effect-family adapters for level-dependent duration/magnitude and fixed potency require fixtures. Missing required context is a technical failure, not implicit level one. Once applied, effect live/captured dependencies follow declared owner contracts; the potion's origin does not make all power continually track drinker level.

### Access and default restrictions

Ordinary drinking requires no spellbook or magicka and is allowed while silenced, climbing, paralyzed and underwater. It is independent from spellcasting restriction/animation rules. Dead actors and inaccessible/prohibited items cannot use this path; source/item authorization remains mandatory.

Validated use profiles may change activity restrictions. Exact item-source legality, container/wagon access, quest protection and equipment constraints remain ITEM/activity owner rules. Permissive paralysis/climbing defaults are explicit potion-use policies, not permission for weapon attacks or ordinary spellcasts during those activities. Moddability does not imply resurrection or bypassing unavailable content.

### Timing and selected unit

Default immediate use has no spellcasting wind-up/recovery or additional cooldown. Separate deliberate requests may drink separate units. Mods may define drinking animations/delays/cooldowns/usage limits with explicit consumption/commit/interruption rules. Cosmetic animation alone cannot alter timing or bypass the configured operation.

Inventory and quick-use invoke one checked operation with stable use identity, exact selected bottle/item and resolved payload. Consume exactly one unit, never a whole stack. Duplicate delivery of the same request is not another drink. Stack compatibility must account for relevant payload, potency policy and required per-item state rather than name alone; ITEM defines exact equivalence.

Revalidate selected unit quantity/access/current actor eligibility at commitment. No silent substitution of another same-name potion or refreshed source settings. Capture enough data for the effect source to remain attributable after the consumed item disappears legitimately.

### Admission and defense permissions

Default consumption applies to the drinker as Potion origin. It bypasses on-cast effect chance and RULE-017 effect saves; hard immunity still applies absent explicit specific exception. It is outside spell absorption/reflection/Spell Resistance by default. Each permission remains independently moddable under MAGIC-006/007; no generic bypass-everything flag or free-cost inference.

Unusual harmful/poisoned concoctions can declare alternative supported rules. Drinking origin, defense applicability and hard immunity must be explicit and versioned, not inferred from display name. This feature does not assign every future poison/disease effect an exemption.

Apply supported effects in authored order under MAGIC-006, including current applicability, accepted-only startup, retained outcomes and immediate initial application. MAGIC-009 resolves overlaps. One rejected/ineffective component does not silently cancel independently accepted components. Technical malformed/missing content remains distinct from ordinary immunity/stacking outcomes.

### Consumption and recovery

Prepare/validate complete content and required application context before consuming. Invalid provider/payload/context or technical preparation failure preserves bottle and produces explicit failure. No effect may apply as a free side effect of failed preparation.

Commit one selected-unit consumption and authorized effect application once through checked owners. A valid drink consumes even when all normal outcomes are ineffective: full health/resource, immunity, valid stack suppression or inapplicability under declared effect rules. Do not turn those into technical refund cases.

Unexpected partial gameplay mutation requires explicit same-use recovery preserving committed consumption/application facts. No blind refund with active effects, repeated application or whole-stack retry. Exact preparation/commit/receipt contracts are implementation scope rather than a mandated universal transaction framework. Missing required content cannot be disguised as a successful ineffective drink.

### Practice, history and feedback

Ordinary drinking grants no magic-school practice and leaves last-spell/recast history unchanged. Applying magical effects does not become an ordinary spellcast. Explicit validated mods may grant potion-use progression through appropriate owner operations, with once-only current-session reporting. No default alchemy skill/reward is invented.

Report committed consumption even if actor state did not change effectively; ordinary no-benefit outcome is not bottle preservation. Blocked or technically invalid use explains failure with item unchanged. Show only known potion/effect information under profile discovery rules; no hidden immunity/payload disclosure via preview. Sound/animation failures cannot replay or reverse committed gameplay.

Active effect HUD derives actual accepted state under MAGIC-010; a consumed bottle need not leave an active icon if it produced only immediate or rejected effects. Display presence is not the consumption receipt.

## Relevant formulas and parameters

Default committed consumption=one authorized unit per distinct use; magicka cost=0, no additional wind-up/recovery/cooldown selected. Effect scaling uses saved explicit profile policy and effect-owned formulas; no new magnitude/duration equation or universal drinker-level fallback. Permissions are separate named rules. Exact delayed-profile timings/limits remain mod schemas, not arbitrary universal constants.

## Required data

Use/session/actor/item/unit identity; saved ordered bundle/settings/profile/version/provenance; fixed or consumption-time scaling context; item quantity/access; independent defense/restriction permissions; timing/cooldown/commit state where configured; per-entry retained outcomes and recovery obligations; explicit progression eligibility/receipt. Exact item serialization/stack equivalence remains dependency.

## Inputs, outputs and events

Inputs: deliberate inventory/quick-use, exact item selection, actor/access/content checks, resolved use profile and owner application results. Outputs: committed one-unit consumption and effect outcomes, blocked/invalid unchanged-state failure or explicit partial recovery; optional progression, feedback and derived HUD. Concrete APIs/signals unselected. UI use selection and effect icon refresh cannot independently remove a second item.

## Cross-system interactions

MAGIC-013 supplies stable generated contents/potency provenance; MAGIC-006/007 admission/permissions, MAGIC-008/009 timing/stacking and MAGIC-010 persistence/HUD. MAGIC-004 history/practice remains unaffected by ordinary drink. ITEM owns quantities/access/stacking and consumption; CHAR pools/progression receive authorized effects/reports. UI/input/activity owners enforce explicit use restrictions; DATA/MOD validate profiles; SAVE/CORE-013 preserve coherent state/readiness.

## Edge cases and failure conditions

- Full health or immunity: valid bottle consumed, independent other effects may apply.
- Missing recipe after generation but valid saved contents: no automatic current-recipe dependency; required payload/provider incompatibility still recovers explicitly.
- Same-name different potencies: exact selected unit, no name-based substitution/stack collapse.
- Free/silenced/paralyzed/climbing/underwater: default drink permitted subject to living/item validity; no inherited spell restriction.
- Dynamic fixed-power versus drinker-level potion: use stored policy once, not double crafting scaling or altered current recipe.
- Inventory and quick-use duplicate callback: one unit/effect operation; distinct permitted requests remain distinct.
- Technical error after some components applied: retained recovery, no free duplicate effect or blind bottle refund.
- Cosmetic animation hidden/missing: gameplay timing/receipt unchanged.

## Configuration and balancing options

Validated profiles may change activity use restrictions, separate chance/save/immunity/interception permissions, fixed/drinker scaling, timings/cooldowns/limits and explicit progression. Permissive stated defaults remain. Delayed profiles must define interruption/payment-equivalent consumption points and save behavior before activation. Exact hooks/selector precedence/numeric limits remain dependencies; no arbitrary unsupported potion mutation or blanket status bypass is approved.

## Save/load considerations

Persist resolved bottle contents/potency policy and committed one-unit use/effect state. Native restore never drinks, removes another bottle, refreshes a timer or grants practice again. Preserve mod cooldown/pending-use progress only through explicitly supported coherent schemas; otherwise explain safe-boundary save delay/rejection under CORE/SAVE.

Applied effects restore under MAGIC-010 without reconstructing from current recipes. Provider/profile changes require explicit supported compatibility/migration; missing required content cannot silently delete an effect. Exact partial-use result/receipt and delayed-profile migration remain SAVE/MAGIC/ITEM scope. Classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. Separate consumption receipt from effect acceptance, source origin from spell flags, and durable bottle contents from recipe lookup. Inventory/quick-use share checked owner operations, not duplicate UI item removal. Exact save/version schema, item equivalence, preparation/commit recovery and mod API remain design work. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Use retained ordered payload/per-effect settings and explicit potency policy without current-recipe regeneration/double scaling.
2. Default permissions bypass chance/save but not hard immunity or unrelated spell defenses; explicit profile permissions remain independent.
3. Default use works without book/magicka while silenced/climbing/paralyzed/underwater but rejects dead/inaccessible/prohibited contexts.
4. Default timing immediate; declared animation/delay/cooldown rules cannot change through cosmetic-only flags.
5. One checked inventory/quick-use request consumes one exact unit despite ordinary ineffective outcomes; technical prep failure preserves unit with no free effect.
6. Mixed accepted effects apply safely/in order; partial technical recovery cannot duplicate consumption/application or refund live benefits.
7. Ordinary use leaves practice/history unchanged; explicit progression reports once through owners.
8. Feedback respects knowledge and consumption truth; native restore never repeats use and preserves supported cooldown/pending/effect state coherently.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-006/007/010/013, MAGIC-004 origin/history, CHAR resource/progression ownership and CORE-013 safeguards plus recorded MAGIC-014-D01–D09. No direct contradiction identified. Saved contents and explicit drinker-scaling policy preserve MAGIC-013 generated output without forcing every potion to fixed power. Permissive activity drinking is distinct from casting/weapon restrictions. Normal ineffective consumption differs from technical failure. Separate bypasses and no ordinary spell practice/history preserve prior policies; ITEM/partial-use contracts remain dependencies rather than assumed implemented.

## Outstanding questions

No further blocking drinking player-policy choice is identified. Before implementation is complete: fixture-verify recipe-family scaling/permission inventories; define bottle/item equivalence, source/access and exact use/preparation/commit receipts; specify mod restriction/timing/progression API and delayed interruption profiles; integrate knowledge-safe feedback, active effects and coherent native migrations. These deferrals cannot authorize current-recipe rewriting, duplicate units/effects, blanket bypass or silent technical item loss.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-014-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented scaling/permission inventories, item/access and use-commit contracts, mod timing/restriction profiles and native persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
