# CHAR-016 — Paid skill training

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Exchange payment, time and fatigue for skill practice through authorized guild/temple services, with safe settlement and explicit mod extensions for staged or interruptible activities.

## Intended player experience

Choose an offered skill, confirm a truthful price and complete training under clear eligibility/cooldown rules. Training buys practice rather than a guaranteed skill point and remains purchasable even when the practice counter is full. Mods may change stages, consequences and interruption behavior through declared policies.

## Confirmed requirements

CHAR-016-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish the baseline practice/time/fatigue, cooldown/limits, quoted price/access, validated transaction, full-counter purchasing, protected default activity and explicit mod stages/interruption settlements.

CHAR-012 owns raw saturation, living/session context and duplicate-safe reports. CHAR-013 default/live advancement consumes practice; training does not independently award permanent skills. CHAR-011 supplies permanent eligibility values. CHAR-014/015 actual level remains distinct from unclaimed eligibility for pricing. Guild/temple owners retain service access and skill definitions.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/DaggerfallGuildServiceTraining.cs#TrainingService`: blocks elapsed time below 720 game minutes, then offers training. Exactly 720 passes.
- ConfirmTraining checks funds before showing a skill picker; TrainingSkill re-fetches the list by index, rejects permanent skill strictly above the trainer maximum, recalculates price and calls DeductGoldAmount without checking its result. Intended stable quote/revalidation eliminates this stale-offer/partial-payment risk.
- TrainSkill timestamps start, advances three hours, decreases fatigue by PlayerEntity.DefaultFatigueLoss×180, rolls inclusive integer 10–20 times the skill advancement factor and tallies practice. No RaiseSkills call is made here.
- `Game/Guilds/Guild.cs#GetTrainingMax` defaults to 50; GetTrainingPrice is actual player level times member 100/nonmember 400. GetTrainingSkills routes temple services through their divine-specific lists, including nonmember temple routes; other services use guild skills. Exact access/rank rules require guild/temple owner review.
- `Game/Entities/PlayerEntity.cs` declares DefaultFatigueLoss=11, making the inspected training deduction 1,980 internal fatigue units. This is not a cost of 1,980 displayed fatigue points.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Complete service access/skill lists, time-event ordering and runtime fatigue remain verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Offer and eligibility

Resolve offered skills, access requirements, trainer limits and prices through the guild/temple/service owner. Identify selected skill/service by stable IDs, not a mutable picker row. Default price is actual level×100 for members or actual level×400 for nonmembers. Unclaimed eligible levels do not raise price before CHAR-015 commits actual levels.

Compare permanent skill to trainer maximum; default maximum 50 is inclusive. Temporary effects cannot qualify/disqualify the character. Enforce character-wide cooldown independent of trainer, guild or selected skill. Default next start requires elapsed≥720 game minutes from prior accepted training start. No prior training is a distinct fresh state, not necessarily a timestamp that prevents the first session.

Show a quote for the specific service/skill before acceptance. Revalidate current living character, service access/offering, permanent skill limit, cooldown, funds, fatigue and required definitions before payment/start. Changed price requires fresh confirmation; changed skill/access cannot silently redirect the purchase. Cancelled/failed preflight changes no payment, time, fatigue, cooldown or practice.

Do not reject or require a special purchase warning solely because raw practice is at/near its cap. Training remains available with the same payment/time/fatigue/cooldown costs. It buys practice subject to normal saturation, not a guaranteed skill increase or refund.

### Default activity and settlement

At accepted start, successfully charge the confirmed price and record the character-wide cooldown start once. Failed payment cannot begin a successful activity. Advance three game hours as a protected training activity; propagate elapsed time to responsible systems, without ordinary combat interruption. Apply one training fatigue cost equivalent to 180 ordinary base-fatigue minutes; do not additionally drain the same interval through the ordinary activity path.

Require enough fatigue before acceptance to finish without reaching exhaustion: current usable fatigue must exceed the resolved full training cost. Default protection does not invent immunity to every future quest/time event; exact event handling follows TIME/QUEST/activity contracts while maintaining the uninterruptible default. Mod interruption is separately declared below.

On successful completion credit raw practice Q=k×u, u uniform inclusive integer 10–20 and k the selected skill's positive advancement factor. Retain generated results once resolved so callbacks/restore cannot reroll or duplicate credit. Whether sampled at preparation or completion is an engineering detail, but any resolved result is stable. No reflex/career multiplier is applied to this raw credit; CHAR-013 handles advancement factors later according to its approved formula.

