# MAGIC-026 — Charm, pacification and language

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose and intended player experience

Resolve encounters peacefully through targeted magic or language proficiency enhanced by magic. Charm and Pacify establish lasting, explicitly scoped nonhostility rather than follower control. Comprehend Languages temporarily improves encounter checks without teaching permanent skills. Mod profiles may provide broader social, control or translation behavior.

## Confirmed requirements

MAGIC-026-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record four interviews confirmed with three “Yes” answers each. The complete specification is approved under MAGIC-026-A01. RULE-019's property mappings and encounter formula, MAGIC-003–010 casting/admission/timing, CHAR-012 practice and COMBAT-015–017 attack commitments remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths relative to reference `Assets/Scripts/`:

- `Game/MagicAndEffects/Effects/Thaumaturgy/CharmEffect.cs` declares chance but disables duration. Its comments explain incorrect text descriptions: Charm pacifies enemy classes, not humanoid monsters, lasting until attacked. Initial `MagicRound` sets the target motor's `IsHostile=false` when eligible.
- `Effects/Thaumaturgy/PacifyEffect.cs` defines Animal/Undead/Humanoid/Daedra variants, chance support and group eligibility, also setting `IsHostile=false`. Pacify Humanoid is distinguished from enemy-class Charm. Group mappings use `EnemyEntity.GetEnemyGroup` and `Game/Formulas/FormulaHelper.cs#GetEnemyEntityEnemyGroup`; they are explicit data, not inferred from appearance.
- `Effects/Mysticism/ComprehendLanguages.cs` is a duration incumbent with custom chance handling and compatible duration extension. `FormulaHelper.CalculateEnemyPacification` adds its `ChanceValue` to the encounter score before an integer 0..199 roll.
- `Game/EnemySenses.cs` attempts language pacification on first detection of the player, excludes actors with quest behavior and awards 3 skill uses on success, or 1 on failure for languages other than Etiquette/Streetwise.
- `Game/EnemyMotor.cs#MakeEnemyHostileToAttacker` can restore player hostility on attack. Source shared hostility flags do not establish independent per-caster protection.

Static inspection only; no runtime/classic-parity verification. Target per-caster scope, explicit NPC persistence and general hostile-application break policy are confirmed intended rules rather than claims of complete DFU parity.

## Detailed rules and behaviors

### Eligibility and admission

Default Charm affects enemy-class actors. Default Pacify variants affect the mapped Animal, Undead, Humanoid-monster or Daedra group. Preserve RULE-019's explicit group mappings/intentional absence; appearance or a localized name cannot substitute for classification. Ordinary civilians and player recipients are not implicitly eligible. Mods may redefine eligibility and add supported actor adapters.

Use MAGIC-006/007's current applicability, spell defenses, effect chance and applicable saving throw pipeline. Interpret Charm/Pacify resistance as binary admission: success establishes nonhostility; failure establishes none. Do not convert partial numeric resistance into partial allegiance or unapproved duration scaling. Wrong-category targets remain unaffected. Modded immunities, eligibility and resistance behavior require explicit validated profiles.

Casting/payment/practice/history remain MAGIC-003/004 and origin rules. A successful cast is not proof of accepted pacification; missed/resisted applications remain paid normal outcomes. Failure of one area recipient does not cancel another's independent success. No preview or constructor may mutate hostility.

### Nonhostility result and scope

Default successful Charm/Pacify creates an NPC-owned relationship protecting the caster, with no duration. It is not a timed magic incumbent that expires when its application effect ends. Original caster death, absence or scene unloading does not automatically erase the relationship. Retain stable identity without resurrecting missing actors or attaching records to reused identities.

Pacification stops that target's attacks against the protected actor, not every combat relationship. It can continue fighting unrelated enemies. Another caster's independent protection survives removal of one relationship. Repeated successful applications for the same relationship do not create duplicate rewards or redundant behavioral layers; subsequent genuine casts still follow ordinary costs/practice. Timed/source-bound, caster-group or global calm profiles may explicitly change scope/lifetime/composition.

Do not change faction membership, follower allegiance, command permissions, crime records, quest state or kill/defeat rewards implicitly. A nonhostile enemy is not automatically a friend, companion or surrendered prisoner. NPC/quest rules may explicitly restrict eligibility or create later hostility events; those overrides must have defined precedence rather than incidental update order. Mods can add disposition, allegiance, commands or broader consequences through the relevant owners.

### Combat handoff and later hostility

On accepted pacification, cancel unfinished attacks aimed at the protected actor and reject new attacks against that actor. Preserve committed costs, settled damage, existing recovery and captured attack intervals under COMBAT-015–017. Canceling a wind-up cannot erase costs already committed by another phase. AI needs a fresh authorized decision for any later attack; no stale marker may finish a canceled attack.

Already released arrows/spells and committed effects persist independently. Pacification cannot rewind damage, delete projectiles or remove an ongoing poison. No universal invulnerability or safe passage through collision follows. Retargeting to an unrelated actor must begin a new authorized action rather than redirect an existing swing.

