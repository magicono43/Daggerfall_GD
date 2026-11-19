# MAGIC-020 — Poison lifecycle

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Manage accepted poison onset, active progression, residual effects and treatment through explicit extensible profiles with retained outcomes and coherent time advancement.

## Intended player experience

Poisons can start immediately or after a delay, cause type-specific effects and leave repairable penalties after progression ends. Repeated same-type exposure does not reset the default poison. Cure Poison clears all poison-owned state by default without refilling previously lost resources. Mods may define doses, alternate timing/resistance, selective antidotes and mixed drug-like profiles while preserving knowledge and once-only behavior.

## Confirmed requirements

MAGIC-020-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm profile-based lifecycle, same-type redundancy, residual repair/cure, binary exposure save, cure-all scope, drug completion, onset/tick accounting, chronological elapsed handling, retained randomness, knowledge and native persistence. The complete specification is approved under MAGIC-020-A01.

RULE-016/COMBAT-011 own weapon exposure/coating settlement. MAGIC-006/009 admission/contributions, MAGIC-008 timing, MAGIC-010 persistence, MAGIC-017 pool damage, MAGIC-018 repair and RULE-017 saving composition remain binding. A profile is not limited to the classic enum.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full classic data/range/runtime catch-up fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/`.

- `MagicAndEffects/Effects/Poisons/PoisonEffect.cs` has Waiting/Active/Complete state, randomized type-specific onset/active minute counts and forced lifecycle rounds. Start stores current minute; UpdatePoison separately iterates elapsed minutes; same-key incumbent AddState does nothing.
- Payloads include pool damage and negative/positive attributes. CompletePoison removes drug positives and leaves negative contributions until repaired/cured. CurePoison marks complete/resigns; manager CureAllPoisons removes poison bundles.
- `Formulas/FormulaHelper.cs#InflictPoison` checks some career/racial immunity, one SavingThrow, admits on any nonzero retained result, skips level-one targets and assigns with save bypass. Target uses explicit approved immunity/composition and no universal level-one exclusion.
- `Effects/Restoration/CurePoison.cs` calls CureAllPoisons. Source minute-decrement onset boundary is not presumed identical to the explicit native rule below; fixture-map classic content accordingly.

## Detailed rules and behaviors

### Profiles, states and onset

Each poison declares stable profile identity/version, onset, active duration/tick count, cadence/clock, ordered payloads, completion/removal behavior and persistent penalties. Verified classic profiles form default content baseline; exact values/random bounds remain fixture work. Support validated additions beyond hard-coded poison IDs and MAGIC-008 round/real-time alternatives.

Distinguish waiting, active progression and completed-with-residual state. Positive onset delay postpones first payload until that delay elapses. Zero-delay profile applies first payload immediately after acceptance. Declared active tick count includes this first application, avoiding an extra transition tick. Exact zero active-count legality and alternate scheduling must be explicit, not inferred.

Resolve randomized onset/duration once for a new accepted instance. Every genuine randomized payload tick resolves once and retains outcomes against duplicate/retry/restore. Merely polling state/previewing/diagnosing cannot consume gameplay RNG.

### Exposure, resistance and repeated doses

Default exposure uses one RULE-017 binary save: R=0 rejects; nonzero admits full poison profile. No default retained-percentage reduction of duration/payload and no tick saves. Explicit mod alternatives may define reduced potency/duration or recurring checks with declared cadence/identity. Do not apply exposure save again in generic effect admission.

Immunity composition and separate permissions follow approved RULE-017/MAGIC-006. No blanket level-one immunity adopted from source. Hard immunity exceptions/classifications must be declared rather than bypassed by a generic flag or source absence. Exact variant/source mapping requires inventory validation.

Default same-type accepted re-exposure does not add an instance, reset onset, extend duration or reroll existing state. Different poison types coexist. Redundant/resisted valid weapon attempts still consume coating under RULE-016; technical failure does not masquerade as ordinary redundancy to spend it. Distinguish coating receipt from ongoing poison instance.

Validated dose accumulation, refresh, replacement and independent-instance policies supported with explicit matching, amount, order/source ownership and save rules under MAGIC-009. After cure, a genuinely new accepted instance may resolve new onset/duration. Completed residual same-type matching must be explicitly represented consistently with default no-reset rule, not silently replaced because no active ticks remain.

### Progression, payloads and units

