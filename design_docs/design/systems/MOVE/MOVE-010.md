# MOVE-010 — Landing and fall damage

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-07: “I approve”.
Updated: 2026-11-07.

Approved amendment — 2026-11-07, MOVE-014-D08: valid entry into designated surface-only exterior swimming water is a safe water landing despite abstract depth. Floors, boats and intervening obstacles take precedence. This narrow exception qualifies depth-only wording below, including acceptance criterion 5; depth-enabled water retains sufficient-depth validation. The user explicitly approved this amendment during MOVE-014's third interview; the complete MOVE-014 specification is now approved — finalized v1 under MOVE-014-A01 (2026-11-07). See [MOVE-014](MOVE-014.md).

## Gameplay purpose and intended player experience

Make unprotected falls consequential through predictable distance-based damage, while successful protective traversal/effects provide genuine recovery. Landings resolve once, independently of audio, and cannot be erased through pausing, resizing or native restoration.

## Confirmed requirements

MOVE-010-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record three interviews, each confirmed with three “Yes” answers. The rules below consolidate those choices. MOVE-001–009, CHAR health/activity and CORE suspension/restoration contracts remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Source paths below are relative to the reference directory's `Assets/Scripts/`. Static inspection only; source unchanged.

- `Game/Player/AcrobatMotor.cs#CheckInitFall` records fall-start transform height when entering falling state. `CheckFallingDamage` computes start minus landing height, emits damage alert above threshold 5 or hard-fall alert above half that threshold, and excludes an outdoor-water tile path. This is not explicit jump-apex tracking.
- `ApplyGravity` updates fall-start height continuously under Slow Fall. `AdjustFallStart` compensates vertical origin shifts; `ClearFallingDamage` clears falling state and resets reference height.
- `FallingDamageAlert`/`BadFallDetected` send optional string messages. `Game/PlayerHealth.cs#ApplyPlayerFallDamage` calculates integer damage using a separate constant threshold 5 and 5 HP per excess unit, then calls health mutation/flash handling.
- `Game/PlayerFootsteps.cs#ApplyPlayerFallDamage` and `HardFallAlert` play sounds only. Damage is therefore not implemented solely by the footsteps receiver; missing audio and missing gameplay receivers are distinct integration concerns.

Target behavior uses one authoritative landing result and explicit protection/support transitions, rather than adopting source message wiring or broad water-tile immunity.

## Detailed rules and behaviors

### Fall segments and measurement

Track an unprotected airborne segment after actual loss of support or release from a protective state. Measure the downward drop from the highest actual foot/base position reached during that segment, including a jump apex. Use consistent world-space height or equivalent origin-compensated representation; floating-origin changes and collider resizing cannot alter measured distance.

At actual landing let d be max(0, highest segment foot height minus landing foot height), converted into the approved reference distance scale. Do not use accumulated path length, camera height, takeoff-only height or terminal speed as substitutes. Actual world motion can update the apex; transform rebasing or presentation smoothing cannot.

Ordinary platform carriage is support, not an airborne fall. Small supported step corrections remain MOVE-007 surface motion, not repeated tiny falls. Actual support loss/recovery defines airborne/landing boundaries under MOVE-004/009. Exact contact stability and step-versus-drop classification require shared physics fixtures.

### Damage and feedback

Vanilla damage is `trunc(max(0, 5 × (d − 5)))` health, with 5 reference units safe threshold and 5 HP per excess unit. Both parameters/formula are moddable through validated contracts. Verify reference distances against chosen Godot world scale.

Above 2.5 reference units, a landing is eligible for hard-landing feedback independently of whether rounded damage is positive. Boundary comparisons are strict: at 2.5 the hard threshold is not crossed; at 5 damage is zero. A small excess above 5 can still truncate to zero. No automatic minimum-one damage is selected.

One authoritative landing outcome records distance, protection and resolved damage/feedback eligibility. Health and presentation consume that resolved outcome independently: missing/muted audio cannot suppress health loss, and repeated contact or listener callbacks cannot apply it twice. Exact hard-versus-damage sound selection remains AV integration; do not require two overlapping sounds for one landing.

Health loss uses CHAR's authoritative health/death contract, including zero-damage handling and once-only lethal transition. No automatic armor, live Jumping skill or attribute reduction applies in vanilla beyond explicitly approved protections. This feature introduces no additional landing stamina charge, movement lock, injury or forced crouch.

