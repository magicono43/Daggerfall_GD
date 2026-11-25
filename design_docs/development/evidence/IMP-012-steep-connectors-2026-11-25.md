# IMP-012 steep corridor implementation — 2026-11-25

**Later ordinary-stair update:** The user authorized DFU-style step tuning. See
[the 0.50 m follow-up](IMP-012-ordinary-stairs-2026-11-25.md) and its
[new human review](IMP-012-ORDINARY-STAIRS-REVIEW-2026-11-25.md). Earlier 0.25/0.18 m
limits and open stair-boundary statements below describe the previous checkpoint.

Implemented explicitly scoped traversal permissions for the three user-confirmed
corridor floor designs, limited to the 25 reviewed source records. Human checks
1-5 pass on all three designs and the source-block ramp works; ordinary stairs
and the returning support-loss hold remain open. See the [playable review](IMP-012-STEEP-CONNECTORS-REVIEW-2026-11-25.md).
The earlier eight posture/surface checks remain user-reported PASS. This follow-up
does not accept the entire increment, parent IMP-012, M2, later increments or SAVE.

## Scope and ownership

The existing `move.ground:policy#player` DATA definition now includes a replaceable
`connectors` array. Each row pins the classic block/record, source address, exact
source pose, model hash, block payload hash and original floor plane. The shipped
list contains 61030/plane 1, 67027/plane 6 and 67029/plane 6 at 25 exact records.
MOD/loose patch/replace precedence remains the ordinary DATA publication path;
an empty list removes grants. No model-only or dungeon-wide exemption is used.

LOC records source-plane identity for immutable collision triangles and binds
eligible floor triangles to each checked physical shape. Source/record/resource
changes, replacement meshes, unreviewed tilted placements, stale tickets,
changed world poses and shape edits do not inherit permission. Changing a shared
shape invalidates its grants. Runtime queries resolve the actual shape owner,
selected triangle point and geometric normal. Jolt's optional missing face index
is handled through bounded source-triangle containment, without a global engine
setting change. The position tolerance is the existing 0.001 m frame tolerance.

MOVE consumes current LOC observations. Full capsule sweeps, footprint support,
clearance, deliberate posture and ordinary restrictions remain authoritative.
Rounded-cap entry/exit contacts are measured rather than treating the centre ray
as the only surface. Longer observations follow actual upward contact/plane normals, independently
of uphill permission; they retain the full-shape contact-depth and footprint-height
bounds. A derived hint only reduces rediscovery work and grants no traversal
permission. Maintained unlisted 55/69-degree standing/crouched cases reproduce
the prior short-probe failure and verify stable support without granting uphill
walking.

Very short movement fragments now recover contact from the full-margin query
when `test_move` misses it. The approach prefix and redirected incline fragment
consume one gait budget. At lips, physical movement is bounded by that same
budget; CHAR activity cannot receive a float32 rounding excess. Actual physical
displacement is checked separately. Connector following counts as voluntary
surface travel, with no free stair lift or speed bonus.

The gait/RULE payload remains a fixed 15-field projection, prepared once at bind.
The 25-row source catalog is excluded from per-frame copying and validation.
LOC builds its source lookup once per preparation; point permission queries
inspect only the selected floor triangles. No adapter, native dependency,
toolchain, source archive, reference file or classic byte was changed.

## Source placement results and limits

The independent [source follow-up](IMP-012-steep-ramp-source-followup-2026-11-25.json)
retains the complete 187-block inventory and independently measures model 67025's
sixteen 0.30 m risers. It supplements the [original list](IMP-012-STEEP-RAMP-LIST-2026-11-24.md),
rather than replacing its historical source-only status.

Real LOC preparation inspects all 16 source blocks: 1,038 model occurrences and
25,369 triangles, using 247 physics bodies and 180 unique geometry prototypes.
The suite checks all 25 floor bindings, 275 full standing-capsule interior samples,
their full swept routes, 25 review spawn volumes and 50 entrance/exit surroundings.
This is block-template coverage, not a count of all instances across all dungeons.

Forty-nine stationary fitted endpoint probes are clear. The remaining upper probe
at `block-0917/record-00028` intersects the next riser of original staircase model
67025 (`record-00019`), in both postures. The regression requires that exact
ordinary obstacle to remain collidable. Four lower joins have an actual 0.30 m
height discontinuity into ordinary stairs. Two initially suspicious quest-block
joins instead continue onto another 69° ramp with no seam-height discontinuity.
Measured sloped floors are distinguished from a missing support ray or a drop.

The ordinary 0.25 m up / 0.18 m down limits remain the previously tested tuning.
No exception is extended to the neighbouring staircase. Jump/air/fall integration
or a separately reviewed tuning change remains necessary for those ordinary stair
boundaries. The source-block review makes these cases directly inspectable.
Full assembled-location routes, mechanisms, water, actors and native SAVE retain
their named owners and later integration gates.

## Verification

