# MAGIC feature catalog

Static analysis of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Sources are relative to `Assets/Scripts/Game/MagicAndEffects/`. Symbols follow `#`. Complexity estimates review scope. Confidence rates the sampled source trace.

## MAGIC-001 — Effect registration and discovery

- **Parent subsystem** — Framework
- **Purpose** — Resolve effect keys and crafting availability.
- **Existing implementation** — The broker registers effect templates, maps classic keys and indexes recipe and crafting metadata. It exposes custom registration and optional replacement.
- **Source** — `EntityEffectBroker.cs#RegisterEffectTemplate`, `EntityEffectBroker.cs#MapClassicKey`, `EntityEffectBroker.cs#InstantiateEffect`
- **Inputs and outputs** — Template, key and replacement option → registered or instantiated effect
- **Dependencies** — MOD, DATA-011
- **Edge cases and interactions** — Verify collision behavior for string keys, classic keys and recipes.
- **Design questions** — Which identifiers and metadata must remain stable?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-08 under MAGIC-001-A01; specification: `docs/design/systems/MAGIC/MAGIC-001.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-002 — Classic spell conversion

- **Parent subsystem** — Framework
- **Purpose** — Translate original spell records to runtime settings.
- **Existing implementation** — The broker converts classic targets, elements and effect records to bundle entries. AllEffectsImplemented exposes a separate compatibility check.
- **Source** — `EntityEffectBroker.cs#ClassicSpellRecordDataToEffectBundleSettings`, `EntityEffectBroker.cs#ClassicEffectRecordToEffectEntry`, `EntityEffectBroker.cs#AllEffectsImplemented`
- **Inputs and outputs** — Classic record and bundle type → settings and compatibility result
- **Dependencies** — DATA-011, RULE-018
- **Edge cases and interactions** — Use fixtures for unmapped keys, duplicate classic IDs and unsupported combinations.
- **Design questions** — How should a partially supported spell be represented?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-002-A01; specification: `docs/design/systems/MAGIC/MAGIC-002.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-003 — Ready spell and affordability

- **Parent subsystem** — Casting
- **Purpose** — Prepare a spell before release.
- **Existing implementation** — SetReadySpell checks silence unless free, rejects a cast in progress and invalid version, computes cost and enforces affordability for the player except free or god mode. Caster-only spells mark instant cast.
- **Source** — `EntityEffectManager.cs#SetReadySpell`, `EntityEffectManager.cs#AbortReadySpell`
- **Inputs and outputs** — Bundle, caster, magicka and free flag → ready state or rejection
- **Dependencies** — CHAR-018, RULE-018, COMBAT-001
- **Edge cases and interactions** — Enemy affordability differs. By default the cost path can use player skills for enemies.
- **Design questions** — Should cost be committed at readying or recomputed at release?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-003-A01; specification: `docs/design/systems/MAGIC/MAGIC-003.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-004 — Cast execution and history

- **Parent subsystem** — Casting
- **Purpose** — Commit resources and dispatch a ready spell.
- **Existing implementation** — Animated player casts deduct magicka and wait for a release-frame handler. Enemy release has a separate path. CastNoAnimSpell assigns self or launches payload and clears last spell. The manager also tallies effect skills for player ready spells.
- **Source** — `EntityEffectManager.cs#CastReadySpell`, `EntityEffectManager.cs#CastNoAnimSpell`, `EntityEffectManager.cs#PlayerSpellCasting_OnReleaseFrame`, `EntityEffectManager.cs#TallyPlayerReadySpellEffectSkills`, `../FPSSpellCasting.cs`
- **Inputs and outputs** — Ready bundle and release event → payment, effect delivery and cast state
- **Dependencies** — COMBAT, CHAR-012, AV, UI
- **Edge cases and interactions** — Check interruptions after payment, no-animation recast and repeated release events.
- **Design questions** — What should cancel a paid cast or qualify for practice?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-004-A01; specification: `docs/design/systems/MAGIC/MAGIC-004.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-005 — Touch, projectile and area targeting

- **Parent subsystem** — Casting
- **Purpose** — Find recipients for spell payloads.
- **Existing implementation** — Player touch checks range before animated casting. DaggerfallMissile supplies contact and area targeting and assigns payloads to selected entities. Self casts can apply directly.
- **Source** — `EntityEffectManager.cs#CastReadySpell`, `EntityEffectManager.cs#InstantiateSpellMissile`, `../DaggerfallMissile.cs#DoAreaOfEffect`, `../DaggerfallMissile.cs#AssignPayloadToTargets`
- **Inputs and outputs** — Aim, target type, element and collision → target recipients
- **Dependencies** — COMBAT-014, MOVE-018, NPC, AV
- **Edge cases and interactions** — Verify aim changes before release, blockers and caster inclusion per mode.
- **Design questions** — Should range and line of sight be checked again at release?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-005-A01; specification: `docs/design/systems/MAGIC/MAGIC-005.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-006 — Bundle admission and chance

- **Parent subsystem** — Framework
- **Purpose** — Instantiate effects for a recipient.
- **Existing implementation** — AssignBundle copies settings and provenance, creates effects from keys, skips unknown effects, checks hard disease/paralysis immunity, starts each eligible effect and applies on-cast chance and non-magnitude saves. Accepted effects receive an initial magic round.
- **Source** — `EntityEffectManager.cs#AssignBundle`, `EntityEffectBundle.cs`, `LiveEffectBundle.cs`, `EntityEffect.cs`
- **Inputs and outputs** — Source bundle and bypass flags → active effects and notifications
- **Dependencies** — CHAR, RULE-017, MOD
- **Edge cases and interactions** — Missing effects can yield partial application. Self-cast and magnitude paths differ in save handling. Start occurs before later checks.
- **Design questions** — Which admission steps may produce side effects?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-006-A01; specification: `docs/design/systems/MAGIC/MAGIC-006.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-007 — Absorption, reflection and resistance

- **Parent subsystem** — Framework
- **Purpose** — Intercept incoming spell effects.
- **Existing implementation** — Caster-backed spell assignment attempts absorption, then reflection and resistance. Absorption tallies refund per effect and caps applicable self-cast refunds. Reflection tracks a count to prevent repeat reflection.
- **Source** — `EntityEffectManager.cs#AssignBundle`, `EntityEffectManager.cs#TryReflection`, `Effects/Restoration/SpellAbsorption.cs`, `Effects/Thaumaturgy/SpellReflection.cs`, `Effects/Thaumaturgy/SpellResistance.cs`
- **Inputs and outputs** — Spell, caster and defenses → refund, rerouting or prevention
- **Dependencies** — RULE-017, CHAR-018, COMBAT
- **Edge cases and interactions** — Saving-throw bypass gates reflection/resistance in this path, while absorption has a separate condition. Test mixed bundles.
- **Design questions** — Should defenses apply to individual effects or to the whole spell?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-007-A01; specification: `docs/design/systems/MAGIC/MAGIC-007.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-008 — Magic rounds and elapsed time

- **Parent subsystem** — Framework
- **Purpose** — Advance effects with game time.
- **Existing implementation** — The broker raises a magic round per game minute, including during pause when game time moves. It skips loading and caps catch-up at two days. It publishes a synthetic-time completion event.
- **Source** — `EntityEffectBroker.cs#Update`, `EntityEffectBroker.cs#InitMagicRoundTimer`, `EntityEffectManager.cs#DoMagicRound`
- **Inputs and outputs** — Clock delta and load state → round and time events
- **Dependencies** — TIME, SAVE, CORE-016
- **Edge cases and interactions** — Long jumps discard excess generic rounds. Diseases and poisons have their own elapsed-time paths.
- **Design questions** — Which effects must account for the full elapsed interval?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-008-A01; specification: `docs/design/systems/MAGIC/MAGIC-008.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-009 — Incumbents, constant effects and expiration

- **Parent subsystem** — Framework
- **Purpose** — Manage overlapping and persistent effects.
- **Existing implementation** — The manager runs constant effects, merges entity modifiers and removes expired bundles. Incumbent effects have effect-specific merging. Concealment, for example, adds duration to the incumbent.
- **Source** — `IncumbentEffect.cs`, `EntityEffectManager.cs#DoConstantEffects`, `EntityEffectManager.cs#UpdateEntityMods`, `EntityEffectManager.cs#RemoveBundle`, `Effects/Illusion/ConcealmentEffect.cs`
- **Inputs and outputs** — Live bundles, sources and duration → modifiers, refresh or cleanup
- **Dependencies** — CHAR-011, ITEM, UI
- **Edge cases and interactions** — Held items and zero-duration effects can have distinct lifetimes. Verify reapplication and cleanup order by family.
- **Design questions** — Which recasts extend, replace or stack?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-009-A01; specification: `docs/design/systems/MAGIC/MAGIC-009.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-010 — Effect persistence and HUD state

- **Parent subsystem** — Framework
- **Purpose** — Restore active magic and represent its status.
- **Existing implementation** — The manager exports instanced bundle and effect records, restores instances through Resume, and exposes active-spell icon updates and lifecycle events.
- **Source** — `EntityEffectManager.cs#GetInstancedBundlesSaveData`, `EntityEffectManager.cs#RestoreInstancedBundleSaveData`, `EntityEffectManager.cs#UpdateHUDSpellIcons`, `EntityEffectManager.cs#RaiseOnRemoveBundle`
- **Inputs and outputs** — Saved keys, rounds, caster identity and effect data → live state and display
- **Dependencies** — SAVE, UI, MOD
- **Edge cases and interactions** — Test missing caster, missing template and restored equipped sources. Effect-specific save fields need fixtures.
- **Design questions** — Which effect state is authoritative on reload?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-010-A01; specification: `docs/design/systems/MAGIC/MAGIC-010.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-011 — Spellbook and spell offers

- **Parent subsystem** — Spell services
- **Purpose** — Present owned and available bundles.
- **Existing implementation** — Entities expose spell list access, sorting and serialization. The spellbook is a UI entry point. Custom spell offers are indexed by usage for eligible services.
- **Source** — `../Entities/DaggerfallEntity.cs#GetSpells`, `../Entities/DaggerfallEntity.cs#SortSpellsPointCost`, `../UserInterfaceWindows/DaggerfallSpellBookWindow.cs`, `EntityEffectBroker.cs#RegisterCustomSpellBundleOffer`
- **Inputs and outputs** — Owned bundles, offered bundles and usage → selection lists
- **Dependencies** — UI, ECON, MOD, SAVE
- **Edge cases and interactions** — Verify item dependency, spell purchase and selection behavior in the service windows.
- **Design questions** — How should learned, innate and item-based spells be distinguished?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-011-A01; specification: `docs/design/systems/MAGIC/MAGIC-011.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-012 — Spellmaking

- **Parent subsystem** — Spell services
- **Purpose** — Compose a spell from supported effects.
- **Existing implementation** — The spellmaker uses effect templates and settings to compose a bundle. The broker exposes crafting-station-filtered effects and FormulaHelper computes resource costs.
- **Source** — `../UserInterfaceWindows/DaggerfallSpellMakerWindow.cs`, `EntityEffectBroker.cs#GetEffectTemplates`, `../Formulas/FormulaHelper.cs#CalculateTotalEffectCosts`
- **Inputs and outputs** — Effects, parameters, target, element and cost → custom bundle
- **Dependencies** — UI, ECON, RULE-018, MOD
- **Edge cases and interactions** — Confirm incompatible combinations, pricing, max effect count and duplicate handling in UI.
- **Design questions** — Which effects and parameters should players be able to combine?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-012-A01; specification: `docs/design/systems/MAGIC/MAGIC-012.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-013 — Potion recipes and mixing

- **Parent subsystem** — Crafting
- **Purpose** — Turn ingredients into potion items.
- **Existing implementation** — The broker indexes recipe variants by effect and recipe key. The potion maker stages ingredients in a cauldron and has a dedicated mixing path.
- **Source** — `PotionRecipe.cs`, `EntityEffectBroker.cs#GetPotionRecipe`, `../UserInterfaceWindows/DaggerfallPotionMakerWindow.cs#MixCauldron`
- **Inputs and outputs** — Recipe or ingredient selection → potion crafting outcome
- **Dependencies** — ITEM, ECON, UI, MOD
- **Edge cases and interactions** — Verify duplicate recipes, missing ingredients and whether failed mixing consumes them.
- **Design questions** — Should recipes be discovered, supplied or inferred?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-013-A01; specification: `docs/design/systems/MAGIC/MAGIC-013.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-014 — Potion consumption

- **Parent subsystem** — Crafting
- **Purpose** — Apply a potion as an effect bundle.
- **Existing implementation** — DrinkPotion applies its bundle using saving-throw and chance bypass flags.
- **Source** — `EntityEffectManager.cs#DrinkPotion`, `EntityEffectManager.cs#AssignBundle`
- **Inputs and outputs** — Potion item and recipient → applied bundle
- **Dependencies** — ITEM, CHAR, MAGIC-006
- **Edge cases and interactions** — Separate bypass rules from hard immunity. Trace depletion and invalid potion data in ITEM.
- **Design questions** — Which potion effects should ignore resistance?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-09 under MAGIC-014-A01; specification: `docs/design/systems/MAGIC/MAGIC-014.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-015 — Enchantment creation and capacity

- **Parent subsystem** — Crafting
- **Purpose** — Combine item powers with constraints.
- **Existing implementation** — ItemMaker filters eligible items, enumerates enchantments, adds forced powers or side effects and has an explicit enchant confirmation path. Item enchantment power uses shared formulas.
- **Source** — `../UserInterfaceWindows/DaggerfallItemMakerWindow.cs#EnumerateEnchantments`, `../UserInterfaceWindows/DaggerfallItemMakerWindow.cs#SortForcedEnchantments`, `../UserInterfaceWindows/DaggerfallItemMakerWindow.cs#EnchantButton_OnMouseClick`, `../Formulas/FormulaHelper.cs#GetItemEnchantmentPower`
- **Inputs and outputs** — Item, powers, side effects and capacity → enchanted item outcome
- **Dependencies** — ITEM, RULE-018, ECON, UI
- **Edge cases and interactions** — Check forced effect conflicts, existing enchantments and cost boundaries.
- **Design questions** — How should powers, drawbacks and capacity trade off?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-015-A01; specification: `docs/design/systems/MAGIC/MAGIC-015.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-016 — Enchanted item triggers

- **Parent subsystem** — Crafting
- **Purpose** — Run held, used, striking and periodic item payloads.
- **Existing implementation** — The manager dispatches enchantment payloads and has distinct paths for equipped/held, unequip, use, broken items and magic-round callbacks. CastWhenHeld, Used and Strikes implement different triggers.
- **Source** — `EntityEffectManager.cs#DoItemEnchantmentPayloads`, `EntityEffectManager.cs#StartHeldItem`, `EntityEffectManager.cs#UnequipHeldItem`, `EntityEffectManager.cs#BrokenItem`, `Effects/Enchanting/CastWhenHeld.cs`, `Effects/Enchanting/CastWhenUsed.cs`, `Effects/Enchanting/CastWhenStrikes.cs`
- **Inputs and outputs** — Item, trigger flags and target context → spell or item effect
- **Dependencies** — ITEM, COMBAT-011, SAVE, MOD
- **Edge cases and interactions** — Audit callback order on breakage, re-equip and load. Effects may modify physical damage.
- **Design questions** — Which triggers should consume condition or charges?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-016-A01; specification: `docs/design/systems/MAGIC/MAGIC-016.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-017 — Immediate and ongoing damage

- **Parent subsystem** — Health effects
- **Purpose** — Damage health, fatigue or magicka through effects.
- **Existing implementation** — Destruction contains distinct damage and continuous-damage effects. Health damage executes through MagicRound. Magnitude effects use the later magnitude/save path described by AssignBundle.
- **Source** — `Effects/Destruction/DamageHealth.cs#MagicRound`, `Effects/Destruction/ContinuousDamageHealth.cs`, `Effects/Destruction/DamageFatigue.cs`, `Effects/Destruction/DamageSpellPoints.cs`, `EntityEffectManager.cs#AssignBundle`
- **Inputs and outputs** — Effect settings and recipient → damage to selected resource
- **Dependencies** — RULE-017, COMBAT, CHAR-018
- **Edge cases and interactions** — Verify initial versus recurring ticks and lethal multi-effect ordering.
- **Design questions** — Should initial and periodic damage use the same mitigation?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-017-A01; specification: `docs/design/systems/MAGIC/MAGIC-017.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-018 — Healing, regeneration and fortification

- **Parent subsystem** — Health effects
- **Purpose** — Restore resources or raise effective attributes.
- **Existing implementation** — Restoration separates healing, recurring regeneration and fortification. The manager exposes attribute healing and merges temporary stat and maximum modifiers.
- **Source** — `Effects/Restoration/HealEffect.cs`, `Effects/Restoration/HealHealth.cs`, `Effects/Restoration/Regenerate.cs`, `Effects/Restoration/FortifyEffect.cs`, `EntityEffectManager.cs#HealAttribute`, `EntityEffectManager.cs#MergeStatMaxMods`
- **Inputs and outputs** — Effect settings and current state → restoration or live modifier
- **Dependencies** — CHAR-011, CHAR-018, RULE
- **Edge cases and interactions** — Verify over-cap behavior and what remains when fortification expires.
- **Design questions** — Which boosts should modify capacity versus current values?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-018-A01; specification: `docs/design/systems/MAGIC/MAGIC-018.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-019 — Drain and transfer

- **Parent subsystem** — Health effects
- **Purpose** — Reduce capabilities or transfer resources.
- **Existing implementation** — Destruction separates drain and transfer families from direct damage. Variants target named attributes or vital resources.
- **Source** — `Effects/Destruction/DrainEffect.cs`, `Effects/Destruction/TransferEffect.cs`, `Effects/Destruction/TransferHealth.cs`, `Effects/Destruction/VampiricFortifyEffect.cs`
- **Inputs and outputs** — Caster, recipient, resource and effect parameters → drained or transferred amount
- **Dependencies** — CHAR, COMBAT, RULE-017
- **Edge cases and interactions** — Confirm permanent versus temporary deltas, caster absence and effect termination per variant.
- **Design questions** — When should a transfer conserve the amount lost?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-019-A01; specification: `docs/design/systems/MAGIC/MAGIC-019.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-020 — Poison lifecycle

