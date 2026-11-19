# ITEM-024 — Summoned items and expiry

Approval status — **Approved and finalized v1 on 2026-11-10**

## Gameplay purpose and intended experience

Summoned items remain usable for their agreed lifetime. Rest, travel, custody changes and save/load preserve the same deadline. Players can see the remaining lifetime when their character knows it, and expiry removes equipment and its contributions without disturbing other possessions or committed effects.

## Confirmed requirements

- **ITEM-024-D01.** Summoned items become unusable at their deadline, including when rest or travel crosses it. The same deadline applies in every supported custody location. Unloaded containers may reconcile removal when available, before exposing contents.
- **ITEM-024-D02.** Voluntary dropping, stashing, gifting and selling are blocked by default. Explicit profiles may permit these actions while retaining the original deadline.
- **ITEM-024-D03.** Equipped expiry removes the item and its source-bound contributions through one checked transition. Affected slots stay empty. Committed combat outcomes and independently released effects retain their approved lifetimes. Unfinished actions follow the approved interruption rules.

- **ITEM-024-D04.** Pending use, transfer and attack recheck expiry at commitment when they still require the item. Expiry takes precedence at the exact deadline. Committed effects and released arrows follow their approved rules.
- **ITEM-024-D05.** Permitted summoned stacks merge only with compatible deadlines, provenance and other relevant state. Both resulting stacks retain the original deadline on split.
- **ITEM-024-D06.** Ordinary expiry removes the temporary item without equipment Breaks payloads or a repairable remnant. Explicit expiry profiles may define other outcomes subject to quest protection and once-only settlement.

- **ITEM-024-D07.** Persist the original deadline and completed expiry steps. Reconcile overdue items against restored game time before access. Failed cleanup keeps the item unusable while recovery resumes unfinished steps only.
- **ITEM-024-D08.** Quest hand-ins, repair jobs and other services taking custody require explicit policies that handle expiry. Preserve the deadline and any committed obligation.
- **ITEM-024-D09.** Inspection shows summoned status and remaining lifetime when permitted by character knowledge. Each completed removal affecting a player-carried or equipped item gives one notice. Loading does not replay that notice.

The user confirmed D01–D09 on 2026-11-10 across three interviews. See the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Reference behavior

In the local DFU 1.1.1 snapshot, `Game/Entities/PlayerEntity.cs` calls `ItemCollection.RemoveExpiredItems` on its carried collection when the game minute changes. The helper tests whether a nonzero deadline is strictly earlier than the current minute, then unequips matching player equipment and removes the expired entries. `DaggerfallInventoryWindow.TransferItem` blocks summoned transfers on its inspected path. `CreateItem` sets a game-minute deadline on the created item. These findings come from static source inspection.

## Approved dependencies

MAGIC-027 starts the item-owned lifetime at successful creation and preserves it across supported movement and reconstruction. ITEM-005/006 govern stack compatibility and splitting. ITEM-010/012 govern equipment and source cleanup. COMBAT-008/009 govern summoned ammo selection, release and projectile lifetime. ITEM-022/023 govern world custody and quest obligations.

## Detailed behavior

### Deadline and eligibility

MAGIC-027 starts the item-owned lifetime on successful creation from the captured spell duration under MAGIC-008. Time spent in the suspended creation picker does not count. Ending the casting effect leaves the item deadline intact. Use the authoritative game clock, including authorized rest and travel advances. Every supported custodian evaluates the same deadline. The item becomes unusable at equality, even when removal has yet to settle.

An unloaded custodian may reconcile removal when available. Complete the eligibility check before exposing contents for access or selection. Queries report expired items as ineligible without settling removal. A pending use, transfer or attack that still requires the item validates the deadline at commitment and rejects at or after it. A committed effect or released projectile keeps its approved lifetime. In particular, COMBAT-009 gives released summoned arrows their captured projectile lifetime, and COMBAT-008 governs their recovery eligibility.

### Transfers, stacks and services

Block voluntary drop, stash, gift and sale by default. Explicit profiles may permit an action through the ordinary ITEM access, transfer and capacity rules. Movement, equipping, splitting and merging preserve the original deadline. Trade permission and value require a supported ITEM/ECON policy.

Apply RULE-025 eligibility and ITEM-005/006 matching and splitting. Ordinary and summoned units remain distinct. A permitted summoned merge requires compatible deadlines, provenance and relevant state. Both split results retain the original deadline and compatible source facts. Expired units cannot be selected or used as inputs.

A quest hand-in, repair or other service that takes custody requires explicit compatible expiry handling. Preserve any committed obligation if the item expires during settlement. ITEM-023 governs unresolved quest links and protected dispositions. If required permission or disposition is unresolved, preserve protected custody for recovery and keep the overdue item unusable.

