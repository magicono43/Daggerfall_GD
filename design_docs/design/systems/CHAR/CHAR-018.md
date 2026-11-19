# CHAR-018 — Vital pools and derived limits

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Maintain health, fatigue, magicka and breath through consistent limits, explicit mutations and once-per-transition depletion, supporting safe restoration and configurable breath recovery.

## Intended player experience

Vital changes behave predictably: increasing capacity does not refill a pool, insufficient costs do not partially spend, and depleted pools do not repeatedly replay consequences. Breath follows the current activity and can support modded gradual replenishment without re-entry exploits.

## Confirmed requirements

CHAR-018-D01–D08 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish baseline pools/formulas, maximum-change handling, authoritative operations, transition notifications, spending versus damage semantics, activity-owned breath, configurable recovery and strict definition/save validation.

CHAR-011 supplies live attributes and source-owned modifiers. CHAR-015 increases base maximum health without healing. CHAR-017 fresh initialization fills health/fatigue/magicka only after required derived limits; native restoration preserves state without replay. CHAR-020/021 own activity costs/recovery, CHAR-022 exhaustion outcomes and CHAR-023 death. No complete drowning/death/prevention mechanic is finalized here.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/DaggerfallEntity.cs`: MaxFatigue=(LiveStrength+LiveEndurance)×FatigueMultiplier, FatigueMultiplier=64; MaxBreath=LiveEndurance/2; GetRawMaxHealth returns stored maximum; GetMaxHealth applies an active limiter if lower.
- GetRawMaxMagicka uses `Game/Formulas/FormulaHelper.cs#SpellPoints` for players, floor(live Intelligence×career multiplier). GetMaxMagicka adds MaxMagickaModifier and floors at zero. Enemy raw magicka is stored separately; player-derived rules do not automatically apply identically to NPCs.
- SetHealth/SetFatigue/SetMagicka normally clamp, but restore mode assigns directly and setters can still raise depletion events. SetBreath clamps without depletion notification. FillVitalSigns directly fills health/fatigue/magicka and excludes breath.
- SetMaxHealthLimiter chooses the lower active limiter and explicitly clamps current health. Other maximum-change paths are not uniformly reconciled in these getters/setters.
- `Game/Entities/PlayerEntity.cs` overrides health for guild death prevention and health/fatigue/magicka for god mode. Underwater activity initializes/decrements breath elsewhere; the reserve is not a universal always-active pool.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Runtime max changes, depletion overlap and underwater consumption remain owner verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Baseline pools and limits

Player health has a positive stored base maximum, independent of temporary live limiters. Effective maximum is the lesser of base maximum and the lowest valid active limiter; with no limiter, use base maximum. Limiter sources must be at least 1 and use source ownership under CHAR-011/MAGIC. Removing a limiter recomputes capacity, not permanent health gains.

Fatigue maximum is (live Strength+live Endurance)×64 internal units. Keep units explicit across UI, activity costs, training and effects; 64 is precision scaling, not a multiplier to apply twice. Display conversion/rounding must not erase authoritative internal state.

Player maximum magicka is max(0,floor(live Intelligence×class multiplier)+resolved magicka modifier). Source owners determine eligibility/stacking. Breath maximum is floor(live Endurance/2). These maxima may be zero where valid; zero maximum magicka does not imply a repeated depletion event or dead character.

Permit validated overrides of supported parameters while retaining explicit owner schemas and numeric compatibility. NPC pool construction remains NPC-owned; this feature's player formulas do not authorize regenerating enemy vitals from player class rules.

### Maximum changes and mutations

On a valid maximum increase, leave current amount unchanged. On decrease, clamp current only if above the new maximum. Do not preserve percentage or refill automatically. Recompute source-derived limits from authoritative inputs, then reconcile current amounts before consumers observe consistent state. Removal of a temporary limiter cannot restore previously clamped-away current health for free.

Use explicit operations for spending, damage/drain, healing/recovery, fill and save reconstruction, carrying correct units/source/session context. Ordinary costs require sufficient current resource; otherwise fail unchanged. A cost exactly equal to current resource may reach zero unless the owner imposes a stricter safety rule, such as CHAR-016 training fatigue. Partial spending/overdraft requires an explicitly approved owner exception.

