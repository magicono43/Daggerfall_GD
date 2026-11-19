# MAGIC-030 — Career passives and artifacts

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose and intended player experience

Apply career advantages/disadvantages predictably and give exceptional artifacts explicit, reviewable activation rules. Separate passive capabilities, triggered payloads and permanent reward entitlements. Support mod-added passive and artifact profiles without duplicating outcomes or embedding gameplay in cosmetic callbacks.

## Confirmed requirements

MAGIC-030-D01–D30 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record ten interviews, each confirmed with three “Yes” answers. The complete specification is approved under MAGIC-030-A01. CHAR-005/011/015/018, RULE-003/016/017, COMBAT-010/011, MAGIC-007–010/016/019/027–029 and CORE/SAVE contracts remain binding. This feature does not claim every career ability or general enchantment family is implemented by the passive controller.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths relative to reference `Assets/Scripts/`, chiefly `Game/MagicAndEffects/Effects/Special/`:

- `PassiveSpecialsEffect.cs` is explicitly described as work in progress. It maintains persistent state, runs regeneration/sun/holy damage every four magic rounds and applies environmental magicka modifiers. Regeneration is 1 health; sun/holy damage 12. Some predicates use player-global environment.
- Its Light-Powered disadvantage applies at night or indoors, Darkness-Powered in sunlight. Reduced variants subtract truncated raw-magicka×.33; unable variants use a huge negative modifier. Target chooses actor-local inputs and explicit zero capacity, not that sentinel.
- `RingOfNamiraEffect.cs` scales retaliation from supplied physical damage by enemy team (zero listed animals/Spriggans, half Daedra, double Undead, otherwise equal), changes enemy health directly and returns durability loss. Target validates actors, costs and owner-routed retaliation under approved post-primary phases.
- `OghmaInfiniumEffect.cs` sets shared level flags, opens character UI and removes the book. CHAR-015 replaces this with durable ordered artifact reward ownership.
- `MaceOfMolagBalEffect.cs` declares Held/Strikes, uses a binary magic save, drains magicka up to incoming damage or Strength1–6, permits overflow bonuses and clears them after >12 game minutes without a strike. Comments identify magicka transfer as description-based rather than confirmed classic observation. Source reseeds RNG by frame and may continue without live wielder state; neither is target behavior.
- `MasqueOfClavicusEffect.cs` adds live Personality/5 reaction modifiers for social groups. `MehrunesRazorEffect.cs` returns current target health as strike modulation and durability loss after a permitting magic save. Target makes scoped modifier and lethal semantics explicit rather than relying on accumulating callbacks or ambiguous additive returns.
- `SanguineRoseEffect.cs` requires a non-allied enemy within12 and spawns one allied Daedroth for100 condition. `SkullOfCorruptionEffect.cs` uses nearest eligible enemy type similarly. `Game/Utility/FoeSpawner.cs` is a generic placement helper without an artifact-specific summon timer and can retry placement asynchronously; target defines summon lifecycle and checked commitment.
- `WabbajackEffect.cs` excludes active quest foes/already transformed targets, selects a different monster from a17-entry pool, disables the old actor, creates a new one and carries absolute prior health damage. `SerializableEnemy.cs` retains WabbajackActive. Target preserves encounter identity/inventory and normal hit settlement rather than treating raw scene replacement as completion.
- `AzurasStarEffect.cs` exposes equipped capability and clears its stored soul on use, with no extra returned condition cost. Capture is elsewhere and governed here by approved MAGIC-027 one-soul arbitration. Hircine Ring and Skeleton Key exceptions remain MAGIC-029/027.

Static inspection only; no runtime/classic-parity verification. Source constants are adopted only where confirmed below. Other ordinary enchantment templates remain governed by MAGIC-015/016 and their detailed ITEM/effect profiles; this document inventories dedicated special artifacts, not every item enchantment's numeric behavior.

## Detailed rules and behaviors

### Shared passive and artifact ownership

