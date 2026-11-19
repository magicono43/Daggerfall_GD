# MAGIC-008 — Magic rounds and elapsed time

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Advance ongoing effects reliably through ordinary gameplay and authorized simulated time, preserving all required ticks/expiry outcomes while supporting alternative timing models and compatible native-save transitions.

## Intended player experience

Default magic uses shared game-minute rounds. Pausing does not consume effects. Rest/travel processes the full authorized interval unless interrupted, without silently discarding long-lived effects. Mods can replace round-based behavior with gameplay-second/real-time profiles. Existing saves prefer explicit migration or supported old-profile continuation rather than routine rejection or lost effects.

## Confirmed requirements

MAGIC-008-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm the moddable timing system, round default, full elapsed accounting, pause/explicit-advance separation, independent timing controls, saved-profile compatibility/migration/continuation, gameplay-second conversion, default round accounting, chronological scheduling and interruptible advancement. The complete specification is approved under MAGIC-008-A01.

Inherited MAGIC-006 immediate accepted-effect application, CORE-016 suspension, RULE-003 retained outcomes and MAGIC-004 cast timing remain distinct contracts. MAGIC-009 owns detailed merging/removal, MAGIC-010 effect persistence, TIME the calendar and authorized advances.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full disease/poison catch-up and runtime expiry fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/MagicAndEffects/`.

- `EntityEffectBroker.cs#Update` compares classic game minutes against lastGameMinute and broadcasts one OnNewMagicRound per crossed minute, including explicit time advances during pause. It skips loading/pre-init.
- Catch-up is capped at two days, 2880 rounds; after processing it sets the cursor to current game minute, losing excess generic rounds. Comments justify this using expected short durations, constant states and separate disease/poison catch-up paths. Modded long-lived effects need explicit target behavior rather than those assumptions.
- `InitMagicRoundTimer` resets minute cursor/count after start/load. SyntheticTimeIncrease signals some travel/prison time jumps; completion notification follows broker catch-up.
- `EntityEffectManager.cs#DoMagicRound` iterates a copied bundle list, ignores dead/disabled actors, ticks effects with remaining rounds or equipped-item sources, and ends duration effects otherwise. Item rerolls/callbacks also participate.
- `EntityEffect.cs#BaseEntityEffect.MagicRound` decrements remaining rounds. Assignment gives accepted effects an immediate round. Exact family overrides can differ; source inspection is not a universal proof of all effect lifetimes.

## Detailed rules and behaviors

### Clocks and timing profiles

Default ordinary round effects align to shared one-game-minute boundaries. An effect applied just before a boundary may receive its next scheduled round soon afterward. This is not an application-relative one-minute delay.

The timing system itself must support validated mod alternatives, not merely a global round-length slider. Profiles can independently declare duration units, tick interval, shared-boundary or application-relative scheduling, and periodic payload versus continuously active state until expiry. Support eligible-gameplay seconds independent of calendar speed, allowing real-time styles while retaining the round default.

Gameplay seconds advance only with eligible active simulation; they are not wall-clock seconds while paused, loading or closed. Exact effect-profile schemas, custom scheduling APIs and safe supported numeric domains remain technical dependencies. Continuous state need not mutate every rendered frame: owner operations establish/remove it at its lifetime boundaries.

Immediate initial application remains default under MAGIC-006. A profile changing that behavior must explicitly declare its effect policy rather than deriving it from hidden animation or scheduler settings. Profile selection does not change cast wind-up/recovery under MAGIC-004 automatically.

### Default rounds and lifetime

For ordinary positive duration N rounds, the immediate initial application counts as one payload application. There are at most N−1 later scheduled payload ticks, and cleanup occurs at the boundary after the final active round. A one-round effect applies immediately and remains active until the next shared boundary; it does not receive another payload just for expiring.

For example, a two-round effect applies immediately, ticks once at the next shared boundary and cleans up at the following boundary. Earlier valid removal/merge/source rules may change that lifetime. Zero-duration immediate effects remain governed by their explicit effect rules, not forced into a one-round buff; this feature does not reinterpret all zero values.

Alternative profiles explicitly define elapsed-time lifetime and tick accounting. Exact zero-duration legality, merge changes and cleanup owner behavior remain effect/MAGIC-009 contracts. No duplicate initial application is allowed on schedule registration or native restore.

### Pause, ordinary elapsed time and authorized jumps

Ordinary pause/focus loss contributes zero to effect progression and accumulates no wall-time backlog. Loading and native restore are reconstruction, not simulated time. Ordinary gameplay advances each profile using its declared clock.

Rest/travel/prison and other authorized calendar operations supply an explicit elapsed-time request. Their processing may occur while ordinary gameplay is suspended without treating UI pause as ordinary ticking. Report completion only when required effect work for the actual completed interval has settled.

For gameplay-second profiles, baseline simulated conversion uses an explicit normal calendar-to-gameplay rate held consistently for the operation. If K is positive game seconds per normal gameplay second, requested calendar interval ΔG corresponds to ΔS=ΔG/K eligible-gameplay seconds. Never use loading-screen duration. Profiles may override that conversion or explicitly freeze during such operations. The baseline value/provenance of K remains TIME/configuration work; no new universal numeric timescale is selected here.

