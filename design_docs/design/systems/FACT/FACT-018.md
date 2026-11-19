# FACT-018 — Faction and membership restoration

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-018-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-018-interview-decisions).

## Gameplay purpose and intended experience

Loading preserves the character's faction standing, political history, guild progress, and earned rewards. If required guild content is missing, the player receives an explanation before the running session is replaced. A supported optional membership can remain inactive with its history intact after the player accepts the disclosed recovery.

## Confirmed requirements

- Block load when a missing or incompatible definition is required or backs an unresolved obligation, unless a validated migration restores it. An explicitly optional membership with no outstanding obligations may remain inactive after disclosed, accepted recovery. Retain its original identity and history. It grants no active benefits.
- Validate candidate state before replacing the running session. Rebuild lookups and entitlements from compatible definitions and saved state. Preserve applicable membership sets, ranks, review dates, political progress, invitations, and used and pending claims. Resume unfinished work at its normal trigger. Loading itself does not invoke joining, rank review, invitation delivery, or reward fulfillment. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-018-interview-decisions).
- Native means saves from this Godot recreation. CORE-013 leaves DFU and classic save import outside the current scope.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SerializablePlayer.cs#RestoreFactionData` restores faction and name dictionaries, adapts older region numbering, and adds registered custom factions. `Game/Guilds/GuildManager.cs#RestoreMembershipData` clears the selected ordinary or vampire set and rebuilds it from saved group and variant records. It skips records if guild creation returns null. `Game/Guilds/Guild.cs#RestoreGuildData` restores rank and last rank-change day. The separate classic import path merges faction reputation with source records, maps membership faction IDs, invokes join for the applicable set, and converts classic rank-change minutes to game days. These are reference behaviors from static inspection.

## Detailed rules and behaviors

1. Prepare candidate state using compatible versioned definitions and stable faction, region, guild, variant, membership set, and record IDs. Apply explicit supported migrations to candidate data and validate the result before replacement. Display names, matching group alone, and package order cannot redirect a reference.
2. Restore mutable standing, social reaction inputs, political relationships and war state, power and rulers, regional conditions, and processed calendar boundaries under their owner rules. Rebuild derived hierarchy and query indexes from validated definitions. Preserve the political and market handoff with ECON and TIME. Restore live reaction effects through their owners and derive their contribution once.
3. Restore ordinary and vampire memberships separately where applicable. Retain exact variant, rank, join and last rank-change dates, relevant departure history, and supported recruitment and benefit records. Rebuild entitlements after the applicable character and transformation state is ready. Preserve used knightly order claims and pending choices independently of current membership.
4. Resolve required logical links with QUEST, ITEM, ECON, and other owners before declaring readiness. An obligation remains required when its provider or beneficiary is missing. Recovery must preserve its authorized target, pending custody, or settled outcome through a supported path. A valid reference can resolve before its scene loads.
5. When an explicitly optional membership cannot be restored and has no outstanding obligations or required dependents, disclose the reason and the effects of continuing. With acceptance, retain it as inactive with original IDs, provenance, and recoverable history. Exclude it from active membership, rank review, entitlements, and recruitment dispatch. If recovery is declined, stop the replacement and preserve the running session.
6. Publish coherent faction and membership state through the native restore lifecycle. Revalidate supported pending work at its owning trigger. Keep the saved identities and outcomes for settled work. Restoration itself performs no calendar advance or gameplay consequence.

## Approved integration defaults

- Validate both membership sets, even when only one is active. Optional recovery depends on declared requiredness and linked obligations, rather than active set status.
- A returning package can make an inactive record eligible for explicit, validated recovery. Validate compatibility, group limits, and current dependencies before reactivation. Preserve rank and history and do not invoke ordinary join effects.
- For a genuinely new definition in an existing save, initialize live state only under a declared compatibility policy. Keep existing saved values and history intact. Reject invalid values through explicit migration or recovery.

## Parameters and required data

There are no new balance formulas. Use native save and record versions, definition and package provenance, stable references, committed faction and membership state, owner progress and settlement records, and optional recovery metadata. Preserve current bounds and membership policy checks from the approved FACT features.

## Inputs, outputs, and events

Inputs include the native save generation, resolved content plan, candidate FACT records, migration support, owner dependency results, and the accepted recovery choice where applicable. Outputs include validated restored state, disclosed inactive optional records, or actionable blocking diagnostics. CORE-013 publishes Session Restored after readiness. Restore emits no join, rank change, invitation, or reward event.

## Cross-system interactions

CORE-013 and SAVE coordinate preflight, session replacement, readiness, and recovery. DATA-009 and MOD supply validated compatible definitions. FACT-001–008 supply faction state and progress. FACT-009–017 supply membership, recruitment, and benefits. MAGIC-028 supplies applicable transformation context. TIME and ECON coordinate saved market progress. QUEST-022 and the item and housing owners validate obligations, custody, and settled outcomes.

## Edge cases and failure conditions

- A missing guild with a pending armor delivery or required quest binding blocks load absent a supported resolution. A missing explicitly optional membership with no required dependency may remain inactive after disclosed recovery.
- A guild rename preserves identity. A removed variant cannot become a different variant by matching display name or guild group.
- Duplicate records, invalid rank, or incompatible exclusivity rules require explicit validation and recovery. Restoring one valid set cannot publish a partial result while required data in the other fails.
- A due invitation remains pending until its normal eligible trigger. A used claim, committed war outcome, or processed time boundary cannot settle again.

## Configuration and balancing

Declare optional recovery eligibility and supported migrations in versioned owner policies. Content updates can add compatible definitions through a declared initialization policy. Required validation cannot be bypassed by a balance setting.

## Save/load considerations

Save a coherent snapshot of owner state and retain sufficient identity and progress to distinguish pending from settled work. Derived indexes and entitlement views rebuild after restore. Coordinate unsupported intermediate states with SAVE's defer or recovery policy. Keep inactive records recoverable without making them active on package discovery alone.

## Technical constraints and consistency review

Validate before publishing and keep authoritative saved state separate from definitions and derived lookups. Preserve CORE-013's native scope and recovery consent, DATA-009's required reference validation, QUEST-022's obligation checks, and approved FACT rules for exact variants, time progress, and claim retention.

## Acceptance criteria

1. Native round-trip preserves standing, political and calendar progress, both applicable membership sets, rank dates, recruitment, and used and pending claims.
2. Missing required definitions or unresolved obligations block replacement with a reason unless an explicit migration validates. The running session remains intact after preflight rejection.
3. An optional unresolved membership with no outstanding obligations becomes inactive only after disclosed recovery is accepted. Its history remains available and it grants no benefits.
4. Restore rebuilds exact membership and faction queries before gameplay resumes and emits one session restoration outcome. It does not replay previously settled effects.
5. A retained invitation, claim, or market step resumes only its unfinished work at the owner's eligible boundary.

## Outstanding questions

Exact schemas, supported migration inventory, and diagnostic wording remain integration details.