Career, condition and item capabilities retain owning source identity. Rebuild restores contributions rather than adding another modifier/tick/reward. Removing one source cannot clear another surviving source. Same sun/holy vulnerability from career and vampire produces one hazard of that type by default; alternate stacking is explicit. General regeneration/other passive combinations declare composition through MAGIC-009; no hidden multiplication from flag sources.

Use affected actor's context rather than implicit player fallback. Passive profiles and new artifacts are extensible via validated stable definitions/owner adapters, with trigger, eligibility, captured/live inputs, defenses, cost, numeric basis, ordering, lifetime, source dependence, cleanup and persistence. A template's existence is not permission to expose unsupported behavior.

All triggered operations retain source/power/actor/session identity and completed phases. Follow MAGIC-016 and COMBAT-011: default positive-D0 strike eligibility, ordinary weapon wear separate from artifact costs, full declared condition before mutation unless explicit alternative, and last-condition committed payload completes before break cleanup. Do not stack standard ten-condition Used/Strikes wear on top of these explicitly declared artifact costs by accident.

Prepare required payload/world state before payment/mutation. Technical failure after partial commitment retains known facts for explicit recovery, not whole-operation reroll/refund/replay. A resisted effect may have its declared no-special-cost result without undoing ordinary attack wear. Queries, UI draws, reconstruction and optional AV cannot authorize another activation or practice award. Manual Used origin permissions remain MAGIC-016; automatic reactions do not inherit a new speech requirement.

### Career regeneration and hazards

Career regeneration baseline is1 health per four game minutes when its selected predicate holds: Always; Darkness = night or dungeon; Light = daytime and not dungeon (including an ordinary indoor building); Water = actual swimming under MOVE. These predicates intentionally differ from magery. Healing saturates at current maximum, does not revive and adds no bank at full health. Conditions/amount/cadence moddable.

Sun and holy vulnerability each apply12 health per four game minutes while actual relevant exposure holds. Reuse approved MAGIC-028 hazard contracts for current actor environment, saved phase, chronological progression and CHAR/MAGIC-022 protection/death settlement. Sharing a vulnerability does not duplicate it; simultaneous different vulnerabilities retain distinct ordered sources. Exact initial/shared-boundary phase requires fixture, not an invented load-time tick.

MAGIC-008 clocks and full authorized time processing apply to periodic work. Pause/load/offline wall time adds none; no scheduler startup modulo reset may postpone/repeat a saved event. Exposure, composition and timing alternatives moddable. Renderer brightness/shadow quality or missing optional visuals cannot change authoritative exposure.

### Environmental magery

Light-Powered magery disadvantage holds at night or anywhere indoors. Darkness-Powered disadvantage holds in actual sunlight. Magical illumination does not automatically change either; explicit mod light coupling supported. Resolve actor-local environment and coherent source state when conditions change.

Reduced power contributes -floor(.33×Mraw) to maximum magicka for validated nonnegative baseline Mraw. Use CHAR's declared raw premodifier capacity, not already-reduced current maximum, avoiding recursive shrinkage. Factor/base/composition moddable; exact handling of alternative signed inputs requires valid domains.

Unable variant explicitly imposes zero effective maximum magicka while applicable; no huge negative sentinel. Reconcile through CHAR-018: decreases clamp current, restored capacity does not refill. Other capacity modifiers cannot accidentally override a currently authoritative zero-capacity rule unless explicit composition changes it. This is a resource rule, not blanket magic-action prohibition: normal paid spells fail affordability, authorized free abilities and item/potion routes keep separate eligibility. Mods may instead block casting or preserve stored magicka with declared semantics.

### Ring of Namira

Default reaction requires positive resolved incoming physical D0 and a valid equipped source. Resolve after primary health/prevention settlement only if wearer remains alive/eligible under COMBAT-011. Do not subtract retaliation from original incoming damage.

