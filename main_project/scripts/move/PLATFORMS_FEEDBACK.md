# IMP-012 increment 4 — platforms and feedback

**Acceptance update, 2026-11-25:** All seven human checks passed and the user
accepted increment 4 and parent IMP-012 as complete; see
[acceptance](../../../design_docs/development/evidence/IMP-012-ACCEPTANCE-2026-11-25.md).
The scope/integration limits below remain explicit future-owner obligations;
M2 remains open.

This extends the existing SessionShell coordinator, placement capsule, resolved
view, CHAR activity/vital/death owners and classic audio adapter. The course uses
controlled entry, LOC mechanism/context, TIME, traits and prevention suppliers.
It does not deliver the classic action owner, NPC hearing, specialist movement,
native SAVE, live transit, WORLD residency or the M2 milestone.
Machine qualification and human acceptance are recorded separately in execution
evidence. Development implementation alone is not a passing verification claim.

## DATA and mechanism ownership

`move.mechanism:policy/<id>` uses `mechanism-motion-v1`; `move.feedback:policy/player`
uses `movement-feedback-v1`. Both join the ordinary shipped → MOD → loose
publication and content lock. They require complete validated records and retain
DATA winners/provenance. Point queries use captured small definitions, not new
catalog preparation. No new native library or toolchain is introduced.

Mechanism policies declare upright-box geometry, carry/push/crush booleans,
grounded-crouch lethal eligibility (or none), a finite numerical tolerance and
explicit exception evidence. Shipped `carry-push` is nonlethal; `grounded-crush`
qualifies actual translating grounded compression. No all-elevator pass-through,
model-name exception, stop-on-player trajectory or generic angular/specialist
lethal policy is inferred. Unqualified blocked motion requires owner recovery.
The tolerance is 0.001 m by default, may not exceed half the current contact gap,
and cannot reduce the existing MOVE collision margin.
`exceptions` retains bounded stable IDs and evidence for a provider-selected
policy; it is provenance, not executable model-name matching. Effective behavior
comes from that validated policy's flags/mode. Both shipped exception lists are
empty. Selecting a real classic mechanism policy remains its owner's joint gate.

The current bounded composition admits one explicitly bound mechanism supplier.
`bind_mechanism(provider, source, policy)` requires a current CORE session service
with the motion role. The provider owns the mechanism's state and actual static
collision box; MOVE alone owns the player's pose. Stable source/support identities
and committed motion revisions are separate from the borrowed runtime Node/RID.
Those engine handles are observations, never durable identity.

Provider methods are:

- `mechanism_sample(context, eligible_seconds)`: a read-only candidate containing
  exactly session, source, support, next committed revision, from/to Transform3D,
  current geometry and dimensions in metres. Context includes the MOVE sequence
  and placement serial. Preparing a different duration replaces an uncommitted
  candidate; it cannot advance trajectory phase or rewrite committed history.
- `mechanism_current(candidate) -> bool`: attests the exact current candidate.
- `mechanism_commit(candidate) -> bool`: idempotently commits that candidate's
  mechanism state and synchronizes actual collision transforms. It cannot move
  the player. Repeated acknowledgment must not advance the mechanism again.
- `mechanism_checkpoint()` / `mechanism_checkpoint_current(state)`: read and
  attest the mechanism owner's current phase/trajectory state. Checkpoints admit
  bounded finite plain data, not provider pointers or unvalidated cyclic graphs.
  A changed trajectory or collision shape rejects player reconstruction even
  when the mechanism's displayed origin has not moved.

Transforms are finite, upright, unscaled and orthonormal; box dimensions and
velocities have explicit bounds. Translation is at most 100 m/s and yaw at most
four turns/s in this profile. The complete support point inherits the existing
1000 m/s point-motion envelope. Physics/Node transform agreement uses 0.00001 m
origin and 0.000001 basis-axis tolerances; these admit engine normalization, not
changed geometry. Sampling requires the actual current single box and nonzero
collision layer; wrong shape/dimensions, scope/support identity, regressing
revision or discontinuous from-transform rejects. Reconstruction additionally
compares the captured support dimensions and requires active collision geometry.

