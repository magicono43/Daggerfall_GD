# Definition publication — IMP-005 increment 3

IMP-007 increment 1 adds the production `text.catalogs` adapter and
[`text-csv-v1` intake](TEXT_CATALOGS.md). `.csv` contributions dispatch to that
registered reader; existing JSON schemas/operations are unchanged. The normal
shell registers bundled text explicitly before preparation. Adapter-owned bundled
contributions are shipped-tier bytes read from the PCK; filesystem declarations
continue to use the checked physical transport below. The earlier absence-of-
production-schema statements describe the IMP-005 delivery, not current text
readiness. Text availability does not establish later media/world/gameplay schemas.

`StartupProviderBoundary.definitions` owns `definition_registry.gd` for the
application. CORE owns the menu-entry transaction; MOD owns the selected plan and
profiles. This service does not decode classic records, implement a game domain,
execute package code, or establish SAVE compatibility. Classic readers remain
in their separate application-scoped registry. Normal consumers receive copies.

## Trusted adapter registration

Before classic preparation, call
`register_content_adapter(adapter, absolute_shipped_root, declared_files)` on the
startup provider. Registration enables that adapter for this startup. Each domain
has one owner. Required classic sources join `classic.register_adapter` and
`enable_capability` before any reader initializes; unsupported formats reject
registration instead of being relabeled as supported. The delivered classic
registry supports `bsa-v1` and IMP-007 increment 2's real `text-rsc-v1`.
See [structured text](STRUCTURED_TEXT.md). Later owners must supply real checked readers for
their formats. Late registrations reject without switching/reconstructing active
classic indexes. Adapter callbacks are trusted application GDScript, never loaded
from a package.

Adapter interface:

| Method | Required result |
| --- | --- |
| `declaration()` | Stable `id`, `domain`, supported `operations` (`replace/add/patch`), optional `required_resources`, `capabilities`, `classic_sources` |
| `validate_record(id, value)` | Empty string on valid complete value, otherwise reason |
| `patch_record(previous, fields)` | `{ok:true,value:complete_record}` or `{ok:false,reason}`; explicit null/nested/list policy belongs here |
| `validate_references(resources)` | Array of failures with source/reason; may identify introducing contribution token and whether it may be explicitly omitted |

`json_envelopes` defaults to true for existing adapters. The production text
adapter explicitly declares false: even an empty JSON envelope cannot reset a
CSV catalog or bypass entry validation. Its versioned CSV reader owns operations.

Adapter declarations and validators/patch callbacks are synchronous and pure over
their supplied data copies; they must not yield or submit MOD/CORE state changes.
An asynchronous adapter needs its own checked ticket contract before integration.

Required resource names use the shared MOD relative-path validator. Combined
reference validation receives a deep copy of all domains, after all selected
contributions. An unresolved required resource/reference blocks publication even
after omission. Unknown operations do not acquire universal merge/delete semantics.
No adapters are enabled implicitly: the ordinary build without production domain
adapters reports `adapters_unavailable`. Bounded fixture adapters are registered
only through the explicitly isolated verification launch path. No IMP-007–010
production text/media/authored/world schema has been invented.

## Sources and explicit contributions

Order is shipped defaults, each enabled package in the validated MOD order, then
the active CORE root's **`Overrides/`**. Default sources are explicitly declared
relative JSON files under adapter-owned, read-only absolute filesystem roots.
This is a filesystem intake transport, including exported installations; virtual
`res://` archive intake is not claimed by this transport. Future domain owners
must choose/verify their shipped transport with their assets.

Packages declare `content` as an array of relative JSON paths, or objects
`{"file":"relative.json","integration":"package.id:0"}`. An integration key must
belong to that package's declared relationship. Inactive optional integrations
leave their dependent files unread/unapplied. Ordinary unconditional contributions
remain active; suppression does not disable the entire mod. Required package
capabilities must have a registered implementation. Unknown capabilities, including
Luau/trusted-GDScript executable capabilities, block entry; omission cannot bypass
them. No executable activation, sandbox, lifecycle or window registration exists.

