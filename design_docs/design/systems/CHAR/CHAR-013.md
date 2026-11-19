# CHAR-013 — Periodic skill increases and mastery

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Convert raw practice into permanent skill improvement through predictable, validated advancement policies, supporting the familiar rest/travel default and an optional live mode without separate progression implementations.

## Intended player experience

Under the default policy, rest or complete fast travel after enough game time to consolidate practice into skill gains. Optionally choose live advancement before character start, earning gains through practice without resting. Understand gains/mastery through notifications without repeated popup floods or load-time duplication.

## Confirmed requirements

CHAR-013-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish default checkpoints/strict interval, threshold formula and scaling, default reset behavior, optional fixed live mode, alternate validated consumption/gain policies, overridable mastery restrictions, snapshot eligibility, exact raw carryover and persistent policy/notifications.

CHAR-012 owns raw counters, nonnegative valid reports, caps and duplicate/context protection. CHAR-010 owns fixed reflex selection/scaling; CHAR-005 career advancement parameters. CHAR-011 owns permanent/live values and validated mutations. CHAR-014 owns level eligibility; CHAR-015 level rewards. This feature does not award a level merely because practice qualifies.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/PlayerEntity.cs#RaiseSkills`: returns during death or elapsed classic game minutes ≤360, then updates last-check time; each skill's reflex-scaled tally is compared to its requirement. Qualifying tallies reset before cap/mastery checks. At most one point per skill is awarded.
- `AlreadyMasteredASkill` checks whether any Primary is exactly 100. RaiseSkills permits gains below 100 when current skill is below 95 or no Primary is mastered. Because the loop mutates before evaluating later skills, simultaneous outcomes can depend on skill order. Intended snapshot eligibility explicitly replaces this behavior.
- Successful increases mark recently increased skills, update level-progress sums and show messages. Primary reaching 100 can show text token 4020 and fanfare; CheckForLevelUp can request the character sheet.
- `Game/Formulas/FormulaHelper.cs#CalculateSkillUsesForAdvancement`: floor(skill × skill multiplier × career multiplier × 1.04^level × 2/5 + 1).
- `Game/Entities/DaggerfallSkills.cs#GetAdvancementMultiplier` supplies skill-specific factors. `DaggerfallRestWindow.RestFinishedPopup_OnClose` and `DaggerfallTravelPopUp` request RaiseSkills after their respective completion flows.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete checkpoint routing, time units and runtime notification sequencing require verification. Source remains unchanged.

## Detailed rules and behaviors

### Modes and triggering

Default mode checks at approved rest/fast-travel completion checkpoints only, with no continuous check. Eligibility requires strictly more than 360 game minutes since the last eligible check. Exactly 360 is insufficient. A valid eligible check updates its timestamp even when no skill gains occur; a premature/invalid/stale request does not consume the interval.

Support optional live mode: check after an accepted practice update without requiring rest/travel or the six-hour gate. Select mode before character start and keep it fixed for that character. Both modes use the same threshold, mastery and consumption contracts. Rest/travel must not become a second ungated reward route in live mode. Zero/no-change or duplicate reports are not opportunities to repeatedly process identical state.

Validate current living character/session and authoritative activity context; no advancement during loading, preview/initialization or after death. A single originating action can report several skills; evaluation/commit boundaries must prevent callback or iteration order from granting the same result twice. Exact batching is an integration contract, not permission to split a coherent check into order-dependent mutations.

### Thresholds and gains

Use permanent skill values, skill-specific factor, current career multiplier, level and fixed character reflex scaling. Recorded raw practice remains unchanged by the scaling calculation itself. Eligible practice can yield permanent +1 steps, subject to configured limits and mastery eligibility. Temporary live modifiers do not make a character master or lower the permanent-value requirement.

Default: at most one +1 per skill per eligible check. If the scaled tally meets the threshold, reset the entire raw counter even when excess exists or a cap/mastery restriction blocks gain. Below-threshold counters remain unchanged. This potentially wasteful behavior is deliberately retained as default, not silently replaced by carryover.

Mod policy may choose a finite maximum gains per skill/check, carryover versus full reset, and whether blocked qualifying gains consume practice. Full-reset mode permits at most one gain per skill/check. Carryover uses the exact raw-cost rule below and recomputes requirements after each simulated point. Never grant beyond permanent bounds or authorized advancement cap. Global per-check level/context inputs remain the check snapshot; this feature does not grant levels mid-calculation.

### Mastery and simultaneous candidates

Vanilla progression cap is 100. Once a Primary is mastered at 100, skills already at 95 or above cannot improve through this path. Skills below 95 can reach 95. Existing values are never reduced merely because mastery is present. Validated mods may change/disable this restriction and compatible thresholds/caps.

