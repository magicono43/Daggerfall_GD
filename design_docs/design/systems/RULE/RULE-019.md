# RULE-019 — Enemy properties and pacification

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Provide explicit enemy group/language/weight definitions, enemy-class health construction and precise language-based pacification checks, separate from NPC eligibility and behavior.

## Intended player experience

Enemy properties follow declared content, including modded creatures. Assigned health remains stable across loading. Live language/Personality, weapon state and approved language effects influence an eligible pacification attempt without hidden percentage rounding. Merely querying an enemy does not reroll or pacify it.

## Confirmed requirements

RULE-019-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve moddable explicit property mappings/absence, once-assigned rolled enemy-class health, moddable 200-outcome pacification, classic weight conversion, positive health domains and one draw even for guaranteed pacification.

CHAR-011 supplies resolved live skills/attributes; RULE-003 owns random sources/results, RULE-004/DATA-003 validated locked definitions/hooks. Player growth under RULE-006 is separate. NPC/COMBAT own encounters, construction scheduling, pacification authorization and hostility consequences.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#GetEnemyEntityEnemyGroup` maps classic creature careers into Animals/Humanoid/Undead/Daedra/None, with comments describing classic differences. `GetEnemyEntityLanguageSkill` maps rogue-type enemy classes to Streetwise, other classes to Etiquette and specific monsters to language skills; unmatched monsters return None.
- `GetEnemyEntityWeightInClassicUnits` adds trunc(carried weight kg×4) to monster definition Weight or humanoid 240 for female/350 otherwise.
- `RollEnemyClassMaxHealth` starts at 10 and adds one uniform inclusive 1..HP-per-level roll for each level. `Game/Entities/EnemyEntity.cs` invokes it in enemy-class construction paths; full initialization/restore routing remains unverified.
- `CalculateEnemyPacification` uses integer skill/10+Personality/5 for Etiquette/Streetwise, otherwise skill+Personality/10. It adds +10 sheathed or −25 drawn plus incumbent Comprehend Languages.ChanceValue, then compares uniform integer 0–199 against the score.
- `Game/EnemySenses.cs` invokes pacification on first encounter under quest/type/language conditions, changes hostility and tallies language practice according to result. Those caller decisions are not automatically approved here.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete mappings/restore/caller behavior and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Classification and language definitions

Retain inspected classic group/language mappings as moddable baseline definitions using stable IDs and explicit classic adapters. Support added-creature mappings and intentional None/no applicable language. Unknown/missing required definitions are errors rather than silent None fallback. A complete mapping fixture must be established before implementation is complete; examples are not substitutes for the inventory.

Classic examples: rats/bats/bears/tigers and specified creatures map to Animals; skeletal warriors/zombies/ghosts/vampires/liches to Undead; listed daedra to Daedra; atronachs intentionally None. Orc variants use Orcish; harpies Harpy; giants/gargoyles Giantish; dragonlings Dragonish; nymphs/lamias Nymph; centaurs Centaurian; imps/dreugh Impish; specified vampires/liches Etiquette. Verify remaining entries from the source rather than treating unlisted examples as absent.

Enemy-class Burglar/Rogue/Acrobat/Thief/Assassin/Nightblade use Streetwise by baseline; other supported classes use Etiquette. Group and language are separate properties. Neither determines faction/team, legal status, sensory hostility or damage-policy tags automatically. NPC owns whether a language-mapped creature can be pacified at all, including quest exclusions.

### Weight

Compute Wclassic=B+trunc(4×I), where I is total valid carried kilograms and B is monster-defined base weight or baseline humanoid 240 for female/350 otherwise. Both terms are classic weight units after conversion; do not treat B as kg or multiply it by four again. Sum carried weight before truncation.

Base weight, body mapping and conversion parameters are moddable through explicit definitions/hooks. New body definitions can supply their own base. Do not infer extra character attribute differences from this weight model. ITEM owns which carried items contribute and their effective weights; COMBAT/MOVE own uses such as knockback. Validate finite nonnegative supported inputs/output and safe conversion, rather than wrap or invent a zero weight.

