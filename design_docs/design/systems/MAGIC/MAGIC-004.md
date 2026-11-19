# MAGIC-004 — Cast execution and history

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Execute a prepared spell through unpaid wind-up, one checked release/payment, and recovery. Attribute practice and recast history to a committed release without duplicating consequences across interruptions, notifications or native loading.

## Intended player experience

Casting has a predictable cadence. Interrupted wind-up costs nothing; released spells remain paid even when they miss or meet defenses. Casting restrictions, timing and practice are moddable, explicitly including climbing casts and cost-based practice gain. Cosmetic animation choices do not secretly alter timing, practice or history.

## Confirmed requirements

MAGIC-004-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm release-time payment, busy wind-up/recovery, failed-release retention, configurable interruption rules, paused timers, explicit timings across routes, per-effect baseline and cost-based moddable practice, origin-based recast history, native-load cancellation and checked delivery preparation. D06/D07/D10 resolve earlier timing, restriction and practice-context questions. The complete specification is approved under MAGIC-004-A01.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime interruption, delivery failure and mod combinations unverified. Source unchanged. Paths relative to reference `Assets/Scripts/`.

- `Game/MagicAndEffects/EntityEffectManager.cs#CastReadySpell` checks silence/ready state and player touch range, deducts cached magicka, then starts player animation or enemy execution. Player delivery occurs later through `PlayerSpellCasting_OnReleaseFrame`.
- `CastNoAnimSpell` applies self or creates a missile before deducting magicka, clears last-spell history and does not use the animated player's practice route. Enemy execution has another delivery/history path.
- `TallyPlayerReadySpellEffectSkills` tallies one point per effect's declared school. The player release handler invokes it before delivery, without requiring eventual hit/effect acceptance.
- Animated ordinary player releases update last spell; no-cost casts preserve prior history. No-animation casts clear history. These flags do not reliably express spell origin.
- `Game/FPSSpellCasting.cs` uses releaseFrame=5, animSpeed=0.04 and frame sequence 0,1,2,3,4,5,0. Manager castInProgress clears at release, although visual animation can still be finishing. These are source constants, not approved native duration profiles.

## Detailed rules and behaviors

### Lifecycle and request admission

Use explicit caster/source/spell context prepared under MAGIC-003. A cast begins when its wind-up starts and remains busy through post-release recovery. New cast/readiness requests during actual casting are rejected without queuing. COMBAT-001's Ready Weapon restriction lasts through this casting period. Readiness selection alone is not execution.

Use one cast identity with phase/commitment state sufficient to prevent duplicate or stale callbacks from paying, delivering, tallying practice or updating history twice. Presentation signals can request/provide release timing but cannot independently authorize duplicate gameplay. Exact API/storage is deferred.

### Wind-up and release commitment

Wind-up spends/reserves no magicka. At release, recalculate RULE-018 cost using current caster context; recheck eligibility, silence permission, source validity, current targeting and MAGIC-003 affordability mode. Target locking, aim sampling, range and line-of-sight details remain MAGIC-005 contracts; this feature requires valid release targeting rather than approving a specific lock-on behavior.

Prepare and validate required delivery before spending. A prepared projectile must not already fly/hit, and preparing a self-effect must not apply gameplay mutations. Required creation/preparation failure produces no payment, practice or history update. No cost-free effect may escape failed preparation.

After preparation and checks succeed, commit authorized payment and delivery once, then release practice/history notifications from the committed result. MAGICKA payment is authoritative CHAR state, using full, positive-magicka or no-cost policy as approved in MAGIC-003. Content validation and separate silence permissions still apply to free casts.

Once delivery commits, subsequent miss, immunity/resistance or absorption is a normal paid outcome, not a failed technical preparation. Defense-owned refunds remain MAGIC-007 scope. A technically valid self-effect whose admission is prevented by normal game rules is not grounds for inventing a refund here.

If release eligibility fails due to silence, insufficient magicka or invalid target, end casting, retain the valid spell readied and require fresh input. No payment, practice, history change or automatic retry follows. Loss of required source invalidates that selection; confirmed death follows death handling. Technical delivery failure must be reported explicitly; recover from a safe unchanged state where preparation failed.

