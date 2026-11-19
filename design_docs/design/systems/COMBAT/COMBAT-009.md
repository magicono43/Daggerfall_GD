# COMBAT-009 — Arrow collision and attack attribution

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Make released arrows travel, hit actual blockers and retain their own attack context independently of later equipment/AI changes. Preserve airborne threats across same-location saves, prevent thin-wall tunneling/spawn-offset exploits and support custom flight policies without duplicating impact effects or recovered ammunition.

## Confirmed requirements

COMBAT-009-D01–D15 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record five interviews. D04 explicitly refines RULE-013/014 live-input evaluation for airborne arrows: offensive data captured at release, current defender data at impact. D09 approves in-flight persistence; D12 limits flight to current location scope. The complete specification is approved under COMBAT-009-A01. COMBAT-001–008 release costs, timing and ammunition conservation remain binding.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths below are relative to reference `Assets/`.

- `Scripts/Game/DaggerfallMissile.cs#Start` disables gravity, builds an arrow model/trigger mesh, offsets its position and ignores collision with a caster collider. Player visual offsets include 0.6 forward, 0.11 downward-relative and ±0.15 side; NPC offsets use caster forward/height. These offsets are evidence, not approved target constants or a complete near-wall safety check.
- Missile Update moves along direction×MovementSpeed×deltaTime and tracks lifetime. `Prefabs/Missiles/ArrowMissile.prefab` sets MovementSpeed=35 and LifespanInSeconds=8 with gravity off, overriding class speed default 25. Native collision thickness is not established by copying one prefab collider: the prefab and created arrow model have distinct geometry.
- `DoCollision` uses impactDetected, changes collider/rigidbody state, gathers contact entity and dispatches arrow damage for its trigger route, destroys arrow model and marks impact. Trigger/physical callback behavior requires target-independent explicit contact handling.
- `AssignBowDamageToTarget` reads WeaponManager.LastBowUsed for player arrows; enemy dispatch checks contact against the caster's current EnemySenses.Target and calls EnemyAttack.BowDamage, which also uses current equipment/target. Target deliberately removes these mutable per-manager dependencies.
- Complete native save support for in-flight arrows was not established in source analysis. Target persistence is an approved intended requirement, not a claim of DFU parity.

## Detailed rules and behaviors

### Per-arrow source and offensive snapshot

Each successful release creates a distinct arrow record carrying firing actor identity, source bow identity/relevant definition and COMBAT-008 ammunition payload/status/recovery data. Multiple arrows/volleys never share a mutable last-bow/current-ammo lookup as their authoritative source. Capture offensive stats/modifiers at actual release; later buffs/debuffs, equipment swaps, source breakage/removal or shooter death do not rewrite airborne offense or recall the arrow.

At impact read current contacted defender defenses and target-dependent classification/state coherently under RULE-013/014. Evaluate target-dependent bonuses for that actual target using captured source data. Snapshot numeric inputs is not a pre-rolled hit against the draw-start target; probability/body-part/damage draws remain impact-resolution work unless their owner explicitly specifies otherwise. Exact field inventory and effect/hook phase adapters require RULE/ITEM/MAGIC integration so mixed captured/live values cannot arise accidentally.

Shooter death/removal does not discard the projectile within its active location scope. Stable attribution remains for damage/legal/quest ownership. Any side effect needing an extant source actor or bow must address the original stable identity through its owner. Never mutate a replacement actor, newly equipped bow or unrelated inventory item. Missing-source mutation policy remains an explicit owner dependency; continuing projectile damage does not promise arbitrary mutation on nonexistent state.

### Flight and eligible time

Default flight is straight, non-homing and gravity-free at 35 reference units/eligible gameplay second, with an eight-second eligible lifetime. Treat these as initial scale-verified balance values. Pause/loading does not advance position/lifetime or create catch-up motion. Mods may define speed, lifetime, gravity, homing and other flight policies through validated profiles.