- **Parent subsystem** — Health effects
- **Purpose** — Track a poison independently of ordinary duration.
- **Existing implementation** — PoisonEffect controls forced remaining rounds, processes magic rounds and saves its own state. The manager creates poison bundles and exposes cure-all handling.
- **Source** — `Effects/Poisons/PoisonEffect.cs#MagicRound`, `Effects/Poisons/PoisonEffect.cs#GetSaveData`, `EntityEffectManager.cs#CreatePoison`, `EntityEffectManager.cs#CureAllPoisons`
- **Inputs and outputs** — Poison type and time → ongoing poison state or cure
- **Dependencies** — COMBAT, CHAR, TIME, SAVE
- **Edge cases and interactions** — Verify elapsed-time jumps, duplicate poisons and weapon consumption at COMBAT-011.
- **Design questions** — What should determine onset, intensity and antidote scope?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-020-A01; specification: `docs/design/systems/MAGIC/MAGIC-020.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-021 — Disease and cure lifecycle

- **Parent subsystem** — Health effects
- **Purpose** — Apply infection, progression and cleanup.
- **Existing implementation** — DiseaseEffect keeps forced duration and effect-specific save data. The manager creates disease bundles, checks hard immunity and exposes disease cures. Special infections can bypass the hard disease gate.
- **Source** — `Effects/Diseases/DiseaseEffect.cs#MagicRound`, `Effects/Diseases/DiseaseEffect.cs#GetSaveData`, `EntityEffectManager.cs#CreateDisease`, `EntityEffectManager.cs#CureAllDiseases`, `EntityEffectManager.cs#AssignBundle`
- **Inputs and outputs** — Disease definition and elapsed time → illness, penalties or cure
- **Dependencies** — CHAR, TIME, SAVE, COMBAT
- **Edge cases and interactions** — Compare individual diseases, immunity and whether curing restores existing losses.
- **Design questions** — Should a cure remove symptoms, permanent damage or both?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-021-A01; specification: `docs/design/systems/MAGIC/MAGIC-021.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-022 — Paralysis, silence and magical defense

- **Parent subsystem** — World and control
- **Purpose** — Alter allowed actions and protect the recipient.
- **Existing implementation** — Paralyze has a separate hard-immunity path. Silence gates readying and release. Free Action, cure, shield and elemental resistance are separate effect templates.
- **Source** — `Effects/Alteration/Paralyze.cs`, `Effects/Mysticism/Silence.cs`, `Effects/Restoration/FreeAction.cs`, `Effects/Restoration/CureParalyzation.cs`, `Effects/Alteration/Shield.cs`, `Effects/Alteration/ElementalResistance.cs`, `EntityEffectManager.cs#CastReadySpell`
- **Inputs and outputs** — Effect and recipient state → action restriction or defense
- **Dependencies** — MOVE, COMBAT, CHAR, MAGIC-007
- **Edge cases and interactions** — God mode and free casts have explicit exceptions in sampled manager paths. Verify immunity/cure ordering.
- **Design questions** — Which restrictions should cancel queued actions?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-022-A01; specification: `docs/design/systems/MAGIC/MAGIC-022.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-023 — Magical traversal

- **Parent subsystem** — World and control
- **Purpose** — Change movement or survival in traversal modes.
- **Existing implementation** — Separate effects expose levitation, water walking/breathing, slowfall, jumping and climbing. MOVE consumes movement flags and modified capability.
- **Source** — `Effects/Thaumaturgy/Levitate.cs`, `Effects/Thaumaturgy/WaterWalking.cs`, `Effects/Alteration/WaterBreathing.cs`, `Effects/Alteration/Slowfall.cs`, `Effects/Alteration/Jumping.cs`, `Effects/Alteration/Climbing.cs`
- **Inputs and outputs** — Active traversal effect → locomotion or hazard modifier
- **Dependencies** — MOVE-009, MOVE-011, MOVE-013, MOVE-015, CHAR
- **Edge cases and interactions** — Test expiry midair or underwater and overlap between effects.
- **Design questions** — How should movement recover when an effect ends?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-023-A01; specification: `docs/design/systems/MAGIC/MAGIC-023.md`. Documented technical and cross-owner dependencies remain open.

### My Intended Specification

## MAGIC-024 — Recall anchor and teleport

- **Parent subsystem** — World and control
- **Purpose** — Store a destination and return to it.
- **Existing implementation** — Teleport has a dedicated start/end lifecycle and custom save data for its persistent state. Its interaction is presented through the teleport popup.
- **Source** — `Effects/Mysticism/Teleport.cs#Start`, `Effects/Mysticism/Teleport.cs#GetSaveData`, `Effects/Mysticism/Teleport.cs#RestoreSaveData`, `../UserInterfaceWindows/DaggerfallTeleportPopUp.cs`
- **Inputs and outputs** — Recall interaction and world context → anchor or repositioning request
- **Dependencies** — LOC, WORLD, MOVE-027, SAVE, UI
- **Edge cases and interactions** — Verify restrictions and invalid anchors across dungeons and replaced locations.
- **Design questions** — Which contexts may set or use an anchor?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-024-A01; MAGIC-024-D01–D09 confirmed. Specification: `docs/design/systems/MAGIC/MAGIC-024.md`.

