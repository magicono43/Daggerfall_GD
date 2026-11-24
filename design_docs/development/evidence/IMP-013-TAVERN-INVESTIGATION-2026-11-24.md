# IMP-013 tavern binding investigation

Follow-up to the user's request to resolve the unqualified tavern before
increment-2 acceptance. Investigation remains in progress; no corrective geometry
or new tavern binding has been published by this follow-up.

## Visible doors and unused markers

A new maintained rendered inspection uses the normal startup/session composition
and production LOC requests. It renders all three exterior surfaces separately,
both static interior exits, and the interior wall opposite the middle courtyard
door. `verification-rendered-12577dffeb904831a9244c08b79e0d7f` passes **1266 primary
/1108 fresh-process checks**; its extra nine checks cover inspection/captures.
This is source inspection, not completed tavern binding or actor placement.

All three exterior planes are visibly door-textured. Planes36/41 face each other
across the small courtyard; plane46 is on the outer rear wall. Their centres are
`[64.975,1.175,-48]`, `[69.425,1.175,-41.6]` and `[64.975,1.175,-35.2]` in the
current local metre frame. The first two are **7.80 m apart**, not coincident.

![Numbered source positions](../../../main_project/tests/.runs/imp013-tavern-review-2026-11-24/door-positions.png)

The interior has visible static exit models31529/31530 at record-00200 and
record-00203. The corresponding inside position for exterior plane41 is a plain
wall in model31524 / record-00206. Its four original entry markers do not prove
four doors. Two outlying entry markers may simply be unused; no doorway should
be created merely to satisfy marker count.

Read-only DFU evidence agrees with the inventory: editor
`Persisted/DefaultBuildingsCatalog.json`, template0815, uses exterior model626
with the same 85 interior models and only those two static exit models. DFU's
`PlayerEnterExit.BuildingTransitionExteriorLogic` selects the closest exterior
door to the player's current position. `TransitionInterior` separately uses the
nearest entry/rest marker and then nearest interior static door. These are not
explicit per-door bindings and do not prove the intended link.

The user confirmed that entering courtyard door #2 arrives at the rear interior
entrance; immediately using that interior exit returns outside door #3 on the
outer rear wall. The approved follow-up adopts an explicit entry-only alias to
that already valid rear landing. Each actual interior exit retains its own
canonical exterior destination. This records the user's DFU observation, not
verification against the original executable or proof from nearest-marker distance.

## Concrete geometry comparison

The source editor categorizes model31524 as a three-way corridor and model31530
as a three-way corridor with an exit. Independent scalar model-byte comparison
finds a geometrically precise candidate: replace record-00206's model31524 and
yaw512 with model31530 and yaw0, retaining source position `[64,-63,-195]`.

Both transformed bounds are exactly `[0,0,3.35]` to `[3.2,3.15,6.4]` metres.
Seven polygon geometries match; the floor keeps the same boundary with extra
collinear vertices, and the closed wall is subdivided around a 1.25×2.25 m door.
Its centre would be `[2.225,1.125,3.35]`, directly opposite exterior plane41's
building-local `[2.225,1.175,3.2]`. Other openings and the footprint align. Four
unchanged wall geometries use different source texture records in the exit
variant, which must be accounted for in any adopted correction.

This is a candidate baseline repair, not a DFU-shipped fix or original-executable
behavior claim. Its detailed raw/transformed polygons and model hashes are in
the compact review folder's `geometry-comparison.json`, with `applied=false`.
The geometry replacement was not adopted: the confirmed explicit alias resolves
the required behavior without changing geometry or unused original markers. MOVE clearance,
pose commitment, SAVE and parent IMP-013/M2 remain outside this inspection.

## Locations for comparison

Direct read-only MAPS.BSA inventory finds 21 uses of TVRNBS04.RMB. The exact
fixture site is **The Flying Goat Hostel, Alik'r Desert**, a single-block map
destination (place-00001). **The Crimson Sword Lodge, Sentinel** (place-06300) is
another single-block example. These are verified map-site names, not inferred
MAPS building-name/door-pool associations. Full location/grid references are in
the compact `tavern-sites.json` observation.