Process due ordered payloads through authoritative pool/modifier owners. Health/fatigue/magicka damage and gains retain requested/resolved/actual amounts, explicit units and consequence ordering under MAGIC-017/018/CHAR. Attribute penalties/bonuses are source-owned contributions, not permanent stat rewrites. Profile classification/scaling does not inherit ordinary drain's permanent−1 floor automatically.

Settle each tick's damage, exhaustion, prevention/death and applicable cure before later work. Default no new practice per symptom/tick. No per-frame damage, generic-plus-specialized duplicate catch-up or new random roll from getters.

Authorized rest/travel/prison processes all required elapsed events chronologically under MAGIC-008; no fixed catch-up cap discards poison. Specialized handler and scheduler must declare which owns each due event. Pause/loading/offline wall time does not progress ordinary poison. Death/applicable activity interruption stops at actual event time and reports actual elapsed advance, not false requested completion.

### Completion, repair and cure

Natural progression end stops future active ticks but may leave declared repairable negative attribute contributions. Attribute healing repairs eligible poison penalties oldest-first under MAGIC-018 without stopping active poison; later ticks can damage again. Preserve each source's remaining damage, never heal another poison or extend a drug bonus inadvertently.

Default drug-like profiles support harms and benefits. At progression completion remove their temporary positive attribute contributions, retaining declared repairable penalties. Already committed health/fatigue/magicka gains/losses are not reversed. Completion alternatives are moddable; addiction/withdrawal/permanent rewards require explicit additional profiles rather than assumptions.

Ordinary Cure Poison removes all poison instances, including waiting poisons and completed residual penalties. Remove only their remaining contributions; do not refill health/fatigue/magicka or remove unrelated disease/drain. Cure source admission/chance remains applicable under its source rules. Mod antidotes may select type/family/dose explicitly; exact matching/priority/strength requires complete profile.

When completed instance has no residual contributions or obligations, remove empty lifecycle state. Cure/removal repeated callbacks harmless. Retained operation facts may outlive visible effect sufficiently to prevent duplicate work; empty record removal is not permission to forget pending coating/cure receipts.

### Attribution, symptoms and knowledge

Keep original actor/item/exposure identity even after scene attacker disappears. Ordinary accepted poison does not require ongoing caster presence. No attribution to current weapon, replacement actor or a later same-type exposure without explicit dose policy.

Profiles declare symptom/identification/HUD knowledge rules. Appropriate DFU-style symptom communication may remain baseline, but delayed onset must not automatically reveal exact poison name, hidden payload or countdown. Explicit mod diagnosis/knowledge may reveal more. UI hidden state never disables progression; fallback icons/active details follow MAGIC-010 within disclosure policy.

Symptoms/ticks are not automatically fresh attacks/crimes/casts. NPC/LAW/QUEST consume declared attempt/loss/death/exposure semantics with stable once-only identities. Optional feedback cannot roll, tick, reapply or cure the poison itself.

## Relevant formulas and parameters

Default exposure R=0 rejects; R>0 admits full profile after explicit immunity/eligibility. Positive onset first payload at elapsed delay; delay=0 initial immediate; active count includes first payload. Same-type redundancy adds zero duration/dose by default. Exact classic onset/duration/tick magnitudes, half-open source random bounds and endpoint mappings must be fixture-verified; no blanket universal value or disease/drain floor introduced.

## Required data

Stable profile/version/poison-instance/exposure/source/recipient identities; type/matching/dose policy; retained immunity/save/onset/duration results; state/next tick/remaining count/timing profile; payload outcomes; residual penalties/bonuses/repair progress; positive cleanup/cure completion; knowledge/symptom policy; separate coating and partial recovery facts. Exact schema remains dependencies.

## Inputs, outputs and events

Inputs: settled valid exposure, due elapsed event, explicit healing/cure/antidote, source profile/knowledge and native restore. Outputs: resisted/redundant/new/dosed poison, waiting/active/residual/completed state, ordered payload results, scoped cleanup/cure, truthful interruption or technical recovery and optional symptoms. APIs/signals unselected. Symptom notification is not another damage event or exposure attempt.

## Cross-system interactions

