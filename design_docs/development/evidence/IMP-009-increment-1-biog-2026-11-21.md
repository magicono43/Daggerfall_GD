# IMP-009 increment 1 — approved BIOG correction and real-source qualification

## User acceptance and increment-2 handoff

On 2026-11-21 the user said, “I accept what you have done in increment 1” and
requested a copy/paste prompt for another agent to start increment 2. Git records
the accepted implementation at `f9779c4` (`Implementation Task 009, Part 1
Completed, 11-21-2026`). Increment 1's assigned input-reader delivery is now
user-accepted. The [increment-2 prompt](../handoffs/IMP-009-INCREMENT-2-PROMPT.txt)
is prepared for issuance in another chat; it starts no implementation here.
Parent IMP-009, increment 3, real-owner/semantic, SAVE and M1 gates remain open.
Earlier uncommitted/pending-acceptance statements below preserve the execution
history and are superseded by this acceptance. Current uncommitted cleanup-policy
and handoff/acceptance edits are not part of the earlier implementation commit.

## Authorization and delivery status

On 2026-11-21 the user explicitly instructed: “In this case, assume the DFU
correction, if that would allow for this to no longer be a blocker for Increment 1.”
This approves only removal of the 12 observed standalone ampersands from executable
biography-effect input. It does not approve other DFU biography fixes or balance.

The BIOG blocker is now cleared. The complete selected installation passes
structural reader preparation, DATA/MOD candidate publication and real CORE menu
entry. Increment 1's input-reader delivery is verified and awaits user acceptance;
it is no longer dependent on a substitute compatible installation. Real CHAR/NPC,
effect-owner, SAVE, parent IMP-009 and M1 gates remain open as originally staged.
No increment 2/3 or other IMP was started. Changes remain uncommitted.

This evidence supersedes the source-blocking status and bounded positive-fixture
qualification in the [initial handoff](IMP-009-increment-1-2026-11-21.md) and
[flat/CLASS18 follow-up](IMP-009-increment-1-source-gates-2026-11-21.md). Their
reports/hashes remain preserved as historical checkpoints, not latest results.

## Exact compatibility correction

Read-only comparison of all 18 installed files with DFU StreamingAssets/BIOGs
found 12 standalone `&` lines. Every occurrence is between answer c's “Getting
along with others” and `RR -5`. All corresponding DFU-packaged files omit that
line. The packaged files also contain unrelated equipment/reward and balance
changes, explicitly described in their readme; none of those are adopted here.
The local review is `main_project/tests/.runs/biog-ampersand-review.json`.

`biog-dfu-ampersand-v1` recognizes only the declared source filename and question,
answer c's exact text, an empty preceding effect list, and immediately following
`RR -5`. It records the raw marker, original one-based source line, source file,
stable question/answer IDs and correction-profile version in `source_annotations`.
The marker is not emitted as an executable effect. The actual `RR -5` declaration
and every other original effect command remain unchanged. Original files remain
read-only and unchanged; no corrected biography library is shipped or copied.

| Original files | Stable question |
| --- | --- |
| BIOG01/02/03/05/10T0.TXT | q12 |
| BIOG06T0.TXT | q9 |
| BIOG12/13/14/15/16/17T0.TXT | q7 |

The rule is an explicitly approved compatibility assumption, not proof of what
the marker did in the original executable. `&` remains unsupported as a direct
effect command. Unknown filenames, changed contexts, different following effects
and other unknown commands still fail. The trusted adapter retains correction
receipts per candidate and rejects their removal, modification or fabrication in
contributions. Arrays/views are independent; read mutation cannot alter receipts.
Annotations describe original-source provenance rather than execute or apply an
effect, select a class, grant rewards or allocate live/persistent instances.

## Full real-data publication exposed one additional source typing issue

After all BIOGs prepared, the first full real candidate exposed ENEMY005.CFG's
raw career skill-position byte **40**. Initial bounded monster vectors had not
covered that record. Independent read-only directory inspection found **43**
ENEMY career records, all selected through the checked MONSTER.BSA boundary;
ENEMY005 is the only one with a value outside player skill IDs 0..34.

