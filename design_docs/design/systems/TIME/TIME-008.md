# TIME-008 — Regional holidays

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-15 with “I approve”. See TIME-008-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended player experience

Tell the player when they encounter a local holiday. A brief, dismissible notice marks the occasion when they reach a settlement or the date changes during their stay. Services convey any holiday benefits through their own interactions and quotes.

## Confirmed requirements

[TIME-008-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm arrival and day-change triggers, a one-time classic-style notice for each applicable holiday, and mod extension points for alternate triggers and presentation.

## Daggerfall Unity reference

Static inspection of the local DFU 1.1.1 Release snapshot. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits. Paths are relative to `Assets/Scripts/`.

- `Game/Formulas/FormulaHelper.cs#GetHolidayId` resolves one match from classic region and day-of-year data. The approved RULE-028 contract supports the full matching set and all valid days.
- `Game/PlayerEnterExit.cs#Update` discards a pending holiday message if its location changes and displays it when the delay has elapsed and the HUD is active. `ShowHolidayText` uses localized tokens in a click-to-dismiss message box and sets a ten-second repeat cooldown. The arrival path primes the notice after a short delay.
- Service callers query holiday eligibility separately. `Game/Formulas/FormulaHelper.cs#CalculateItemIdentifyCost` uses it for a festival price override.

## Detailed rules and parameters

1. Use the authoritative TIME-001 calendar date and the explicit region belonging to the relevant location or service. Retrieve the ordered active holiday set through RULE-028. The base game retains the classic dates and regional coverage. All days in the 360-day calendar are valid, including 356–360. Lookup is side-effect-free.
2. Check the active set at a ready arrival in an eligible settlement and when the committed date changes while the player remains in an eligible settlement. This includes travel arrival and a day change from rest or loiter. A normal doorway traversal adds no time under MOVE-026. A jump uses its actual destination date and location. Holidays active only during skipped time create no base notice.
3. Present a classic-style dismissible initial message. If several eligible holidays are active, queue individual notices in RULE-028 order and show them one at a time. Defer while the appropriate gameplay UI is unavailable. Revalidate holiday, date, region, and location before displaying. Discard stale candidates on relocation, expiration or session replacement. Re-evaluate at a newly eligible context through the normal triggers. The base game uses only the initial notice for general holiday presentation.
4. Use `(character, holiday ID, calendar date)` as the suppression identity. Record a notice when it is successfully shown. Deduplicate queued candidates and remember shown identities through native save/load. Crossing into another region with that same holiday on the same date does not duplicate the notice. A different active holiday can still appear that day. The next annual occurrence has a different date. Reconstruct undisplayed eligibility from the restored ready context and its shown records, including a notice deferred when the save was taken.
5. Allow validated mods to change notice triggers, eligible locations, holiday notice eligibility and presentation. Expose read-only active holiday data and notice eligibility or occurrence hooks. A mod can supply a nonblocking HUD notice, journal panel or alternate presentation. Use stable identifiers and explicit replacement or composition rules under DATA-003 and UI. An informational read cannot mark a holiday shown or grant a benefit.

## Required data, inputs, outputs and events

Inputs include committed date and region, ready session and location identity, ordered RULE-028 holiday data, localized notice text, trigger and presentation definitions, shown identities and UI readiness. Outputs include the ordered holiday set, distinct lookup failures, eligible notice candidates, successfully shown notice identities and optional presentation hooks. Stable holiday IDs provide identity across localization. Exact UI API and signal names remain implementation decisions.

## Cross-system interactions

- TIME-001 supplies dates and rollover. TIME-002–004 supply committed advances and destination handling. WORLD, LOC and MOVE supply ready location and region. UI owns message presentation and modal interaction. Restore uses committed state after applicable CORE readiness gates.
- RULE-028 owns holiday lookup and ordered matching. RULE-023/024 and ECON service owners decide benefit eligibility and composition using their explicit service region and date. [ECON-008](../ECON/ECON-008.md) retains free eligible identification during the Witches Festival. RULE-024 counts each eligible rental date slot once. A notice does not grant benefits, change opening hours or reprice an accepted transaction. Service availability or fees can still be explained at the relevant service.

## Edge cases, configuration and save/load

- An empty set is a valid result. Missing required date or region data is a distinct error. A deferred notice cannot appear after the player has left or the date has expired. Simultaneous arrival and day-change triggers produce one candidate per identity.
- Store the shown identities needed for suppression in native saves. Keep candidate queues and message timing as transient presentation. Loading adds zero elapsed time and can present a qualifying unseen notice once after readiness. It cannot replay an already displayed notice or reapply service consequences. SAVE and DATA own compatibility for changed or removed definitions.
- Validate mod location rules, triggers, text references and presentation policies. If optional announcement text is unavailable, diagnose it and leave the valid holiday lookup and service behavior available. Exact notice styling, localization assets, eligible settlement classifications and extension formats remain owner dependencies.

## Acceptance criteria

1. Eligible settlement arrival shows each active unseen holiday once. A day change in the same eligible settlement can show the incoming day's holiday, including after rest.
2. A fast-travel arrival checks the ready destination. A jump that spans the entirety of a holiday shows no notice for that skipped date. A queued notice is discarded if the player leaves or the holiday expires before it appears.
3. Overlapping holidays show separate notices in stable order. Duplicate triggers, crossing a border and reloading after display do not repeat the same holiday on the same character/date. An unseen notice can still appear in a valid restored context.
4. A mod can add an eligible location, change a trigger, opt a holiday out of stock presentation, or use active data to drive an alternate HUD or journal display. Presenting or querying the holiday does not grant a benefit.
5. A day-360 mod holiday resolves correctly into year rollover. Identification and rental benefits follow their owners' rules regardless of notice eligibility or display history.

## Consistency review and outstanding dependencies

The specification fits approved TIME-001–004, RULE-028, RULE-024, ECON-008 and MOVE-026. Baseline text and coverage fixtures, exact UI handoff and mod schemas remain integration dependencies.
