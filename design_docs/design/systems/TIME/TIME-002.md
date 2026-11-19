# TIME-002 — Continuous and requested time advance

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-15 with “I approve”. See TIME-002-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended experience

Give exploration a predictable day and night pace. Let activities such as rest and travel consume their stated durations while ordinary play is suspended. Pausing, losing focus, and loading leave the player at the same in-world instant. An interrupted activity accounts for the time that actually passed.

## Confirmed requirements

[Decisions TIME-002-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm a moddable calendar-only 12× default with no dedicated in-game setting, one TIME-owned advance operation with explicit authorization and retry protection, and preservation of sub-millisecond progress through native save/load.

## Daggerfall Unity reference

In the local DFU 1.1.1 Release snapshot, `Assets/Scripts/Internal/WorldTime.cs#Update` applies and clears a positive `RaiseTimeInSeconds` request, adds Unity `Time.deltaTime × TimeScale` with a default of `12`, and calls `RaiseEvents`. `Assets/Scripts/Game/GameManager.cs` sets Unity `Time.timeScale` to zero when pausing and restores it when resuming. `DaggerfallRestWindow`, `DaggerfallTravelPopUp`, `DaggerfallCourtWindow` and `DaggerfallGuildServiceTraining` call `DaggerfallDateTime.RaiseTime` directly in their activity paths. These findings are from static inspection. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Ordinary calendar advancement

- Use eligible simulation elapsed time supplied through CORE-015/016/017. Apply the calendar rate once. The default of 12 game seconds per eligible simulation second yields one game hour per five eligible minutes. Movement, combat and other simulation cadences keep their own timing rules. Calendar-based deadlines and effects naturally advance at the calendar rate.
- For eligible elapsed simulation seconds `d`, configured calendar rate `r`, and retained remainder `f` measured in game milliseconds, compute `total = f + d × r × 1,000`. Advance by `floor(total)` whole game milliseconds and retain `total − floor(total)`. Use deterministic elapsed-time accounting so splitting the same accounted duration across updates produces equivalent committed time and remainder. Preserve `0 ≤ f < 1` across pause, explicit advancement and save/load. A positive delta that yields zero whole milliseconds still contributes to the remainder.
- Startup, load, ordinary pause and focus loss admit zero ordinary elapsed time. Resuming uses new eligible elapsed time. Clock reads, presentation and native restore do not advance time. A single eligible interval is accounted for once even when a simulation update is retried.
- Resolve the rate as a positive, finite value through validated DATA-003 mod definitions. Expose the override to mods. Apply the resolved definition under DATA-003's lock. If the configured rate changes between compatible sessions, future ordinary time accrues at the new rate and existing timestamps, deadlines and retained remainder keep their recorded values.

## Requested calendar advancement

- TIME is the sole writer of the authoritative timestamp for advances. An explicit request identifies the current session, the authorized activity and operation, the reason, and a positive duration in whole game milliseconds. Explicit durations are applied directly. They are independent of the ordinary calendar rate and leave its fractional remainder intact.
- Authorize against the current lifecycle, activity and suspension context. The activity may advance under its own suspension. Independent blockers such as focus loss, loading, or an unrelated pause prevent new segments from committing. Revalidate at each segment boundary. The activity owner governs whether a blocked activity waits, cancels, or terminates. An explicit advance does not release anyone else's suspension or turn on ordinary gameplay simulation.
- Serialize clock ownership. While an explicit activity owns the clock, ordinary advancement is inhibited and competing activity requests receive a busy outcome. A retry of the same request identifies the original operation and returns its recorded progress or outcome. Reusing that identity with different request data fails. Each committed segment advances the clock once. Release ownership after a terminal outcome or session teardown. Reject stale work from replaced sessions.
- Return the requested duration, actual committed duration, start and current timestamps, and an outcome such as completed, interrupted, rejected or in progress. An interruption preserves committed time and prevents uncommitted segments from applying. The initiating owner determines applicable interruption conditions within approved rules. TIME-003/004 define crossed-boundary delivery and reconciliation, including when an in-flight interval must stop for a required consequence.

## Required data, outputs and save/load

Required data include the [TIME-001 timestamp](TIME-001.md), the ordinary rate and retained remainder, authoritative eligibility and suspension context, and current activity/request identity and committed progress. Advance results identify the reason and committed old/new instants. Publish that transition only for actual clock movement. Boundary event types and ordering belong to TIME-003/004.

Persist the exact TIME-001 timestamp and the fractional remainder in a compatible native save. New characters start with zero remainder. Restore with zero elapsed time and without replaying committed advances. SAVE and the activity owner define valid save boundaries. If saving an in-progress activity is supported, retain sufficient operation and segment progress to prevent replay on restore. A save path with no such contract must use a settled boundary.

## Cross-system interactions and failure conditions

- CORE-011/012 initialize startup without elapsed time. CORE-013 governs restore. CORE-016/017 govern eligible simulation timing. CORE-019 requires fresh threat and veto checks at rest segment boundaries. TIME-009–017 own rest and travel rules.
- LAW-015 owns prison duration and its separate release interval. QUEST-010 reconciles exact deadlines on committed time. MAGIC-008 distinguishes calendar time from eligible-gameplay time, requires chronological handling where applicable, and reports actual elapsed time after interruption. Calendar-to-gameplay conversion for explicit activities follows the applicable effect profile and owner rules.
- Reject invalid rates, negative or invalid elapsed input, nonpositive explicit duration, overflow, stale scope and unauthorized requests. Validate the requested endpoint before committing the operation. Failed admission leaves the clock and remainder intact. Budget and cadence choices must preserve eligible elapsed accounting under CORE-017. No renderer, window timer or raw wall-clock gap may supply extra eligible time.

## Acceptance criteria

1. At the default rate, five eligible simulation minutes add one game hour. A valid mod rate changes calendar progression without changing the ordinary movement or combat rate. No dedicated player setting is exposed.
2. At a fixed rate, the same accounted eligible duration split into different update sizes yields the same whole timestamp and remainder. Native save/load mid-remainder gives the same subsequent advancement as uninterrupted accounting.
3. Startup, stacking pause reasons, focus loss and loading add zero ordinary time. Resuming produces no advance for suspended duration.
4. An authorized rest segment can commit under its own suspension. Acquiring an independent blocker prevents the next segment. A competing activity receives busy and cannot silently commit later. A replaced session rejects stale requests.
5. An explicit one-hour request adds one game hour at any ordinary calendar rate. A duplicate request or segment retry cannot add the hour twice. If an activity stops after one segment, the reported elapsed time equals committed segments only.
6. Invalid requests and overflowing endpoints leave the timestamp intact. Native restore and pure queries emit no advance transition. Applicable quest and effect consequences reconcile through TIME-003/004 and their owner contracts.

## Consistency review and open dependencies

The specification preserves approved TIME-001 precision, CORE-011/012 entry gating, CORE-013 restoration, CORE-016/017 eligibility and accounting, CORE-019 rest guard checks, QUEST-010 deadlines, MAGIC-008 interruption and clock distinctions, and LAW-015 prison timing. TIME-003/004 own boundary dispatch, catch-up, and ordering when multiple consequences share an instant. Implementation details for deterministically representing the remainder, request identities and persistence, and the owner-specific save and resume policies remain open.