Released summoned arrows follow their captured projectile lifetime rather than former inventory-stack expiry. They remain nonrecoverable under COMBAT-008; magical projectile policies may explicitly define other expiry. No inventory timer/reference is queried to silently reclassify the fired arrow.

### Origin safety and traveled-segment contact

COMBAT-007 supplies release-time resolved aim, excluding cosmetic bob and default cursor aim. Validate the path from authoritative firing position to any visual projectile-spawn offset. A solid obstruction on that segment receives immediate impact from the released shot; do not spawn beyond it, cancel/refund an otherwise successful release, or award release practice again. Exact authoritative origin/offset and initial-overlap handling require player/NPC fixtures; rendering offsets cannot authorize through-wall travel.

Each eligible simulation step checks the full traveled segment against eligible blockers, not only overlap at endpoint. Select nearest valid contact along travel. For effectively tied contacts, solid world geometry precedes actors, then stable object/actor identity breaks remaining ties. Tie tolerance/collision thickness must be validated in native world scale rather than depend on physics enumeration. Segment checking must account for moving actors/geometry under declared observation order; it does not alone prove continuous relative-motion coverage without fixtures.

Ignore firing actor's own colliders. Other eligible allies, civilians, player and combat actors may intercept independently of current AI target/hostility. Ordinary arrows ignore other projectiles. Trigger/decorative/interaction-only collider presence is not automatic blocking; explicit collider ownership/classification determines contact. Solid world geometry and closed solid doors block. MOVE-021 ordinary open/moving doors do not block merely through interaction targetability.

### Impact resolution and stopping

Resolve the actual actor contacted, not the caster's sensed target. Default arrow stops at first blocking actor/world contact even when accuracy fails, damage is zero or target is immune. Contact determines actor; RULE-013 probability rules still select damage body part. No default high-contact headshot is added. Modded collision eligibility/aimed-part, piercing, ricochet and interception policies must be explicit.

One default terminal contact owns one impact operation. Deduplicate multiple colliders/callbacks by projectile/actual actor identity and preserve resolved random results on retries. After terminal impact, disable further gameplay contact immediately; optional impact effects/audio cleanup cannot dispatch damage again. Projectile simulation must not physically push actors into riding/bouncing on the projectile. Concrete physics/visual representation remains engineering choice.

Route damage/effects/attribution through COMBAT/RULE owners using captured source and current defender context. CIVILIAN/legal/hostility outcomes remain their owners' contracts, not automatic permission to run generic enemy-only formulas on unsupported NPCs. A bystander can block a shot without becoming an eligible recovered-arrow inventory target. Existing corpses may block according to collider policy, but COMBAT-008 grants no default recovery from already-dead targets.

Recovery uses COMBAT-008's one per-arrow unit, preserved remaining properties, summoned exclusion and actor/corpse transfer policy. Impact grants no second release practice/fatigue charge. Technical failure after partial impact requires explicit same-impact recovery preserving committed outcomes; never reroll or blindly apply another target/default handler after partial mutation.

### Modded flight and multi-contact policies

Support validated custom ammo/flight profiles and independent per-arrow records within multishot. Pierce/ricochet policies must declare target deduplication, remaining flight/energy/lifetime, geometry response, damage phases and the one recovery recipient under COMBAT-008. Projectile interception requires explicit outcomes rather than ordinary crossing shots destroying each other. Extra item generation needs a declared rule. Profiles cannot silently bypass approved release costs or duplicate practice. Exact extension API/schema/precedence and supported movement integration remain dependencies; no vanilla ballistic/ricochet model is invented here.

## Relevant formulas and parameters

Baseline eligible step displacement Δx=direction×35×Δt; remaining lifetime decreases by eligible Δt from eight seconds. Default no gravity/homing. A pristine unobstructed baseline arrow has nominal travel budget 280 reference units from release, not a separate approved max-range gate or permission to skip collision near expiry.

