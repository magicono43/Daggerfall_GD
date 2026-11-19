# MAGIC-029 — Lycanthropy infection and transformation

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose and intended player experience

Acquire a curable infection that establishes persistent werewolf/wereboar identity with voluntary and lunar-forced beast forms, powers, restrictions and a monthly urge. Keep condition, current form and birth identity distinct. Support additional mod-defined transformations through shared lifecycle and persistence contracts.

## Confirmed requirements

MAGIC-029-D01–D18 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record six interviews, each confirmed with three “Yes” answers. The complete specification is approved under MAGIC-029-A01. CHAR-019 identity/compatibility/entitlements, CHAR-011/018 caps/vitals, MAGIC-008–010 timing/persistence, MAGIC-021 special infection boundaries and MAGIC-028 mod-added transformation contracts remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths relative to reference `Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#OnMonsterHit` uses special infection chance 0.6 for player hits from werewolves/wereboars. `Game/MagicAndEffects/Effects/Diseases/LycanthropyInfection.cs` rejects redundant/opposing types and active racial overrides. Base `DiseaseEffect.Start` limits acquisition to player level>=2. Special infection explicitly bypasses ordinary disease immunity in the manager.
- Infection source records calendar starting day; warning occurs at daysPast>0 and establishment at daysPast>3, despite three-day comments. It assigns Morph Self and deploys a curse in place. Target chooses elapsed 24/72 hours instead, independent of video callbacks.
- `Effects/Special/LycanthropyEffect.cs` separates infection type and transformed state. Acquisition initializes satiation and invokes broad CureAll. `MorphSelf` unequips both hands on entry, toggles form, fully heals and updates a shared last-cast timestamp for both directions. `CanCastMorphSelf` requires more than one day unless Ring equipped. Target changes timestamp/boundary/healing policies explicitly.
- `ApplyLycanthropeAdvantages` applies +40 STR/AGI/END/SPD and +30 Swimming/Running/Stealth/Critical Strike/Climbing/Hand-to-Hand/Jumping without checking form. Disease immunity is condition-wide; Silver minimum material only transformed. Beast presentation uses Werecreature weapon, custom head/body/voices and inventory/talk suppression.
- `ForceTransformDuringFullMoon` forces entry on magic rounds when either moon is full, allowing temporary reversion until next round and bypassing forcing with equipped Hircine Ring. No automatic full-moon-end reversion appears in this path.
- Monthly urge uses 30 elapsed game days since innocent kill, then rounded reduction at 24 health/day with minimum limiter 4. Qualifying victims are mobile civilians/city watch in either form. Ring suppresses urge without updating last kill time. `SuppressCrime`/`SuppressPopulationSpawns` return beast state.
- Cure morphs back if needed, fully heals, advances a minute, deletes tagged spells and ends named cure quests. Custom save retains type, last kill/cast, Ring and transformed state. Target uses scoped cleanup and explicit quest outcomes instead.

Static inspection only; no runtime/classic-parity verification. Source broad cure/healing, global player references and presentation callbacks are not approved architecture.

## Detailed rules and behaviors

### Acquisition and infection

Default qualifying positive-initial-damage physical hits from matching werewolf/wereboar expose player recipients level>=2 with exact 0.6% probability per hit. Use retained RULE-003 exposure outcome and COMBAT/RULE creature-ability eligibility, not animation/contact callbacks or whole-percent rounding. Explicit special-infection bypass applies to ordinary disease resistance/immunity, not transformation compatibility. Sources/recipients/chance/trigger/bypass are moddable.

Accepted source determines type. First accepted werewolf/wereboar infection is retained; redundant exposure cannot restart incubation or switch type. Preserve CHAR-019 one-active-condition default without silent cure/replacement. Competing latent type/condition events require deterministic compatibility handling; unsupported combinations cannot publish partial grants. Added transformations declare their own acquisition profiles, rather than inheriting werewolf defaults automatically.

Default hidden infection warns at 24 elapsed game hours and establishes at 72. Diagnosis/modded UI may disclose more. Ordinary Cure Disease may remove infection before establishment; dedicated cure required afterward. Video success cannot gate authoritative progress or repeat grants. Establish in place without vampire absence/cemetery relocation. Rest/travel processes milestones chronologically; pause/load/offline time adds none. Cure windows, stages, knowledge and timing are moddable.

### Persistent condition and form identity

Persistent lycanthropy is distinct from humanoid/beast form. Preserve birth race, portrait/gender and independent abilities under CHAR-019. Reversion removes form-only capabilities; cure removes condition contributions. Derived identity/appearance must not replace birth data. Establishment grants source-owned Morph Self access through MAGIC entitlement/casting contracts; exact baseline spell record/cost mapping requires fixtures. Repeated acquisition/restore cannot duplicate that access.