### My Intended Specification

Confirmed: one replaceable, successful-use-consumed anchor by default; moddable limits/consumption; cross-context recall without default combat/distance restrictions; moddable restrictions; paid post-cast choice with no refund for cancel/no anchor. Destination validity follows MOVE-027. Failed arrival retains anchor without automatic cast refund; safe departure/recovery required. Anchor persists through saves/rest/travel with stable destination identity and mod expiry/invalidation. Successful Recall restores pose with fresh movement history and current destination conditions, retaining ongoing effects rather than old character state; alternative mod handoffs supported. See `docs/design/GAMEPLAY_DECISIONS.md`.

## MAGIC-025 — Concealment, detection and light

- **Parent subsystem** — World and control
- **Purpose** — Change visibility or reveal targets.
- **Existing implementation** — ConcealmentEffect applies persistent state and handles incumbent duration. Normal-power concealment has an explicit break helper. Detection and light are separate effect families.
- **Source** — `Effects/Illusion/ConcealmentEffect.cs`, `EntityEffectManager.cs#BreakNormalPowerConcealmentEffects`, `Effects/Thaumaturgy/DetectEffect.cs`, `Effects/Illusion/LightNormal.cs`, `Effects/Illusion/MageLight.cs`
- **Inputs and outputs** — Effect family, duration and world state → visibility flags, detection or lighting
- **Dependencies** — NPC, AV, LOC, UI
- **Edge cases and interactions** — Verify normal versus true power, reveal targets and scene/light lifetime.
- **Design questions** — Which actions should break concealment?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-025-A01; MAGIC-025-D01–D13 confirmed. Specification: `docs/design/systems/MAGIC/MAGIC-025.md`.

