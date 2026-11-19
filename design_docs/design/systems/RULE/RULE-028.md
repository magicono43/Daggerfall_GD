# RULE-028 — Regional holiday and clan mappings

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Supply explicit regional holiday sets and vampire-clan mapping inputs from validated extensible content, keeping lookup separate from service benefits and transformation assignment.

## Intended player experience

Regional celebrations apply on valid dates, including mod-added overlaps and late-year dates. Services consistently explain applicable benefits. Established vampire clan identity survives travel, loading and mapping edits instead of silently switching to a default.

## Confirmed requirements

RULE-028-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve stable moddable mappings, explicit context/no-event distinction, declared clan fallbacks, deterministic holiday sets/service priority, full valid-calendar support and retained assigned clan identity.

RULE-023/024 already consume explicit holiday/service context. CHAR-019 separates transformation identity/grants from acquisition rules and preserves sources through restore. DATA-003/RULE-004 govern validated locked content/hooks. TIME owns calendar; MAGIC/FACT clan-assignment timing/benefits.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#GetHolidayId` uses 53 parallel region/date entries. Region 0xFF means all regions; other entries compare regionIndex+1. Day is gameMinutes modulo 518400, divided by 1440, plus one, corresponding to a 360-day year.
- It searches only while day<=355, returns first matching index+1 or zero. Therefore array order is implicit priority and late-year dates cannot match in this helper even if content were extended.
- `GetVampireClan` reads a region faction's vam affiliation and maps Vraseth/Haarvenu/Thrafey/Lyrezi/Montalion/Khulari/Garlythi/Anthotis/Selenu faction IDs to clan enum values. Unknown affiliation defaults Lyrezi; successful faction lookup is not explicitly checked by this helper before use.
- Holiday callers include identification/cure/spell/trade/tavern and building-access paths, with some callers passing region zero. Complete caller semantics remain unverified. CHAR-019 analysis traces clan-based grants separately; this lookup alone does not establish when clan is assigned.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full table/content provenance, caller/assignment routing and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Definitions and context

Retain inspected classic holiday dates/regional coverage and clan associations as baseline content, with stable holiday/region/clan identities and explicit classic adapters. Support added regions/holidays/clans only with valid complete owner references. A display string or array position is not durable identity.

Holiday queries require the relevant explicit region and valid game date/calendar. Clan queries require explicit relevant region/policy context. Do not substitute player location or region zero for missing data, including remote services. Invalid/unavailable required context is an error, not a successful no-holiday result or default clan.

DATA-003 controls valid contributions/provenance/lock and explicit recovery. Supported RULE-004 extensions must declare lookup/policy semantics and safe outputs. No arbitrary content expression engine or automatic dynamic remapping is introduced.

### Holiday set lookup

Each holiday definition declares stable identity, valid date/recurrence and explicit regional applicability, including a supported all-regions rule. Preserve classic associations through verified adapters rather than magic numeric region markers in new content. Validate calendar dates and required region references before publication.

Return all applicable holidays for a valid region/date in a deterministic declared order. An empty set is a valid result when none applies. Exact ordering/priority fields must be defined before implementation; incidental file/registration order cannot determine service outcomes.

Each service owner declares which holidays affect it and whether/how benefits combine. A compatibility caller requesting one holiday must use an explicit priority rule. Multiple applicable free-day holidays do not by themselves grant multiple days or duplicated transactions: RULE-024 counts each rental slot once, and benefit composition remains service-owned. This lookup does not set opening hours, fee discounts or quest behavior automatically.

### Calendar boundaries

TIME supplies valid date/day/year conversion and rollover. Retain supported classic dates while allowing added holidays on any valid calendar day, explicitly including 356–360 in the classic calendar. Do not preserve the blanket day-355 cutoff for modded content.

Queries over year-crossing rentals use each declared slot's date under RULE-024 rather than a narrow numeric day comparison. Date recurrence, leap/alternate calendar support and timezone-independent game-time semantics require TIME/content contracts; this feature does not replace the game calendar with real-world dates.

### Clan resolution and assignment

Resolve region affiliation through explicit mappings to a valid clan ID. Default classic association adapters cover the nine inspected clans. A fallback to Lyrezi or another supported clan is permitted only when explicitly configured and validated for the region/domain; unconditional fallback is not retained.

Missing mapping differs from configured fallback and from an explicitly supported no-applicable-clan context. MAGIC/FACT must decide whether no clan is valid for a given acquisition policy. A lookup cannot silently grant vampirism, select infection timing or apply spells/traits.

Assignment occurs at MAGIC/FACT's approved acquisition boundary using explicit context. Retain the assigned clan identity and required definition references under CHAR-019/SAVE. Subsequent travel, locale changes and loading cannot recalculate it from the current region or replay clan grants. Existing character identity is separate from current regional clan distribution.

### Updates and migration

Changed clan mappings affect future assignments by default. Existing assignments change only through explicit approved migration/transition. Removed required clan definitions require explicit compatibility recovery, not substitution to Lyrezi or dropped grants.

