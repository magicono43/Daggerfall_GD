# M1 milestone integration audit — 2026-11-22

**Current recommendation: NOT READY FOR M1 ACCEPTANCE pending applicable human manual checks.** The authorized [M1-A01–A03 remediation](M1-AUDIT-REMEDIATION-2026-11-22.md) is implemented and independently verified, including maintained complete-composition Windows exports. The original observations, timings and failed native attempt below are retained as historical evidence. This does not start M2 or close later-provider gates.

## Scope and authority

Reviewed revision `fb03e7f62fa9352cfd89822df3382d78f73cba59`, initially clean working tree, on Windows / Godot `4.7.2.stable.official.ed1daf0bf`. Scope is the delivered, user-accepted increments of IMP-001–010, rather than full completion of every shared feature tracked by those cards. No runtime code, approved gameplay, architecture, source data or dependency selection is changed by this audit.

Authority: the ten task cards and their linked specifications/contracts; approved GAD-01–12; PROJECT-DATA-D01; ROADMAP, MILESTONES, DEPENDENCY_GRAPH and PRE_IMPLEMENTATION_AUDIT_2. M1 is the foundation/recovery gate. Actual movement/combat/loot/native SAVE belongs to M2; character/opening/quest integrations to M3; exported executable-mod activation to M5. The existing MOD_RUNTIME_REVIEW records the approved early runtime review, while explicitly leaving feasibility unverified. This audit does not convert those later gates into M1 defects.

## Prioritized findings

### M1-A01 — P2, verified defect: cinematic skip Apply reports success without applying the choice

**Remediation status:** Addressed: checked media-owner application, truthful rejected/unsaved messages and the stock-handler effective/accepted/disk/relaunch regression pass in independent editor and packaged modes. See [follow-up evidence](M1-AUDIT-REMEDIATION-2026-11-22.md). Original finding retained below.

Locations: `main_project/scripts/session/session_shell.gd:294`, `main_project/scripts/startup/settings_owner.gd:215`, and `main_project/scripts/av/media_preferences.gd:14`.

`media/video_skip` is declared live. Its stock **Apply Cinematic Skip** handler calls `settings.apply` without the live consumer callback. The settings owner correctly rejects that application group, retains its previous value, and successfully persists the unchanged settings. The handler checks only persistence `ok`, then reports **Cinematic skip preference saved.**

Reproduced through the actual `render_settings` OptionButton and button signal, with real storage and all ordinary startup adapters, independently in headless and rendered processes. Selecting `back` from the initial `authored` setting leaves accepted, effective and reopened on-disk values `authored`; the displayed message claims success. This violates CORE-006 acceptance 4/7 (rejected groups must be reported rejected) and the delivered native playback preference contract. Existing native tests pass an accepting callback directly and therefore bypass this broken UI handoff (`native_cases.gd:468,506`).

Resolve before acceptance: route this setting through its checked application interface and distinguish rejected application from successful persistence. Add a focused regression through the stock UI handler, including reopened settings. No settings-owner redesign is needed. This audit leaves the defect unchanged for review.

### M1-A02 — P2, measured performance concern: combined publication stalls the application thread and faction queries copy unrelated domains

**Remediation status:** Addressed in the authorized focused scope: measured scoped validator copies, exact-ticket faction lookup keys, private ownership transfer and same-stack automatic commitment reduce the observed costs. Residual synchronous intake and retained memory are explicitly documented; no universal budget or asynchronous responsiveness claim is made. See [follow-up evidence](M1-AUDIT-REMEDIATION-2026-11-22.md). Original finding retained below.

The all-adapter probe observed approximately 46–48 seconds from constructing the ordinary startup composition through source selection/menu publication, with no process-frame advancement during its synchronous selection call. Godot tracked approximately 1.80 GB static memory after publication and 2.20 GB peak. A single `FactionQuestInputs.children(registry, "packs/dfu", "faction-17")` took approximately 0.97–1.17 seconds in the same composition.

Source evidence explains the amplification: `StartupController.check_content` prepares a candidate and `commit_content_menu` prepares again; `definition_registry.prepare` deep-copies the complete resource dictionary for each domain reference validator; `commit`, `active`, and CORE's published projection copy the catalog again. `FactionQuestInputs.children` calls `registry.active()` and rebuilds its graph, copying geography/layout/text/media data for a faction-only query (`faction_quest_inputs.gd:260`). Normal point `registry.query` already returns a detached individual record.