RULE-016/COMBAT-011 own eligible hit/coating consumption; RULE-017 exposure composition and RULE-001/003 retained RNG. MAGIC-006 admission, MAGIC-008 full elapsed scheduling, MAGIC-009 source/dose combination, MAGIC-010 persistence/HUD, MAGIC-017/018 damage/repair/recovery. CHAR owns pools/prevention/death/exhaustion, ITEM poison sources, NPC/LAW/QUEST attribution/reactions. DATA/MOD validate profiles; SAVE/CORE-013 preserve compatibility and coherent state.

## Edge cases and failure conditions

- Zero-delay exposure: one immediate first payload, not one extra generic initial tick plus poison update.
- Same type re-exposed while waiting/active/residual: no default reset/dose/reroll; weapon attempt still settles own coating.
- Full repair while poison active: cause remains and can inflict more; complete with no residuals cleans state.
- Cure while waiting: no future onset; cure after completion clears remaining poison penalties without pool refill.
- Drug bonuses removed: surviving unrelated fortification remains; no reversal of pool gains or invented withdrawal.
- Long travel includes lethal tick: stop chronological advancement there, not after ignored future ticks.
- Missing required service/provider: explicit recovery, not ordinary resistance/coating consumption or silent skip.
- Load/resume/UI diagnosis: no onset reset, tick replay, bonus reroll or hidden countdown disclosure.

## Configuration and balancing options

Validated type-independent onset/duration/cadence/payload, dose/matching policies, resistance interpretation, antidote selection, repairability/completion and knowledge rules are moddable. Support alternate MAGIC-008 clocks and mixed drug payloads without hard-coded enum limits. Default remains verified classic content plus explicit native boundaries above. Exact profile APIs, safe limits and selector precedence remain owner work; new addiction/permanent reward/level immunity not inferred.

## Save/load considerations

Preserve waiting/active/residual state, onset progress/remaining ticks/phase, retained random values, source/repair/contribution data and completed cure/tick/coating outcomes. Restore without exposure, initial payload, onset reroll or damage replay. Future genuine ticks use approved fresh randomness without replacing saved outcomes.

Required profile/source-state compatibility follows MAGIC-010/CORE-013; timing migrations use MAGIC-008. Coherent snapshots or supported retained partial-operation progress prevent double cleanup/consumption/poison progression. Exact cure/tick boundary schemas and receipt retention remain dependencies. Classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. Explicit lifecycle/profile/time/event ownership replaces forced-round sentinels and hard-coded enum reliance. Keep source contribution, positive/negative residue and knowledge separate; safe numeric/random boundaries and once-only owners required. Exact scheduler/family adapter, dose schema and native representation remain design work. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Extensible profiles support onset/active/residual phases and declared tick accounting without double initial/generic progression.
2. Default one binary exposure save/full profile and same-type redundancy behave independently of valid coating consumption; no implicit level-one exclusion.
3. Natural completion stops ticks but retains repairable penalties; active repair can recur; empty complete state cleans safely.
4. Cure-all includes waiting/residual instances and removes own contributions only, no unrelated cure/pool refill; selective mod antidotes explicit.
5. Drug positive cleanup/remaining penalties and committed pool changes follow declared policy without invented addiction effects.
6. Full elapsed chronology/interruptions preserve damage/death order without cap loss or paused/load catch-up.
7. Retained onset/duration/tick/cure results survive retry/restore; symptoms/HUD respect knowledge and attribution without fresh crimes/practice by default.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved RULE-016/017, COMBAT-011, MAGIC-006/008–010/017/018 and recorded MAGIC-020-D01–D12. No direct contradiction identified. Poison's declared delayed initial payload is an explicit scheduling policy allowed by MAGIC-008, not an accidental violation of generic immediate application. Binary poison admission is the explicit family interpretation left open by RULE-017. Repair/cure source semantics match MAGIC-018. Weapon coating settlement stays separate from redundant poison instance. Full elapsed progression and residual state preserve native safeguards without adopting source catch-up assumptions.

## Outstanding questions

No further blocking poison-lifecycle player-policy choice is identified. Before implementation is complete: fixture-map classic profiles/random endpoints/onset counts; inventory immunity/payload/repair classifications and nonclassic source delivery; define dose/antidote/knowledge schemas, scheduler ownership/ties and coherent cure/tick/receipt persistence. These deferrals cannot authorize level-one blanket immunity, hidden onset reset, duplicate poison ticks, unrelated modifier cleanup or silent required-content loss.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: MAGIC-020-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented classic profile fixtures, immunity/payload classifications, dose/antidote/knowledge schemas, scheduler integration and native recovery/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