Capture permanent values, Primary membership, mastery state, counters and required policy/context at check start. Determine whether a Primary was mastered from that snapshot, then stage all skill outcomes and commit a consistent result. With none mastered initially, multiple eligible skills may advance, including multiple Primaries reaching 100 in the same check. Do not let iteration order select a winner.

Within a modded multipoint carryover check, apply the check-start global mastery state consistently while simulating each skill's increasing value and cap/restriction boundary. A newly mastered Primary affects the next check rather than retroactively blocking other staged gains. When mastery was already present initially, no skill may progress through the restricted boundary by looping several times.

### Commit and presentation

Validate staged permanent changes, consumed counters and timestamp together before publishing completion. Do not expose half-applied gains or clear counters when an invalid required rule prevented evaluation. A legitimate default cap-blocked consumption remains valid policy and is distinct from a failed operation.

After committed changes, mark earned increases and publish skill-gain notifications plus Primary-mastery recognition for crossing the relevant threshold. Coalesce live-mode messages to avoid popup floods; no modal acknowledgement is required merely to commit progression. UI ownership and exact grouping/fanfare presentation remain deferred. Notifications cannot drive the authoritative gain or replay it on reopening/loading.

Report committed skill changes to CHAR-014 for level eligibility, without defining level thresholds or rewards here. Source behavior of opening the character sheet does not by itself approve automatic modal interruption in every live-mode situation.

## Relevant formulas and parameters

For permanent skill S, positive skill factor k, career factor c and character level L, vanilla requirement T=floor(S × k × c × 1.04^L × 2/5 + 1). Require a supported positive integer T and finite safe intermediate arithmetic. Reflex-scaled practice E=floor(U × r), where U is raw practice and r is CHAR-010's positive resolved multiplier. Qualification is E≥T.

Default skill factors from DaggerfallSkills: Medical 12; Etiquette/Streetwise 1; Jumping 5; language skills 15; Lockpicking 2; Mercantile 1; Pickpocket/Stealth 2; Swimming 1; Climbing 2; Backstabbing 1; Dodging 4; Running 50; Destruction 1; Restoration 2; Illusion/Alteration 1; Thaumaturgy 2; Mysticism 1; Short Blade/Long Blade/Hand-to-Hand/Axe/Blunt 2; Archery 1; Critical Strike 8. Verify complete classic-ID mappings and added-skill factor definitions before implementation is complete.

For carryover, raw cost Q=ceil(T/r). On a permitted +1 gain, subtract Q from U, increment staged S, recompute T from new S and repeat only up to the finite configured per-skill gain limit. Use numerically reliable arithmetic so floor/ceil boundaries agree; Q must be at least one. Do not subtract scaled practice directly from raw counters.

For a threshold-qualified blocked gain, the configured consumption flag determines whether counter state changes: preserve if disabled; if enabled, full-reset clears U and carryover consumes the current Q once, then stops processing that blocked skill in this check. Repeated blocked-loop deductions without gains are not permitted. This precisely implements the approved blocked-consumption alternative without an unbounded loop.

Defaults: rest/travel mode, strict elapsed >360 game minutes, full-reset consumption, blocked consumption enabled, maximum one gain/skill/check, mastery at 100 and restricted boundary 95. Modded caps/thresholds must remain compatible with CHAR-011 permanent bounds and CHAR-012 raw-counter caps. Requirements above the raw cap's scaled capacity may make a skill unadvanceable and must be reported/validated explicitly, not treated as a reason to overflow.

## Configuration and balancing options

Validated mod parameters/policies cover checkpoint interval, threshold parameters (including skill factors and growth/scale constants), finite maximum gains, reset/carryover, blocked consumption and mastery restriction thresholds/disablement. Live/default mode is chosen before character start and fixed. CHAR-010 reflex definitions and CHAR-005 career values remain their owners' inputs rather than duplicate independent settings here.

Reject nonfinite/invalid factors, nonpositive requirements, impossible cap relationships, invalid intervals and unbounded gain counts. Full-reset plus multiple gains is invalid. Definitions and compatibility require DATA-003 explicit validation/recovery; no silent clamping, fallback or live reload. Supported data policies are not permission for arbitrary executable formula code. Exact schemas/numeric ranges remain owner dependencies.

## Required data

Stable skill/tier identity, permanent values, raw counters, level/career/reflex context, skill factors/formula parameters, immutable check snapshot, fixed mode, last-check time, consumption/gain/mastery policy and staged results. Retain configuration version/resolved values sufficient to prevent silent policy switches on load. Concrete schema and operation identity remain technical choices.

## Inputs, outputs and events