These are observed costs on this machine, not a proven violation of an approved latency/memory budget, leak, or universal benchmark. Isolated repeats confirmed 47,910 / 47,659 ms through menu publication, 946,849 / 976,270 microseconds for one faction-child query, and 2,177,483,527 / 2,201,545,513 bytes peak tracked static memory (headless / rendered). The ordinary release export's launch log records 41 seconds between initial launch metadata and committed content publication. Resolve or explicitly disposition responsiveness before extending these paths with M2 consumers. Keep fixes narrow and preserve detached public views, atomic publication, exact candidate tickets and the content lock. Broad refactoring is not justified by this audit.

### M1-A03 — P2, integration coverage gap: the named M1 suite does not exercise the complete ordinary composition

**Remediation status:** Addressed: the named M1 suite now requires the maintained complete-composition inventory, fresh-process remembered startup and consumer handoff; Windows debug/release exports use the same gate. Separate adapter inventories and unavailable/failure classifications remain intact. See [follow-up evidence](M1-AUDIT-REMEDIATION-2026-11-22.md). Original finding retained below.

`verify.ps1:116` selects only qualification/startup/session for `-Suite m1`. Later independent source suites intentionally register different adapter subsets in `startup_shell.gd:45–109`: variant/layout fixtures include geography/media but exclude actor/item/faction/text/preference adapters; geography includes the authored readers but excludes layout/variant/text/preference adapters. Passing those inventories alone cannot certify all enabled adapters together.

The audit's disposable subclass overrides only launch roots, retains an empty fixture dictionary, and executes the normal `_ready` registrations, controller source selection and menu publication. All ten domains compose successfully against the selected installation, and the rendered menu was visually inspected. Ordinary debug/headless and release/rendered exports also published the complete configuration from their PCKs with no fixture override, using fresh portable roots and a preseeded valid content path. Post-commit launch-log output verifies that publication; no human visual/device check is inferred from it. Thus there is no reproduced all-adapter publication failure. The remaining issue is a missing maintained regression gate: promote the combined scenario into the normal harness, including clean/remembered startup, invalid required input/recovery, publication/lock and settings consumer handoffs. Preserve separate suite inventories and fail/incomplete behavior. Current audit evidence closes the tested joint publication run; maintaining its coverage is the follow-up, not evidence that publication failed.

## Task and boundary review

| Task | Delivered scope and evidence reviewed | Boundary assessment and deferred obligations |
| --- | --- | --- |
| IMP-001 | Windows native storage adapter, root lease, INI recovery/publication, launch logging, independent recovery shell; startup and process/interruption evidence | CORE owns one root and startup transaction; native operations stay behind C++ adapter. Real DATA/MOD routing now exists. Actual SAVE I/O recovery remains M2. |
| IMP-002 | Session admission/preflight/replacement/cleanup, scoped holds, modal/input shell, stale completion rejection | CORE owns lifecycle and independent gates; UI owns windows/focus. Production new/load provider truthfully rejects unavailable entry. CHAR/input/real restore and later window providers remain staged. |
| IMP-003 | Independent headless/rendered runner, fixed fixtures, isolated copies/roots, explicit failure/incomplete exits, build/assertion reports | Import validation uses production scripts. Negative harness qualification and maintained all-adapter coverage must be distinguished from positive shell tests. |
| IMP-004 | Explicit classic manifest, checked readers, missing/unavailable/malformed distinctions, application lifetime, restart-only source changes | Real required-source readiness contributes before menu entry; source files opened read-only. Later adapters declare requirements rather than infer gameplay readiness. |
| IMP-005 | Folder/ZIP discovery, duplicate choice, pending profiles, deterministic dependency planning, clean DATA transactions, provenance and actual menu lock | MOD owns plan; DATA owns definitions; CORE reserves and commits. Invalid contributions retain explicit recovery. No executable package code is enabled. Character/SAVE compatibility remains later scope. |
| IMP-006 | Classic/nonclassic numeric vectors, purpose streams, scope retirement, fresh-load initialization contract, bounded formula registry | RULE owns RNG/formula services; owner results stay with owners. Controlled retained-result/load tests establish interfaces, not native SAVE or production formula semantics. |
| IMP-007 | Catalog/CSV fallback, structured TEXT.RSC controls, fonts/live locale, translation codec and per-mod preferences | DATA supplies immutable definitions; presentation owns rendering; MOD owns preferences. Essential recovery text/fonts remain independent. Macro/message/gameplay/authoring integrations retain their named later gates. |
| IMP-008 | Classic decoders, provider-qualified replacement resolution/cache isolation, native MIDI/SF2/video and bounded consumers | DATA owns resources, AV owns playback cursor/terminal lifecycle, CORE gates flow. User listening evidence already exists for PCM/Vorbis/MIDI/AAC; this audit does not claim to hear audio. M1-A01 affects the stock preference handoff. Real room/environment/opening consumers remain staged. |
| IMP-009 | Actor/class/BIOG, item/spell, faction/quest readers, corrections/provenance and structural publication | No actor creation, item grant, spell execution, quest start or standing mutation occurs in reading. Semantic flags truthfully remain false. Approved DFU source/corrections are permitted by PROJECT-DATA-D01, not deviations requiring renewed approval. |
| IMP-010 | Stable geography/layout/occurrence identities, raw coordinate frames, explicit variant scopes/remaps and structural proposals | DATA does not own physical pose, residency, live layouts or saved selections. Unsupported required structure fails explicitly. WORLD/LOC/MOVE/QUEST/SAVE compatibility is not certified by DATA receipts. |