Weight queries can recompute when inventory changes; they never generate health, loot or pacification attempts. Missing required body/item weight context differs from a valid zero contribution.

### Enemy-class health

For valid integer level L>=1 and class HP parameter H>=1, assign max health M=10+sum(i=1..L) Ui, with independent uniform integer Ui in inclusive 1..H. Validate all ranges/sums/work limits before draws. H=1 consumes one logical draw per level and produces M=10+L.

Roll once when the enemy's creation/construction is authorized, using an explicitly owned NPC-generation purpose under RULE-003. Retain assigned maximum as authoritative state. Viewing, location reconstruction or loading cannot reroll it. Technical retries reuse already resolved draws/assigned results rather than create another enemy health outcome.

This model is for enemy classes, not a universal replacement for authored monster health or player progression. Modded level zero or alternative health formulas require an explicit supported construction policy. Changes after spawn/level scaling need NPC policy; no retroactive reroll is inferred from a level field changing.

### Pacification formula and resolution

For live mapped skill S and live Personality P, baseline raw score C is trunc(S/10)+trunc(P/5) for Etiquette/Streetwise, otherwise S+trunc(P/10). Add weapon-state adjustment +10 sheathed or −25 drawn and the owner-resolved applicable Comprehend Languages contribution E. Preserve separate integer divisions toward zero, including valid negative live skills.

Resolve applicability/stacking of language effects through MAGIC; do not enumerate the same effect twice or infer universal effect stacking from the source's incumbent lookup. Both formula branches, coefficients, weapon adjustments and effect contribution are moddable under explicit contracts. No skill means no authorized language model unless NPC explicitly defines another one; unknown required skill cannot become zero/easy success silently.

Set Q=clamp(C,0,200); draw one uniform integer R in 0..199; success iff R<Q. Probability is Q/200, or Q/2 percent. Use the 200-outcome rule directly instead of rounding Q/2 into RULE-001 integer percentages. This is an explicit half-percent model alongside RULE-001, with RULE-003 ownership and retained outcomes. Guarantees Q=0/200 still consume one logical draw.

Capture coherent current skill/Personality/weapon/effect context at each NPC-authorized attempt. Queries do not authorize attempts or grant practice. NPC defines first-encounter timing, retries, quest exclusions, target constraints, duration of pacification, later hostility and player messaging. A passed probability alone does not commit permanent friendly allegiance or suppress a later attack. CHAR accepts only owner-approved practice reports.

### Customization and inspection

Definitions and explicit RULE-004 hooks support group/language/weight, health and pacification policies. Validate domains, required mappings, positive divisors and supported output semantics under DATA-003; unknown IDs/nonfinite/overflowing values fail explicitly without silent defaults. Hook changes cannot bypass NPC eligibility or mutate the character during a property query.

Inspection/diagnostics may expose resolved properties, health generation inputs and pacification score/probability/result without consuming live draws. If probability is displayed, identify the 200-point score separately from percentage; odd Q yields a half percentage point. Player UI layout/visibility remains NPC/UI scope rather than a new mandatory exact-risk display.

## Relevant formulas and parameters

- Weight Wclassic=B+trunc(4×carried kg); baseline humanoid B=240 female/350 otherwise, monster B=definition.
- Enemy-class M=10+sum L independent rolls Ui~uniform integers [1,H]; L,H>=1.
- Social C=trunc(S/10)+trunc(P/5)+weapon adjustment+E.
- Other-language C=S+trunc(P/10)+weapon adjustment+E.
- Q=clamp(C,0,200); R~uniform integers [0,199]; success R<Q.

Examples: S=50,P=50,sheathed,E=0 gives social score 25 (12.5%) or other-language score 65 (32.5%). Drawn reduces either score by 35 relative to sheathed. At L=3,H=1, assigned health is 13 with three logical draws. Carried 2.8 kg contributes trunc(11.2)=11 classic units.

