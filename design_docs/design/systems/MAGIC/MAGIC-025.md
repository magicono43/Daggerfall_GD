# MAGIC-025 — Concealment, detection and light

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose and intended player experience

Change how actors are perceived, sense nearby eligible subjects and illuminate surroundings through independent magical capabilities. Preserve distinct Normal/True concealment and compass-based detection defaults while supporting modded perception, Life/Undead detection and through-wall visual representations.

## Confirmed requirements

MAGIC-025-D01–D13 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews and the user's explicit Life/Undead shader-detection request. The complete specification is approved under MAGIC-025-A01. COMBAT-011's positive initial physical damage trigger, MAGIC-006–010 admission/source/timing/persistence and NPC-owned perception remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths relative to reference `Assets/Scripts/`:

- `Game/MagicAndEffects/Effects/Illusion/ConcealmentEffect.cs` applies/removes entity flags, extends incumbent rounds and rebuilds on Resume. Invisibility/Chameleon/Shadow each define Normal/True flags. `Game/MagicAndEffects/EntityEffectManager.cs#BreakNormalPowerConcealmentEffects` ends the three Normal families, leaving True untouched.
- `Game/EnemySenses.cs#BlockedByIllusionEffect` permits configured enemies to see through concealment; otherwise Invisibility blocks this check, Chameleon permits an 8% pass and Shadow a 4% pass. Chameleon takes priority when both latter families are present. These are illusion gates, not total detection odds.
- `Game/WeaponManager.cs` and `Game/EnemyAttack.cs` break ordinary concealment on positive calculated physical damage. `Game/Entities/DaggerfallEntityBehaviour.cs#HandleAttackFromSource` also breaks the source's Normal concealment through shared damage routes. Target hostile-control policy below is a confirmed design choice, not proof every DFU control effect uses that path.
- `Game/MagicAndEffects/Effects/Thaumaturgy/DetectEnemy.cs`, `DetectMagic.cs` and `DetectTreasure.cs` register compass detectors, extend compatible duration and update results on magic rounds. `Internal/PlayerGPS.cs#GetNearbyObjects` defaults to distance <14 reference units and has no line-of-sight filter. Comments say its range is not matched to classic.
- `PlayerGPS.GetEntityFlags` classifies enemy-class/monster actors as Enemy and actors with active effects as Magic; `GetLootFlags` classifies nonempty loot containers as Treasure. The source explicitly expresses uncertainty about Magic and Treasure criteria. `Game/UserInterface/HUDCompass.cs` draws directional markers from results.
- `Game/MagicAndEffects/Effects/Illusion/LightNormal.cs` creates a player-following candle and extends compatible duration. Its 1.4-unit forward placement avoids some wall problems but does not implement its suggested collision-aware spring. `MagicCandleBehaviour.cs` disables candle collision so it cannot block spells. `MageLight.cs` is an example custom colored-glow effect with five variants, not proof these are baseline registered content.

Static inspection only; no runtime/classic-parity verification. Target current-world detection refresh deliberately differs from magic-round-only result membership.

## Detailed rules and behaviors

### Source ownership, duration and composition

Preserve Invisibility, Chameleon and Shadow as distinct families, each with Normal and True profiles. Compatible recasts extend incumbent duration under MAGIC-009 without duplicate initial gameplay, extra protection multipliers or timer reset. Different families may coexist. Track every surviving contribution so removing one cannot erase another's capability; no single unowned flag clear may defeat surviving sources.

Normal and True use the same default illusion strengths but different breakability. True survives ordinary offensive-action break rules. Explicit dispel, expiry or source removal still applies under its own contract; True does not mean permanent or universally immune. Effect/spell/actor profiles may override perception strength, counters, composition and break conditions with validated policy selection.

### Concealment perception

For an observer without a configured see-through counter, default illusion-check priority is Invisibility, then Chameleon, then Shadow. Invisibility blocks the illusion gate. Chameleon permits 8% passing the gate; otherwise Shadow permits 4%. Coexisting Chameleon and Shadow use the Chameleon check, even though its protection is weaker. Do not multiply independent source/family probabilities. Normal and True of the same family do not create extra rolls.

