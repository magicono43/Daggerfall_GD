# MAGIC-013 — Potion recipes and mixing

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Turn checked ingredient selections into potion items through a recipe-based default or explicit alternative alchemy profile, with once-only consumption/output and durable generated effect settings.

## Intended player experience

Players can follow possessed recipe items or experiment. Default matching is deterministic; a confirmed unmatched experiment wastes selected ingredients without a potion. Technical errors preserve inputs. Mods can implement common-effect ingredient alchemy and customizable generated potions rather than being restricted to fixed recipes. Staging and previews respect item access and learned knowledge.

## Confirmed requirements

MAGIC-013-D01–D13 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm stable recipes/multiset matching, experimentation, default failure consumption, extensible ingredient data/dynamic potion composition, station profiles, exact staged inputs, knowledge rules, checked output, persistent staging, retained randomness and disclosure. The complete specification is approved under MAGIC-013-A01. Drinking is MAGIC-014; item transfer/access, service pricing and progression remain their owners.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full recipe assets/runtime failure scenarios unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/`.

- `MagicAndEffects/PotionRecipe.cs` stores sorted ingredient template IDs, effect settings, price/name/texture and secondary effect keys; equality compares ingredient arrays, while recipe lookup uses a computed ingredient hash/classic key mapping.
- `MagicAndEffects/EntityEffectBroker.cs#IndexEffectRecipes`, `GetPotionRecipe` index recipes provided by effects, with replacement/collision behavior governed by registration.
- `UserInterfaceWindows/DaggerfallPotionMakerWindow.cs#Refresh` gathers unenchanted ingredients and recipe items from inventory/wagon, using cloned ingredient collections for staging. `AddRecipeToCauldron` selects matching types through a dictionary, so repeated-ingredient handling requires a quantity-aware target design.
- `MixCauldron` hashes selected types, creates a potion for a matched recipe, then removes selected ingredients regardless of match. Creation precedes inventory consumption; missing later ingredients can leave incomplete work. Target checked commitment does not adopt this ordering.

## Detailed rules and behaviors

### Recipe-based default

Use stable recipe IDs separate from ingredient combinations/display names/hash codes. Default matching uses an order-independent multiset of ingredient types and required quantities: repeated ingredients count, and ingredient order does not alter match. A hash can accelerate lookup but must not establish identity/equality alone. Ambiguous combinations require an explicit validated resolution rule; registration order cannot silently choose output.

Valid matching default recipes succeed deterministically and produce their declared potion output. Players may experiment without possessing a recipe item; possessed recipe items provide convenient selection of required ingredients. Default success does not permanently teach recipes. Mods may require knowledge/books or award discovery; default remains recipe-item access for the shortcut, not permanent learned discovery.

A deliberately confirmed, valid unmatched experiment consumes staged quantities and yields no potion. This is a legitimate gameplay outcome, distinct from missing definitions, inaccessible items, invalid profile or technical creation failure. Validated profiles may change failure consumption/output. No default random failure chance is added to a valid exact recipe.

### Ingredient data and alternative alchemy models

Alchemy extension must support Morrowind/Oblivion-like common-effect combination and dynamic potion arrangements, not just adding predefined recipes. Mods can declare versioned namespaced ingredient properties, including supported effect references, potency, discovery thresholds or quality. Validate references/types/defaults; exact property set is profile-defined rather than hard-coded to another game's formulas.

Keep reusable ingredient definitions separate from per-item or character state where a profile needs degradation, discovered effects or similar properties. Metadata does not itself execute arbitrary gameplay or grant ingredient knowledge. ITEM/DATA/MOD must define safe schema/instance compatibility rather than silently attaching uncontrolled runtime fields to existing items.

An alternative profile can control matching/shared-effect rules, ordered generated effects, magnitude/duration/chance, yield and failure outcomes using declared ingredient, skill, equipment and environment inputs. Required apparatus/service/progression rules must be explicit; no particular Morrowind/Oblivion formula, skill curve, ingredient count, apparatus bonus or reward becomes vanilla by this feature.

Generated potions retain their resolved supported effect bundle and source/profile provenance. Effect arrays are not constrained to a predefined recipe combination or classic slot arrangement. Validate complete effect support and numeric domains under MAGIC-001/006 and owner formulas. Generation does not bypass hard-immunity/save/consumption rules of MAGIC-014 merely because a profile authored a custom bundle.

Later ingredient/profile changes cannot silently rewrite existing bottles' resolved arrangements or potency. Save compatibility/migrations still validate required providers; snapshots do not make unavailable executable effects usable. Exact stacking/identity for bottles with different payloads belongs to ITEM/MAGIC-014 and must not collapse distinct contents by name alone.

### Profile selection and captured attempt

