# Text catalogs — IMP-007 increment 1

Increment 2 adds [structured classic text](STRUCTURED_TEXT.md) through a distinct
real reader and an extension of the shared token representation. Existing catalog
grammar/identities and CSV semantics remain frozen. `lookup` now optionally accepts
an exact requester-owned required-control signature; incompatible locale entries
continue selected/base/source fallback without reviving overwritten values. The
earlier increment-1-only scope statements below retain their delivery history.

DATA owns `text_catalog.gd`, `text_csv.gd` and `text_tokens.gd`. The normal startup
shell explicitly calls `StartupProviderBoundary.register_bundled_text()` before
source preparation. This registers the real `text.catalogs` domain in the existing
definition registry. No TEXT.RSC source is declared or read in this increment.
Legacy verification compositions retain their explicit adapter selection; the new
`text` scenario uses the production text adapter and real CORE/MOD/DATA entry.

## Identity, schema and intake

Frozen identities: **text-catalog-v1**, **text-csv-v1**, **text-token-v1**. CSVs
are real CSV contributions, dispatched by physical `.csv` extension to the
registered reader. They are not JSON envelopes or BSA records. JSON cannot target
the text domain: its `json_envelopes=false` declaration rejects the entire
envelope before record iteration, including an empty destructive replacement.

The exact header, in order, is:

```csv
schema,codec,collection,locale,key,operation,base,optional,essential,placeholders,suppress,value
text-catalog-v1,text-token-v1,sample,en,greeting,add,en,false,false,name:string:plain,false,Hello {name:string:plain}
text-catalog-v1,text-token-v1,sample,zz-Test,greeting,add,en,false,false,name:string:plain,false,Sample {name:string:plain}
```

Each data row declares both versions, target and operation. Unknown versions,
headers, column counts, operations and invalid metadata reject the whole file.
Boolean spellings are exactly `true`/`false`. No implicit metadata inheritance,
upsert, delete, rename, wildcard, all-locale operation or locale alias exists.

- Collection: shared MOD stable-ID validator (1–128 lowercase ASCII
  letters/digits/dot/underscore/hyphen, initially alphanumeric). It becomes the
  normalized logical resource path `text.catalogs:<collection>`.
- Key: 1–128 ASCII letters/digits/dot/underscore/hyphen, case-sensitive and exact.
  No trimming, case folding or Unicode normalization. Collection + key identifies
  one shared definition; its `entries` dictionary separately tracks locale presence.
  The origin's GAD key retains domain/package/local (`collection#key`) and author
  record ID, with collection/key projections alongside it.
- Locale and base: 1–64 ASCII letters/digits/hyphen, initially a letter, exact and
  case-sensitive. These are declared identifiers, not OS/BCP-47 negotiation. No
  neighboring/regional/cross-collection search. Regional mappings are unsupported
  in v1; a later explicit mapping schema must validate before enabling any.
- First creation declares the key's immutable base, required-reference set and
  optional/essential flags. Every later translation row must agree. New keys may
  declare a non-English base. Adding a translation does not recreate the key.
- `add` requires absence of that exact locale entry; `replace` requires presence.
  A different locale's entry cannot satisfy either condition. Replacements retain
  original key identity/base/origin. Same-file duplicate collection/locale/key
  targets reject even if identical. Ordered files may replace the same target.

Source order is the accepted DATA-003 pipeline: bundled defaults, declared shipped
files, enabled packages in resolved MOD order, explicit loose `Overrides/` last.
Physical paths use the existing normalizer and normalized file order. Rows retain
source order. Package folder/ZIP reads, integration eligibility, source limits,
link/collision checks and loose first-intake retention are unchanged. No package
code runs. Each file applies to a deep copy; any structural failure discards all
its mutations. Other valid files may appear in a failed diagnostic candidate but
none publishes. Omission uses existing source tokens/tickets and clean rebuilds;
it cannot bypass dependencies or required resources. Actual CORE menu entry locks
these resources with the MOD plan and other DATA definitions. Read projections
are copies. Direct authoring/hot reload is not introduced.

The bundled English asset is `res://content/text/recovery.csv`, read through
Godot FileAccess, including from an exported PCK. Its committed `.csv.import`
selects `keep`, preventing Godot's unrelated translation-table importer from
interpreting these schema columns as languages. The export include filter retains
the raw CSV. Bundled source provenance uses `@shipped/text.catalogs.v1`, virtual
root `res://content/text`, file and schema version; subsequent package/loose
provenance uses the existing checked physical sources. No machine-specific root
or new library/license/native option is required.

## CSV transport and diagnostics

Complete UTF-8 only; one optional leading UTF-8 BOM is accepted. Invalid scalar
encodings, overlongs, surrogates, truncated sequences and NUL reject before engine
decoding. ASCII is a subset. CSV accepts quoted commas, doubled quotes, empty
fields and quoted multiline fields. LF and CRLF record/embedded line endings
normalize to LF. Bare CR rejects. Meaningful leading/trailing spaces and tabs
remain unchanged. No comments, blank-row skipping, permissive regex matching,
trailing garbage after quotes or whitespace trimming around metadata is supported.
An optional final record terminator adds no extra row; a blank physical row is a
row and fails the schema. Quotes must begin a field; only comma/newline/EOF may
follow closing quotes (or a doubled quote inside the field).