### My Intended Specification

Confirmed: distinct Normal/True Invisibility, Chameleon and Shadow, moddable perception/break rules; source-owned contributions and compatible duration extension; explicit nonmultiplicative family composition; detection/light independent from concealment with explicit mod connections. Accepted hostile magic and COMBAT-011 positive-D0 physical hits break eligible Normal sources. Default illusion priority Invisibility then Chameleon 8% pass then Shadow 4%, with moddable counters/composition. Detection defaults to current-world 14-reference-unit through-wall compass direction, DFU categories and independent query cadence. Explicit mod support for Life/Undead categories and through-wall shaders/silhouettes/representations independently of compass UI. Illumination and remaining lifecycle policies remain under review. See `docs/design/GAMEPLAY_DECISIONS.md`.

## MAGIC-026 — Charm, pacification and language

- **Parent subsystem** — World and control
- **Purpose** — Change social or targeting behavior through magic.
- **Existing implementation** — Charm, Pacify and Comprehend Languages are distinct effects. Their downstream behavior depends on actor and interaction systems.
- **Source** — `Effects/Thaumaturgy/CharmEffect.cs`, `Effects/Thaumaturgy/PacifyEffect.cs`, `Effects/Mysticism/ComprehendLanguages.cs`
- **Inputs and outputs** — Effect and affected actor → temporary behavior or language change
- **Dependencies** — NPC, COMBAT, FACT
- **Edge cases and interactions** — Audit eligibility, target allegiance and cleanup after expiry.
- **Design questions** — Which actors can be influenced and how does hostility resume?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-026-A01; MAGIC-026-D01–D12 confirmed. Specification: `docs/design/systems/MAGIC/MAGIC-026.md`.