### Full elapsed accounting and ordered processing

Account for the full authorized interval without silently discarding generic rounds after a fixed cap. Use equivalent bulk advancement only where all relevant outcomes/order are preserved. Otherwise process bounded sequential work while retaining unfinished progress. Work budgets limit processing per batch/frame, not simulated consequences or total duration.

Process due ticks, expirations and new effects chronologically. Document deterministic tie ordering for simultaneous events across relevant owners; callback-registration order cannot determine gameplay. Newly created effects begin at their creation time and cannot receive retroactive ticks from the interval before they existed. Ordinary shared-boundary rules and immediate application must be reconciled by that documented order.

Retain completed event/results so yielding, retry or restore cannot repeat damage, healing, infection, grants or random checks. A disease/poison family's specialized elapsed handler and generic scheduling cannot both apply the same progression. Effect owners must explicitly declare which path owns each event. Constant/held effects may avoid redundant computation only where equivalent lifecycle/source outcomes are preserved.

### Interruptions and truthful elapsed outcome

If processing causes death or an applicable owner-defined interruption, stop at that simulated point and preserve completed consequences. Report actual elapsed time and remaining/unfulfilled requested interval, not full requested completion. Rest/travel/prison owners define their applicable nondeath interruptions and resume/cancel decisions; scheduler does not invent those policies.

TIME must coordinate calendar publication with effect/event progression so stopping at an earlier event does not leave a falsely completed future calendar. This is an explicit integration dependency, not approval of rollback after exposed irreversible future events. Required technical failure likewise retains progress and uses recovery rather than skipping unfinished effects and declaring success.

Affected simulation/readiness must not expose an inconsistent partially advanced world. Exact loading coverage, safe unrelated work and batching UI belong to CORE/TIME. No universal blocking popup, numeric timeout or general transaction framework is selected.

### Configuration, native migration and old-profile continuation

Resolved timing rules remain fixed for the application run under DATA-003/MAGIC-001 configuration lifetime. A locked configuration may contain both a new profile for new applications and supported saved profiles for existing effects; this is explicit resolution before readiness, not live arbitrary code activation.

Native saves retain each effect's timing profile identity/version, remaining duration, next-tick progress/phase and required completed-event facts. Preserve fractions/units sufficiently to avoid refresh, lost lifetime or extra ticks. Exact representations remain SAVE/MAGIC-010 contracts.

When changing timing rules, prefer a supported documented migration preserving remaining lifetime and next-tick progress under explicit old/new unit and semantic conversion. Do not blindly multiply minutes into seconds or restart durations. Migration validates before replacing the current session under CORE-013.

If no safe conversion exists, offer disclosed continuation with the supported saved profile for already-active effects, while new applications use the new profile. If old support is also unavailable, offer restoration of required profile/configuration. Do not silently delete effects, issue extra ticks or promise arbitrary incompatible code can always migrate. Unavailable required content still uses established safe recovery; the preference for continuation does not waive CORE-013 validation.

Cross-profile merges must have explicit compatible interpretation under MAGIC-009 before combining states; continuation does not authorize silently folding old units into new ones. Mod executable activation/dependencies remain MOD-owned.

## Relevant formulas and parameters

Default interval=one game minute, globally aligned. Default positive N-round payload count≤N including initial application; normal scheduled payload count≤N−1, cleanup after final active round. Eligible-time clocks contribute zero while ordinarily suspended. Simulated gameplay-second baseline ΔS=ΔG/K for explicit positive K fixed for the operation. No generic 2880-round loss cap or arbitrary native profile duration/conversion constant is introduced.

## Required data

Effect/source/actor/session identity; profile ID/version/units/clock; initial-application status; remaining lifetime, next due event/phase/fraction; stable event ordering/retained outcomes; supported bulk/sequential ownership; authorized time-request identity/start/requested/actual interval; operation conversion rate/policy; interruption/remaining work; resolved legacy profile and migration provenance. Exact schemas/precision/limits remain dependencies.

## Inputs, outputs and events

Inputs: eligible ordinary elapsed time, effect creation/removal/source changes, explicit time request, current profile plan, migration/continuation choice and owner tick/interrupt results. Outputs: due once-only events, current lifetime/state, cleanup requests, retained partial advancement, actual elapsed/completion/interruption/failure and compatible restored state. API/signal names remain unselected. Scheduler completion is not automatically successful travel/rest reward completion.

## Cross-system interactions

TIME owns calendar, normal rate, authorized jumps and cross-system chronological coordination. CORE-016/017 own simulation eligibility/bounded scheduling; SAVE/CORE-013 safe snapshot/restore and migration. MAGIC-006 supplies immediate initial application; MAGIC-009 merging/removal, MAGIC-010 persistent effect state; disease/poison/item families declare elapsed handlers. CHAR/death and rest/travel/prison owners supply authoritative consequences/interruptions. DATA/MOD resolve validated profile coexistence and activation. UI/AV observe progress without ticking effects.