### Removal and recovery

Ordinary expiry removes and retires the temporary item through its actual custodian. For an equipped source, clear the complete occupied arrangement and its source-bound contributions in the checked transition. Leave the affected slots empty. Apply approved combat interruption to unfinished work and preserve committed combat outcomes and independently released effects.

Ordinary expiry produces neither equipment Breaks payloads nor a repairable remnant. An explicit alternate expiry disposition must preserve quest protections and once-only settlement. A technical failure retains completed removal and cleanup facts. Resume only outstanding work against the original item and current authoritative custody. Pending cleanup cannot restore usability or cause duplicate removal, source cleanup or rewards.

### Player information

Use ITEM-019 knowledge rules for summoned status and remaining lifetime. Inspection is read-only. Report one notice per completed expiry removal affecting player-carried or equipped items. Restoration does not replay completed notices.

## Formulas and parameters

Deadline equals successful creation game time plus the captured duration expressed in the same clock units. Remaining lifetime is the greater of zero and deadline minus current game time. Expiry eligibility is current game time greater than or equal to the deadline. Use checked time arithmetic. Duration calculation remains with MAGIC-008/027. This draft introduces no extra expiry grace period or polling interval.

## Required data

Stable item, custodian, actor, source and operation identities. Summoned provenance, original deadline and compatible lifetime profile. Stack state and equipment bindings. Quest or service obligations. Completed and outstanding expiry steps and notice state.

## Inputs, outputs and events

Inputs include successful creation, game-time advances, access and commitment checks, custody changes, explicit expiry policy and restoration. Outputs include remaining lifetime, eligibility, committed removal and source cleanup, rejection or retained recovery. Feedback reports completed removal and cannot reapply it.

## Cross-system interactions

MAGIC-008/027 own duration and creation. TIME supplies the game clock. ITEM-005/006 and RULE-025 govern stacks. ITEM-007/008 and ITEM-022 govern movement and world custody. ITEM-010/012/013 govern equipment, contributions and the distinct break lifecycle. ITEM-014/023 and ECON govern compatible services and quest dispositions. COMBAT-001/008/009 govern interruption and released arrows. ITEM-019 governs disclosure. SAVE and CORE coordinate restoration.

## Edge cases and failure conditions

- A time advance crosses several deadlines. Each overdue item becomes ineligible and settles removal once.
- A pending attack reaches its commitment point at the deadline. Apply the approved interruption and preserve earlier committed work.
- A released summoned arrow outlives its former inventory deadline. Apply its captured flight and recovery rules.
- An unloaded or protected custodian cannot settle immediately. Retain the obligation and prevent overdue use.
- A cleanup step fails after earlier work commits. Resume the unfinished steps without replaying completed work or notices.

## Configuration and balancing

Explicit profiles may authorize movement, service use or alternate expiry disposition. Profiles preserve the original deadline across custody changes and respect owner protections and settlement rules.

## Save and load

Persist the deadline, authoritative custody and completed or outstanding expiry steps. Restore game time and reconcile overdue eligibility before access. Resume supported cleanup without restarting the lifetime, replaying settled work or notices, or accepting callbacks from the previous session.

## Technical constraints

Target Godot 4.7.2. Evaluate expiry independently of UI refresh, rendering and scene presence. Resolve cleanup against stable item and custodian identities. Clock conversion, unloaded-custody reconciliation and native recovery records remain integration work.

## Acceptance criteria

1. Items become unusable at the deadline in every supported custody location, including after time advances and before unloaded contents become accessible.
2. Default voluntary restrictions hold. Permitted moves, merges and splits preserve deadlines and relevant state.
3. Exact-deadline commitment rejects overdue sources while committed effects and released arrows retain their approved behavior.
4. Equipped expiry clears occupied slots and source contributions once. Ordinary expiry produces no Breaks payload or repairable remnant.
5. Quest and service custody requires explicit compatible expiry handling. Unresolved protected items stay in custody and unusable.
6. Save/load preserves deadlines and completed steps. Failed cleanup resumes outstanding work only.
7. Inspection respects knowledge and completed player expiry notices do not replay on load.

## Consistency review and open dependencies

Reviewed against MAGIC-027, COMBAT-008/009 and the approved item custody, stacking and protection rules. No direct conflict was identified. Clock conversion, unloaded-custody reconciliation, compatible service profiles and native recovery records remain open.

## Approval

The user approved Draft v1 on 2026-11-10 with “I approve”. The specification is finalized as v1 under ITEM-024-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).