Damage/drain saturates at zero; healing/recovery saturates at maximum. Reject malformed amounts or unsupported arithmetic rather than reinterpret negative healing as damage. Generic fill targets health/fatigue/magicka, not active breath. Eligibility for fills/revival remains owner-controlled; a fill call is not general authorization to resurrect.

### Depletion and consequences

Notify positive-to-zero transitions once, including a valid maximum reduction that clamps a positive pool to zero. Repeated zero assignments and existing zero-max pools do not emit a new transition. Recovery above zero allows a future transition. Report source context so responsible outcome systems can resolve consequences once.

Death prevention, exhaustion/collapse and drowning remain their owners' policies and must coordinate with authoritative final outcomes. A preliminary damage calculation is not already a committed death. This feature does not choose prevention charges, guild rescue, exhaustion recovery or zero-breath damage rules.

Save reconstruction is consequence-free under CHAR-017 and must not rearm/replay death or depletion merely by assigning saved fields. Genuine saved conditions remain obligations. Consumers entering an activity with an already-zero resource must inspect valid current state rather than depend on a fabricated positive-to-zero event.

### Breath activity and recovery

Maintain explicit breath-holding/activity state separate from reserve amount. Default behavior supplies a fresh full reserve for a new eligible breath-holding activity and ends the holding activity when normal breathing resumes. Generic vital filling cannot reset an active timer. Underwater consumption/cadence, Argonian benefits, water-breathing and what qualifies as breathable space remain MOVE/CHAR-020/MAGIC owner rules.

Default replenishment is instant in an appropriate normal-breathing state. Allow validated alternative policies declaring eligible recovery states, refill rate and optional delay. In gradual mode retain reserve between activities; re-entry uses the available amount, not an unconditional full refill. Recovery saturates at the current maximum and respects maximum-change rules. No breathing-state toggle exploit may bypass a configured recovery delay/rate.

Persist reserve, active/recovery context and required timing so loading cannot refill or restart recovery for free. Exact time units/integration/rounding remain TIME/activity schema dependencies. Zero-capacity or already-empty activity entry follows explicit owner outcome rules without repeatedly manufacturing depletion events.

## Relevant formulas and parameters

- Health: Hmax=Hbase with no limiter; otherwise min(Hbase,min(valid active limiters)); Hbase>0, limiter≥1.
- Fatigue: Fmax=(live Strength+live Endurance)×64 internal units.
- Magicka: Mmax=max(0,floor(live Intelligence×class multiplier)+resolved modifier).
- Breath: Bmax=floor(live Endurance/2).
- Valid current pools: 0≤current≤effective maximum. Valid runtime maximum changes reconcile current=min(old current,new maximum), without refill on increases.
- Spend a≥0: if current≥a, subtract a; otherwise reject unchanged. Damage/drain: max(0,current−a). Healing/recovery: min(maximum,current+a).

Use safe supported arithmetic for intermediate values. Magicka's specified zero floor is intentional gameplay formula behavior, distinct from repairing malformed definitions. Breath recovery alternatives require explicit rate/delay and integration rules; this feature does not invent numerical rates.

## Required data

Current pools, base health maximum, live attribute/class inputs, owner-resolved maximum modifiers/limiters and source IDs; explicit unit metadata; prior/final transition context; breath activity/reserve/recovery policy/timing; definition provenance and restore validation results. Concrete schema and representation remain engineering dependencies.

## Inputs, outputs and events

Inputs: authorized costs, damage/healing/fill, source/max changes, activity/recovery updates and restoration. Outputs: committed pool/max values, insufficient-resource/invalid-operation results and once-per-transition depletion notifications. API/signal names are deferred. Query/display operations do not mutate pools or replay outcomes.

## Cross-system interactions

CHAR-011/MAGIC resolve live attributes/modifiers; CHAR-015/017 establish base health/start/restore. COMBAT/MAGIC/ITEM and activity owners submit valid mutations. CHAR-020/021 define consumption/recovery, CHAR-022 exhaustion and CHAR-023 death/prevention; MOVE controls breathable/underwater context. CHAR-016 training uses explicit internal fatigue once. TIME integrates delayed recovery; UI presents actual values; DATA/MOD validate parameters; SAVE/CORE restore and gate consistent state.

