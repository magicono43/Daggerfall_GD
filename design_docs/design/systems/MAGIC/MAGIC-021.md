# MAGIC-021 — Disease and cure lifecycle

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Manage accepted infection, incubation, chronological disease progression and cure/recovery while preserving source-owned penalties, knowledge and transformation boundaries.

## Intended player experience

Default ordinary diseases affect players level two and above, progress on calendar-day boundaries and may end naturally or require treatment. Attribute healing can repair symptoms without curing the disease. Natural recovery or cure clears remaining disease-owned penalties without refilling lost pools. Mods can extend susceptibility, timing, progression, diagnosis and remedy policies beyond classic definitions.

## Confirmed requirements

MAGIC-021-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm extensible profiles, default susceptibility/day boundaries, binary exposure save, same-type redundancy, cure scope, natural recovery, repair, full chronological progression, retained randomness, knowledge and native persistence. The complete specification is approved under MAGIC-021-A01.

MAGIC-018 disease repair/cure distinction, MAGIC-008 elapsed accounting, MAGIC-006/009 source admission/cleanup and RULE-017 resistance remain binding. Established transformations remain separately owned; ordinary disease cure does not erase them.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full disease/transform/runtime fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/`.

- `MagicAndEffects/Effects/Diseases/DiseaseEffect.cs#Start` rejects nonplayers/level<2, records current calendar day and resolves finite duration. MagicRound delegates to a custom day-based UpdateDisease; same-key AddState does nothing.
- `UpdateDisease` processes crossed days, then adjusts finite duration; target must explicitly stop at lifetime rather than apply excess events from a large jump. IncrementDailyDiseaseEffects adds negative stat contributions and separately changes current pools. EndDisease marks completion for cleanup.
- `Formulas/FormulaHelper.cs#InflictDisease` accepts a player target above level one, resolves SavingThrow, selects a random disease from a list and assigns with saving bypass. Manager hard-immunity/special-infection gates also participate; exact target composition follows approved explicit rules rather than every source shortcut.
- `EntityEffectManager.cs#CureAllDiseases` removes disease bundles; CureDisease finds a specific class/type and marks cured. Source bundle classification alone is not a complete native ordinary/special/established transformation remedy policy.

## Detailed rules and behaviors

### Profiles and default susceptibility

Each disease profile declares stable identity/version, susceptible actor categories, incubation, progression clock/cadence, finite count or until-cured lifetime, ordered payloads, cure eligibility and knowledge rules. Verified classic ordinary content forms initial baseline; new profiles need not fit classic enum/file limits.

Default ordinary eligibility is player-only, level≥2. Support validated mod NPC infection and altered level protection with complete progression/persistence/cleanup support. Accepting an NPC infection then silently discarding its lifecycle is invalid. Content-specific immunity, race/career and special infection permissions remain explicit, separate from level/category eligibility.

Special transformation infections declare their own exceptions/windows. Do not automatically apply ordinary susceptibility/cure or a blanket hard-immunity bypass. Established transformation state is not the incubating infection and follows its own removal rules.

### Exposure, selection and re-exposure

Default ordinary exposure resolves one RULE-017 binary saving result: R=0 rejects, R>0 admits the full disease. No default progression-time saves or scaled payload/duration from fractional retained percentage. Validated mod alternatives may define potency/duration scaling or recurring checks with explicit identity/cadence.

Apply explicit hard-immunity composition/permissions under MAGIC-006/RULE-017 without double exposure saves. Missing required context/provider is technical recovery, not resistance or a silent immunity exception. Creature activation and physical-hit delivery remain RULE-016/COMBAT-011; disease lifecycle does not multiply attack attempts.

Where an exposure declares a disease candidate list, resolve its selection and randomized duration once for the accepted infection; retain result/selection context. Uniform or weighted/alternative selection must be explicit under validated profile, not registration order. Same-type re-exposure leaves the existing illness unchanged by default; distinct types coexist. No hidden incubation/duration reroll on redundant exposure. Mod severity/refresh/replacement/independent instance policies may differ under source-owned MAGIC-009 rules.

### Incubation and progression

Default progression aligns to shared calendar-day boundaries, first progression at the next day boundary after infection, not a full elapsed 24 hours. Profiles may use explicit elapsed-hour or gameplay-second incubation/cadence under MAGIC-008. Record units/alignment so short pre-midnight incubation is intentional rather than an undocumented timer bug.

