# MAGIC-028 — Vampirism infection and curse

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose and intended player experience

Acquire a hidden, curable infection that can progress into a persistent clan-defined vampire condition. Provide meaningful powers, feeding and environmental restrictions with safe transformation/cure and native persistence. Support mods adding different transformation conditions and forms, not just changing built-in vampire values.

## Confirmed requirements

MAGIC-028-D01–D19 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record six interviews and the explicit request for additional modded transformations. The complete specification is approved under MAGIC-028-A01. CHAR-019 birth identity/source-owned grants/compatibility, CHAR-011/018 caps/vitals, MAGIC-008–010 timing/persistence and MAGIC-021 ordinary-versus-special disease boundaries remain binding. MAGIC-029 must carry forward the shared transformation extension requirement without treating its lycanthropy details as already reviewed.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths relative to reference `Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#OnMonsterHit` uses `specialInfectionChance=0.6f` for vampire/ancient-vampire attacks against the player, assigning a special infection. `Game/MagicAndEffects/EntityEffectManager.cs#AssignBundle` permits explicit special-infection disease-immunity bypass. `Effects/Diseases/DiseaseEffect.cs#Start` rejects nonplayer/level<2 disease recipients.
- `Effects/Diseases/VampirismInfection.cs` stores starting calendar day and infection region; redundant incumbents terminate without restarting symptoms. `ProgressDisease` schedules a dream after daysPast>0 and apparent-death video after daysPast>3 once the dream played, despite comments describing three days. The target explicitly chooses elapsed 24/72-hour milestones instead.
- Its transformation callback advances two weeks plus an hour-of-day adjustment, chooses a cemetery in the current region, relocates the player, assigns vampire spells and starts the curse. The target explicitly treats time/destination as gameplay commitments independent of video callbacks.
- `Effects/Special/VampirismEffect.cs#Start` derives a compound birth-race template, takes clan from infection, starts satiated and calls broad `CureAll`. `EntityEffectManager.CureAll` refills vitals and cures poison/disease/attribute/skill damage. Target scoped cleanup deliberately replaces this broad restoration.
- `ApplyVampireAdvantages` adds +20 to STR/WIL/AGI/END/PER/SPD/LUCK and Anthotis INT, plus +30 Jumping/Running/Stealth/Critical Strike/Climbing/Hand-to-Hand. Constant state provides disease/paralysis immunity and Silver minimum material. Compound race adds sunlight/holy-place vulnerabilities.
- `Game/Entities/PlayerEntity.cs#AssignPlayerVampireSpells` supplies common and clan spells, tags them and marks minimum casting cost. `VampirismEffect.OnWeaponHitEntity` refreshes feeding time; `IsSatiated` uses <=one day. `CheckStartRest` rejects hunger; `CheckFastTravel` rejects daytime departure.
- `Effects/Special/PassiveSpecialsEffect.cs` applies 12 sun/holy health damage every four magic rounds while exposed, using player-global environment checks. Target uses affected actor context and persisted timing phase.
- `VampirismEffect.CureVampirism` advances one minute for cleanup, stores previous clan, deletes tagged spells and terminates quests by name prefix. Target uses scoped entitlements and explicit quest outcomes instead. Infection/curse save data retain milestone flags, clan, feeding time and initial quest status.

Static inspection only; no runtime/classic-parity verification. Source TODOs about membership/reputation resets do not establish approved consequences.

## Detailed rules and behaviors

### Acquisition and compatibility

Default vampire and ancient-vampire qualifying physical hits expose player recipients of level>=2 with exact 0.6% chance per hit. Use COMBAT/RULE's approved positive-initial-damage creature-ability trigger, not cosmetic contact, preview or repeated observers. Resolve one retained exposure draw per qualifying hit; fractional-percent probability must not be rounded to a whole-percent helper. Exact RNG representation follows RULE-003.

This special infection explicitly bypasses ordinary disease resistance/immunity; it is not permission for all diseases to bypass immunity. Respect active-condition compatibility. CHAR-019 defaults to one active racial transformation condition, rejecting incompatible acquisition without replacing or curing the existing condition. Redundant infection does not reset incubation or reroll clan. Latent versus active compatibility follows declared policies; unsupported combinations cannot publish partial identity.

