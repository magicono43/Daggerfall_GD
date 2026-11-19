# CORE-017 — Active gameplay and classic cadence

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Purpose and intended experience

Provide authoritative simulation eligibility and reliable delivery of explicitly slower gameplay updates without tying every system to one cadence or assuming a fidelity target prematurely.

## Confirmed requirements

First interview, confirmed by the user on 2026-11-05:

- Gameplay systems consume authoritative simulation eligibility under CORE-015/016 rather than independently guessing from UI top window/load flags. Gameplay-input eligibility remains separate.
- Leave slow-update frequency open until combat/AI behavior is examined; define reliable scheduling now. Neither DFU-like effective frequency nor 16 Hz is approved as the target.
- Only explicitly designated systems use slow cadence; physics, smooth movement, rendering and UI retain appropriate update mechanisms. Deliver each slower update once with an explicit step identity rather than an ambiguously observed shared boolean.

Second interview, confirmed by the user on 2026-11-05:

- Retain fractional time by subtracting each delivered interval rather than resetting the accumulator to zero, avoiding systematic threshold drift.
- Bound catch-up work per scheduling pass during active stalls and retain remaining eligible time for later passes. Do not silently drop steps or execute unbounded bursts. Exact work limit/prolonged-overload behavior remains combat/AI/performance scope; delayed systems can otherwise lag.
- Pause preserves already-accumulated fractional eligible time but contributes no paused duration. Resume from that fraction. New sessions do not inherit old accumulators. Native-save phase preservation remains SAVE/TIME reproducibility scope.

Third interview, confirmed by the user on 2026-11-05:

- Use explicit stable consumer order with owner-declared dependencies, not accidental registration/scene traversal. Exact order and RNG behavior remain RULE/COMBAT/NPC decisions.
- Stop further gameplay work when suspension becomes effective. Track completed consumers so the same-session resume cannot repeat them. Discard ended-session remainder. Required consumer failure invokes safe recovery rather than skipping it or rerunning partial mutations.
- Fix cadence for each running session. Future tuning/mod changes take effect only at a declared new-session/restart boundary, with explicit restored-timing-state policy. No player frequency slider is implied.

## Inherited requirements

CORE-016 stops automatic simulation/calendar/effects during suspension, permits appropriate UI/loading/real-time presentation and forbids paused-time catch-up. CORE-015 lifecycle readiness is distinct from input/pause/overlays. CORE-005 scope ownership and stale-work rejection apply. Existing entry/restore gates remain authoritative. CORE-009 is deferred and CORE-014 outside scope.

## Existing Daggerfall Unity behavior — reference only

`Assets/Scripts/Game/GameManager.cs`, IsPlayingGame checks pause, save-manager readiness/loading and top-window pause policy. FixedUpdate accumulates delta, emits ClassicUpdate when >= 0.0625 seconds and resets accumulator to zero; inactive processing clears the boolean but retains prior remainder. EnemyAttack, EnemyMotor, EnemySenses and PlayerEntity consume ClassicUpdate.

`ProjectSettings/TimeManager.asset` fixed step is 0.02 seconds. Under steady unchanged active timing, threshold crossing every four steps implies ~0.08 seconds/12.5 Hz rather than nominal 0.0625 seconds/16 Hz. This is source-derived arithmetic, not runtime measurement or proof of original-game timing.

Baseline: local DFU 1.1.1 Release; exact commit unavailable per repository overview. Source remains unchanged. No original cadence/RNG contract is adopted implicitly.

## Detailed scheduling rules

Use CORE-015/016's committed lifecycle and owner-based suspension to derive simulation eligibility. Systems must not invent competing notions of active gameplay from a UI stack, saved flag or sampled input state. Gameplay-input eligibility is separate: an input context can block player actions without proving simulation should stop, and UI/loading/independent presentation can continue while simulation is suspended.

Designate only consumers needing classic-style slower updates. Do not force physics, smooth movement, rendering, audio presentation or UI onto that cadence. The final interval/fidelity target is deliberately undecided until combat/AI timing and random-opportunity behavior are reviewed. Neither the nominal DFU 16 Hz interval nor its source-derived effective ~12.5 Hz is a target by default.

Accumulate eligible simulation elapsed time, never paused/unfocused/initialization duration or raw real-time gaps. Deliver due steps with explicit session/step identity and configured interval. Subtract one interval per fully accounted step while retaining fractional eligible remainder and overdue backlog. Bound work per scheduling pass; retain unprocessed eligible time for later eligible passes rather than silently dropping it or executing an unlimited burst. A pass must remain bounded even if a backlog is large. Exact cap and prolonged-overload treatment require later performance/behavior policy; this feature does not claim that bounded catch-up alone keeps all systems synchronized under sustained overload.