An enemy's see-through capability bypasses this illusion gate, not walls, ordinary sight/detection requirements or other sensory rules. NPC owns when checks occur, retained randomness, target acquisition and memory. Exact eligible-time check cadence must be explicit before implementation; frame rate, UI refresh or detector query frequency cannot silently change these odds. Modded counters may be enemy-specific and need not be blanket counters to every family.

Concealment does not grant collision bypass, invulnerability, damage immunity or cancellation of released projectiles. Physical contact and area damage remain possible. It does not automatically erase hostility or last-known position. NPC handles tracking of a now-concealed target; optional explicit mod behaviors may change memory or other capabilities through their owners.

### Offensive break rules

Retain COMBAT-011: positive initial resolved physical formula damage D0 breaks the attacker's eligible Normal concealment even if later strike modifiers reduce physical damage Dp to zero. No preview, miss or repeated per-effect callback may repeat the break operation. Exact placement within COMBAT's committed phases remains its integration dependency.

For magical offense, successfully applying a hostile effect qualifies: damage, drain or hostile control. Casting alone does not. A missed projectile or fully resisted effect does not break concealment through this rule. Use authoritative effect-owner acceptance/application results rather than infer hostility from animation, school or visual impact. Exact result classification for zero-loss accepted effects, redundant control, reflected attribution and item/reactive origins requires explicit integration fixtures; it cannot silently turn a resisted effect into an accepted hostile application.

Healing, buffs, movement, potion drinking and ordinary interaction do not break concealment by default. Mere illumination does not qualify. Mods may change triggers by effect, spell or actor, including different timing or action classes. Break only eligible contributions; True and explicitly protected sources survive. Source-bound powers must obey a declared break/reapplication policy under MAGIC-009/016 rather than accidentally reappear on the next visual rebuild; exact equipment-family policy remains a required dependency.

### Detection query and information

Default Detect Enemy, Detect Magic and Detect Treasure are independent self-centered information capabilities. Default radius is 14 reference units with through-wall sensing and no line-of-sight requirement. Use the inspected strict distance <14 boundary, subject to native-scale fixtures. Results concern eligible subjects in the current loaded gameplay location; do not query undisclosed unloaded locations or discover rooms/map geometry as a side effect.

Default Enemy eligibility means enemy-class/monster actors, regardless of present hostility. It is not a hostility test or universal living-creature detector. Default Magic means actors with active magical effects; enchanted items in containers do not automatically qualify. Default Treasure means nonempty loot containers, including corpse loot. Ownership/access permission does not unlock a detected container. Eligibility updates through authoritative actor/container state; exact dead-actor-to-corpse handoff must avoid stale entity results and uses NPC/ITEM lifecycle contracts.

Default presentation shows compass direction, without automatic names, exact contents, effect details or precise range disclosure. Detection supplies information without dispelling concealment, guaranteeing a hit, granting attack targeting through walls or bypassing ordinary range/geometry rules. Detect Enemy may indicate a qualifying concealed actor without removing its concealment. Detection and Light are independent; neither implicitly grants the other.

Refresh membership from current world state during eligible gameplay independently of the duration clock or magic rounds. Configurable query cadence must respond to movement, actor removal/death, emptied loot and effect removal without retaining stale markers indefinitely. Exact initial refresh/latency and work budgets need fixtures; no new gameplay target cap is approved. Deduplicate equivalent results across overlapping sources without losing distinct category information. Pausing/loading is not extra query-driven gameplay or effect advancement.

### Modded Life/Undead detection and presentation

Explicitly support custom eligibility categories such as Life and Undead, configurable range/obstruction rules and independently selectable presentations. Life/Undead membership uses authoritative actor tags/profiles; exact taxonomy is declared by the mod/NPC data rather than guessed from meshes or current hostility.

Provide a supported way to present eligible results using through-wall shaders, silhouettes, auras or other representations, replacing or accompanying compass markers. A compass-only result contract is insufficient. Renderer-independent detection results must expose enough stable subject/category and authorized representation context for those consumers without requiring each visual mod to duplicate the detection query system.

Through-wall visibility is a deliberate rendering option for detected subjects, not general wall transparency or disclosure of undetected actors. Actor appearance versus generic proxies, colors, occlusion/depth behavior, distance styling and additional information are declared presentation profiles. They do not mutate collision, hostility, spell defenses or targeting. Exact shader/material/overlay API and Godot renderer compatibility remain technical design. This approves extension capability, not new default Life/Undead spells or mandatory Oblivion assets.

