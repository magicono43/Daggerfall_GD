# ECON-016 — Training, donation and disease treatment routing

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-016-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-016-interview-decisions).

## Gameplay purpose and intended experience

Players can buy practice from trainers, make a voluntary temple offering, or seek a cure from an authorized provider. Each service explains its terms before commitment. Temple visitors can use offered stock routes as nonmembers, with relevant member benefits reflected in the quote.

## Confirmed requirements

Use full eligible carried gold and credit. Preserve provider-specific access and stock temple nonmember eligibility. Confirm positive voluntary donations and preserve their ceremonial stock outcome. Retain DFU treatment pricing and holiday relief as moddable policies, with confirmation for free and paid treatment. Treat eligible incubating vampirism and lycanthropy through their owning cure rules. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-016-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/Guilds/Temple.cs#CanAccessService` admits nonmembers to these offered routes. `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#DoGuildService` dispatches separate training, donation and cure windows. Training checks funds before skill selection and recalculates its fee later. Donations deduct the entered amount and acknowledge the offering. The cure window applies holiday and guild adjustments, and its free holiday path cures on opening. Both cure paths clear the pending vampire or werebeast timer. These are static source observations.

## Detailed rules and behaviors

1. **Authorize and quote.** Bind the offer to the exact provider, service, player, applicable deity or guild, and operating context. Apply FACT-014's visibility and access rules. Stock temple training, donation and treatment routes permit eligible nonmembers. Other trainers use their declared access policy. Show the selected service, expected effects, price and tender. Use ITEM-009's carried coins when sufficient, otherwise eligible carried credit and then coins. Revalidate before commitment. Material changes to scope, fee or tender require renewed acceptance.
2. **Training.** Confirm the exact offered skill and CHAR-016 terms, including time, fatigue, cooldown and price. Commit full payment and accepted start through CHAR-016. That specification governs progression, practice, and any interruption or recovery. An invalid or canceled offer starts no activity.
3. **Donation.** Require a positive whole amount in the declared unit. Confirm the exact amount, temple recipient and any applicable effect before debiting. Stock settlement acknowledges the offering as ceremonial under FACT-016. A mod may attach a disclosed effect through its owner, validated with the full debit. Insufficient funds cannot reduce the donation automatically.
4. **Disease treatment.** Resolve the eligible ordinary infections, including incubating ordinary disease, under MAGIC-021. Include incubating vampirism or lycanthropy only within the transformation owner's permitted cure window. Count each eligible infection once. Established transformations use their separate cure rules. Quote the agreed treatment using knowledge-safe presentation. When nothing is eligible, give a no-service explanation. Confirm both fee-free and paid offers before any cure.
5. **Settle and publish.** Validate the exact treatment scope and full payment before committing the debit and immediate cure. If infection eligibility changes, revalidate and obtain acceptance of materially changed terms. Remove the agreed conditions and their source-owned effects through the appropriate owners. A cure preserves unrelated conditions and previously lost pools under MAGIC-021. Publish committed service facts after settlement. Retain completed facts and recovery obligations if a technical failure crosses a mutation boundary.

## Formulas, parameters and configuration

- Training prices, skill eligibility, duration and practice follow CHAR-016 and the declared trainer profile.
- The donation amount is the accepted positive offering. Mods may define supported tender and disclosed blessings under FACT-016.
- For N eligible infections, the stock cure base is 250 × N gold. Apply the eligible Arkay rank discount from FACT-016, the stock shop cost adjustment, and then the North Winds Festival halving with integer truncation when applicable. Apply stock buy bargaining through the approved RULE-021 stages used by the cure adapter. South Winds Prayer, First Harvest and Second Harvest waive the fee for eligible treatment. Resolve festival policy in the actual service region. Preserve explicit free treatment through pricing. Use checked arithmetic and validated service, benefit and calendar inputs.
- Mods can vary service access, tender, cure scope compatible with effect owners, fees, discounts and holiday policies.

## Required data, inputs, outputs and events

Use stable operation, actor, provider, service and guild or deity identities, calendar and pricing context, accepted terms and tender, and service-specific skill, donation or infection identities. Inputs include quote, confirmation and cancellation. Outputs include actionable denial, changed terms, committed training start, donation or cure, or explicit recovery. Selecting or inspecting a service spends nothing and applies no effect.

## Cross-system interactions

ECON-001 and NPC-004 supply service and provider context. FACT-014/016 own entitlement, Arkay discounts and donation effects. CHAR-016 owns training. MAGIC-021 and transformation owners validate and settle cures. ITEM-009 owns tender. RULE-021 and TIME supply applicable pricing and calendar context. UI presents terms, DATA/MOD validate policies, and CORE/SAVE protect session and recovery.

## Edge cases and failures

- A valid holiday treatment with eligible infections is free and still requires confirmation. An empty eligible scope incurs no payment or treatment.
- If a quoted infection clears, a new one appears, or a special cure window expires before commitment, the old confirmation cannot silently apply a changed cure scope.
- Changed rank, provider availability or tender can block or change an offer. A failed validation leaves funds and service effects unchanged.
- Repeated callbacks cannot duplicate training start, donation, cure or modded effects.

## Save/load and technical constraints

Target Godot 4.7.2. Discard transient offers and confirmations on load. Persist committed payment, training and cure facts and supported donation-effect state through their owners. Preserve any required unfinished settlement facts for recovery. Restore without replaying debits or effects. Keep routing, quotation and fulfillment independently verifiable.

## Acceptance criteria

1. An authorized stock temple offers these routes to an eligible nonmember. Current provider access and complete tender are checked before commitment.
2. Training commits only the accepted skill and terms under CHAR-016. A confirmed stock donation charges the disclosed amount and gives ceremonial acknowledgment.
3. Stock treatment applies the accepted discount and holiday order. Free and paid treatment both require confirmation. No eligible condition produces a no-service result.
4. An eligible incubating transformation counts once and can be cured within its owner-defined window. Established transformation and unrelated effects remain intact.
5. Stale confirmations, cancellation, retry and load cannot cause duplicate payment or service effects.

## Compatibility review and outstanding questions

The specification follows FACT-014 access, FACT-016 ceremonial donations and Arkay discounts, CHAR-016 training settlement, MAGIC-021 cure boundaries and ITEM-009 full tender. Exact cure valuation fixtures, special infection mappings, provider tables and recovery interfaces remain open.
