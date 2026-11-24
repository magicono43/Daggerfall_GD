# IMP-013 increment-1 assembly review

**Ground UV review follow-up:** User review exposed reversed tile imagery. The
[follow-up evidence](IMP-013-ground-uv-2026-11-23.md) records its correction,
independent orientation checks and replacement captures. Earlier results below
retain their exact historical snapshot scope; acceptance remains pending.

Review scope: geometry/collision assembly and detached metadata only. User
acceptance remains pending. These captures use the production LOC owner and real
classic/model/material resources under the maintained controlled-session fixture.
They provide no playable actor, entrance transition, owner restore or native SAVE.

## Captures

![Classic RMB exterior](../../../main_project/tests/.runs/imp013-review-2026-11-23/exterior.png)

`place-00001` / `TVRNBS04.RMB`, complete one-block exterior: all 9 source models,
source building placements and 256 ground tiles. The declaration explicitly
selects desert ground archive 2. Miscellaneous props use the source-specific
block origin and documented DFU Y offset. WORLD terrain outside this block is
pending; no replacement terrain or unrelated room supplies readiness.

![Classic building interior](../../../main_project/tests/.runs/imp013-review-2026-11-23/interior.png)

The same block's `building-0000`, interior instance `suite-alpha`. Models, floors,
walls, furnishings and closed action doors use the independent interior frame.
Exterior placement/building-parent transforms do not displace these interior
records. The camera shows actual geometry using ordinary face culling; no required
model, ground or door was deleted to obtain a capture or a readiness result.

Agent review found these captures readable and corrected the earlier misc-prop
origin error. This records agent visual QA, not the user's review or acceptance.
Capture SHA-256, source run/build and engine identity are retained in the adjacent
machine audit and `main_project/tests/.runs/imp013-review-2026-11-23/review.json`.

## Reproduce on Windows

From the repository root, run one command at a time:

```powershell
./main_project/tools/verify_headless.ps1 -Suite location-assembly -Fixture location-assembly-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
./main_project/tools/verify_rendered.ps1 -Suite location-assembly -Fixture location-assembly-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
./main_project/tools/qualify_location_inventory.ps1
```

Each suite creates disposable storage and reports its exact GUID run root. The
rendered primary saves `location-exterior.png` and `location-interior.png` under
`project/tests/.runs/scenario-1/`. Open those images and the terminal report for
the newly reported run. The renderer and headless processes are independent;
fresh-process reconstruction is tested separately inside each selection.

For the delivered exported slice:

```powershell
./main_project/tools/verify_startup_export.ps1 -Configuration debug -LocationAssembly -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration release -LocationAssembly -ClassicSource C:/Games/Daggerfall/arena2
```

The stock application still reports unavailable gameplay services. Review does
not require using a fake ready menu, entering another location, moving an actor
or accepting a later increment. Read [execution evidence](IMP-013-increment-1-2026-11-23.md)
for exact outcomes, scoped limits, named integration obligations and cleanup.
