# MOVE-015 — Swimming control and buoyancy

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Provide deliberate horizontal/depth swimming with fine analog control and stable passive buoyancy. Character skill and Water Walking affect speed without land gait exploits. Water representation, breath and fatigue remain independently authoritative.

## Confirmed requirements

MOVE-015-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. Rules below consolidate those choices. MOVE-004/006/013/014 authority, shape, levitation and water contracts and CHAR-020 activity remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/LevitateMotor.cs#Update` collects horizontal and explicit vertical swim intent, with weight-induced sinking and a paralysis early return. `AddMovement` removes camera-derived vertical swim motion unless levitating and suppresses ascent near the surface.
- `Game/Player/PlayerSpeedChanger.cs#GetSwimSpeed` returns baseSpeed*(live Swimming/200+0.25). Source base selection can include posture/gait context; target explicitly chooses standing Walk instead.
- `LevitateMotor.AddMovement` uses ordinary motor speed with Water Walking. `Game/MagicAndEffects/Effects/Thaumaturgy/WaterWalking.cs` manages effect activation/resume/end integration; exact target effect costs/stacking remain MAGIC scope.
- Source height/swim flags and exterior/dungeon paths are distributed across `PlayerHeightChanger`, `PlayerMotor` and `PlayerEnterExit`. Target uses MOVE-014's declared representations and one motion authority.

Source weight-induced sinking is superseded by approved vanilla inventory-only encumbrance, not retained automatically.

## Detailed rules and behaviors

### Controls and representations

Use horizontal-facing-relative Forward/Backward/sideways input; camera pitch cannot change depth. Held Jump/Float Up ascends and Crouch/Float Down descends in depth-enabled water. Opposing vertical inputs cancel. These inputs neither execute an ordinary jump nor toggle posture.

Vertical controls are held actions independent of land Crouch Hold/Toggle preference. Require release/fresh press before entry-held Jump/Crouch becomes vertical intent; ordinary directional movement can continue. Cap the complete 3D input magnitude and retain proportional controller strength, preventing diagonal/up-forward speed bonuses.

Surface-only exterior water has no underwater descent under MOVE-014; depth-enabled water supports actual immersion. Surface upward input cannot launch the player into air. Exiting requires valid shore movement, climbing or levitation. Surface and shore collision validation cannot bridge unsupported gaps or clip through a bank.

### Speed and effects

Let W be resolved ordinary standing Walk speed and Q live Swimming. Vanilla ordinary swim baseline is `W*(Q/200+0.25)`. Run/Sneak requests cannot raise it. With valid Water Walking, replace the skill multiplier with full W, rather than multiplying both formulas. This gives a boost over ordinary vanilla skill-range swimming without a new walkable-water floor.

Apply explicit source-owned swim multipliers once to the selected baseline and enforce a validated moddable maximum on otherwise valid results. Changes to live skill, standing Walk inputs and authorized effects take effect next eligible physics step. Walk-derived versus swim-specific contributions must be distinguished so the same source cannot apply twice accidentally. Exact schemas/order for explicit formula replacements follow RULE-004.

Validate finite stat/formula/modifier domains and arithmetic; cap does not repair malformed definitions or authorize negative/backward speeds. Exact maximum and supported extended skills require testing. At extended Swimming above 150, the retained ordinary formula can exceed W; the approved Water Walking replacement remains W unless a validated override changes it. No guaranteed boost at every extended modded skill value is invented.

MAGIC owns Water Walking source stacking, duration/cost and alternate supported semantics. MOVE-014 permits explicit modded surface-support behavior; it is not vanilla. Spell expiry recomputes speed without granting jump, breath or fall immunity.

### Buoyancy, forces and shape

Neutral swimming holds current depth without voluntary drift or vanilla weight-induced sinking. Paralysis blocks voluntary controls but passive buoyancy remains; external pushes still resolve through collision. Buoyancy is explicit physical support, not whole-simulation suspension or breath/exhaustion immunity. Mods may add declared sinking/buoyancy/paralysis rules.

MOVE-004 coordinates all motion, separating voluntary and external forces. Exact external-force persistence and boundary behavior remain owner contracts; neutral input cannot erase required pushes or accumulate voluntary launch impulses against walls.

Use a dedicated validated swim shape and eye position, not ordinary crouch. Entry/exit shape changes obey MOVE-004/006 clearance. Preserve desired land posture; leaving cannot force standing through a ceiling. Exact dimensions, blocked shore enlargement handling and transition ordering require fixtures. Levitation takes movement authority according to MOVE-013 while actual submersion/breath context remains MOVE-014.

### Activity, pause and restoration

Report actual swimming/activity intervals under CHAR-020. Preserve its approved Swimming checks/practice, racial exemption and fatigue precedence; do not add per-stroke or per-frame rewards. Contextual Jump is not an ordinary jump event. Water Walking does not automatically remove swimming fatigue, grant water breathing or bypass CHAR exhaustion.

