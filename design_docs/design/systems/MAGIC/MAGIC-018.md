# MAGIC-018 — Healing, regeneration and fortification

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Restore current resources and explicitly healable attribute damage, or provide temporary source-owned attribute bonuses, without permanent growth, duplicate recovery or implicit revival.

## Intended player experience

Healing restores what is missing without banking excess. Regeneration continues through damage/combat/full health until its declared lifetime/removal condition. Fortification temporarily changes live values under moddable caps without automatically refilling derived pools. Attribute healing can repair ordinary disease penalties without curing their cause; curing removes remaining disease penalties without over-restoration.

## Confirmed requirements

MAGIC-018-D01–D13 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm capped resource recovery, regeneration, source-owned resolved fortification, healable attribute contributions/oldest-first repair, coherent derived limits, disease clarification, magnitude/resistance, compatible extension, no banked healing and native persistence. D07 resolves D04's conditional disease question. The complete specification is approved under MAGIC-018-A01.

CHAR-011 moddable attributes/caps and CHAR-018 pool semantics remain authoritative. MAGIC-006 accepted initial application, MAGIC-008 timing/migration, MAGIC-009 overlap/cleanup, MAGIC-010 restore and MAGIC-017 magnitude/unit baseline remain binding.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity and full family fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/MagicAndEffects/`.

- `Effects/Restoration/HealHealth.cs`, `HealFatigue.cs`, `HealSpellPoints.cs` restore the selected pool using GetMagnitude; fatigue uses a multiplier. `Regenerate.cs` heals health each MagicRound and extends matching-settings incumbent duration.
- `FortifyEffect.cs#BecomeIncumbent` resolves a stat modifier once; compatible same-stat/settings recasts add remaining rounds. Manager merges value/max contributions; exact family cap-changing source properties require inventory verification.
- `HealEffect.cs` calls manager.HealAttribute but comments that disease attribute loss is not currently healed. The inspected implementation does not establish that exclusion: manager.HealAttribute scans negative effect modifiers; base EntityEffect.HealAttributeDamage repairs them up to zero; DiseaseEffect inherits that repair behavior.
- `Effects/Diseases/DiseaseEffect.cs#IncrementDailyDiseaseEffects` accumulates negative attribute modifiers and separately damages current pools. `EntityEffectManager.cs#CureAllDiseases` removes disease bundles. Thus the inspected path can repair disease modifiers without cure, later progression can damage again, and cure removes remaining penalties rather than restoring an old full-stat snapshot. Pool damage is not automatically reversed. This static finding corrects reliance on the HealEffect comment alone.

## Detailed rules and behaviors

### Resource healing

Ordinary healing restores only selected current health/fatigue/magicka up to effective maximum under CHAR-018. It does not raise capacity, overheal, increase permanent attributes or revive confirmed-dead actors. Specialized mod effects require explicit supported owner behavior; generic healing cannot silently become resurrection.

Discard excess healing rather than bank it. Report requested amount and actual gain distinctly. Valid zero/full-pool gain is an ordinary result, not technical failure or proof a source should refund consumption. MAGIC-004/014/016 govern committed cast/bottle/item costs. Negative/unsafe/unsupported healing fails rather than becoming damage or a repaired default.

Fatigue magnitude represents displayed points converted once into CHAR-018 internal units, baseline×64, with explicit supported mod unit policy. Other pools use their own units. Queries/UI/intake cannot multiply fatigue twice.

### Regeneration

Default restores health immediately after acceptance and on genuine scheduled ticks. Each tick has fresh magnitude under captured caster power, with retained per-tick result against duplication. Compatible recasts extend lifetime without another initial heal, preserving next-tick progress and power under MAGIC-009.

Default regeneration remains active/ages through ordinary damage, combat and full health. Full-health ticks have zero gain and do not bank a future burst. Expiry, explicitly selected dispel/cure/source rule or recipient invalidation can end it. Confirmed death stops ordinary regeneration, not automatic revival. Source disappearance matters only for declared ongoing dependencies.

Validated resource/magnitude/timing/break-condition alternatives are moddable. MAGIC-008 round/real-time profiles and full elapsed accounting apply. No default combat-break rule, offline healing, extra final expiry tick or per-tick casting practice is introduced.

### Attribute fortification and caps

Ordinary fortification supplies temporary source-owned live attribute value contribution, leaving permanent values intact. Resolve magnitude once for new accepted incumbent; rebuilds/restore cannot reroll. An effective-cap increase requires explicitly declared cap contribution, not automatic unlimited fortification.

