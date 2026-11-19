# CHAR-007 — Name and portrait

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Establish the player's display name and face independently of durable character identity. Support creation edits, free later renaming and explicit missing-portrait recovery.

## Intended player experience

Type a name or request editable culturally mapped suggestions. Browse race/gender portraits with Previous/Next, retain choices during navigation and adjust both in final summary. Rename freely from the character sheet while preserving identity, progress and history.

## Confirmed requirements

CHAR-007-D01–D08 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish trimmed nonblank Unicode names, duplicates, editable random suggestions, explicit classic/mod mappings, a 31-grapheme limit, extensible portraits, free renaming, creation-only ordinary portrait editing and explicit recovery.

CHAR-001 permits name/face summary edits and compatible-choice retention; Restart/exit discard unfinished state without confirmation. CHAR-002 supplies race/gender sets. DATA-017 requires isolated generation, stable name-bank identity and persistent assigned names. CHAR-006 preserves completed history despite later renaming.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/CreateCharNameSelect.cs`, AcceptName and Random handler: nonempty text is accepted; suggestions use NameHelper.FullName with race/gender. Race/gender changes clear text. ShowRandomButton reseeds shared DFRandom, excluded by approved DATA-017 isolation.
- `Utility/MacroHelper.cs#GetNameBank`: seven races use corresponding banks; Argonian uses Imperial; unknown input defaults to Breton. Intended unknown-mapping policy is explicit failure.
- `Game/UserInterface/TextBox.cs`: defaults to 31 characters and can truncate. This does not establish Unicode-grapheme safety; intended validation rejects overlong input without silent truncation.
- `Game/UserInterfaceWindows/CreateCharFaceSelect.cs#SetFaceTextures` resets face index to zero. `Game/UserInterface/FacePicker.cs` loads ten race/gender faces and wraps indices 0–9. Intended navigation retention and mod-extensible counts differ explicitly.
- `CreateCharSummary.cs` edits name/face; `Game/Entities/PlayerEntity.cs#AssignCharacter` transfers them and trims the name. `DaggerfallCharacterSheetWindow.cs`, name-button/input handlers, permits renaming. No ordinary in-play portrait editor was identified in these inspected UI paths; repository-wide absence is not claimed.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Name patterns, Unicode rendering and portrait fixtures require verification. Source remains unchanged.

## Detailed rules and behaviors

### Names

Trim surrounding whitespace and require a nonblank result. Allow Unicode, internal spaces, punctuation and duplicate names. A name is display text, never the sole entity/save identity or filesystem path.

Limit accepted names to 31 Unicode grapheme clusters after trimming. Use the same validation for typing, paste, IME input, generated suggestions, summary edits and character-sheet renaming. Do not split combining sequences or silently truncate. Invalid/overlong input shows an explanation and remains correctable; acceptance must not silently commit different text. Long accepted names can wrap/scroll in displays without altering stored text. Render names literally rather than interpret them as markup. Precise segmentation/version, control-character and glyph-coverage contracts remain UI dependencies.

### Random naming

Retain Random during name selection. Each deliberate click produces another editable suggestion; navigation preserves current text. Use owned/isolated randomness under DATA-017, without reseeding shared gameplay RNG or changing future simulation outcomes.

Vanilla mappings: Breton→Breton, Redguard→Redguard, Nord→Nord, Dark Elf→Dark Elf, High Elf→High Elf, Wood Elf→Wood Elf, Khajiit→Khajiit, Argonian→Imperial. Gender selects the supported components/pattern. Retain supported classic composition with validated DATA-003/017 overrides/additions; exact probabilities and gender-conditioned pattern fixtures require verification.

Missing/invalid mapping or generation failure reports the problem while allowing manual entry and preserving existing text. Do not silently try another culture or publish empty output. Generated suggestions must satisfy normal name validation. No uniqueness reroll is required. Once accepted, preserve the assigned text across saves, locales and bank changes rather than regenerate it.

### Portraits

Previous/Next cycles with wraparound through valid portraits for the selected race/gender. Initially provide the ten classic faces; derive count from validated definitions so mods may add/replace compatible portraits. Use stable portrait/set IDs with explicit classic-index mapping; display ordering is separate from identity.

Normal navigation and summary edits preserve the current compatible face rather than reset it to zero. Missing/unavailable selected portraits require explicit valid replacement before creation completion; do not silently choose face zero or another race/gender. Reordering a list cannot change the face. Declared visual replacement of an existing identity can change its imagery; stable identity does not prohibit explicit overrides.

### Changes in play and recovery

Allow free renaming from the character sheet using creation-equivalent validation. Invalid/cancelled input preserves the prior name. Successful rename preserves entity/save identity, progress and established biography history, including historical text that may contain an older name. Do not regenerate rewards or bank components. No fee/cooldown is introduced.

Ordinary portrait editing is limited to creation/final summary. Transformations remain CHAR-019 scope. A missing selected portrait during load is an explicit recovery exception: require the player to choose a valid compatible replacement before load completes. This is not a general in-play editor.

