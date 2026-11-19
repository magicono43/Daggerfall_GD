# COMBAT-005 — Player reach and collision

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Select reachable melee contacts predictably, including default multi-enemy cleaving, without striking through solid barriers or accidentally activating doors/mechanisms during combat. Allow very close targets and narrow openings. Preserve deliberate civilian/environment strikes and support richer weapon/direction profiles through mods.

## Confirmed requirements

COMBAT-005-D01–D20 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record six interviews. Requirements include commitment-time aim, forward-volume cleave, per-target obstruction, nearest-first order, no default gameplay cap, enemy-first dispatch and optional modded wall-stop sweeps. The complete specification is approved under COMBAT-005-A01. Approved COMBAT-001–004 costs, practice, source identity, interruption and input ownership remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths are relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#MeleeDamage` spherecasts from mainCamera position/forward with weapon.Reach and SphereCastRadius. defaultWeaponReach is 2.25 and SphereCastRadius is 0.25. The mask excludes the Player layer.
- The inspected method selects one contact, tries WeaponEnvDamage, and conditionally raycasts for narrow cages after handled environmental contact. No thin-ray fallback is attempted when the initial spherecast misses.
- `WeaponEnvDamage` routes attack actions, action/exterior door bash and static impact sounds. Actor handling follows through WeaponDamage. This conditional source routing does not establish the target's explicit enemy-first multi-contact policy.
- `ApplyWeapon` normally sets defaultWeaponReach; visual/racial overrides are separate paths. Unity transforms and collider hierarchies do not supply a complete durable target-identity contract.

## Detailed rules and behaviors

### Aim, origin and acquisition

At the COMBAT-004 commitment marker, resolve targeting from current player position and current resolved gameplay camera facing, not targets locked at attack start. Exclude cosmetic bob/offsets from authoritative aim under MOVE-003. Capture commitment origin/facing for this attack's resolution; do not retarget from subsequent camera turns.

Default aim remains camera-forward in gameplay cursor mode. The visible cursor continues to target ordinary interactions; HUD-consumed input cannot start an attack. Mods may provide explicit cursor-directed combat policies.

Default melee uses a modest forward volume, not exact sprite-motion collision. Initial balance dimensions are reach R=2.25 reference units and acquisition radius r=0.25, subject to Godot world-scale verification. Valid contact must lie in front of the origin, inside the configured forward volume and within actual reach; broad-phase volume thickness cannot extend reach. Close enemies overlapping the volume at commitment remain hittable when these contact tests pass; do not inherit a cast-origin overlap blind spot. Behind-origin contact does not qualify.

The exact primitive/cap representation and axis/tolerance conversion require native fixtures. These are bounded engineering details, not permission to widen the approved 0.25 radius, add rear coverage or extend 2.25 contact reach. Broad-phase casts/overlaps only find candidates; collider-center proximity alone is not a confirmed hit.

### Reachable contact and obstruction

For each candidate, find a valid combat-collider contact within volume/reach using a declared deterministic contact-check method. Actor center need not be reachable if another valid part is reachable through a gap. Do not use random samples or assume a blocked center proves the entire actor blocked. Exact contact sampling/collider-authority contract remains an engineering dependency; this does not promise exhaustive continuous surface visibility from a finite sample set.

Check an unobstructed thin path from captured attack origin to the selected valid contact. Walls and closed solid doors block. Enemies do not themselves block cleaving other nearby enemies. Nearby wall/bar contact with the wider acquisition volume does not reject a contact reachable through a genuine gap. Never use a fallback that passes through a solid wall. Effective attack-blocking geometry/material classification and collider ownership must be explicit, not guessed from render opacity or interaction components.

Ordinary open/moving doors follow MOVE-021's nonblocking policy and do not block attacks merely because they remain interactable. Closed solid doors block. Door attack-blocking policy is moddable. Nonblocking does not itself authorize door bash/activation.

### Enemy cleave and resolution order

At commitment, collect and deduplicate eligible combat actors by stable actor identity, qualify contact/reach/obstruction, and order by nearest valid contact distance. Stable actor identity breaks exact-distance ties; physics-query enumeration cannot choose order. Retain the candidate list/order for this attack.

Baseline has no separate gameplay target cap: every distinct eligible enemy in the unobstructed volume may resolve. Mods may impose a cap. Technical query buffers must detect overflow and collect a complete result or enter explicit failure/recovery; never silently omit candidates. Exact bounded-work strategy remains engineering work rather than an unapproved gameplay cap.

Before each ordered target resolves, revalidate existence, living/eligible state, contact volume/reach and obstruction against captured origin/facing. Skip invalid targets without retargeting to a new actor. Newly arriving enemies are not added; revised contact distances do not resort the original order. Target/current collider state may be reread, but the attack's origin/facing remains captured. Exact mutation/physics observation ordering must be declared before implementation.