Within each source, files sort by normalized relative path; manifest enumeration
order is not precedence. Declared entries inside a file retain their order.
Duplicate normalized physical paths invalidate both copies and cannot be omitted
to select an arbitrary winner. Loose intake recursively enumerates only ordinary
directories; unsupported files, links, access failures and path collisions block
instead of becoming a successful empty override set. Missing Overrides means
explicitly no optional overrides. Required declared shipped files differ: missing
is a failure. No source is extracted, and package reads use MOD's checked boundary.

Normalization reuses `package_library.gd.relative_path`: `/` separators and
lowercase lookup, no absolute/escaping/dot/empty components, ADS/drive syntax,
Windows reserved device names, trailing dots/spaces or control/metacharacters.
JSON is UTF-8 without BOM, using the existing Godot JSON dialect (including its
last-value duplicate-property behavior). Files are bounded to 16 MiB by the
filesystem intake; normal package bytes retain the package access contract.

Loose file catalog/bytes and root failures are retained at first intake for the
application. Later pre-menu MOD rebuilds do **not** adopt loose edits, additions
or removals; restart is required. Loose-root repair likewise requires restart.
This is not an immutable/concurrent-filesystem snapshot guarantee. Package
repair/adoption remains explicit pre-menu Rescan/rebuild. Shipped declared inputs
are reread on rebuild so source failures remain truthful.

Envelope example (fixture domain only):

```json
{
  "domain": "fixture.records",
  "path": "items/main.json",
  "operation": "patch",
  "entries": [{"id": "sword", "value": {"power": 7}}]
}
```

Domain plus normalized logical `path` identifies the resource, independent of its
physical contribution file. Same basenames in different directories remain
distinct. A stable definition identity is `{domain, package, local, record}`:
`local` is `<normalized logical path>#<author record ID>`, and `record` retains
the exact author ID. This scopes local keys without renumbering records. Ordinary
package additions use that package ID; reserved non-manifest namespaces
`@shipped/<adapter ID>` and `@loose` avoid collisions with installed package IDs.
Matching replacements/patches preserve the original definition key and separately
record replacing/contributing provider identity.

## Operations, atomicity and provenance

`replace` resets the whole resource's record set where the adapter supports it;
matching record IDs retain prior origin. `add` requires unused target IDs and
`patch` requires existing IDs. Add/replace duplicate IDs are invalid; repeated
patch entries apply sequentially to the same record. Invalid late entries reject
**all** mutations from that file. All work is isolated on copied candidate state.
Other valid files may be visible in a failed diagnostic projection, but none of
that failed candidate can publish or satisfy normal definition reads.

Patch behavior is delegated to the domain adapter. The bounded fixture schema
implements omitted-field retention, supplied-field replacement, whole list and
nested-object replacement, null only for its explicitly nullable/ref fields,
and no deletion/deep merge. It is not a production game schema or an implicit
policy for every future content type. Adapters requiring finer nested/element
provenance must extend their explicit contracts before enabling those policies.

Each resource and record retains ordered contributors and latest applying winner;
each top-level field retains its winning source. Sources include provider,
physical root, normalized file, version and contribution token. Required combined
references are validated after all files. The fixture adapter reports the token
of the contribution that introduced an unresolved reference, so its entire file
can be explicitly omitted and rebuilt. Tokens are run-local content/source
fingerprints, not SAVE compatibility IDs.

Failures distinguish missing, unreadable, invalid paths, ambiguous paths, schema/
operation rejection, references, unsupported capabilities and unavailable adapters.
The UI reports source/reason and offers explicit omission only where permitted.
Shipped source, path-ambiguity and required-reference/source failures cannot be
waived by an arbitrary skip. `omit(token,ticket,mods)` requires the current failed
candidate and current MOD inputs/revision; it clears the candidate. The next
prepare rebuilds from clean defaults and validates the remainder. Any MOD revision
change clears omission choices; a changed file/version also has a new fingerprint.
No invalid file is silently skipped and no complete mod is silently disabled.

## Candidate, entry and lock boundaries

