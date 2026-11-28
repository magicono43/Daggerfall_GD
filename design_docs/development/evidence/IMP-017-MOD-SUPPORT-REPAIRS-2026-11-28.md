# IMP-017 — Mod support review repairs, 2026-11-28

**Acceptance follow-up:** The user subsequently considers IMP-017 completed,
including these repairs. See [parent acceptance](IMP-017-ACCEPTANCE-2026-11-28.md).
Delivery-time pending-acceptance fields below retain their historical scope.

Status: **implemented and targeted-verified; F1/F2 repaired; user review open**. Parent/user acceptance
and the existing real-owner/SAVE/room/M2 gates remain open.

Started **2026-11-28 02:56:03 EST (UTC−05:00)**. Baseline HEAD:
`c4897dc1df96bb63fe09d1a14a0db479057709a4`. Existing uncommitted review documentation
was preserved. The user authorized the two proposed corrections with “Alright,
give it a go.” No later Implementation task, branch operation, commit, push,
chat or subagent was started.

Completed **2026-11-28 03:27:13 EST (UTC−05:00)**; elapsed **31 minutes 10 seconds**.

## Changes

**F1:** Construction DATA validation reserves category key `semantic` in both
policy categories and template style maps. It reports a specific invalid-content
reason before publication. Supported added categories continue through the
existing property and appearance adapters. The maintained construction fixture
now rejects a real package using the reserved policy key, checks atomic rejection
of a reserved template style map, repairs the pending package, and publishes a
`custom-plate` category. Construction, recalculation, a supported dye request and
authorized copy all use the actual ITEM owner.

**F2:** Nonmonetary semantic restore records must match the semantic intake
representation: kind equals stack type, stack identity, no constructed body or
visual projection, exact microkg weight boundary, and the same bounded per-unit
properties/key rules used at intake. The property validator is shared by intake
and restore. A resolved stack policy must be a type contract before validating
its state. Monetary representation and constructed-item reference checks retain
their existing paths.

The maintained persistence fixture includes the original malformed constructed
record disguised with the semantic sentinel, plus contradictory semantic kind,
identity, appearance, property range/key, weight precision and policy-kind cases.
Rejected preflights preserve the input, live ITEM store and outgoing scope.
A mod-published `charged` type carries three units, contents, per-unit charges,
knowledge, provenance and custom physical properties through real ITEM intake,
collection admission, capture, replacement hydration and separate-process reload.
Explicit callback counts prove hydration/reload does not replay intake.

No representation/schema migration, new mod API, executable provider loader,
gameplay rule, native adapter or source-data change was introduced. Existing
legitimate semantic records already satisfy the enforced intake contract.
Definitions using the conflicting category now require an author correction;
there is no silent rename or saved-record conversion.

Affected contracts: [construction](../ITEM_CONSTRUCTION_CONTRACT.md),
[collections](../ITEM_COLLECTIONS_CONTRACT.md),
[persistence](../ITEM_PERSISTENCE_CONTRACT.md).
The [original review](IMP-017-MOD-SUPPORT-REVIEW-2026-11-28.md) retains the defect
reproductions and review-time evidence.

## Verification

**1,886 assertions passed across eight commands.** Final evidence and exact
command/report/source/archive hashes are recorded in the
[companion audit](IMP-017-MOD-SUPPORT-REPAIRS-2026-11-28.audit.json).
All heavy suites/exports ran sequentially.
Windows/Godot target: `4.7.2.stable.official.ed1daf0bf`; classic source:
`C:/Games/Daggerfall/arena2`, with maintained read-only source guards.

| Selection | Passing assertions | Owned report root under `main_project/tests/.runs/` |
| --- | --- | --- |
| Headless construction | 134 | `verification-headless-c79c22c1d0214b7e8dc2841458b383d5` |
| Rendered construction | 136 | `verification-rendered-ce6bbb0f356e42c795557cd85a50ee77` |
| Headless persistence + fresh process | 159 + 39 | `verification-headless-7ada3b5ed4dd4561bd245712b2d7bd4d` |
| Rendered persistence + fresh process | 163 + 43 | `verification-rendered-b9fedb02ecdb4f1aab2d131c0692dcc0` |
| Headless collections | 200 | `verification-headless-dc544e1674644bbcb92c652c2e02dc65` |
| Rendered collections | 204 | `verification-rendered-5196914988e541cbb95086ca061a806d` |
| Windows debug persistence export, both modes + fresh processes | 404 | `export-19fdf76af4494744b496d0cc9ad8bc87` |
| Windows release persistence export, both modes + fresh processes | 404 | `export-f860fb026a35450a9e3a84f3e0d0b7f4` |

