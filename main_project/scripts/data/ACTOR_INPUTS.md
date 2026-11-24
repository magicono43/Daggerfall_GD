# Actor and character input profile — IMP-009 increment 1

IMP-016 increment 1 adds the separate `actor.baseline` numeric policy and
[real CHAR owner](../char/README.md). The structural catalog below remains
unchanged and `semantic_ready:false`. CHAR qualifies only a published playable
class record's HP-per-level, explicit multiplier bits and unique mapped career
skill groups for its supported baseline. It does not execute biography effects,
qualify source-only careers, resolve ambiguous FLATS or certify creation/entry.
The numeric policy uses normal registry/MOD/loose precedence and locked provenance;
supported permanent bounds/caps/added skill IDs/ratio domains are documented by CHAR.

Version: `actor-inputs-v1`, Windows / Godot 4.7.2, 2026-11-21.
DATA-007/008 and approved GAD-01/10 govern this implementation. This is a
structural input contract. Nothing here constructs an actor, selects a custom
class biography, evaluates effects, grants items, or establishes SAVE readiness.

## Production entry and publication

The ordinary startup shell calls `StartupProviderBoundary.enable_actor_inputs()`
before source preparation. The trusted `actor_inputs.gd` adapter registers its
explicit 41-source inventory with the existing application-owned classic registry:
FLATS.CFG, MONSTER.BSA, PAINT.DAT, BIO.DAT, CLASS00..18.CFG and BIOG00..17T0.TXT.
No search for alternate installations or fallback to the DFU library exists.
Foundation containers remain separately required. Other capability declarations
and accepted text/media adapters retain their own requirements.

`actor_source_reader.gd` opens READ only, bounds intake to 16 MiB, verifies the
selected profile during preparation, closes every file, and reopens on access.
It retains path/length/readiness rather than a mutable decoded cache. Changing
source length fails; retirement disables reads. Same-length external changes
remain subject to DATA-002's restart policy, not snapshot guarantees. Preparation
is all-or-nothing under the existing classic registry; failure discards staged
readers and never publishes a partial inventory. No new library/native toolchain
is introduced.

Active declared readers supply the shipped-tier baseline through
`bundled_contributions()`. MONSTER enumeration uses the existing BSA physical
ordinal interface, then checks unique named ENEMYnnn.CFG mappings. Sources remain
distinct from package contributions. The project-authored
`res://content/actors/profile.json` is read using Godot FileAccess, including from
an exported PCK; the absolute-filesystem intake is not used for that resource.
Its provenance/license is in `content/actors/PROVENANCE.md`.

The existing `definition_registry.gd` applies baseline, ordered checked MOD folder/
ZIP contributions, then cached loose overrides. It owns candidate tickets,
whole-contribution rejection, explicit omission/revalidation and menu reservation/
publication. CORE persists history and assigns DATA only at actual menu entry.
No parallel registry or post-durable adapter callback was added. A trusted bundled
adapter can now return a checked `read` failure instead of bytes; its original
source/record diagnosis is retained as `input_failure` in a candidate issue.
Required-reference failures retain target/provider context. Earlier adapters'
default byte hook and operations are unchanged.

## Observed source qualification and deliberate blocking

The supplied installation is `C:/Games/Daggerfall/arena2`. The versioned
`tests/actor_input_source_observation.json` records all 41 filenames, lengths and
SHA-256 hashes, including rejected inputs. This is an observed installation, not
a claim of original-release authenticity. No classic payload is shipped or
committed. The DFU BIOG00 text hash is separately recorded for provenance comparison.

This installation now passes structural source preparation and definition publication. The user-approved BIOG correction below and source-gate amendments supersede earlier file-wide rejections. This does not establish gameplay semantic readiness.

- `classic-flat-conflicts-v1` permits the seven exactly observed conflicting
  groups (22785, 22788, 23040, 23342, 23438, 23443, 25488) as source diagnostics.
  Canonical six-line record SHA-256 fingerprints and complete group cardinality
  are pinned in `actor_input_formats.gd`. Source order does not select a winner.
  `flat_conflict` records retain every alternative and physical block address.
  File initialization succeeds with warnings; unique source/catalog flat queries
  return `ambiguous_mapping`. A required reference to kind `flat` cannot resolve
  to kind `flat_conflict` and still blocks preparation. Other duplicate groups,
  extra copies and changed conflict members remain rejected. Source data is unchanged.
