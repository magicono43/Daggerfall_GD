# IMP-013 increment-2 doorway review

Increment-2 user acceptance is pending. These captures inspect prepared geometry
and bound marker/exit identities. They do not demonstrate actor traversal,
clearance, committed placement, native SAVE or parent IMP-013/M2 completion.

Gold outlines identify original static exit planes. The sphere is the exact
marker anchor and the one-metre line shows its declared unit facing. Labels name
the local marker and original plane. Overlays remain visible through occluders;
they do not establish an unobstructed actor path. The source room geometry is
the existing baseline, with no wall cutting or pose correction added here.

## Classic home-east

Building-0000, exit record-00004/plane16, entry199/8 record-00033.
Source anchor `[4.8,0,-1.6]`, inward baseline facing `[-1,0,0]`.
The exact exterior return is record-00000/plane0, independently observed model549.

![Classic east doorway](../../../main_project/tests/.runs/imp013-doorway-review-2026-11-24/classic-east.png)

## Classic home-north

Building-0001, exit record-00089/plane4, entry199/8 record-00116.
Source anchor `[1.6,0,4.8]`, inward baseline facing `[0,0,-1]`.
The exact exterior return is record-00088/plane0, model546.
Facing is an authored baseline, not original executable verification.

![Classic north doorway](../../../main_project/tests/.runs/imp013-doorway-review-2026-11-24/classic-north.png)

## Native front/back, shared instance

Both views belong to `a-suite` in the same authored hall. Front selects
marker-front / exit-front / facade-front. Back selects marker-back / exit-back /
facade-back independently of which entry was selected earlier. Back's texture199/4
retains rest and gains explicitly verified entry use; it is not globally promoted.

![Native front doorway](../../../main_project/tests/.runs/imp013-doorway-review-2026-11-24/native-front.png)

![Native back doorway](../../../main_project/tests/.runs/imp013-doorway-review-2026-11-24/native-back.png)

The back anchor/facing are independently asserted as `[-4.8,0,-11.2]` / `[1,0,0]`;
its exterior desired anchor is `[-7.4,1.125,-11.825]`. These are LOC anchor facts,
not MOVE actor poses. A second instance reuses the same block template with its
own identity and rotated exterior. Reordered occurrences retain destinations.

## Tavern follow-up

The tavern follow-up binds the front and rear source exits without changing
geometry. Courtyard door #2 explicitly uses the rear landing shown below; its
selected entrance remains #2 and the actual rear exit returns outside #3. See
[follow-up evidence](IMP-013-TAVERN-BINDINGS-2026-11-24.md). The source marker
anchors lie at aperture edges; these overlays do not certify actor clearance.

![Tavern front landing](../../../main_project/tests/.runs/imp013-tavern-review-2026-11-24/tavern-front.png)

![Tavern rear landing, also used by courtyard entry](../../../main_project/tests/.runs/imp013-tavern-review-2026-11-24/tavern-rear.png)

The [numbered source overview](../../../main_project/tests/.runs/imp013-tavern-review-2026-11-24/door-positions.png)
identifies doors #1/#2/#3. Entry markers00272/00273 remain retained and unbound.
The compact manifest records capture hashes and the explicit alias relationship.

## Reproduce

Run sequentially from the repository root with Godot4.7.2 and the pinned source:

```powershell
./main_project/tools/verify_headless.ps1 -Suite location-assembly -Fixture location-assembly-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
./main_project/tools/verify_rendered.ps1 -Suite location-assembly -Fixture location-assembly-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
./main_project/tools/verify_startup_export.ps1 -Configuration debug -LocationAssembly -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration release -LocationAssembly -ClassicSource C:/Games/Daggerfall/arena2
```

The rendered fixture launches through normal startup/DATA/CORE/session composition
with disposable storage. It writes these labelled captures along with the existing
exterior/interior views. The native close-ups replace an earlier overview whose
labels were too small. Final checks and exact run identities are in
[execution evidence](IMP-013-increment-2-2026-11-23.md). Full copied builds are
removed after qualification; authoritative fixtures and compact captures remain.