## Coordinated physics and attribution

The coordinator splits eligible moving-geometry intervals into bounded collision
slices. The bound includes translation plus box-corner yaw travel. Travel stride
is no larger than the normal probe stride and half `sqrt(8 * capsule_radius *
motion_margin)`; yaw slices are at most one degree. This keeps rounded-contact
grazes below the numerical margin. More than 2048 required slices rejects or
retains an already-performed prefix under recovery; it never teleports geometry.
No elapsed remainder is replayed after suspension or failure.

Each ground slice prepares full posture/route and all required supplier facts,
reserves CHAR performed-work custody, commits mechanism motion and the same MOVE
capsule, then captures the actual TIME/activity proof. Ground carriage precedes
voluntary movement. Actual support-relative feet are refreshed after that travel,
including walking off onto another ordinary surface. Horizontal carriage blocked
by a wall can retain a collision-valid prefix while the platform slides beneath
the rider; that frictional contact is not crushing.

Yaw changes retained actual view facing and the upright physical body. Subsequent
look remains additive. Voluntary velocity excludes carriage/pushing; supported
surface distance excludes passive displacement and stair/contact correction.
`mechanism_metres` sums the passive mechanism path across slices, separately from
the displacement vector. Only actual voluntary supported travel supplies Running
practice and walking stride progress. Ordinary CHAR elapsed costs remain active.

Actual support samples populate the same nine-field `platform_velocity` contract
used by increment 3, with a current mechanism attestation and collision witness.
Conflicting external point providers reject while that binding is active. Jump
and walk-off inherit linear velocity plus angular radians/s cross the actual
metre radius once. Detachment is immediate. A rejected Jump remains a carried
ground step. Flight advances before the mechanism's residual collision-valid push,
so a rising platform cannot add both carriage and takeoff inheritance. Real
support loss enters the existing air history without a support timer.

## Compression and required consequences

Capsule/box volume and full-capsule swept routes establish compression. Opposing
contacts come from actual full-shape queries, including destination-volume checks
when a cast ends at a numerically tangent boundary. Their bounded witness extension
is twice the query margin. No camera ray or model description authorizes death.
Stationary actions use the stock complete posture/collision query. A supported
elevator, stationary roof or horizontal frictional carriage alone is not a crush.

A crush-enabled translating mechanism must actively compress a grounded Foot
body against a real opposing obstruction. Forced crouch commits first, retaining
desired posture and a source-owned temporary reason. Release removes only that
reason; desired standing still requires complete clearance. Continued compression
that cannot fit the validated crouched capsule retains one crush operation.
Angular traps and specialist lethal combinations require their own qualification;
they receive no invented immunity, universal lethality or tiny substitute shape.

The safe crouched pose and unadvanced compressing sample are retained under a
CORE consequence hold. This is a technical consequence boundary, not an authored
stop-on-player mechanism rule. Performed activity settles before CHAR health.
The existing narrow `move-landings` MOVE vital binding additionally attests only
the exact retained crush request. Saturating health damage uses real CHAR
prevention/death resolution and acknowledgment; MOVE never assigns health.
`retry_crush` cannot move, repeat a mechanism interval, reroll prevention or replay
death. Retirement retains unresolved original requests in diagnostics.

Successful prevention preserves survival and keeps the collision recovery hold.
`recover_crush(original_provider, outcome_id, eligible_seconds)` qualifies a new
safe provider proposal while gated, without advancing time or pose. Unchanged
lethal compression rejects. An owner-selected safe proposal can release only the
crush hold; its next actual update is fully revalidated. Other CORE/CHAR holds
remain. Recovery receipts are separate from immutable health outcomes.

Lost mechanism acknowledgment retains the original sample and performed work.
`retry_mechanism` repeats acknowledgment only. Independent holds and unrelated
recovery failures cannot be released by an empty retry.

## Feedback, camera and audio