Finite ordinary disease progresses for its declared event count; until-cured profile continues until valid removal. Per-event random payload resolves once and retains actual outcomes. Process only events within active lifetime, then natural recovery; never damage for extra days before noticing finite lifetime ended.

All authorized rest/travel/prison advances process required due events chronologically, settle pool damage/prevention/exhaustion/death/cure and stop at applicable interruption's actual simulated time. No generic catch-up cap loss or specialized-plus-generic duplicate tick. Ordinary pause/load/offline wall time contributes no progression. Equivalent bulk handling must preserve outcomes under MAGIC-008.

Payloads use explicit typed pool units and source-owned modifiers through MAGIC-017/018/CHAR. Disease does not automatically inherit ordinary Drain's permanent−1 floor. Attribute-zero consequences require owner-defined valid operations; this feature does not invent a new death or blanket safety rule. Exact base payload values/classifications require fixtures.

### Repair, natural recovery and cures

Attribute healing can repair ordinary disease-owned penalties under approved MAGIC-018 without curing/resetting incubation, shortening lifetime or preventing future damage. Preserve permanent values/unrelated contributions; each disease tracks its remaining penalty. Profiles may explicitly declare unhealable/exceptional penalties through approved mod rules.

Finite ordinary disease natural recovery removes its remaining owned penalties after the final declared progression event, leaving prior health/fatigue/magicka loss unrecovered. Unlike poison's default residual phase, ordinary disease does not retain those penalties after normal recovery. Lasting-aftereffect profiles must explicitly declare different behavior. Until-cured disease has no implicit natural completion.

Ordinary Cure Disease removes all eligible ordinary diseases, including incubating infections, and their remaining owned contributions. No old full-stat snapshot restore or lost-pool refill; repairing first then curing cannot grant bonus points. Unrelated poison/drain/other-source modifiers remain intact.

Selective remedies, type/family targeting and special-infection cure windows are configurable explicit policies. Cure admission/chance still follows source rules; no universal cure success inferred merely from function naming. Established vampirism/lycanthropy or other transformations use their own cure contracts rather than ordinary removal. Exact ordinary/special eligibility inventories remain content work.

Removal/recovery is coherent and idempotent under MAGIC-009, including derived pool limits. No transient clear-all clamp, free refill, repeated grant or replayed transformation on cleanup.

### Knowledge, symptoms and attribution

Profiles control symptom onset/messages, diagnosis, disease name and remaining-duration disclosure. Appropriate baseline symptoms may be retained without automatically revealing every incubating illness or exact hidden countdown. Explicit mod/diagnosis knowledge may reveal more. Inspecting possible illness cannot roll infection or disclose otherwise hidden state.

Hidden HUD state does not pause progression. UI derives actual authoritative effects under MAGIC-010 within knowledge policy; no icon capacity can cap illnesses. Retain stable infecting actor/item/exposure attribution after source leaves scene. Ordinary disease does not require ongoing original caster.

Tick/symptom/cure callbacks do not automatically become new attacks/crimes/casting practice. NPC/LAW/QUEST define truthful attempt/loss/death/cure reactions with retained event identity. Optional presentation cannot mutate illness or reroll its progression.

## Relevant formulas and parameters

Default susceptibility player and level≥2; default first event at next shared day; binary exposure R=0 reject/R>0 full profile. Finite active event count limits progression exactly; until-cured explicitly unbounded by duration. No universal disease magnitude, incubation-hours value, cure price or post-cure immunity period is selected. Classic duration/payload/random endpoint mapping needs verification, not a guessed global constant.

## Required data

Stable profile/version/infection/exposure/source/recipient IDs; susceptibility and hard-immunity permissions; candidate selection/save/duration results; incubation alignment/state, next event/count/clock; typed payload outcomes and remaining repaired penalties; natural/cure/special-window status; knowledge/diagnosis flags; completed/pending operation facts. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: authorized exposure, current susceptibility/defense, due calendar/profile event, healing/cure/diagnosis, lifecycle and native restore. Outputs: resisted/redundant/new/severity-modified infection; progression/consequences; scoped recovery/cure; knowledge-safe symptoms or explicit failure/recovery. API/signal names unselected. Symptom notification does not authorize another progression or exposure.

## Cross-system interactions

