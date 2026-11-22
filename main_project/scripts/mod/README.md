# MOD package, profile and dependency contracts — IMP-005

IMP-009 increment 1 adds [actor/character input contributions](../data/ACTOR_INPUTS.md)
under capability `data.actor-inputs-v1`. The same checked folder/ZIP and loose
intake, explicit omissions, candidate tickets and run-long locks apply. This adds
no executable activation or gameplay semantic provider.

IMP-008 increment 2 adds real [media exports/replacements](../data/MEDIA_REPLACEMENTS.md)
through checked `content` declarations, not previously retained manifest metadata.
The pre-menu Content Diagnostics button shows the actual rebuilt candidate and
its contributors/field winners. MOD's `discovery_generation` changes only on an
explicit rescan and distinguishes media payload source adoption from order/profile
edits. Existing dependency/profile/save/run-only/main-menu lock rules remain intact.

IMP-007 increment 1 adds real versioned CSV entries to manifest `content` and
loose DATA intake under [TEXT_CATALOGS.md](../data/TEXT_CATALOGS.md). MOD still
owns package identity/order and checked reads; no CSV activates package code or
changes profiles/preferences. Increment 4 now supplies the separate application
[preference definition/store/editor contract](PREFERENCES.md).

Increment 3 now supplies the separate
[DATA/menu publication contract](../data/DEFINITION_PUBLICATION.md). Validated
dependency planning is still distinct from candidate definitions, persistence and
actual menu commitment. The earlier increment boundaries below retain their scope;
the real DATA pipeline is no longer absent, while normal domain adapters and
executable/SAVE integrations remain unavailable until their owners deliver them.

`StartupController.mods` is an application-owned `mod_configuration.gd`, created
after CORE has selected and leased its storage root. It reads only that root's
`Mods/` and `settings/mod_profiles.json`. Standard, portable and explicit fallback
therefore have independent libraries and profiles. Missing Mods is an empty
library; discovery does not create it. No watcher, extraction or code execution
exists. DATA's application-scoped classic registry remains independent.

## Discovery and manifests

`package_library.gd.scan(root)` returns `ok`, candidates and path/reason
diagnostics. Root inspection/enumeration failure returns `root_unreadable`, one
root path/reason and Retry / Continue without mods for this run / Quit. It never
claims descendants were inspected. Unreadable grouping subtrees have their own
diagnostic. Individual invalid packages are excluded; other packages remain.

Ordinary grouping directories recurse in sorted, case-sensitive path order,
without contributing priority. Any immediate case-insensitive `mod.json` entry
establishes a folder package boundary, including an invalid manifest or manifest
directory. Canonical spelling `mod.json` is required. Its descendants cannot be
independently discovered. Directory reparse points/junctions are skipped and
reported. Reparse points or hard-linked files inside installed folders reject
the package. The Windows adapter's read-only `inspect` operation uses native
attributes and file link counts; failure stays a failure. No native build pin or
dependency changed. This is checked disk access, not a hostile concurrent-file
mutation snapshot guarantee; changing installed content during the run is
unsupported. Each package reference rechecks its path components before reading.

ZIPs must have root `mod.json`. Wrapper folders get an explicit ZIP-root
diagnostic. Central and local entry names/flags/methods must agree. Supported
archives are single-disk, unencrypted, non-ZIP64 ZIPs with stored or deflated
entries. Reject malformed/bounded-directory failures, Unix symlink attributes,
escaping entries and ambiguous normalized paths before reading the manifest.
ZIP64/multidisk/encrypted/unsupported compression is diagnosed, not extracted.
Read manifest/resource payloads must match central-directory length and CRC32;
an incomplete/corrupt read is never reported as a successful empty resource.
Entry names must round-trip UTF-8 (ASCII is a subset). Both forms use UTF-8 JSON
objects without BOM; manifests are bounded to 1 MiB. JSON uses Godot's parser
dialect; duplicate object properties follow that parser's last-value behavior.
Unknown manifest fields are retained as metadata and confer no activation rights.

Required fields:

| Field | Version 1 contract |
| --- | --- |
| `manifest_version` | Numeric integer value 1; strings and booleans rejected |
| `id` | 1–128 lowercase ASCII letters/digits/`.`/`_`/`-`, first character alphanumeric |
| `name` | Nonblank string, at most 200 characters, no C0 controls |
| `version` | Three nonnegative decimal components without leading zeros; optional dot-separated ASCII alphanumeric/hyphen prerelease and build identifiers; maximum 128 characters |