### My Intended Specification

Confirmed: Charm/Pacify default lasting nonhostility with original target category distinctions, not control/disposition; explicit hostility events may end it. Moddable eligibility, duration, break/scope and social/control alternatives. Comprehend Languages timed encounter-language bonus with compatible extension and moddable formula/translation uses, not permanent skill. Combat handoff, break predicates and language details remain under review. See `docs/design/GAMEPLAY_DECISIONS.md`.

## MAGIC-027 — Object utility, soul capture and dispelling

- **Parent subsystem** — World and control
- **Purpose** — Apply specialized magic interactions.
- **Existing implementation** — Open and Lock bridge to activation. Identify, CreateItem and SoulTrap have dedicated templates. DispelMagic inspects effect bundles, with separate undead/Daedra dispels.
- **Source** — `Effects/Mysticism/Open.cs`, `Effects/Mysticism/Lock.cs`, `Effects/Thaumaturgy/Identify.cs`, `Effects/Mysticism/CreateItem.cs`, `Effects/Mysticism/SoulTrap.cs`, `Effects/Mysticism/DispelMagic.cs#MagicRound`
- **Inputs and outputs** — Object, item, target or active bundle → specialized utility result
- **Dependencies** — MOVE-020, MOVE-021, ITEM, NPC
- **Edge cases and interactions** — These are separate review candidates once target restrictions and implementation coverage are traced. Template existence alone cannot establish full behavior.
- **Design questions** — Which world and item operations should be available as spell effects?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-027-A01; MAGIC-027-D01–D24 confirmed. Specification: `docs/design/systems/MAGIC/MAGIC-027.md`.

