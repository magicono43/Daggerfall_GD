# Structured classic text — IMP-007 increment 2

Frozen catalog/CSV/token identities remain `text-catalog-v1`, `text-csv-v1`,
`text-token-v1`. The checked binary profile is **classic-controls-v1**, reader
**text-rsc-v1**, projection **structured-text-v1**. This extends the shared token
representation; it does not reinterpret the accepted catalog brace grammar.

## Composition and lifetime

Normal startup explicitly registers bundled catalogs and enables the real
`classic-text-v1` capability before preparation. It requires `TEXT.RSC` through
`classic_access.gd`, alongside the four existing BSA/SND sources. No production
machine path/default/discovery fallback is added. Legacy fixture compositions
without this capability still require only their declared sources. New
`structured-text` fixtures exercise the actual five-source composition.

Reader factory dispatch uses declared format, never filename relabeling. Conflicting
formats for the same composed filename reject. Existing validation, unpublished
initialization, tickets, all-reader cleanup, CORE settings/activation, restart-only
source replacement and application disposal stay authoritative. Reads reopen READ
access, verify source length and return detached bytes. No source write API,
watcher, hot registration, package execution or session-owned cache is added.
Like the existing BSA reader, same-length external edits are not an immutable
snapshot guarantee; supported content changes require application restart.

## Binary evidence and addressing

Read-only DFU 1.1.1 release snapshot (exact upstream commit unavailable):

| File under `Assets/Scripts/` | SHA-256 |
| --- | --- |
| `API/TextFile.cs` | `a56a77e44e47da258cd29e8339bc2b0a35ec87922eb5e6d82facd76a262eb96d` |
| `Localization/DaggerfallStringTableImporter.cs` | `f62ceb948c22a3356b3265a9273327e6cb559514da79d3b68a4cf74ed811c46e` |
| `Game/UserInterface/MultiFormatTextLabel.cs` | `177d4aecf9dcbd90f3b1eefe381533f42157f63e474a00d523fb23c08ffd60c0` |

`TextFile.RecordCount`, `ReadHeader`, `ReadTextRecordHeaders`, `GetRecordLength`,
`ReadTokens`, `ReadFormattingToken` and `ReadTextToken` establish LE u16 directory
length, six-byte u16-ID/u32-offset entries, `(length / 6) - 1` records and FE
termination. The actual input verifies a final FFFF/file-length directory entry,
payload starting at header-length + 2, and indexed aliases.
The checked v1 reader rejects unsupported directory layouts, duplicate IDs,
reserved identities, out-of-file addresses and invalid terminal entries.
Equal addresses are explicit aliases: 1200/1201/1202 share one payload. Their
extent ends at the next distinct physical address, sorted independently of
directory enumeration order; this never searches neighboring
IDs for a missing record. Missing ID and unavailable source differ.

Observed local input `C:/Games/Daggerfall/arena2/TEXT.RSC`: 353,393 bytes,
directory length 8,454, 1,408 IDs / 1,396 distinct payload addresses, SHA-256
`cdbf1d8caced2888eac2b131185ef508de431ad3b2bb86fe973c5981164d4b52`.
Every distinct indexed extent ends with FE. These are evidence identities, not
hardcoded production counts or checksum acceptance gates. Real fixtures pin
record 25 (input cursor), 11 (five authored variants) and 1200/1201 (alias).

## Checked tokens and limits

`text_tokens.gd.decode_classic(bytes, source, record, file_offset)` returns ordered
`tokens`, separate authored `variants`, and empty-variant `diagnostics`. Each token
has `kind`, record-relative byte `position`, `absolute_position` and byte `length`.
Literal runs also have `text`; operand controls have integer `operand`.

| Byte | Kind | Operand / meaning retained |
| --- | --- | --- |
| 20–7E | `text` | Printable ASCII run, including all leading/trailing spaces, braces, backslashes and percent signs |
| 00 | `line_break` | Separate line boundary |
| F6 | `page_break` | Separate page boundary; final page closes with FE |
| F8 | `input_cursor` | Required input position marker; accepts/submits nothing |
| F9 | `font` | Exactly one unsigned byte, retained classic font identifier |
| FB | `position` | Exactly one unsigned byte, retained classic horizontal position (zero denotes tab stop in DFU) |
| FC / FD | `justify_left` / `justify_center` | Retained layout controls, distinct from 00 |
| FF | `variant_break` | Closes authored variant, preserves original zero-based ordinal |
| FE | `record_end` | Required final record boundary, no trailing bytes accepted |