Inputs: approved checkpoint or live practice-update context, time, character/policy snapshot and counters. Outputs: no-check/validated check/failure, staged then committed gains/counter consumption/timestamp, recent-increase markers, post-commit notifications and CHAR-014 eligibility input. Conceptual contracts do not prescribe API/signal names. No UI completion callback can independently re-award a committed gain.

## Cross-system interactions

CHAR-012 reports raw practice and authorizes counter operations; CHAR-010 scales comparisons; CHAR-005 supplies career factor; CHAR-011 validates permanent state. TIME supplies game timestamps; rest/travel/activity owners request checkpoints; DATA-003 validates locked policies. UI/AV present gains/mastery. CHAR-014/015 handle level eligibility/rewards. CORE scopes checks/readiness and SAVE restores policy/time/counters consistently.

## Edge cases and failure conditions

- Exactly six hours does not qualify by default; several elapsed intervals still produce one checkpoint evaluation, not automatic catch-up loops.
- Long travel and repeated completion callbacks cannot multiply the same check. Default eligible no-gain check still advances timestamp.
- Qualification at cap can consume the whole counter by default; configured preservation/carryover is explicit, not inferred from gain failure.
- Snapshot mastery makes simultaneous outcomes independent of skill enumeration order; newly mastered state applies on the next check.
- Carryover recomputes after each point, stops at finite limit/boundary and cannot exploit fractional rounding to consume zero raw practice.
- Temporary skill buffs do not affect permanent mastery/threshold inputs; initial grants are not practice gains.
- Invalid/missing rules or clock rollback cannot silently award a check; TIME/SAVE must define recovery for inconsistent time.
- Live-mode notifications cannot require repeated blocking popups or become a second mutation path.

## Save/load considerations

Persist fixed mode, relevant resolved progression configuration/version, last-check timestamp, permanent skills and raw counters. Restore these consistently without issuing a checkpoint/live update or replaying notifications as new gains. Loading cannot switch modes/policies because current UI defaults changed.

Staged incomplete operations must either restore coherently under an explicit SAVE contract or be excluded from save boundaries; never save gained skill with unconsumed practice or consumed practice with missing gain. Required missing/changed configuration uses explicit migration/failure policy. Exact serialization, notification-history retention and time representation remain SAVE/TIME scope. New-character initialization must establish a consistent last-check baseline rather than inherit another session's timer.

## Technical constraints

Target: Godot 4.7.2. Share evaluation across modes, separating triggers, pure staged calculation, validated commit and presentation. Use stable identities, safe arithmetic, reliable floor/ceil and session/operation protection. Do not rely on skill array order or popup callbacks to resolve mechanics. Reference source/content remain read-only; APIs, schemas and batching implementation remain engineering decisions.

## Acceptance criteria

1. Default rest/travel checks require elapsed >360 game minutes and update timestamp on valid eligible evaluation even without gains; no automatic catch-up checks occur.
2. Optional fixed live mode checks accepted practice updates without rest/gate, using the same validated progression rules and duplicate/context safeguards.
3. Vanilla requirements/factors and CHAR-010 floor-scaled practice use permanent inputs and safe positive arithmetic.
4. Default threshold qualification clears all practice and yields at most one point/skill, including configured consumption of cap/mastery-blocked qualification.
5. Mod carryover consumes ceil(T/r), recomputes after each point, obeys finite gain limits and compatible bounds; blocked consumption follows the explicit stop rule.
6. Mastery eligibility uses check-start snapshot, allowing simultaneous mastery when initially eligible and producing identical outcomes under reordered skills.
7. Consistent gains/counters/time commit before notifications/CHAR-014 input. Live messages coalesce and cannot grant twice.
8. Invalid policy/context/time/source fails truthfully without partial progression; supported mod overrides preserve explicit validation and fixed mode.
9. Saves restore mode/configuration/time/values/counters without repeated gains or silent policy substitution.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-005/009/010/011/012, DATA-003 and relevant CORE lifecycle/restore constraints. No direct contradiction identified. Optional live advancement explicitly extends default checkpoint-only behavior while retaining raw counters and shared rules. Snapshot mastery intentionally replaces DFU loop-order dependence. Authorized consumption uses separate progression operations under CHAR-012; no negative ordinary practice reports are introduced. Permanent bounds and fixed reflex selection remain binding. Level eligibility/rewards and broader architecture are not approved by implication.

## Outstanding questions and approval

No further blocking advancement-policy question is identified. Before implementation is complete: verify time units/checkpoint routes and original factor fixtures; define mod schemas, cap/threshold reachability and reliable numeric representation; finalize coherent activity/check batching, startup timestamps, UI coalescing and SAVE boundaries/migrations. Exact rest interruption checkpoints and level-sheet presentation remain owner integration dependencies. These cannot waive fixed mode, finite carryover, snapshot mastery or duplicate-safe commit.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-013-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented time/schema/numeric, batching/UI and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