Unexpected failure after partial gameplay mutation requires explicit same-cast recovery preserving known committed facts. Do not blindly retry delivery, reroll outcomes or refund while leaving effects active. Exact owner ordering/recovery receipts are implementation dependencies; unproven failure atomicity is not permission to report success. This draft does not impose a general transaction framework.

### Interruptions and suspension

Default wind-up cancellation conditions are confirmed death, paralysis, entering climbing or losing a required source. Ordinary damage alone does not interrupt. Before release, cancellation costs no magicka/practice and retains selection only if its source remains valid; no canceled cast later resumes/releases automatically.

Validated mod rules independently control whether climbing, paralysis and ordinary damage prevent cast start or interrupt a cast underway. Climbing casts must be supportable. Confirmed death and required-source loss remain mandatory stops before release. Silence uses MAGIC-003's independent permission; this configuration is not a generic bypass of death, invalid content or unavailable sources.

After release, preserve payment, practice/history and delivered effects/projectiles. Interrupting the caster cannot recall released payloads or undo consequences. Where the session continues, forced interruption retains remaining recovery rather than permitting an immediate new cast. Death still stops ordinary actor gameplay; this is not permission to resume dead actors. Summoned/source-dependent ongoing effects retain their own lifecycle policies.

Ordinary pause freezes wind-up and recovery; load/focus/menu wall time cannot complete them. Eligible gameplay resumes the existing phase under input rules, not a new cast from stale physical input. Native loading has the explicit cancellation behavior below rather than ordinary pause resumption.

### Timing and execution routes

Player, NPC and animation-free casts use explicit validated moddable wind-up/recovery timings. Hiding/replacing animation alone never shortens gameplay timing or changes practice/history. Explicit ability profiles may use zero wind-up, but zero-time releases still execute once under the same checks. No implicit per-frame recast loop or extra casting queue is approved.

Exact baseline durations and NPC profiles require verification. Animation/AV integration must preserve authoritative release/recovery timing and mandatory failure handling; this draft does not adopt DFU's visual frame interval as a complete native cast duration. Runtime timing capture/modifier rules and selector precedence must be documented without allowing cosmetic edits to bypass recovery.

### Practice and mod extensibility

Default ordinary player releases grant one raw practice point per active effect's declared school, including repeated school entries. Later misses/resistance do not revoke release practice. Rejected, canceled or interrupted pre-release attempts, preparation failures, previews and restoration grant none. Item/innate effects require explicit practice eligibility; animation suppression alone cannot change it.

Practice eligibility and amounts must support broad validated mod configuration, explicitly including practice based on spell cost. Provide calculated current spell cost before payment exemptions, actual magicka spent, ordered effect schools, stable spell/source identity and caster context. The calculated cost here is the RULE-018 cast quote before applying a free/underfunded payment mode; the actual debit is a distinct input. Any further cost-purpose variants require explicit schemas rather than ambiguous unlabelled values.

Mods may use these inputs for cost-based amounts, per-effect weighting or distinct-school awards. No particular cost-to-practice coefficient, rounding or universal anti-grinding penalty is selected. Rules return supported nonnegative integer skill contributions through CHAR-012's validation/cap/deduplication. Exact expression/hook API and additional supported contexts remain technical design; broad moddability does not authorize arbitrary side effects during quoting/preview.

Calculate/store the qualifying once-only release result with cast context, so repeated callbacks/impact/load cannot award again. Apply only under CHAR-012's living-character/current-session requirements; dead/stale callbacks cannot bypass them. Genuine later casts remain distinct qualifying actions.

### Last-spell history and recast

Successful ordinary player spell releases update last-spell history regardless of animation or magicka cost. Item/innate casts preserve that entry and cannot turn into unrestricted ordinary recasts. Origin/authorization is explicit rather than inferred from animation/no-cost flags.

