# ECON-015 — Rent and extend a room

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-015-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-015-interview-decisions).

## Gameplay purpose and intended experience

Players can rent a bed for a disclosed period, extend the same booking, and leave possessions in the inn during their stay. Checkout ends the rental's rest and item persistence rights.

## Confirmed requirements

Use rolling 24-game-hour days, an exact 350-day booking horizon, and the existing bed on extension. Apply DFU bargaining to the nonfree base fee, accept eligible carried gold and credit, and confirm paid and free bookings. Protect player-dropped items throughout the inn while the rental is active. Stop rental rest and end rental protection at expiry. Support moddable rental policies. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-015-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/UserInterfaceWindows/DaggerfallTavernWindow.cs#RentRoom` chooses a rest marker index, registers the inn interior for persistence, and adds whole game days to the existing expiry on renewal. Paid bookings use a confirmation prompt after the bargaining calculation. The Knightly Order free branch books directly. `Game/Entities/PlayerEntity.cs#RemoveExpiredRentedRooms` removes the rental and its interior persistence registration. These are static observations.

## Detailed rules and behaviors

1. Resolve the authorized inn and current booking by stable identity. For a new booking, start at commitment. For an active extension, add time from the existing expiry and retain the assigned bed. An expired booking requires a new selection. Reject invalid day counts and offers beyond the supported horizon.
2. Quote added time, checkout, fee and tender before committing either a paid or free booking. Price consecutive calendar slots starting on the date the added stay begins. Apply any FACT-017 waiver automatically. Revalidate provider access, bed, timing, fee and full tender. Material changes require renewed acceptance. Settle payment and rental entitlement together.
3. Assign a stable eligible bed on a new booking using retained selection across technical retries. Validate the bed before charging. Extensions revalidate the original bed. Missing or unusable beds yield an explanation and leave funds and the prior booking intact. A stale extension cannot become a new booking without acceptance.
4. An active rental grants rest at the assigned bed under TIME and protects player-dropped items throughout that exact inn across transitions. This protection applies regardless of the drop location within the inn. Property ownership and access to existing containers continue to follow MOVE-022 and ITEM.
5. At exact expiry, revoke the rental's rest and persistence rights. Stop ongoing rental rest at that boundary and explain why. Dropped items lose rental protection and become subject to ordinary cleanup. The expiry releases the rental's protection without itself scheduling immediate deletion or transferring items to the innkeeper. Independent item protections continue to apply.

## Formulas, parameters and configuration

Expiry equals the start of the added stay plus rented days × 24 game hours. The projected expiry may be at most 350 game days ahead of commitment. RULE-024 sets the stock base fee to seven gold per nonfree calendar slot, including applicable Heart's Day relief. Apply RULE-021's purchase bargaining stage to the nonfree base using inn quality. Preserve an all-free rental or valid FACT waiver at zero. ITEM-009 governs carried coin and eligible letter spending. Mods can define compatible pricing, duration, room access, rest, storage and expiry policies.

## Required data, inputs, outputs and events

Use stable renter, inn, bed, booking and operation identities, accepted start and expiry, calendar and benefit context, price and tender, and rental protection scope. Accept booking, extension and status requests. Return quoted terms, explicit rejection, committed entitlement, expiry or recovery. Publish booking and expiry after their authoritative changes. Status queries spend nothing.

## Cross-system interactions

ECON-001 supplies service access. RULE-024 and RULE-021 supply pricing. FACT-017 supplies waivers. ITEM-009 owns tender. LOC owns inn and bed identity. MOVE-022 and ITEM govern dropped property and cleanup. TIME owns rest and exact interruption. CORE/SAVE coordinate restoration. DATA/MOD validate profiles.

## Edge cases and failure conditions

- A stay crossing a calendar boundary uses the applicable holiday slots. Extensions quote only the added stay.
- A missing bed, insufficient funds or invalid booking horizon blocks settlement. Repeat confirmation cannot charge or extend twice.
- Checkout during rest interrupts at the boundary. Reentering the inn after expiry carries no rental protection for earlier drops.
- Expiry or other failed work retains authoritative facts for recovery without replaying charges or deleting independently protected property.

## Save/load and technical constraints

Target Godot 4.7.2. Persist booking identity, stable bed, accepted terms, expiry, active protection and required recovery facts. Restore current rights from authoritative game time before allowing rest or protected storage. Preserve active protected drops through entry, exit and load. Clear transient confirmations and handle missing beds or inn mappings through explicit compatibility or recovery.

## Acceptance criteria

1. New bookings add whole 24-game-hour days. Extensions keep the same bed and add time at the old expiry. Exact 350-day horizon succeeds, and longer requests fail.
2. Paid and free bookings require acceptance. Invalid bed or tender leaves funds and existing entitlement unchanged. Multi-day and extension quotes apply applicable free slots correctly.
3. Drops in separate areas of the same inn persist across transitions during a valid rental. At expiry ordinary cleanup rules apply, with independent item protections retained.
4. Ongoing rental rest stops at exact expiry with an explanation. Further rental rest requires a valid booking.
5. Repeated callbacks and load cannot duplicate payment, extension or entitlement. Validated mods can change the lodging policies.

## Compatibility review and outstanding questions

The specification follows RULE-024 calendar fees, FACT-017 waiver eligibility, ITEM-009 tender and the existing MOVE/ITEM property boundaries. Exact cleanup cadence after expiry follows the dropped-item owner. Bed mapping, interruption fixtures and save integration remain open.
