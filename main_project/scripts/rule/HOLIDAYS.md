# Regional holiday queries — TIME-008 / RULE-028

`regional_holidays.gd.query(definitions, region_reference, native_timestamp)` is
RULE's pure authoritative lookup. TIME exposes the same query as
`calendar.regional_holidays(region_reference, native_timestamp)`. Calendar date
callers first use TIME's checked `Calendar.encode` query. Missing/invalid date or
region fails distinctly from a successful empty holiday set. No current location,
arrival region, zero, display name or ordinal is substituted. A region reference
is the actual delivered geography resource/record reference, for example
`packs/classic#region-00`, validated against `kind:region` definitions.

## Publication and index

Enabling geography registers `regional-holidays-v1` before classic preparation.
Compositions without geography expose holiday lookup as unavailable. The
`rule.holidays:annual` resource joins normal shipped → enabled MOD → captured
loose candidate resolution, provenance, recovery and run-long locking. Invalid
candidates clear their derived index and cannot partially publish. Registration
must occur before startup prepares readers, including fresh-process restoration
of startup preferences. No independent publication or live hot-reload exists.

Each record contains exactly `schema`, `label`, `recurrence`, `day`, `priority`,
`regions`, `classic_id`, and nonempty `provenance`. Recurrence is
`annual-fixed-360`; day is any integer 1..360. Regions are distinct explicit
geography references or the sole entry `"*"` for all resolved regions, including
valid additions. Priority is an explicit integer −1,000,000..1,000,000. Return
**all** matches ordered by descending priority, then ascending stable holiday ID.
Equal priorities therefore have explicit deterministic semantics. There is no
implicit first-result compatibility API or incidental registration-order winner.
Classic ID zero denotes an authored addition; IDs 1..53 adapt the inspected source
and must be unique in a candidate. Replacements preserve DATA identity/provenance.

DATA builds a day index and validated region membership set once per candidate.
`definition_registry.point_query` routes a detached narrow context to that exact
published index and returns detached matches, with identity, coverage, priority,
source provenance and field contributors. Repeated queries copy no geography or
holiday catalog and do not rebuild graphs/indexes. Work is proportional to that
day's holiday candidates and returned matches, independent of elapsed years.

## Complete shipped baseline

`tools/build_holiday_baseline.py` reproducibly extracts all 53 used entries from
the pinned DFU `FormulaHelper.GetHolidayId` region/date arrays and the matching
`DFLocation.Holidays` enum. It maps region byte 0xFF explicitly to all regions,
and other bytes through `byte−1` to the actual delivered geography profile's
ordinal→stable-reference adapter. Dates/coverage are unchanged. Every record
retains the two source-file SHA-256 hashes, classic holiday ID, original region
byte/day and MIT provenance; the existing `DFU_LICENSE.txt` applies. Reference
sources and classic data remain read-only. No new library is used.

Intentional differences: return all matches; make original table order explicit
as priority `54−classic_id`, with stable ID ties; remove the blanket day-355 cutoff
and fixed-region-array limit for public content. The unused trailing Old Life
Festival enum has no source date/coverage and is excluded rather than invented.
Labels preserve the inspected enum spelling and are diagnostic baseline labels;
localized holiday notice text remains a real UI/text-owner integration.

Full baseline lookup coverage is tested separately from controlled additions.
The generator comparison/source manifest verifies the complete chosen table,
including all native region adapters, rather than claiming original-executable
parity. Day 360, rollover, explicit different regions, all-region additions,
overlaps, reversed registration, errors versus empty results, actual MOD/loose
precedence/provenance and locking are covered by the additive activity inventory.

## Scope

Reads do not advance time, change fractions/gates, draw RNG, mutate owners, mark
notices, grant benefits, reprice accepted services, set opening hours or assign
clans. Service composition and retained accepted terms remain with ECON/RULE-023/
024. RULE-028 clan mapping/assignment/grants are excluded. TIME-008 ready arrival/
day-change notices, restored-location eligibility and durable shown suppression
still require real WORLD/LOC/UI/SAVE providers. The labelled controlled-context
review displays explicit-region pure queries; it does not impersonate location
readiness or close notice criteria.