Sound and optional visual feedback respect camera/accessibility preferences. They cannot change collider state or aim. Optional presentation failure cannot invalidate an already committed health consequence or cause damage replay.

### Protection transitions

Active Slow Fall cancels accumulated damaging-fall distance. While protected, descent adds no damaging distance and landing causes no fall damage. If the effect expires in midair, start a new unprotected segment at that actual position. MAGIC/MOVE-009 own descent motion, eligibility and frame-independent start/end handoff; this specification does not choose Slow Fall speed.

Actual entry into validated swimmable water sufficiently deep to receive the player ends the damaging segment. Water merely beneath a floor/boat or shallow/obstructed water does not protect: resolve the actual contacted landing surface. Depth, water-volume identity, simultaneous bottom contact and swimming-entry validation require MOVE-014/WORLD/LOC contracts. No universal water-tile bypass remains.

A successful supported climb/rappel grab or active levitation actually taking movement control ends the current damaging segment. A failed grab, input request or cast attempt alone does not. Losing protective support/control starts a new unprotected segment at release unless another valid protection remains. Resolve overlapping protections coherently; removing one cannot end another's active protection or manufacture a landing.

Protection changes cannot replay prior resolved damage or count as new jump practice. Supported climb, water and levitation mode eligibility remains their features' responsibility; this contract specifies fall-history consequences of actual successful transitions.

### Moving platforms and modded impact rules

Vanilla uses world-space drop distance for moving-platform landings, without extra relative-impact-speed damage. A rising/falling platform's actual landing height affects d, but speed alone is not a second damage formula. MOVE-008 compression remains separate from falling and cannot be inferred merely from a landing.

Support optional modded relative-impact rules and explicit thresholds/formulas/protections through declared validated hooks. They require defined velocity/contact inputs, source/provider selection and activity/save semantics. No arbitrary callback stacking, default armor mitigation or blanket material immunity is implied. RULE-004 failure/provenance and DATA configuration rules remain binding.

### Pause, placement and native restoration

Pause preserves unresolved fall history, actual motion and protection state under CORE/MOVE contracts; paused duration adds no fall movement. Crouch resizing, camera smoothing, menu entry and origin shifts cannot reset the segment or grant immunity. MOVE-009's downward-speed cap does not erase history.

Native save/load retains unresolved segment/apex information, relevant protection and landing-resolution state with actual flight. Restore after geometry readiness without replaying damage, feedback, jump impulse or activity. Already resolved landing consequences remain resolved. Exact safe save boundaries/outcome representation must prevent duplicate application without promising generic transaction rollback.

Explicit teleport/placement establishes history through its owner contract rather than interpreting placement displacement as a physical fall. No global clear-fall call is authorized for arbitrary interruptions; correction bounds and mode validity remain MOVE-026/027/SAVE dependencies.

## Relevant formulas and parameters

`d = max(0, H_peak − H_landing)` in reference-scale units for an unprotected segment.

`damage = trunc(max(0, r × (d − T)))`, vanilla T=5 and r=5 HP/unit; hard-feedback eligibility d>2.5. Protected transitions terminate/reset the damaging segment as defined above.

Validate finite distances, thresholds/rates and supported output domains before applying effects. Invalid configuration/overflow follows approved recovery, not wraparound, silent formula substitution or manufactured immunity. Exact unit conversion, maximum supported domains and optional mod relative-impact formula remain engineering/owner dependencies.

## Required data

Fall segment identity/status, actual foot/base world height and peak, support/mode observations, origin compensation, active protection reasons and transition boundaries, landing height/surface, validated formula parameters, resolved damage/feedback and once-only completion state. Mod impact rules may require relative contact velocity under their declared schema. Raw collider/audio references are not durable identity.

## Inputs, outputs and events

Inputs: support loss/landing, actual motion/apex updates, protection entry/exit, origin shifts, placement, suspension and native restoration. Outputs: authoritative resolved landing, checked health consequence, independent optional feedback and retained/ended fall segment. API/event names remain unselected. Probes and presentation notifications cannot independently authorize another damage application.

## Cross-system interactions

MOVE-004 owns motion/history arbitration; MOVE-006 base-preserving posture; MOVE-007 supported steps; MOVE-008 platforms/crushes; MOVE-009 jump/velocity; MOVE-011–015 climb/rappel/water/levitation; MOVE-026/027 placement. CHAR-018/023 own health/damage/death integration; CHAR-020 activity cannot duplicate from landings. MAGIC owns protective effects, WORLD/LOC water/geometry, AV/UI feedback and accessibility, CORE gates suspension/death/readiness, SAVE native consistency and MOD/RULE/DATA validated extensions.