Default advancement mode does not treat training completion as a new rest/travel checkpoint. In live mode, a qualifying accepted practice update invokes CHAR-013 through its shared rules, after the completed training settlement context is consistent. A full raw counter saturates under CHAR-012; it is not a reason to refund, bypass caps or manufacture a gain/check from duplicate/no-change events.

This is one authoritative operation with explicit stage/completion identity. Preflight may be cancelled without effects. Default successful activity is not an ordinary cancellable purchase after start. Detected failures after start require explicit recovery, preserving receipts for effects already committed rather than reporting partial success or blindly restarting all costs. No rollback of arbitrary elapsed world events is promised.

### Mod stages and interruptions

Support declared training stages and supported activity/event hooks that change order and consequences. Mods must explicitly define payment, cooldown, time advancement, fatigue and practice settlement, including required/optional stage failures and interruption paths. The default order above remains the initial policy, not a universal hard-coded sequence.

Allow event-driven interruption during a configured time skip. Interruptible definitions must declare what is retained, refunded or awarded and whether partial progress is terminal or resumable. Initial interruption policy: retain full payment and cooldown start, advance only actual elapsed time, charge corresponding elapsed training fatigue and grant no practice unless completion was reached. Do not charge the full duration then also replay elapsed costs.

Validated alternatives may refund payment or grant partial practice under declared formulas. Exact proportional rounding, eligibility and source provenance are required for those alternative definitions; no universal prorating formula is silently assumed. Supported resumable activities need explicit saved stage/progress contracts. New executable behavior requires MOD/owner extension support, not arbitrary code hidden inside unvalidated data.

Duplicate callbacks, interruption/completion races and save/load must not charge, refund, advance the same interval or reward twice. If completion already committed, a late interruption cannot retroactively refund or erase the result. Context/stage validation precedes each mutation. Gameplay stays gated until the activity safely yields to its declared interruption outcome; ordinary enemy simulation cannot leak into the protected default.

### Presentation

Explain offered skill, eligibility errors, quoted price, duration/cooldown and that training contributes practice. Show completion/interruption/failure truthfully; do not claim a permanent skill gain when only practice was credited. Raw practice counters remain developer diagnostics under CHAR-012. Changed quotes require explicit confirmation, but no rejected near-cap warning/refusal is introduced.

## Relevant formulas and parameters

- Default cooldown C=720 game minutes, measured start-to-start; eligibility elapsed≥C.
- Default duration d=180 game minutes. Completion leaves 540 minutes until next start if no other time passes.
- Trainer maximum M=50; permanent skill S≤M qualifies, S>M fails.
- Price=actual level×(member ? 100 : 400), subject to service-owner overrides.
- Raw practice Q=k×u, u uniform integers [10,20]; apply CHAR-012 safe saturation.
- Default full fatigue cost F=base ordinary fatigue rate×180; source reference rate 11 internal units/minute gives F=1,980. Require preflight fatigue>F, avoiding exhaustion. Modded duration/rate/settlement must use explicit consistent units.

Safe supported integer arithmetic is required for price, credit, fatigue and timestamps. Training's use of k in its award and CHAR-013's use of k in the threshold are both retained; do not cancel/rewrite them implicitly.

## Configuration and balancing options

Validated mods may override supported duration/fatigue/practice-roll parameters, cooldown, service price/limit/skill definitions, activity stage order/effects and interruption/settlement policies. Guild/temple access remains owner-controlled. Respect DATA-003 precedence/configuration locking and supported added-skill IDs under CHAR-009/011.

Require valid ranges, compatible units, nonnegative supported prices/costs/cooldowns, positive supported skill factors, explicit stage references and complete settlement contracts. Unknown effects or invalid policies fail rather than silently fall back. No automatic price bargaining, guaranteed skill point, new full-counter restriction or generalized trainer system outside the approved service ownership is introduced.

## Required data

Stable character/service/skill and quote identity; actual level/member/access context; offered skills/limits; cooldown state; current fatigue/funds; resolved stage/policy configuration/provenance; operation/stage receipts; elapsed duration/costs; retained random outcomes and credited practice; interruption/failure/refund/completion state. Exact schemas/transactions remain owner dependencies.

## Inputs, outputs and events

Inputs: service interaction, skill selection, quote confirmation/cancellation, validation results, time/event progression, configured interruption and restore. Outputs: unchanged preflight rejection or accepted staged operation; once-only payment/time/fatigue/cooldown/practice effects; truthful completion/interruption/failure and optional declared refund/partial-credit results. These are conceptual contracts, not approved API/signal names.