Calculated retaliation A: zero for Vermin, Spriggans, Bears, Tigers, Spiders, Scorpions teams; floor(D0/2) for Daedra;2×D0 Undead; D0 otherwise. Stable explicit attacker-category data replaces unsafe EnemyEntity casts. Added/unsupported actor types need valid mappings rather than guessed access. Category/factor/trigger/actor policies moddable.

A is also condition cost. Require full available condition; A=0 means no damage/cost. Once per qualifying hit despite multiple copies; deterministically select one eligible equipped source and charge it only. Exact tie order and fallback when one ring lacks condition must be explicit. A valid last-condition reaction completes then breaks source once. Partial/final-underfunded/multiple-source alternatives moddable.

Apply retaliation through health/protection/death owners with attribution and chain context, not a fresh weapon attack that repeats poison/wear/Strikes. Reflection cannot trigger reflection by default; explicit bounded chains require COMBAT-011 budgets/visited context. Death-trigger retaliation is not default.

### Oghma Infinium

Valid use consumes one book and creates exactly one durable30-point attribute entitlement together. If entitlement creation fails, retain book; if UI fails after commitment, entitlement remains pending. Do not let effect callback and inventory result both consume a unit. No actual level or ordinary level-health award.

Use CHAR-015 ordered pending rewards without overwriting/interruption or unsafe combat allocation. Permanent allocation caps, unusable-remainder explicit confirmation and supported deferral remain CHAR-015. Reopening/load cannot regenerate benefit or consume another book. Amount/eligibility and supported reward parameters moddable through declared owners.

### Mace of Molag Bal

Positive-D0 strike checks its applicable binary magic save once. A permitted activation drains magicka up to D0 if target currently has any; otherwise resolve Strength drain1–6. No second save inside resulting drain. Gain is bounded by actual target loss, including MAGIC-019 Strength floor/capacity/attribution contracts; preview/retry cannot reroll1–6. Branches/amounts/defenses moddable.

Explicit artifact exception permits supported transferred magicka/Strength above normal capacity/cap using temporary source-owned modifiers. Increase only capacity needed to retain actual magicka transfer; keep Strength benefit tied to actual drained amount. No imaginary gain from a target at drain floor. Prepare required live wielder state before draining victim; missing required state is checked technical failure, not victim-only partial success.

Accepted transfer activation costs D0 condition, full resource before mutation; resisted activation no special wear. Exact accepted zero-transfer semantics need adapter fixtures consistent with actual-loss conservation. Successful qualifying transfer refreshes accumulated wielder-bonus expiry to12 elapsed game minutes later. At expiry clear accumulated artifact bonuses, reconcile capacity/current values without refill and leave victim's persistent drain to its normal repair rules. Default exact12-minute expiry intentionally clarifies source >12/tick timing. Retain source dependence through MAGIC-016; precise unequip/break handoff and ownership across copies must be declared before implementation.

Costs, cap/lifetime/composition and underfunded profiles moddable. This exception does not turn generic attribute transfer into unrestricted fortification. Bonuses/timers are authoritative saved source data, not regenerated by another strike on load.

### Masque of Clavicus

While eligible/equipped, contributes trunc(live Personality/5) to each supported social-group reaction modifier. Temporary source contribution, not repeated permanent faction reputation. Recompute on relevant changes; remove only its own contribution. Formula/groups/stacking moddable. NPC/FACT owns how reaction values affect conversations/prices/quests; no automatic friendship, legal immunity or faction rank.

### Mehrunes' Razor

Positive-D0 strike resolves applicable magic save. Permitted effect attempts lethal outcome through current health/protection/quest/death-prevention owners. Explicit lethal payload replaces ambiguous additive physical return; no guarantee of bypassing Shield, protected actors or death prevention. Keep D0, pending physical Dp, separate lethal outcome and actual loss distinct; exact remaining-primary ordering must be fixed within COMBAT-011 to avoid double kill/damage.