A released spell that later misses or is resisted still updates history. Failed/canceled pre-release attempts and delivery preparation failures do not. Store sufficient stable definition/custom-settings/source context to re-enter normal MAGIC-003 readiness and current eligibility checks. History is not a free cast, ownership grant or frozen cost quote. Exact spellbook/access prerequisites remain MAGIC-011/source-owner scope; DFU's spellbook-item gate is not newly approved here.

## Relevant formulas and parameters

MAGIC-003 supplies current C, current M and authorized debit: C for full-cost admission M≥C, min(M,C) for positive-magicka mode M>0, and zero for no-cost. RULE-018 supplies cost evaluation. Wind-up/recovery use nonnegative supported eligible-gameplay durations; exact baseline values remain open. Default practice per school equals the number of active entries assigned to that school; mods may replace eligibility/amounts using declared cost/context inputs. No default cost-based formula is invented.

## Required data

Cast/session/caster identity; stable spell and source identity/settings; readiness authorization; phase, release outcome and remaining timing; current cost/debit/affordability policy; silence/restriction permissions; target/delivery preparation result; committed delivery/payment facts; ordered effect schools and resolved practice result; last eligible ordinary spell; partial-failure obligations where supported. Exact persistence/operation schemas remain dependencies.

## Inputs, outputs and events

Inputs: accepted cast request, current actor/target/source/cost checks, eligible time, interruption/suspension changes, delivery preparation/commit outcomes and native restore. Outputs: wind-up/busy state, failure or cancellation, one release/payment, recovery, once-only practice/history update and optional presentation. Cast-start, release and recovery-finished are distinct conceptual notifications. A release notification is not a second delivery request or proof the eventual target accepted effects. Concrete APIs/signals remain unselected.

## Cross-system interactions

- MAGIC-001/002 and DATA-011 supply stable complete definitions/providers; MAGIC-003 supplies readiness, automatic policy and affordability/silence separation. DATA/MOD validate extension policies under the locked content plan.
- MAGIC-005 owns aiming/target delivery details, MAGIC-006 admission, MAGIC-007 defenses/refunds, MAGIC-008–010 effect time/lifecycle/persistence, and item/innate owners their required sources. Delivery preparation cannot run admission side effects prematurely.
- CHAR-018 commits resource operations; CHAR-012 records eligible practice once; CHAR-023 and COMBAT-020 enforce player/NPC death. NPC AI supplies actual requests and source context.
- COMBAT-001 governs weapon readiness throughout casting. MOVE-018 preserves one-input spell/interaction arbitration; CORE-016/017 govern suspension/time/session context. AV/UI follow authoritative state.
- SAVE/CORE-013 validate native state/history and reconstruct coherent commitments. COMBAT-009 governs arrows, not automatic proof of magic-projectile persistence; MAGIC's released payloads need their own delivery/save contracts.

## Edge cases and failure conditions

- Buff expires or magicka drains during wind-up: re-evaluate at release; failure retains readiness without payment/practice/history.
- Target invalidates during wind-up: fail current release checks without automatic target acquisition or retry; MAGIC-005 settles exact targeting.
- Projectile creation fails: no live payload/payment. Self preparation fails: no applied bonus/payment. Normal later defense is a committed outcome.
- Duplicate animation release or zero-duration processing: one debit/delivery/practice/history result; old-session callbacks cannot affect new actors.
- Mod allows climbing casting: no climbing-only start rejection/interruption where permitted, while other mandatory checks remain active.
- Interruption immediately around release: retain already committed facts; cancellation prevents later commitment. Exact simultaneous-event order needs integration fixtures.
- No-animation/free ordinary spell: timing/history/practice follow explicit policy. Item-triggered cast cannot erase history or become an ordinary unrestricted recast.
- Cost-based practice with free/underfunded NPC modes: distinguish calculated cost from debit; player eligibility still follows declared origin/context and CHAR-012.
- Failure after partial mutation: preserve explicit progress and require recovery; do not double deliver/refund or declare empty success.

## Configuration and balancing options

