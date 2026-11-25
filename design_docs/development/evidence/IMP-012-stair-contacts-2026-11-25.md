**Acceptance update, 2026-11-25:** The user approved the improved angled/wall-adjacent stair behavior and explicitly accepted increment 2. See [acceptance](IMP-012-INCREMENT-2-ACCEPTANCE-2026-11-25.md). Earlier pending wording below records the preceding checkpoint; later integrations remain open.

# IMP-012 diagonal and wall-adjacent stair contacts — 2026-11-25

The user's follow-up confirms ordinary straight ramp/stair travel, but reports
sticking at an angle and rapid falling/handoff indication when hugging either
wall. The human build is
`verification-rendered-17dbac68203440ca92259c5ce685505e`; its review is closed.
The preceding ordinary-stair audit remains its historical checkpoint. New contact
behavior and human re-review are not automatically accepted.

## Reproduction and intended correction

The maintained source course now has a separate entry for eight trajectories:
standing/crouched Walk at yaw ±30 degrees and Run at ±45 degrees. Each approaches
the stairs straight, turns at the ramp lip, presses into its enclosing wall during
ascent, then retains pressure against that same wall while descending. Between
trajectories, stock input returns the actor to the lower landing's centre. No
test writes actor poses. All phases require actual support, bounded gait speed,
clear committed capsules, consistent motion direction and real CHAR practice.

Before the corrections, the first trajectory reproduced a missing-footprint
handoff with a clear capsule. Correcting angled tread sampling then exposed the
wall seam further up the stairs. Some original tread faces end 0.025 m inside
their enclosing wall. A full-radius footprint ray can therefore land in that seam
while the capsule is genuinely supported on the tread.

The step top is now sampled across the measured obstacle's horizontal normal,
rather than only along the diagonal input direction. Full requested across-route
clearance and the 0.50 m height bound remain mandatory. Actual enclosing walls are
observed above any legal riser, so stair faces are not treated as walls. Their
constraints act on original input, with at most four bounded redirects and no
movement against that input. A zero-length blocked prefix does not itself imply
leaving valid ground.

A missing footprint at a nearby enclosing vertical wall can be re-observed on a
real floor inside that wall. This is a bounded, wall-specific floor observation;
it does not reduce capsule size/margins or replace full-shape clearance. Centre,
other footprint, height-span, physical-contact and real-drop checks remain.
An open ledge has no wall witness and retains its existing unsupported result.
No falling owner, hidden support grace timer or global slope exemption is added.

## Verification

All final maintained checks passed: headless 693 plus 10 reload, rendered 694
plus 10 reload, Windows debug and release 1,407 each, and 15 launch-smoke
assertions: **4,236 selected assertions**. The new contact course contributes
107 assertions, covering eight standing/crouched Walk/Run trajectories at
30/45-degree angles against both walls. Straight Walk/Run/Sneak travel, the
three ramp designs, 0.50 m boundaries, 0.51 m drop handoff, 0.80 m obstacle,
low-clearance/posture and open-edge cases also passed. Launch smoke is not a
human pass. See the [machine audit](IMP-012-stair-contacts-2026-11-25.audit.json)
for exact source hashes, reports, fixtures and retained outputs.

The first full headless run caught premature stopping before a pure wall;
preserving its reachable approach prefix corrected it without weakening checks.
Focused development and that failed run are excluded from acceptance.
The final headless/rendered 5,000-update probes took 5,570,632/5,597,470 us;
1,000 capability queries took 14,999/15,075 us, with 145 retained objects.
These are fixture measurements rather than an invented frame budget.

Cleanup preserved hashed source archives, typed inputs, reports and player logs,
then removed six inactive disposable project/export/cache payloads (10,269 files, 1,904,709,918.0 bytes). Total `.runs` retention measured 4,414,152,511 bytes without following reparse points. Earlier human review roots remain untouched.

Changes remain uncommitted. New human contact checks and overall increment,
parent IMP-012/M2, full-route and native SAVE acceptance remain open.
