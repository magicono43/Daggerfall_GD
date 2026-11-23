# M1 audit remediation — 2026-11-22

**M1-A01–A03 remediation is implemented and verified; M1 is still not ready for
acceptance pending the applicable human manual checks below.** Changes are
uncommitted. No gameplay feature, approved mechanic, M2 implementation, data
baseline, native dependency, source data or Git history is changed.

The [original audit](M1-INTEGRATION-AUDIT-2026-11-22.md) and its original timing
failure remain evidence. This follow-up distinguishes corrected engineering
findings from milestone acceptance. The [machine-readable evidence](M1-AUDIT-REMEDIATION-2026-11-22.json)
records command arguments, fixture/build/source/report identities, expected/actual
classifications, phase measurements, changed files and retained evidence paths.

## Implemented scope

M1-A01: the actual stock cinematic skip button now uses the media preference
owner's checked live application method. Playback admissions continue to capture
the effective policy. Application rejection, successful persistence and applied
but unsaved outcomes have distinct messages. The combined stock-handler regression
checks effective/accepted/reopened disk state, rejection, write failure, reverse
application and fresh-process effective/accepted/UI selection.

M1-A02: per-phase microsecond profiling identified full-catalog copies for each
validator as unnecessary amplification. Stock adapters now explicitly declare all
reference domains they read; DATA still supplies detached copies. Undeclared
legacy adapters retain full-catalog input. Faction child/mapping queries reuse
validated, exact-ticket lookup keys through the existing domain-index boundary.
No derived FACT/QUEST gameplay state is introduced. Private DATA candidate
ownership transfers at commit, and CORE owns the already detached return value,
removing two redundant catalog copies. Automatic startup uses the just-validated
candidate within the same synchronous call; interactive Continue still rebuilds
and checks current package files. Existing reservations, durable profile order,
atomic publication, obsolete ticket rejection and content locking remain intact.

M1-A03: `m1 / m1-v1` now includes a maintained `m1-composition` scenario. It uses
every ordinary startup adapter and ordinary source contributions, with disposable
launch roots and controlled setup routing. Clean/cancel/invalid/unreadable source
recovery, combined publication failure/retry, unpublished candidate/index access,
detached public views, retained menu entry and locking have named assertions.
A separate process verifies remembered automatic startup and exactly one
preparation. The standalone fixture is `m1-composition-v1`; the Windows export
wrapper accepts `-M1Composition`. Missing source/fixture/renderer/assertion or
relaunch remains incomplete/failing. Existing adapter inventories are unchanged.

## Measurements and remaining cost

All owned engine processes ran sequentially on Windows / Godot
`4.7.2.stable.official.ed1daf0bf`, using disposable game/engine roots and the
explicit read-only `C:/Games/Daggerfall/arena2` installation. The complete
composition guards/hashes all 51 ordinary manifest entries; source hashes
remained unchanged. Layout/variant fixtures keep their additional declared
texture requirements and guards.

| Diagnostic | Before | Current headless | Current rendered |
| --- | --- | --- | --- |
| Ordinary automatic startup/publication | 47.91 / 47.66 s (original audit) | 16.53 s | 16.99 s |
| Validator input copies per preparation | 9.57 s (instrumented baseline) | 2.35 s | 2.45 s |
| Faction-17 child query | 946.85 / 976.27 ms | 1.08 ms | 1.14 ms |
| Peak tracked static memory, automatic launch | 2,177,483,527 / 2,201,545,513 bytes | 1,788,107,092 bytes | 1,811,496,265 bytes |

These are observations on this machine, not a new latency/memory budget or a
universal benchmark. Original timing starts before ordinary shell construction;
current timing spans `_ready` through initial route/render. The instrumented
baseline's two routing assertions failed because of a fixture assumption; its
phase timings are profiling observations, not a passing regression. No memory
comparison uses that exploratory run.

Residual cost is explicitly retained: source intake/definition construction and
detached public catalog projections still execute synchronously. Startup still
blocks frame advancement during that work; this change reduces its duration and
allocation amplification. Retained static memory remains about 1.78–1.80 GB;
interactive publication failure/retry and projection-isolation tests can produce
higher peaks than an ordinary automatic launch. Further asynchronous loading or
catalog representation changes are outside this focused correction. Interactive
Continue deliberately rebuilds to detect package-file edits. No assertion was
removed and no native sync tolerance was loosened.

## Independent verification

Twenty-two independent suite commands passed. Each row shows primary plus
fresh-process assertions; fixture IDs match `<selection>-v1`, except `m1-v1`.
M1 contains four separate scenario inventories; the other adapter inventories
remain unchanged.

| Selection | Headless | Rendered | Result |
| --- | --- | --- | --- |
| m1 | 382 + 12 | 393 + 13 | Passed |
| publication | 111 + 8 | 117 + 8 | Passed |
| faction-quest-inputs | 132 + 0 | 134 + 0 | Passed |
| variant-inputs | 497 + 21 | 503 + 21 | Passed |
| actor-inputs | 236 + 0 | 238 + 0 | Passed |
| item-spell-inputs | 160 + 0 | 162 + 0 | Passed |
| locale-fonts | 419 + 10 | 441 + 10 | Passed |
| translation-preferences | 149 + 10 | 164 + 10 | Passed |
| replacements | 168 + 10 | 173 + 10 | Passed |
| native | 344 + 11 | 374 + 11 | Passed |
| formula | 82 + 0 | 84 + 0 | Passed |