Cost equals target current health captured for accepted lethal attempt. Require full condition before commitment. Resisted attempt no special cost; paid attempt remains paid when subsequent protection prevents death. Ordinary wear remains separate. No special cost is fabricated for invalid/dead targets. Eligibility/defenses/lethality/cost/final-underfunded behavior moddable. Use stable attribution and retained outcomes for once-only death/quest/loot handling.

### Sanguine Rose and Skull of Corruption

Both are Used powers requiring an eligible non-allied enemy within strict distance<12 reference units. Default source classification uses non-allied enemy actors, not an implicit hostility-only test. Query may sense through walls, independent of detection buffs; summon placement still validates full shape/context under WORLD/LOC/MOVE-027. No valid target or technical spawn preparation failure means no special condition charge.

Rose creates one allied Daedroth. Skull selects nearest eligible enemy's type, deterministic stable ties, then creates one allied actor of that type. Type copy does not copy unique identity, inventory, quest obligations, earned rewards or transient mutable state. Supported generated stats resolve once and persist, not reroll on load. Selection/type/quantity/copied properties/range/eligibility moddable.

Each valid activation costs100 condition, full resource required. Prepare supported summon and safe placement before committing creation/payment once; last-condition completes then break. No silent charged spawn omission, indefinite unowned retry or placeholder ally in invalid geometry. Technical work limits return checked outcomes; repeated callbacks/recovery cannot create extra allies.

Default allies are location-bound, no timed expiry, persist same-location saves and end when caster leaves that gameplay location. No automatic following through doors/Recall/fast travel; exact same-location versus internal room changes needs stable LOC scope. Source item removal/break after commitment does not dismiss them. No default one-summon cap: further valid paid uses create further allies. Active limits/replacement/following/dismissal/duration/source-dependence moddable.

Created allies have no default loot, capturable soul or ordinary kill reward, preventing generated-ally farming. They retain combat abilities and truthful action attribution. Do not generate unique quest items/identities from a type copy. Explicit mod inventory/soul/reward policies supported. NPC owns ally behavior/targeting; no unrestricted companion command system inferred. Ending summon is cleanup, not ordinary death reward.

### Wabbajack

Positive-D0 strike transforms eligible EnemyEntity through one retained random outcome into a different monster type. Default no additional magic save, one Wabbajack transformation per encounter identity, no automatic reversion. Quest-required actors protected unless explicit supported outcome permits it. Eligibility/outcomes/defenses/repeats/reversion/costs moddable.

Baseline outcome pool: Rat, Imp, Spriggan, Giant Bat, Grizzly Bear, Spider, Nymph, Harpy, Skeletal Warrior, Giant, Zombie, Giant Scorpion, Iron/Flesh/Ice/Fire Atronach, Lich. Uniformly select from eligible different entries with validated finite pool rather than unbounded rejection loop; retain selection across retry. Verify stable content IDs/form compatibility before commit.

Preserve absolute prior health deficit delta=Mold−Hold: Hnew=max(0,Mnew−delta), using valid owner maxima. A resulting lethal outcome resolves through normal protection/death owners. Remaining primary strike damage applies once against committed actor state. Prepare required new representation/shape/placement before replacement; no scene disable leaving orphaned authoritative identity on failure.

Transformed actor remains same persistent encounter identity, retaining authoritative inventory/ownership/attribution and applicable state through explicit compatibility rules. Do not generate replacement loot, duplicate original actor or leave an accessible original behind. Form-incompatible effects/attachments need declared migrate/remove/recovery outcomes, not silent loss. Source callback's no additional special condition cost is retained; ordinary weapon wear remains. Transformation is not an automatic kill/reward event; any real resulting death uses normal owner contracts.

### Azura's Star

Preserve MAGIC-027 shared equipped automatic-capture/container rules, priority and at most one soul per death. Use explicit actual source-item identity; no independent extra capture callback after Soul Trap. Captured soul, eligibility/access/capacity and marking versus automatic claim ordering follow that owner contract. Modded souls/containers use same validated extension model.

