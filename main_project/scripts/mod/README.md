# MOD package and profile contract — IMP-005 increment 1

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
Version ordering/prerelease comparison and capability admission are later gates.

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
The actual successful-menu history writer/lock must join increment 3's CORE menu
commit boundary. No first-increment operation can pretend that success occurred.

## Deferred interfaces and acceptance gates

`selection()` projects saved/pending profiles, eligible sources, unresolved
duplicates, run skips and discovery outcome. `dependency_ready` and `data_ready`
are explicitly false. No planner or candidate definition publication exists yet.
The production startup provider continues to report unavailable content support.
The normal setup UI exposes this increment before actual main-menu entry even
when classic-source setup still needs repair. Profile persistence is independent
of that source selection. Rescan/edit actions are absent after actual menu entry.

Increment 2 must consume the selected enabled copies, validate required/optional/
presence-only constraints and provide an accepted deterministic preview. Increment
3 must consume that real plan, domain adapter schemas and bounded initial DATA
fixtures; validate/persist Continue choices; publish at actual menu entry; lock
plan/definitions and record successful-profile history. SAVE-017, IMP-007–010
schemas, export sharing and IMP-050/051 executable registration/lifecycle remain
owner integrations. An executable capability is metadata here, never a claim of
data-only compatibility or executable readiness. M1 remains open.