Chance, source/recipient eligibility, trigger, special bypass and reinfection/strain behavior are moddable through validated profiles. Mod NPC recipients need supported actor lifecycle/identity adapters rather than global-player references. Missing required definitions are technical failure, not successful infection or assumed immunity.

### Clan and infection milestones

Resolve default clan from the acquisition region at accepted infection and retain its stable identity through travel/loading. Do not switch clan based on current region at transformation. Complete baseline region/clan mappings require content fixtures; missing required mapping is not implicit Lyrezi. Mods may select clan/strain from source vampire, location, quest or spell.

Record accepted infection time. Default warning milestone is 24 elapsed game hours; transformation milestone is 72 elapsed game hours. This is not calendar-midnight progression. Pause/load/offline wall time contributes zero. Process rest/travel and other authorized advances chronologically under MAGIC-008, stopping at transformation before finishing the requested interval.

Initially hide exact disease identity/countdown. Warning dream conveys risk; explicit diagnosis or modded UI may reveal more. Ordinary Cure Disease may remove eligible infection before transformation commitment; established vampirism requires dedicated cure. Timing, stages, warning presentation and cure windows/remedies are moddable. No duplicate dream, clan roll or transformation from redundant infection/recovery.

### Apparent-death transformation

At the due transition, prevalidate compatibility, required clan/grants/appearance, world destination and owner settlement. Default sequence represents apparent death, two weeks of absence and awakening in a suitable cemetery at night. It is not ordinary confirmed death/resurrection and emits no normal player-death consequences by inference.

Choose and retain a suitable cemetery through a declared location policy, validating geometry/placement with MOVE-027 before commitment. Source uses current region; exact baseline cemetery pool, exclusions and night alignment need WORLD/LOC/TIME fixtures. Missing content invokes explicit recovery rather than unrelated fallback. Retain resolved random destination so retries cannot reroll it. Night alignment must not silently shorten the approved two-week absence; exact resulting timestamp requires a documented TIME policy.

Process the two-week advance as an explicit transformation-owned elapsed interval, not loading/video wall time. Preserve unrelated effects and settle required due events through MAGIC-008/CHAR, with interruption/death rules explicitly reconciled before implementation. Transformation transition handling cannot silently clear detrimental effects merely to avoid those obligations. Exact protected/ordinary-exposure context during apparent death requires a declared owner profile; no free invulnerability or generic simulated-route exposure is inferred.

Commit condition, elapsed-time work, location placement and source grants coherently with stable completion facts. Validate before destructive changes, keep required gameplay gated during unresolved reconstruction and recover from known partial commitments rather than replaying the whole sequence. Cinematics may accompany but cannot authorize gameplay completion; missing/failed video does not lose the condition, repeat time/relocation or duplicate grants. Timing, destination and presentation are moddable.

### Identity, grants and transformation cleanup

Preserve birth race, portrait/gender and independently learned abilities under CHAR-019. Derive effective vampire identity/appearance and source-owned modifiers without overwriting birth data. Inherit birth traits unless explicit profile replacement/suppression applies; protection stacking uses its owner rules.

Baseline source modifiers: +20 STR/WIL/AGI/END/PER/SPD/LUCK; Anthotis also +20 INT. Add +30 Jumping, Running, Stealth, Critical Strike, Climbing and Hand-to-Hand. Apply once, with CHAR-011's moddable caps and CHAR-018 vital reconciliation; rebuilding a source does not repeatedly add permanent points or refill a growing maximum.

Provide explicit disease/paralysis immunity and Silver-or-better physical material protection through CHAR/COMBAT capability contracts. These are not immunity to every damage source or unconditional death prevention. Add sunlight/holy-place vulnerabilities. Clan-specific values, protections and inheritance/compatibility are moddable.

