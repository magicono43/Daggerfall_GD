# FACT-006 — Alliances, rivalries, and war relationships

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-006-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-006-interview-decisions).

## Gameplay purpose and intended experience

Give factions political relationships that affect regional simulation, rumors, and explicitly propagated standing changes. Two provinces can make peace while remaining rivals. An authored one-way relationship can make a quest's consequences depend on which faction authorized it.

## Confirmed requirements

- Preserve authored and imported directional links. Ordinary simulated alliances and rivalries are reciprocal and commit together. If either side lacks capacity, reject the change. Keep three ordered slots per relationship kind where DFU compatibility requires them. New policies define their own limits.
- Track war as an explicit reciprocal state. The stock simulation can start war between bordering provinces with an existing rivalry. Ordinary rivalry expiry cannot end an active war. Peace removes hostility created solely for the war and preserves independent rivalry. Supported compatibility content can use DFU's cleanup of both enemy links. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-006-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Player/PersistentFactionData.cs#StartFactionAllies` and `StartFactionEnemies` write the selected initiator slot and attempt to write the first empty reciprocal slot. They can return success after a one-sided write. The end methods clear matching slots in both records. Ally and enemy queries inspect the requested direction. The common-relationship count compares all slot pairs, including equal empty entries. The border check uses a regional adjacency table. `Game/Entities/PlayerEntity.cs#RegionPowerAndConditionsUpdate` uses bordering province rivalries for war, skips ordinary expiry for protected border rivalries, and clears both directions at war conclusion.

## Detailed rules and behaviors

1. Keep authored relationship definitions separate from current political state. Each relationship identifies its endpoints, kind, direction, and source. A reciprocal relationship is visible from both endpoints. Directional queries report the actual outgoing link. A missing required endpoint is an explicit failure.
2. A simulated alliance or rivalry validates both endpoints and both capacities before changing either. Apply and end both sides together. Capacity is checked against the effective links of the requested kind. Supported compatibility views preserve the ordered slots and empty positions FACT-003 needs. Authored direction does not imply a reciprocal link.
3. A war identifies the two province participants and its lifecycle state. A stock start requires both province definitions, a valid border, and an existing rivalry. FACT-007 owns when eligible wars start and how they progress. While war is active, ordinary rivalry expiry cannot remove effective wartime hostility or end the war.
4. At peace, remove war-scoped hostility and preserve independent rivalry. The explicit compatibility cleanup removes matching enemy links in both directions and preserves unrelated links. Commit war and relationship changes before consumers receive the outcome.

## Approved defaults

- Reject self-links and contradictory effective ally and enemy links in the same direction in native policies. Permit explicitly authored asymmetry across opposite directions. Retain legacy ordered entries for supported compatibility behavior, including overlap used by FACT-003.
- Repeating an already satisfied start or end returns a no-change outcome. Reject stale or unauthorized transitions with an explicit reason. Keep a distinct existing source when the same link also represents wartime hostility. Expiry may remove an eligible independent source while the active war continues to supply hostility.
- For native political counts, count distinct shared outgoing allies and distinct shared outgoing enemies, excluding empty slots. FACT-007 owns how those counts affect transition odds.

## Parameters, required data, inputs, and outputs

Use stable faction and region IDs, directional authored links, mutable links and their sources, capacity policy, legacy slot positions, validated province adjacency, and current war state. Inputs include endpoints, relationship kind, authority and cause, and the selected transition policy. Outputs include directional and reciprocal query results, committed changes, unchanged results, or explicit rejection. Relationship and war changes notify consumers after commitment. No transition directly changes the player's faction standing.

## Cross-system interactions

DATA-009 validates authored directions and targets. FACT-001 supplies identities and separate structural ancestry. FACT-003 reads the committed relationship view, including compatibility slot order, when a standing effect requests propagation. FACT-007 owns regional simulation and war timing, WORLD provides adjacency, and ECON and NPC consume committed regional outcomes. TIME supplies simulation boundaries and SAVE restores live state.

## Edge cases and failure conditions

- A full reciprocal endpoint prevents a simulated start. It creates no one-way link and displaces no existing relationship.
- A declared one-way link is visible from its source only. Directional cycles are valid. The operation does not implicitly add transitive relationships.
- If two provinces make peace and their rivalry has an independent source, rivalry survives under the native policy. If hostility came solely from the war, it ends with peace.
- Duplicate delivery or a rejected operation creates no second transition or rumor. Missing required endpoints and invalid restored relationships use explicit validation and recovery.

## Configuration and balancing

Compatibility keeps three ordered ally slots and three ordered enemy slots per faction where required. Native limits come from the selected policy. Stock war eligibility uses bordering provinces. Start odds, progression, duration, and regional consequences belong to FACT-007 and related features.

## Save/load considerations

Persist current relationships, their direction and sources, active wars and their participants, and legacy order where applicable. Restore authored definitions and validate the resulting live state before publishing it. A restored war preserves the distinction between wartime and independent hostility. Loading does not reissue committed transition events. Removed required definitions use DATA-009 and SAVE compatibility handling.

## Technical constraints and consistency review

Publish reciprocal changes and their war state coherently. Keep authored defaults, live diplomacy, player standing, and regional legal standing distinct. The draft preserves DATA-009 authored direction and FACT-003's ordered compatibility propagation. The outcome of a settled quest effect remains fixed even when relationships later change.

## Acceptance criteria

1. An authored one-way link resolves only in its declared direction. An ordinary simulated start succeeds in both directions or makes no change when either endpoint is full.
2. A bordering province pair with an existing rivalry is eligible for stock war. A nonbordering pair is ineligible under that policy.
3. Ordinary expiry leaves active war hostility intact. Native peace preserves independent rivalry and removes war-only hostility. Compatibility peace clears both enemy links for the pair.
4. FACT-003 sees the committed relationship view and legacy slot order. Relationship changes alone leave player standing unchanged.
5. Save and reload preserve relationship direction, war state, independent rivalry, and ordered slots without replaying transitions.

## Outstanding questions

FACT-007 owns simulation odds, war phases, and ordering. Exact native capacities, legacy fixture coverage, and persistence schemas remain integration details.
