# MAGIC-023 — Magical traversal

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Authorize source-owned traversal/survival capabilities and resolve their power, overlap and expiry through approved movement authority without bypassing collision, hazards or native state.

## Intended player experience

Levitation, swimming-speed Water Walking, Water Breathing, Slow Fall and enhanced Jumping/Climbing have independent predictable benefits. Compatible recasts extend duration; duplicate flags do not multiply speed. Last-source expiry returns to real movement/hazard state. Water Breathing provides fresh ordinary breath when protection ends underwater by default; alternative reserve systems and movement profiles remain moddable.

## Confirmed requirements

MAGIC-023-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm source ownership, explicit levitation speed selection, Water Breathing refill/mod alternatives, capability independence, MOVE enhancement formulas, expiry and native state. D04 clarifies D03's refill timing and supersedes the rejected reserve-preserving recommendation. The complete specification is approved under MAGIC-023-A01.

Approved MOVE-004/009–015, CHAR-018/020 and MAGIC-008–010 remain authoritative for physical motion, activity, timing and reconstruction. This feature does not reopen those movement formulas or create collision immunity.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; native scale/mode/expiry fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/`.

- `MagicAndEffects/Effects/Thaumaturgy/Levitate.cs`, `WaterWalking.cs` and `Effects/Alteration/WaterBreathing.cs`, `Slowfall.cs`, `Jumping.cs`, `Climbing.cs` enable capabilities through startup/constant/resume and disable on End. Their compatible incumbent patterns extend duration; native source aggregation avoids direct one-source flag clearing.
- Levitation routes into player/enemy motors; Jumping/Climbing expose enhanced capability flags rather than a magnitude bonus in their inspected activation methods.
- `Entities/PlayerEntity.cs` skips ordinary submerged breath depletion while Water Breathing, setting ordinary counter to zero in the protected branch; after protection ends underwater it initializes fresh reserve. Target preserves that experience without requiring zero-sentinel representation.
- Approved MOVE reviews trace physical consumers including LevitateMotor, PlayerSpeedChanger, jumping/fall and water classification. Effect names alone do not define actual surface support or breath behavior.

## Detailed rules and behaviors

### Source ownership, admission and clocks

Track independent valid sources for each capability. Compatible recasts extend under explicit MAGIC-009 matching/lifetime policy; last valid contributor governs capability loss. Rebuilds/restore cannot add speed repeatedly, refresh duration or clear another contributor's protection. Source-bound equipment effects follow MAGIC-016 rather than lasting forever after item loss.

MAGIC-006 admission/accepted-only mutation and explicit source permissions apply. Ordinary duration uses MAGIC-008; validated alternative timing models supported. No per-frame chance rolls, movement grants or duplicate initial application from constant updates.

### Levitation and overlapping power

Default levitation uses approved MOVE-013 profile, including baseline 4 reference units per eligible second and normalized combined 3D intent, independent of ordinary gait. No implicit caster-level speed or duplicate-source multiplier. Validated profiles may declare speed/potency and selection/composition.

When multiple eligible sources specify speeds, default highest speed with stable source-order ties. Do not silently sum/multiply or let callback order choose. Suppressed contributions retain source timing under MAGIC-009. Explicit alternative profile mixing requires supported rules; physical motor remains MOVE-004's single authority.

Preserve approved MOVE-013 transitions: actual entry cancels prior voluntary/fall momentum and ends damaging segment once; active hover suppresses gravity, supports collision/external pushing and grants no blanket crush immunity. Paralysis stops voluntary controls while valid hover continues. Ending the last source selects valid ground/swim support; otherwise zero initial vertical falling speed with retained horizontal travel and a new unprotected fall segment unless another protection applies.

Expiry never restores old canceled momentum or leaves permanent unsupported hover. Levitation in water controls movement but actual submersion still determines breath. Exact NPC movement integration/geometry/force decomposition remains MOVE/NPC work, not automatic permission to attach player motors to all actors.

### Water Walking

Default Water Walking replaces the ordinary swim skill multiplier with full standing Walk speed under MOVE-015, not a new solid water floor. Apply capability once and explicit source-owned modifiers once. It grants neither breathing nor fall immunity. At extended modded skill values it is not guaranteed faster than every alternate swim formula.

Validated mod profiles may provide actual surface support under MOVE-014/015 contracts, with explicit collision/entry/exit/hazard rules. Name alone cannot bridge gaps, support a collider through geometry or change depth-enabled versus surface-only water. Effect expiry recomputes valid swim/movement state without new impulse.

### Water Breathing and breath reserve

Default valid Water Breathing protects ordinary breath for active lifetime and leaves full ordinary breath reserve when its last source ends underwater. This is explicitly approved restoration behavior, not the initially proposed reserve-preserving model. Keep current maximum/units under CHAR-018; no invented breath maximum or drowning formula.

The source counter-reset representation is not required. Native implementation may record reserve/protection/transition facts directly, but must grant the full reserve once on the genuine protected-to-unprotected underwater transition, not every rebuild/save/load. Overlapping sources ending individually do not repeatedly trigger last-source refill.

Support validated reserve-preserving, gradual-refill or custom models. Declare transition/recovery semantics and compatible native migration under MAGIC-008/010; no implicit refill from recreating actors or changing UI. Outside water, CHAR's normal reserve/activity rules remain authoritative.

Water Breathing does not grant swimming stamina, general underwater immunity, collision support or automatic revival. Other owner-approved breath benefits/exhaustion remain separate.

### Slow Fall, enhanced Jumping and Climbing

Slow Fall follows approved MOVE-009/010 motion/protection: active protection cancels accumulated damaging-fall distance, protected descent adds none, and expiry midair begins a fresh unprotected segment at actual position. It does not replay canceled distance. Exact approved motion parameters remain MOVE-owned, not a guessed MAGIC formula.

Default enhanced Jumping/Climbing are capabilities consumed by approved MOVE formulas: enhanced jump contribution E=0.6 in takeoff formula, enhanced climbing doubles the approved standing-Walk/3 baseline. Do not add strength from caster level or multiply repeated flags. Explicit stronger/custom modifiers are moddable with source resolution.

Preserve MOVE's snapshot/physics distinctions: ordinary jump captures takeoff inputs, later enhancement expiry does not recalculate that impulse. Climbing uses current eligibility/speed/check rules through MOVE, not magic-driven collider teleport. Slow Fall's ordinary-jump restriction remains explicitly moddable under approved MOVE-009; this feature does not remove it silently.

### Capability independence and expiry

Levitation, Water Walking, Water Breathing and fall/enhancement capabilities remain independent. Combined spells/mod profiles may supply several explicitly. Removing one does not clear another source or imply another capability.

Last-source loss selects actual valid MOVE state immediately without free grace, teleport to safe ground or automatically casting replacement. Water Breathing's full-reserve transition is the stated default exception for breath, not general hazard immunity. Expiry underwater/midair can expose hazards under existing movement/CHAR rules.

Coherently publish capability changes before next eligible physics/action evaluation; no two competing motors or lost support due to intermediate flag clears. Collision/shape clearance, transport and simultaneous mode precedence follow approved MOVE contracts. Unsupported overlaps require explicit handling, not walking fallback through geometry.

## Relevant formulas and parameters

Default levitation speed MOVE-013=4 reference units/eligible second; overlapping source default max eligible speed. Water Walking MOVE-015=W standing Walk rather than W×(Swimming/200+0.25). Enhanced jump uses MOVE-009 E=0.6 at takeoff; enhanced climb speed=2×(W/3). Units/native scale fixture required. No new magical stamina rate, grace duration, breath maximum or drowning magnitude introduced.

## Required data

Stable source/effect/actor/contribution IDs; capability/profile/speed/combination; timing/lifetime/suppression; actual MOVE mode/posture/velocity/fall segment; water/submersion/support context; breath profile/reserve/max and committed last-source transition; explicit source dependencies and required restore references. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: accepted effect/source activation/removal/expiry, current movement/environment/restriction, profile clocks and native restore. Outputs: resolved capabilities/power, coherent movement handoff, genuine breath transition or explicit failure/recovery and optional warnings. APIs/signals unselected. Casting request alone cannot reset fall or grant support before actual authorized transition.

## Cross-system interactions

MOVE-004 owns motion/mode authority; MOVE-009/010 jump/fall, MOVE-011 climbing, MOVE-013 levitation, MOVE-014/015 water/swim. CHAR-018/020 own breath/resources/activity, MAGIC-006/008/009/010 admission/timing/stacking/restore and MAGIC-022 restriction coexistence. ITEM/MAGIC-016 source-bound contributions; DATA/MOD validated profiles; SAVE/CORE-013 world/reference readiness and UI/AV warnings.

## Edge cases and failure conditions

- Two levitation sources: max eligible speed, one expiry recomputes survivor without fall/reset; last expiry uses valid support/fall.
- Paralyzed levitator: hover persists with active source, no voluntary flight; expiry resumes actual physics.
- Water Walking active underwater: speed benefit only, no breathing/surface floor by name.
- Water Breathing sources overlap: only last genuine end underwater grants full reserve; restore/rebuild not new refill.
- Enhanced Jumping expires mid-jump: captured impulse retained; Slow Fall independently affects protection under MOVE.
- Climbing enhancement ends: current MOVE rules resolve speed/validity, not arbitrary teleport or fresh grab.
- Mod surface-support/real-time profiles: complete explicit integration, no hidden mode/clock substitution.
- Native geometry/source missing: safe recovery, no invented permanent hover or arbitrary safe relocation.

## Configuration and balancing options

Validated levitation power/composition, movement modifiers, Water Walking alternate surface support, Water Breathing reserve models, durations/real-time clocks and source policies are moddable. Existing MOVE speed/shape/activity contracts remain until explicit supported alternatives adopted. No universal stacking multiplier, levitation water immunity or source-name-derived behavior. Exact APIs/selector precedence/safe limits remain owner work.

## Save/load considerations

Preserve contributions, lifetime/profile/power and actual movement/hazard state, including fall history and breath transition facts. Restore through geometry/reference/movement readiness without new impulses, fall resets, extra Water Breathing refill or effect activation. Legitimately pending supported transition must resume once rather than be discarded/replayed; exact coherent boundary SAVE-owned.

MAGIC-008 migration/old-profile continuation and MAGIC-010 source compatibility apply. Missing required actor/support/effect state follows CORE-013 recovery, not unrelated relocation. UI expiry warnings derive truthful state, cannot extend lifetime or alter hazards. Classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. MAGIC resolves source capability/power; MOVE authoritatively moves/validates collision. Distinguish actual transition from requested cast and native reconstruction from fresh entry. Safe timing/units and stable source/transition identity required; exact motor adapters/breath semantics/save formats remain implementation work. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Capabilities source-owned/compatible extension; one source removal cannot erase survivor or duplicate speed/timing grants.
2. Levitation approved baseline/max-source selection and entry/expiry/paralysis/water behavior hold with explicit mod alternatives.
3. Default Water Walking is swim-speed replacement, distinct from breathing and explicit mod surface support.
4. Water Breathing lifetime protection and genuine last-source-end full reserve work once; alternative models explicit, no load/rebuild refill.
5. Slow Fall and enhanced jump/climb preserve approved MOVE formulas/fall/takeoff rules without caster-level/duplicate-flag strength.
6. Last expiry resolves real mode/hazard immediately, no grace/teleport/auto-spell; other protections remain.
7. Native movement/source/timing/breath/fall restoration and warnings produce no new entry effects, impulses or erased hazards.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MOVE-004/009–015, CHAR-018/020, MAGIC-008–010/022 and recorded MAGIC-023-D01–D09. No direct contradiction identified. Water Breathing full-reserve transition is explicit approved exception to ordinary no-refill policy; restore is not fresh transition. Levitation gravity suppression during paralysis remains approved specialized support, distinct from general restriction physics. Water Walking remains swim replacement, Slow Fall fall-history and jump takeoff capture preserved. Source timing/potency alternative profiles require validation rather than undocumented callback changes.

## Outstanding questions

No further blocking traversal-effect player-policy choice is identified. Before implementation is complete: inventory family matching/eligibility/duration and NPC capability adapters; fixture native scale/overlap/forced motion/shape transitions; define speed-profile selectors, breath last-source receipt/migration and mod surface support; integrate coherent physical/hazard snapshots and UI warnings. These deferrals cannot authorize duplicate speed, refill-on-load, collision bypass, stale fall reset or unsupported permanent hover.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: MAGIC-023-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented capability/NPC adapters, movement-transition fixtures, speed/breath profiles and native recovery/persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
