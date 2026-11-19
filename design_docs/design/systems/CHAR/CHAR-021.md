# CHAR-021 — Rest recovery

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Restore eligible health, fatigue and magicka during rest, with explicit recovery cadence, environmental modifiers and interruption settlement.

## Intended player experience

Rest for a selected duration or until recoverable pools are full. Completed hours provide recovery/practice; interruptions preserve committed progress. Rapid Healing's light/dark classification is understandable, including the broad default Darkness coverage in buildings/dungeons. Rest cannot silently loop forever when a missing pool is unrecoverable.

## Confirmed requirements

CHAR-021-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish source recovery formulas, Rapid Healing +60/+100 terms and environment rules, completed-hour/mode practice, unfinished-hour settlement, until-healed termination and dynamic reevaluation with explicit time boundaries.

CORE-019 owns structured rest eligibility/interruption, scope-safe vetoes and preserved committed time/recovery. CHAR-018 owns pools/limits, CHAR-020 excludes ordinary drain from rest-owned intervals, CHAR-012 records Medical practice and CHAR-013 governs advancement. TIME owns durations, encounters and exact simulation boundaries. Infection/cure and transformation-specific restrictions remain their respective owners.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#CalculateHealthRecoveryRate` uses live Medical, live Endurance, effective max health and career RapidHealing flags. The added Medical term is 60, or 100 for applicable Rapid Healing. Light is daytime outside; the opposite branch includes interiors and nighttime outdoors as Darkness.
- `CalculateFatigueRecoveryRate` uses max(1,floor(max fatigue/8)); `CalculateSpellPointRecoveryRate` returns zero for NoRegenSpellPoints, otherwise max(1,floor(max magicka/8)). Integer operands affect actual rounding; intended safe arithmetic preserves the accepted source baseline.
- `Game/UserInterfaceWindows/DaggerfallRestWindow.cs` advances time in subhour chunks and recovers via TickVitals on full-hour timed/full-rest ticks, after nearby-threat/veto checks in the inspected path. Loitering does not call TickVitals.
- TickVitals adds the three rates through current pool paths and tallies Medical +1. IsPlayerFullyHealed requires health/fatigue full and magicka full or NoRegenSpellPoints. RestFinishedPopup_OnClose requests RaiseSkills.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Full time-boundary/quest behavior, original descriptions and runtime interruption overlap remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Recovery formulas

Default recovery applies per completed eligible rest hour, using then-current validated live attributes, skill and effective maxima. Base health formula adds the Endurance healing modifier to the Medical contribution and guarantees minimum one health per eligible tick unless an explicit owner restriction blocks recovery.

Fatigue restores one eighth of current maximum per hour, minimum one internal unit; magicka restores one eighth per hour, minimum one, unless regeneration is prohibited. Recovery saturates at current maxima through CHAR-018. Zero-cap pools remain zero without fictitious recovery/depletion events.

No ordinary fatigue drain is additionally charged for the same owned rest interval. Recovery is not a generic full-vitals refill and does not reset active breath. Effect-driven health/magicka recovery restrictions and transformation vetoes are owner inputs; this feature does not invent additional restrictions from source hook availability.

### Rapid Healing environment

Normal added Medical term is 60. Applicable Rapid Healing replaces it with 100; it does not add another 100 or multiply the entire formula. General applies always. Light applies during daytime outdoors. Darkness applies otherwise, explicitly including both building and dungeon interiors regardless of daytime and nighttime outdoors.

This makes Darkness generally more prevalent during interior exploration; it is not a measured light-brightness test and lamps do not automatically change the classification. Do not promise quantified time spent inside/outside; prevalence describes the rule's coverage, not a measured play statistic.

Allow validated overrides of environment classification through the focused environment/lighting rule owner. Rest consumes that owner's explicit context rather than hard-code a second conflicting definition. A future brightness-based policy requires declared support/thresholds; this feature does not invent them. Recalculate applicability at each committed recovery tick.

### Modes and cadence

Timed rest and until-healed rest recover after each completed eligible hour. Loitering does not restore these pools or award recovery-tick Medical practice by default. Other loiter/time effects remain TIME scope.