Monster careers now use the already versioned `career-source-v1` layout. All fields
and raw skill-position bytes (0..255) are retained. `encounter_career` remains
explicitly incomplete source metadata and reports unsupported interpretation
diagnostics for 40; it is not a player class or complete enemy definition. Player
class validation remains strict at 0..34. CLASS18 likewise remains source-only
with its actual byte 35. Gameplay-use requests for either still fail with
`semantic_unavailable`; no unknown skill, combat statistic or NPC behavior was
invented. This corrects over-eager player-enum interpretation during structural
input reading without fabricating real owner validation.

Known flat source conflicts also retain their earlier approved behavior: all seven
groups load as diagnostic records, unique flat lookup remains ambiguous, and a
required typed flat reference cannot silently use such a record. No winner or
fallback is selected. These are deliberate record/consumer gates, not remaining
file-wide startup blockers.

## Final verification and actual coverage

Godot **4.7.2 stable official**, hash
`ed1daf0bf001b61586d9930840f2f1394092c079`, Windows, `actor-inputs-v1`.
Source is explicitly `C:/Games/Daggerfall/arena2`. The 41 actor inputs and four
foundation sources are held with Windows read-only sharing and hashed before/
after each relevant child. All source hashes match the original observation.
The [final audit](IMP-009-increment-1-biog-audit-2026-11-21.json) records source/
build hashes, engine, EXE/PCK identities, report references and assertion counts.
Both exports' ten relevant source/resource hashes match the final workspace.

```powershell
./main_project/tools/verify_headless.ps1 -Suite actor-inputs -Fixture actor-inputs-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_rendered.ps1 -Suite actor-inputs -Fixture actor-inputs-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration debug -ActorInputs -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration release -ActorInputs -ClassicSource C:/Games/Daggerfall/arena2
```

| Final selection | Expected / actual | Report under `main_project/tests/.runs/` |
| --- | --- | --- |
| Independent headless | 236 / 236 PASS | `verification-headless-5e7d6fe3492940b3989c9d0e90f0a0ea/report.json` |
| Independent rendered | 238 / 238 PASS | `verification-rendered-692de3dbe0854b34b9056e99a009e67f/report.json` |
| Debug export, headless + rendered | 236 + 238 PASS | `export-6ab565c653264f07b19476b8371ab27e/result.json` |
| Release export, headless + rendered | 236 + 238 PASS | `export-a042b5a74f424fe695173783991896ee/result.json` |
| Classic regression, headless | 97 / 97 PASS | `verification-headless-deae48d788be4fb2a1e895cd6a33aca3/report.json` |
| Classic regression, rendered | 100 / 100 PASS | `verification-rendered-4037e2b952054a36881ffbaba7ce8feb/report.json` |

All positive source/menu paths now use the complete actual installation: all 18
biography sets, **216 questions**, original effect-command sequences, all 43
MONSTER careers, classes, full flat/painting/BIO sources. An independent raw-line
command recognizer verifies unchanged command sequences for each of the 18 BIOGs;
all 12 corrected answers independently retain precisely the original typed
reaction-modifier declaration and amount -5. Marker count, source position/identity
receipts, unrelated unknown-command rejection, changed-context rejection, receipt
stripping rejection and mutation isolation are asserted. No broad correction or
silent unsupported-effect omission is used.

An additional independent post-run audit compared the published annotations with
the original 12-line source review: all filenames and original one-based line
positions match. The expected/actual position rows are retained in the audit JSON.

The frozen actor inventory is now 236/238. Missing-source recovery remains tested
with tiny authored foundation containers and missing required actor inputs; it
publishes no partial readers. The positive compatible-fixture copier was removed.
All existing actor mapping/reference, MOD operations/provenance, whole-contribution
rollback, omission/retry, stale candidate, failed-menu recovery and run-long-lock
checks now operate on the complete actual definitions. Repeated reads/validation
leave the CORE session and active definitions unchanged. Real semantic-use requests
remain rejected. Existing unrelated assertion inventories were not weakened.

The affected classic registry regression was repeated through independent
`verify_headless.ps1` / `verify_rendered.ps1 -Suite classic -Fixture classic-v1
-ClassicSource C:/Games/Daggerfall/arena2` commands; original 97/100 inventories
passed. The audit also rechecks the retained publication (111/117 plus 8/8 reload),
text (121/127) and replacement (168/173 plus 10/10 reload) assertion reports for
their unchanged owners. They were not unnecessarily rerun as gameplay integrations.