Bounds: 16 MiB encoded input, 100,000 logical rows including header, 262,144
Unicode scalar positions per field, 32 parser columns (schema requires 12).
UTF-8 failures report the zero-based byte offset in the reason, with predecode
line/column 1/1. CSV syntax failures report one-based physical line/column.
Schema failures report one-based logical row (header = 1) and physical start
line; file/provider/root/token are retained by DATA's issue wrapper. Winning entry
provenance adds collection/key/locale, logical row and physical start line.
Usability failures retain zero-based scalar/token-parser position and reason.
These diagnostics are values; lookup never opens a popup or mutates a log/cache.

## Usability and lookup

`TextCatalog.lookup(registry, collection, key, selected = "en", fallback = "")`
returns text, kind, tokens, stable identity/origin, source/winner, attempted locales
and failed-attempt diagnostics. Registry may be null during essential recovery.
It never publishes a candidate or changes an operation's authoritative result.

Try usable selected text, declared base text, explicit usable caller/source text;
skip a repeated selected/base locale. Missing, all-whitespace and malformed
reference entries fall through. Returned values preserve original whitespace.
An invalid translation is still the winning resolved entry and keeps provenance;
there is **no** overwritten same-language fallback tier. A usable caller fallback
must satisfy the same required references. Exhaustion returns `kind=missing`,
`ok=false` and visible `<Missing text collection/key locale=... source=...>`.
Missing-key/candidate-unavailable diagnostics retain source context. `ok` describes
text resolution only, never operation permission/success.

Optional suppression requires `optional=true`, `essential=false`, `suppress=true`
and an exactly empty value. It returns `kind=suppressed`, empty text, and stops
fallback. Essential/ordinary suppression is a structural failure. Blank ordinary
values, including replacements, do not delete or suppress anything.

`RECOVERY` enumerates eleven keyed essential controls: Retry, Quit, Choose Folder,
Continue, Cancel, Return to Setup, standard-storage fallback, preserve/reset
settings, Save and Continue, Continue for This Run, retry saving preferences.
`StartupShell.essential_button(key, action, container)` submits an explicit stable
key, never derives identity from displayed wording. Startup, session recovery and
MOD continuation callers reuse it. English constants independently retain usable
labels if the registry/classic/optional catalogs are unavailable or selected/base
text is unusable (`kind=essential_fallback`). Required key/classification/base-entry
presence validates before publication; invalid individual text still uses fallback.
Other existing static recovery instructions/controls remain bundled GDScript
English. This increment does not claim their complete localization or font shaping.
Text failure never removes a control's existing restriction/callback guard.

## Initial token grammar and later increments

`text-token-v1` currently parses literal Unicode text, tab, LF `line_break`, and
typed references `{name:string:plain}` / `{name:int:d}`. The CSV `placeholders`
field is a `|`-separated required signature set (empty for none); declaration order
is normalized by sorting. Every required signature must occur at least once;
repetition and reordering are allowed, unknown/type/format-changed references fail.
`{{` and `}}` escape literal braces. Percent syntax and inserted-looking strings
such as `%pcname` are literal; no classic macros execute. Other unescaped braces
and C0 controls except tab/LF make an entry unusable. Raw text and parsed token
projections are separate. There is no interpolation, recursive expansion,
pluralization, rich-text execution, name generation or RNG dependency.

Source evidence inspected read-only: DFU 1.1.1 `Assets/Scripts/API/TextFile.cs`
Formatting/Token/ReadTokens and `Localization/DaggerfallStringTableImporter.cs`
conversion helpers. TextFile SHA-256
`a56a77e44e47da258cd29e8339bc2b0a35ec87922eb5e6d82facd76a262eb96d`;
importer SHA-256
`f62ceb948c22a3356b3265a9273327e6cb559514da79d3b68a4cf74ed811c46e`.
Classic evidence distinguishes newline 00, page F6, input F8, font F9,
position FB, justification FC/FD, record FE and variant FF. Their operands and
boundaries cannot be flattened to catalog literals. Shared structured envelopes
will retain codec identity, explicit source/record and ordered variants/tokens;
typed controls carry kind/operands and source positions. Those control kinds are
reserved, **not accepted/decoded here**. Inc-2 must verify exact mappings and
extend the checked supported inventory before use; unknown required kinds fail.
No TEXT.RSC readiness, structured export/import round trip, input/variant renderer
or editorial-wrap normalization has been verified. Inc-4 owns authoring codec
acceptance. Book editions/anchors remain DATA-018; production expansion IMP-030.

## Prepared locale/settings boundary

Increment 1 defaults all normal callers to explicit `en`; it does not inspect OS
language or advertise `zz-Test` as a supported language. The second locale is a
synthetic catalog fixture only. Reserved CORE setting ID `presentation/locale`
will be TYPE_STRING, default `en`, live presentation timing, persisted through
CORE-003 and accepted only against already loaded validated catalog **and font**
resources. It is not declared/exposed in CORE yet: inc-3 supplies the real font
validator, declaration and coherent reflow consumer before Apply can affect it.
Persisted unavailable requests must retain truthful accepted/effective recovery
under CORE-006. No locale request can call MOD edits, DATA rebuild/publication,
formula registration or RNG initialization. Installing/editing packs remains
configuration/restart work. Inc-4 mod preferences use their own stable identities.

Verification: shared `text` / `text-v1`, owner fixture `IMP-007-catalog-v1`, fixed
121 headless / 127 rendered checks. See tests README and increment execution
evidence for commands, retained report identities and deferred integrations.
