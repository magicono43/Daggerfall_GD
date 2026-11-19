# DATA-020 — Translation table import and token round-trip

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Convert supported source text into editable localization entries and back into structured messages without losing meaning or interaction structure. Give authors reviewable, non-destructive import behavior and traceable validation.

## Intended player experience

Imported translations preserve intended text/layout behavior and do not break prompts through unnoticed conversion loss. Authors can preview bulk changes, retain existing work and identify translations affected by source updates. Repeated unchanged imports are predictable and do not create duplicates.

## Confirmed requirements

DATA-020-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm semantic round-trip preservation; documented escaped editable markup; explicit import targets and reviewable atomic commit; stable idempotent reimport; retained needs-review translations after source changes; and structural/rendered verification without gameplay side effects.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Localization/DaggerfallStringTableImporter.cs` includes source-copy helpers for RSC, flats, locations, spells, items, magic items and factions with overwrite controls. Editor-specific table operations coexist with runtime conversion helpers.
- `ConvertRSCTokensToString` represents selected controls through editable markup for justification, line breaks, positioning, input cursor and subrecord/end boundaries. It inserts editorial newlines and applies leading-space trimming, with `ExcludeFromStartTrim` exceptions.
- `ConvertStringToRSCTokens` and helper parsers accept additional markup including fonts, color, scale and images. Unknown/unmatched markup can become literal text. Export's default branch states unsupported tokens are ignored, so the two directions do not establish complete symmetric support merely by existing.
- Source comments claim conversion back to original tokens; actual whitespace, escaping, unsupported-token and boundary fidelity require fixture verification.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Original-record and rendered round-trip tests were not performed. Source remains unchanged.

## Detailed rules and behaviors

### Supported round trips

Require supported source text → editable representation → structured text conversion to preserve meaningful text, whitespace, formatting operands, variant boundaries and required interaction structure. Equivalent normalized representation is acceptable; identical source bytes are not required. Normalization must have an explicit documented equivalence rule rather than hide discarded content.

Unsupported required tokens fail explicitly instead of disappearing. Any decorative degradation must retain DATA-015's explicit UI-approved policy; importer convenience cannot silently weaken required structure. Full format coverage is a verified support inventory, not a claim to understand every classic field or token.

Original files remain read-only. Import targets are authored localization artifacts, distinct from classic source data and active runtime state. Book-specific formats under DATA-018 are not automatically replaced by this generic token codec.

### Editable markup

Provide documented human-editable markup with explicit escaping for literal markup characters. Preserve meaningful whitespace. Editorial line wrapping must be distinguishable from actual displayed line breaks, so reformatting an authoring file does not accidentally repaginate required text or erase spaces.

Validate supported macros and required placeholders against DATA-016 contracts. Literal values are not recursively executed; imported text cannot become arbitrary quest/gameplay code. Exact syntax, escape sequences, normalization and token/operand schema remain technical contracts shared with DATA-015/016/UI.

### Targeting, preview and commit

Explicitly identify collection/domain, locale and source-to-stable-key mappings. Preview additions, selected replacements and conflicts before bulk commit. Preserve existing translations unless replacement is explicitly selected. Invalid imports publish no partial changes within the declared import operation.

The concrete operation boundary and safe persistence mechanism must be documented before implementation. Do not report success before the selected validated changes are durably published as required by the authoring tool. Approval here authorizes the specification, not execution of an import or overwriting translation files.

Authoring replacement selection is distinct from runtime DATA-003/014 resolution. Exported contributions must obey their declared schemas/add/replace rules and normal content lock. Running the tool does not hot-reload the active game's catalogs or bypass installed-package validation.

### Reimports and source changes

Match entries using stable keys and explicit source mappings. Reimporting unchanged source with unchanged mappings produces no duplicate entries or needless changes. Renaming or reordering records cannot silently retarget translations; ambiguous mappings require explicit resolution. DATA-011 classic spell-index collisions and other domain ambiguity remain explicit rather than selecting an arbitrary source.

Retain translation text and mark needs review when source meaning, required placeholders or structure changes. Do not automatically overwrite/delete translations for changed or removed source entries. Removal may require an orphan/stale status, but no destructive cleanup policy is approved. A needs-review status is distinct from runtime unusability: DATA-013 format/fallback rules still determine whether text can be used.

Exact change detection, reviewer confirmation and review-status storage remain authoring contracts. Automated comparison cannot be assumed to prove semantic equivalence. Retaining old text does not approve using invalid placeholders or references in a published runtime contribution.

### Verification and diagnostics

Use structural round-trip fixtures plus rendered samples covering meaningful whitespace, literal escapes, multiple variants, input controls, multiline macros and required supported scripts. Validate token order/operands/boundaries rather than relying only on similar-looking screenshots. Rendering must meet DATA-019 shaping/font coverage and DATA-015 essential interaction rules.

Report failures by source record/key and token location where available. Preview and validation must not generate live names, consume gameplay randomness, execute quests, reveal information or grant rewards. Use explicit sample context/test values where rendering macros needs context; DATA-016's pure-expansion contract remains binding.

## Relevant formulas and parameters

No gameplay formulas, ID width, fixed token inventory or normalization constants are approved. Round-trip equivalence is semantic/structural for the declared supported format, not byte identity. Exact normalization, change-detection metadata and import-size limits remain technical dependencies.

## Required data

Stable target keys and collection/locale; source record identity/provenance and explicit mappings; structured tokens/editable markup; format/macro schema versions; existing translation values; selected operation/overwrite choices; preview conflicts/validation results; source-change and needs-review metadata. Exact file/schema, source fingerprints and review representation remain dependencies.

## Inputs, outputs and events

Inputs: supported source records, target catalogs, explicit mappings/locale, import selections and validation/sample context. Outputs: editable entries, preview diff/conflicts, valid committed changes or explicit failed operation, review flags and conversion diagnostics. These are conceptual contracts, not concrete APIs/signals. Import/conversion success is not message presentation, gameplay commitment or runtime activation.

## Cross-system interactions

- DATA-003/013/014 govern installed resolution, stable text identity, fallback and patch validation. Authoring tools produce compatible artifacts without bypassing runtime contracts.
- DATA-004–012 supply domain source mappings; their identities/ambiguities cannot be replaced by display-name matching.
- DATA-015/016 define token/placeholder/macro structure and pure expansion. DATA-018 preserves book-specific edition/layout rules; DATA-019/UI/AV supply rendered font/script verification.
- DEV owns authoring/test tooling. MOD owns package lifecycle. SAVE/gameplay identities remain independent of translated wording; importing tables must not mutate characters or quest progress.

## Edge cases and failure conditions

- Leading/trailing spaces or editorial wraps differ: documented normalization must preserve display meaning; no blanket trimming justified by one classic record.
- Source contains unsupported required token: fail rather than emit a plausible incomplete translation entry.
- Literal text resembles markup/macro: explicit escaping preserves text without creating an executable/nested instruction.
- Existing translation present but overwrite not selected: preserve it. An invalid selected bulk import publishes none of that operation's changes.
- Unchanged source reimport: no new duplicates or needless modifications. Reordered source: same stable mappings, not shifted translations.
- Source meaning/placeholders/structure changes: retain text and mark review; invalid runtime formatting still uses approved fallback.
- Source removed: retain translation for explicit author review rather than deleting it automatically.
- Preview renders generated names/quest resources: use isolated sample context without live generation/randomness/gameplay side effects.

## Configuration and balancing options

Authors explicitly select mappings, locales and replacements through reviewable previews. No silent unsupported-token dropping, automatic orphan deletion or gameplay execution is approved. Exact import UI, batch grouping and optional export formats remain DEV/UI decisions. There are no gameplay balance changes.

## Save/load considerations

Authoring catalogs/review metadata are separate from character saves. Imports do not rewrite saved narratives or remap gameplay identity. Persisting tool work, source versions and review status needs a safe authoring format; runtime history/localization behavior remains DATA-013/owner scope. New catalogs activate under approved configuration rules, not as a side effect of loading a character.

## Technical constraints

Target engine: Godot 4.7.2. Separate source decoding, reversible supported codec, authoring validation/preview and commit. Keep original inputs read-only; stage changes before publication and preserve unselected translations. Concrete markup, APIs, storage/versioning, parser library and UI are implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Supported round trips preserve meaningful text/whitespace, operands, variants and required interaction structure under documented normalization without requiring byte identity.
2. Unsupported required tokens fail; editable markup provides literal escaping and separates editorial wrapping from displayed line breaks.
3. Macro/placeholder validation follows DATA-016 without gameplay side effects.
4. Explicit collection/locale/source mappings produce a preview of additions/replacements/conflicts before commit. Existing translations stay unchanged unless replacement is selected.
5. Invalid import operations publish no partial changes and never modify original Daggerfall files.
6. Unchanged reimports are idempotent; rename/reorder cannot silently retarget translations and ambiguous mappings require resolution.
7. Changed/removed source retains translation work, marking relevant changes for review; runtime unusable text still follows DATA-013 fallback.
8. Structural and rendered fixtures cover whitespace/escapes/variants/input/multiline/macros/scripts, with source/key/token diagnostics and no live random/gameplay consumption.
9. Authoring commit remains distinct from runtime content activation and character/save state.

These are future verification criteria. No implementation, original-record fixtures or rendered tests were performed during specification.

## Consistency review

Reviewed against DATA-001–019 and approved CORE lifecycle/presentation contracts. No contradiction identified. Import previews/explicit replacement preserve DATA-003 operations without requiring live catalog mutation. Retained needs-review translations remain subject to DATA-013 usability. Codec fidelity refines DATA-015/016 without weakening formatting or pure expansion, and rendered verification incorporates DATA-019 support requirements.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: codec/escape/normalization schema and supported token inventory; stable source mappings/collision resolution; import boundary/safe persistence; semantic change/review metadata; exact authoring UI/export formats; macro sample context; font/render verification and representative fixtures. These deferrals do not waive reviewable atomic imports, preserved translation work or round-trip fidelity.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-020-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including codec schemas, import persistence, review metadata and verification fixtures. Approval does not initiate implementation, coding tasks or another feature review.