The real-source release-export menu capture was reviewed: normal menu entry
succeeds while the UI continues to identify character-entry/save support as
unavailable. No actor construction, effect execution or actual gameplay outcome
was claimed. There is no new native dependency, library or toolchain change.

## Remaining gates and retention

No known selected-source initialization/publication blocker remains for this
increment's supported profile. Required unique flat mappings and actual skill/
actor/effect interpretation remain with their real consumers. CHAR/NPC construction
and validation at IMP-015/016, effect target resolution/application, custom-class
selection, preview/randomization, startup ordering/idempotence and SAVE restore/
compatibility are staged owner checks, not passing adapter assertions. Parent
IMP-009 items/spells and faction/quest increments, shared features and M1 remain
open. Stop for user review of increment 1.

Changed actor format/catalog validation and source annotations, actor fixtures/
frozen inventory, wrapper counts, source observation and execution/contracts/
readiness documentation. Existing user work and approval history are preserved.
No classic/reference payload, generated executable/PCK, dependency copy or cache
is part of the review changes. Cleanup journals preserve compact reports/logs/
captures and remove completed builds. Passes 8–10 removed **8,842 disposable
files / 2,225,544,190 bytes (2.07 GiB)**. Final global `.runs` inventory measured
**1,324,256,099 bytes (1.23 GiB)**, below the 2 GiB review threshold, with zero
EXE/DLL/PCK payloads, zero reparse points and zero completed runnable builds.
Retained evidence hashes matched after cleanup. All 41 observed actor-source
SHA-256 values still match their initial read-only observation. Exact manifests
and totals are in `main_project/tests/.runs/imp009-biog-cleanup-summary.json` and
the pass-specific cleanup journals. Installed tools, classic/reference/base data
and unrelated historical archives were not deletion targets.

Final `git diff --check` passed. Git HEAD remains `e792ed9`; no commit or branch
operation occurred. Runtime qualification is complete for the assigned increment-1
reader scope; user acceptance remains pending. No unavailable real-owner check is
counted as passing.

## Exact files for review

```text
design_docs/development/DEPENDENCY_GRAPH.md
design_docs/development/evidence/IMP-009-increment-1-2026-11-21.md
design_docs/development/evidence/IMP-009-increment-1-audit-2026-11-21.json
design_docs/development/evidence/IMP-009-increment-1-biog-2026-11-21.md
design_docs/development/evidence/IMP-009-increment-1-biog-audit-2026-11-21.json
design_docs/development/evidence/IMP-009-increment-1-source-gates-2026-11-21.md
design_docs/development/evidence/IMP-009-increment-1-source-gates-audit-2026-11-21.json
design_docs/development/IMPLEMENTATION_READINESS.md
design_docs/development/MILESTONES.md
design_docs/development/TASK_BACKLOG.md
design_docs/development/tasks/IMP-009.md
main_project/content/actors/profile.json
main_project/content/actors/PROVENANCE.md
main_project/export_presets.cfg
main_project/scripts/data/actor_input_formats.gd
main_project/scripts/data/actor_input_formats.gd.uid
main_project/scripts/data/actor_inputs.gd
main_project/scripts/data/actor_inputs.gd.uid
main_project/scripts/data/ACTOR_INPUTS.md
main_project/scripts/data/actor_source_reader.gd
main_project/scripts/data/actor_source_reader.gd.uid
main_project/scripts/data/classic_access.gd
main_project/scripts/data/DEFINITION_PUBLICATION.md
main_project/scripts/data/definition_registry.gd
main_project/scripts/data/README.md
main_project/scripts/mod/README.md
main_project/scripts/startup/provider_boundary.gd
main_project/scripts/startup/startup_shell.gd
main_project/tests/actor_input_cases.gd
main_project/tests/actor_input_cases.gd.uid
main_project/tests/actor_input_inventory.json
main_project/tests/actor_input_source_observation.json
main_project/tests/README.md
main_project/tools/actor_fixture.ps1
main_project/tools/verify_startup_export.ps1
main_project/tools/verify.ps1
```