## Edge cases and failure conditions

- Temporary capacity gains give no free refill; removing/readding a limiter cannot recover clamped health automatically.
- Pool at zero maximum has valid zero current state without repeated notifications. Zero breath on entry still needs owner outcome handling.
- Insufficient spending leaves state unchanged; damage can exceed current and healing can exceed capacity through intentional saturation.
- Repeated callbacks and mixed depletion/max changes cannot replay a single outcome. Source ordering cannot expose invalid intermediate maxima.
- Unsafe numeric limits, negative health base/limiter and invalid saved current/max relationships require explicit failure/migration.
- Breath save/re-entry/toggle transitions cannot secretly refill gradual reserve or reset its timing.
- God-mode/developer overrides need explicit DEV/owner contracts; source cheats do not silently override restore validation here.

## Configuration and balancing options

Validated mods may override supported pool formula parameters/modifier definitions and breath instant/gradual recovery states/rate/delay. Preserve health positivity and other nonnegative maxima, safe arithmetic, explicit units and source-owner stacking. DATA-003 locking applies. New pools, arbitrary executable formulas, alternate spending exceptions or depletion consequences require separate owner support/approval.

## Save/load considerations

Persist authoritative currents/base health and required effect/activity sources. Rebuild valid maxima before checking saved pool compatibility, rather than compare against temporary pre-reconstruction limits. Restore reserve/recovery timing and state without filling or depletion replay. Invalid saved pools/required definitions need explicit SAVE migration/recovery; do not silently clamp loaded values under ordinary gameplay mutation rules.

Live max/source caches are derived, not extra authoritative bonuses. Exact time representation, fractional recovery accumulation and zero-condition restoration remain SAVE/TIME/outcome-owner contracts. Fresh full health/fatigue/magicka remains CHAR-017 policy; load is not fresh initialization.

## Technical constraints

Target: Godot 4.7.2. Separate authoritative values, derived limits, mutation intent, depletion transitions and outcome handlers. Validate units/source identity and safe arithmetic; rebuild/publish consistent max/current pairs. Use explicit restore-safe operations. Concrete APIs, numeric widths and scheduler/event mechanics remain engineering choices. Reference source/content remain read-only.

## Acceptance criteria

1. Four player pools use approved baseline formulas with separate base/effective health and explicit fatigue scaling.
2. Max increases do not refill; decreases reconcile current without percentage preservation or hidden restoration.
3. Costs fail unchanged when insufficient; valid damage/healing saturate at zero/max with explicit owner exceptions only.
4. Positive-to-zero depletion notifies once, rearmed only after recovery above zero; reconstruction/repeated zero writes do not replay consequences.
5. Generic fill excludes active breath. Default breath activities receive full reserve while gradual policies retain/recover available reserve without entry resets.
6. Gradual eligible states/rate/delay and timing survive save/load and activity toggles without free refill.
7. Validated limits ensure positive health base/limiters and nonnegative other maxima; malformed definitions/saved values fail explicitly rather than repair silently.
8. UI/consumers see consistent actual pool/max state and units; training/effect costs cannot double-apply scaling.
9. Restore preserves currents/conditions, rebuilds sources before validation and resumes owner obligations without false death/exhaustion/drowning events.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-002/005/011/015/016/017, DATA-003 and CORE restore/readiness constraints. No direct contradiction identified. Level-health capacity increases preserve current health. Training's stricter fatigue safety remains an owner-specific cost rule. Gradual breath is an explicitly approved extension of default fresh-reserve behavior, not a hidden unconditional refill. Restore validation differs intentionally from normal runtime saturation. Later survival/outcome policies and broader architecture remain unapproved here.

## Outstanding questions and approval

No further blocking pool-policy question is identified. Before implementation is complete: define compatible mod schemas/numeric limits and recovery rates/delays; finalize source batching and unit conversions; verify breathing/zero-capacity/prevention/collapse/death owner contracts; establish SAVE timing/fractional state and consistent reconstruction. Dependencies cannot waive no-refill max changes, transition notifications or gradual-reserve retention.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-018-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented source/outcome/schema and SAVE/TIME dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
