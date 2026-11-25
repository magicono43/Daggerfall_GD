# IMP-012 ordinary stair allowance — 2026-11-25

**Later contact follow-up:** Straight travel works in human review, but diagonal/
wall-adjacent contacts exposed further defects. See [contact execution evidence](IMP-012-stair-contacts-2026-11-25.md).
This document and its audit retain the prior straight-travel checkpoint.

The user authorized following DFU's step allowance after reviewing source stair
heights and reporting that the grey stairs above the approved ramp should be
walkable. The previous 0.25 m upward / 0.18 m downward values were project tuning,
not user-selected limits or original-game measurements. This follow-up replaces
them; historical execution reports retain the values they actually tested.

## Behavior and provenance

`move.ground:policy#player.surface` now supplies independent **0.50 m up and
0.50 m down** limits. Both remain ordinary DATA/MOD/loose-override values within
the existing validated schema. The upward reference is DFU's pinned
`PlayerAdvanced.prefab` and `PlayerStandalone.prefab`, both with
`m_StepOffset: 0.5`. Downward 0.50 m is an explicit project choice so ground-only
following accommodates the same stairs; DFU uses controller/gravity rather than
our separate downward parameter. This is not a claim of identical Unity physics.

The sampled original ordinary staircase risers span roughly 0.20–0.45 m,
including the reported 67025 model's 0.30 m risers. Oversized examples have
0.80 m risers. A 0.50 m allowance accommodates ordinary examples while retaining
larger ledges for jump/climb owners. The sample is not an exhaustive placement or
original-executable behavior classification. The steep-floor list and ordinary
45-degree uphill limit are unchanged; a taller step limit is not a broad slope
exception or collision/posture bypass. Air/fall beyond the bounded ground route
remains a later increment, not an ordinary resumable Pause state.

## Contact corrections

The source-stair regression initially remained blocked after the first stair even
with the new tuning. Capsule support had incorrectly treated agreement between
adjacent tread normals as evidence that their support planes shared a height.
It now uses the real full-capsule cast clearance for bounded tread contacts even
when their normals are parallel. At the upper ramp lip, a higher ordinary tread
can establish footing while the rear cap still touches the finite ramp.

Measured tread height now determines the upward probe lift, bounded by the
configured allowance. Small stairs no longer require headroom for the entire
maximum step height. All upward/across/downward route fragments retain complete
capsule clearance and support validation.

For downward following, the owner commits the full-shape-validated across/follow
route. Previously it validated those fragments, then sent their diagonal chord
through a second collision response; that could cut a tall stair lip and leave
an overlapping capsule. Collision prefixes and wall-slide direction remain
measured before commitment; bounded connector motion retains its gait budget.
Already-qualified sweeps are reused rather than repeated on every flat fragment.

Extending the regression across the whole staircase exposed another descending
edge case. At a rounded capsule rim, contact can be almost horizontal even though
the underlying tread is an ordinary slope. The floor-angle policy still applies
to the real centre/footprint floors. A lower-hemisphere contact is accepted only
within the existing margin-sized point tolerance and with an upward tread witness
at that finite edge; a wall-side sample is insufficient. A descent obstructed by
the preceding lip uses a bounded twelve-probe search for a clear prefix, followed
by fresh nearby-support validation. No route or support failure is waived.

## Verification and review

Maintained coverage now includes 0.50 m upward/downward boundaries, 0.51 m
rejection/handoff, a blocked 0.80 m obstacle, and the existing small-step,
low-ceiling/crouch, gap, slope, camera, activity and persistence cases. The original
`block-0917/record-00028` scene tests ascent along the full original 16-riser staircase and
return across the ramp in standing/crouched Walk/Run/Sneak. Actual committed
capsules are independently queried for overlap, with performed speed and real
CHAR practice checks. Expected inventories are 586 headless, 587 rendered and
10 fresh-process preference assertions. All final selections passed; see the
[machine audit](IMP-012-ordinary-stairs-2026-11-25.audit.json). The upper-tread goal
is 6.0 m into the independently measured 6.1 m tread-height span; it does not
certify the adjoining passage or complete assembled-location reachability.

The earlier three-ramp human checks remain PASS. The altered ordinary stairs and
their return transition require a new human check; previous check 7 remains a
historical report, not a pass for this build. Overall increment, parent IMP-012,
M2, full assembled routes and native SAVE acceptance remain separate gates.

Changes remain uncommitted.

Four final maintained selections passed: headless 586 + reload 10; rendered
587 + reload 10; Windows debug and release each 586 + 587 + two reloads of 10
(1,193 assertions per export). The actual source-block review-window smoke passed
15 checks across 60 live frames, without recording human acceptance. Total selected
passing assertions: **3,594**. Failed, superseded and focused development runs are
retained separately and excluded.

The 12-adapter 5,000-update observations were 5.551 s headless and 5.643 s rendered,
versus the earlier 5.691/5.550 s observations. Capability queries (1,000) took
15.143/14.989 ms. These are local observations, not new budgets or an isolated
measurement of stair-edge cost. The rare edge checks/searches remain narrowly
scoped native queries; no catalog traversal or repeated DATA graph preparation
was added to physical point queries.

The first debug rendered export ended before producing a result. Repeating the
same exported code completed 587 checks, but that diagnostic probe had non-isolated
shader-cache warnings and is not counted as qualification. The initial cause is
not conclusively localized. Ground export allowance now matches the maintained
runner's 1,800 frames and records child exit/result presence; no assertion or
inventory was relaxed. Fresh debug and release exports each passed both modes
and fresh-process reloads. Exported and source-run builds use the same frozen
production and maintained-test source hashes.

Ten owned roots were compacted after verification: 16,729 reproducible files /
3,065,487,507 bytes removed. Retained 138 hash-verified child reports/logs/captures,
32 disposable player logs, exact typed inputs and source archives. No selected
full project, export or cache remains. Logical retention changed from
7,237,018,321 to 4,180,061,408 bytes before small final report writes. Earlier
accepted evidence and protected other-task review projects were preserved.
