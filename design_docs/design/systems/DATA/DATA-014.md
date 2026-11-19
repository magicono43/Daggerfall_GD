# DATA-014 — CSV string table patches

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Support validated localized text additions and corrections through CSV contributions with explicit targeting, operations and provenance. Preserve deterministic resolution and usable fallback without changing gameplay identity or publishing structurally partial patches.

## Intended player experience

Text patches affect the intended language/collection, and intentional later overrides work predictably. Normal spreadsheet CSV exports preserve quoted and multiline text. Invalid files identify their source and row rather than silently dropping changes. Unusable translations fall back under the approved language policy; essential controls remain readable.

## Confirmed requirements

DATA-014-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm collection/locale targeting; explicit add/replace; DATA-003 precedence and same-file duplicate rejection; UTF-8 CSV quoting/multiline/whitespace support; whole-file structural rejection; and entry-level usability fallback without silently restoring overwritten same-language text.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/StringTablePatcher.cs#PostprocessTable` acts only on Unity StringTable input. It loads rows using TableCollectionName, updates existing entries by key or adds missing ones. The load request does not explicitly include locale.
- `Game/StringTableCSVParser.cs#Load` checks ModManager before StreamingAssets/Text and returns null for absent/empty or caught parsing failure. This path differs from some other DFU text-source precedence.
- `ParseCSVRows` uses a limited regex-based two-column parser with optional Key,Value header handling and trims carriage-return/newline characters from matched values. Complete malformed-row rejection and target format fidelity are not established by this code alone.
- `LoadDictionary` uses Dictionary.Add and rejects duplicate keys, while the patcher iterates rows and can replace a key repeatedly. The consumers therefore have different duplicate behavior.
- `ReadAllText` opens read-only with shared read/write access. This allows external editing access but does not establish safe live reload. The patcher contains commented setup code for attaching its postprocessor; actual asset attachment still requires verification.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; localization settings attachment, locale fixtures and CSV round trips were not tested. Source remains unchanged. Intended behavior below follows confirmed decisions rather than adopting all source details.

## Detailed rules and behaviors

### Targets and operations

Every patch explicitly targets collection/domain and locale, retaining contributing package/file provenance. Target base-language tables using their declared language explicitly; no patch implicitly applies to every locale. Exact metadata placement in file/path/manifest remains a schema decision, but required targeting must be unambiguous.

Use stable DATA-013 text keys. Support explicit add and replace operations. Add requires the target key to be absent in that target locale/collection; replace requires it to exist. A key present only in another language is not automatically present in the target locale. Invalid add/replace usage rejects the contribution rather than silently becoming an upsert. Exact catalog/shared-key representation must support this explicit target-entry distinction.

Blank values and intentional optional suppression follow DATA-013. Blank replacement does not mean deletion; by default it results in missing/unusable text that falls back. This feature does not approve a delete operation, suppression syntax or key renaming through value edits. Essential labels cannot be suppressed.

### Resolution and duplicates

Apply DATA-003 ordering: shipped content, enabled mods in resolved order, then explicit loose overrides. Later valid replacements win. Within-source ordering remains normalized relative path then declared row order. Reject duplicate target keys within one CSV file; deliberate successive replacements must use separately ordered contributions rather than accidental duplicate rows.

Use complete target identity, including collection/locale/key, for collision diagnostics. If the final schema permits multiple locale/collection targets per file, it must preserve that distinction; the file layout is not selected here. Retain contributing and winning-source provenance. Ordinary valid replacements need no blocking popup under DATA-003.

Resolve during the editable pre-menu stage and lock contributions at actual main-menu entry. Language switching among already loaded/validated resources follows DATA-013 without rereading external CSV or changing mod order. External edits and installed-package changes retain restart/configuration rules.

### CSV format

Support UTF-8 with documented header/schema, quoted commas, escaped quotes, multiline values and common Windows/Unix line endings. Preserve meaningful whitespace, including authored text boundaries, rather than indiscriminately trimming values. Key/target normalization and blank interpretation must be explicit and separate from text whitespace preservation.

Do not infer successful parsing from a subset of regex matches. Structural validation must account for the entire input under the declared schema. Exact columns, operation/target metadata, encoding/BOM policy, optional comments and error-position representation remain technical dependencies. Normal spreadsheet exports satisfying the supported schema must round-trip text meaningfully.

### Structural errors and atomic publication

Malformed CSV, invalid operations, duplicate targets and missing required targeting fields reject the entire patch file. Report file and row/reason context; multiline records may require record/start-line context rather than assuming one physical line equals one entry. No rows from a structurally invalid file publish as applied changes.

Stage and validate operation targets against the resolved earlier state before publication. Repeated candidate rebuilds must start from the appropriate clean base rather than already patched values. DATA-003's explicit fix/removal or continuation-without-contribution recovery applies only when the remaining content validates. Do not automatically skip malformed rows/files or silently restore earlier content on structural rejection.

### Translation usability and fallback

Distinguish structural patch validity from translated-value usability. A structurally valid patch can produce an entry whose required placeholders or supported formatting are invalid. Diagnose its source/key and mark that entry unusable for lookup; use DATA-013's selected-language → declared content-base-language → explicit source/caller fallback chain.

Do not silently reveal an overwritten earlier same-language value as an extra precedence fallback. The patch remains the winning resolved entry even when unusable. An unusable base-language entry advances to the next approved fallback; ordinary exhaustion yields the visible placeholder, while essential controls retain bundled usable labels. No fallback stage authorizes arbitrary cross-collection/language search.

