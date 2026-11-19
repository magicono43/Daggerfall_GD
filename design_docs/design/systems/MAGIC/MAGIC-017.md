# MAGIC-017 — Immediate and ongoing damage

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Apply immediate or scheduled magical damage to current health, fatigue or magicka with explicit magnitude, resistance, units, source attribution and once-only consequences.

## Intended player experience

Damage affects the selected pool without silently lowering its maximum. Ongoing damage applies promptly and then follows its timing profile; default resistance is resolved once, while magnitude can vary per tick. Compatible recasts extend duration without another immediate hit. Mods can change magnitude/defense/stacking policies, including admit-once effects with no further saves and full-strength ticks.

## Confirmed requirements

MAGIC-017-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm pool damage, retained per-tick magnitude, default retained saves and alternative full-strength policy, scaling/units, compatible extension, typed intake, explicit eligibility, consequence ordering, attribution and native restoration. The complete specification is approved under MAGIC-017-A01.

MAGIC-005 captured caster power/current target admission, MAGIC-006 accepted-only initial effects, MAGIC-007 interception, MAGIC-008 timing, MAGIC-009 source-owned stacking, RULE-017 mitigation and CHAR/COMBAT death/resource contracts remain binding.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full damage/intake/quest parity fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/`.

- `MagicAndEffects/Effects/Destruction/DamageHealth.cs`, `DamageFatigue.cs`, `DamageSpellPoints.cs` apply GetMagnitude during MagicRound. Fatigue requests a multiplier and fatigue/magicka paths call aggro handling.
- ContinuousDamageHealth and corresponding fatigue/magicka classes support duration/magnitude and recurring damage. Inspected health AddState extends incumbent rounds rather than creating another independent tick source.
- `MagicAndEffects/EntityEffect.cs#GetMagnitude` draws inclusive base/increase ranges, uses caster-level multiplier and invokes ModifyEffectAmount for non-caster-only mode. Missing caster defaults to level one in this source path. Repeated magnitude calls can invoke saving resolution again; target instead uses explicit retained policies.
- `Entities/DaggerfallEntityBehaviour.cs#DamageFatigueFromSource` includes a blanket nonhostile-NPC exclusion described as a quest workaround. Target quest protection is explicit rather than a universal fatigue immunity inferred from that workaround.

## Detailed rules and behaviors

### Pools and authoritative intake

Reduce the selected current pool, not its maximum. Damage saturates at zero under CHAR-018; retain requested amount, resolved mitigated amount and actual loss separately. Health uses typed normal health/prevention/death intake; fatigue uses its exhaustion consequences; zero magicka alone does not kill. Maximum reductions, drain/transfer and healing belong to separate effects.

Validate supported nonnegative safe amounts/units before mutation. Valid zero stays zero with no injury/blood/lethal check merely from the request. Negative/overflow/unsupported values fail explicitly rather than becoming healing or guessed defaults. Technical failure is not immunity or permission to reroll.

Health damage carries magical type/element and stable source to intake without also applying ordinary weapon armor, material, critical or backstab computations. Hybrid effects explicitly separate their components/mitigation. Do not apply the same RULE-017 reduction again in health intake. Fatigue/magicka use their own pool operations, not health damage relabeling.

Fatigue magnitude represents displayed fatigue points, converted once into internal units with baseline ×64. Explicit mod unit policies supported; retain units across preview, effect resolution and intake to prevent double scaling. Health/magicka retain their own pool units.

### Magnitude and captured power

Baseline raw magnitude A=Broll+Iroll×floor(L/D), where Broll is uniform inclusive integer base min…max, Iroll uniform inclusive increase min…max, L is declared captured caster level and D positive validated divisor. Validate ordered endpoints and safe arithmetic. Do not default absent required source context to level one or silently reverse endpoints.

Immediate effects resolve magnitude once per effect/recipient application. Ongoing effects resolve fresh magnitude for each genuine scheduled tick by default. Retain each tick's resolved draws/result against duplicate callbacks, repeated getters and technical retries. Distinct genuine ticks are separate attempts.

Fresh magnitude does not recapture later caster buffs: retain offensive snapshot under MAGIC-005 and source-specific potion/item power policies. Explicit permitted live dependencies must be declared rather than all ticks consulting current player stats. Validated mod fixed-per-application or alternative magnitude policies supported.

### Defense interpretation across time

MAGIC-006/007 resolve applicability/interception/on-cast chance before accepted damage. Default ongoing damage resolves one RULE-017 retained percentage R at admission and uses it for initial and later ticks, without new saves. Per tick resolved damage=trunc(A×R/100), no automatic minimum one. A small valid nonzero percentage can still yield zero.