## Required data

Stable enemy/class/body/group/language identities; resolved definition provenance; carried weight inputs; level/class HP and assigned health; current live skill/Personality/weapon/effect context; eligibility/attempt identity; owned source and retained results. Concrete schemas/versioning/source subdivisions remain dependencies.

## Inputs, outputs and events

Inputs: validated definition/property queries, authorized enemy construction or NPC pacification attempt. Outputs: explicit properties/absence, assigned health, score/probability/result or explicit failure. Queries do not change hostility, grant practice or reroll properties. NPC/CHAR own committed notifications; APIs/signals are unselected.

## Cross-system interactions

DATA/NPC own definitions/adapters/construction; ITEM carried weight; CHAR-011 live skills/Personality and CHAR-012 accepted practice; MAGIC language effect context. NPC/COMBAT own allegiance/targeting and property consumers. RULE-003/004/DATA-003 govern sources/hooks/locked configuration; CORE/SAVE preserve identity/readiness/assigned health; UI/DEV query without mutation.

## Edge cases and failure conditions

- Explicit no-group/language is valid; missing custom mappings cannot silently imitate it.
- Negative/extended live skill uses supported arithmetic then score saturation; no global skill clamp is added.
- Invalid/huge level or H cannot cause unchecked loops/overflow; finite supported bounds are required.
- Assigned health and pacification results survive technical retry; new authorized future checks may use fresh randomness after load without rerolling saved health.
- Failed hooks/missing effects/weight context use explicit recovery, not hostile/friendly defaults or successful zero values.

## Configuration and balancing options

Support validated property maps/base weights, health parameters/models and pacification coefficients/contributions with explicit hooks. Preserve integer/half-percent interfaces and declared units. No automatic new factions, universal pacification eligibility, player-race weight stat bonuses or NPC-level scaling behavior is introduced.

## Save/load considerations

Persist assigned health/current pools and owner-required enemy identity/pacification/hostility facts. Derive weight/properties from valid restored definitions/inventory without rerolling construction. Retained attempts cannot replay practice/hostility changes. Definition changes use explicit compatibility/migration, not silent language/group reinterpretation or reestimated health. General NPC despawn/respawn/pacification persistence remains NPC/SAVE policy.

## Technical constraints

Target: Godot 4.7.2. Use explicit units/stable IDs, safe integer truncation and unbiased independent draws. Separate property mapping, assigned health generation, pacification probability and behavioral mutation. APIs/numeric domains/schemas remain engineering dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Baseline group/language/body maps and intentional absence resolve explicitly, including validated added creatures; missing required IDs fail.
2. Weight conversion sums carried kg once and preserves classic units/moddable body definitions without double conversion.
3. Enemy-class health uses L independent inclusive rolls, validates before draws and retains assigned result across queries/retries/load.
4. Pacification branches preserve separate truncation/live inputs and weapon/effect contributions, resolving exact Q/200 including half-percent and guaranteed boundaries.
5. NPC authorizes attempts/consequences; property queries/previews cannot pacify, award practice or roll.
6. Mod definitions/hooks validate safe domains/contexts and restore preserves facts without reroll/replay or silent fallback.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-011/012, RULE-003/004/006 and DATA-003. Enemy health is separate from player growth; assigned outcomes remain fixed despite fresh future streams. The explicit 200-outcome rule preserves precision rather than misusing integer-percent helpers. Classification/language mapping does not approve NPC behavioral/quest policies by implication.

## Outstanding questions and approval

No blocking policy question remains for these numeric/property rules. Before implementation: verify complete mappings/body/weight adapters, define numeric/loop/hook domains, health construction/source identity, language-effect stacking and NPC eligibility/consequence/save contracts. These cannot waive explicit absence, once-assigned health, safe units or 200-outcome precision.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-019-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented mapping, numeric-domain and NPC/COMBAT/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