Maintained reproduction commands use PowerShell 7 from the repository root:

```powershell
& ./main_project/tools/verify_headless.ps1 -Suite item-construction -Fixture item-construction-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
& ./main_project/tools/verify_rendered.ps1 -Suite item-construction -Fixture item-construction-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
& ./main_project/tools/verify_headless.ps1 -Suite item-persistence -Fixture item-persistence-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
& ./main_project/tools/verify_rendered.ps1 -Suite item-persistence -Fixture item-persistence-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
& ./main_project/tools/verify_headless.ps1 -Suite item-collections -Fixture item-collections-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
& ./main_project/tools/verify_rendered.ps1 -Suite item-collections -Fixture item-collections-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 240
& ./main_project/tools/verify_startup_export.ps1 -Configuration debug -ItemPersistence -ClassicSource C:/Games/Daggerfall/arena2
& ./main_project/tools/verify_startup_export.ps1 -Configuration release -ItemPersistence -ClassicSource C:/Games/Daggerfall/arena2
```

All four changed production inputs match the final candidate in every owned
runtime. Headless construction copied earlier, unexecuted persistence fixture
inputs; the headless persistence run predates refinement of one negative case to
use a retired, unique in-range item ID. The final rendered run and both export
modes execute that refined input. Executed sources are retained independently;
none of these fixture variants is represented as byte-identical final source.
The audit records their exact differences and scopes.

Rendered construction and both persistence-process captures were inspected:
legible opaque diagnostics, focused inspection control, 509 possessions, two
distinct stash stacks and carried load 300. Automated checks/input do not establish
physical-device or playable inventory acceptance. The new custom semantic state
is independently asserted through owner projections, rather than inferred from
the count display. The known host root-certificate-store diagnostic is unchanged;
the maintained diagnostic filters reported no unexpected script errors.

An initial persistence attempt stopped at the new semantic intake assertion:
its fixture had assigned a clothing template override to the charged grant's
construction profile. The negative policy-kind case was moved to the arrow
profile, preserving the intended type bindings. No implementation assertion was
weakened and no production change was needed for that fixture correction.
Its failed report and executed sources are retained separately from passing runs.

The prior 17,233-assertion/32-command final Implementation checkpoint remains
historical evidence in its accepted scope; it is not relabeled as a new run or
added to this repair's fresh assertion total. Broader unrelated suites need no
repeat for these ITEM-local changes. Complete native SAVE orchestration,
full-room restore/Session Restored, live equipment/effect/quest/service/loot/
trade/bank/spatial providers, native actor identity and M2 remain separate gates.
Controlled providers in these fixtures do not close those integrations.

## Cleanup and disposition

Compacted all **nine exact owned run roots**, including the failed development
fixture, after every owned runner returned. Removed **16,463 files /
2,536,059,789 logical bytes** of copied projects, exports, native/bank copies and
caches. Every retained executed-source ZIP entry was independently hash-verified
first. Reports, fixture inputs, checkpoints, logs and reviewed captures remain at
their original child paths; per-root `IMP017-MOD-REPAIR-COMPACTION.json` records
exact deletion/retention manifests and hashes. Both installed-template junctions
were unlinked without traversing or modifying their targets.

Non-elevated activity, absolute containment and no-reparse checks guarded cleanup.
No full copied build remains. External classic/reference data, active mods,
installed tools, unrelated work and earlier run roots were protected. The existing
global >8-GiB retention review remains recorded in the cleanup guide; this bounded
repair performed no global storage/history or allocated-size scan. These deletion
totals are logical bytes, not a physical-allocation claim.

F1/F2 are repaired and verified, with user review/parent acceptance still open.
All changes remain uncommitted for GitHub Desktop review. The useful optional
human check is the maintained rendered persistence command above: inspect its
primary and fresh-process diagnostics and the retained owner outcomes. Automated
input does not claim physical-device acceptance.
