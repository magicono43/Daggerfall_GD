# IMP-013 increment 2 — completed tavern bindings follow-up

The user authorized resolving the remaining tavern mapping and completing
increment-2 implementation/qualification. Their DFU test confirmed entry through
courtyard door #2 arrives at the rear interior entrance; immediately leaving
through that exit reaches exterior door #3. Vanilla inconsistencies are expected;
the standing source policy permits an explicit, replaceable compatibility baseline.

## Delivered behavior

TVRNBS04.RMB / place-00001 / building-0002 now declares two canonical links:

| Route | Exterior | Interior exit | Original entry marker |
| --- | --- | --- | --- |
| tavern-front | door #1, record00150 plane36 | record00200 plane2 | record00274 |
| tavern-rear | door #3, record00150 plane46 | record00203 plane2 | record00271 |
| tavern-courtyard | door #2, record00150 plane41 | entry alias of tavern-rear | record00271 |

The alias retains door #2 as the selected entrance and returns door #3 as the
canonical return destination. It shares the same building-scoped interior and
rear landing. Each actual interior exit retains its independent canonical route;
entry never rewrites that route. Selecting an alias as an exterior arrival fails
`entry_only`, retaining the valid prior scene. An arrival cannot be retargeted.

DATA validates a four-field alias (`id`, `exterior`, `entry_alias_of`, `provenance`)
pointing directly to a canonical link. Missing targets, chains, cycles and duplicate
exteriors reject publication. LOC resolves aliases in a second pass, checks the
actual exterior model plane and exact payload/model/pose/building guards, and
publishes atomically with the canonical bindings. Reordered declarations retain
the same destinations. Interior door metadata is assigned only by canonical links.

All three visible tavern exterior doors and both actual interior exits are bound.
The two house pairs remain bound, giving all five exterior static doors in the
fixture valid entrance definitions. Entry markers00272/00273 remain unbound and
identifiable; all four entry and five rest marker records/roles remain unchanged.
No geometry, source byte, original marker position or role was changed. The
investigated corridor-model replacement was not adopted.

## Source observations and provenance

The independent scalar observer now pins four canonical pairs plus one entry
alias. Door apertures remain 1.25 by 2.25 metres. After subtracting the tavern's
parent, both canonical exterior-to-interior centre differences are exactly
`[0,0.05,0.15]` metres with opposite normals. The two house observations retain
their previous 0.15 m separation checks. This is source geometry evidence, not
actor clearance or a new matching tolerance.

The alias's behavior is a documented user-observed DFU compatibility choice.
Read-only DFU code explains the separate nearest-entry/rest/door and exterior-door
fallbacks; none becomes a runtime selection policy here. Original-executable
behavior is not claimed. Shipped declarations remain complete replaceable DATA
definitions with MOD/loose precedence and exact source guards. Existing classic
data provenance and DFU MIT licensing apply; no third-party code was copied.

See [the source investigation](IMP-013-TAVERN-INVESTIGATION-2026-11-24.md),
[the contract](../../../main_project/scripts/loc/LOCATION_DOORWAYS.md), and
[the review captures](IMP-013-DOORWAYS-REVIEW-2026-11-24.md).

## Verification

All six final commands pass on Godot 4.7.2, with the same frozen 107 runtime/test/data
files, including 101 production GDScripts. The independent observer reproduces
byte-for-byte. The declared scenario inventory's separate 24-check policy passes.

| Qualification | Primary / fresh-process assertions | Owned run |
| --- | --- | --- |
| Headless location | 1296 /1136 | verification-headless-3ee36f3b15dc4841a058ba7b6b12a5e2 |
| Rendered location | 1313 /1144 | verification-rendered-bb64aa0d678c4db08f3e321eecbdfa89 |
| Windows debug export | headless1296 /1136; rendered1313 /1144 | export-b678383150d14f3d90bb83dd9275bf4d |
| Windows release export | headless1296 /1136; rendered1313 /1144 | export-9497073602d54f6db6a4b50235b09ead |
| Headless dungeon markers | 2277 /35 | verification-headless-df4108e613784f3caa597dcb46a655a0 |
| Headless layout inputs | 369 /15 | verification-headless-d42a3e5af19f4fd6aba21b46df5610ae |