Optional `dependencies` is an array of objects with provider `id`, boolean
`optional` (default false), `order` (`provider_first` default or `presence_only`),
and optional `min` / `max` version strings. Optional `capabilities` is an array
of stable identifier strings. Discovery validates declaration shape and retains
the original values, including executable capabilities. It does not compare
versions, activate integrations or claim required executables are available.
Version comparison is defined below. Capability admission remains a later gate.

Candidates contain stable `id`, display `name`, `version`, `format` (`zip` or
`folder`), absolute source `path`, owner/format/path provenance, dependencies,
capabilities and the manifest. Projections return deep copies.

## Package-relative access

Normalize separators to `/` and paths to lowercase for lookup. Reject absolute
paths, empty/dot/parent components, control characters, Windows reserved device
names, colon/ADS/drive syntax, wildcard/metacharacters and trailing dots/spaces.
Normalized ZIP collisions reject the package. Folder lookup requires exactly one
matching component and rejects links/inaccessible entries before traversal.
`read_package_file(id, relative)` resolves only an eligible selected copy and
returns checked bytes and provenance, or failure. It cannot accept an arbitrary
filesystem package source supplied by a content reference. No exported-asset or
cross-package-reference authority is invented; dependency/export validation
belongs to the later planner/content adapters. Discovery never loads resources
or executes scripts.

## Duplicates and rescans

Resolve duplicates before dependency planning. `grouped`, `unresolved` and
`available` expose all eligible sources, required decisions and chosen sources.
`choose_copy(id, source, expected_set)` accepts only a currently listed source,
or empty source for explicit skip. `expected_set` is the sorted exact set of
lowercase absolute Windows paths, IDs and exact version strings. A stale request
is rejected. Format is implicit in the path; timestamps/hashes are not equivalence
inputs. Skip and chosen path are persisted transactionally. If writing fails,
the current pending choice remains available and the failure is visible.

`rescan` explicitly refreshes candidates and diagnostics, clears a root-level
run omission, preserves equivalent choices and removes changed choices. Changes
that leave duplicates require another decision; a unique remainder is ordinary
selection. New IDs appear disabled. Invalid packages never enter the eligible
set. No continuous monitoring occurs.

`continue_without_mods` is admitted only after root failure and returns a
run-scoped empty installed library. Profiles and enabled missing IDs are retained.
It never marks dependencies, DATA or SAVE compatible. Retry performs real
discovery again; a new application always attempts discovery.

## Profiles, drafts and persistence

The versioned JSON store contains `schema:1`, `next_id`, `profiles`, duplicate
`choices`, and `last_successful`. Profile IDs are `default` or monotonically
allocated `profile-N`; display names are independent of identity. Names must be
unique case-insensitively, trimmed, 1–80 characters and free of C0 controls.
Default remains named Default and cannot be renamed/deleted; duplicate it for
a custom editable identity. Create starts empty; Duplicate copies the selected
pending draft. Rename preserves pending entries. Delete requires explicit
confirmation, retires its draft/run skips, clears its matching history, and
selects Default. Failed management writes change no committed identity/selection.

Each profile's `entries` array contains unique stable IDs with boolean enablement;
array position is preferred order, including disabled and missing IDs. Missing
enabled IDs retain their position. Discovery-only rows append sorted, disabled
IDs without making a saved profile dirty. Editing materializes those rows in
the draft. Remove edits the pending profile permanently when Save succeeds;
Skip/Restore affects only that profile's run omissions and never its draft.
Switching profiles retains each pending draft and run omissions. Nothing is
implicitly saved or discarded when switching.

`save_profile` accepts unfinished selection, including unmet dependencies or
missing IDs. Saved profile, pending draft and run omissions remain separate.
The shared storage adapter stages/verifies bytes and performs the existing
flushed same-volume replacement. Failed staging/replacement preserves committed
bytes/state and pending edits. Orphan `.staged` files are ignored on restart.
Malformed/unreadable/unsupported stores are retained and require repair/Retry;
they are never quietly reset. Lease ownership remains CORE's process-held lease.