### My Intended Specification

Confirmed: persistent one-use Open/Lock with captured power and explicit item exceptions; deferred per-batch Identify; temporary data-driven Create Item; lethal-attempt Soul Trap with scoped containers, ordered caster claims and no-container 1-health outcome; selected-bundle Dispel Magic with persisted item suppression; nearby Undead/Daedra banishment without ordinary death rewards and with quest protection. Mod alternatives, owner-safe cleanup and native persistence specified in Draft v1. See `docs/design/GAMEPLAY_DECISIONS.md`.

## MAGIC-028 — Vampirism infection and curse

- **Parent subsystem** — Special states
- **Purpose** — Model infection and persistent vampire identity.
- **Existing implementation** — The manager creates separate disease and curse bundles. VampirismEffect provides live race override, feeding callback, rest/travel checks, quest hooks and custom save state.
- **Source** — `EntityEffectManager.cs#CreateVampirismDisease`, `EntityEffectManager.cs#CreateVampirismCurse`, `Effects/Special/VampirismEffect.cs#OnWeaponHitEntity`, `Effects/Special/VampirismEffect.cs#CheckStartRest`, `Effects/Special/VampirismEffect.cs#GetSaveData`
- **Inputs and outputs** — Infection, clan and player activity → curse, feeding and restrictions
- **Dependencies** — CHAR-019, QUEST, FACT, TIME, COMBAT
- **Edge cases and interactions** — Verify incubation, clan, cure and classic save restoration with fixtures.
- **Design questions** — Which restrictions and grants should vary by clan?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-028-A01; MAGIC-028-D01–D19 confirmed. Specification: `docs/design/systems/MAGIC/MAGIC-028.md`.