- CLASS18 is the City Watch source, not a nineteenth playable class: DFU
  `DaggerfallUnityEnums.cs` / `EnemyEntity.SetEnemyCareer` reach index 18 for
  Knight_CityWatch, while `EntityEnums.ClassCareers` defines player classes 0..17.
  `career-source-v1` preserves the complete 74-byte source, including raw skill
  byte 35, as `career_source` / `career-source-18`. It never claims that 35 is a
  valid skill. Strict `career-cfg-v1` requests still reject it, required `class`
  references do not resolve to raw sources, and gameplay-use requests remain
  `semantic_unavailable`. Structural lookup exposes unsupported-byte diagnostics.
- `biog-dfu-ampersand-v1` adopts only DFU's omission of the 12 observed
  standalone `&` lines. The user explicitly approved this correction on
  2026-11-21. Recognition requires the declared filename/question marker, answer
  c text “Getting along with others”, no preceding effect, and immediately
  following `RR -5`. The raw line, original line number and stable question/
  answer IDs are retained in `source_annotations`; `RR -5` remains unchanged.
  Other unknown markers/contexts still reject. This is an approved compatibility
  assumption, not a claim to have proven the marker's classic executable meaning.
  No DFU equipment/reward/balance corrections or packaged text are imported.
- All 43 MONSTER ENEMY career records use the source-only career layout.
  ENEMY005.CFG contains raw skill byte 40; it remains preserved with an unsupported
  interpretation diagnostic. Player-class skill validation stays 0..34.
  The incomplete encounter metadata cannot authorize spawning or actor construction.

The user clarified that “leave it blocking” meant rejecting ambiguous mappings,
not rejecting FLATS.CFG or the installation. The user authorized the source
exception/workaround and CLASS18 follow-up on 2026-11-21. This clarification
supersedes the initial handoff's broader interpretation. No source correction,
arbitrary duplicate winner, skill substitution or automatic actor fallback occurs.

Final positive transaction verification uses the **complete real selected installation**
through the normal registered source and DATA/MOD/CORE menu path. Earlier bounded
compatible-composition evidence is historical. No substitute biography library or
classic payload copy is used for the qualified success path.

## Binary and text formats

Integers below are little-endian. Flags are preserved source integers, not an
adoption of runtime flag arithmetic. Unknown unused fields are retained verbatim.
Malformed bounds and required unsupported interpretation fail explicitly.

| Profile | Supported layout and identity |
| --- | --- |
| `flats-cfg-v1` | Lossless UTF-8/ASCII, six nonblank trimmed lines per blank-separated block: archive/record integers, caption, raw gender string, signed unknown2, signed unknown3, signed face index. Numeric source fields retain signed 32-bit bounds. Unknown duplicate groups reject the source; the pinned classic conflict subprofile preserves its known groups as non-resolving diagnostics. |
| `career-source-v1` | Same 74-byte source layout, raw skill bytes 0..255, no valid-skill or usable-career claim; used for CLASS18 and MONSTER career source metadata. |
| `career-cfg-v1` | Exactly 74 bytes, shared CLASS*.CFG / ENEMYnnn.CFG layout below. Short records are malformed; extended records unsupported. Empty/unknown names are not replaced with generic names. |
| `paint-dat-v1` | Nonempty complete 40-byte records; physical zero-based index is the classic mapping. All 40 bytes remain uninterpreted. No DFU record correction or painting-description policy is imported. |
| `bio-dat-v1` | NUL-terminated lossless UTF-8/ASCII narrative strings. Split bytes before decoding (Godot UTF-8 strings cannot transport embedded NULs losslessly). Empty source strings remain explicit records; no question/effect parser is applied. |
| `biog-text-v1` | Positive signed-32-bit question numbers and answer letters provide identities. Optional initial `#<text ID>` header is preserved; its absence remains null. Questions may continue across lines before answers. Answers have one literal line followed by checked commands. No fixed question count is imposed on added sets. |