Using a filled Star releases stored soul and leaves reusable item empty; no spawned creature or extra reward. Empty Star reports no soul only. No additional special condition cost by default. Revalidate item identity/access/stored state before clearing once; UI failure cannot repeat release or restore discarded soul. Equipped/load/query never generates a soul. Release, cost and alternate outcomes moddable. Soul-bound/enchanting consumption remains ITEM/MAGIC-015 explicit ownership, not automatically redesigned here.

## Relevant formulas and parameters

Regen1/four game minutes; sun/holy12/four; reduced magery modifier -floor(.33Mraw), unable effective capacity0. Namira A factors0/.5/2/1 from D0, condition=A. Oghma30 permanent points, level/ordinary HP0. Mace magicka loss<=D0 or Strength roll1–6 bounded actual loss, condition=D0,12-minute accumulated bonus expiry. Masque trunc(P/5). Razor condition=captured victim current health. Rose/Skull range<12, quantity1, condition100. Wabbajack17-type pool excluding current, absolute deficit preserved, extra cost0. Star release extra cost0. Supported numeric domains/rounding/scale are validated owner parameters.

## Required data

Stable passive/artifact/power/source/actor/session/provider IDs; environment/profile/composition and periodic cursor; raw magicka/zero-capacity state; physical D0/Dp/primary result and reaction-chain context; selected item/current condition and cost/commit facts; artifact category/defense/RNG outcomes; Oghma entitlement; Mace actual transfers/temporary capacity/timer; Masque reaction source; summon type/generated stats/ownership/location/lifecycle; Wabbajack encounter form/deficit/compatibility; soul storage/capture/release record; required pending recovery and schema versions. API/storage details remain dependencies.

## Inputs, outputs and events

Inputs: career/source/equipment changes, eligible elapsed time/exposure, settled incoming hit or eligible strike, Used request, target/world preparation, reward/actor/inventory owners and native restore. Outputs: derived capacities/reactions, periodic health events, artifact cost/payload outcomes, durable reward/summon/form/soul mutations or checked failures. Distinguish accepted request, cost commitment and completed result; UI observation/scene creation alone is not universal gameplay completion.

## Cross-system interactions

CHAR-005 selection definitions, CHAR-011/018 modifiers/vitals, CHAR-015 rewards; RULE-003/016/017 RNG/triggers/defenses; COMBAT-010/011 damage phases/retaliation/death, COMBAT-020/021 actor death/loot; MAGIC-007 defenses,008 clocks,009/010 source lifecycle/save,016 item triggers,019 transfers,027 souls,028 hazards,029 artifact capability; ITEM inventory/condition/reward/ownership; NPC/FACT reactions/allies; QUEST protected actors/identity; WORLD/LOC placement/current scope/exposure; UI/AV feedback; CORE/SAVE/DATA/MOD readiness and migration.

## Edge cases and failure conditions

Cover overlapping hazard sources, indoor daylight regen versus magery, zero capacity plus free casts, clamp/no-refill cycling; multiple Namira rings/insufficient condition/lethal primary/zero half-damage; Oghma ordinary-level backlog/UI failure/capped attributes; Mace target at drain floor/zero capacity/missing live effect/expiry; Masque negative live Personality/other reaction sources; Razor shield/death prevention/remaining physical hit; summon no eligible enemy/blocked shape/tied Skull targets/location leave/repeated use; Wabbajack smaller health maximum/quest target/incompatible state; full/empty Star/competing capture. Every partial commit preserves truthful recovery facts, not duplicate outcomes.

## Configuration and balancing options

Explicit validated passive conditions/amounts/cadence/composition; artifact triggers/targets/defenses/bases/costs/lifetimes/stacking; reward amounts; summon type/copy/access/reward/following; transformation pools/compatibility; soul policies and mod-added artifacts. No generic arbitrary observer execution or closed built-in-only enum required. Exact selector precedence/output domains/adapters must be documented before exposure.

## Save/load considerations

