# IMP-061 — classic dungeon action-axis follow-up

**Subsequent acceptance, 2026-11-23:** The user accepted increment 3 and approved
IMP-061 complete after satisfactory image review. See
[acceptance evidence](IMP-061-ACCEPTANCE-2026-11-23.md). The machine audit retains
its pre-acceptance execution status; unavailable integrations are not human passes.

User authorization, 2026-11-23: resolve the remaining axis problem here; vanilla
dungeon blocks should not be rejected. This extends the approved structural DATA
import policy and preserves the increment-3 marker boundaries. Changes remain
uncommitted. It does not close IMP-061/M2 or begin another implementation task.

## Source finding and resulting behavior

The earlier axis rejection was an overly strict recreation decoder restriction,
not proof that the classic block was structurally corrupt. All nine remaining RDB
rejections had that same cause. An independent scalar observer finds 11 affected
motion-action records across those blocks. N0000007's model 54000/tag TRP at source
address 15030 has translation kind 1, axis 11, duration 180, magnitude 1782 and
absent target -2. Its separate flat at address 20251 has unknown kind 27.

Read-only DFU evidence is `Assets/Scripts/Utility/RDBLayout.cs`, methods
`GetRotationActionVector`, `GetTranslationActionVector` and `AddAction`, and
`Assets/Scripts/API/DFBlock.cs` axis definitions. Generic out-of-enum motion axes
leave the constructed vector at zero. Rotation on TRP/axis 13 specifically uses
NegativeX and magnitude 400, with the source's magnitude 392 left unchanged in
the retained raw parameters. DFU's later LID/WHE overrides exist, but none of the
11 inventoried records has those tags. No universal masking operation is inferred.
The existing retained DFU MIT license applies to reference evidence. No library,
native adapter, AV, engine or toolchain dependency changes are introduced.

DATA now retains recognized `action` and required links, annotating exceptional
axes with `classic-action-axis-metadata-v1` / `action_axis_metadata`. It records
the complete original parameters and applicable DFU interpretation with
`gameplay_owner_ready=false`. DATA does not execute motion. This differs from
unknown action kinds, whose outgoing executable edge is omitted and whose entire
payload remains in `unused_action`. Missing required targets still reject known
actions, including exceptional-axis actions. Authored mod motion axes retain the
explicit enum validator; arbitrary authored semantics are not silently enabled.

DATA projections expose `action_axis_owner_ready` and
`pending_action_axis_records`. LOC retains detached pending bindings through
preparation/publication and reports readiness/count in marker handoffs. Geometry
preparation and source import do not certify action execution or owner state.

## Complete corpus and identities

All **187/187 RDB** and **920/920 RMB** blocks in the pinned source edition now
structurally decode. The 187 RDI archive entries are auxiliary unknown-format
data, documented by DFU `DFBlock.BlockTypes.Rdi` as unsupported/ignored; they are
not RDB dungeon geometry. The extensionless archive entry is also not a supported
layout. No source files are modified and no malformed-data check is waived.

New profile SHA-256:
`1856fd83d96f96505091b540e9c3d78ffb9e5be8b9fa96a670860770f1f86b23`.
Previous profile:
`fd562348b60af17df54ddbe33b393fcd239aeb3e9b6e2bd1d1aaa844ac9ff00f`.
All **618,798** prior object IDs and all building/location/placement mappings are
preserved exactly. Only N0000007's previously empty ledger gets **307** new record
IDs, for **619,105** reserved keys. Eight other formerly rejected blocks already
had reserved keys. The authoring flag permits new allocation only for an empty
ledger with the exact prior axis diagnostic, within the pinned source edition.

All **13/13** unknown action records now reside in supported blocks and are
retained non-executing. All **11/11** exceptional known-motion records retain
their action kind/parameters and pending interpretation. Source hashes remain:
BLOCKS `6f5a4c8d9401c1b00ef83eaac9b0c6c32f53cef6eaa4c7d7027deb739bde4795`;
MAPS `8b5550bfcac03b6f605842568fdbfb7cc6bbed7ace5999c33c900ad286fc24be`.

## Verification and regression boundary

`observe_dungeon_action_axes.py` independently walks source enumeration chains,
inventories all 187 block record counts and the 11 exceptional records, and pins
payload hashes without calling production decoders. The maintained
`classic_action_axes_audit.gd` passes **808** unique checks, including complete
source counts/hashes, stable IDs, original parameters/model tags, known graph
retention, pending interpretation, and required-target rejection. The updated
unknown-action audit passes **473** unique checks. Its earlier 478 included nine
now-obsolete rejection checks and four fewer checks for N0000007's unknown record.