Support explicit alternative admit-once/full-strength profile: declared initial gate decides admission, then subsequent ticks have no saving-throw reduction. Its exact gate/initial-tick interpretation must be specified; do not infer full admission merely from nonzero R. Also support explicit recurring defense profiles with cadence, identity and current-defense observation rules. These are alternatives, not cumulative default save layers.

Magnitude randomness and defense randomness are distinct controls. A profile can reroll magnitude every tick but perform no further saves. Completed defense results remain retained; preview does not roll them. Default per-effect save is not an automatic per-tick absorption/reflection check. Any recurring interception requires a complete MAGIC-007-compatible explicit policy.

### Initial application, timing and stacking

Accepted immediate damage applies once through initial application. Accepted ongoing damage receives initial tick then scheduled ticks under MAGIC-008 default rounds or declared mod real-time profile. Default N-round accounting includes initial application, with no extra tick at cleanup. Pure inspection/restore cannot apply initial damage again.

Default compatible ongoing recasts extend duration under MAGIC-009, preserving incumbent power, retained resistance and next-tick phase, without an additional initial hit. Preserve constituent source provenance. Compatibility must explicitly account for element, source and defense/power context; do not merge dissimilar applications merely because both damage health and thereby inherit another source's defenses or attribution.

Independent stacks, replacement, refresh and other validated alternatives supported. Exact family matching/source domain and merged-duration attribution need inventory/owner contracts. Failure to match standard extension is not permission to silently discard or auto-stack an incompatible effect.

Dispelling, expiry or valid source removal stops future scheduled work under the declared lifecycle. It does not heal prior damage, refund resource loss or undo settled death. No default extra spell practice per damage tick; MAGIC-004 owns release practice and explicit mod progression requires once-only owner eligibility.

### Recipient changes and consequence ordering

Use explicit spell/effect/quest eligibility instead of blanket nonhostile fatigue immunity. Preserve required quest behavior through explicit protected actor/effect rules. This does not automatically make all actors damageable or decide criminality/hostility.

Fully settle each application's/tick's prevention, death or exhaustion consequences before the next effect proceeds. After confirmed death reject later ordinary living-target damage; prevention leaving actor alive permits later genuine operations under owner rules. MAGIC-006 authored order and current validity remain binding.

Do not aggregate multiple scheduled ticks into one damage amount if that changes prevention opportunities, source accounting, random results or interruptions. Equivalent bulk processing only where MAGIC-008 permits. Large time advances stop at death/applicable interruption and report actual elapsed time.

### Attribution, reactions and feedback

Retain original actor/item/spell and application/tick identity after source representation disappears. Never attribute a tick to a replacement actor, current spell selection or newly equipped item. Source-provenance accounting for merged durations must remain explicit.

Report actual pool loss separately from requested/resolved amount, immunity/resistance and valid zero loss. No blood/injury for a zero request; UI/AV effects follow intake outcomes. LAW/QUEST/NPC use declared attempt/hit/loss/death semantics. Tick callbacks are not automatically fresh crimes/casts/skill reports, and this draft selects no universal aggro/crime frequency.

Optional feedback cannot apply damage, redraw outcomes or roll checks. Required reaction failure retains committed facts for explicit recovery rather than replaying the whole effect.

## Relevant formulas and parameters

A=uniformInt(Bmin,Bmax)+uniformInt(Imin,Imax)×floor(L/D), D>0. Default resolved amount=trunc(A×R/100) with retained R and safe domains. Fatigue internal amount=resolved displayed points×64 baseline, applied once. Actual loss≤current pool under saturation, subject health prevention/outcome accounting. No new magnitude minimum, weapon multiplier, fatigue death formula, duration curve or recurring-save interval is selected.

## Required data

Stable cast/effect/contribution/recipient/source/tick IDs; resource type/units and element; captured potency/level/settings; magnitude policy/draws/result; defense policy/retained result or declared recurring cadence; lifetime/next tick/source provenance; requested/resolved/actual loss and settled prevention/death/exhaustion; compatibility/cleanup/recovery progress. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: accepted application/due tick, retained power/defense state, current recipient eligibility/pools, mod profile and authoritative intake result. Outputs: one typed pool mutation or valid zero/ordinary rejection/technical failure, settled consequences, retained tick outcome and optional feedback. API/signal names unselected. A damage notification is not a second damage request or cast/practice event.

## Cross-system interactions