Multiple presentation sources must compose and clean up without leaving overwritten materials or permanent highlights. Ending one detector cannot clear another still-eligible presentation. Subject despawn, scene change and session teardown revoke stale representation handles; stable identity must not attach highlights to a reused object identity.

### Illumination

Default Light creates a following magical candle. Compatible recasts extend duration without multiplying brightness or candle count. Color, brightness, range, placement, appearance and composition policies are moddable. Explicit alternatives include an actor-centered glow or a world-placed light with declared location/lifetime ownership; example MageLight variants are not mandatory default spells.

Candle/visual geometry must not block actors, interactions or spell/projectile delivery. Follow placement should avoid obvious embedding/light appearing across a nearby wall through validated AV/LOC placement; exact collision-aware offset, shadows and numerical light profile need representative fixtures. No source prefab intensity/range is approved without inspection/tuning.

Light does not automatically dispel, break or cancel concealment. Explicit NPC environmental-lighting rules may consume authoritative illumination inputs. Mods may make light reveal actors or modify detection chances. Optional graphics/shadow quality cannot change authoritative perception rules; renderer settings are not an alternate gameplay light calculation.

### Restoration and cleanup

Rebuild source-owned concealment, current detection results and eligible lights after native load or scene transitions without recasting, resetting duration, rerolling admission or duplicating emitters/markers. Maintain current effect lifetimes under MAGIC-008/010. A removed source cleans up only its own contribution.

Presentation handles and scene references are derived, not authoritative saved capabilities. Shader cleanup restores compatible presentation state without overwriting another active effect. Optional visual failure does not change authoritative concealment/detection eligibility, consume another cast or replay gameplay; missing required provider/data uses CORE/SAVE recovery. A failed required detection display must be reported rather than represented as a truthful empty-result query.

## Relevant formulas and parameters

Default illusion pass: 0 for Invisibility absent counter, 8% for Chameleon, 4% for Shadow, with priority above and NPC's ordinary remaining gates. Detection membership uses distance <14 reference units and declared category. Query cadence is separate from duration/tick cadence. Compatible duration extension follows MAGIC-009; no new brightness-stacking formula. Native scale, query latency, perception cadence, light range/intensity/offset and mod numeric domains remain validated parameters.

## Required data

Stable actor/source/effect/spell identity; concealment family/tier, surviving contributions, duration and break/counter/composition policy; authoritative offensive acceptance/D0 outcomes and once-only identity; observer counter/perception profile; detector category/filter/range/obstruction/query timing; current subject identity/category and authorized presentation context; light profile/attachment or world placement; provider/schema versions and derived presentation ownership. Concrete APIs, selector precedence and data schemas remain dependencies.

## Inputs, outputs and events

Inputs: admitted effects/source changes, eligible time, physical or magical offensive results, observer checks, current actors/loot/effects/geometry, location changes and restore. Outputs: effective concealment/illusion-gate result, eligible current detection results, source-owned compass/through-wall visual requests, illumination contributions and cleanup. Distinguish query results, gameplay perception decisions and presentation notifications; drawing a marker does not itself detect an actor for NPC AI or authorize an attack. APIs/signals unselected.

## Cross-system interactions

MAGIC-006 admission, MAGIC-008 duration, MAGIC-009 composition/source cleanup, MAGIC-010 persistence/HUD, MAGIC-016 equipment powers and MAGIC-017–022 offensive outcomes; COMBAT-011 D0 break and COMBAT-014 actual spell geometry; NPC sensing/counters/memory/tags/lifecycle; ITEM loot contents/ownership; WORLD/LOC loaded-location queries and light placement; AV/UI compass, shaders and emitters; RULE retained RNG/mod validation; CORE/SAVE reconstruction and provider recovery. NPC perception cadence and item constant-source break lifecycle are required integration work, not automatically approved source accidents.

## Edge cases and failure conditions

