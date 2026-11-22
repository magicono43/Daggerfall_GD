# IMP-009 increment 1 — flat source and CLASS18 gate correction

**Later qualification:** The user subsequently approved the narrow DFU ampersand
correction. BIOG is no longer a source blocker; the complete real selected source
is qualified in [BIOG/source evidence](IMP-009-increment-1-biog-2026-11-21.md).
The counts/hashes and partial-delivery description below preserve this earlier
checkpoint and are superseded by that final adapter qualification.

## User clarification and scope

On 2026-11-21 the user clarified that “leave it blocking” meant rejecting an
ambiguous flat mapping, not rejecting FLATS.CFG or the installation. The user
authorized an exception/workaround and then requested resolving CLASS18 as well.
This supersedes the initial handoff's broader interpretation. The initial
148/150 assertion reports remain historical; they are not current qualification.

The original increment is still **partially delivered** while the separate BIOG
ampersand interpretation remains unresolved. This correction fixes two excessively
broad source-startup gates; it does not certify actor construction, City Watch
skill semantics, effect execution or all M1 requirements. No later increment or
other IMP was started. All work remains uncommitted.

## FLATS.CFG: source records versus unique mappings

The complete installed file has seven conflicting groups, including a three-way
group. The initial parser stopped at the first duplicate, hiding the others.
`classic-flat-conflicts-v1` pins complete group cardinalities and unordered sets
of SHA-256 fingerprints of canonical six-line records. Fingerprints were computed
independently through read-only PowerShell/.NET source inspection; no classic
payload or caption-selection policy is shipped.

| Packed source key | Archive / record | Alternatives |
| --- | --- | --- |
| 22785 | 178 / 1 | 2 |
| 22788 | 178 / 4 | 2 |
| 23040 | 180 / 0 | 2 |
| 23342 | 182 / 46 | 2 |
| 23438 | 183 / 14 | 2 |
| 23443 | 183 / 19 | 2 |
| 25488 | 199 / 16 | 3 |

Known groups now initialize successfully and return warnings. A single typed
`flat_conflict` diagnostic retains every decoded alternative, physical source
block address, original file receipt and source provenance. No duplicate valid
flat definitions or arbitrary first/last winner is published. Source/catalog
queries requiring a unique flat return `ambiguous_mapping` with independent
candidate views and source/provider context. Required references to kind `flat`
cannot resolve to `flat_conflict` and still reject preparation. Conflict records
reserve their mapping namespace, preventing another added definition from silently
claiming the same classic ID. Manufactured/modified conflict diagnostics fail
verified source-receipt validation.

Unknown conflicting groups, extra copies, and changed conflict members still
reject; ordinary unused-field handling is unchanged. Reordering the exact known
source members cannot choose a winner. Explicit content replacement retains its
normal declared-operation, identity/provenance and owner-validation requirements.
No source bytes were modified.

## CLASS18: preserve the City Watch source without inventing a skill

The deeper consumer trace distinguishes two roles:

- DFU `Game/Entities/EntityEnums.cs#ClassCareers` defines playable classes 0..17;
  class selection excludes the extra file. CLASS18 must not become a nineteenth
  selectable player class or acquire a guessed biography mapping.
- `DaggerfallUnityEnums.cs#MobileTypes.Knight_CityWatch` and
  `Game/Entities/EnemyEntity.cs#SetEnemyCareer` reach class-career index 18 for
  City Watch. Therefore simply dropping the file would lose a real source.

`career-source-v1` now preserves CLASS18's full supported 74-byte structure as
`career_source`, stable record `career-source-18`. Raw skill bytes are u8 source
values (0..255), including the actual major-skill slot 2 value **35**. This is
not a declaration that 35 is a valid skill. Structural lookup reports an
unsupported-byte diagnostic. Existing strict `career-cfg-v1` interpretation still
rejects 35, a required `class` reference cannot resolve to a `career_source`, and
gameplay-use lookup remains `semantic_unavailable`. No skill substitution, stat
correction or real-owner validation was invented. CLASS18 remains explicitly
declared and read through the normal classic registry before menu preparation.