Establishment starts the monthly urge timer as satiated once. It removes the incubating infection without CureAll: preserve unrelated ailments, drains and current resource deficits. No acquisition, form entry, reversion or cure automatically heals/refills. Explicit mod profiles may add restoration through owners. Maximum changes use CHAR-018: increases do not heal, decreases clamp only when needed.

### Voluntary shapechange and lunar forcing

Successful voluntary entry starts a 24-game-hour cooldown; another ordinary voluntary entry is allowed when elapsed>=24h. Voluntary reversion is allowed regardless of that entry cooldown. Reversion and forced entry do not restart the voluntary-entry timestamp under the default policy. Initial entitlement/entry readiness must be explicit so acquisition does not accidentally inherit an unrelated world-zero cooldown.

Morph Self is an explicitly allowed reversion route in beast form, subject to normal casting/source checks. Default allowance to revert is a cooldown exemption, not universal permission to cast while dead, silenced or otherwise ineligible. Eligibility, cooldown, timing and alternative direct-action profiles are moddable. Required transition validation precedes consumption/commit through the declared cast/operation boundary; no extra grant or free heal on failed morph.

At each default shared magic-round boundary, either moon being full forces beast entry if humanoid and no applicable Ring exception. Forced entry bypasses voluntary cooldown. A player may revert briefly before the next boundary forces entry again. Full-moon end does not itself revert an already transformed actor. No duplicate forcing while already beast; loading does not invent an additional boundary. Calendar lunar definitions/cadence are TIME-owned; alternative forcing/reversion clocks moddable under MAGIC-008.

### Bonuses and form capabilities

Condition-wide in both forms: +40 STR/AGI/END/SPD; +30 Swimming, Running, Stealth, Critical Strike, Climbing, Hand-to-Hand and Jumping; disease immunity. Source-owned modifiers apply once subject to CHAR-011 moddable caps and inheritance rules. Silver-or-better physical material protection is beast-only, not general damage immunity. Werewolf/wereboar share these baseline numbers; type/form overrides are moddable.

On successful beast entry unequip both hands, retaining item identity, condition, quantity and ownership. Do not drop/destroy items. Other equipment stays equipped unless explicit form policy says otherwise, including source powers with declared eligibility. Use werecreature attack profile; exact damage/reach/animation mapping follows COMBAT/RULE and asset fixtures, not appearance-based damage inference. Reversion does not auto-re-equip hands.

Cancel/reconcile incompatible unfinished attacks through COMBAT transition contracts, retaining committed costs/recovery/projectiles. No mid-swing weapon substitution or replay of equip rewards. Full shape/context changes validate through MOVE owners; no barrier crossing, arbitrary teleport or ignored low ceiling. If required form cannot fit, use explicit transition failure/recovery; exact mandatory-lunar retry policy requires fixtures rather than exposing invalid collision.

### Action restrictions, crime and population

Default beast form blocks ordinary inventory and conversation, with clear feedback. Enforce on actual operations and shortcuts, not only window visibility. Source-defined form display/voices are optional presentation; missing assets cannot silently change gameplay. Morph Self reversion remains explicitly supported. Additional spells/items, potion/quick-use, selected inventory/dialogue and other form actions need a declared action mask reconciling MAGIC-014/016 defaults; no accidental UI-only bypass or universal spell ban inferred. These policies are moddable.

Beast actions do not create ordinary player crime charges by default. Report truthful attributed incidents to LAW/NPC/QUEST; apply an explicit beast-form charge policy rather than deleting evidence/events. Existing crimes persist. NPC fear/hostility depends on perceived form and explicit sensory/reaction rules, not omniscient global hostility. This is not a default guarantee of safety from witnesses or quest consequences. Policies moddable through owners.

Suppress new ordinary civilian population spawns while beast, not existing actors, persistent population records or quest-required spawn policies. Transformation cannot erase people/loot/state by despawning them. NPC/LOC own resumption and spawn reconciliation after reversion without retroactive duplication. Scope and reactions moddable.

### Monthly urge and maximum-health limiter

Let T be elapsed game minutes since the last qualifying kill (or genuine initial satiation). Default period P=30×1440 minutes. Without Ring exception, urge becomes active when T>P. Reduction follows inspected rounded rate r=round((T−P)×24/1440), with explicit validated rounding under RULE contracts. Limiter Hlim=max(4,Hbase−r), where Hbase is the character's authoritative raw/base max-health input under CHAR-018. Effective health remains bounded by base and other active limiters; minimum 4 here cannot raise a lower base/other limit.