Dispatch each step's designated consumers in explicit stable dependency order, with required bindings and scope-safe registration. Consumers must not infer step count by sampling one global true/false flag. Registration or scene traversal order must not decide outcomes accidentally. RULE/COMBAT/NPC must specify authoritative ordering and RNG contracts; stable dispatch alone is not a guarantee of complete replay determinism.

If suspension takes effect during delivery, prevent further authoritative gameplay work as soon as the gate is effective. Retain current step identity and completion position for safe same-session continuation. Already completed consumers must not receive that step again. Do not mark a partly delivered step fully complete or subtract its time twice. Track enough progress/accounting to deliver remaining permitted work once without multiplying combat/effect mutations. Exact interruption boundaries inside a consumer are owner contracts; no generic rollback of an in-progress mutation is promised.

A required consumer failure enters CORE-005/007 recovery as applicable. Do not continue pretending the step succeeded, silently omit a required system or retry a partially mutating callback as if it had no effects. Safe recovery must determine remaining-session viability; if it cannot, end/reconstruct under the owner contract. This is not CORE-015's optional notification-observer failure isolation: scheduled authoritative work is checked gameplay work.

Pause retains the pre-pause fractional phase and valid current-step progress for that session; paused duration adds no debt. Pending active-time backlog remains pending but cannot run while suspended. Resume only when lifecycle and all applicable reasons permit. Ending the session invalidates its accumulator, backlog, current cursor and callbacks; another character cannot inherit them. Ordinary location changes do not create a new session, but location-owned consumers are rebound under CORE-005 without invoking stale objects or replaying completed work.

Fix the configured interval for a running session. Deferred tuning/mod changes take effect at a declared new-session/restart boundary, not mid-combat. SAVE/TIME must decide whether native saves preserve cadence phase/current-step state or define a consistent reconstruction/reset policy, including eligibility for saving mid-step. No silent load-time reinterpretation of saved phase under a changed interval is approved. This deferral is required before timing-sensitive save fidelity can be claimed.

## Relevant formulas and parameters

Let h > 0 be the configured interval (not yet selected), A eligible accumulated simulation time, and B the positive bounded work allowance per scheduling pass (not yet selected). Without an interrupted current step, due full steps = floor(A / h). A pass processes only work within B; each completed step accounts for h once, leaving all fractional/backlog time. If no backlog remains, 0 <= A < h. Partial-step tracking must preserve equivalent accounting without subtracting twice.

Only eligible simulation elapsed time contributes to A. Real-time pause duration contributes zero. A zero/negative/invalid interval or invalid work allowance cannot be used to schedule gameplay. Whether B counts steps, consumer units or another bounded budget is an implementation/performance decision that must retain explicit step semantics. Intended-rate effects follow CORE-016 and must not be counted twice.

## Required data

Session identity, authoritative simulation eligibility, fixed configured interval, eligible-time accumulator/backlog, per-pass budget, step identity, current consumer completion position, declared consumer dependencies/order/requiredness and scope ownership. Diagnostics need enough context to identify timing/consumer failure without dumping gameplay/save contents. Exact numeric precision, ID representation, budget and restore schema remain deferred.

## Inputs, outputs and events

Inputs: eligible elapsed simulation time, lifecycle/suspension changes, session/location scope changes, validated cadence configuration and consumer results. Outputs: explicit ordered slow-step deliveries with interval/identity, accumulated remainder/backlog, committed completion position, eligibility queries and actionable required-work failure. Public API/signal names are not selected here. A scheduled delivery is authoritative checked work, not a best-effort broadcast event whose listener may silently fail.

## Cross-system interactions

CORE-015 supplies committed state and CORE-016 suspension/rate/focus rules. CORE-005 owns bindings/disposal/stale callback rejection; CORE-007 entry gating means initialization does not accumulate gameplay debt. NPC/COMBAT/CHAR/MAGIC and other declared consumers define timing responsibilities; RULE owns RNG contracts. TIME distinguishes simulation elapsed from calendar advancement; explicit rest/travel need their own bulk/step policy rather than automatically replaying this scheduler for every elapsed calendar unit. SAVE/TIME define timing-phase persistence and valid save boundaries. UI/rendering/AV keep independent appropriate processing. CORE-009 stays deferred and CORE-014 outside scope.

## Edge cases and failure conditions

- Physics delta may not divide h evenly; fractional remainder must survive and prevent systematic threshold drift.
- Active stalls can produce overdue steps. Bounded passes retain debt, but prolonged debt can create behavioral lag; no silent drop/unbounded catch-up resolves that trade-off without later policy.
- Pause/focus loss does not create debt for its duration. Backlog from before suspension must not execute through the gate.
- Suspension after some consumers finish retains their completion status; resume cannot repeat attacks/random draws. Failure inside a consumer requires its explicit safe contract, not blind generic replay.
- Ending/replacing session discards old timing/work. Stale deliveries cannot run against the next character even if local numeric step IDs repeat.
- Location consumer replacement must invalidate old references and respect current step accounting. Binding changes cannot accidentally double-register a role or make traversal order authoritative.
- Required scheduled-work failure is not a harmless observer exception. Stop unsafe progress and enter recovery rather than advancing other authoritative consumers as if the step committed.
- Mid-step saves or cadence-version changes require explicit SAVE/TIME rules before support; neither phase persistence nor phase reset is silently assumed.
- No single cadence can be assumed to match original or DFU combat from source arithmetic alone; measure intended behavior with owner fixtures before selecting frequency.