The producer emits scoped actor/placement/sequence identities from committed
movement. Fractional stride progress survives ordinary gait/surface seams. It
emits the complete crossed-step range separately from optional AV playback;
muting, missing clips and cosmetic omission cannot change that range, CHAR
activity or consequences. NPC intensity, propagation, consumption/retirement and
detection remain real NPC-owner integration gates, not an implemented hearing
system. No stealth readiness follows from this presentation seam.

LOC context supplies a validated category under the current placement ticket.
The controlled course supplies stone explicitly. Production locations without
that context are `unclassified`, with diagnosed optional silence. Definitions
include stone, ground, snow, shallow-water, swimming, wood and modded categories;
those mappings do not establish water, climate or mounted gameplay.

Strides are Walk/Run 2.5 m and Sneak 1.6 m. The first two are the documented DFU
PlayerFootsteps distance baseline interpreted in project metres; Sneak and camera
amplitudes are project tuning. Sound ordinals follow DFU's MIT-licensed
PlayerFootsteps/SoundClips tables. The existing validated classic decoder supplies
PCM from the external source; no classic audio bytes are redistributed. Streams
are prepared once at binding, with no per-frame decoding, catalog scans or I/O.
Four listener-relative voices and one step admission per 100 ms of eligible
presentation time bound cosmetic catch-up. Missing optional clips are silent with
diagnostics. Required asset recovery is not weakened. Landing impact wins over a
step at the same contact; hard-feedback eligibility remains independent of damage.
The presentation-only `water_entry` receipt seam gives a validated water contact
priority over its duplicate impact/step while retaining separate impacts and the
complete gameplay-noise distance range. Earlier solid contacts reject late splash
receipts. This seam is qualified with controlled events only; actual entry,
protection and water ordering remain MOVE-014 work.

Stock Controls owns live gait bob, mounted bob, landing camera and movement-audio
percentages, each with 0/Off. Defaults are 50/50/0/100. Full-strength position
amplitudes are 0.015/0.020/0.045 m respectively; no rotational bob/roll is added.
Mounted application is a controlled interface until actual mounted context exists.
Effective preferences reach recreated consumers independently of saved values.
The AV preference consumer participates directly in Controls' validate-all /
publish-all boundary; view configuration emits no mixed-preference notification.
`SessionShell.replace_movement_audio` reapplies that effective state and binds the
new consumer after the current placement and monotonic cue sequence. The cue
sequence remains separate from physical update numbering, so landing and step
events from the same physical update remain individually ordered. Late queued cues from
the preceding consumer are rejected.

The view owner composes safe cosmetic position with the existing posture/stair
baseline. The same displayed camera exposes its actual projected origin plus the
declared cosmetic offset. Targeting removes only that positional treatment;
direction remains the actual displayed resolved look. Ray tickets validate both
origins/offset and direction. A full enclosing-sphere route bounds the displayed
offset. Camera treatment cannot alter pose, collider, health, breathing or aim.
Cursor mode eases bob to neutral while eligible distance audio continues.

Pause suspends eligible mechanism/player advancement and gameplay-linked audio
without catch-up. Placement, coherent reset and supported restoration reset
cosmetic phases/voices without decoding again or treating relocation as walking.
Death retains its existing view ownership. Feedback callbacks cannot reenter
physical advancement, vital consequences or required settlement.

## Checkpoints and remaining gates

`capture_ground_state`/`restore_ground_state` extend the settled gated in-memory
air checkpoint with current mechanism/support history, desired/forced posture,
crush outcomes and recovery receipts. Current geometry/provider state must already
match. Missing or changed support rejects; no nearby-object fallback, transform
replay or rewind is allowed. Pending required debt rejects settled capture.
These APIs explicitly report `native_save_ready=false`.

DFU PlayerGroundMotor attachment and PlayerCrush source are representative static
evidence only. Its model-description BOX exclusion and reported elevator behavior
do not establish a general exception here. Unknown classic actions/axes retain
their non-executing metadata policy; this increment implements none of their
execution semantics. Real classic mechanisms, multiple-provider location
composition, specialized lethal modes, WORLD origins/residency, native SAVE/live
transit, NPC hearing, real prevention directories and named long-session/CHAR
retirement obligations remain open. Human audible/feel checks and acceptance are
separate from automated success.