Launch selects a stored `last_successful` only if its profile still exists,
otherwise Default. Save, selection and discovery never advance this history.
The successful-menu history writer/lock now joins increment 3's checked CORE menu
commit boundary. No discovery/profile-only operation can pretend entry occurred.

## Deferred interfaces and acceptance gates

`selection()` projects saved/pending profiles, eligible sources, unresolved
duplicates, run skips and discovery outcome. `dependency_ready` reflects the real
planner; `data_ready` becomes true only at the checked menu commit. See the linked
publication contract for candidate preparation and required adapter availability.
The normal setup UI exposes this increment before actual main-menu entry even
when classic-source setup still needs repair. Profile persistence is independent
of that source selection. Rescan/edit actions are absent after actual menu entry.

Increment 2 delivers the planner below. Increment 3 consumes that real plan,
adapter schemas and bounded initial DATA fixtures, validates/persists Continue
choices and publishes/locks at actual menu entry with successful-profile history.
SAVE-017, IMP-007–010
schemas, export sharing and IMP-050/051 executable registration/lifecycle remain
owner integrations. An executable capability is metadata here, never a claim of
data-only compatibility or executable readiness. M1 remains open.

## Dependency planning — increment 2

`dependency_planner.gd.build(planning_input())` is pure MOD logic over validated
discovery metadata. The configuration owner supplies selected eligible copies,
enabled preferred rows, explicit run skips/duplicate skips, root outcome and
profile-scoped optional suppressions. No dependency facts are derived until all
duplicate choices and root recovery are resolved. Missing enabled IDs block
unless explicitly skipped; a root-level run-empty discovery choice does not
silently remove enabled profile entries or waive required dependencies.

Disabled or run-skipped dependents impose no constraints. Each enabled dependent's
declared provider is checked against eligible copies and the enabled set. Required
missing, disabled or incompatible providers produce blocking diagnostics with
dependent/provider IDs, source provenance, installed version, requested range and
reason. A compatible disabled provider is offered for explicit enablement only.
`enable_dependency(key, expected_revision)` sets that provider enabled, restores
its explicit run skip if needed, leaves other package enablement unchanged and
revalidates, including the provider's own prerequisites. An incompatible provider
cannot be enabled through this action. Ordinary profile enablement remains an
explicit separate request and can create an unfinished configuration.

Missing/disabled optional integrations are inactive without warnings. Enabled
incompatible optional integrations warn, stay inactive and add no edges. Compatible
enabled optional integrations are active unless suppressed. Presence-only
relationships still check availability/version but add no ordering edge, including
self-presence relationships. Every ordered active declaration adds a constraint
from provider to dependent; parallel declarations share a graph edge while
retaining separate relationship records. Required parallel edges cannot be
removed by suppressing an optional declaration.

### Version comparison

Keep increment 1's accepted manifest syntax. Compare core decimal components
numerically without integer conversion/overflow; build metadata after `+` does
not affect precedence. A release sorts after its same-core prerelease. Compare
dot-separated prerelease identifiers left to right: ASCII digits-only identifiers
compare numerically and sort before nonnumeric identifiers; other identifiers
compare case-sensitively by ASCII lexical order. Equal shared identifiers put
the shorter list first. Numeric prerelease leading zeros accepted by the original
manifest syntax compare by numeric value (`01` equals `1`); this is explicit
compatibility with the delivered syntax, not a new strict SemVer rejection rule.
Hyphens inside nonnumeric identifiers are ordinary ASCII characters, not signs.
Minimum is inclusive; maximum is exclusive. Empty/inverted ranges accept no
version. Prereleases have no extra exclusion rule: only the declared bounds apply.

### Validation, cycles and deterministic previews

`validate_dependencies()` returns value-only copies of `ok`, `revision`, profile,
current active `order`, blocking `errors`, optional `warnings`, relationship
`integrations`, active `constraints`, complete closed `cycles`, optional cycle
relationship keys `suppressible`, `sortable` and `proposed_order`; DATA readiness
is always false. `ok` is dependency validity only. It is not publication or menu
readiness. Invalid manual order produces `order` errors. Structural failures or
cycles prohibit previews; ordering errors alone can be repaired by sorting.