Biography transport is selected-installation BIOG text in the DFU-style text
grammar. DFU's `API/BiogFile.cs` reads its own packaged StreamingAssets/BIOGs text;
`API/BioFile.cs` reads classic BIO.DAT narrative strings. These are **not
interchangeable formats**. No DFU-packaged biography library was copied into the
game, and no installed BIOG text is labeled original ARENA2 by implication.

### Career field offsets and units

| Bytes | Field |
| --- | --- |
| 0..3 | u8 resistance, immunity, low-tolerance, critical-weakness flags |
| 4..5 | u16 ability/spell-point bitfield |
| 6, 7, 8, 9, 10 | u8 rapid healing, regeneration, unknown1, spell absorption, attack modifier |
| 11..12 | u16 forbidden-material bitfield |
| 13..15 | Source bytes a,b,c; combined weapon/armor/shield bitfield `(a << 16) \| (c << 8) \| b` |
| 16..18, 19..21, 22..27 | Three primary, three major, six minor skill source IDs (0..34 for career-cfg-v1; raw bytes for career-source-v1) |
| 28..43 | 16-byte name storage, retained; display name ends at first NUL |
| 44..51 | Eight unknown2 bytes, retained |
| 52..53 | u16 hit points per level, preserved input units |
| 54..57 | u32 advancement multiplier in unsigned 16.16 fixed-point source units; no DFU rounding applied |
| 58..73 | Eight u16 attributes in source order; no derived stats or actor initialization |

Evidence: read-only DFU API/FlatsFile.cs, ClassFile.cs, DFCareer.cs,
MonsterFile.cs, PaintFile.cs, BioFile.cs and BiogFile.cs, plus actual input
inspection. `Utility/EnemyBasics.cs` separately supplies MobileEnemy properties
and animation tables; `Game/Entities/EnemyEntity.cs#SetEnemyCareer` combines career
data with level/health/armor and random owner operations. Consequently
`encounter_career` is **incomplete structural metadata**, not a complete enemy
definition. ANC payloads remain available through raw BSA access; their unknown
interpretation is never promoted into actor behavior.

## Definition schema and identity

Domain `actor.inputs`, logical resource `catalog`, standard DATA-003 JSON
envelopes and add/replace/patch. Record value:

```json
{"schema":"actor-inputs-v1", "kind":"appearance",
 "data":{"resource":"author/sprite/500000/200"}, "references":[]}
```

Kinds: profile, flat, class, encounter_career, painting, narrative, biography,
appearance, actor, flat_conflict and career_source. Each has checked fields in `actor_inputs.gd`; unknown required
fields reject. Optional top-level `unused` is a dictionary of explicitly
uninterpreted metadata, never a place to request execution. Optional `classic`
is an explicit canonical mapping for supported source kinds. `input` contains
verified baseline provenance, not an author-controlled claim of classic origin.
The trusted adapter retains source receipts per candidate and rejects forged or
removed receipts on matching baseline replacements. Registry contributor/field
winners separately identify modifications.

Classic IDs: `flat-<packed>`, `class-<two-digit number>`, `enemy-<three-digit
number>`, `painting-<ordinal>`, `narrative-<ordinal>`, `biogNNtN`. Numeric mappings
must be canonical: `0` cannot alias class `00`; negative/ambiguous mappings fail.
Classic set/question/answer identities use source filename, `q<number>` and
literal answer letter. Full choice identity includes the stable set definition
key; changing text or array order cannot remap a selected answer.

Known conflict markers retain `flat-<packed>` as a diagnostic identity, not a
valid flat mapping. CLASS18 uses separate `career-source-18`, kind `career_source`,
and never implicitly resolves a `class-18` playable-class request.

Registry keys remain `{domain, package, local, record}`; e.g.
`actor.inputs / @shipped/actor-inputs-v1 / catalog#class-00 / class-00`.
Added records use the adding package's origin. Matching replacements preserve
that identity and retain prior contributors. Replace resets the entire record
set, preserving matching identities; patch replaces complete top-level fields,
never recursively merges lists/objects. Schema/kind/classic/source receipts cannot
be changed by patch. Deletion is not a patch operation. Canonical source mappings
are unique per kind, validated after complete contribution resolution.