Award +1 raw Medical practice per committed recovery hour through CHAR-012, including an otherwise valid timed-rest recovery tick where pools cap some/all gains. This does not guarantee a permanent Medical increase; ordinary/full-rest termination still prevents inventing extra hours after completion. Practice remains unscaled until CHAR-013.

An unfinished default hour grants neither recovery nor its Medical point. Elapsed game time and already-committed world effects are not rewound. Stopping/restarting starts a new recovery hour; partial progress is not banked across separate rest requests. Explicit validated alternatives may support proportional recovery or retained partial progress with their own unit/rounding/practice policies.

UI pacing and render frames do not define eligibility. TIME may advance subhour steps for events, but those steps cannot accidentally produce full-hour benefits or duplicate a tick.

### Interruptions and changing state

Evaluate start/continuation restrictions under CORE-019 at declared boundaries, with actionable reasons and no hidden threat disclosures. New threats/vetoes stop further advancement; no automatic restart occurs when a blocker clears. Preserve completed committed time/recovery/practice and never award future/unelapsed recovery.

Recompute rates each committed tick from current valid live Medical/Endurance, maxima, career/condition restrictions and environment. TIME must declare ordering between elapsed-time events, restriction checks and recovery commit so an event at the same boundary cannot depend on UI callback order or replay a benefit. If a tick was not committed before interruption, do not fabricate it afterward. Once committed, an interruption cannot retract it.

Each recovery tick's pools and practice must settle coherently. A failed required rate/restriction query stops advancement with explicit failure, not a zero/default success or partial unexplained tick. Exact transaction/batching mechanics remain engineering contracts.

Completion/termination invokes the appropriate rest checkpoint once under CHAR-013; the strict default interval still applies. Live mode processes accepted practice updates through its shared rules rather than granting a second ungated reward at rest completion. Exact interruption/cancellation checkpoint routing remains TIME/CHAR-013 integration scope, not an assumed new trigger.

### Until-healed termination

Finish when health/fatigue and all required rest-recoverable pools are full. Magicka prohibited from regenerating is excluded from the completion requirement. A valid zero-capacity pool is already full.

If another declared rule makes a required missing pool unrecoverable, explain the limitation and stop rather than keep advancing indefinitely or report full recovery falsely. Rates/restrictions may change over time, so reassess at relevant boundaries. Do not impose a generic arbitrary rest timeout as a substitute for correct eligibility/termination.

## Relevant formulas and parameters

Let E=live Endurance, M=live Medical, Hmax=effective maximum health and K=60 or applicable Rapid Healing 100.

- Healing modifier h=floor(E/10)−5.
- Default health/hour=max(1,h+trunc((M+K)×Hmax/1000)), preserving source integer division toward zero for the Medical term with safe wider arithmetic.
- Fatigue/hour=max(1,trunc(Fmax/8)) internal units.
- Magicka/hour=0 if regeneration prohibited, otherwise max(1,trunc(Mmax/8)).
- Medical practice=+1 per committed eligible hour; default cadence=60 game minutes.

Because CHAR-011 live Medical can be negative or exceed 100, preserve explicit arithmetic and validate supported numeric ranges rather than silently clamp it here. Minimum health rate remains an approved formula rule, not permission to override explicit no-recovery restrictions. Actual healed amount is limited by missing capacity.

## Configuration and balancing options

Validated mods may override supported recovery coefficients/minima/divisors/restrictions, recovery cadence/mode eligibility and explicit partial-recovery policies. Environment classification can be replaced through its owner contract, including building/dungeon treatment. Keep units, arithmetic/rounding and practice cadence declared; changing one-hour cadence does not silently preserve a full hourly reward for every shorter tick.

DATA-003 precedence/locking applies. Invalid/nonfinite/unsupported formulas, zero divisors, nonpositive tick intervals or ambiguous partial-practice policies fail validation. New executable recovery behavior needs owner support. No default breath refill, loiter healing or universal rest safety guarantee is introduced.

## Required data

Current pools/maxima; live Medical/Endurance; class/condition regeneration flags; Rapid Healing variant; validated environment context; resolved rate/cadence/mode policy; owned elapsed/partial interval and committed tick identity; restrictions/completion state and raw practice result. Concrete schemas/time representation remain owner dependencies.

## Inputs, outputs and events