Persist periodic phase and actual source state, reaction/cost results, pending Oghma entitlement, Mace transferred bonuses/expiry, generated summon identity/stats/location scope, Wabbajack identity/form/inventory/state and Star soul/release facts. Rebuild derived capacities/presentation without periodic tick, reward, drain, spawn, transformation or capture replay. Restore capacity before reconciling saved over-normal Mace magicka; no artificial refill. Missing required data uses supported migration/recovery. Unresolved partial operations retain checked obligations and coherent SAVE boundaries, never silently complete based on a missing UI callback.

## Technical constraints

Target Godot4.7.2. Separate source composition, clock/environment queries, artifact admission/cost, owner mutation and optional presentation. Prepare before commitment; stable identities and idempotent results prevent double inventory consumption and scene-driven actor duplication. No global-player fallback/unsafe actor cast, frame-seeded gameplay RNG or huge-negative capacity sentinel. Concrete staging/partial recovery interfaces remain engineering design; no general transaction framework implied. No implementation/coding tasks authorized.

## Acceptance criteria

1. Source-owned passives reconstruct without extra modifiers/ticks; same sun/holy vulnerability applies once by default.
2. Regen/hazard amounts/predicates and saved timing follow approved clocks and actor-local context, independent of visuals.
3. Magery uses distinct environment predicates, explicit reduced/zero capacity, clamp/no-refill and separate free/item eligibility.
4. Namira uses retained D0/category scaling, one selected source/full cost, living-wearer post-primary/no-chain default and owner-safe retaliation.
5. Oghma item consumption/durable30-point reward succeed together, retaining CHAR-015 order/limits without ordinary level/HP gain or UI-loss duplication.
6. Mace save/branch/actual-loss conservation/cap exception/cost/expiry work without missing-state victim loss or RNG replay.
7. Masque temporary reaction contributions do not accumulate reputation and clean up only their source.
8. Razor explicit paid lethal attempt respects protection/death and primary phase settlement without ambiguous additive/double kill behavior.
9. Rose/Skull valid target/prepared spawn/full100 cost commit once; type copies preserve identity restrictions and no-farm defaults.
10. Summons persist same-location saves, end on caster location leave, lack invented one-summon cap and do not reroll stats or follow accidentally.
11. Wabbajack retains different-type outcome, absolute deficit and encounter/inventory identity without duplicate loot/original actor or lost primary hit.
12. Star uses shared one-soul arbitration and once-only emptying without extra reward/cost or query/load capture.
13. New mod passives/artifacts declare complete validated lifecycle/cost/target/persistence; native restore does not replay any completed gameplay.

These are future verification criteria; no implementation/runtime tests performed.

## Consistency review

Reviewed against CHAR-015/018, COMBAT-011 and MAGIC-008/009/016/019/027–029. Artifact-specific condition costs replace accidental generic ten-cost addition. Namira retains post-primary living eligibility and no chains. Mace over-cap benefit is explicit exception with actual-loss conservation. Oghma preserves durable reward ownership. Razor/Wabbajack require explicit combat settlement rather than unsafe source callbacks. Summon no-soul flags constrain MAGIC-027 eligibility; Star arbitration remains shared. Source-owned hazards and magery preserve no-refill/native timing rules.

## Outstanding questions and approval

No further blocking player-policy question identified. Required dependencies: full passive/environment/phase fixtures; category/duplicate-item selector precedence; exact Mace zero-transfer/source-removal settlement; Razor lethal/remaining-primary ordering; summon placement/location/AI attribution and complete generated-stat records; Wabbajack state/shape compatibility and quest policies; Star automatic claim priority under027; versioned schemas/native migration and recovery. Material gameplay changes found during integration return for review; these do not waive paid-once/no-duplicate, actual-loss or source-owner requirements.

The user explicitly approved the complete Draft v1 on 2026-11-10 with “I approve”. This specification is finalized v1 under MAGIC-030-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented integration and persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