Holiday lookup uses current valid locked definitions and date, while committed service entitlements/prices retain their owning accepted-term rules. New calendar/content definitions cannot retroactively reprice completed services or rewrite a saved rental/repair/loan by lookup alone. Policy changes affecting pending obligations require owner/SAVE compatibility handling.

### Queries and explanations

Lookups are deterministic and side-effect-free. Expose matching holiday IDs/coverage/priority/provenance or clan mapping/fallback reason for inspection. Querying performs no random draws, benefit grants, hostility changes or transformation application. Missing-data errors must remain distinguishable from empty holiday sets and explicitly valid absence.

Localization changes labels only through approved text rules, never region/clan identity or holiday matching. Exact UI presentation and error recovery screens remain owners' contracts.

## Relevant formulas and parameters

Classic date adapter: day=floor((gameMinutes mod 518400)/1440)+1, yielding 1–360. Target lookup delegates calendar validity to TIME instead of hard-coded cutoff.

Holiday result is the ordered set of validated definitions matching explicit region/date. Clan result is an explicit region/affiliation mapping or declared validated fallback, not a random choice. Complete baseline date/coverage/clan fixtures must be verified before implementation; no new holiday dates/clan benefits are invented here.

## Required data

Stable region/holiday/clan/affiliation identities; date/recurrence/calendar and applicability/priority definitions; explicit fallback policy; baseline adapter provenance; assigned clan/definition version context; owner accepted-service facts where relevant. Concrete schemas/order fields and migration metadata remain dependencies.

## Inputs, outputs and events

Inputs: explicit valid region/date or clan-policy context under locked definitions. Outputs: ordered holiday set, valid clan/fallback/explicit absence or distinct error. Lookup emits no acquisition/benefit events. TIME/service/MAGIC/FACT owners apply changes and notifications; APIs/signals are unselected.

## Cross-system interactions

TIME owns calendar/recurrence, LOC/WORLD region identity, DATA/FACT affiliations/content. RULE-023/024 and ECON/MAGIC service owners select benefits/priorities. CHAR-019/MAGIC own clan assignment/grants/cure, QUEST associated obligations. RULE-004/DATA-003 validate extensions/locks; CORE/SAVE restore valid identity/context; UI/DEV inspect localized labels without mutation.

## Edge cases and failure conditions

- Valid no-holiday and overlapping holidays are supported; unknown calendar/region cannot masquerade as an empty result.
- Late-year valid dates and year rollover do not disappear through source cutoff/array limits.
- Conflicting priority/service composition must be resolved explicitly rather than first-loaded winner.
- Missing clan affiliations/definitions cannot silently choose Lyrezi, erase identity or reapply benefits.
- New region ID insertion/reordering and locale changes cannot reinterpret old numeric indices or compare display names as identity.

## Configuration and balancing options

Support holiday dates/coverage/recurrence/declared priority, clan/affiliation mappings and explicit fallbacks through validated content/hooks. Added clans require complete MAGIC/FACT/CHAR definitions beyond mapping. No new vampire powers, holiday price percentages, infection timing or automatic benefit stacking is introduced.

## Save/load considerations

Save assigned clan identity and required authoritative transformation/grant state under CHAR-019. Restore without current-region reassignment or acquisition replay. Holiday sets derive from valid restored calendar/region/content; committed service facts remain retained, not recalculated into new fees/benefits. Required definition changes use explicit migration/recovery, preserving stable references rather than automatic fallback. Exact pending calendar/service obligation schemas remain owner/SAVE scope.

## Technical constraints

Target: Godot 4.7.2. Use stable IDs, explicit calendar/region contexts, validated deterministic multi-match ordering and separate lookup/application. Avoid fixed classic region arrays as universal content limits. Interfaces/cache/schema remain engineering dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Verified baseline holiday/clan mappings resolve through stable adapters and support valid added IDs without array-position identity assumptions.
2. Holiday queries return all applicable matches deterministically; empty valid results differ from errors and single-result consumers use declared priority.
3. Valid late-year/modded dates and year crossings work through TIME rather than day-355 suppression.
4. Clan fallback is explicit/validated; missing required data errors rather than silently selecting Lyrezi.
5. Assigned clan survives travel/locale/load/mapping edits without grant replay; required-definition removal uses recovery/migration.
6. Pure queries/localization do not draw, grant benefits or alter committed service terms. Service benefit composition remains explicit.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-019, RULE-004/023/024 and DATA-003. Multi-holiday lookup complements one-count-per-rental-slot pricing without approving stacked benefits. Explicit clan persistence preserves transformation/source ownership. Complete context/data recovery replaces source silent defaults, while legacy dates/associations remain baseline fixtures rather than invented mechanics.

## Outstanding questions and approval

No blocking shared-mapping policy question remains. Before implementation: verify full date/coverage/affiliation fixtures, define priority/recurrence/service contracts, stable fallback/absence schemas, MAGIC/FACT assignment boundary and definition migration/SAVE handling. These cannot waive explicit contexts, multi-match holidays, full valid-calendar support or retained clan identity.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-028-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented calendar/service-priority and MAGIC/FACT/SAVE integration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