Apply independent hit/damage resolution per reached target. An accuracy miss, immunity or ineffective-material result does not suppress other targets. COMBAT-004 charges fatigue once per committed swing and awards practice once per distinct eligible enemy actually reached, even on failed accuracy/zero damage. Candidate acquisition alone grants no practice. Active-weapon break preserves the current target's committed outcome and cancels remaining strikes under COMBAT-001/004; skipped targets grant nothing. Source replacement cannot continue the old attack.

### Enemy-first purpose and deliberate central aim

If at least one combat enemy passes the commitment-time volume/reach/obstruction checks, select enemy handling for the attack. Exclude doors and attack-triggered environmental switches/mechanisms from that swing. A subsequent miss, zero damage, skipped target or interruption cannot fall back to environmental handling. An enemy visible behind a blocking closed door does not qualify and therefore does not suppress a deliberate bash at that door.

When no reachable enemy qualifies, use deliberate central aim: the nearest relevant object along the central attack ray within melee reach may receive its applicable actor/environment handling. A nearer solid blocker prevents targeting behind it. An incidental object near the edge of the cleave volume is not purposeful targeting. Doors/mechanisms are not mass-cleaved. COMBAT-006 owns bash/action execution and composition; nearest central selection does not approve automatic door toggling or duplicate linked actions.

Ordinary civilians are excluded from default enemy cleave, but are deliberately attackable through this central-aim route when no reachable combat enemy takes priority. Their attack eligibility/damage/legal consequences are separate from combat-practice eligibility: COMBAT-004 grants no default civilian practice. Eligibility is moddable. Central classification and civilian/environment conflicts require explicit nearest-object dispatch rather than all matching handlers running.

### Modded profiles and wall-stop behavior

Support moddable reach, width/cleave geometry, target cap, eligibility and attack-blocking rules. Profiles may vary by weapon and attack direction and support explicitly defined directional sweeps. Baseline continues to use the common forward volume, not per-direction sprite tracing. Modded profiles must declare geometry, origin/aim source, timing, contact order and interruption behavior rather than relying on visual frame side effects.

An optional mod policy may stop a swing early when its arc hits solid geometry, such as a greatsword contacting a cramped hallway. This is explicitly off by default; baseline acquisition-volume wall contact does not cancel the whole attack. A wall stop before commitment cancels without attack fatigue. A stop after commitment retains the single fatigue charge and already committed hits/practice, preventing remaining strikes. Never undo completed target results or grant practice for targets not reached.

Timed mod sweeps require explicit reconciliation with COMBAT-004's one commitment and COMBAT-001 cancellation, captured origin/facing and default nearest-first ordering. This feature authorizes extensibility, not an unspecified stock sweep animation, alternate damage formula or silent replacement of baseline ordering. Exact supported profile variants/scheduling and validated override precedence remain MOD/COMBAT engineering contracts.

## Relevant formulas and parameters

Baseline R=2.25 and r=0.25 reference units. For contact P and captured origin O, require positive forward projection relative to captured unit facing F, valid configured volume membership, distance |P−O|≤R and an unobstructed segment O→P. Boundary epsilon and primitive endpoints require consistent native scale fixtures; radius must not add to allowed distance R.

Sort initial valid contacts by ascending contact distance and stable actor identity on exact ties. Each actor occurs once. Default target cap is absent; any mod cap must be explicit and validated. Costs/practice remain COMBAT-004's once-per-swing/per-eligible-enemy policies; reach/width do not introduce new damage/accuracy bonuses.

## Required data

Attack/session identity and captured source/direction; resolved profile/provider; captured commitment origin/facing and world-coordinate context; reach/volume policy; stable actor identities and authoritative combat colliders; valid contact evidence/distances; initial order/purpose; current target validity; geometry/door blocking state; central ray result; per-target completion/interruption; query overflow/failure results. Raw collider IDs/query indices are not durable actor identity.

## Inputs, outputs and events

Inputs: commitment marker, current aim/position, selected weapon/form/direction, profile data, actor/geometry observations, target mutation and source interruption. Outputs: ordered eligible targets/contact evidence, skipped/blocked outcomes, selected enemy or deliberate central purpose, COMBAT resolution requests and optional modded wall-stop cancellation. Concrete APIs/signals remain unselected. Acquisition/preview cannot itself damage, train, trigger mechanisms or consume gameplay randomness.

## Cross-system interactions

COMBAT-001 interruption/cooldown/load; COMBAT-002 attack source/presentation; COMBAT-003 direction/input/camera capture; COMBAT-004 commitment/fatigue/practice/cleave consequences; COMBAT-006 environment; later COMBAT/RULE damage, effects and wear. MOVE-003 resolved aim/cursor, MOVE-004/027 position/origin coherence and MOVE-021 effective door blocking; LOC/WORLD geometry and mechanism policy; NPC/LAW actor/civilian eligibility/consequences; ITEM source validity; AV feedback/contact presentation; MOD/DATA profile validation; CORE/SAVE lifecycle and coherent observation.

## Edge cases and failure conditions