RULE-016/COMBAT-011 creature/hit delivery, RULE-017/001/003 resistance/RNG; MAGIC-006 admission, MAGIC-008 clocks, MAGIC-009 source overlap/cleanup and MAGIC-010 save/HUD. MAGIC-018 repairs/cure boundary, MAGIC-017 typed pool loss; CHAR attributes/vitals/death/exhaustion. Transformation features own established state/cure; NPC/LAW/QUEST reactions, TIME interrupted advances and DATA/MOD profiles. SAVE/CORE-013 gate native compatibility/reconstruction.

## Edge cases and failure conditions

- Infection just before midnight: next-day event may be soon; no unintended full-day delay or duplicate initial damage.
- Level-one/NPC default blocked: valid explicit profile can change eligibility only with working lifecycle, not silent source workaround.
- Same-type exposure: no default reset/reroll; different diseases retain independent penalties/knowledge.
- Heal then disease progresses: repaired penalty can recur, no implicit cure. Heal then cure/natural recovery: no bonus/full-stat snapshot.
- Long jump exceeds finite duration: only due active events, then cleanup; lethal event stops before requested future time.
- Special infection versus established transformation: use explicit eligibility/window, no ordinary cure erasure or replayed transformation.
- Missing infecting actor: disease continues with stable attribution; required provider incompatibility remains explicit recovery.
- Restore/diagnosis/UI: no reinfection, countdown reset, progression replay or hidden illness leakage.

## Configuration and balancing options

Validated susceptibility/level protection, candidate weights, incubation/cadence/lifetime, payload/severity/re-exposure, cure/aftereffect and diagnosis policies are moddable. Support NPC and alternate timing profiles end-to-end. Default remains DFU-style ordinary player eligibility/day progression with explicit safe lifetime accounting. No universal contagion spread, epidemic simulation, addiction or new transformation mechanics are implied; such content needs explicit profiles/owner review.

## Save/load considerations

Preserve accepted disease identity/source, retained selection/duration/save and completed payload outcomes, incubation/next progression/remaining count, penalties/repair, cure/recovery and knowledge state. Restore without reinfection, initial/progression damage or cure reward replay. Future genuine event RNG follows fresh-load policy without replacing saved results.

Timing/provider changes use MAGIC-008/010 supported migration/continuation/recovery, not reset incubation or silent effect loss. Established transformations remain separately owned, not reconstructed by rerunning infection. Coherent boundaries or supported retained partial work required for progression/cure/transform transitions; exact schemas/migrations SAVE-owned. Classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. Explicit disease lifetime/profile replaces hard-coded forced-round/completion sentinels as architectural requirement; implementation may differ. Maintain stable event/source identities, finite-count safety and coherent owner cleanup. Exact susceptibility adapters, cure selection, diagnosis schemas and native serialization remain technical design. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Explicit profiles/default player≥2/day-boundary behavior and supported mod actor/timing alternatives progress/persist correctly.
2. One binary exposure save and stable candidate/duration outcomes, default same-type redundancy/no reroll and distinct coexistence.
3. Only active-lifetime events execute chronologically through authorized jumps, with death/interruption/no duplicate tick or catch-up discard.
4. Attribute repair leaves cause/lifetime intact; natural/cure cleanup removes own penalties only without pool refill or double restoration.
5. Cure-all includes eligible incubating ordinary diseases, selective/special windows explicit and established transformation protected by its own rules.
6. Symptoms/diagnosis respect hidden knowledge without changing progression or consuming RNG.
7. Native restore retains infection/repair/phase/cure state without reinfection/transform replay and recovers required incompatibilities safely.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-008–010/017/018/020, RULE-017 and CORE-013 boundaries plus MAGIC-021-D01–D12. No direct contradiction identified. Delayed disease first application is explicit timing policy, binary disease admission is declared family interpretation. Natural disease penalty cleanup differs deliberately from poison residual default. Repair/cure preserves MAGIC-018's confirmed source semantics. Player level protection is disease-specific, not copied to poison. Special infections/transformations retain separate owners; full elapsed handling fixes source overrun risk without altering unverified values implicitly.

## Outstanding questions

No further blocking disease-lifecycle player-policy choice is identified. Before implementation is complete: fixture-map classic profiles/random endpoints/susceptibility classifications; define candidate/severity/cure/diagnosis schemas and special windows; integrate NPC lifecycle, attribute-zero consequences, calendar tie order and coherent infection/progression/transform save migrations. These deferrals cannot authorize hidden duration reroll, extra damage beyond recovery, universal cure of established transformations or silent required-state loss.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: MAGIC-021-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented classic profile fixtures, susceptibility/cure/diagnosis schemas, special infection windows, NPC/calendar integration and native recovery/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