Each station/service explicitly selects one resolved alchemy profile per mixing attempt. Mods may replace default or assign different profiles to different stations, allowing fixed recipes and shared-effect systems to coexist. Never run multiple profiles against one attempt as fallback after partial execution.

Capture selected profile/version, exact ingredients/settings, declared caster/skill/equipment/environment context and service quote for the authorized attempt. Revalidate current requirements before commitment. Profile selection/override precedence and mutable-context capture details require explicit schemas; UI guesses do not become rules.

### Staging and item access

Stage exact item identities/quantities without moving/consuming original inventories. Default eligibility is unenchanted ingredients; mods may explicitly extend it. Quantity accounting must handle multiple stacks/repeated types without selecting one unit twice.

Inventory/wagon sourcing follows actual ITEM/travel access, ownership, quest and other restrictions. Being visible in a crafting list is not permission to access an absent wagon or consume a protected item. Recipe shortcuts select valid items under those rules rather than bypass them. Exact deterministic source selection may be implemented under ITEM/UI contracts; captured intent remains stable.

Revalidate all staged quantities and access at commitment. Missing items/quantity/source changes are explicit failure preserving remaining inputs; do not silently substitute another stack/item. Staged selections survive subwindows, service exit/reopen and native saves. Reopening revalidates and flags stale selections; restoration never auto-mixes. Canceling/un-staging is not an inventory refund because ingredients were never consumed.

### Preview, knowledge and randomness

Profile declares what preview may disclose: known result, estimated conditions/chance or unknown outcome. Possessed recipe-assisted mixing may show known output; dynamic experiments follow saved discovery rules. Preview cannot leak otherwise hidden ingredient effects, roll actual attempt RNG, consume ingredients or apply potion effects. Disclosed estimates must be labelled rather than actual hidden rolls.

Show selected quantities and any service charge before confirmation. Actual pricing, apparatus availability and progression rewards remain explicit profile/service contracts; no default new fee or practice is invented.

Alternative profiles may resolve skill checks/random potency/yield. Resolve actual authorized attempt results once and retain them through technical retry/partial recovery. A genuine new attempt after load follows RULE-001/003 fresh-randomness policy; already resolved saved outcomes cannot reroll. Exact logical resolution point and draw schedule must be specified before implementation; preview cannot stand in for it.

### Output preparation and commitment

Prepare/validate the resolved potion output and its destination before consuming ingredients. Unacceptable destination or required output-definition failure preserves inputs. ITEM owns capacity/container acceptance; no silent floor drop or capacity bypass is added here. Variable-yield profiles must support a checked destination contract for the resolved result without exploiting retry to reroll it.

Commit selected ingredient consumption, declared service charge where applicable, profile outcome/knowledge changes and output once through checked owner operations. Legitimate unmatched/profile failure consumes only as declared and may have no output. Technical/access errors cannot grant free output, lose partial ingredients or masquerade as random failure.

Duplicate confirmation/retry retains same attempt/result identity. Unexpected failure after partial mutation needs explicit retained-progress recovery, not blind refund/recraft that duplicates items. Exact owner preparation/commit/receipts are implementation design, not a mandate for a universal transaction framework. Report success/failure only when the actual outcome is committed truthfully.

## Relevant formulas and parameters

Default matching compares ingredient-type multiplicities, independent of order; matching recipe yields declared output deterministically, unmatched valid mix yields no potion with consumed selected inputs. No universal ingredient limit, potency equation, yield amount, apparatus/skill formula, charge or failure probability is selected. Dynamic profiles explicitly supply supported rules and safe domains; no classic effect-count ceiling is imposed on generated potion payloads by assumption.

## Required data

Recipe/profile ID/version and resolved provenance; canonical quantity requirements; ingredient definition extensions and instance identities/state; staged quantities/source access; character knowledge/property discovery; captured attempt/context/quote; retained random/result facts; resolved output bundle/yield/destination; completed consumption/output/charge/knowledge obligations. Exact schemas/provider compatibility remain dependencies.

## Inputs, outputs and events

Inputs: service/profile access, stage/un-stage/recipe shortcut, preview/confirm, inventory/wagon/context checks, profile resolution and native restore. Outputs: known/estimated/unknown preview, valid/invalid staging, deterministic recipe or resolved dynamic result, one consumed-input/output/failure outcome and optional knowledge/reward under explicit rules. Signals/APIs unselected. Selecting ingredients is neither consumption nor potion drinking.

## Cross-system interactions

MAGIC-001 defines registered effect/recipe validation; MAGIC-006/009 supported payload/stack behavior; MAGIC-014 consumes bottles. ITEM/DATA own ingredient definitions/instances, quantities, output container/stack identity; ECON/services prices/access; NPC/CHAR explicit skill context; TIME/LOC apparatus/environment where profiles use them. RULE-001/003 retain randomness; DATA/MOD resolve schema/profile order. UI respects knowledge and pure preview; SAVE/CORE-013 preserve custom bundles/staging/outcomes without replay.