`pack_flat(archive, record)` accepts integer archive 0..16777215 and record
0..127; maximum is signed packed ID 2147483647. This only describes the legacy
adapter. Added appearance and actor IDs/resource references have no packed-flat
limit. An actor explicitly references its separate appearance and career, plus
matching typed `references`. Sharing an appearance never shares gameplay identity
or mutable actor state. Replacing an appearance cannot patch the actor's career.

References are required `{id, kind}` links in this single checked catalog. The
baseline declares class-to-biography and biography-to-class links explicitly for
00..17; class18 has no invented biography choice. Missing/mistyped targets return
referring catalog key, target and winning provider. Omission never suppresses a
remaining mandatory reference failure or removes the required shipped profile.

## Biography effects

Typed declarations contain exactly `type`, `target`, `parameters`,
`classic_command`, `required:true`. Validation reconstructs the declaration from
its command and checks exact fields, permitting JSON's integer-valued numeric
transport. Tampering a target/amount/type independently fails. No optional unknown
effects or silently skipped required commands exist.

BIOG data also carries `source_annotations` (empty unless the approved correction
was applied). Each correction receipt contains `profile`, `source_file`, `line`,
`raw_text`, `question`, `answer`. It records original-source context, not executable
instructions or current effect arithmetic. Verified baseline receipts must survive
replacement/patch; new contributions cannot fabricate a corrected classic origin.

| Command input | Structural type / required parameters and target |
| --- | --- |
| `<skill> <signed amount>` | skill_adjustment; classic.skill:0..34; signed 32-bit amount |
| `GP <signed amount>` | gold_adjustment; player; amount. Source `GP + 100` spacing remains in classic_command; no reward arithmetic is performed. |
| `IT <group> <index> <material>` | item_grant; explicit classic.item:group/index; three nonnegative signed-32-bit parameters. ITEM legality/availability is a separate required owner gate. |
| `r<0..4> <amount>`, `rf<ID> <amount>` | social_reputation / faction_reputation; explicit source target; amount, faction ID 0..65535 |
| `RP`, `FT`, `RR`, `RD`, `MR`, `TH` plus amount | poison/fatigue/reaction/disease/magic/avoid-hit modifier declaration; player; amount |
| `#ID`, `!ID`, `?ID` | narrative_token; text.rsc:ID (0..65535); channel and text_id |
| `AE`/`AF <M/O/F> <int> <int> <int>` | classic_ae_declaration / classic_af_declaration; character.effect_owner; source selector and three signed-32-bit ordered operands. Their arithmetic is deliberately unimplemented, as in the inspected DFU dispatcher. |

Malformed arguments fail with source line and question/answer context. Unknown
required commands (including `&` and AO) are unsupported. No custom-class affinity,
tie/no-match rule, default backstory ID, class-zero fallback, application order,
random reward rule or preview result is inferred. Effect target owner resolution
is not fabricated from these source addresses.

## Readiness and immutable projections

`classic.read_record(file, "@all")` returns detached structural records;
individual string source keys return independent detached values. Missing keys,
unavailable sources, malformed input, unsupported interpretation and premature
reads have distinct unsuccessful kinds and source context. Ordinary registry
lookup remains unavailable until the actual menu publication.

`ActorInputs.lookup(registry, id)` returns a detached registry record plus
`structural_available:true`, `semantic_ready:false`. `lookup_classic` resolves
only explicit unique mappings and never defaults to class zero. Any lookup use
other than `structural` fails with `semantic_unavailable`, definition identity,
target use and provider. There is no production validation provider in this
increment, no controlled validator that can turn this gate green, and no implicit
actor/effect “usable” outcome. Downstream owners must introduce their real checked
validation interfaces at IMP-015/016 and effect/target integrations before use.

All reads, patches, reference checks and published queries use deep independent
views. The adapters have no live RNG/session/instance allocator imports and make
no calls to gameplay owners. Verification compares unchanged CORE session and
active definitions after repeated reads/validation. Actual preview/application,
startup effect ordering/idempotence, random-stream policy and SAVE restoration
remain real-owner integration obligations, not passing adapter assertions.

Verification commands, exact inventories, source rejections, reviewed captures,
exports, regressions and cleanup are recorded in the IMP-009 execution evidence.