Pause preserves depth, water context and physical state without movement/breath/fatigue advancement or catch-up. Restore validated water representation, swim shape, desired land posture and required motion/effects after geometry readiness. Do not replay entry splash, practice, fatigue or magical activation costs. Missing required water/mod state invokes explicit recovery rather than silently substituting depth/shape.

## Relevant formulas and parameters

Ordinary v0=W*(Q/200+0.25); Water Walking v0=W. Resolve source-owned modifiers once and cap valid speed at configured maximum. Direction magnitude is capped to one while retaining submaximal analog strength. Parameters/formulas are moddable through validated contracts.

No exact maximum, swimming shape/eye dimensions, buoyancy numeric solver or waterline tolerance is selected. Water thresholds/fall protection remain MOVE-014/010; breath reserves remain CHAR-018. No vanilla weight-sinking threshold is introduced.

## Required data

Validated representation/water/support context; horizontal facing and contextual intent; fresh vertical-input eligibility; live Q and resolved W; Water Walking/levitation sources; swim contribution identity/cap; actual/desired shape/posture; voluntary/external motion; activity intervals and save/readiness state. Concrete schemas and force decomposition remain engineering work.

## Inputs, outputs and events

Inputs: eligible direction/vertical intent, water/shore geometry, stats/effects/restrictions, source changes and lifecycle/restore. Outputs: bounded swim intent/speed, collision-resolved movement, shape/mode handoff, ordered activity and checked failures. API names remain unselected. Input or speed changes alone cannot award practice or refill breath.

## Cross-system interactions

MOVE-001/002 own input/preferences, MOVE-003 facing, MOVE-004 authority, MOVE-005 W/encumbrance policy, MOVE-006 shape, MOVE-010 water fall history, MOVE-011 water exit, MOVE-013 levitation and MOVE-014 representation/submersion. CHAR-018/020/022 own breath/fatigue/practice/exhaustion; MAGIC effects; WORLD/LOC/DATA geometry; CORE/SAVE restoration and MOD/RULE validated extensions.

## Edge cases and failure conditions

Test combined depth/horizontal input, held crouch on entry, surface-only descent rejection, low-ceiling shore exits and effects expiring underwater. Paralysis cannot stop all collision response or create immunity. Missing required shape/data enters owner recovery, not tiny-collider fallback. Fast/extended valid speeds are bounded; invalid results cannot hide behind caps. Restoring sources/contributions cannot double speed or replay activity. Actual swimming classification, not Run held, controls activity context.

## Configuration and balancing options

Support validated swim formulas/modifiers/cap, Water Walking replacement rules, buoyancy/sinking and explicit paralysis interaction overrides. Vanilla retains neutral depth hold, no weight penalty, no Run/Sneak bonus and no camera-pitch depth control. Exact mod resource/cost/provider selection remains declared owner integration, not arbitrary callback stacking.

## Save/load considerations

Restore representation, posture, necessary motion/effects and owner breath/activity timing coherently after geometry readiness. Rebuild derived speed once from validated inputs, not persisted transient cache handles. No recreated swim motor may grant a new breath reserve or replay entry/practice. Exact save schema, external-force state and mod compatibility remain SAVE/owner contracts.

## Technical constraints

Target: Godot 4.7.2. Separate intent, speed, buoyancy, collision and water/breath state. One physics authority must handle surfaces, external pushes and mode exits. Verify scale/speed limits, shape queries and frame-independent activity using representative fixtures. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Horizontal facing controls swim direction; explicit held vertical inputs cancel when opposed and do not jump/toggle posture.
2. Entry-held Jump/Crouch needs release/fresh press; complete 3D normalization preserves proportional input without speed bonuses.
3. Ordinary and Water Walking baselines follow selected formulas without Run/Sneak scaling or duplicate contributions; live changes apply next eligible step.
4. Valid speed stacking is capped and malformed values follow recovery; extended skill behavior is explicit.
5. Neutral/paralyzed swimmers retain buoyancy and external collision response without breath/exhaustion immunity or vanilla weight sinking.
6. Surface ascent does not launch into air, and surface-only water cannot support underwater descent.
7. Swim shape/shore exits obey clearance and desired land posture; levitation handoff preserves actual water context.
8. CHAR activity is charged/reported once from actual context without contextual Jump awards or Water Walking fatigue immunity.
9. Pause/restore preserve required context without catch-up, replayed splash/cost/practice or silent missing-content fallback.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-004–006/010/011/013/014, CHAR-020 and relevant CORE restoration requirements. No direct contradiction identified. Dedicated swim shape resolves the earlier posture deferral, with clearance mandatory. Water Walking uses explicit swim-speed replacement, consistent with the user's correction. Vanilla no-weight-sinking preserves MOVE-005. Passive buoyancy during paralysis is explicit support, not paused physics. Extended skill may exceed Water Walking's replacement pace; no unsupported universal boost promise is added.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Dependencies: exact W/swim contribution schemas, extended domains/cap, swim shape/eye values, shore/mode handoffs, surface clamp, force persistence, MAGIC source resolution, mod override contracts and native/physics/activity fixtures. These do not waive proportional control, clearance or approved fatigue/breath ownership.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-015-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