Clip travel to remaining lifetime when a step crosses expiry, checking collisions along authorized travel before terminal expiration. Exact equal-time impact/expiry ordering needs an explicit native scheduler contract; no beyond-lifetime hit or silently omitted pre-expiry blocker is allowed. Collision thickness, origin offsets and tie epsilon are unselected engineering/profile parameters. RULE-013/014 own hit/damage formulas with the explicit offensive snapshot exception. COMBAT-008 owns ammo/recovery/practice quantities.

## Required data

Projectile/volley/attack and session/location identities; original actor/bow identity and captured offensive/configuration context; per-arrow ammo/payload/remaining-property data; position/direction/velocity/profile and remaining lifetime; actual contact/collider owner and ordered path evidence; defender-resolution snapshot; retained hit/part/damage results; impact/transfer/attribution completion; original source mutation obligations; restoration phase and terminal reason. Durable records use stable identity/versioned coordinates, not engine references or current manager fields.

## Inputs, outputs and events

Inputs: successful release, checked origin/offset, eligible simulation step, collision observations, current defender state, mod flight policy, suspension/location change and save/load. Outputs: moved flight state, actual terminal/continued modded contact, one owner-checked impact, recoverable transfer or loss, stable attribution and optional feedback. APIs/signals remain unselected. Visual completion notifications cannot independently commit damage/recovery.

## Cross-system interactions

COMBAT-004/007 release/aim/costs/cooldown; COMBAT-008 payload/conservation/volley/recovery; COMBAT-010 onward eligibility/effects/intake/feedback; COMBAT-017 enemy supplies/launch targeting; COMBAT-020/021 death/corpse association. RULE-013/014 current defenses and explicit captured offense; RULE-003 retained random results; ITEM/MAGIC source mutations/payloads/summoned policy; NPC/LAW/QUEST actual actor/attribution; MOVE-021 door blocking and MOVE-027 origin rebasing; CORE eligibility/location transition; SAVE persistence; AV feedback and DATA/MOD profile validation.

## Edge cases and failure conditions

Verify multiple bows/arrows in flight, bow swap/breakage, shooter death/removal, AI retargeting, player/ally/civilian interception and unavailable original mutation targets. An orphaned attribution record cannot attach to reused numeric IDs. Source snapshots must include enough data to resolve without a live scene object, but not resurrect it.

Verify near-wall side/forward offsets, initial actor/world overlap, thin geometry, high speed/slow frames, fast-moving targets, door motion, tied actor/wall contacts and origin rebase. Full segment queries must be complete; technical buffer overflow requires explicit recovery rather than a random omitted blocker. Same-location streaming cannot silently delete an arrow or let it cross unready collision geometry; readiness must be gated/handled under CORE/WORLD rather than pretend unloaded space is empty.

Duplicate trigger/physical callbacks cannot repeat impact. Destroying a visual arrow/audio failure cannot cancel already committed damage or create another item. A modded pierce cannot reuse default terminal-impact flags ambiguously; declare scoped per-contact versus terminal completion. Expiry without eligible actor impact loses arrow per COMBAT-008, without refund/pickup.

## Configuration and balancing options

Moddable flight speed/lifetime/gravity/homing, collision eligibility, aim/part policies and explicit pierce/ricochet/interception behavior. Baseline is straight flight, shooter-only actor exclusion, no projectile collisions and terminal first blocker. Numeric domains, collision shape, charge/payload adapters and provider precedence remain validated owner contracts. No default spread, homing, gravity or aimed-headshot bonus is approved.

## Save/load and location lifetime

Native saves preserve in-flight arrows in the saved location: position/flight state, remaining lifetime, original source snapshot/ammo payload and pending impact/completion status. Restore authoritative world/collider/actor context before resuming, with no release cost/practice replay and no load-time progression. Released arrow persistence is separate from COMBAT-001 cancellation of unfinished bow attacks.

