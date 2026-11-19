# TIME-009 — Rest eligibility and bed context

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-16 with “I approve”. See TIME-009-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md).

## Gameplay purpose and intended experience

Let players sleep at suitable campsites and use lodging they have permission to occupy. A rented bed is convenient to use, and a rejected or interrupted attempt gives a clear reason without exposing hidden enemies. Sleeping in restricted town areas carries the established legal consequences.

## Confirmed requirements

[TIME-009-D01 through D03](../../GAMEPLAY_DECISIONS.md) confirm base site eligibility, authorized bed placement and fallback, mod support, and allowing sleep near an untriggered spawner when threat and veto checks pass.

## Daggerfall Unity reference

In the local DFU 1.1.1 Release snapshot, `Assets/Scripts/Game/UserInterfaceWindows/DaggerfallRestWindow.cs#CanRest` checks outdoor town camping, owned housing and ships, room rentals and guild rest privileges. Its rental path resolves the allocated rest marker by index, defaulting to index zero if the stored index is out of range. `MoveToBed` directly positions the player at the marker when applicable. `TickRest` checks interruptions separately. Static inspection only. See the [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md) for revision limits.

## Site and permission rules

- Evaluate timed sleep and heal-until against the same site policy. Allow suitable wilderness and dungeon sites when safety checks pass. For town buildings, require a valid ownership, rental, guild or guest entitlement covering the site. Authorized owned lodging and guild facilities may allow sleep in place where the local policy permits. A permitted bed or suitable space still requires current safety and status checks.
- For restricted outdoor town camping, follow LAW-006. Opening the interface, inspecting eligibility, cancelling or failing an indoor entitlement check incurs no stock vagrancy. A committed illegal sleep attempt follows the warning policy and files at most one permitted charge and guard request through LAW, even when warnings are disabled. Authorization to try illegal camping does not override danger, custody or another required blocker. When authorized enforcement engages, stop sleep before any further advance.
- Ordinary waiting carries no stock vagrancy. Its eligibility, duration and recovery are governed by TIME-010 and the applicable owner policies. A sleep entitlement cannot substitute for waiting authorization or vice versa.

## Assigned beds and eligibility sequence

1. On an explicit sleep request, resolve the current session, actor, location, mode, permission and any required legal confirmation. Use current threat and veto results under CORE-019. Revalidate the request after any prompt, before committing placement or an advance. A confirmation from an obsolete context cannot authorize a new attempt.
2. For rental sleep, resolve the booking's stable bed identity in the current lodging. Use WORLD/LOC and MOVE checks for access and placement. A bed behind an unauthorized locked door is ineligible. An invalid, occupied or unsafe bed can use only an expressly authorized safe fallback in that lodging. If no fallback is available, explain the placement failure before sleep advances. Do not implicitly choose another renter's bed or the first indexed marker.
3. Once the player commits, settle any required legal handoff and safely move them to the assigned bed or authorized fallback if applicable. Before any elapsed time, verify the resulting site and current restrictions. A placement retry cannot repeat a charge or advance. Sleep-in-place permissions use the current validated pose. Merely previewing a site or selecting a menu option does not reposition the player.
4. Check current threats, entitlement, legal context and owner vetoes immediately before each TIME-002 segment. An eligible but untriggered spawner alone is insufficient to deny sleep. If it produces a relevant encounter, settle that encounter at its governing boundary and recheck before another segment. Applied restrictions and interruptions follow CORE-019 and TIME-004, without automatic restart when the blocker clears.

## Timing, expiry and dependencies

- Under ECON-015, a rental is valid until its exact exclusive expiry. Split or stop a rental-authorized sleep at that instant. Settle the expiry before authorizing another segment and tell the player why sleep ended. Another permission does not silently replace the rental during the same sleep. A new request can use a currently valid permission. TIME-010/011 and CHAR own reconciliation of recovery at a shared expiry boundary.
- MAGIC-028 hunger prevents starting sleep and interrupts ongoing sleep at the applicable threshold. Under TIME-001 millisecond precision and MAGIC-028's inclusive predicate, the actor is satiated through `last feeding + 24 game hours`. The first representable hungry instant is one game millisecond later. MAGIC owns the predicate and any modded duration. TIME coordinates interruption and already committed work under TIME-004.
- CORE-019 owns rest threat and veto evaluation. NPC and encounter owners supply current hostility and spawner readiness. ECON owns rental records and entitlements. LAW owns charge and response. LOC/WORLD identify camping zones, bed placement and permissions with relevant ECON, FACT or other owners. TIME-010/011 own sleep modes, durations, encounter and recovery ordering. This feature adds no threat radius or encounter odds.

## Required data, inputs, outputs and events

Use committed session, actor, operation and location identities, site classification and jurisdiction, entitlement identity and expiry, authored bed and fallback IDs, threat and veto outcomes, legal confirmation and enforcement state, and safe placement results. Inputs include a sleep request, responses to confirmation, and current owner state. Outputs include allowed context, warning required, denied, verification failed, placement ready or interrupted, with player-safe feedback. Publish committed placement and eligibility outcomes after owner checks. API and signal names remain implementation decisions.

## Configuration, failures and save/load

- Mods can author campsites, shelter and location exceptions, sleep permissions, bed/fallback references and compatible rest restrictions through validated owner data and hooks. A site exception does not silently remove an independent threat or status veto. Validate required references through DATA-003 and the applicable owners.
- Distinguish no entitlement, unsafe site, blocked bed, current threat and inability to verify. A generic threat message reveals no hidden actor identity, location or count. An invalid required context gates further rest. A technical failure preserves committed time and consequences under TIME-004. Closing or retrying a prompt cannot double-commit legal or movement work.
- Restore authoritative entitlement and site facts through their owners. Do not persist a cached safe result or transient scene marker. If TIME-010/011 and SAVE support a mid-rest save, restore the operation and already committed consequences, resolve current context and revalidate before further progression. Loading adds zero elapsed time and does not replay placement or a charge.

## Acceptance criteria

1. Suitable wilderness and dungeon sleep is admitted when threats and vetoes pass. A town building with no applicable permission denies sleep. Owned lodging, active rental and valid guild or guest permissions work at their eligible sites.
2. Cancel an illegal camping warning or open the rest menu and verify zero charges. A committed illegal attempt makes at most one permitted filing and guard request, including with warnings disabled. Engaged enforcement stops further sleep. Ordinary waiting and denied indoor sleep produce no stock vagrancy.
3. A valid rental moves the player to the assigned accessible bed on commitment. A locked, occupied, missing or unsafe bed uses only a safe authorized fallback in the same lodging. Otherwise sleep advances zero time. A stale prompt or retry cannot duplicate a placement or charge.
4. Rental sleep stops at the exact expiry and explains the reason. Hunger stops sleep at the applicable threshold. Previously committed elapsed time stands and no recovery is awarded for unelapsed time.
5. An eligible untriggered spawner does not block sleep solely by proximity. A relevant spawned encounter is accounted for before the next segment, and newly ineligible rest stops with player-safe feedback.
6. An authored campsite or exception changes site eligibility through validated mod data. An independent threat or veto still applies. Restore or retry rechecks live eligibility before spending time.

## Consistency review and outstanding dependencies

The specification preserves CORE-019 fresh checks, LAW-006 warning and enforcement, ECON-015 rental expiry, MAGIC-028 inclusive hunger, MOVE-026 access and placement, and TIME-002/004 interruption and recovery. Exact campsite criteria, bed reachability and fallback schemas, encounter parameters, shared-boundary recovery order, and mid-rest save support remain owner dependencies.