## Save/load, ownership and lifecycle

M1 persistence is application configuration: startup settings/backup/recovery, MOD profiles/history and per-mod preferences. Fresh-process checks exercise those files under disposable roots. The RNG retained-result fixture and layout/variant reload fixtures validate contracts and selected identities; they are not native character saves. No SAVE owner or generation bundle exists in the stock session provider. Native failed-restore preservation is deliberately incomplete and remains a required M2 check under GAD-04/12.

Inspected production owners/callers preserve the approved split: CORE lifecycle/storage/publication, MOD plan/preferences, DATA definitions/readers, RULE random/formula services, UI focus/windows, AV playback. Definitions/projections are detached; candidate content is separate from the committed catalog; scoped operations reject obsolete completions. No verified cross-domain authoritative-state duplication or unintended gameplay mutation was found in the reviewed M1 paths. The measured use of complete-catalog copies is a performance/coupling concern, not evidence that callers mutate shared state.

The runner and export wrapper duplicate scenario-selection/count wiring, and several source adapters repeat format-specific validation patterns. This is maintenance risk only: no demonstrated behavior divergence or justification for broad deduplication was found. Native runtime pins/provenance and bundled data licensing remain explicit. Unapproved original-executable fidelity is not an acceptance requirement.

## Verification and manual obligations

Commands, outcomes, failed attempts, build/source identities and cleanup are recorded below and in the [machine-readable audit](M1-INTEGRATION-AUDIT-2026-11-22.json). All results use disposable application/engine roots. The selected external installation is `C:/Games/Daggerfall/arena2`; it and repository reference/base data remain read-only. The all-adapter and ordinary-export probes held READ-sharing guards on all 51 declared external files and verified unchanged before/after hashes.

| Fresh verification | Result |
| --- | --- |
| Independent `m1 / m1-v1` commands | Passed: 349 headless / 359 rendered assertions. Every copied project imported successfully. |
| 19 independent selections in both modes | 37/38 initially passed; only the first headless native timing assertion failed. All other selections passed, including 497/503 variant assertions and 21 fresh-process assertions per mode. |
| Isolated native repeat | Passed: 344 headless + 11 relaunch assertions. Independent rendered native run passed 374 + 11. No threshold or fixture change was made. |
| All-adapter diagnostic, first and isolated repeat | Menu publication succeeded in both modes; ten domains and 51 manifest entries. Stock skip-setting handler defect reproduced in both modes. Actual rendered menu inspected. |
| Harness qualification | 6/6 expected classifications: pass/0, deliberate failure/1, unavailable native restore/incomplete/2 independently in both modes. |
| Windows storage/process verification | 9/9 scenarios: same-root aliases, concurrent distinct roots, termination/normal-exit reacquisition, and backup/publication interruption/reopen preservation. |
| Windows debug and release publication exports | Both configurations passed headless 111 / rendered 117 primary assertions, plus 8 relaunch assertions per mode. |
| Ordinary exported startup, no fixture override | Debug/headless and release/rendered both passed post-commit publication/log/diagnostic checks using fresh portable roots. Total launch/exits: 52.83 / 51.10 seconds, including 120 post-start frames; these are not precise startup-only benchmark intervals. |
| Project/Git validation | Fresh isolated imports passed throughout; `git diff --check` passed. Runtime source and dependency pins unchanged. |

