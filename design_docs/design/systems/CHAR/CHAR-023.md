# CHAR-023 — Lethal damage and death sequence

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Resolve prevention before committing player death, then present a short unskippable death sequence and hand off safely to the approved death-video/menu return.

## Intended player experience

An applicable prevention benefit can save the character with positive health. Otherwise death is definitive for that session: controls stop, the camera lowers and fades with audio, then the original death movie leads to the menu. Existing saves remain available and unchanged. The initial short sequence cannot be skipped; the following movie can.

## Confirmed requirements

CHAR-023-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish once-per-event prevention, minimum positive survival health, default presentation with nonblocking resource failure, authoritative death, deterministic source ordering/charges, unskippable initial sequence and blocked death-state saves.

CORE-008 already specifies original ANIM0012.VID once per death return, deliberate movie skip, failure bypass directly to menu without replacement death text, consumed skip input and no autosave/save deletion/automatic load. CORE-007 scopes dispatch/busy retry; CHAR-017 suppresses reconstruction replay; CHAR-018 supplies pool mutation/depletion and CHAR-022 routes lethal exhaustion through normal prevention.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/PlayerEntity.cs#SetHealth` handles god mode, normal clamp/restore assignment and lethal health. GuildManager.AvoidDeath can return survival at truncated MaxHealth×0.1; this can be zero for a small maximum. Intended minimum-one survival explicitly corrects that edge case.
- `Game/Guilds/GuildManager.cs#AvoidDeath` iterates memberships and stops on success. `Temple.AvoidDeath` tests Stendarr membership context, not submerged and Random.Range(0,50)<rank. Precise rank/benefit balance remains FACT-owned; incidental dictionary order is not approved priority policy.
- `Game/PlayerDeath.cs#PlayerEntity_OnDeath` guards repeat sequence and missing camera, pauses input, sets camera lowering, fades over default two seconds and plays default/race-gender death audio. Source default classic sound is WoodElfMalePain1; CombatVoices can select Pain3 by race/gender. Exact sound policy remains AV/identity-owner verification.
- PlayerDeath.Update requests TitleMenuFromDeath after default roughly three seconds and resets camera. Its camera dependency/timing coupling can block handoff when resources are absent; intended failure-safe coordination differs.
- ClearDeathAnimation clears fade, death flag, pause and camera. Intended cleanup releases only its own state under CORE, not arbitrary global pause.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Full lethal caller/camera/audio and prevention interactions remain runtime verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Lethal evaluation and prevention

Route lethal health mutations, including ordinary damage and CHAR-022 exhaustion requests, through one authoritative scoped lethal-event operation. Validate current session/character and determine prevention before publishing confirmed death. Block ordinary saving during unresolved evaluation so no half-resolved event becomes a normal save.

Resolve applicable owner-defined prevention sources in explicit deterministic priority order. Evaluate each at most once for the event; stop when a source succeeds. Only that source consumes a success-related charge; failed-attempt costs require an explicit owner rule. Invalid required source evaluation is an actionable resolution failure, not permission to reroll, silently skip it or invent success. Exact failure recovery is an owner/CORE contract and must keep state coherent.

Retain decisions/random outcomes and source-consumption receipts for duplicate delivery. Repeated callbacks for the same lethal event cannot retry failed chance rolls or consume multiple benefits. A later distinct lethal event after survival can evaluate again according to owner cooldown/charge rules; no new invulnerability window is introduced here.

Successful prevention sets health to max(1,floor(0.1×effective maximum health)) under the vanilla benefit policy and commits survival consistently with source cost. Respect CHAR-018's valid positive health maximum. Validated mod parameters may change supported restoration fraction/minimum within valid limits; no zero-health successful survival or silent out-of-domain health is allowed.

FACT/MAGIC/ITEM and other benefit owners define eligibility, rank chance, charges, cooldowns and scope. This feature does not approve the Stendarr formula as complete gameplay policy merely because it was inspected. It also does not automatically exempt drowning/exhaustion from owner-defined applicability.

### Confirmed death

If no prevention succeeds, commit death once and record originating session/event identity. Stop ordinary gameplay simulation/input; further stale damage/practice/reward callbacks cannot continue normal gameplay or duplicate death. Presentation and audio are observers of the committed outcome, never the authority deciding it.