Common spell entitlements: Levitate, Charm Mortal, Calm Humanoid. Baseline clan assignments: Vraseth Nimbleness; Khulari Paralysis; Montalion Recall; Thrafey Heal; Garlythi Shield; Selenu Resist Cold/Fire/Shock; Lyrezi Silence/Invisibility; Haarvenu Ice Storm/Wildfire. Anthotis's listed special grant is its INT bonus. Verify exact stable spell records/settings/cost profiles before implementation; do not infer free casting from a vampire tag. Clan grants and casting profiles are moddable.

Grant through owning vampire source, preserving independent learned/other-source access on cure. Rebuild/load cannot duplicate grants or reset ongoing spell state. Remove incubating vampirism infection at completed acquisition; preserve unrelated diseases, poison, drains and current deficits. No broad CureAll or automatic vital refill. Explicit mod transformation profiles may declare restoration benefits through owners. New vampire begins satiated when condition establishment commits, not on every rebuild.

### Feeding and hunger

Default feeding occurs on a qualifying physical weapon/unarmed hit, without a kill or separate feeding interaction. Refresh last-fed game time once per qualifying operation. No automatic extra heal, drain or victim damage. Exact hit/target eligibility must be explicit in COMBAT-011/MAGIC adapters; source comments alone do not approve undead/construct/environmental feeding. Mods can define target/hit predicates, bites, sleeping-target interactions and other blood sources.

Satiated iff elapsed game time since last successful feeding <=24 hours. Hunger begins after that inclusive boundary. No default starvation damage or invented hunger stages. Hunger prevents rest start and interrupts ongoing rest when satiation expires. TIME must preserve the inclusive predicate and stop before simulating hungry rest; exact clock-resolution boundary treatment is a fixture dependency, not permission to shift the window by minutes.

Pause/loading adds no hunger time; authorized travel/other elapsed advances do. Feeding duration, rest restrictions and penalties are moddable. A resumed/load state does not feed automatically; initial satiation belongs only to genuine condition acquisition.

### Sunlight, holy places and travel

Default each active vulnerability applies 12 health damage every four game minutes while its exposure predicate is true. Use affected actor's actual environmental context, not player-global exposure for every actor. Sunlight/holy-place definitions must be authoritative WORLD/LOC inputs independent of brightness, shaders, optional visuals or sound.

Use MAGIC-008 clocks with saved phase and chronological elapsed handling; do not reset hazard phase on load, scene change or source rebuild. Default cadence does not imply an extra initial damage tick merely because a condition was reconstructed. Exact shared-boundary alignment and first genuine due event need fixtures. Distinct sun/holy exposures are explicit damage sources, with ordering/composition through CHAR/MAGIC, not duplicated handlers.

Route health loss through approved protection/damage/death handling, including applicable MAGIC-022 Shield coverage rather than bypassing the owner because source calls DecreaseHealth. Damage, cadence, exposure, protection eligibility and clan rules are moddable. Settle lethal/prevented outcomes before processing later time events.

Default ordinary fast travel rejects daytime starts, allows nighttime starts and grants no exposure immunity. Travel owner must account for actual elapsed route exposure and stop at applicable harm/transformation events; departure approval is not permission to finish daylight travel unharmed. Exact route shelter/exposure samples require TIME/WORLD contracts. Mods may allow protected daytime travel or alternate restriction/interrupt policies.

### Cure and social/quest coordination

Ordinary disease cure treats the incubating infection under its explicit window; ordinary dispel does not silently remove established vampirism. Dedicated cure validates authorization and required restoration data, then removes only vampire-owned modifiers/protections/vulnerabilities/hunger restrictions/appearance and entitlements. No artificial one-minute time advance to trigger cleanup, vital refill or unrelated-effect removal.

Preserve independently learned abilities, unrelated sources, current deficits and birth identity; clamp vitals only where owner maximum decreases require it. Retain previous-clan history when required by explicit quests. Repeated cure/retry cannot strip unrelated spells or replay rewards. Cure requirements/benefits and alternative lifecycle outcomes are moddable.