No balance cadence, RNG algorithm, attack rate, catch-up threshold or frame-rate dependency is approved. Main risks are opportunity-count changes, drift, backlog lag, duplicated mutations and inconsistent partial-step continuation.

## Configuration and balancing options

Cadence interval, exact consumer order, bounded workload allowance and prolonged-overload policy are intentionally open for combat/AI/RULE/TIME/performance review. Configuration is fixed within a running session and not a player slider. Only explicitly classified consumers participate. This approves scheduling constraints, not a global replacement for every update loop or a promise of classic parity.

## Save/load considerations

SAVE/TIME must choose supported timing-phase/current-step serialization or consistent reset/reconstruction semantics. That policy must preserve no duplicate authoritative work, supported activity state and interval-version compatibility. In-memory pause preserves current phase, but this does not automatically approve saving/restoring scheduler cursors. CORE-013 preflight must reject unsupported required timing state once defined. Fresh sessions start with clean timing context; native load cannot inherit the discarded session's accumulator. Existing save files remain unchanged by this specification.

## Technical constraints

Target engine: Godot 4.7.2. Implement interval accounting and ordered dispatch explicitly rather than relying on Unity-style sampled flags or assumed callback order. Use sufficient time precision and positive validated configuration. Honor immediate gating/scope invalidation, bounded work and checked consumer outcomes. Physics integration, numeric precision, step/cursor representation, consumer interruption boundaries and engine scheduling hooks remain implementation decisions to verify.

## Acceptance criteria

1. Slow consumers share authoritative CORE-015/016 simulation eligibility; gameplay input/UI eligibility remains separate.
2. No target frequency is silently selected. Only declared slow consumers participate; physics/movement/render/UI keep appropriate mechanisms.
3. Each scheduled step has explicit originating identity/interval and stable dependency order; a shared sampled boolean or incidental scene order does not govern delivery.
4. Uneven eligible deltas retain fractional remainder, with exactly one interval accounted per completed step. No reset-to-zero drift or double subtraction occurs.
5. Active stalls produce bounded per-pass work with remaining eligible debt retained. No silent dropped steps or unlimited burst occurs; prolonged-overload policy remains an explicit dependency.
6. Pause retains existing fractional/partial-step phase and contributes no paused-time debt. Resume requires eligibility and does not catch up paused wall time.
7. Mid-step suspension stops further gameplay work, remembers completed consumers and resumes the same valid session without repeating them. Session end discards remaining old work.
8. Required consumer failure enters safe recovery rather than skipping the system or blindly replaying partial mutations. Diagnostics identify originating context.
9. New sessions cannot inherit old accumulator/backlog/callbacks. Location changes safely rebind their scoped consumers without duplicate delivery.
10. Cadence stays fixed per running session. Deferred changes activate only at declared session/restart boundaries with explicit restored-state handling.
11. SAVE/TIME explicitly resolve cadence-phase/current-step persistence and save eligibility before timing-sensitive restoration is claimed. No native-load phase behavior is invented here.

These are future verification criteria. No implementation/runtime timing tests or classic-parity measurements have been performed during specification.

## Consistency review

Reviewed on 2026-11-05 against approved CORE-001–008, CORE-010–013 and CORE-015–016 v1, CORE-009 deferral, CORE-014 exclusion, decision log, CORE catalog and CORE architecture review. All nine interview decisions are represented. No conflict identified: only active eligible time accrues, independent presentation continues appropriately, readiness never overrides pause, and checked scheduling failure differs from optional observer failure. Save-phase and exact timing choices remain deliberately open.

## Outstanding questions and approval

Before scheduling implementation is considered complete, owners must select h, exact consumer order/RNG opportunity semantics, bounded allowance B, prolonged-overload policy, partial-consumer interruption contracts, location rebind boundaries and native-save timing policy. These are explicitly deferred design dependencies, not permission to invent defaults. The user approved leaving frequency open while defining this contract. No further blocking player-policy choice is identified for draft review.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”, following the request to finalize CORE-017. This document is finalized v1. Approval reference: CORE-017-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Frequency, work allowance, prolonged-overload behavior, exact ordering and save-phase policy remain explicitly open as documented. No implementation or coding tasks have been produced; approval does not initiate implementation or another feature review.