Caps are explicitly moddable under CHAR-011: validated base caps and supported source-owned cap changes must use safe consumer domains. Vanilla base cap remains CHAR's baseline; no new hard-coded MAGIC-only maximum is introduced. Retain valid cap-hidden value contributions so later source/cap changes recompute correctly.

Compatible same-attribute recasts default to duration extension preserving resolved incumbent bonus/phase without additional initial bonus. Different power/source/timing/defense compatibility must be declared. Independent additive, strongest-only, refresh/replacement alternatives remain supported under MAGIC-009, not automatically applied universally.

Cleanup removes only affected contribution and recomputes surviving values/caps rather than subtracting from clamped live totals. No permanent progression loss or removal of another source's bonus.

### Derived pool limits

Fortified Strength/Endurance/Intelligence can change derived fatigue/breath/magicka limits through CHAR-owned formulas. On increased capacity leave current amount unchanged; on decrease clamp only excess above new limit. Rebuild all valid contributions coherently before reconciliation; no transient clear-all capacity loss.

Any desired refill requires explicit restoration component, applied in authored order after relevant capacity changes if that composition intends it. Apply/remove/reapply cannot regenerate clamped-away resources for free. Removing fortification does not refund previously discarded healing.

### Attribute damage repair and diseases

Attribute healing repairs only explicitly healable source-owned damage contributions. Do not raise permanent attributes, erase unrelated penalties or automatically cure underlying curse/disease. Drain damage and ordinary disease-owned attribute penalties are eligible baseline candidates; other families declare repairability. Explicit moddable disease exceptions supported.

Spend resolved repair magnitude across eligible contributions in stable oldest-application order until exhausted, with moddable selection policy. Each repairs toward zero penalty, never above it. Retain source's remaining damage so later source expiry/removal cannot grant another restoration or remove someone else's penalty. A fully repaired source may remain active and damage again under its own progression.

Ordinary disease repair does not cure the disease. Later disease updates can inflict further penalties. Cure removes only that disease's remaining contributions, preserving permanent values/other diseases/unrelated modifiers. It does not restore an old full-character snapshot or automatically heal health/fatigue/magicka previously lost. Exact disease cure eligibility/cadence belongs to the disease feature; this policy states the repair/cleanup boundary.

### Magnitude, admission and resistance

Baseline healing/regen magnitude uses MAGIC-017 formula A=uniformInt(Bmin,Bmax)+uniformInt(Imin,Imax)×floor(L/D), inclusive ranges and captured declared caster level, D>0. Immediate healing/repair rolls once/application; regeneration fresh per genuine tick; fortification retains its accepted resolved magnitude. Validated formula/fixed-per-tick alternatives supported. Required missing context cannot silently default to current player/level one.

Caster-only mode follows MAGIC-006 effect-save exemption. External restoration follows effect eligibility and retained RULE-017 result absent explicit source bypass; a beneficial label is not universal defense bypass. Regeneration reuses its admission-time percentage by default; recurring checks require explicit mod cadence/identity. Apply selected mitigation once, not again at every getter/intake.

Admission/startup follows authored order and accepted-only mutation. Potion/item power context and permissions remain MAGIC-014/016, independent of school/name. No rejected heal may repair disease or extend incumbent before acceptance.

## Relevant formulas and parameters

Default magnitude as above; applicable numeric save scaling trunc(A×R/100) under RULE-017, no implicit minimum. Actual pool gain=min(resolved valid amount,maximum−current), for living eligible state. Attribute repair per source≤remaining negative contribution. Fatigue internal conversion×64 once. Fortification value/cap math follows CHAR-011 and capacity reconciliation CHAR-018. No new permanent cap, regen interval, overheal reserve or disease-cure formula selected.

## Required data

Stable application/tick/source/recipient/contribution IDs; target pool/stat and units; resolved/captured power; magnitude/defense policy/results; healable source classification/remaining damage/order; fortification value/cap contributions and compatibility; timing profile/lifetime/phase; requested/actual gain; declared ongoing dependency/break rules; completion/recovery/native version facts. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: accepted heal/regen/fortify/repair application, due tick, current pool/attribute/source context, expiry/removal and native restore. Outputs: actual pool gain, reduced eligible source penalty, temporary live contribution/derived-limit reconciliation, retained outcomes or explicit failure and optional feedback. APIs/signals unselected. Full-pool/no-repair-target result cannot itself regrant resources or authorize another cast.

## Cross-system interactions