The shared command runs and native repeat contain **8,310 primary + 202 relaunch assertion records** across 45 scenario executions; these include the original failed attempt and repeated/shared scenarios. Export, qualification and process checks are reported separately. These totals are not unique feature coverage or a line/branch coverage percentage.

The 19 selections were `classic`, `mods`, `planning`, `publication`, `randomness`, `randomness-session`, `formula`, `text`, `structured-text`, `locale-fonts`, `translation-preferences`, `media`, `replacements`, `native`, `actor-inputs`, `item-spell-inputs`, `faction-quest-inputs`, `geography-inputs`, and `variant-inputs`. Each used its matching `<selection>-v1` fixture, explicit classic source and 600-second child bound. Windows imports/exports ran sequentially. Diagnostic processes initially overlapped the first matrix phase; the native and performance repeats ran without another audit engine process.

Reproduction entry points (repository root):

```powershell
./main_project/tools/verify_headless.ps1 -Suite m1 -Fixture m1-v1
./main_project/tools/verify_rendered.ps1 -Suite m1 -Fixture m1-v1
# Repeat independently for each of the 19 selections above:
./main_project/tools/verify_headless.ps1 -Suite variant-inputs -Fixture variant-inputs-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 600
./main_project/tools/verify_rendered.ps1 -Suite variant-inputs -Fixture variant-inputs-v1 -ClassicSource C:/Games/Daggerfall/arena2 -TimeoutSeconds 600
./main_project/tools/qualify_verification.ps1
./main_project/tools/verify_storage_processes.ps1
./main_project/tools/verify_startup_export.ps1 -Configuration debug -DefinitionPublication -ClassicSource C:/Games/Daggerfall/arena2
./main_project/tools/verify_startup_export.ps1 -Configuration release -DefinitionPublication -ClassicSource C:/Games/Daggerfall/arena2
```

The local diagnostic/support scripts and complete executed command matrix remain under `main_project/tests/.runs/m1-audit-2026-11-22/`. `composition.gd` retains the launch-root override, public production operations and stock control-handler reproduction. `run-normal-exports.ps1` records ordinary launch arguments, disposable Portable.txt/settings inputs, source guards and the post-commit log assertion. These scripts describe executed disposable paths; rebuild removed runtime copies/exports before repeating them.

Debug PCK SHA-256: `F1316E53C19420A0CD7E7912BCA510BB0B8D4BE165E197CEDC8EF4161B3C3415`.
Release PCK SHA-256: `AAE7D5AD34F7C6A3721A1BA73E01C0B5FE5DD6ABC3E8C1255DE12BCB4E7F360A`.
Engine/executable, probe, source and individual report hashes are retained in the machine-readable audit and local reports.

### Non-green attempts and limits

- First headless native run: `verification-headless-4c232847a051401cbbf5afcef187b87b`, assertion `vp9-full presented sync within two frames`, expected `true`, actual `false`. It overlapped all-adapter diagnostics. Its report remains failed. The isolated repeat `verification-headless-ca1c02ee6c864d68b216be6f0aa1f8e7` and independent rendered native run `verification-rendered-6288ca05793e4c0285daf4e514424116` passed. This is a retained load-sensitive test observation with unproven cause, **not a verified decoder/playback defect** and not permission to suppress the assertion.
- The first ad hoc rendered diagnostic logged shader-cache write errors and was not qualified. Explicit isolated engine-root reruns had only the previously documented certificate-store diagnostic and passed diagnostic checks. Exploratory logs remain preserved; they are not counted as passing checks.
- Native restore remains deliberately incomplete in the qualification request. No real SAVE, enemy encounter or quest fault/retry result is claimed. Non-Windows exports and physical IME/device playtests were not run.
- The separate missing-DLL/default-bank fault matrix was not rerun. Its [accepted IMP-008 evidence](IMP-008-increment-3-2026-11-21.md) remains relevant: comparison from `7d88e99` to this audited revision found only a README change under native media/AV/backend implementation paths. Fresh native capability/playback and Windows exports were run here. Latest accepted variant-export evidence also remains applicable: `git diff c4d50e7 HEAD -- main_project` is empty.

