# Translation authoring — IMP-007 increment 4

`text-author-v1` is a new editable codec; `text-token-v1` brace syntax and
`classic-controls-v1` binary decoding remain unchanged. Runtime catalogs remain
`text-catalog-v1` CSV with the existing `text-csv-v1` header. The explicit codec
column selects the new adapter; JSON catalog envelopes remain rejected.

The editable grammar is a JSON **array**, not an object:

```json
["text-author-v1",["greeting"],["text","  Literal {braces} %name \\ and \"quotes\"  ",[-1,-1,-1]],["input_cursor",[-1,-1,-1]],["record_end",[-1,-1,-1]]]
```

Element zero is the version; element one is the ordered, unique, explicit variant
ID inventory. IDs are nonnegative integral numbers or bounded token identifiers.
Each remaining element is `[kind, value?, [position,absolute_position,length]]`.
Coordinates retain source evidence; `-1` denotes newly authored/unknown position.
JSON's escaping applies inside strings (`\\`, `\"`, `\n`, `\t`, Unicode escapes).
Whitespace between JSON elements is editorial only; literal spaces and newlines
inside strings are displayed. No trimming, Unicode normalization or macro scan
occurs. Percent/brace/markup-looking text and inserted sample values stay literal.
Arrays avoid duplicate JSON object property ambiguity in this codec.

Supported: Unicode `text`; distinct line/page/input/left/center/variant/record
controls; unsigned-byte `font` and `position` operands; explicit typed `reference`
signatures from the caller's required inventory (`name:string:plain`, `name:int:d`).
Exactly one final record end and one closing boundary per explicit variant are
required. Unknown controls/fields, NUL, invalid operands, missing/undeclared
references and malformed variants fail with source/key/token context. Limit:
1 Mi characters per author value. No production macro registry is introduced.
`sample` requires explicit typed values and inserts each once without reparsing.
No binary encoding is claimed for arbitrary Unicode. Source byte encoding and UI
capability remain separate: position, unselected variants, unmapped classic fonts
and other unsupported required presentation fail rather than disappear.

Normalization preserves token order, literal scalars, operands, explicit IDs and
source coordinates. Numeric JSON coordinates normalize to integers, JSON escapes
normalize to their scalar values, and editorial JSON whitespace is insignificant.
Binary round trips additionally use the existing ASCII/control encoder. This does
not change DATA-018 book edition/anchor rules or deliver IMP-030 macro expansion.

## Explicit import operation

`translation-import-v1` documents have `schema`, exact `collection`, exact `locale`
and at most 4096 `entries`. Each entry declares `source_id`, stable `key`, original
`base`, `optional`, `essential`, `required`, `operation` (`add`/`replace`), `source`
and `translation` author strings and a `provenance` object. Mappings are explicit;
record order, wording and neighboring IDs never identify a key. Original identity,
classification and base metadata cannot silently change. Source/translation must
retain required structure/operands and explicit variant IDs. The initial runtime
add/replace intent is retained; installing a replace CSV requires its real earlier
definition under DATA's normal validation/order.

Preview retains a copied document and complete target pointer. Selections map
stable keys to `preserve` or explicit `replace`. Unselected work is untouched.
Unchanged selected work returns `writes:0`. Changes retain translations, original
publication requirements and provenance while recording current source/requirements
and `needs-review`; removal retains `orphan` work. Explicit replacement marks
`reviewed`. Reordered sources retain mappings; duplicate source/key and ambiguous
renames reject. Exact normalized source/placeholder/structure comparison detects
changes; it cannot prove semantic equivalence or recognize an undetectable change
in an external referent. Review state does not override runtime usability/fallback.

Each operation publishes one complete **generation**: actual `catalog.csv` plus
`review.json` containing mappings, source versions, translations and review state.
The directory name is the metadata SHA-256. Both immutable files are validated before writing, flushed and reopened for byte
verification before a single flushed same-volume
`active.ini` pointer replacement publishes the generation. The pointer includes
the CSV digest. The pointer is the sole authoring visibility boundary; callers
must use `load_active`, never enumerate/promote prepared directories. Failed or
interrupted preparation leaves the old pointer authoritative. Orphan generations
and `.staged` files are ignored and retained; no destructive cleanup is implemented.
Retry verifies/reuses exact files. Corrupt/incompatible pointers, mappings or CSV
fail closed without resetting author work. No cross-file atomic replacement is
claimed: one atomic pointer selects already complete files, and native Windows
flushed replacement is inherited from CORE's storage adapter. Root leasing admits
one cooperating writer; hostile/concurrent external edits are unsupported. Stale
previews revalidate pointer, document and selected operations before publication.

## Production entry point and boundaries

Main menu/session UI exposes **Translation Import / Export**. The bounded console
exports an explicitly entered TEXT.RSC ID/key to its editable document, loads prior
work, previews text/review changes, selects operations and commits under the selected
root's `Authoring/<stable-workspace-id>`. Editing the document or workspace expires
the UI preview. It also renders an explicitly selected variant with literal sample
context, using accepted fonts/layout; unsupported required rendering returns context.
This is not IMP-056's full authoring interface. Commit returns the actual immutable
CSV path; installation remains a separate normal configuration/restart operation.
No active catalog/font refresh, MOD order change, package code, source initialization,
character/save write, RNG draw or gameplay owner callback occurs in these services.

Read-only DFU evidence: `Assets/Scripts/Localization/DaggerfallStringTableImporter.cs`
in the local 1.1.1 snapshot, SHA-256
`f62ceb948c22a3356b3265a9273327e6cb559514da79d3b68a4cf74ed811c46e`.
`ConvertRSCTokensToString`, `ConvertStringToRSCTokens`, `ExcludeFromStartTrim` and
the `TrimStart(' ')` branch establish why its asymmetric trimming/control behavior
is not copied as approval. Original source files remain read-only.

Numeric variant IDs use integral value identity (JSON `0` and `0.0` are equivalent);
string IDs remain distinct. No source ID is inferred from that numeric formatting.
Explicit JSON integer sample values normalize safely to engine integers only when
integral and exactly representable (absolute value at most 2^53-1).