Do not use a health-zero assignment during native reconstruction to replay a new lethal event under CHAR-017. Saved zero/dead-condition compatibility follows explicit SAVE/owner rules. God mode or developer recovery requires its own DEV contract rather than silently bypassing restore validation or reviving a confirmed-dead session.

Death cancels or gates active activities through their settlement contracts without automatically deleting pending obligations or mutating existing saves. CHAR-022 prevention that leaves fatigue zero remains unresolved exhaustion under that feature; successful prevention is not automatic fatigue recovery.

### Initial presentation

Default presentation lowers the camera, plays appropriate resolved death audio and fades the HUD over two seconds; request death return after roughly three seconds total from sequence start, not three extra seconds after the fade. Lowering trajectory/collision-safe pose and precise audio mappings remain AV/MOVE/UI engineering dependencies.

The initial short sequence is unskippable. Do not add a skip action that jumps directly into the movie/menu. Ordinary gameplay input remains disabled, and held input cannot be treated as an already-requested movie skip or menu action. The following movie's deliberate skip policy remains CORE-008, distinct from the initial sequence.

Missing camera, audio, fade resource or failed cosmetic animation cannot block authoritative death or safe return. Use an independent presentation timer/completion path that progresses while gameplay is suspended. Optional resource failure is not successful resurrection and does not generate a new mandatory death popup. Exact diagnostics follow CORE-002; failure-safe handoff must not depend solely on a camera Update callback.

### Handoff and cleanup

Submit originating dead-session return to CORE-007/008 after initial presentation. Respect busy rejection: retain intent and submit a fresh request after the competing operation finishes only if that same dead session still requires return. Do not preempt/queue through a hidden mutable start slot or affect a replacement character.

CORE-008 owns teardown, one original death movie, deliberate skip/failure bypass and usable menu readiness. Do not replay the initial sequence or movie on menu-load retry. Clear death-owned camera/fade/audio/input state with session teardown while preserving movie-owned presentation; cleanup cannot clear other owners' pause/readiness reasons.

No separate main-menu death notice, automatic save, automatic load or save deletion is introduced. Skipping the movie never resumes the dead world. Existing saves remain available through the normal menu.

## Relevant formulas and parameters

- Vanilla prevention survival health=max(1,floor(0.10×effective max health)).
- Default initial fade=2 seconds; pre-return presentation duration≈3 seconds total.
- At most one committed death and one initial presentation per originating death/session event.
- Deterministic prevention priority, once per applicable source/event, stop on success; no universal chance/charge formula selected.

Use safe arithmetic, supported nonnegative presentation durations and valid health restoration parameters. Clock/presentation scheduling must not depend on stopped gameplay-time advancement. Full movement/camera speed constants are source evidence, not a required Godot unit conversion.

## Configuration and balancing options

Validated mods may override supported prevention restoration parameters/priorities and presentation resources/durations. Benefit eligibility and costs remain owner-defined. Priorities require deterministic tie handling; unsupported ambiguous source order or invalid numeric parameters fail explicit validation.

DATA-003 configuration locking applies. Modifiable presentation does not introduce a vanilla initial-sequence skip control or override CORE-008 save/menu/video rules. New executable death alternatives, resurrection/respawn modes or save deletion require separate explicit owner approval/support.

## Required data

Lethal event/session identity and source context; pending/committed resolution; ordered applicable prevention definitions/outcomes/consumption receipts; effective health maximum/result; death/presentation phase and timing; originating return intent and completed handoff state. Concrete IDs/schema and transaction details remain engineering dependencies.

## Inputs, outputs and events

Inputs: valid lethal mutation, source eligibility/results, presentation progress/resource failures and coordinator return outcomes. Outputs: authoritative survival/confirmed-death/failure, once-only source consumption, initial presentation completion and scoped death-return request. Notifications occur after coherent state; exact APIs/signals remain deferred. UI/audio callbacks cannot apply death or consume benefits again.

## Cross-system interactions