A successfully applied hostile action by the protected actor ends that actor's applicable protection. A qualifying physical hit or accepted hostile magical effect can qualify even if Shield prevents health loss. Misses, fully resisted magical effects, rejected attempts and incidental environmental damage do not qualify by default. Pacification's own accepted application must not immediately break the relationship it creates. The NPC owner then resolves resulting hostility without silently removing another caster's independent protection.

Break predicates are moddable. Exact classification for zero-damage physical hits, repeated/ongoing payloads, reflected effects, proxies and ally attribution requires explicit source/outcome adapters. Do not infer every damage callback is a new hostile action or let cosmetic events control relationships. Explicit NPC events can restore hostility independently under their declared policies; no arbitrary periodic reset is approved.

### Comprehend Languages

Default self-buff contributes a temporary score bonus to eligible encounter-language checks. Its chance fields define bonus E=B+I×floor(L/D), with validated positive divisor D and release-captured caster power L under MAGIC-005/006. No extra buff-cast success roll uses those fields. RULE-019 resolves the encounter itself; this is not a percentage-point bonus.

One compatible incumbent retains its existing bonus while recasts extend remaining duration under MAGIC-009. Repeated casts do not add bonuses or silently replace power. Mods can define strongest/replacement/custom composition with explicit source/lifetime rules. Removing one contribution cannot erase another surviving source. Expiry removes future bonus contribution without undoing a successful earlier encounter pacification.

No permanent learned skill increase or universal translation is granted. Mods may define dialogue translation or other language interactions using temporary capability context through NPC/UI owners. Missing required language definitions cannot silently turn into automatic comprehension.

### Encounter check timing and formula

Default automatic attempt occurs once when that enemy first detects the player. Quest-controlled actors are excluded unless their quest explicitly permits the attempt. A declared language mapping is required. Casting, improving or reapplying Comprehend Languages after the encounter does not automatically retry. Timing/retries/exclusions remain moddable; opening UI, querying properties, reloading or revisiting are not new attempts.

Use coherent live language skill S, live Personality P, current weapon state and applicable resolved E at the authorized attempt. RULE-019 defines:

- Etiquette/Streetwise: C=trunc(S/10)+trunc(P/5)+W+E.
- Other mapped languages: C=S+trunc(P/10)+W+E.
- W=+10 sheathed, −25 drawn; Q=clamp(C,0,200).
- Draw one unbiased integer R in [0,199]; success iff R<Q. Probability=Q/200, preserving half-percent increments. Guaranteed boundaries still consume the owned logical draw.

Thus +20 bonus score adds 10 percentage points before final clamping. Do not clamp E to a percentage merely because the effect settings are named chance. Preserve RULE-019 division/rounding and RULE-003 retained outcomes. Mod formula replacements must retain explicit output domains and owner-authorized attempts.

Successful encounter pacification protects the player under the relationship rules above. Failed checks do not invent added hostility penalties or automatic retries. Default encounter practice is 3 raw points on success; 1 on failure for non-Etiquette/Streetwise languages; 0 for Etiquette/Streetwise failure. Apply through CHAR-012 validation/progression, independently of ordinary spell-release practice. Validated award policies are moddable; no practice is earned from preview, restore, UI refresh or duplicate notifications.

### Persistence and feedback

NPC owns committed nonhostility relationships and completed encounter-attempt/result/practice facts. They persist through native load and location revisit independently of the transient effect or original caster presence. Stable actor lifetime/reconstruction contracts distinguish a returning actor from a genuinely newly generated actor. Loading cannot reroll an attempt, forget success or repeat practice.

Save Comprehend Languages sources, resolved bonus, remaining timing/profile and required composition state through MAGIC-010. Restore derived bonus without recasting, rerolling admission or granting skill. Timed modded calm expires through its declared MAGIC-008 clock; default lasting relationships have no fabricated countdown.

Feedback distinguishes accepted pacification, resisted/ineligible application and technical failure without exposing hidden immunity or exact encounter probability by default. Existing HUD effect duration applies to Comprehend Languages, not an invented duration for persistent peace. Exact wording/layout is UI/NPC scope. Optional presentation failure cannot change the relationship or replay its award.

## Relevant formulas and parameters

Default Charm/Pacify duration: none; scope: caster relationship; result: binary nonhostility. Comprehend Languages E and RULE-019 encounter formulas above govern the bonus/check. Default encounter practice: success 3; eligible non-social failure 1. No default disposition amount, follower limit, control duration or translation coverage is invented. Policy domains, NPC event precedence and actor mappings remain validated dependencies.

## Required data

Stable actor/caster/session/effect/spell identity; explicit group/language mappings and quest eligibility; application chance/defense/save outcomes; relationship scope/protected identities/provenance and current status; hostile-action identity and accepted outcome; canceled attack and committed phase facts; encounter-attempt eligibility/completion/result/practice state; buff sources/resolved bonus/timing/profile versions; mod policy/provider/schema versions. Concrete persistence/API schemas remain engineering work.

## Inputs, outputs and events