The source inventory remains 41 files plus four foundation files. Only CLASS18's
declared source profile changes; ordinary class and MONSTER career validation
retain their prior skill vocabulary and failure behavior. The shipped PCK format
profile explicitly declares the additional source-only transport.

## Verification

Windows / Godot 4.7.2 stable official,
`ed1daf0bf001b61586d9930840f2f1394092c079`, fixture `actor-inputs-v1`.
The [current audit](IMP-009-increment-1-source-gates-audit-2026-11-21.json) records
source/build hashes, commands through report reproduction metadata, unchanged
guarded inputs, EXE/PCK identities and expected/actual counts. All ten relevant
exported source/resource hashes match the workspace. No native dependency changed.

```powershell
./main_project/tools/verify_headless.ps1 -Suite actor-inputs -Fixture actor-inputs-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_rendered.ps1 -Suite actor-inputs -Fixture actor-inputs-v1 -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration debug -ActorInputs -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration release -ActorInputs -ClassicSource C:/Games/Daggerfall/arena2
```

| Selection | Expected / actual | Report under `main_project/tests/.runs/` |
| --- | --- | --- |
| Independent headless | 168 / 168 PASS | `verification-headless-75bcf0c668e342329af4fbef69d4bd69/report.json` |
| Independent rendered | 170 / 170 PASS | `verification-rendered-9e072c46f646496f82887aaa290c0303/report.json` |
| Debug export, headless + rendered | 168 + 170 PASS | `export-a3681a79e0604d2dae5d86010fcef9aa/result.json` |
| Release export, headless + rendered | 168 + 170 PASS | `export-40b098cf7a1c471087041ba2950e412e/result.json` |
| Classic regression, headless | 97 / 97 PASS | `verification-headless-66b90e590a194e548284c332bbf654da/report.json` |
| Classic regression, rendered | 100 / 100 PASS | `verification-rendered-f19ceb3089ac457c9617caef463d9c02/report.json` |

The actor assertion set explicitly checks complete real FLATS.CFG initialization,
all seven warnings, unaffected flat lookup, rejected 178/1 lookup, both captions,
independent rejection views, source order, extra/changed conflict rejection,
published conflict markers, required-reference rejection, source-only CLASS18
registration, strict interpretation rejection, preserved actual byte 35, separation
from playable classes and denied gameplay use. Previous actor acceptance cases
remain except the three deliberately corrected source-wide rejection expectations.
Other accepted suite inventories are unchanged; the initial publication/text/media
regression evidence remains applicable to their unchanged owners.

Positive publication now uses the **complete original FLATS.CFG and real CLASS18
source**, plus the previously documented bounded composition for other sources.
The actual installation's remaining BIOG failure is independently verified;
neither the flat file nor CLASS18 appears in its initialization failures. That
does not claim the entire installation now reaches the menu. Semantic readiness
remains unavailable under real CHAR/NPC and effect-owner integration gates.

## Files and retention

Updated actor format/source/catalog adapters, the shipped format inventory,
actor cases/frozen IDs/source observation, wrapper counts, concrete contract and
task/readiness/evidence records. Existing user changes and initial execution
history are preserved. No classic/reference files, commits or branches changed.

Cleanup uses the same checked local journal as the initial task. Pass 6 removed
completed development builds; pass 7 removes completed qualification builds after
recording their hashes and reports. Logs/results and required captures remain,
with zero completed runnable builds retained. These two batches removed
**10,827 files / 2,591,157,376 bytes (2.41 GiB)**. Final global `.runs` inventory
measured **1,090,977,639 bytes (1.02 GiB)**, with zero EXE/DLL/PCK payloads or
reparse points. Preserved evidence hashes matched, all 41 observed classic inputs
still matched their original SHA-256 values, and final whitespace checks passed.
The local `imp009-source-gates-cleanup-summary.json` records the totals. Final
Git HEAD remains `e792ed9`; changes are uncommitted.

The final release-export menu capture was visually reviewed: it reaches the real
menu with the bounded compatible composition and continues to state that character
entry/save support is unavailable. No real actor or City Watch skill semantics
were exercised or claimed.