## Edge cases and failure conditions

High jumps include apex drop even when takeoff and landing heights match. Airborne crouch cannot reduce distance by shifting collider center. Origin rebasing cannot create damage. Threshold and fractional rounding fixtures must distinguish hard feedback from actual HP loss.

Water beneath a boat/floor cannot suppress a solid landing. Valid water entry versus simultaneous bottom contact requires explicit depth validation. A failed grab cannot reset the apex; successful supported recovery can. Protection expiry begins a new segment without restoring pre-protection debt.

Moving platforms require actual loss/recovery of support; carriage cannot become a perpetual fall. Repeated contacts, save restoration or audio retry cannot duplicate damage. Required health/formula failure enters owner recovery instead of assuming immunity or rerunning partially applied work. Compression and fall outcomes require independent cause identities to avoid confusing separate hazards with duplicate fall damage.

## Configuration and balancing options

Thresholds, damage formula/rate, protections and optional relative-impact rules support declared validated mod contracts. Vanilla retains selected distance formula, no automatic armor/skill/attribute mitigation and no additional landing debuff. Feedback settings cannot disable authoritative damage. Exact hooks/provider semantics and effect combinations remain required integration work.

## Save/load considerations

Version unresolved segment/peak, actual flight/protection and committed outcome state sufficiently to resume without erased distance or replayed landing. Restore owner effects once, establish geometry/context and distinguish restored support from a newly occurring landing. SAVE must choose valid commit/save boundaries and safe interrupted-operation recovery. Do not persist presentation history as gameplay authority or reroll/reapply completed health consequences.

## Technical constraints

Target: Godot 4.7.2. Separate authoritative fall/health resolution from optional audiovisual consumers; no string-message receiver absence may suppress required gameplay. Use foot-based origin-invariant measurements and explicit support/protection lifetimes. Concrete event IDs, numeric precision, health API, save transaction boundaries and probes remain implementation choices to verify. No implementation/coding tasks are authorized.

## Acceptance criteria

1. Unprotected landings use peak actual foot height, including jump apex, and the approved distance/rate/truncation baseline.
2. Exact 2.5/5 boundaries and small positive excesses behave as specified; feedback eligibility does not imply nonzero damage.
3. One landing applies health consequences once regardless of duplicate contacts, muted/missing audio or optional feedback failure.
4. Slow Fall clears accumulated damaging distance; protected landing is harmless and midair expiry starts fresh at expiry position.
5. Only actual sufficiently deep valid swimming entry protects; water below floors/boats/shallow obstruction cannot create blanket immunity.
6. Successful supported climb/rappel/active levitation ends the segment; failed requests do not. Loss starts fresh unless another protection remains.
7. Moving-platform landings use world-space drop without vanilla relative-impact damage; ordinary carriage is not falling.
8. Vanilla adds no armor/skill/attribute mitigation or movement/stamina/injury/crouch penalty beyond approved health/protections.
9. Posture/origin/camera changes and pause cannot alter physical fall distance or accumulate paused movement.
10. Native restoration preserves unresolved history and cannot replay resolved landing damage/feedback; placement does not fabricate a physical fall.
11. Validated mod formulas/protections/impact rules preserve authoritative once-only resolution and explicit failure handling.

These are future verification criteria; no runtime tests or implementation have been performed.

## Consistency review

Reviewed against MOVE-001–009, CHAR health/activity ownership, relevant CORE suspension/restoration contracts, MOVE catalog/architecture and nine interview decisions. No direct contradiction identified. Apex-based distance intentionally differs from takeoff-only source tracking; no prior jump approval promised damage-free high jumps. Slow Fall/climb/water/levitation reset rules resolve earlier fall-history deferrals without granting failed-attempt protection. Terminal speed remains independent of distance-based damage. Moving-platform inheritance affects flight, not a new impact formula. Health and audio remain distinct required/optional consequences with no replay.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Before implementation is complete resolve reference-scale conversion/numeric domains, contact/landing stability, deep-water criteria, specialized protection eligibility and overlapping handoffs, teleport history policy, health/outcome commit boundaries, native schema, mod hook inputs/selection and boundary/platform/water/save fixtures. These deferrals do not waive peak tracking, actual-entry protection or once-only health consequences.

The user explicitly approved the complete Draft v1 on 2026-11-07 with “I approve”. This specification is finalized v1 under MOVE-010-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented tuning, engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