MAGIC-005/006/007 supply delivery/captured power/admission/defenses; RULE-001/003 randomness and RULE-017 retained scaling; MAGIC-008 elapsed scheduling, MAGIC-009 merging and MAGIC-010 persistence. CHAR-018 pool mutation, CHAR-022 exhaustion and CHAR-023/COMBAT-013 health death/prevention; COMBAT-020 NPC death. NPC/QUEST/LAW define eligibility/reactions, ITEM/MAGIC-014/016 explicit source potency contexts. UI/AV observe actual outcomes; DATA/MOD validate policies and SAVE/CORE-013 gate compatibility/reconstruction.

## Edge cases and failure conditions

- Full resistance or rounded zero magnitude: no resource loss/injury; no extra save to chase a nonzero result.
- Pool smaller than damage: saturate, retain resolved versus actual loss; magicka depletion not health death.
- Repeated callback/restore: same tick result, no repeated damage/RNG/practice.
- Caster buff/scene disappearance after release: retained power/attribution, not current player fallback.
- Recast with different element/save/source: explicit compatibility, no silent incumbent resistance inheritance.
- Lethal early entry/tick: settle death/prevention before later work and stop applicable synthetic advance at real event time.
- Nonhostile quest actor: declared protection/eligibility, not universal fatigue loophole or invented hostility policy.
- Mod admit-once versus recurrent saves: complete distinct policy, no accidental double reduction or hidden recurring check.

## Configuration and balancing options

Validated magnitude/scaling/units, fixed-versus-per-tick rolls, retained/full-strength/recurring-defense models, intervals, matching/stacking and eligibility policies are moddable. Baseline remains stated formula/retained save/compatible extension. Exact effect-specific numeric limits, full-strength admission predicate and recurring cadence must be declared; no new fixed damage-over-time model or global immunity override is implied.

## Save/load considerations

Preserve power, source contributions, selected resistance/magnitude policy, completed draws/results, remaining lifetime and next tick. Restore no initial or completed tick damage; future genuine ticks may draw fresh randomness under RULE-001/003. No extra tick from loading wall time or a cleared HUD. Migration follows MAGIC-008/010 without silently resetting power/resistance/phase.

Partial damage/prevention/reaction operations require coherent save boundary or supported retained progress; no whole-effect reroll/reapplication after partial mutation. Required provider/context incompatibility follows CORE-013 recovery. Exact merged-duration attribution and tick serialization remain dependencies. Classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. Explicit typed resource/units and retained application/tick state rather than live caster/getter side effects. Safe integer endpoints/divisors/intermediates and once-only owner operations required. Exact damage/intake adapters, compatibility keys, profile APIs and save format remain implementation design. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Health/fatigue/magicka current pools damage safely with separate actual loss/maxima and correct consequence owners; no duplicate weapon mitigation.
2. Baseline inclusive magnitude formula and captured inputs apply once/immediate or fresh per genuine tick, retaining each outcome across retries.
3. Default retained save scales every tick without reroll; explicit full-strength/recurring alternatives cannot accidentally add duplicate defenses.
4. Fatigue×64 converts once, zero stays zero and invalid inputs fail rather than heal/default.
5. Compatible ongoing recasts extend without new initial damage or power/save/phase change; incompatible source/element/outcome semantics explicit.
6. Each tick settles consequences before next; death/time-interruption and bulk equivalence preserve prevention opportunities.
7. Attribution/feedback/reactions report stable true outcomes, not fresh casts/crimes/practice from callbacks by default.
8. Dispel/expiry stops future damage only; native restore preserves state without initial/completed damage replay.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-005–010, RULE-017, CHAR-018 and COMBAT-013/CORE native safeguards plus MAGIC-017-D01–D12. No direct contradiction identified. Recurring magnitude differs from recurring defenses; explicit full-strength profile is an owner-approved alternative to default retained save. Compatible extension preserves MAGIC-009 provenance/phase, and current recipient consequences coexist with captured caster power. Fatigue conversion is explicit unit translation, not a second damage bonus. Quest exceptions and reactions remain owner contracts rather than adopting source workaround universally.

## Outstanding questions

No further blocking damage-family player-policy choice is identified. Before implementation is complete: verify full family coefficient/target/element inventories and unit adapters; define extension compatibility/provenance consumption, full-strength gate and recurring-defense cadence; integrate exact health/exhaustion/NPC reaction contracts, tick tie order, partial recovery and native migrations. These deferrals cannot authorize duplicate mitigation, live caster rewriting, universal nonhostile immunity, replayed damage or incorrect pool units.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: MAGIC-017-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented family inventories, unit/intake adapters, extension compatibility, alternative defense policies, reaction/tick ordering and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