QUEST/FACT own clan offerings, initial/cure quest progression and social consequences through explicit stable identities/eligibility/outcomes. No blanket faction membership/reputation reset, name-prefix quest deletion or automatic legal absolution. Each affected quest declares acquisition/cure transition and required acknowledgment. Source random offer percentages are not adopted as a complete reviewed quest scheduler; offering rates/pools/eligibility and reactions remain moddable owner policies.

### Mod-added transformations

Explicitly support new transformation conditions and forms beyond vampirism and lycanthropy, carrying CHAR-019's extension requirement into MAGIC lifecycle design. Registration must not require editing hard-coded vampire/werewolf-only switches for supported data-driven additions.

Versioned stable definitions can declare acquisition/infection stages, clocks, condition/form distinction, clan/strain variants, identity/presentation mappings, trait inheritance/suppression, ability entitlements, modifiers/protections/hazards, feeding/resource interactions, action restrictions, cure/reversion and quest hooks. Lifecycle operations use their authoritative owners and validated extension points; genuinely new executable mechanics require supported adapters, not arbitrary side effects in a definition query.

Declare compatibility/precedence explicitly, including optional combinations and which source controls physical form/presentation. Default one-active-condition remains. Additions need save/migration, required asset/provider validation and source-specific cleanup; do not silently cure an unknown saved condition or replace birth identity. The capability is required across MAGIC-028/029; this document does not preapprove unspecified hybrid balance or lycanthropy gameplay details.

## Relevant formulas and parameters

Default infection probability 0.006 per qualifying hit, player level>=2. Warning +24 game hours; transformation +72 game hours. Apparent absence two weeks followed by validated night alignment. Listed +20 attributes/+30 skills; Efeed<=24h satiated. Exposure damage 12 per four-game-minute event per applicable vulnerability. Exact spell settings, cemetery/night selection, hazard phase alignment and mod numeric domains require validated fixtures.

## Required data

Stable condition/form/clan/provider versions; exposure identity/roll/source/region; accepted infection time, milestone deadlines/completion/knowledge; selected clan and destination; transition/time-advance/placement/grant completion facts; preserved birth identity and source-owned modifiers/entitlements; last-fed time and feeding identity; hazard phase/exposure profile; current cure/quest/social obligations and previous-clan history; compatibility/migration policies. Concrete schemas/API names remain dependencies.

## Inputs, outputs and events

Inputs: qualifying hit/exposure, cure/diagnosis, eligible calendar advance, milestone due, validated world placement, feeding hit, rest/travel request, environmental exposure, authorized quest/cure and native restore. Outputs: accepted/rejected infection, warning, condition acquisition, absence/arrival, coherent grants/identity, satiation/hunger restrictions, damage/interrupt results, source-scoped cure and acknowledged quest facts. Notifications describe committed stages rather than authorize duplicate gameplay. APIs/signals unselected.

## Cross-system interactions

CHAR-019 identity/compatibility/grants, CHAR-011/018 caps/vitals and CHAR death prevention; COMBAT-011 creature/feeding predicates and material capabilities; MAGIC-008–010 clocks/persistence, MAGIC-021 infection cure scope and MAGIC-022 protections; MOVE-027 placement; WORLD/LOC/TIME cemeteries, night/route/exposure/advance interruption; QUEST/FACT clan/cure/social progression; ITEM learned versus source access; UI/AV warning/appearance/cinematics; DATA/MOD added transformations/provider validation; CORE/SAVE coherent gated transition and migration/recovery.

## Edge cases and failure conditions

Cover redundant/competing infection, already active incompatible condition, cure at milestone boundary, level-one recipient, immunity bypass versus compatibility, region change, missing clan/ability/cemetery, long travel crossing both warning/transformation, video failure, death during authorized elapsed work, simultaneous hunger/hazard events, fractional feeding boundary, weapon hits against questionable blood sources, cure during pending quest and load mid-lifecycle. Deterministic simultaneous-event ordering must be declared before implementation, preserving known commits rather than callback order.

## Configuration and balancing options

Validated infection chance/eligibility/bypass, stages/cure windows/clan selectors, transition absence/destination/presentation, grants/protections/caps, feeding/hunger, exposure/cadence/travel/rest rules, cures/social policies and new transformation definitions. Exact selector precedence/domains and owner adapters remain required. Cosmetic variants cannot alter authoritative timing/eligibility merely by failing to render.