CHAR-018 owns health mutations; CHAR-022 supplies lethal exhaustion; FACT/MAGIC/ITEM prevention owners resolve benefits; CHAR-011/017 source state and restoration remain authoritative. COMBAT supplies lethal context; AV/MOVE/UI render presentation; CORE-005/007/008/015 coordinate scope/return/lifecycle. DATA/MOD validate overrides; SAVE blocks ordinary saves during resolution/death and preserves existing files.

## Edge cases and failure conditions

- Small max health cannot yield zero-health successful prevention.
- Multiple lethal callbacks cannot multiply chance rolls, source charges or presentation; distinct later lethal events after valid survival remain separate.
- Dictionary/resource enumeration cannot decide prevention priority.
- Missing camera/audio/fade and frozen gameplay clock cannot trap a dead session.
- Initial-sequence input cannot skip it or leak as a movie/menu action; movie skipping remains deliberate and isolated.
- Death during an active reward/training/collapse cannot replay its settlement or bypass normal return ownership.
- Busy/stale return intent cannot end a newer character or replay a completed video on menu recovery.
- Ordinary saving is blocked both during unresolved lethal evaluation and after confirmed death; no dead-session overwrite/autosave occurs.

## Save/load considerations

Do not permit ordinary saves while resolving lethal state or after death is committed. Existing saves remain untouched; death return neither autosaves nor automatically reloads. Valid live-session saves after prevention follow normal owner state persistence, including consumed benefit charges/cooldowns, without replaying the prior event.

Developer diagnostics/recovery snapshots remain separate from normal gameplay saves and cannot imply save compatibility for a dead session. Restore validates saved condition/source state without re-triggering death/prevention chance as an assignment side effect. Exact crash/receipt persistence for supported operations remains SAVE/owner scope; no new ordinary death-state save path is authorized.

## Technical constraints

Target: Godot 4.7.2. Separate lethal resolution, prevention settlement, committed death, cosmetic presentation and application return. Use stable identity, deterministic priority and duplicate-safe source receipts; no reliance on UI/camera existence for outcome. Own suspension/cleanup locally and reject stale callbacks. Reference source/content remain read-only; APIs, schema and timer mechanism remain engineering choices.

## Acceptance criteria

1. Applicable prevention resolves once/source/event in explicit priority order, stopping on success with correct owner-declared charge settlement.
2. Vanilla successful survival restores positive max(1,floor(10% effective max health)); small maximums cannot remain zero.
3. Failed prevention commits one death, stops normal gameplay and rejects stale mutation/reward replay independently of presentation resources.
4. Initial camera/audio/fade sequence is unskippable, defaults to 2-second fade/~3-second total, and cannot be trapped by missing resources or paused simulation time.
5. CORE-008 receives one scoped return intent with correct busy/stale retry handling; retries cannot replay initial/movie presentation.
6. Movie skip/failure/menu/input cleanup follows approved CORE-008 without extra death notice or gameplay resumption.
7. Ordinary saves are blocked during unresolved lethal evaluation/confirmed death; existing saves remain untouched with no autosave/deletion/automatic reload.
8. Supported mod prevention/presentation parameters validate explicitly without implicit resurrection, ambiguous priority or zero-health success.
9. Native reconstruction does not reroll prevention or replay death; owner obligations/charges remain coherent.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-011/015/016/017/018/022, CORE-005/007/008/015 and DATA-003. No direct contradiction identified. Minimum-one survival explicitly corrects source rounding. Initial unskippable sequence follows the user's correction while retaining CORE-008 movie skipping. Positive-to-zero pool transitions and authoritative lethal resolution cooperate without UI-driven death. Confirmed-death save blocking preserves existing-save/menu policy; detailed prevention benefit balance remains FACT/MAGIC scope.

## Outstanding questions and approval

No further blocking lethal/death policy question is identified. Before implementation is complete: finalize benefit applicability/priority ties/charges and resolution-failure handling; verify sound/form mappings and camera trajectory; integrate activity termination, presentation clock/input gates and CORE busy return; define mod schemas/numeric limits and SAVE benefit receipts. Dependencies cannot waive once-only death, unskippable initial sequence, positive survival health or existing-save preservation.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-023-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented benefit/AV/input, mod-schema and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