### My Intended Specification

Confirmed: 72-hour curable infection, 24-hour hidden-warning milestone, retained infection-region clan, two-week apparent-death/night cemetery transition; source-owned vampire grants, scoped cleanup, feeding/hazards/travel/rest rules and dedicated cure with explicit quest consequences. Native persistence and mod-added transformation conditions/forms beyond vampire/lycanthrope explicitly required under CHAR-019. See Draft v1 and `docs/design/GAMEPLAY_DECISIONS.md`.

## MAGIC-029 — Lycanthropy infection and transformation

- **Parent subsystem** — Special states
- **Purpose** — Model infection and changing werebeast state.
- **Existing implementation** — The manager creates infection and curse bundles. LycanthropyEffect exposes race, weapon presentation, attack and inventory/talk hooks and can suppress crime and population spawns.
- **Source** — `EntityEffectManager.cs#CreateLycanthropyDisease`, `EntityEffectManager.cs#CreateLycanthropyCurse`, `Effects/Special/LycanthropyEffect.cs#MagicRound`, `Effects/Special/LycanthropyEffect.cs#GetSuppressInventory`, `Effects/Special/LycanthropyEffect.cs#GetSaveData`
- **Inputs and outputs** — Infection type, elapsed time and character actions → transformation state and overrides
- **Dependencies** — CHAR-019, NPC, LAW, QUEST, TIME, SAVE
- **Edge cases and interactions** — Compare werewolf/wereboar, cure and save during transformation. Content determines quest outcomes.
- **Design questions** — Which controls and interactions should change while transformed?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-029-A01; MAGIC-029-D01–D18 confirmed. Specification: `docs/design/systems/MAGIC/MAGIC-029.md`.

