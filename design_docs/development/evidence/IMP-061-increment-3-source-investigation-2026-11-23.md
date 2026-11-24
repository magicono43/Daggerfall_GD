# IMP-061 increment 3 — source dependency investigation

**Subsequent resolution, 2026-11-23:** The user explicitly authorized retaining
unknown vanilla actions as non-executing metadata, with gameplay-owner readiness
pending, and requested an AGENTS.md update. PROJECT-DATA-D02 records that policy.
The import/profile extension now decodes S0000999.RDB and allocates explicit
record IDs without changing any previously allocated identity. The rejection
below is a historical before-state, not a current blocker. The initial nine-check
report and pre-policy inventory retain their original meaning. Current resolved
observations and full-corpus verification are recorded with increment3 execution.

Historical status before subsequent authorization: **incomplete; source dependency decision required**. Increment 3 was
authorized by the issued prompt. No production marker resolver, route schema,
entry, placement or exterior traversal has been delivered or qualified. Accepted
increments 1/2 remain unchanged. IMP-061/M2 and real-provider gates remain open.

Initial tree was clean at `b9b9348` (accepted increment 2 committed by the user).
No commit, branch or history operation was performed. Changes in this investigation
are an independent read-only source observer, its complete frozen editor-marker
inventory, a production-decoder dependency audit and these progress records.

## User clarification

The user explicitly selected **"Allow documented DFU north-facing baseline"**
after being told that the RDB flat records contain no orientation and DFU supplies
north in code. This resolves the facing policy: use DFU north as a documented
baseline difference; do not claim original-game orientation verification.
In the accepted geometry frame, classic +Z north converts to Godot -Z. No actor
height offset, floor snap, correction policy or committed actor pose is implied.
This permission does not establish the original opening role from source alone.

## Independent observations

`main_project/tools/observe_dungeon_markers.py` reads raw MAPS/BLOCKS bytes using
the existing independent BSA observer, without importing production layout/LOC
code. It validates the pinned edition and records every archive-199 editor marker
in every placed dungeon occurrence, including raw flags/magnitude/sound/action,
local position, independently converted anchor, source address and existing stable
IDs where the accepted ledger actually supplies them. Unsupported blocks retain
`id:null`; no source address is invented as a durable runtime identity.

Frozen output: `main_project/tests/dungeon_marker_observation.json`, SHA-256
`1b1118926097e9818da90c0d55283a01653c075056d6ad7dbced565ced448e7c`.
A fresh independent observation produced identical bytes/hash.

| Location | Source name | Complete unique editor markers |
| --- | --- | --- |
| place-00032 | Ruins of Cyeghtan Manor | 72 across the accepted eight placements |
| place-04310 | Privateer's Hold | 56 across five original placements |

Privateer's Hold's original central occurrence is `placement-00001`,
`S0000999.RDB` / `block-1094`, grid `[0,0]`, starting bit set. Its source-labelled
arrival candidates are:

| Source address | Archive/record | Source XYZ | Geometry-frame anchor metres |
| --- | --- | --- | --- |
| 32778 | 199/10 (Start) | [1135,-1559,496] | [28.375,38.975,-12.4] |
| 32814 | 199/8 (Enter) | [510,-25,1672] | [12.75,0.625,-41.8] |

These are source marker anchors, not MOVE-adjusted actor positions. Source labels,
vertical separation and DFU preference are observations, not proof of original
executable opening behavior. Neither marker has an encoded facing field.

Exact source edition (no unverified retail-version claim):

| File | SHA-256 |
| --- | --- |
| MAPS.BSA | 8b5550bfcac03b6f605842568fdbfb7cc6bbed7ace5999c33c900ad286fc24be |
| BLOCKS.BSA | 6f5a4c8d9401c1b00ef83eaac9b0c6c32f53cef6eaa4c7d7027deb739bde4795 |
| ARCH3D.BSA | a51a9e149168814c4a14dc80bb93d38f153be18dc9754be44bc9c7b25dd46a85 |
| S0000999.RDB payload | 761f5118289b237842045f110bca2d0b9384af55339e3a89950b3c1cae75818d |

## Concrete prerequisite failure

The accepted layout profile classifies S0000999.RDB as **unsupported**, with an
empty record-ID ledger. The actual production `layout_formats.gd.decode` reproduces
`unsupported`, record address **19568**, action **27**, reason
`Unsupported required action interpretation.` This occurs before either arrival
candidate can acquire an accepted runtime record binding. Four surrounding border
blocks are decoded, but cannot substitute for the required central block.

Independent byte inspection identifies that flat at `[1264,-32,1504]`, archive
206/record2, flags3, magnitude4, sound31, target-2, action27. No incoming model/flat
action target to address19568 was found in that block. This does not prove that
dropping the flat/action is safe. DFU `DFBlock.RdbActionFlags` names27 `Unknown27`;
the inspected `DaggerfallAction` dispatch table has no27 handler. No semantics
have been invented and no decoder gate has been relaxed.

The supplied scope explicitly requires rejecting unsupported required data and
preserving accepted import contracts. Delivering a ready Privateer's Hold geometry
handoff therefore needs either qualified source-matched treatment of this record
and explicit stable-ID allocation, or an explicitly unavailable opening gate.
A controlled isolated marker fixture could exercise interfaces while retaining
that gate, but would not qualify the original full dungeon. Merely allowing DFU
north-facing does not resolve this decoder failure.

## Verification and limitations

Commands, from repository root (explicit installed Python 3.12 runtime used):

```powershell
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' main_project/tools/observe_dungeon_markers.py C:/Games/Daggerfall/arena2 C:/Godot/Projects/Daggerfall_GD/main_project/tests/dungeon_marker_observation.json
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' main_project/tools/observe_dungeon_markers.py C:/Games/Daggerfall/arena2 C:/Godot/Projects/Daggerfall_GD/main_project/tests/.runs/imp061-marker-source-audit/reobserved.json
& 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe' --headless --path main_project --script res://tests/dungeon_marker_source_audit.gd -- C:/Games/Daggerfall/arena2 C:/Godot/Projects/Daggerfall_GD/main_project/tests/.runs/imp061-marker-source-audit/report.json
git diff --check
```

Dependency audit: **9/9 expected source/dependency observations matched** on
Godot `4.7.2.stable.official.ed1daf0bf`. This is explicitly NOT a passing marker,
geometry, opening or DEV-014 delivery suite. It proves the rejection, not support.
Local report is in the `.runs` path above. The engine also emitted
`Failed to read the root certificate store`; it was not suppressed. The first
audit launch had a script parse error (invalid static hash API), corrected before
the successful run; it is not counted as a passing run.

Installed paired engine executable SHA-256:
`ab1824f85bfd8e0e4128182c000c4003a3e042245b2967848d089b2a04b22424`.

No required rendered, Windows export, integration, stress/performance, native
reconstruction or review-capture checks have run for increment3. They remain
unperformed, not PASS or waived. No PCK/build was created. No source/classic data,
reference material, accepted inventories or production contracts were modified.
The observer and numeric evidence contain no original block payloads. DFU source
was read only; its existing retained MIT license/provenance remain applicable.

Only compact audit/reobservation JSON was generated in the task-owned `.runs`
root; no copied project, export or full build exists to retain. No other-task
payload or protected IMP-011 human state was touched.
One task-generated Python bytecode file and its empty `tools/__pycache__`
directory were removed after inspecting their exact workspace paths/attributes;
no recursive deletion or broad cleanup was used. No other retention was changed.