Limiter is source-owned and recomputed from elapsed time rather than repeatedly subtracting permanent max health. Clamp current only if above new effective max. A qualifying kill resets time and removes this limiter without healing previously clamped health. No generic lethal health damage or permanent loss is inferred from the limiter.

Default victims: mobile civilians and city watch. Qualifying attributed death counts in either form; resolve from COMBAT-confirmed death and source identity once, not a weapon observer or corpse query. Banishment, nonlethal damage and prevented deaths do not count. This category named innocent is not LAW's verdict. Exact indirect/damage-over-time/summon kill attribution requires explicit adapters. Mods may redefine interval, penalty/minimum/victims and nonlethal satiation.

Provide appropriate urge/weakness feedback without per-frame message spam; exact reminder cadence is UI tuning. Cosmetic RNG/voices cannot change urge or combat RNG. Pause/load does not advance the timer; authorized long advances do, with chronological health reconciliation.

### Hircine Ring

An eligible equipped Hircine Ring bypasses voluntary entry cooldown, suppresses full-moon forcing and suspends this urge limiter. Identify capability through stable artifact/power data. Exceptions independently moddable. Wearing does not cure condition, reset last kill or erase underlying timestamps. Removing reapplies current elapsed restrictions/limiter, without retroactive damage ticks or healing; current-health clamp on lowered max still applies under CHAR-018.

Reconcile actual equipment changes through ITEM and source ownership rather than waiting for accidental graphics refresh. Exact effect-change/round ordering must be explicit, while forcing itself remains round-based. Restored equipped state is not a fresh equip reward or satiation event. Removing Ring does not force an extra off-cadence lunar event by inference.

### Cure, elapsed time and mod transformations

Dedicated cure validates authorization and safe humanoid restoration, then removes lycanthropy-owned modifiers, grants, form restrictions, protections and urge limiter. Preserve birth identity, independently learned access, equipment and unrelated effects. No artificial minute advance or vital refill. Cure quests have explicit acknowledged completion/cleanup outcomes; do not blanket-delete unrelated quests. Requirements/benefits moddable.

Rest/travel processes infection, lunar boundaries, cooldown and urge changes chronologically under MAGIC-008/TIME. Stop when form change needs player control or invalidates the activity; do not complete a long trip first then apply accumulated forcing. Settle actual completed time and retained outcomes once. Exact form-specific travel/rest eligibility belongs to action profiles, not an invented blanket block. No pause/load wall-time catch-up.

Carry forward MAGIC-028's explicit support for additional mod-defined transformation conditions/forms. Stable versioned definitions and supported adapters cover acquisition, stages, form grants/appearance/collision/actions, compatibility, hazards/urges, artifact exceptions, reversion/cure and save migration. A closed werewolf/wereboar switch cannot be the sole identity/extension mechanism. New mechanics need owner contracts; mod support does not preapprove unspecified hybrids or unrestricted execution during queries.

## Relevant formulas and parameters

Infection probability .006/qualifying hit; warning 24h, establishment 72h; voluntary entry elapsed>=24h. Lunar forcing default each shared one-game-minute round while either moon full. Listed +40/+30 bonuses; urge P=30 elapsed game days, reduction 24/day after P, minimum source limiter 4, rounded once from total elapsed. Exact rounding, extreme domains and baseline attack/ability profiles require validated fixtures.

## Required data

Stable actor/condition/form/type/profile/provider versions; exposure outcome and accepted infection time/milestones/knowledge; birth identity and source entitlements/modifiers; actual form and transition completion; last successful voluntary-entry time/initial readiness; lunar schedule cursor; last qualifying kill and retained death attribution; urge limiter provenance; equipped Ring capabilities; action mask, equipment/shape readiness and crime/population context; cure/quest obligations and migration state. Concrete schemas/APIs remain dependencies.

## Inputs, outputs and events

Inputs: qualifying exposure/death, authorized time/lunar boundary, voluntary cast/reversion, equipment changes, action requests, cure and native restore. Outputs: infection/stage/type outcomes, safe form transition, scoped grants/restrictions/limiter reconciliation, attributed incidents, spawn policy and quest/cure results. Distinguish attempted morph, successful form entry and current condition; observers/UI cannot authorize another grant or timer reset.

## Cross-system interactions

CHAR-019 identity/compatibility, CHAR-011/018 modifiers/vitals; MAGIC-003/004 morph casting, MAGIC-008–010 timing/persistence, MAGIC-014/016 item/potion actions, MAGIC-021 cure and MAGIC-028 extension; COMBAT-002/010/011/015 attack/source/death attribution; MOVE shape/mode/placement; ITEM hand/equipment/artifact ownership; TIME lunar/calendar/advance; NPC/LOC population/perception; LAW explicit charge policy; QUEST cure/outcomes; DATA/MOD providers and CORE/SAVE transition readiness/recovery.

