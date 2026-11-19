# MOVE-017 — Movement feedback

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Communicate movement, surface and impact through consistent audio and optional comfortable camera motion. Presentation preferences, missing cues and stalls cannot change physical movement, damage, breathing or stealth outcomes.

## Confirmed requirements

MOVE-017-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. Rules below consolidate those choices. Approved MOVE camera/stair/landing/water/transport and CORE suspension contracts remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths are relative to reference `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/PlayerFootsteps.cs#FixedUpdate` selects clips from location, season/climate, path/static geometry and water context. Horizontal distance thresholds drive steps, with lower volume for slow movement and alternating clips. It suppresses loading/reposition artifacts and handles grounding transitions.
- `Game/Player/HeadBobber.cs#GetBobbingStyle` selects walking/running/crouching/horse/swimming patterns; position and rotation are applied separately from controller movement. Its update gates include pause, gameplay cursor, climbing and grounding. Exact branch reachability and perceived motion require runtime testing.
- `PlayerFootsteps.HardFallAlert`, `ApplyPlayerFallDamage` and splash handlers play event sounds. `TransportManager.Update` supplies separate mounted animation/audio paths.

Target presentation does not adopt exact source offsets, rotational bob or frame-dependent timing by implication.

## Detailed rules and behaviors

### Optional camera motion

Provide separate adjustable intensity controls, each including Off, for ordinary gait bob, mounted bob and landing camera feedback. Default gait/mounted bob is modest positional motion with no rotational bob or roll. Landing camera feedback defaults Off. Exact strengths remain tested tuning, not copied source constants.

Disabling camera effects leaves footsteps and important landing/water sounds available under audio preferences. Stair smoothing and necessary posture-height changes remain separate MOVE-007/006 functions, not disabled as incidental head bob.

Optional motion is geometry-safe and cannot alter authoritative aim, breathing, posture or collider. Compose it with posture and stair offsets without overwriting their authoritative baselines or adding harsh rhythmic stair bounce. Visual obstruction may shorten/suppress an offset. MOVE-003 aim consistency remains binding.

In gameplay cursor mode optional bob eases to neutral and remains suppressed, while actual-motion sounds continue. Do not pause movement or change facing to steady the cursor. Ordinary menus follow CORE suspension.

### Movement cadence and surfaces

Footsteps follow actual voluntary supported travel distance using configurable gait-specific stride lengths. Held input against a wall, passive platform carriage or external pushes alone cannot generate walking steps. Use resolved movement context rather than input magnitude alone. Swimming strokes and mounted audio use their own actual movement context; stationary swimming/hovering does not loop movement sounds merely because a mode is active. Ambient water remains AV scope.

Map validated surface/context identities to stone, ordinary outdoor ground, snow, shallow-water and swimming cues, supporting modded categories. Exact climate/material priority and asset inventory require AV/WORLD/DATA fixtures. Mapping a sound cannot change traction, damage or detection.

Retain fractional stride progress through ordinary eligible travel. Bound audible catch-up after stalls, skipping obsolete presentation cues rather than rapid sound backlogs. Exact playback budget and cosmetic phase transitions remain AV engineering decisions. This permission to omit old audio does not permit dropping authoritative fatigue/practice or NPC noise events.

### Event cues and gameplay separation

One resolved landing or water-entry outcome selects its appropriate cue, avoiding duplicate step/impact/splash sounds for the same event. MOVE-010 health resolution and MOVE-014 water transitions remain authoritative. Independent legitimate events can retain their own cues; exact priority/deduplication is an explicit AV contract, not silent gameplay suppression.

NPC hearing consumes authoritative gameplay noise separately from audible playback. Muting footsteps, turning bob off, missing a clip or skipping obsolete playback cannot improve stealth. Exact noise intensity, propagation and cadence remain NPC/LAW/COMBAT owners; this feature does not invent detection mechanics.

### Failure, pause and reconstruction

Optional movement sounds use declared fallback mappings or silence when explicitly permitted. Diagnose missing/invalid assets through existing systems without blocking movement or suppressing damage. Required media still follow DATA/AV owner recovery; optional silence is not a universal invalid-resource exemption.

Pause gameplay-linked feedback with simulation. Resume supported ongoing audio without replaying completed steps/impacts. Teleport/load resets camera offsets and distance baselines so relocation cannot generate a footstep burst or old-location bob. No paused-time catch-up. Recreated consumers receive effective preferences under CORE-006.