CORE-007/SAVE should detect missing references during preflight where possible, preserving the intact current session on failure/cancellation. If no valid replacement exists, load cannot complete. Recovery must not automatically overwrite the original save; persist replacement through normal SAVE operations. Exact recovery UI placement remains deferred.

## Relevant formulas and parameters

- Name: 1–31 grapheme clusters after surrounding-whitespace trim, with nonblank input.
- Portrait count N comes from the valid compatible set, initially ten classic faces. Previous/Next wraps across the ordered set while retaining stable identity; N must exceed zero.
- No uniqueness constraint, rename cost or gameplay bonus from a name/portrait is introduced.

## Required data

Assigned name and transient edits; independent character identity; race/gender; explicit bank/pattern mappings; stable portrait/set IDs, compatibility, display order, classic mappings and availability; content provenance and explicit recovery result. Concrete schemas/versioning remain DATA/SAVE scope.

## Inputs, outputs and events

Inputs: text/IME/paste, Random, portrait Previous/Next, summary edits, accept/cancel, rename and recovery choices. Outputs: validated candidate/assigned name and portrait, suggestions, actionable errors or compatible replacement selection. These are conceptual contracts, not approved API/signal names. Cosmetic edits do not grant resources or change character identity.

## Cross-system interactions

CHAR-001 owns creation/summary; CHAR-002 race/gender; CHAR-019 transformed appearance; CHAR-006 preserved history. DATA-017 supplies validated names/patterns, DATA-003 content precedence/lock, and relevant DATA/AV owners portrait resources. UI provides Unicode/literal rendering, controls and recovery. CORE-007/SAVE own safe loading, identity, migrations and persistence. Other consumers display assigned names without regeneration.

## Edge cases and failure conditions

- Blank/overlong input cannot pass through alternate summary/rename paths; combining sequences and IME/paste need meaningful verification.
- Duplicate names must not collide in save paths/entity references.
- Random failure preserves manual entry and existing text; no cultural fallback or navigation-triggered draw.
- Portrait reordering cannot reinterpret an old index. Empty sets block completion; one-face sets wrap to themselves.
- Missing portrait recovery cannot silently change race/gender or overwrite a save.
- Rename does not rewrite biography history. Transformations must distinguish birth portrait from effective presentation under CHAR-019.

## Configuration and balancing options

Validated mods may add/override supported name banks/patterns/mappings and compatible portraits. Do not hard-code portrait count to ten. The name limit remains 31 grapheme clusters; no unlimited-name mode, in-play ordinary portrait editor or new naming probability is approved. DATA-003 content locking remains binding.

## Save/load considerations

Persist assigned text and stable portrait identity with needed set/classic context. Bank/locale edits do not rename characters and list reordering does not replace faces. Save renames through normal persistence. Explicit portrait recovery does not automatically rewrite the original save. Compatibility/migration and recovery-state representation remain SAVE/DATA contracts. Unfinished drafts remain transient under CHAR-001.

## Technical constraints

Target: Godot 4.7.2. Separate stable identity, display text, draft edits and transformed presentation. Apply authoritative shared validation rather than only widget limits. Preserve grapheme boundaries and isolated randomness. Concrete codecs, IDs, fonts, segmentation version and resource adapters remain engineering choices. Reference source/content remain read-only.

## Acceptance criteria

1. Trimmed names reject blank/overlong input and accept supported Unicode, spaces/punctuation and duplicates, without silent truncation.
2. Creation, summary, generated suggestions and rename share 31-grapheme validation, including IME/paste paths.
3. Deliberate Random uses approved explicit mappings, including Argonian→Imperial, without disturbing gameplay RNG. Navigation preserves text.
4. Generation failure reports the issue, preserves text/manual entry and never substitutes another culture.
5. Portrait cycling wraps through compatible validated sets, initially ten classic faces, supporting mod additions/replacements and variable counts.
6. Stable identity survives list reordering/navigation; missing portraits require explicit compatible selection or failure.
7. Free rename preserves identity/progress/history and prior text on invalid/cancelled input; accepted text persists normally.
8. Ordinary face editing remains creation-only; load recovery is an explicit exception respecting CORE/SAVE safety and no automatic save overwrite.
9. Saves restore assigned names/faces without generation or index reinterpretation; biography history remains unchanged by rename.
10. Restart/exit discard unfinished choices under CHAR-001; cosmetic edits grant no gameplay effects.

These are future verification criteria; no implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001/002/006, DATA-003/017 and CORE-007/011 safety requirements. No direct contradiction identified. Missing-portrait recovery is an explicit exception to normal creation-only editing. Argonian→Imperial is explicit policy rather than inferred importer approval. Persistent names/history remain compatible with free rename. Stable IDs do not prohibit declared visual replacements or preapprove transformation rules.

## Outstanding questions and approval

No further blocking player-policy question is identified. Before implementation is complete: verify name/gender patterns and portrait fixtures; define portrait compatibility/migrations; verify Unicode segmentation/input/glyph coverage and literal handling; finalize wrapping/recovery UI and SAVE contracts. These dependencies cannot waive name validation, isolated generation or explicit missing-portrait selection.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-007-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented Unicode/resource/UI and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
