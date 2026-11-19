# FACT-017 — Knightly order rewards

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-017-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-017-interview-decisions).

## Gameplay purpose and intended experience

Members claim armor and housing through their order. Players can leave an armor selection and return to the same choices. Eligible room and ship privileges appear automatically in booking and travel terms.

## Confirmed requirements

- Allow one explicit armor claim at the player's current rank. Generate three to six choices once and retain them through closing, failed delivery, and reload. Consume the claim only on delivery. A promotion that skips ranks grants no retroactive claims.
- Allow one rank 9 house claim per character and order. Require no existing house and select randomly from eligible homes for sale in the authorized settlement. Keep the claim open when none is available.
- Apply stock room and ship privileges automatically at their thresholds. Recheck access before booking or departure. Waive the applicable cost while retaining ownership and other travel requirements. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-017-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Guilds/KnightlyOrder.cs#ReceiveArmor` uses a claim bit per rank and generates random armor pieces with material indexed by rank from Iron. Its comment describes three to six choices, while the inclusive countdown adds four to seven. The selection callback sets the claim flag. `ReceiveHouse` checks rank 9, the claim flag, existing ownership, and local houses for sale, then selects one randomly. `FreeTavernRooms` permits free rooms in the order's home region at member ranks and anywhere from rank 4. `FreeShipTravel` permits free travel from rank 6. The tavern and travel code consume these benefit queries.

## Detailed rules and parameters

1. Resolve the exact active order membership and committed rank under FACT-009/011. Claim services use an authorized provider and FACT-014 revalidation. Armor eligibility is for the current rank. A pending offer for another rank remains stored and can be used only if the player later holds that rank again and qualifies.
2. Generate a uniform count from three through six when the player first opens an eligible armor claim. Use the stock armor piece pool and rank-indexed material, with ITEM owning item creation and compatibility. Retain the generated choices. After a player confirms a piece, retain that exact selection if delivery is blocked. Commit item delivery and the used claim together. Discard unused choices after successful delivery.
3. For housing, require actual rank 9 or higher and no existing house under the housing owner's rules. The authorized settlement supplies the eligible homes for sale. Select uniformly from the eligible candidates and revalidate before allocation. Commit ownership and the used claim together. A missing eligible home leaves the claim open. A technical fault follows owner recovery.
4. A stock active member gets free eligible rooms in the order's home region. Rank 4 extends the benefit to eligible rooms elsewhere. Rank 6 waives eligible ship fare. The appropriate service owner applies the waiver to its quote. For travel spanning regions, the lodging owner uses the region of the lodging being priced. A waiver confers no deed, ship ownership, room reservation, or bypass of other requirements.
5. Before booking or departure, check current membership, rank, and context. If a revised quote changes the accepted amount, require renewed acceptance under RULE-021 and the applicable service owner. A later rank change does not alter an already committed booking or trip.

## Approved integration defaults

- Store armor claim history per character, order, and rank, and housing history per character and order. Resignation, rejoining, demotion, and sale of an awarded house do not reset used claims.
- Retain a selected house through technical retry. If the housing owner confirms it is no longer eligible before commitment, leave the entitlement open for a fresh authorized claim using the current eligible list.
- Check each cost waiver once. Multiple eligible memberships do not create additional credit or stack unless an explicit policy defines how they combine.

## Required data, inputs, outputs, and events

Use stable character, order, membership, provider, region, rank, claim, item, and property identities. Retain rank and claim state, generated choices, selected reward, and settled outcomes. Inputs include authorized claim or booking context, current eligibility, ownership, and eligible inventory or property data. Outputs include offered choices, pending delivery, unavailable reward, committed grant, or an applicable cost waiver. Owners publish committed delivery, allocation, and booking outcomes.

## Cross-system interactions

FACT-009/011/014 supply exact membership, rank, and provider access. FACT-015 governs general benefit scoping and stacking. ITEM owns armor creation and admission. ECON owns property allocation and booking terms. TIME and travel owners use lodging and fare terms. RULE-003 governs retained draws and RULE-021 governs changed quotes. FACT-018 and SAVE restore claim history and pending rewards.

## Edge cases and failure conditions

- Closing an armor picker and reopening it preserves the choices. Failed admission preserves the selected piece and leaves the claim unconsumed.
- Skipped ranks create no claims on promotion. A return to a previously claimed rank cannot grant a second piece.
- Existing ownership blocks the house claim. An empty sale list leaves it available. Selling an awarded house does not reopen a used claim.
- A stale provider or lost eligibility blocks a new commitment. A valid waiver cannot be exchanged for gold or used as proof of ownership.

## Configuration and balancing

Stock thresholds are home-region rooms at any member rank, rooms elsewhere at rank 4, ship fare at rank 6, and housing at rank 9. Stock armor has three to six choices and uses material tied to rank. Validated policies can configure reward pools, thresholds, and authorized locations under ITEM and ECON contracts.

## Save/load considerations

Persist used claims and retained pending choices and selections independently of active membership records. Restore them before accepting new claims. Resume outstanding delivery without regenerating selections or reissuing settled rewards. Revalidate any supported uncommitted booking against current entitlement and terms.

## Technical constraints and consistency review

Keep entitlement, random selection, and fulfillment separate. Use exact reward identities for retry. The draft preserves FACT-009 variant isolation, FACT-010 rejoin rules, FACT-011 committed rank, FACT-014 access checks, and RULE-021 quote revalidation.

## Acceptance criteria

1. Opening an eligible armor claim offers three to six retained choices. Closing, failed delivery, and reload do not reroll them. Successful delivery consumes the claim exactly once.
2. A rank 9 member without a house can claim one eligible local home. No eligible homes leaves the claim open. Rejoining or selling the awarded home does not restore a used claim.
3. An eligible member receives free home-region rooms, rank 4 extends lodging eligibility, and rank 6 waives eligible ship fare. Other requirements and ownership remain independent.
4. Loss of eligibility before commitment triggers revalidation and any required new quote. Settled outcomes survive reload and repeated requests.

## Outstanding questions

Exact stock armor pool mappings, property reservation semantics, and persistence schemas remain integration details.
