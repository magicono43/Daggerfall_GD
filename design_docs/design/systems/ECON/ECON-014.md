# ECON-014 — Ship deeds and transport entitlement

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-014-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-014-interview-decisions).

## Gameplay purpose and intended player experience

Players can buy a ship at a port-town bank and gain access to a persistent offshore destination and its storage. An authorized bank can buy the ship back after the player disembarks and retrieves their possessions.

## Confirmed requirements

Allow one stock ship per player. Buy from port-town banks and sell at any authorized bank. Keep the two stock prices and 85% resale, using eligible carried funds before the local account for purchases and crediting sale proceeds to the selling branch's local account. Block sale while aboard, during pending boarding or return, and while player possessions remain aboard. Support moddable trade policies and explicit relocation of belongings. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-014-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/UserInterfaceWindows/DaggerfallBankingWindow.cs` checks ownership and port-town status before purchase and checks ownership before offering sale. `Game/DaggerfallBankManager.cs` stores one owned ship type. `PurchaseShip` draws from carried funds and the local account. `AssignShipToPlayer` registers the corresponding exterior and interior for persistence. `SellShip` credits the local account and removes those registrations without an explicit check for belongings or an active ship visit. These observations come from static inspection.

## Detailed rules and behaviors

1. **Offer and purchase.** Resolve the authorized port-town bank and its local account. Present the eligible ship type, price, destination and tender. Validate the one-ship ownership limit, the selected ship profile and destination data, full funds, and the ownership and persistence plan. Use ITEM-009 within the eligible carried portion before drawing any remainder from the local account. Reconfirm material changes. Commit payment and the deed together.
2. **Grant entitlement.** Bind ownership to the exact ship, its static offshore destination, and persistent interior and exterior state. Expose ownership to MOVE-016 for validated boarding and return. Buying grants permission to use the ship and its specific storage. Boarding remains a separate action. FACT-017 fare waivers remain travel benefits.
3. **Offer and settle resale.** At any authorized bank, bind the offer to the exact owned ship and selling branch's local account. Show the resale amount and explain any restrictions. Check that the player is ashore, the ship has no pending boarding or return, and authoritative interior and exterior records show no stored or dropped player possessions. If a check fails, preserve ownership and explain what prevents the sale.
4. **Release ownership safely.** Revalidate the accepted terms and the approved contents disposition at commitment. Credit proceeds and relinquish the exact deed, owner access and storage rights as one outcome. Preserve protected contents through ITEM and QUEST policies. A modded relocation service must disclose the destination and terms and validate custody before settlement. Concurrent boarding and sale requests cannot invalidate the player's return context.
5. **Publish committed results.** Successful deed purchase and sale notifications follow commitment. Ordinary rejection or cancellation leaves balances, ownership and contents unchanged. A technical failure across a mutation boundary retains completed facts and explicit recovery obligations.

## Formulas, parameters and configuration

Stock ship prices are 100,000 and 200,000 gold for the respective stock ship types. Resale equals floor(stock ship valuation × 85 / 100), yielding 85,000 or 170,000 gold. Compute amounts with checked integer arithmetic. Mods can define supported ship profiles, prices, resale rates, ownership limits, authorized branches, payment sources and compatible belongings relocation. Alternate movement behavior uses the MOVE/LOC contracts.

## Required data, inputs, outputs and events

Use stable player, ship, deed, branch, region, account and operation identities, ship type and destination, ownership and transition status, authoritative contents, quoted amounts and tender or payout. Inputs include quote, purchase and sale requests. Outputs include reviewed terms, actionable rejection, committed deed transfer or explicit recovery. Ownership changes inform the transport and storage owners after commitment.

## Cross-system interactions

ECON-001/009 supply service access and local accounts. ITEM-007/009/021 own tender, possessions and custody. MOVE-016 owns boarding and return, while MOVE-020/022 consume authorized property access. LOC/WORLD supply ship destinations and scene state. FACT-017 owns fare waivers. QUEST protects applicable items. CORE/SAVE restore coherent ownership, transport and recovery facts. DATA/MOD validate profiles.

## Edge cases and failure conditions

- Two banks offering the same ship type cannot grant a second stock ship while an existing deed is active.
- Boarding or return becoming pending after a quote blocks sale. A stale boarding request after a committed sale fails against current ownership.
- Possessions in an unloaded interior or on the exterior still block stock sale. Unavailable contents records require explicit unavailability or recovery.
- Missing ship definitions, failed payment, failed payout or an unavailable relocation destination cannot produce a successful deed transfer with incomplete settlement.

## Save/load and technical constraints

Target Godot 4.7.2. Persist the deed, ship identity, contents and required recovery facts. Restore active visit and return context under MOVE-016 against current ownership before exposing ship actions. Clear transient confirmations. Restore without reissuing payment, proceeds or ownership. Missing destinations or incompatible profiles require explicit migration or recovery that preserves possessions and outstanding transition facts.

## Acceptance criteria

1. A stock port-town bank offers both stock ship types. A non-port bank cannot sell a ship to the player. An authorized non-port bank can buy an eligible owned ship.
2. Purchase uses eligible carried funds and then the local balance. Resale credits exactly the accepted 85% amount to the selling branch's local account.
3. Purchase grants ownership of the exact ship and persistent storage. Boarding uses MOVE-016 and a fare waiver does not grant a deed.
4. Being aboard, a pending transition, or stored or dropped player possessions blocks stock sale. A supported mod can relocate belongings through a validated plan.
5. Failed settlement, stale callbacks and load preserve coherent ownership, contents, return context and balances without duplicate effects.

## Compatibility review and outstanding questions

The specification follows MOVE-016's boarding and return contract, ITEM-021's property-specific storage, ECON-009's local accounts and FACT-017's fare-waiver scope. Exact ship profile fixtures, ownership-transition handling, mod relocation terms and settlement recovery interfaces remain open.