Test overlapping Normal/True and equipment/spell sources, Chameleon plus Shadow, see-through enemies behind walls, full resistance, zero actual pool loss, ongoing hostile ticks, reactive/reflected offense, current versus released attack state, moving/out-of-range subjects, death-to-corpse transfer, empty containers, multiple detectors, origin rebase, unavailable visuals and shader cleanup on scene/despawn/load. No preview roll, query cadence change, draw callback or rehydrated source may create repeated offensive breaks or practice awards.

## Configuration and balancing options

Validated effect/spell/actor concealment triggers/strengths/counters/composition; custom detection tags/categories including Life/Undead; range, obstruction and query cadence; compass, shaders/silhouettes/proxies and mixed presentations; illumination profiles and explicit perception coupling. Profiles declare information disclosure and source cleanup. Exact precedence, numeric domains and custom renderer/eligibility adapters must be documented before implementation; broad moddability does not authorize hidden target omission or gameplay mutations from cosmetic callbacks.

## Save/load considerations

Persist actual surviving sources, tier/profile versions, remaining timing and required completed break facts through owners. Reconstruct derived flags, query membership and presentation only after location/actor readiness. Do not serialize stale detection scene pointers or restore obsolete queried positions as current facts. Loading does not repeat cast costs, admission rolls, practice, start rewards or completed break events. Required missing mod profiles use supported migration/recovery; optional visual substitutions must not alter eligibility or lifetime.

## Technical constraints

Target Godot 4.7.2. Separate authoritative source state, NPC perception, spatial eligibility query and optional presentation consumers. Through-wall visuals require supported actor representations and renderer contracts; avoid requiring shader mods to own perception or reimplement detection. Idempotent reconstruction and scoped cleanup are mandatory. No implementation or coding tasks authorized.

## Acceptance criteria

1. Distinct Normal/True families retain source ownership; compatible recasts extend without multipliers or lost surviving sources.
2. Default illusion priority/probabilities and explicit enemy counters operate independently of rendering/query cadence and ordinary NPC sight gates.
3. COMBAT-011 physical D0 and accepted hostile magic break eligible Normal sources; misses/fully resisted magic and benign actions do not; True survives.
4. Concealment grants no collision/damage immunity, projectile cancellation or automatic memory erasure.
5. Default detection uses current-location distance <14 through walls and approved Enemy/Magic/Treasure categories, with directional compass disclosure only.
6. Detection does not dispel concealment, unlock/discover world content or authorize otherwise invalid targeting.
7. Eligible-gameplay refresh independently tracks membership and deduplicates overlapping results; removed subjects do not leave indefinite stale markers.
8. Mods can define Life/Undead categories and through-wall shaders/silhouettes/representations independently of compass presentation and query implementation.
9. Default Light is one following nonblocking candle per compatible incumbent; recasts extend rather than multiply brightness; explicit alternative profiles supported.
10. Light does not automatically cancel concealment; explicit perception coupling uses gameplay data rather than optional graphics quality.
11. Load/scene rebuild preserves remaining durations and current eligibility without duplicate flags/lights/markers, admission rerolls or residual shader highlights.
12. Optional visual failure cannot change authoritative eligibility; required provider/display failures are handled truthfully through appropriate recovery/feedback.

These are future verification criteria; no implementation/runtime tests performed.

## Consistency review

Reviewed against COMBAT-011 and MAGIC-006/008–010/016. Physical D0 break is preserved independently of later health loss; magical hostile admission remains distinct from cast release and resistance. True protection and source stacking remain MAGIC-owned. Detection refresh is deliberately independent of round-based duration and does not cause extra effect ticks. Through-wall information is separate from COMBAT line-of-sight/delivery. Native rebuild is not a fresh grant, and graphics settings do not redefine authoritative perception.

## Outstanding questions and approval

No further blocking player-policy question identified. Required dependencies: perception check cadence/retained rolls; offensive classification/attribution and equipment reapplication policy; detection death/loot lifecycle, scale/query latency and complete spatial collection; mod selector/taxonomy schemas; light numerical/placement fixtures; Godot shader/proxy layering and renderer compatibility; native provider migration/cleanup. These must be resolved consistently with the confirmed defaults before implementation is complete.

The user explicitly approved the complete Draft v1 on 2026-11-10 with “I approve”. This specification is finalized v1 under MAGIC-025-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented integration, tuning and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