Fresh maintained headless and rendered checks passed with 519 and 520 assertions,
respectively, plus ten fresh-process preference checks per run. Windows debug and
release exports each passed both inventories and both reloads (1,059 assertions
per export). The current 12-adapter composition caller passed 33 checks plus 12
fresh-process checks. Real LOC assembly callers passed 1,417 + 1,136 headless and
1,437 + 1,144 rendered assertions. Exact executed-source identities, launcher
results and retained evidence are in the [machine audit](IMP-012-steep-connectors-2026-11-25.audit.json).
Development probes, failed preparations and superseded runs are excluded from
the selected acceptance count.

Four actual review-window smokes passed: all three designs and the original
`block-0917/record-00028` surroundings. Each ran 60 live frames and passed 15
assertions; none records human acceptance. The selected seven maintained runs
and four window smokes total **8,416 passing assertions**. The final full-block
smoke uses the corrected floor observation and the fresh-build selector.

The maintained matrix covers all three original designs in standing/crouched
Walk/Run/Sneak, both directions: 18 round trips / 36 directed traversals. It checks
real CHAR practice, actual posture, geometric and physical speed bounds, restored
preferences, source/shape/pose/replacement negatives, ordinary steep restrictions
and actual LOC identity. The source/placement checks use the current 12-adapter
composition and the pinned full classic corpus. Additional caller regressions,
observed timings, executed-source identities and compacted evidence are recorded
with the final audit. No unavailable check is counted as passing.

The review launcher also received a concrete build-selection fix. Previously,
archiving evidence during preparation could update an older run directory's
modification time and make it appear newest. Selection now excludes every run
that existed before preparation and chooses only a newly created passing build.
The initial smoke exposed that defect; its older-build results are retained as
development evidence rather than current-code qualification.

The full-block launch additionally exposed a review-fixture error: a clear spawn
volume was assumed to have the ramp bottom's floor height. A neighbouring landing
can differ in height. The review now observes the actual ordinary floor and sends
that sole anchor through normal MOVE validation and commitment; it does not write
an actor pose or suppress a missing-support hold. The launch smoke independently
checks actual input, movement, crouching, standing and rendered visibility.

Observed 5,000-update timings were 5.691 s headless and 5.550 s rendered; 1,000
capability queries took 15.299 ms and 15.533 ms, with 142 retained intervals.
Debug exported timings were 5.592/5.451 s and release 4.892/4.962 s for the
headless/rendered update loops. These are local observations, not new performance
budgets. Exact microsecond values and build/report hashes are retained in the audit.

Four cleanup batches compacted 25 unique owned roots, removing 39,057
reproducible files / 6,259,215,829 logical bytes. Reports, logs, reviewed captures,
typed inputs and executed-source archives were retained and hash-checked. No
follow-up-owned full project, export, dependency copy or cache remains. Before
the final batches, `.runs` measured 8,304,061,168 logical bytes (7.73 GiB); final
retention was 3,936,613,573 bytes before small documentation/audit writes. Earlier
accepted evidence and protected other-task review roots were preserved. Exact
containment, ordinary engine inactivity and reparse checks precede deletion;
installed template links were unlinked without following their targets.

All changes remain uncommitted for review in GitHub Desktop.

## PowerShell launch correction — 2026-11-25

The user-facing `powershell.exe` command started Windows PowerShell 5.1. The
user's run `verification-rendered-b5902f39d7a4470db6e2cec1caea70be` stopped before
copying the project or starting a scenario: Godot printed
`4.7.2.stable.official.ed1daf0bf`, but the process wrapper received a null exit
code. An isolated reproduction returned null under PowerShell 5.1.19041.6456 and
zero under PowerShell 7.6.9 for the same executable/version request.

The review launcher now rejects PowerShell below 7 with an explicit requirement.
The playable review documents the complete installed `pwsh.exe` command, with
process-only execution-policy bypass. Verified the old-shell guard, successful
PowerShell 7 version/exit observation, script parsing and whitespace checks.
No movement code changed or movement suite failed. The earlier machine audit
records the original qualification checkpoint; this later launcher/doc correction
intentionally changes its recorded file hashes without rewriting that checkpoint.
The compact reproduction is retained under `tests/.runs/imp012-powershell-version-probe*`;
the user failure report remains available for inspection.

## Human results - 2026-11-25

The user reports checks 1-5 PASS in all three design windows and confirms the
source-block orange ramp works. They cannot ascend the grey stairs beyond the
first lower stair; returning toward the ramp then entered the non-resumable
ground-support hold. Check 7 remains an open boundary limitation. The closed human
build is `verification-rendered-cc8b5f15a7814be586b3eae8dc2c719d`. Its log lacks
a detailed contact trace, so the exact losing-support contact is not independently
localized. Existing code holds on support loss with the increment-3 handoff
pending; the report is consistent with that limitation and the 0.30 m stairs.
No movement code or tuning changed. No overall increment or full-route acceptance
is inferred; historical machine audit remains the earlier checkpoint.