## Edge cases and failure conditions

- Effect created just before shared boundary: legitimate short next-round wait, no duplicate initial event.
- Long-lived mod effect exceeds two days: full remaining interval processed, bulk-equivalent or retained sequential work, never discarded by source cap.
- Constant/poison/disease has custom elapsed path: no double progression from generic rounds plus family catch-up.
- Tick creates effect or changes another's expiry: schedule from actual simulated event point, respect deterministic ties, no retroactive ticks.
- Lethal tick partway through travel/rest: stop at that time, retain death, report actual advance; do not publish completed future operation.
- Pause/load/offline time: zero ordinary advancement, no catch-up burst on resume.
- Profile changes in existing save: explicit migration preferred, supported disclosed coexistence next, configuration restoration if unavailable; no silent loss/reset.
- Merge old/new timing profile: require explicit unit/semantic compatibility, not guessed numeric addition.
- Technical failure mid-batch: retained committed events/remaining work and safe recovery; no replay, silent skip or false completion.

## Configuration and balancing options

Support round-based and gameplay-second timing models, explicit per-profile intervals/units/alignment/lifetime styles, simulated-time conversion/freeze policy and declared migration. Modding must be capable of replacing the ordinary round timing model with a supported real-time alternative. Exact scripting/hook surface, profile selectors/precedence, numeric limits and effect-family conversions remain design dependencies; no blanket arbitrary scheduler execution is implied. Default remains regular rounds; no modernized baseline or offline decay is introduced.

## Save/load considerations

Preserve profile/version, duration/phase/next tick, completed initial/events and required partial-advance state. Reconstruct before gameplay resumes without executing initial application or replaying resolved ticks/randomness. Choose coherent save boundaries or support sufficient event/progress state; exact mid-advance save admission remains SAVE/TIME work.

Migration/old-profile continuation is described above and must integrate with locked executable/data configuration. Saved profile metadata alone is not executable code or proof its provider remains available. Native restore does not advance calendar/effects for loading duration. Source attribution, missing-provider and effect-specific state follow prior MAGIC/CORE-013 requirements. Classic/DFU save import remains outside scope.

## Technical constraints

Target Godot v4.7.2. Separate authoritative time units/event identity from frame delta and Unity broadcasts. Use sufficient safe precision for profile conversion and phase preservation. Document stable simultaneous-event order, bounded processing and outcome-equivalent bulk rules; no performance optimization may silently discard events. Exact scheduler architecture, queue structures, model API, migration schema and calendar coordination remain technical dependencies. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Default shared-minute rounds and N-round initial/tick/cleanup accounting match the specified examples without duplicate initial work.
2. Supported profiles can use eligible-gameplay seconds, relative/shared alignment, independent intervals and continuous lifetime; model replacement is more than a global interval slider.
3. Ordinary pause/loading/offline time creates no advancement/backlog; authorized explicit advances use declared conversion rather than wall waiting.
4. Full authorized elapsed time is accounted for without fixed-cap loss; batching retains unfinished work and bulk mode preserves equivalent outcomes.
5. Chronological events/new effects/expiry use documented deterministic ties and no retroactive ticks or duplicate family catch-up.
6. Death/applicable interruption stops at actual simulated time with preserved consequences and truthful elapsed/completion; calendar/owner state stays coherent.
7. Native profile/remaining duration/next-tick progress survives load without replay/reset, using migration-first handling and disclosed supported continuation where needed.
8. Unsupported conversion/provider scenarios offer safe configuration recovery without silent effect deletion or guessed conversion.
9. Old/new profile coexistence and merges are explicitly supported/validated within locked configuration.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved CORE-016, MAGIC-006 immediate application, MAGIC-004 cast-time separation, DATA-003 configuration lifetime and CORE-013 native-entry safeguards, plus recorded D01–D12. No direct contradiction identified. Explicit simulated advancement is the approved exception to ordinary suspension. Profile coexistence resolves before required readiness and does not unlock run-long configuration. Migration/continuation is preferred without promising unsafe unsupported loads. Initial payload is counted, not repeated; MAGIC-009 owns merge/removal details. TIME remains unreviewed and must implement cross-system truthful advancement rather than inherit DFU's clock-jump/catch-up loss. Architecture proposals remain recommendations beyond confirmed policy.

## Outstanding questions

No further blocking scheduling player-policy choice is identified. Before implementation is complete: TIME defines authoritative normal rate/precision and interruption-aware cross-system advancement; CORE defines bounded work/readiness; effect families inventory generic versus custom elapsed ownership; MAGIC-009 settles zero-duration/merge cleanup/cross-profile semantics; DATA/MOD define timing-model/profile APIs and provider support; SAVE/MAGIC-010 define migration, phase representation and coherent partial-operation saves. Exact tie ordering needs native fixtures. These deferrals cannot justify lost elapsed events, wall-time catch-up, duplicate ticks, silent save-effect removal or false full-interval completion.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-008-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented scheduler/TIME coordination, event ordering, effect-family elapsed ownership, profile/mod APIs, cross-profile merging and native migration/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