Outstanding manual work must be scoped correctly: inspect the final combined exported startup/recovery UI and the corrected cinematic preference handler; maintain real device/playback checks when a backend/device changes. Prior user listening acceptance is retained rather than silently reset. Real input/window behavior, room/collision/spatial audio, save thumbnails/restore, character/opening and quest outcomes remain manual/rendered requirements at their named M2–M5 providers, not missing M1 implementations.

Manual checklist not claimed completed by this audit:

- Cold-start the ordinary packaged application with the complete current adapter composition; use the actual folder picker, cancel/retry recovery, and keyboard navigation in disposable storage. Automated normal-export commitment and the inspected editor menu do not establish every interactive recovery path.
- After correcting M1-A01, choose a different cinematic skip policy through the stock control, reopen it, and relaunch. Automated reproduction presently demonstrates rejection plus the false success message.
- Actual Windows IME composition/Enter/Back behavior remains unqualified in the session UI contract. Synthetic input and Godot LineEdit ownership are not human IME evidence. Qualify it before claiming that device/input path supported; English is the only currently offered locale.
- Preserve the named later-provider playtests: real input delivery and window replacement, geometry/marker/collision/placement agreement, spatial audio, native save/preview/restore preservation, character grants/opening, and quest fault/retry. Each closes at its assigned integration checkpoint.

Coverage here is scenario/assertion coverage. No line/branch coverage percentage was measured, and repeated assertions across related selections are not additional unique feature coverage.

## Evidence retention and changed files

All owned children completed before compaction. The audit's 47 verification copies and two exports were removed; **zero completed audit builds or EXE/DLL/PCK payloads remain**. Reports/logs, captures, expected/actual outcomes, build/source identities and custom diagnostic inputs/scripts are retained. Twenty large JSON outputs were compressed from 226,765,002 to 6,242,888 bytes with verified decompressed SHA-256 recovery; their original paths contain explicit archive pointers, not terminal reports. The measured total `.runs` retention was approximately 1.63 GiB before the last small summaries. Rebuild through the recorded commands rather than attempting to launch archived build paths.

The process verification's editor import generated 23 previously absent UID sidecars. Creation times matched that import; their exact bytes/hashes were archived before removing those audit-generated files. The runtime source tree was restored. Exact cleanup/retention/archive manifests remain in the local audit directory and are summarized in [RUN_ARTIFACT_CLEANUP.md](../RUN_ARTIFACT_CLEANUP.md).

Review changes are this report and its JSON, the audit notices in MILESTONES/TASK_BACKLOG/IMPLEMENTATION_READINESS, and the cleanup record. No game code, feature specification, architecture decision, data asset, dependency pin or Git history was changed. Changes are uncommitted for the user's review.

## Acceptance and next milestone

**Original audit disposition (superseded by the remediation status above; manual M1 acceptance remains open).** M1-A01 is a verified behavior/specification defect and should be corrected with a stock-handler persistence/relaunch regression before acceptance. Close the applicable manual startup/recovery checks. M1-A02 needs a focused performance correction or an explicit recorded disposition; M1-A03 is a maintained-coverage follow-up supported by successful current joint runs. Neither cost measurements nor the original non-reproduced timing failure establish an additional functional defect. No P0/P1 product defect, source-data corruption, native-save regression or new ownership violation was verified.

The accepted IMP-001–010 delivery/prerequisite records remain valid; this audit does not claim full acceptance of their shared later-owner features. Later prerequisite-cleared tasks may be planned in the verified dependency waves, but this audit starts none and does not claim the M2 encounter/save loop is available.

The next prerequisite-cleared wave is IMP-011 (input), IMP-014 (clock), IMP-016 (actor baseline), IMP-017 (possessions), IMP-024 (room presentation) and IMP-061 (dungeon layout/arrival markers), each subject to explicit authorization and its increment scope. IMP-013 still requires actual IMP-061 delivery; IMP-012 requires IMP-011/013/016; IMP-022 requires IMP-017; IMP-023 requires the named room/combat/save providers. Numeric task order is not the dependency order. M2 must add the actual bounded placement/combat/loot/save-and-restore loop and failed-restore preservation, plus its independent rendered timing/thumbnail checks.