Support validated casting restriction/interruption rules, wind-up/recovery profiles and practice eligibility/amount rules, including at least cost-based formulas and school aggregation options. Defaults remain unpaid wind-up, release payment, stated forced interruptions and per-effect practice. Exact schemas/selectors/precedence, timing values and additional context hooks require owner design. Individual item/innate exceptions and NPC profiles are not approved wholesale. No automatic universal damage-stagger or practice diminishing returns is added.

## Save/load considerations

Native loading cancels unfinished wind-up without payment and restores valid selected spell readied with fresh input, never an automatic release. It preserves remaining post-release recovery and last-spell history. Already committed payment, practice and delivered effects/projectiles remain committed; restore cannot tally, debit or release again. Loading time contributes no recovery progress.

Store coherent release/phase/obligation facts or save at a safe boundary; unresolved partial operations must not become ordinary successful snapshots without supported recovery. Exact snapshot eligibility/format/versioning belongs to SAVE/owners. Required missing sources/history references use CORE-013 compatibility/recovery rather than silently substituting spells. Released projectile persistence is its owner's contract, independent of wind-up cancellation; no deletion/replay workaround is approved here. Classic/DFU save import remains outside scope.

## Technical constraints

Target Godot v4.7.2 without requiring Unity animation events or broker classes. Preserve explicit phases, eligible time, caster/source context and once-only owner mutations across player/NPC/no-animation routes. Presentation may differ; hiding it must not alter rules. Exact factory/preparation operations, error recovery, deduplication storage, mod API and save schema remain technical dependencies. Reference source is read-only. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Wind-up is unpaid; release rechecks current cost/eligibility and spends once only with prepared delivery.
2. Busy state lasts from wind-up through recovery; rejected requests never queue. Cosmetic animation removal cannot shorten timing.
3. Release eligibility failure retains valid readiness with fresh input, no payment/practice/history and no automatic retry.
4. Default forced wind-up interruptions and mod-controlled climbing/paralysis/damage rules behave as specified; death/required-source loss still stop pre-release commitment.
5. Post-release interruption preserves committed facts and remaining recovery. Pause freezes timings without granting another cast.
6. Player/NPC/no-animation/zero-wind-up routes share commitment safeguards and explicit valid timings.
7. Ordinary release grants default per-effect school practice once; failed pre-release work grants none; later miss/resistance grants no second practice.
8. Mods can configure eligibility and compute nonnegative integer practice from calculated cost or actual debit, ordered schools and source/caster context, under CHAR-012 limits.
9. Ordinary released spells update history independent of animation/payment exemptions; item/innate casts preserve it and recast revalidates eligibility.
10. Native restore cancels wind-up, restores readiness without automatic cast, preserves recovery/history and never replays committed payment/practice/delivery.
11. Required preparation failures have no gameplay/payment result; partial post-mutation failures use explicit same-cast recovery rather than blind retry/refund.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-003, RULE-018, CHAR-012/018, COMBAT-001, CORE-013/016 and recorded D01–D12, with existing MAGIC-001/002 identity/provider rules. No direct contradiction identified. MAGIC-004 selects the release boundary left open by MAGIC-003 and preserves its current-cost modes. D07's mod permissions are explicit exceptions for climbing/paralysis/damage casting, not changes to COMBAT-001's weapon restrictions. Cost-based practice remains nonnegative, once-only and owner-eligible under CHAR-012. Native wind-up cancellation refines ordinary suspension without replaying commitments; magic-projectile persistence remains open rather than borrowed from arrow behavior. Broader architectural proposals remain unapproved.

## Outstanding questions

No further blocking player-policy choice is identified for this execution/history scope. Before implementation is complete: verify timing baselines/profiles and capture policy; define exact source eligibility/target sampling, effect/delivery preparation and partial-failure recovery; specify interruption/mod selector precedence and practice expression/API limits; define native coherent snapshots, history compatibility and magic-projectile persistence; integrate once-only phase notifications with input/AV. These dependencies cannot authorize silent repairs, post-load release, duplicate practice or implicit refunds. Baseline cost-based practice coefficients remain deliberately unspecified because cost-based gain is a supported mod option, not the selected default.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-004-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented timing profiles, delivery/recovery operations, mod/practice APIs, source/target contracts and native-save/projectile dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