Entry-level fallback is not partial structural application: operations and winning provenance resolve coherently, while text usability is evaluated through the separate approved presentation policy. If a later valid contribution explicitly replaces that entry, normal precedence applies. Invalid executable/gameplay commands cannot be introduced through translation; exact token rules remain DATA-015/016/UI-owned.

## Relevant formulas and parameters

No gameplay formulas or balance values apply. Deterministic ordering and fallback follow DATA-003/013. No fixed CSV column layout, maximum file size, row count or placeholder wording is approved here. Duplicate identity is collection/domain + locale + key rather than basename alone.

## Required data

Explicit collection/domain, locale, stable key and add/replace operation; UTF-8 value or supported optional-suppression designation; package/file/row provenance; resolved earlier/winning-entry context; structural and text-usability results; placeholder/format requirements from owners. Complete schema, targeting placement, normalization and base-language ownership remain dependencies.

## Inputs, outputs and events

Inputs: shipped tables, ordered CSV contributions, declared target metadata, schema and format-validation results. Outputs: coherent patched tables/provenance, whole-file rejection with context, and entry-usability status for DATA-013 fallback. These are conceptual contracts, not concrete APIs/signals. Applying a text patch does not trigger gameplay, commit a pending choice or change authoritative identity.

## Cross-system interactions

- DATA-003 supplies precedence, staging/rejection, diagnostics and pre-menu configuration lock. DATA-013 supplies stable keys, base-language declarations, blank/suppression policy, fallback and live locale selection.
- DATA-015/016 define supported tokens/macros; UI/AV and font owners define usable presentation. Patching text cannot become an executable gameplay extension.
- CORE-003/006 retain language settings application/persistence; CORE recovery screens retain independent essential labels. CORE-019 restrictions remain independent of explanation text.
- MOD owns package identities/dependencies. SAVE/domain references remain independent of localized wording; patching does not rewrite character history or relink quests by text.

## Edge cases and failure conditions

- French patch targets French only; a same-named collection in another language is unaffected unless explicitly targeted.
- Add targets an existing locale key or replace targets a missing one: reject the whole file rather than infer an upsert. Presence in another locale is insufficient.
- Two rows repeat the same target: reject, even if their values agree. Separate ordered replacements are allowed.
- Quoted commas, doubled quotes and multiline values: preserve intended contents; malformed quoting must not silently hide rows.
- A later row is structurally invalid after earlier rows parse: none of that file's changes publish.
- Structurally valid replacement has invalid required formatting: retain winner/provenance, mark unusable and follow language fallback, not an older overwritten same-language entry.
- Blank replacement: DATA-013 fallback applies unless explicit supported optional suppression is used; essential control suppression remains invalid.
- Language switches during a pending choice: use loaded patched resources and refresh presentation without replaying actions or changing choice identity.
- External CSV edited during execution: no supported live reload; restart/configuration rules remain binding.

## Configuration and balancing options

Text authors use the documented CSV schema and explicit operations. No automatic row-skipping mode, same-file last-duplicate-wins option or implicit all-locale patch is approved. Supported live language switching remains presentation-only; patch files stay locked with installed content. There are no gameplay balancing changes.

## Save/load considerations

Patched tables and provenance are reusable content, separate from character state. Loads do not activate new CSV edits or change language solely from translated text. SAVE/UI/domain owners decide historical-text representation under DATA-013; this feature does not rewrite saved narratives or repeat events to refresh wording. Source patch application and character restoration remain distinct operations.

## Technical constraints

Target engine: Godot 4.7.2. Use explicit locale/key targeting, full-input CSV validation and staged coherent publication. Separate structural operation results from entry usability. Keep original sources read-only and preserve meaningful text whitespace. Concrete CSV library, schema, key representation, parser limits, diagnostic UI and caches remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Explicit collection/domain and locale targeting prevents accidental cross-language patching and retains package/file provenance.
2. Add-existing and replace-missing fail structurally; stable target identity remains separate from display text and other locales.
3. DATA-003 ordering applies, later valid replacements win, and duplicate target keys within one file reject that file.
4. UTF-8 quoted commas/quotes/multiline values and Windows/Unix line endings work under a documented schema with meaningful whitespace preserved.
5. Structural errors identify file/row/reason and publish no partial changes; explicit DATA-003 recovery precedes omission.
6. Invalid required formatting in a structurally valid entry uses DATA-013 fallback without silently revealing overwritten same-language text.
7. Blank/suppression and essential-label rules remain binding; missing/invalid text never changes gameplay authority or executes commands.
8. Pre-menu rebuilds are coherent; live locale selection uses validated resources without bypassing external-edit/content locks.
9. Original files and character state remain unchanged. CSV round-trip, malformed-late-row, duplicate, locale-isolation, operation and invalid-format fallback fixtures verify these rules before implementation is complete.

These are future verification criteria. No implementation, catalog/CSV fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-003/013 and approved CORE settings/recovery/restriction contracts. No contradiction identified. Whole-file structural rejection is distinct from explicitly approved entry-level usability fallback; overwritten same-language content is not an extra silent fallback tier. Live language selection does not reload contributions. Explicit add/replace narrows DFU's implicit upsert behavior under DATA-003's declared operations.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: CSV header/operation/target schema; locale-entry versus shared-key representation; normalization/BOM/optional syntax and parser limits; suppression designation; base-language ownership across overrides; exact placeholder/format rules; diagnostics/retention integration and representative fixtures. These deferrals do not waive explicit targeting, atomic structural rejection or approved fallback behavior.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-014-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including CSV schemas, normalization, token validation and integration fixtures. Approval does not initiate implementation, coding tasks or another feature review.