Save at a coherent boundary or retain sufficient partial-impact facts so restore completes required work exactly once without duplicating damage, recovered item, poison/charges or legal/quest attribution. A saved arrow cannot resolve through an unready world or silently bind to a different actor/bow. Exact required-data validation/migration and allowed correction remain SAVE/CORE contracts, not silent projectile teleportation or missing-content substitution.

Leaving for a different interior/exterior location scope discards its remaining in-flight arrows without refund/recovery. Do not continue them in an off-location simulation by default. Same-location streaming/origin rebase preserves arrows coherently, not as a location exit. Ordinary pause freezes them. Session end clears runtime instances after saved state is secured; loading that saved location recreates its recorded arrows, not old runtime duplicates. Completed impact obligations remain real consequences and cannot be dropped under a flight-cleanup rule. Exact location-scope identity/boundary and transition ordering require CORE/LOC/SAVE integration.

## Technical constraints

Target Godot 4.7.2. Separate projectile state, source snapshot, contact acquisition, impact resolution and optional presentation cleanup. Use explicit eligible time, swept path tests, stable identities and idempotent per-projectile outcomes. Snapshot offense/current defense adapters must document every consumed rule input and mutation target. Native collision, relative movement, persistence and partial-failure fixtures are required; no exact Unity collider/rigidbody setup is mandated. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Earlier arrows retain original bow/ammo/offense despite later shots/swaps/buffs/debuffs/source death; current defender data resolves at actual impact.
2. Actual contacted eligible actor resolves independent of shooter target/hostility; source mutations never affect replacement actors/new bows.
3. Ordinary flight is 35 reference units/eligible second, eight-second lifetime, straight/gravity-free/non-homing; pause/load contributes no motion/lifetime.
4. Checked spawn-offset path cannot bypass geometry; immediate obstruction impact retains successful release costs/practice without refund.
5. Full traveled segments select nearest blocker; world geometry wins effective ties and stable identities remove enumeration dependence. Thin-wall/high-speed fixtures pass.
6. Shooter colliders are ignored, intervening actors/world block, other projectiles are ignored and doors follow effective MOVE-021 blocking.
7. First blocking impact stops default flight even on miss/zero damage, commits once and does not physically carry/push actors. Visual cleanup cannot repeat effects.
8. Actor contact retains RULE-013 probabilistic body-part selection; recovery follows COMBAT-008, without extra release practice/fatigue.
9. Summoned flight is independent of former inventory expiry and remains nonrecoverable. Explicit mod policies can add flight/contact variants with conserved recovery.
10. Native save/load preserves airborne/pending-impact state without replay or replaced identities. Different-location exit discards remaining flight without refund; same-location streaming/rebase preserves it safely.
11. Partial technical failures, overflow and restoration errors retain committed facts and required obligations through explicit recovery rather than arbitrary target substitution or rerolls.

## Contradiction review

Reviewed against approved COMBAT-001–008, RULE-013/014/015, MOVE-003/021/027 and CORE load/suspension contracts plus source/catalog/architecture. No direct contradiction identified. D04 is an explicitly confirmed projectile exception to live offensive-input evaluation; current defender evaluation/body-part probability remains. COMBAT-008's previously open in-flight persistence/summoned lifetime now have explicit intended contracts. No arrow recall on bow/source loss preserves COMBAT-001 committed release. Location exit cleanup differs intentionally from same-location save/load persistence. Broader architecture proposals remain Proposed beyond confirmed requirements.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: exhaustive offensive snapshot/defender/hook adapters; absent-source mutation semantics; authoritative origin/collision shape/tie tolerance; initial overlap and relative-motion fixtures; expiry/contact ordering; location-scope streaming gates; per-impact recovery and save schemas/migration; mod flight/profile precedence. These cannot revert to mutable last-bow/current-target attribution, bypass walls, duplicate ammo/practice or erase saved incoming arrows without an explicit approved policy change.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-009-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented snapshot/hook adapters, source mutations, collision fixtures, location/streaming boundaries, mod contracts and native persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