Total for this final shared matrix: **5,463 primary +
165 relaunch assertion records**. Repeated/shared
assertions are not unique coverage; no line/branch percentage is claimed.

The new complete composition itself has **33 headless / 34 rendered** named
primary checks and **12 / 13** fresh-process checks. The stock button regression
now observes `back` as effective, accepted, reopened on disk, relaunched and
selected in the recreated stock UI. A rejected application despite successful
persistence yields a rejection message. Failed publication yields accepted
in-memory values and the explicit applied/not-saved message.

Both Windows export configurations passed the same maintained all-adapter
scenario from their PCKs, independently in headless and rendered modes:

| Export | PCK SHA-256 | Assertions (headless / rendered) | Result |
| --- | --- | --- | --- |
| windows-debug | C2F33341FC7E5D87A5061A304FA9045673207FC7522512CD6C099AAA191A41CF | 33 / 34 primary; 12 / 13 relaunch | Passed |
| windows-release | 5E802BBCFC94E002AD82BD9DD63FA60078DD139B22C4F4B0C76D3B5E0A98B329 | 33 / 34 primary; 12 / 13 relaunch | Passed |

The current editor and packaged rendered menu captures were visually reviewed.
This establishes readable rendered output, not human folder-picker, keyboard,
IME or listening acceptance. The new inventory validator passes 40 complete /
missing / duplicate / unknown / wrong-fixture vectors across both fixture IDs
and all four lifecycle/mode inventories. The existing harness again produces
all six expected pass/0, deliberate-failure/1 and unavailable-restore/incomplete/2
classifications. Four additional missing-source/wrong-fixture composition
requests correctly remain incomplete/2 in the independent modes.

Exact commands and terminal reports are in the machine-readable evidence and
`main_project/tests/.runs/m1-remediation-2026-11-22/`. The full M1 command now
requires explicit `-ClassicSource`; omitting it cannot certify the complete
composition. The verification guide documents standalone and export commands.

## Non-green attempts retained

The original `verification-headless-4c232847a051401cbbf5afcef187b87b` remains
**failed** at `vp9-full presented sync within two frames`, expected true / actual
false. The current isolated native runs passed their unchanged 344 / 374 primary
and 11 relaunch inventories. No decoder fix or proven cause for the original
load-sensitive observation is claimed.

This follow-up also retains its exploratory non-green reports: two incorrect
controlled setup-routing assumptions, one missing explicit GDScript bool type,
and a scoped layout input that initially omitted its typed-media dependency.
The latter correctly rejected authored media references and stopped before the
full variant inventory. The declaration now includes media; the complete final
matrix was rerun. These attempts are not counted as final passing verification.

Storage/native backend and dependency pins are unchanged. The original audit's
Windows process/interruption and accepted missing-DLL/default-bank fault evidence
remain applicable; those separate fault matrices were not rerun here. Non-Windows
exports, physical devices and real native character SAVE remain unqualified or
at their named later providers.

Static review passed `git diff --check`, UTF-8/JSON validation and all 706 source
hash comparisons against the final rendered M1 snapshot. New local Markdown
links resolve. A broader scan found 51 pre-existing links to absent historical
handoff prompt files; those unrelated historical links were left unchanged and
are listed in `final-validation.json`.

## Manual acceptance and later obligations

**Keep M1 open.** Engineering findings A01/A02/A03 are addressed in this scope;
this does not substitute for these outstanding human checks:

- Cold-start the ordinary packaged application in disposable storage, exercise
  the actual folder picker, cancellation/retry recovery and keyboard navigation.
- Choose another cinematic skip policy through the packaged stock UI, reopen it
  and relaunch as a human smoke check. Automated state/relaunch coverage now passes.
- Windows IME composition/Enter/Back remains unqualified. Qualify that physical
  input path before claiming support; English remains the only offered locale.

Prior user audio listening acceptance is retained. Real input/window replacement,
room/collision/spatial audio, SAVE/thumbnail/failed restore, character/opening and
quest fault/retry obligations remain at M2–M5 provider checkpoints. They are not
implemented or closed by this remediation. No further task is dispatched.

## Changed files and retention

Changed implementation is limited to the checked skip owner/UI handler; DATA
registry and reference-domain declarations; the derived faction index; same-stack
automatic startup commitment; and the shared/editor/export verification wiring.
New maintained files are `tests/m1_composition_cases.gd`,
`tests/m1_composition_inventory.json` and
`tools/qualify_m1_composition_inventory.ps1`. Contracts, the verification guide,
this audit/evidence, affected task records and the three M1 progress notices are
updated. The machine-readable report lists every changed path.

All owned verification/export children returned before compaction. Completed
copied projects, exports, dependency copies and engine caches were removed;
reports, logs, controlled inputs and relevant captures remain with verified
preservation hashes. Large JSON outputs use verified gzip archives and explicit
pointers. Installed-template junctions were unlinked without following their
targets. The original audit and timing-failure report were not deleted or altered.
See `retention-final.json`, per-root `cleanup.json` and
[RUN_ARTIFACT_CLEANUP.md](../RUN_ARTIFACT_CLEANUP.md). Rebuild via the recorded
commands before attempting to launch archived runtime paths.