## Edge cases and failure conditions

Test conflicting infections, active vampire, cure at milestone, first morph readiness/exact24h, forced versus voluntary timestamp, brief full-moon reversion, Ring removal at lunar boundary, low ceiling/occupied larger shape, active attacks, equipment failure, inventory shortcuts, no-heal limiter removal, base health<4, indirect/duplicate deaths, banished victims, existing crimes, quest-required spawns and long advances across multiple events. Required-data/transition failure is explicit recovery, not default-type substitution, silent cure or partial equipment loss.

## Configuration and balancing options

Validated infection types/acquisition/windows, voluntary cooldown/lunar forcing, condition/form bonuses/protections, action masks/equipment/attacks, urge/satiation, Ring exceptions, crime/population/reactions and cure/quest policies. Added conditions/forms use shared versioned registration and owner adapters. Exact selector precedence/allowed numeric domains are required; optional visuals cannot redefine authoritative form.

## Save/load considerations

Persist actual infection/type/form, milestones, cooldown/initial-entry readiness, kill timestamp, limiter and source facts, Ring/equipment state and completed transitions/cure/quest obligations. Native restore never heals, rerolls infection, re-unequips hands, resets urge/cooldown or emits a fresh equip event. Rebuild derived source state after required owners are ready; preserve actual movement/shape/equipment without treating load as a new morph. Missing required definitions/assets invoke migration/recovery, not silent human/werewolf fallback. Mod timing migrations follow MAGIC-008; save only coherent supported transition boundaries.

## Technical constraints

Target Godot 4.7.2. Separate condition/form state, timing, pure eligibility, equipment/combat/movement settlement and optional presentation. Use idempotent owner operations and stable completion identities; no per-frame permanent stat writes, scene-global fallback identities or observer-triggered kills/grants. Concrete staging/rollback and required recovery interfaces remain engineering work. No implementation/coding tasks authorized.

## Acceptance criteria

1. Matching eligible hits resolve exact retained infection probability/type without redundant reset or incompatible-condition replacement.
2. Elapsed24/72h hidden infection milestones and cure window work independently of video, in place without vampire relocation.
3. Condition/form/birth identity remain distinct, with independently owned abilities and safe scoped reversion/cure.
4. Successful voluntary entry starts24h cooldown with exact-boundary admission; revert/forced entry do not restart it.
5. Either full moon forces at round boundaries unless exempt; brief reversion allowed, no implicit full-moon-end revert.
6. No acquisition/morph/reversion/cure healing; condition bonuses and beast-only material protection apply once through caps/owners.
7. Beast entry safely unequips hands without item loss, attack substitution or geometry bypass; reversion does not auto-equip.
8. Beast action restrictions cover shortcuts and permit explicit normal-contract reversion; mod masks supported.
9. Monthly source limiter follows elapsed formula, no heal on satiation/removal; qualified attributed civilian/watch deaths count once in either form.
10. Beast charge exemption retains incidents/existing crimes; population suppression does not erase actors or quest spawns.
11. Ring exceptions suspend applicable restrictions without timer reset/heal/fresh-load grants; removal reconciles current state.
12. Long advances settle actual chronological consequences and stop at required form handoff; pause/load zero elapsed.
13. Cure/quest settlement and native restore preserve source identity, equipment, timestamps and completed facts without replay.
14. Mod-added transformations/forms use shared validated lifecycle/compatibility/persistence contracts.

These are future verification criteria; no implementation/runtime tests performed.

## Consistency review

Reviewed against CHAR-019/018, MAGIC-008/010/028 and COMBAT-011. No-heal transformation intentionally replaces source refill behavior and retains vital maximum rules. The urge limiter cannot increase a lower capacity. Disease special bypass does not generalize other diseases. Restored form is not fresh entry/equip. Crime exemption retains truthful incidents. In-place lycanthropy establishment remains distinct from vampire apparent-death absence. Mod extensions preserve default compatibility and required provider recovery.

## Outstanding questions and approval

No further blocking player-policy question identified. Dependencies: full type/ability/attack/appearance mappings; action-mask reconciliation including potion shortcuts; hand/shape/attack transition boundaries and forced blocked-shape recovery; first-entry readiness and lunar/Ring tie ordering; exact urge rounding/kill attribution; quest/population/crime adapters; schema/provider migration and representative native fixtures. Material gameplay changes found during integration return for review; these dependencies do not waive no-heal, scoped identity or mod-extension requirements.

The user explicitly approved the complete Draft v1 on 2026-11-10 with “I approve”. This specification is finalized v1 under MAGIC-029-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented integration and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