Inputs: authorized rest mode/request, time boundaries, current values/context, restriction/event results and stop/restore actions. Outputs: coherent capped recovery, once-only Medical reports, completed/interrupted/unrecoverable/failure results and appropriate owner checkpoint. These are conceptual contracts, not API/signal names. Opening/rebuilding UI cannot tick recovery.

## Cross-system interactions

CORE-019 supplies structured restrictions/threat feedback. TIME owns rest duration/events/boundary order; environment/lighting owners supply classification. CHAR-011 gives live inputs; CHAR-018 applies recovery; CHAR-020 excludes duplicate drain; CHAR-012 tracks practice and CHAR-013 advances. MAGIC/condition owners supply restrictions and healing traits. UI presents progress/reasons, DATA/MOD validates alternatives and SAVE/CORE resume coherent activity.

## Edge cases and failure conditions

- Interior daytime still counts as Darkness by default; measured brightness cannot silently alter that baseline.
- A prohibited magicka pool cannot keep until-healed running forever; other required unrecoverable pools need explicit explanation/termination.
- Partial interruption grants no default recovery/practice, while completed committed ticks cannot be rewound or replayed.
- Full/zero pools saturate without fake depletion; no ordinary drain or breath reset from generic recovery.
- Pauses, quest popups and render delays cannot create extra elapsed recovery or bypass boundary checks.
- Rate changes at a boundary use declared TIME ordering, not stale startup values or widget refresh timing.
- Missing required context/rules stops safely rather than treating exceptions as allowed rest.

## Save/load considerations

Persist authoritative rest activity/mode, elapsed partial interval, committed tick/progress and needed policy context when supported. Restoring the same ongoing activity may resume its partial hour under SAVE/TIME rules; stopping it and starting a new request does not bank that partial hour by default. Do not replay completed recovery/practice or advance wall-clock time during load.

Saved pools remain authoritative CHAR-018 state; rebuild derived rates/environment/restrictions before continuation. Invalid/missing required activity/configuration uses explicit migration/recovery/failure, not silent full recovery or activity abandonment. Exact resumable UI, save boundaries and mod partial-policy representation remain SAVE/TIME contracts.

## Technical constraints

Target: Godot 4.7.2. Separate rate calculation, environmental query, rest progression, coherent tick settlement and UI. Use safe source-compatible integer arithmetic, explicit units and owner-scoped interval/tick identity. Concrete APIs/scheduler/serialization remain engineering choices. Reference source/content remain read-only.

## Acceptance criteria

1. Default eligible hourly recovery matches the accepted formulas/live inputs and saturates at valid current maxima.
2. Rapid Healing replaces 60 with 100 only under its declared rule; buildings/dungeons count as Darkness by default and classification supports validated owner overrides.
3. Timed/full rest recover and tally +1 Medical per committed hour; loitering and unfinished default hours do not.
4. Stop/restart cannot bank partial default hours; interruptions preserve committed time/recovery and never award unelapsed ticks.
5. Current context recalculates each tick and CORE-019 restrictions honor declared TIME boundaries without duplicate ordinary drain or live/default advancement rewards.
6. Until-healed completes with recoverable pools full, ignores prohibited magicka and explains/stops other unrecoverable missing pools instead of looping.
7. Supported mod rate/cadence/mode/partial/environment policies validate explicitly with consistent units/rounding.
8. Save/load resumes supported rest state without replay, free recovery or wall-clock catch-up; required failures use explicit recovery.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-005/011/012/013/017/018/020, CORE-019 and DATA-003. No direct contradiction identified. Source approximate healing/environment behavior is explicitly retained with mod support. Partial-hour settlement preserves CORE-019 committed effects without promising uncommitted ticks. Rest-owned time avoids activity double drain; +1 raw Medical remains separate from advancement. No new sleep encounter/duration policy or universal lighting implementation is approved.

## Outstanding questions and approval

No further blocking recovery-policy question is identified. Before implementation is complete: define TIME boundary/interrupt/checkpoint routing; verify rate/environment fixtures and live-input extremes; finalize focused environment schema, partial-policy integration and coherent tick settlement; establish SAVE activity/UI restoration. Dependencies cannot waive interior Darkness defaults, no partial-hour rewards by default, no double drain or truthful unrecoverable termination.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-021-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented TIME/environment/schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
