# MOVE-014 — Water entry and submersion

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

## Gameplay purpose and intended player experience

Determine water contact, swimming and breathing context reliably. Preserve vanilla exterior surface swimming while supporting genuine exterior depth through mods. Boats, floors, cosmetic motion and loading cannot fabricate immersion or breath resets.

## Confirmed requirements

MOVE-014-D01–D10 in [the decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, including the user's corrections about Water Walking and exterior water. Those corrections supersede proposed walkable-water support and any assumption that vanilla exterior water needs actual depth. D08 explicitly amends MOVE-010's depth-only protection rule.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/PlayerEnterExit.cs#Update` gates underwater processing on active gameplay. Dungeon swim/submersion use separate height comparisons against block water level; 10000 denotes absent water. Entry may send a splash message. A weight-based cannot-float warning is also present.
- `Game/PlayerMotor.cs#GetOnExteriorWaterMethod` uses exterior terrain proximity/tile context, distinguishing Swimming/WaterWalking. Supporting checks intend to exclude boats and levitating above water.
- `Game/LevitateMotor.cs#AddMovement` uses ordinary motor speed while swimming with Water Walking. `Game/Entities/PlayerEntity.cs` consumes submersion/Water Breathing context for breath processing.

These observations do not verify complete original depth coverage or approve source offsets, sinking or effect semantics wholesale.

## Detailed rules and behaviors

### Representations and physical states

Definitions explicitly declare surface-only or depth-enabled water. Vanilla exterior water may remain surface swimming without modeled underwater depth. Depth-enabled water permits actual descent/submersion in dungeons or exteriors. Mods can supply exterior depth through validated geometry/definitions without dungeon-only movement logic.

Use validated water extent/context and intervening solid geometry, not tile identity alone. Floors, bridges and boats above water cannot cause swimming. WORLD/LOC/DATA own original-data conversion and actual geometry.

Distinguish body-water contact, swimming support and submerged breathing point. Solid footing permits wading below swimming-entry depth. In depth-enabled water, crouching can submerge the breathing point while still wading. Surface swimming need not mean holding breath. Surface-only water permits no underwater descent or submersion caused by crouch/camera bob; it cannot pretend to be a navigable deep volume.

### Stable classification

Use small configurable entry/exit tolerances to prevent rapid surface switching. Physical breathing-point classification reflects actual posture, excluding cosmetic bob and camera interpolation. Exact thresholds/margins and sampling order require fixtures; tolerance cannot silently grant prolonged underwater breathing or reset reserve.

Levitation may control movement while actual depth-enabled submersion still governs breath/underwater effects. Swimming-motor activity is not the same as submerged breathing state. Commit context through MOVE-004 authority rather than independent collider movement.

### Fall protection

Depth-enabled water grants MOVE-010 protection only on actual validated swimming entry with enough unobstructed receiving depth. Surface contact followed by shallow-bottom/obstacle impact cannot erase a fall. Exact receiving-depth and collision-order criteria remain shared physics dependencies.

Explicit approved exception: designated surface-only exterior swimming entry is a safe water landing despite abstract depth. Floors, boats and intervening obstacles take precedence. This amendment is recorded in MOVE-010; it cannot become general immunity for water tiles, puddles or shallow depth-enabled volumes.

Valid protective entry ends the damaging segment once. Definition crossings, presentation callbacks and tolerance oscillation are not new protection events.

### Effects, movement and breath ownership

Vanilla Water Walking boosts swimming speed rather than creating a Morrowind-style walkable surface. MAGIC/MOVE-015 own exact speed, costs, duration and source stacking. Support modded alternate behavior, including surface support, through explicit validated contracts. Effect name alone cannot grant fall protection or water breathing.

MOVE-015 owns swimming controls/speed; CHAR-018 owns reserve/recovery and their approved modded alternatives. This feature supplies actual breathable/submerged context without inventing depletion cadence, drowning damage or a reserve formula. Racial/effect benefits retain their approved owners.

Vanilla encumbrance remains inventory-admission-only under MOVE-005. Source weight-based warning/sinking is not implicitly retained. Optional mod sinking/restrictions require declared water/movement integration.

### Presentation, pause and reconstruction

Splashes/underwater presentation follow committed physical changes once. Loading, adjacent definitions or tolerance oscillation cannot replay splashes or refill breath. Optional presentation failure cannot suppress authoritative context.

Ordinary pause suspends physical progression/breath activity time under CORE/CHAR rules without catch-up. Loading establishes water geometry, actual pose and effects before releasing gameplay. Reconstructed context is not a new entry grant; retain CHAR-018 instant/gradual recovery distinctions rather than refilling reserves because a consumer was recreated.

## Relevant formulas and parameters

Classification uses actual body/footing/breathing-point positions against declared surface/volume geometry and entry/exit tolerances. No numeric depth thresholds, source coordinate offsets, sentinel or margins are selected for Godot. Surface-only exterior protection is explicit policy, not a fabricated depth calculation. No swim multiplier, breath rate or drowning formula is selected.

## Required data

Stable water/representation identity, extent/surface/bottom/obstructions, actual posture/breathing point, valid footing, contact/swim/submersion and tolerance context, effect/mode authority and entry-completion identity. Schemas and sampling order remain engineering dependencies.

## Inputs, outputs and events

Inputs: pose/support, water definitions/geometry, posture/effect changes and lifecycle/restore. Outputs: committed contact/swim eligibility, breathable/submerged context, checked protective entry and independent presentation requests. API names remain unselected. Tiles/camera bob alone cannot authorize protection or breath refill.

## Cross-system interactions

WORLD/LOC/DATA own representations/geometry. MOVE-004 owns mode authority, MOVE-006 posture, MOVE-010 protection, MOVE-011 water-exit climbing, MOVE-013 levitation and MOVE-015 swim motion. MAGIC owns Water Walking/Breathing; CHAR-018/020 own reserves/activity and CHAR owns exhaustion/death. CORE/SAVE gate restoration; AV/UI handle presentation; MOD supplies validated alternate content/effects.

## Edge cases and failure conditions

Test boats/floors above water, crouched wading, shallow bottoms, deep drops, shorelines and adjacent representations. Surface-only water cannot fabricate underwater space. Levitation cannot hide actual depth-enabled submersion. Fast falls require checked solid/water ordering. Missing required data uses explicit owner recovery, not invented depth, silent surface-only substitution or blanket immunity. Overlap/priority between definitions must be established before implementation is complete.

## Configuration and balancing options

Support validated representations, physical thresholds/tolerances, modded exterior depth and alternate Water Walking/sinking rules. Vanilla retains surface-only exterior swimming, speed-boost Water Walking and no encumbrance movement penalty. Exact hook/provider resolution, balance values and live geometry lifecycle are not approved implicitly.

## Save/load considerations

Restore pose, definitions and breath/effect owner state before deriving water context. Preserve sufficient validated transition state to avoid false entries without saving raw references or replaying presentation. Representation migration and optional mod depth require DATA/SAVE compatibility; missing required content invokes recovery rather than silently changing water type/refilling breath.

## Technical constraints

Target: Godot 4.7.2. Separate representation, physical observation, movement, breathing and presentation. Engine overlap flags alone cannot prove adequate receiving depth or boat exclusion. Concrete queries/volumes, metadata, margins and ordering require fixtures. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Contact, swimming and submerged breath context remain separate; depth-enabled crouched wading can require breath while surface swimming may not.
2. Dungeons/exteriors use validated context; above-water boats/floors cannot induce swimming.
3. Vanilla surface-only exterior water supports surface swimming; modded depth-enabled exterior water permits genuine submersion.
4. Posture affects physical breathing classification; cosmetic/tolerance motion cannot cycle breath or entry feedback.
5. Depth-enabled protection requires actual adequately deep unobstructed entry; surface-only exterior protection follows the explicit exception with solid-obstacle precedence.
6. Water Walking defaults to swim-speed boost context, with no automatic surface support, breathing or protection; mod alternatives have explicit contracts.
7. Levitation does not hide actual submersion; no unapproved vanilla weight-induced sinking appears.
8. Loading/seams cannot replay splashes or reset breath. Missing required content uses compatibility recovery without fabricated context.

These are future verification criteria; no implementation/runtime tests have been performed.

## Consistency review

Reviewed against MOVE-005/010/011/013, CHAR-018 and CORE pause/restoration requirements. D08 explicitly qualifies MOVE-010's depth-only rule, including its acceptance criterion 5. User corrections establish vanilla exterior abstraction and speed-boost Water Walking while retaining mod depth capability. Actual-posture submersion applies to depth-enabled water; surface-only is an explicit qualification. No independent proof of all original terrain cases is claimed.

## Outstanding questions and approval

No further blocking player-policy choice is identified. Required dependencies: original-data mapping, extent/bottom/shore thresholds, representation overlap/priority, depth/solid ordering, water/effect mod schemas, Water Walking speed via MAGIC/MOVE-015, breath timing and native context/migration fixtures. These do not waive solid precedence, declared representations or no artificial breath resets.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-014-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented geometry, tuning and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