Inputs: committed effect applications, target eligibility/defenses, authorized first-encounter check, live formula context, explicit hostile/NPC events, source/timing changes and restore. Outputs: accepted/failed pacification, relationship update, attack cancellation/admission restriction, encounter outcome, once-only practice and truthful feedback. Distinguish spell release, effect acceptance and NPC relationship commitment; none is a second authorization to roll or award. API/signal names unselected.

## Cross-system interactions

RULE-019 group/language and 200-outcome formula; RULE-003/004 retained RNG/hooks; MAGIC-003–010 casting, captured power, defenses, duration/composition/save; MAGIC-017–022 hostile payload outcomes; COMBAT-010/015–017 committed hits/interruptions/projectiles; CHAR-012 practice; NPC relationships, targeting, actor lifecycle/encounters; QUEST eligibility/overrides; FACT/LAW independent allegiance/crime; UI temporary language uses; SAVE/CORE provider validation/readiness. This feature does not finalize the broader NPC, dialogue or quest systems.

## Edge cases and failure conditions

Cover wrong category, intentional group None, missing mappings, quest exclusion, area recipients with mixed resistance, existing nonhostility, multiple casters, missing/dead original caster, combat wind-up/released missile, hostile control, shield-absorbed hits, ongoing poison, reflected/proxy attribution, and changed weapon/buff state at a genuine encounter. Technical partial failure retains committed relationship/outcome/award facts and enters explicit recovery instead of retrying the entire application. A failed cast cannot fabricate friendly allegiance.

## Configuration and balancing options

Validated eligibility/groups/immunities, resistance interpretation, relationship scope/lifetime/breaks, quest-event precedence, timed calm/disposition/allegiance/commands; language formula/bonus composition, attempt timing/retries/exclusions and practice; temporary translation/other language interactions. Exact per-policy precedence, limits and required owner adapters must be specified before exposing alternatives. Default records cannot be silently lost when a mod changes a timed/global relationship policy.

## Save/load considerations

Persist lasting NPC relationships separately from active magic durations, plus encounter completion/results and settled practice. Restore with stable identities and supported migrations, not bare scene flags. Comprehend Languages restore uses captured power/remaining lifetime without new rolls or permanent skill mutation. Required missing policies/actors use declared migration/recovery rather than guessed hostility or reassigned identities. Save only coherent owner state at supported boundaries; unresolved partial commitments follow CORE/SAVE recovery.

## Technical constraints

Target Godot 4.7.2. Separate pure formula/eligibility, effect admission, authoritative NPC relationships, combat cancellation and optional feedback. A single global hostility Boolean cannot represent approved independent caster scopes. Durable relationship results must not require a surviving transient magic instance. Do not impose a generic command bus or transaction framework by implication. No implementation/coding tasks authorized.

## Acceptance criteria

1. Charm and Pacify preserve approved explicit target distinctions; chance/defenses/save produce binary outcomes without mutating wrong-category targets.
2. Accepted default nonhostility lasts without duration and protects caster only; unrelated combat and another caster's independent protection remain valid.
3. Pacification cancels unfinished protected-target attacks without undoing commits, intervals/recovery, released projectiles or ongoing effects.
4. Qualifying accepted hostile actions end applicable protection; misses/fully resisted effects/environmental damage do not; pacification cannot break itself.
5. No implicit followers, faction/crime forgiveness or quest/kill/defeat rewards arise.
6. Comprehend Languages adds captured E to an eligible encounter without a separate cast-chance roll; compatible extension retains bonus and expiry does not undo prior peace.
7. RULE-019's exact branches/weapon adjustment/200-outcome model remain intact, including half-percent increments and retained results.
8. Default first-detection attempt/exclusions do not reroll on buff changes, UI, load or revisit; explicit mod retries remain supported.
9. Practice follows 3-success/1-non-social-failure defaults through CHAR once only, separate from casting; no permanent skill from buff alone.
10. Native restoration retains relationships, attempt results, completed awards and buff lifetime without caster dependence or replay.
11. Supported mod contracts cover eligibility, timed/global/group/social/control alternatives, language formulas/uses and retry/award policies.

These are future verification criteria; no implementation/runtime tests performed.

## Consistency review

Reviewed against RULE-019, CHAR-012, MAGIC-004/006/008–010 and COMBAT-015–017. Numeric encounter rules remain approved; NPC authorization and effect composition are now explicit. Lasting peace is NPC state, not a duration reset loophole. Cast practice is separate from encounter practice. Combat cancellation retains committed facts and cooldowns, while released threats remain independent. Scoped relationships deliberately replace source global hostility behavior without changing faction membership.

## Outstanding questions and approval

No further blocking player-policy question identified. Required dependencies: complete mappings/quest permissions; relationship identity/event precedence and actor reconstruction; hostile outcome/proxy/reflection/ongoing attribution adapters; exact physical-hit qualification and attack-cancellation boundaries; mod scope/composition/migration schemas; temporary translation/UI adapters and persistence fixtures. These do not waive independent protections, once-only attempts/awards or committed combat consequences.

The user explicitly approved the complete Draft v1 on 2026-11-10 with “I approve”. This specification is finalized v1 under MAGIC-026-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented integration and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