## Edge cases and failure conditions

- Same ingredient multiset/hashes collide: compare full quantity signatures and resolve ambiguity explicitly, not random recipe selection.
- Repeated ingredients/multiple stacks: consume exact captured quantities once, no dictionary overwrite or duplicate unit selection.
- Wagon inaccessible/protected item: no consumption/substitution or free output; stage flags explain unavailable selection.
- Unknown recipe but valid exact match: succeeds without recipe item; no automatic permanent discovery under default.
- Valid unmatched versus missing provider: former consumes as declared; latter is technical recovery with no ordinary failed-experiment disguise.
- Dynamic different potion payloads share name: preserve contents/provenance, no assumed stack equivalence.
- Random result then destination failure: retain actual result through same-attempt retry; no reroll/free item/partial loss.
- Save/reopen staged mixture: revalidate, no auto-mix, no duplicated inventory reservation/refund.

## Configuration and balancing options

Support alternative recipe/effect-combination models, ingredient extension schemas, matching/knowledge/discovery, numeric output/yield/failure rules, context inputs, eligible ingredients and station profiles. Default remains fixed recipe matching with experimentation/unmatched consumption. Exact schema/hook surface, selector precedence, numeric limits and preview disclosure require explicit validated contracts; broad moddability does not authorize unsafe item mutation or hidden formula fallback. Individual base recipes/potion effects/ingredients still require fixture verification.

## Save/load considerations

Preserve staged exact selections, learned discovery state where profiles define it, generated bottle payload/provenance and coherent committed attempt/result obligations. Restore without mixing, consuming, rerolling resolved outcome or granting output/rewards again. Later content changes use explicit supported migration/compatibility; no ingredient-derived recalculation of existing bottle power.

Save partial attempts only with supported coherent progress; otherwise apply explained safe-boundary admission under CORE/SAVE. Missing required providers/access/state cannot silently delete a generated effect. Stale staged items remain flagged rather than substituted. Exact draft scope, retained random result serialization and item extension migrations remain dependencies. Classic/DFU save import outside scope.

## Technical constraints

Target Godot v4.7.2. Separate fixed recipe identity from matching signature, profile logic from UI staging and generation from drinking. Generated arrays/data must not rely on fixed classic arrangements. Safe versioned extension/property contracts, stable item/attempt identities and checked once-only operations required; exact APIs/storage/commit architecture remain design dependencies. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Default stable recipes match order-independent type quantities without hash/registration-order ambiguity; repeated ingredients work.
2. Experimentation without recipe is allowed, default success deterministic/no permanent discovery, valid unmatched mix consumes/no output while technical failures remain distinct.
3. Mods can define ingredient properties and shared-effect/dynamic potion composition using declared inputs, not merely add fixed recipes.
4. One station-selected profile captures each attempt; generated bottles retain resolved payload/provenance independent of later ingredient changes.
5. Exact staged quantities respect source/item restrictions and persist without consumption; stale access flags rather than substitutes.
6. Output/destination prepares before consumption; committed input/outcome/charge/knowledge changes occur once without free output or partial-loss success.
7. Preview follows knowledge rules with no gameplay RNG/mutation; actual random attempts retain results across technical retry and supported restore.
8. Native staged/custom/knowledge state restores without auto-mix, altered bottle contents or replayed rewards/consumption.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-001/006/010, DATA-003/010/011 ownership, RULE-001/003 and CORE-013 boundaries plus MAGIC-013-D01–D13. No direct contradiction identified. Stable recipes/profile-generated arrays preserve complete supported content while permitting new ingredient metadata; existing item templates remain separate from instance state. Legitimate experimental consumption differs from technical failure and follows exact checked input ownership. Fresh new-attempt randomness does not replace retained results. Broad alternative alchemy capability does not select another game's balance formulas or drinking permissions. Service/ITEM integration remains open, not assumed available.

## Outstanding questions

No further blocking mixing/profile player-policy choice is identified. Before implementation is complete: verify baseline recipes/quantities/output settings; define recipe ambiguity resolution, ingredient extension/state schemas, profile selection/parameter validation, destination/commit recovery, context/RNG capture, knowledge disclosure and service access/pricing; specify generated-bottle stacking and MAGIC-014 consumption contracts, persistent staging scope and native migrations. These deferrals cannot authorize fixed-array truncation, preview knowledge leaks, hash-only identity, ingredient substitution or reroll/duplicate crafting exploits.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-013-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented recipe inventories, ingredient/profile schemas, item/destination and consumption contracts, knowledge/RNG policies and native persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