## Save/load considerations

Persist actual infection/condition stage, clan, deadlines/completed milestone facts, last-fed time, hazard phase, grants and transition/cure/quest results. Loading cannot restart incubation/satiation, replay videos/time jump/relocation, reroll clan/destination or duplicate grants. Save only coherent owner state at supported boundaries; unresolved partial transformation/cure work uses CORE/SAVE gating/recovery. Derived race templates/appearance reconstruct from authoritative sources and preserved birth state. Missing required definitions/assets use explicit migration/recovery, not silent Lyrezi/default form/cure. Mod timing changes follow MAGIC-008's migration/continuation policies.

## Technical constraints

Target Godot 4.7.2. Separate infection scheduler, condition/form sources, timed hazards, feeding, owner-authorized transformation/cure and optional presentation. Durable completion identities are required; video callbacks and per-frame constant rebuild cannot own grants or elapsed time. Mod additions use reusable contracts instead of a closed built-in enum as the only identity. No general transaction framework is mandated, but partial-owner failure must be recoverable without replay. No implementation/coding tasks authorized.

## Acceptance criteria

1. Qualifying baseline hits resolve one exact 0.6% exposure with explicit special bypass, level/compatibility rules and no redundant timer/clan reroll.
2. Infection retains acquisition-region clan and elapsed 24/72-hour milestones, remains initially hidden and is curable before establishment.
3. Long advances stop at transformation; pause/loading adds no disease time.
4. Apparent-death transition validates destination/grants, commits two-week/night awakening once and does not depend on video success or emit ordinary death.
5. Birth identity and independent sources survive; listed bonuses/protections/grants are source-owned, capped/moddable and idempotent.
6. Acquisition removes only its infection by default, preserves unrelated ailments/current deficits and starts satiated once without vital refill.
7. Qualified physical feeding refreshes timer without extra drain/heal; exact 24-hour inclusive window governs start/interruption of rest.
8. Sun/holy damage uses actual actor exposure, saved four-minute phase and approved damage owners independent of rendering.
9. Daytime travel start restriction does not grant nighttime-departure exposure immunity; authorized time settles applicable interruption once.
10. Dedicated cure removes only vampire contributions without artificial time/vital refill, preserving learned spells and required history.
11. Explicit quest/social policies replace blanket resets/prefix deletion and do not replay through restore.
12. Mods can register additional transformation conditions/forms with lifecycle, compatibility, grants, assets and versioned persistence through supported contracts.
13. Native load restores stage/feed/hazard/transition facts without rerolls, cinematics, grants or absence/arrival replay; missing required content invokes recovery.

These are future verification criteria; no implementation/runtime tests performed.

## Consistency review

Reviewed against CHAR-019, MAGIC-008/010/021/022 and COMBAT-011. Explicit special-infection bypass does not generalize ordinary disease immunity. Elapsed 72-hour policy intentionally replaces source day-boundary timing. Scoped cleanup avoids CHAR-019 vital-refill contradiction. Physical feeding and infection use explicit distinct predicates. Environmental damage honors protection owners. Apparent death remains distinct from confirmed player death. Shared mod-added conditions reinforce approved CHAR extension rather than silently approving hybrids or MAGIC-029.

## Outstanding questions and approval

No further blocking player-policy question identified. Required dependencies: exact feeding target/hit predicates; condition compatibility at infection/milestone boundaries; cemetery pool/night alignment and two-week exposure/time settlement; full grant/cost/content mappings; hazard phase and simultaneous-event ordering; route exposure/rest boundary fixtures; quest scheduler/cure acknowledgment; mod registration/adapter schemas and native migration. These do not waive no-replay, scoped cleanup or new-transformation extension requirements. Material gameplay choices discovered during integration return for review.

The user explicitly approved the complete Draft v1 on 2026-11-10 with “I approve”. This specification is finalized v1 under MAGIC-028-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented integration and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.