Verify very close/overlapping actors, large/multiple colliders, actor center behind bars, partly exposed limbs, solid walls, open/moving/closed doors, stairs/vertical aim, doorway enemies and central civilians. A reachable enemy prevents accidental doorway bash even on zero damage; a blocked enemy does not prevent deliberate closed-door bash.

Queries excluding the player's own colliders must not accidentally exclude valid targets by overly broad shared layers. Target collider mapping and nearest relevant obstruction must distinguish combat identity from decorative/trigger shapes. Solid geometry cannot be ignored merely because it has no action; explicitly nonblocking geometry needs validated classification.

During cleave, removed/dead/moved/obstructed targets are skipped; new actors are not added. Weapon break stops later strikes. Default wall contact must not mimic the optional wall-stop mod. Technical overflow or invalid profiles require truthful recovery rather than a randomly truncated successful cleave. Partial target completion cannot be replayed after failure; exact recovery boundaries remain COMBAT/CORE contracts.

## Configuration and balancing options

Initial reach/radius and no-cap baseline are confirmed, with native scale testing retained. Mods may configure weapon/direction-specific profiles, sweeps, caps, blocking, eligibility, cursor aim and optional wall stop. Exact numeric bounds, schemas, provider precedence and content compatibility remain dependencies under approved DATA/MOD/RULE validation. No new player-facing reach/cap slider or default arc-wall cancellation is approved.

## Save/load considerations

COMBAT-001 cancels unfinished attacks on load; no pending ray/candidate list or gesture is replayed. Preserve already committed target outcomes/costs/practice through their owners. COMBAT-004/SAVE must define coherent save boundaries for ordered multi-target work; this feature does not authorize saving partial collider observations and rerunning them as fresh strikes. World-origin rebasing must coherently transform active captured geometry or safely gate the operation under MOVE; it cannot create new reach or duplicate hits. Exact transient-state/schema and in-progress modded sweep handling remain owner contracts.

## Technical constraints

Target Godot 4.7.2. Separate broad-phase acquisition, deterministic contact qualification, obstruction, ordering, purpose dispatch and effect application. Use stable actor identity and one declared observation/order contract; do not depend on Unity cast semantics, physics return order or visual sprite bounds. Geometry queries must be effect-free. Modded temporal sweeps need explicit commitment/interruption integration; no implementation or coding tasks are authorized.

## Acceptance criteria

1. Commitment-time current position/resolved facing controls melee, excluding cosmetic offsets and gameplay cursor position by default.
2. Forward 2.25-reach/0.25-radius acquisition supports multiple enemies and very close overlap without behind-origin hits or radius-based reach extension.
3. A deterministic reachable collider contact may qualify through a real gap even with blocked actor center; solid world barriers prevent through-wall strikes.
4. Open/moving nonblocking ordinary doors do not block merely through interaction targetability; closed solid doors block, subject to explicit validated mod policy.
5. Initial targets deduplicate by actor, order nearest-first with stable ties, and have no default gameplay cap. Technical overflow never silently truncates.
6. Per-target revalidation skips invalid actors against captured origin/facing without adding newcomers or changing initial order.
7. Independent target outcomes, fatigue/practice and weapon-break interruption follow COMBAT-004; duplicate colliders cannot multiply awards.
8. Reachable-enemy purpose excludes incidental door/mechanism handling regardless of later miss/skip/interruption. Blocked enemies do not suppress purposeful bash.
9. Without reachable enemies, only nearest relevant central-aim civilian/environment contact within reach may route; edge-of-cleave objects cannot activate incidentally.
10. Mod profiles can vary by weapon/direction and support explicit sweeps/wall stops. Default wall contact does not cancel the swing; optional stops retain approved pre/postcommit consequences.
11. Preview/refresh/failure/load cannot replay effects or candidate selection into another attack/session. Native geometry fixtures verify narrow openings, overlaps, blockers and doorway priority.

## Contradiction review

Reviewed against approved COMBAT-001–004 and MOVE-003/004/018/021/027 contracts plus COMBAT catalog/architecture and inspected source. No direct contradiction identified. Enemy-first dispatch intentionally replaces DFU's environmental-first contact path. Effective door blocking preserves MOVE-021's nonblocking moving/open doors while separating targetability from obstruction. Civilian attack eligibility remains distinct from COMBAT-004 practice eligibility. Default nearest-first applies to baseline volume resolution; mod sweeps require declared override contracts rather than silently changing it. Commitment capture/revalidation does not rewrite RULE-015 attack timing or undo committed outcomes. Broader architecture proposals remain Proposed.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: native scale/volume caps/contact epsilon; contact-sampling coverage; collider/obstruction ownership; overlap and boundary fixtures; exact observation/mutation order; bounded complete query processing; central dispatch details; mod profile/sweep schemas/override precedence; partial-operation recovery and save boundaries. These cannot silently enable through-wall/rear hits, truncate uncapped cleave, revert per-target practice or reintroduce incidental door activation. COMBAT-006 still owns environmental outcomes, not started by this review.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-005-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented geometry, collider ownership, ordering, query completeness, mod contracts, recovery and save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