Operand bytes span 0..255 and are consumed before boundary interpretation.
Truncated operands, absent FE and data after FE are malformed. Unknown bytes,
including 01/02, DEL and high-bit encoding bytes, fail as unsupported required
controls with source/record/relative/absolute position. No extended character-set
guess or decorative ignore policy is implemented. Catalog CSV remains Unicode.
Decoding a font/page/input control preserves a definition; it does not certify
that a gameplay presentation can render it. Actual fonts integrate in increment 3;
future message renderers must declare and validate their supported capabilities.

`select_classic(decoded, authored_ordinal)` only returns that explicit usable
variant. No API draws, seeds, chooses weights or selects a neighbor. Empty variants
(including whitespace/layout-only streams) retain IDs and diagnostics and are
unusable; an input marker is meaningful required structure. All-empty records fail.
No intentional-silence designation is invented for binary records.

`encode_classic(tokens, source, record)` verifies the supported source profile and
encodes literal/control bytes, then checks the whole result by decoding. Fixtures
compare exact bytes and token order/operands/boundaries. Positions regenerate from
the resulting byte stream; adjacent literal runs canonically coalesce. This is a
binary structural codec, not the human-editable translation exporter/importer,
preview/commit or authoring round-trip acceptance due in increment 4/IMP-056.
No editorial wrapping, trimming, percent expansion or catalog escape processing
occurs in binary decoding. `{`, `}`, `\\` and `%` are ordinary classic bytes.
The independent catalog grammar retains `{{`, `}}`, LF and typed references.

Encoder schema failures identify `token_position` (zero-based input token ordinal),
without inventing an absolute source-file address. Decoder revalidation failures
identify byte positions in the newly encoded record (offset zero). Reader directory
failure `position` is an absolute source-file byte position.

## Lookup and owner boundaries

`structured_text.gd.read(classic, numeric_id)` reads only published source readers.
`lookup(registry, classic, collection, key, exact_locale, mappings, required_controls)`
uses the real catalog selected/base rules, then an explicit `collection/key` →
numeric-ID mapping for exhausted ordinary text. New key names/ranges are unrestricted
by classic numeric IDs. No wording/order inference or adjacent-record substitution
exists. Invalid mappings/source/decode failures join exhausted-lookup diagnostics.
Bundled essential recovery retains its independent precedence and cannot submit
an answer, make a failed operation succeed or remove a restriction.

The optional requester-owned `required_controls` array declares the exact ordered
control/operand signature needed for that presentation. `null` requests definition
lookup only, with no interaction-usability claim. An array validates each selected,
base and source candidate; mismatches continue fallback. Text/reference runs and
implicit FE are excluded from signatures; line/page/input/layout/variant controls
remain distinct. The accepted catalog grammar cannot yet author classic controls:
such an entry fails a corresponding required signature and falls back to the
explicit mapped source. This does not revive overwritten same-locale values.
Mappings and required signatures belong to trusted requesting definitions/owners,
not executable input, live registration, translated wording or random selection.

Real records may contain raw macro templates. Decode/lookup return definitions,
not expanded display-ready instructions. No production macro expansion exists
here. Fixture-only sample record 25 substitutes `%gii` once from an explicit
literal sample value `42 {literal} %pcname`; inserted percent/braces stay literal,
with no live name generation, callbacks, quest actions, reveals or rewards.
Production registered symbols/missing context/reveal separation remain IMP-030.
Book edition/anchor rules remain DATA-018. Selected message/answer identity and
durable restoration remain gameplay/UI/SAVE owner integration obligations.

## Failure and verification scope

Failures distinguish `before_readiness`, `source_unavailable`, `record_not_found`,
`malformed_text`, `unsupported_required_control`, `empty_variants`,
`variant_unavailable`, `required_structure` and ordinary catalog `missing`.
Structural reader preparation does not eagerly claim every payload decodable;
each requested payload must pass its checked decoder before being usable.

Scenario `structured-text`, fixture `structured-text-v1`, owner
`IMP-007-structured-v1` retains all increment-1 checks plus real source decoding,
binary codec, synthetic boundaries/errors, lifecycle and required-structure cases.
See tests README and increment-2 execution evidence for final inventories/results.
Rendered output is an explicitly isolated token/sample inspector, alongside the
actual recovery/menu captures. It does not implement a gameplay input window,
font scaling, live locale switching or a general classic UI renderer.