Normal marker production tests add 20 unique scenarios: DATA decodes all nine
formerly rejected blocks with correct pending counts; LOC prepares actual
N0000007 geometry and retains both exceptional-axis and unknown-action bindings.
The original assembly fixture named `unsupported-axis` expected a source rejection.
It now correctly stages both blocks, then rejects its unrelated synthetic walk
support declaration. Renamed `unqualified-axis-connection`, it retains failure,
prior-destination preservation and staging-release assertions. Only those five
inherited scenario names change in the assembly/context/marker inventories;
their counts and connection requirements remain intact. This follows the actual
new source qualification rather than retaining an obsolete expected rejection.

Final independent suite/export outcomes, hashes, performance and cleanup are
recorded in the [machine audit](IMP-061-classic-action-axes-2026-11-23.audit.json).
The two first production attempts caught only that old fixture expectation; they
remain failed attempts in the audit, never retroactively counted as passes.
The existing Windows editor certificate-store diagnostic remains visible in
standalone audit output; no diagnostic filter or runner acceptance rule changed.

Final commands all pass on Godot 4.7.2 `ed1daf0bf`:

| Check | Primary / fresh-process assertions | Retained run ID |
| --- | --- | --- |
| Headless markers | 2277 / 35 | `verification-headless-cabb469a90174f66acb04a89ed9ad836` |
| Rendered markers | 2292 / 41 | `verification-rendered-4d674f1113224460b8d4353352a79d26` |
| Headless layout regression | 369 / 15 | `verification-headless-b7a92cdf43024ab69c0ed3db10e20cf0` |
| Rendered layout regression | 372 / 15 | `verification-rendered-5c44d2b97b1546b9b28e843fe1807e73` |
| Windows debug export | Headless 2277/35; rendered 2292/41 | `export-4266fcc05b724ea4979a2e2fd88ad96a` |
| Windows release export | Headless 2277/35; rendered 2292/41 | `export-bedbe5a031d048eeb167b735959cfb23` |

Both exports match all **98 current production GDScript hashes**. Their PCK hashes
are debug `7C4F555E2044898323B12C16238F9055AEB3BF3720029DE4603945160CEC160E`
and release `9642D26816B66A71AD42227D2DC9853AB28251C3C1A001BD5426461D62E43A17`.
Native/runtime hashes and exact commands remain in the audit/raw reports.
Strict inventory qualification passes 20 complete/missing/duplicate/unknown/
wrong-fixture vectors across both primary and reload modes. A temporary validation
invocation used the wrong reload property spelling; correcting that invocation
required no product or runner change. Variant/M1 full suites were not rerun for
this DATA-only follow-up; their earlier results remain prior evidence, not new
passes. The marker suite still includes the inherited assembly/context checks.

Complete ten-adapter preparation measures 14.299/14.128 seconds headless/rendered
versus the prior 13.968/13.410 seconds. The unchanged 64-block stress case retains
10,304 model instances, 1,088 bodies, 204,928 triangles, one block decode and
58 unique model/resource builds. Stress assembly measures 3.772/5.603 seconds;
1,000 marker queries take 150.564/146.476 ms (prior 146.207/147.721 ms).
Full primary static peaks are 3,172,176,976/3,250,587,949 bytes versus the earlier
3,171,966,810/3,250,350,799 bytes. Commands overlapped on the same host; these are
observations, not a new budget or speedup claim. Godot static memory excludes
GPU/driver/process RSS. No capacity, acceptance threshold or diagnostic rule
was increased to obtain a pass.

## Cleanup

All eight explicitly owned follow-up run roots finished before ordinary
non-elevated activity/path/reparse checks. The standard cleanup tool removed
12,131 reproducible payload files / 2,323,584,977 bytes and retained 115 child
reports/logs/captures with verified hashes. No follow-up full build remains.
The cleanup journal was losslessly compressed from 2,915,892 to 150,113 bytes;
its archive and raw hashes remain in the machine audit. The exact earlier
uncommitted profile ledger is preserved as a verified 3,542,198-byte gzip archive;
its raw/current working copies were removed after comparison/archival checks.

Final measured run retention is about 2.15 GiB (2,308,437,691 bytes before final
summary writes), reflecting earlier retained evidence and protected review state.
The protected IMP-011 human review root's 1,317 file hashes match before/after.
Other-task evidence, unique human inputs, classic/reference data and installed
tools remain unchanged. This threshold review does not justify deleting unknown
earlier roots. Exact paths, manifests and retention checks remain under
`main_project/tests/.runs/imp061-action-axes/` and in the machine audit.

## Remaining gates

No vanilla RDB source block is rejected by the structural decoder. Actual
resources, connections, actor placement, gameplay action owners, exterior return,
native SAVE and full story entry retain their existing checks. Privateer's Hold's
full story-connection declarations are still unqualified; this follow-up does
not substitute a different layout or claim playable story entry. Original-facing
verification and the user-deferred physical controller/changed-host IME checks
remain unchanged. Human increment-3 review and IMP-061 acceptance are now recorded
in the acceptance evidence above; named real integrations still remain open.