## Relevant formulas and parameters

Conceptually stride phase accumulates qualifying travel distance divided by the active valid stride length, retaining fractional remainder. Audible playback is bounded independently of authoritative accounting. Exact gait lengths, playback budget, camera amplitudes/timing and surface priorities remain validated tuning. All intensities support zero/Off. No health, practice, breath or noise-propagation formula is selected.

## Required data

Actual voluntary/support/mode context; qualifying distance and stride phase; gait/surface mapping; resolved event identity and playback status; independent camera preferences/offsets; optional/required cue policy and effective suspension/placement state. Representation and event IDs remain engineering dependencies.

## Inputs, outputs and events

Inputs: resolved movement/events, surface context, settings, cursor mode, lifecycle/suspension and relocation. Outputs: optional audio requests, bounded camera offsets, neutralization/reset and diagnostics. Presentation callbacks cannot authorize damage, practice, breathing changes or NPC hearing. API names remain unselected.

## Cross-system interactions

MOVE-003 aim/cursor, MOVE-004 actual voluntary/passive motion, MOVE-006 posture, MOVE-007 stairs, MOVE-010 landing, MOVE-014 water, MOVE-015 swimming and MOVE-016 transport supply authoritative context. AV/DATA own resources/playback, UI settings/accessibility, NPC authoritative noise, CHAR activity, CORE suspension/application and SAVE relocation boundaries. MOD supports validated mappings/strides/strengths without overriding unrelated gameplay through presentation.

## Edge cases and failure conditions

Test blocked walking, platform carriage, tiny analog motion, surface seams, gait changes and stair/posture composition. No cosmetic view offset may toggle submersion or redirect aim. Event deduplication cannot swallow health outcomes. A stall cannot produce a rapid audio burst; reset cannot interpret teleport distance as walking. Optional fallback must be declared, not silently introduced for required assets.

## Configuration and balancing options

Confirmed controls independently scale/disable gait bob, mounted bob and landing camera feedback. Validated mods may change mappings, stride lengths and camera strengths; exact schemas/domains remain owner work. Default motion is positional without rotational bob/roll and landing motion Off. No stealth advantage, extra landing penalty or traction effect follows from presentation settings.

## Save/load considerations

Feedback phase/offsets need not be character-save state. Load resets presentation/baselines without replayed completed cues, preserving authoritative movement/landing/water/noise history under their owners. Application preferences persist separately. Do not restore raw audio objects or old-session offsets.

## Technical constraints

Target: Godot 4.7.2. Separate authoritative outcomes from optional feedback; compose bounded presentation transforms without driving collider/facing. Use actual motion and frame-independent phase, with explicit reset/suspension. Concrete audio/camera nodes, interpolation and cue budgets require fixtures. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Separate Off-capable camera settings work with modest positional defaults, no rotational bob/roll and landing motion Off.
2. Disabled bob leaves eligible audio available and does not disable stair/posture functions.
3. Steps use actual voluntary supported distance; blocked input/passive carriage cannot trigger walking steps.
4. Swim/mount cues use actual context, not idle mode state; validated surface mappings support mod categories.
5. Camera offsets stay safe and cannot affect aim, breath, posture or collision; cursor mode neutralizes bob without stopping audio/movement.
6. Landing/water events avoid duplicate cues without suppressing authoritative health/context.
7. Fractional stride progress persists while audible stall catch-up is bounded; gameplay noise/activity remain independent.
8. Declared optional fallback/silence is diagnostic and cannot block movement or damage; required assets retain recovery rules.
9. Pause/restore/teleport cannot replay cues, generate bursts or retain old-location offsets; effective settings reapply correctly.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-003/004/006/007/010/014–016 and CORE pause/settings contracts. No direct contradiction identified. Cosmetic motion remains separate from authoritative aim/breathing; stair smoothing is preserved independently. Optional landing camera motion does not add a gameplay penalty. Audible cue dropping cannot drop NPC noise/accounting. Missing optional sound policy does not replace DATA required-asset recovery. Exact presentation tuning remains unresolved rather than inferred from source.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: amplitudes/strides, baseline composition and geometry safety, context/surface priority, event cue deduplication, audible budget, declared asset fallbacks, NPC noise contract and rendered/audio/relocation fixtures. These do not waive independent gameplay, user Off settings or safe interruption handling.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-017-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