Reports and source/build hashes are recorded in the
[machine audit](IMP-013-TAVERN-BINDINGS-2026-11-24.audit.json). Reproduce the four
location/export commands from the review page, then run headless `dungeon-markers`
and `layout-inputs` with their `*-v1` fixture IDs and the same pinned classic source.
All heavy commands ran sequentially. The pre-existing Windows certificate-store
diagnostic remains explicitly tolerated by the existing runner; filtering was not
weakened. Ground-UV, literal native poses and retained unknown-action/axis policies
remain covered by the location and affected regression suites.

One initial headless attempt exposed a test
expectation error: an already selected rear arrival correctly rejected a query
for the alias as `route_mismatch`, before the alias-direction check. The maintained
test now asserts both original-route protection and `entry_only` on an independent
inspection request. Runtime behavior was correct; the assertion was corrected.

The full current DATA composition still uses ten validator adapters. In the final
headless run, intake/preparation/projection measured 12.008253 s /14.953178 s
/702.759 ms (prior qualified snapshot: about 12.206 s /15.456 s /777.194 ms).
The unchanged 64-occurrence native fixture has 128 models, 128 physics bodies and
48,512 triangles. Headless unbound/bound assembly measured 1.128927 /1.320823 s;
rendered measured 1.154762 /1.324878 s. Binding preparation measured 136.399
/135.344 ms, and 1,000 narrow queries took 121.931 /118.026 ms. The prior bound
headless fixture measured 1.339129 s, preparation 136.642 ms and queries 122.463 ms.
One block decode is reused. These are observations of the complete fixture, not
invented performance budgets or a claim of an optimization.

## Changed files and retained evidence

The follow-up extends `scripts/data/location_doorway_schema.gd` and the existing
`scripts/loc/location_assembly.gd`; publishes the guarded tavern declarations in
`content/layouts/location_assembly.json` with its new DATA hash pin; and updates
the independent observer, source observations, maintained doorway scenarios and
declared inventory. The earlier maintained tavern visual inspection remains in
`tests/location_cases.gd` and the inventory builder. Owner/DATA/provenance
contracts, task/readiness/backlog/dependency/milestone notes and review evidence
now describe the resolved mapping. The machine audit lists the complete current
uncommitted increment-2 file set. No commit, push or branch change was made.

Eight inactive owned roots were compacted after terminal-report, ordinary
activity/path/reparse checks. Removed 12,191 files /2,336,073,103 logical bytes;
134 child evidence files were retained and hash verified. A redundant 8,927,776-byte
whole DFU catalog diagnostic dump was removed after preserving the relevant compact
template. The journal is losslessly compressed and round-trip verified. All
31 classic source hashes and 1,317 protected earlier human-review hashes match.
No follow-up full copied project/export/cache remains. Regular logical `.runs`
retention measured 2,402,580,558 bytes (about 2.238 GiB), excluding reparse traversal
and before final summary rewrites; earlier protected state/other-task evidence is
the retained baseline. Exact cleanup roots, hashes and measurements are in the
machine audit. The six earlier source-inspection captures match the final rendered
output byte-for-byte; both new canonical landing captures were also reviewed.

## Completion boundary

Increment-2 implementation and required automated/rendered/export qualification
are complete and ready for user acceptance. No unresolved tavern binding remains
in the supported fixture. Increment-2 user acceptance remains pending.
Full MOVE actor-shape validation,
bounded pose correction, commitment and transition completion remain increment 3.
Real WORLD/gameplay/access/SAVE providers, full story entry and parent IMP-013/M2
remain open. Neither the user's DFU comparison nor rendered source inspection
claims those integrations.