Cycles use provider-first graph arrows. For each graph constraint, a deterministic
breadth-first return-path search identifies participation in a cycle, including
self-cycles. Closed paths are rotated to the lexically smallest ID and deduplicated;
neighbors and reported paths have deterministic ordering. This reports full paths
and every participating optional edge, without claiming to enumerate the
exponentially many possible simple cycles in a dense graph. A remaining cycle
continues to block after any suppression.

Validation and sorting consume the exact same active constraints. Stable Kahn
sorting chooses the earliest preferred currently eligible zero-indegree ID at
each step. It preserves preference where constraints permit, with no claim of a
global minimum-inversion optimizer. `request_sort_preview()` retains an owner-held
proposal ticket with serial, configuration revision, profile and full canonical
input fingerprint. It never changes a pending order or enables a package.
Repetition replaces the prior ticket; old tickets cannot apply. The UI shows
the complete proposed active order and explicit Accept/Dismiss controls.

`accept_sort_preview(id)` verifies the retained ticket and current inputs, edits
only pending entries and revalidates. Enabled active slots receive the proposed
IDs while disabled/missing/run-skipped slots retain position. Discovery-only rows
are materialized as disabled pending entries on this explicit edit. Saved state
changes only via Save Profile. Dismissal preserves pending state. Repeated or
obsolete acceptance rejects without mutation. Profile/selection/order/run-skip/
duplicate edits, root choices, rescan and suppression changes invalidate previews
and consumer revisions; even an equivalent rescan requires a fresh preview.
Saving identical pending plan inputs does not invalidate their preview.

### Optional integration admission and run lifetime

A relationship key is `<dependent package ID>:<zero-based declaration index>`.
Its binding digest includes dependent installed source path, ID, version, exact
declaration and index. This distinguishes repeated declarations and rejects a
suppression inherited by a different source/declaration. Keys are plan-local
references, not persistent GAD-01 definition identities.

`suppress_optional(key, expected_revision)` admits only an optional ordered edge
participating in a current cycle. Required and unrelated optional declarations
cannot be suppressed. It records the matching binding for this profile/run and
revalidates. `restore_optional(key)` removes the omission and revalidates. Equivalent
rescans preserve matching suppressions; changed bindings become inactive as
suppression decisions and the new declarations are validated normally. Switching
profiles retains each profile's own run decisions; creating/duplicating a profile
does not inherit those decisions. Save Profile never serializes them; restart
clears them and rebuilds constraints from declarations.

Each relationship projection retains `active`, reason, declaration and provisional
`contributions_allowed` / `hooks_allowed` flags. These flags are meaningful only
in an `ok` plan. Consumers use `integration_allowed(key, consumer,
expected_revision)` (`consumer` is `contributions` or `hooks`), which denies
obsolete revisions, invalid plans, unknown relationships/consumer kinds and
inactive/suppressed integrations. DATA and executable-registration owners must
bind their dependent contributions/hooks to these checked relationship results
before activation. The fixtures verify admission denial, not execution of future
hooks or real domain contributions. No executable provider is activated here.

CORE startup validates the real MOD plan after classic-reader readiness and before
definition preparation. Invalid plans return dependency recovery. Valid plans
reach DATA's real candidate pipeline; absent domain adapters remain a truthful
unavailable result. Validate and Continue uses the checked increment-3 transaction
and its explicit unsaved-profile choices. Planning alone never persists edits,
publishes definitions, enters the menu, updates history or establishes a run lock.
Once locked, MOD rejects selection/profile/rescan/suppression edits and returns
the retained active plan/package metadata through title and character transitions.

## Controlled formula identity/order — IMP-006 increment 3

`formula_provider(id, expected_version, integration)` attests that the exact selected
enabled package/version appears in the current valid resolved MOD order. An
integration key must pass existing `hooks_allowed` eligibility. RULE uses this
read-only result for preflight before selecting the last valid replacement in
that order. It does not use registration arrival order or a separate priority.

This boundary does not load package scripts or admit executable providers. The
initial Callables are application-supplied controlled fixtures; actual executable
capability admission, trust, runtime cleanup and sandboxing remain IMP-050/051.
Explicit omission removes a provider's entire formula-hook contribution for the
run and revalidates; it does not silently disable its package or bypass its other
requirements. Registry registration/winners lock with the actual menu entry.
