# IMP-061 increment-1 assembly review

Status: **user visual review PASS, with gray-box visibility caveat; increment 1 explicitly accepted** (2026-11-23). This is geometry review,
not a gameplay walk-through. No actor, arrival, action, SAVE or later context policy
is claimed. Existing input/controller/IME acceptance is not reopened.

## Disposable review fixture

```powershell
./main_project/tools/verify_rendered.ps1 -Suite dungeon-assembly -Fixture dungeon-assembly-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
```

This uses disposable storage, all ten adapters, real DATA/media and the production
LOC owner under checked CORE scope. A fixed test camera provides reproducible
captures, not another input/view implementation. Fresh-process reconstruction
repeats views from the shipped annotation. No full review build needs retention:
static captures and exact build hashes support this review. Independent actual
Jolt/continuous-support assertions establish collision evidence, not the images.

Final editor captures are under
`main_project/tests/.runs/verification-rendered-245bed27ae9840bab6956b70f2f77d10/evidence/project/scenario-1/`:

| Check | File | Expected | User result |
| --- | --- | --- | --- |
| Overview | [assembly-overview.png](../../../main_project/tests/.runs/verification-rendered-245bed27ae9840bab6956b70f2f77d10/evidence/project/scenario-1/assembly-overview.png) | Coherent multilevel central dungeon; original border components and unused separated pieces retained. | PENDING |
| Lower seam | [assembly-seam-lower.png](../../../main_project/tests/.runs/verification-rendered-245bed27ae9840bab6956b70f2f77d10/evidence/project/scenario-1/assembly-seam-lower.png) | Continuous visible passage and consistent floor/wall orientation across the central adjacency. | PENDING |
| Upper seam | [assembly-seam-upper.png](../../../main_project/tests/.runs/verification-rendered-245bed27ae9840bab6956b70f2f77d10/evidence/project/scenario-1/assembly-seam-upper.png) | Upright stair approach and joined passage, without inverted steps or missing seam geometry. | PENDING |

The agent inspected these exact final images: the overview retains all components,
the lower view shows a continuous hallway and the upper view shows upright stairs.
That earlier agent observation did not establish user PASS. The machine-readable audit records capture hashes and
source/build identities. Neutral inspection materials do not select LOC-010
texture/story policy.

`seam-lower` and `seam-upper` are retained fixture/socket labels, not logical
story selection: their fixed camera heights in the named engine frame are
33.4 m and 14.2 m respectively. Engine +Y points upward. The independently
checked connector heights/transforms, rather than these diagnostic names,
govern geometry checks; floor/story semantics remain increment 2.

## Source placement cross-check

`place-00032`, Ruins of Cyeghtan Manor, source grid X/Z:

| Occurrence | Block | Grid |
| --- | --- | --- |
| 1 | B0000010 | (-1, 0) |
| 2 | B0000001 | (0, -1) |
| 3 | N0000083 | (0, 0) |
| 4 | B0000010 | (0, 1) |
| 5 | B0000011 | (1, -1) |
| 6 | N0000077 | (1, 0) |
| 7 | B0000010 | (1, 1) |
| 8 | B0000000 | (2, 0) |

One grid unit is 51.2 m; classic +Z maps to Godot -Z. Independent observations pin
every record, expected model bounds and required path. Fourteen connections
qualify two levels over seven adjacencies. Border-to-border contact deliberately
does not imply a required passage. Conditional doors remain closed live; only
their declared open-condition validation probes exclude their collision.

## User results — 2026-11-23

The user reviewed the supplied images and performed a flythrough of the same
dungeon in DFU, reporting:

> I checked the images, and did a flythrough of the dungeon in question inside DFU. I think the images you provided seem to be assembled properly, it is difficult to tell with the gray-box lighting and modeling, but I would say it seems correct.

This satisfies the overall visual assembly sanity check with the stated visibility
caveat. The three PENDING entries above are the original checklist; the user gave
an overall assessment, not separate seam measurements or per-image results.
No exact visual parity, collision, actor placement or gameplay-state qualification
is inferred from this report. Automated checks remain the collision/source evidence.
The user subsequently stated, **"I accept what you have done in increment 1"**,
and requested the increment-2 handoff. Increment 1 is complete and user-accepted.
The [increment-2 prompt](../handoffs/IMP-061-INCREMENT-2-PROMPT.txt) is prepared;
issuing it in the destination chat authorizes increment 2 only. Preparing it
starts no implementation here. The automated audit's
human-pending status is the preserved pre-review snapshot, superseded by this report.

MOVE/arrival, native
SAVE/QUEST/action restoration, exterior return, swimming and edited variants
await named real-provider checks. IMP-061/M2 remain open; increments 2/3 require
separate authorization.