## Cross-system interactions

Guild/temple/FACT/ECON own access, membership, offered skills, limits, prices and funds. TIME advances world systems; QUEST/NPC/activity owners supply supported time events and interruptions. CHAR/vital owners validate fatigue; CHAR-012 credits raw practice; CHAR-013 governs advancement; CHAR-014/015 actual level feeds price only after claim. UI presents quote/results. DATA/MOD validate stage extensions, CORE scopes/gates activity and SAVE preserves coherent receipts/state.

## Edge cases and failure conditions

- Exactly cooldown boundary qualifies; skill exactly at trainer max qualifies; temporary modifiers cannot change either policy.
- Offer list reorder, changed membership/level/price or depleted funds cannot charge a different unconfirmed quote.
- Full/near-full practice counter still permits purchase and all costs; saturation grants no automatic refund.
- Insufficient fatigue fails preflight without payment/time/cooldown. Ordinary fatigue cannot double-charge the training interval.
- Repeated selections or completion callbacks cannot multiply credit/costs. Default training does not force rest-mode advancement.
- Interruptions retain only declared elapsed effects and settlement; completion/interruption races resolve once.
- Missing required stages/effects or post-start failures produce explicit recovery, not a free retry that repeats irreversible time/payment.
- Loading must not replay paid stages, random draws, refunds or full activity time; another session cannot receive stale training credit.

## Save/load considerations

Persist last accepted training start and active operation/stage/settlement state consistently with funds, world time, fatigue and raw counters. Save/load cannot bypass cooldown, reset a resolved roll or replay credited practice. Supported resumable interruptible training preserves exact elapsed progress and receipts; terminal interruption cannot resume as if it had not occurred.

SAVE must either support coherent activity snapshots or exclude unsafe save boundaries explicitly. Required missing definitions, invalid clock/cooldown or inconsistent receipts need migration/recovery rather than silent zeroing or full rerun. No prior training must be distinguishable from missing required saved data. Exact duration representation and crash recovery remain TIME/SAVE contracts.

## Technical constraints

Target: Godot 4.7.2. Separate quote/eligibility, activity stages, authoritative settlement and presentation. Use stable skill/service IDs, safe arithmetic, verified payment result and explicit context/stage identity. Allow supported mod stage extension without incidental UI-callback ordering. Reference source/content remain read-only; concrete APIs, transaction mechanism and event scheduler remain engineering choices.

## Acceptance criteria

1. Vanilla training grants uniform [10,20]×skill-factor practice after three hours and one explicit fatigue cost, without direct guaranteed skill gains.
2. Character-wide start-based 720-minute cooldown and inclusive permanent trainer maximum are enforced with valid first-training state.
3. Member/nonmember actual-level prices are quoted for stable skill/service identity; changed quote requires reconfirmation and failed preflight changes nothing.
4. Payment/start cooldown and completion credit occur once under declared order; insufficient funds/fatigue cannot produce partial successful training.
5. Full/near-cap practice never blocks training or adds mandatory cap warnings/refunds; normal saturation applies.
6. Default activity is protected, propagates elapsed time and avoids duplicate fatigue. Default/live progression integration follows CHAR-013.
7. Mod stage/order/event and interruption policies validate explicitly; initial interruption retains payment/cooldown, charges elapsed time/fatigue and gives no incomplete practice.
8. Declared refunds/partial-practice/resume policies cannot duplicate mutations through races, retries or loading.
9. Completion/failure/interruption feedback matches committed state; required recovery and coherent saved receipts prevent replay/bypass.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-005/010/011/012/013/014/015, DATA-003 and relevant CORE lifecycle/restore requirements. No direct contradiction identified. Full-counter purchasing follows the user's correction and is compatible with raw saturation. Training supplies valid simulated practice, not a universal new default-mode advancement checkpoint. Protected default and interruptible mod stages are explicit alternatives; mod order does not waive once-only settlement. Actual rather than eligible level determines default price.

## Outstanding questions and approval

No further blocking training-policy question is identified. Before implementation is complete: verify service access/skill/price fixtures and time units; define stage/event schemas and supported MOD hooks; finalize fatigue/elapsed-time propagation, refund/partial-credit rounding for alternatives and failure recovery; establish coherent SAVE receipts/resume/clock contracts. These dependencies cannot introduce rejected full-counter restrictions or waive quote validation, once-only settlement or configurable stage support.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-016-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented service/time/vital, MOD and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