### My Intended Specification

Confirmed: first-source werewolf/wereboar infection, elapsed 24/72-hour milestones, condition/form separation; 24-hour voluntary entry cooldown, round-based full-moon forcing, no auto-healing; condition bonuses/form restrictions, monthly urge limiter, explicit crime/population policies and Hircine Ring exceptions; scoped cure, chronological advances and native persistence. Mod-added transformations required per MAGIC-028. See Draft v1 and `docs/design/GAMEPLAY_DECISIONS.md`.

## MAGIC-030 — Career passives and artifacts

- **Parent subsystem** — Special states
- **Purpose** — Apply persistent class powers and exceptional item effects.
- **Existing implementation** — The manager has a passive-specials check. Special templates include artifact-specific effects such as Ring of Namira and Oghma Infinium, whose integration points include damage and level rewards.
- **Source** — `EntityEffectManager.cs#PassiveSpecialsCheck`, `Effects/Special/PassiveSpecialsEffect.cs`, `Effects/Special/RingOfNamiraEffect.cs`, `Effects/Special/OghmaInfiniumEffect.cs`
- **Inputs and outputs** — Career flags or artifact trigger → persistent modifiers or exceptional effect
- **Dependencies** — CHAR-005, CHAR-015, COMBAT-011, ITEM
- **Edge cases and interactions** — Inventory remaining artifact templates and distinguish implementation from partial effects per item.
- **Design questions** — Which artifact rules need independent design review?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10 under MAGIC-030-A01; MAGIC-030-D01–D30 confirmed. Specification: `docs/design/systems/MAGIC/MAGIC-030.md`.

### My Intended Specification

Confirmed: source-owned periodic passives and shared hazards; explicit environmental magery capacity rules; individually reviewed Namira, Oghma, Mace, Masque, Razor, Rose, Skull, Wabbajack and Star profiles with costs/targets/lifecycle and no-replay persistence. Mod-added artifacts supported through validated contracts. See Draft v1 and `docs/design/GAMEPLAY_DECISIONS.md`.

## Classic inheritance and review sequence

- Classic spell records provide IDs and parameters. DFU defines the converter, compatibility checks, live-effect lifecycle and mod registrations. Source comments describe the enemy affordability exception as classic-compatible. RULE-017 records the explicit DFU deviation in mixed career tolerances.
- Review MAGIC-003 through MAGIC-010 with one self cast, one touch cast, and a mixed ranged spell facing absorption, reflection and resistance. Include elapsed time and save/reload. Then review potion and item triggers, followed by disease, transformation and utility fixtures.
- Coverage includes the broker, effect manager, casting and crafting entry points and representative effect families. Utility and artifact groups are candidates for finer review by concrete effect. Unsupported classic records, individual effect formulas, Unity assets and timing, effective mod combinations, and parity with original execution remain unverified.