`prepare_content(mods)` calls DATA preparation only with the real valid MOD plan.
Every build starts clean, retires the prior ticket and returns `stage=candidate`,
`ready=false`, ticket, MOD revision/profile/input fingerprint, selected package
metadata, resolved resources/provenance and issues/omissions/inactive integrations.
`query(domain,path,id)` returns `before_readiness` until actual entry; afterward
it returns a copied record or a distinct missing result. Candidate success is
not definition publication. There is no character-specific definition registry.

CORE `continue_to_menu` first rebuilds/validates. Dirty profiles require explicit
`save` or `run`; neither path persists invalid content. The normal UI labels them
Save and Continue / Continue for This Run. A valid startup with no edits retains
the approved optional-setup preference; required failures always remain in setup.

The checked entry sequence is synchronous and does not yield:

1. Rebuild DATA from current validated MOD inputs.
2. Reserve normal MOD mutation requests and the exact DATA candidate ticket.
   Publication-failure checks occur here. Reentrant edits/preparation/Continue
   reject as busy; no obsolete callback can replace the reserved candidate.
3. Ask the menu provider for its checked creation/readiness result. Failure
   releases reservations and enters menu recovery, with no DATA publication,
   profile/history advancement or run lock.
4. Stage/verify/replace one profile store using the existing process-leased,
   flushed atomic replacement. Save and Continue includes pending edits;
   Continue for This Run preserves saved entries. Both include successful-profile
   history **only in this checked menu-entry transaction**, never on ordinary
   profile Save/selection. Failure retains committed storage, pending edits and
   uncommitted DATA and releases reservations.
5. With no fallible I/O/callback remaining, publish the reserved DATA state,
   lock MOD to its exact plan/selected package metadata, record CORE menu entry
   and present the actual title. This is the logical menu commit, not a claim of
   physical power-loss atomicity between RAM, a display frame and disk.

The final assignment steps cannot independently reject normal requests after
the durable profile step. Controlled publication failure is injected before
reservation, not after a half commit. A repeat Continue at the menu is idempotent.
Failed entry does not expose invalid definitions or a falsely locked plan.

Pre-menu MOD-only rebuilds reuse published classic readers without repeating
source preparation or constructing temporary indexes. Explicit source selection
still validates through IMP-004; the provider's diagnostic preparation counter
lets the fixture verify that unrelated rebuilds do not call it.

Returning to title, changing characters, controlled CORE load entry or opening
post-entry Setup cannot unlock/rebuild/replace the published configuration. MOD
projections use retained active metadata after locking. Runtime source changes
remain restart-only under IMP-004. Session cleanup never disposes DATA/classic
readers; application shutdown disposes them before releasing storage. Restart
creates new editable owners and revalidates persisted profiles/current loose input.

`publish_packages(classic)` remains a rejecting legacy direct-publication call;
normal production startup uses `prepare_content` and the checked commit above.
Preserved controlled startup/classic fixtures explicitly opt out of the real
pipeline for their named interface tests and do not qualify real publication.

SAVE receives the eventual read-only active plan/package/definition-provenance
context through its later compatibility integration. No `save_compatible` success
is fabricated, and CORE's real SAVE/CHAR/WORLD providers remain unavailable.
IMP-007–010/061 schemas and IMP-050/051 executable activation are still required
from their owners. Passing bounded schemas does not close all M1 requirements.

## Formula publication participant — IMP-006 increment 3

The same startup provider now owns RULE's formula registry. Formula preflight uses
the real MOD plan before DATA validation; actual menu entry reserves both exact
candidate tickets. Menu/profile failure releases both reservations. After the
existing durable profile/history step, DATA and formulas publish by assignment
and MOD locks to that plan before CORE exposes the actual menu. Empty registries
lock too. No callback/I/O is added after the durable step. Returning to title/setup,
loading or changing preferences cannot replace the registry.

Formula failures have a separate explicit provider-level omission unit and clean
rebuild. This does not omit a DATA file or disable a package. MOD dependencies,
remaining registrations and DATA candidates revalidate on Continue/rebuild.
Invalid plans discard obsolete formula candidates. The initial hook has no DATA
formula-reference schema; real dependent owner schemas remain later integration.
See [RULE's concrete formula contract](../rule/FORMULA_DISPATCH.md).