CHAR-011/018 own caps/live values/pools; MAGIC-006/007 and RULE-017 admission/defenses, MAGIC-008 timing, MAGIC-009 overlap/source cleanup, MAGIC-010 persistence/HUD, MAGIC-017 magnitude/units. Disease/drain owners own underlying progression/repairability and cure; MAGIC-004 release practice/cost, MAGIC-014/016 source policies. DATA/MOD validate overrides; SAVE/CORE-013 restore without replay; UI/AV report actual effects rather than recompute them.

## Edge cases and failure conditions

- Heal at full pool: zero gain, no bank/refund; regen continues aging normally.
- Capacity bonus then healing then expiry: clamp excess once at new limit, no automatic refill on reapplication.
- Fortification above cap: retain valid hidden contribution/permanent baseline, cleanup recomputes rather than subtracts clamped total.
- Disease penalty healed before cure: disease persists/can damage later; cure removes remaining penalty only, no extra bonus.
- Multiple diseases/drains: oldest eligible source first; protected/unhealable penalties remain, no whole-attribute snapshot restore.
- Compatible extension: no rerolled stat bonus/new initial regen tick; incompatible source/settings need explicit policy.
- Confirmed dead target/source disappearance: no ordinary resurrection; ongoing source only required where declared.
- Duplicate tick/rebuild/load: no repeated healing/repair, power reroll or practice.

## Configuration and balancing options

Moddable validated caps/explicit cap contributions, magnitude/unit/resource/timing policies, regen break conditions, healable damage classification/disease exceptions, repair selection and stacking under owner contracts. Defaults remain bounded current-pool recovery, health regen and stated compatible extension. No universal cure, new permanent stat gain or implicit equipment/source exception approved. Exact schemas/safe limits/family defaults remain inventory work.

## Save/load considerations

Save resolved fortification power/contributions, repaired disease/drain state and original source identity, regen lifetime/phase and completed random/tick results. Restore derived state without healing, initial ticks, new bonuses, rerolls or per-tick practice. Future genuine ticks may draw normally; completed outcomes remain facts.

Timing profile changes use MAGIC-008 migration/continuation; source state validates under MAGIC-010/CORE-013. Cure/cleanup reconstruction must preserve unrelated modifiers and reconcile capacities coherently. Partial repair/tick/limit operations require coherent boundary or supported retained recovery; no restoring old pre-disease full-stat snapshot. Classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. Distinguish current resource recovery, temporary modifier, cap change and source-damage repair. Explicit source damage state rather than computed live-stat deficit is required. Preserve safe units/arithmetic, once-only operations and coherent contribution publication. Exact repair adapters/comparators/schema/API remain implementation work. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Healing caps selected current pool, discards excess and never silently revives or changes permanent/max state.
2. Regeneration initial/genuine ticks use retained outcomes/captured power; default persists through combat/full health and compatible extension gives no extra initial heal.
3. Fortification resolves once, uses source-owned live contributions/moddable caps and preserves hidden bonuses/permanent values across cleanup.
4. Derived capacity increases do not refill; decreases clamp only excess after coherent recompute, without toggle-refill exploit.
5. Attribute repair affects eligible oldest-first damage only; ordinary disease repair leaves cause active, cure clears remaining disease contribution without double restoration/pool refill.
6. Magnitude/fatigue units/applicable saves follow explicit policies once; benefits/source labels do not imply universal bypass.
7. Native restore retains power/repair/timing/results without initial healing/reroll/practice; expiry stops future regen without undoing gained health.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved CHAR-011/018, MAGIC-006/008–010/017 and recorded MAGIC-018-D01–D13. No direct contradiction identified. Explicit cap moddability follows CHAR, not new global override. Disease finding resolves a misleading source comment through inspected manager/base/disease paths; future disease specification must preserve confirmed repair/cure boundary. Saved source repair avoids double healing on cleanup. Current-resource reconciliation and captured/live source distinctions remain intact. Family inventories and disease-cure details remain dependencies rather than assumed complete implementation.

## Outstanding questions

No further blocking restoration-family player-policy choice is identified. Before implementation is complete: inventory effects/targets/parameters/cap contributions and repairable penalties; define source-order/compatibility/repair adapters and disease exceptions; integrate units/resistance/current-vital reporting, native partial-state recovery and timing migrations. Disease feature must define progression/cure details consistently. These deferrals cannot authorize unbounded caps, double repair, free refill, source-comment-only exclusions or confirmed-dead healing.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: MAGIC-018-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented family/cap/repairability inventories, compatibility and source-repair adapters, disease progression/cure integration and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
