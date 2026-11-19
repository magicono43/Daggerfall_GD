# FACT-015 — Hall access, training, and member pricing

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-015-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-015-interview-decisions).

## Gameplay purpose and intended experience

Guild membership gives practical benefits at authorized halls and providers. Players can see which guild discounted a repair, use an eligible hall after hours, and receive the guild reward they earned. Each benefit has a defined scope that mods can extend.

## Confirmed requirements

- Keep stock hall access, rest, training and recharge tied to the exact guild and an authorized hall or provider. After-hours entry preserves service availability rules. Rest permission preserves normal safety checks. Mods can explicitly authorize partner providers or other locations.
- Preserve the DFU Fighters Guild repair discount and eligible generated quest gold bonus. Show the discount in the quote and recheck it before payment. Settle the bonus once with the quest reward. Use the authorized guild's benefit by default and permit stacking only through an explicit rule. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-015-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/PlayerActivate.cs` allows ordinary opening hours or a matching guild's `HallAccessAnytime`. `Game/Guilds/FightersGuild.cs` allows members to rest and grants after-hours entry at rank 6. `MagesGuild.cs` also uses rank 6. The Thieves Guild and Dark Brotherhood grant after-hours access to members. `Game/UserInterfaceWindows/DaggerfallRestWindow.cs` checks guild permission in the building. `DaggerfallGuildServicePopupWindow.cs` refills magicka on opening for a Mages Guild member with a career that prevents natural regeneration. `Guild.cs` supplies the stock training price and cap. `Game/Formulas/FormulaHelper.cs` applies the supplied guild's repair adjustment, and `Game/Questing/Item.cs` applies `AlterReward` on its generated gold branch. The explicit gold-range branch follows its own calculation.

## Detailed rules and formulas

1. Resolve exact guild, variant, membership set, provider or hall, and actual committed rank under FACT-009/011/014. Use each benefit's declared location and audience. A partner provider requires explicit authorization. Apply the authorized guild's benefit by default. An explicit stacking policy declares eligible sources, order, and limits.
2. For stock after-hours entry, require rank 6 for Fighters and Mages Guild members and any member rank for the Thieves Guild and Dark Brotherhood. This permission bypasses ordinary hours for an authorized hall entrance. Each service keeps its own opening and authorization rules. Fighters Guild members may rest in authorized halls if the rest owner allows it, including safety and interruption checks.
3. For authorized training, apply CHAR-016. The stock price is actual player level multiplied by 100 gold for members or 400 gold for eligible nonmembers. The stock trainer maximum is 50 permanent skill, inclusive. The exact provider supplies offered skills and supported overrides. CHAR and TIME own practice, fatigue, duration, and the shared cooldown.
4. At the authorized Mages Guild service interaction, an exact member whose career prevents natural magicka regeneration can receive a free refill to current maximum. Apply through the vitals owner after validating the interaction. The refill grants only the missing amount and creates no natural regeneration capability.
5. For a nonnegative base repair quote or generated Fighters Guild gold amount `x` and qualifying stock rank `r`, use DFU fixed-point rounding. Set the factor to `floor(256 * (10 - r) / 10)` for repair or `floor(256 * (10 + r) / 10)` for generated gold, then calculate `floor(x * factor / 256)` with safe intermediate arithmetic. Apply repair adjustment to the service owner's calculated repair quote. Apply the reward adjustment only to eligible generated gold for the authorized Fighters Guild context. Keep the stock generated gold minimum of one. Explicit fixed or ranged rewards follow their authored amount unless an authorized adjustment is declared.
6. Show the repair adjustment and final terms before acceptance. Revalidate the entitlement and price before payment. If the final price changes, request renewed acceptance under RULE-021. Commit quest gold and its adjustment once under QUEST-019 and reuse the settled outcome on retry.

## Approved integration defaults

- Capture the rank and generated reward amount when the quest reward owner first settles its payable amount. Preserve that amount through later fulfillment, retries, or rank changes. The accepted quest's faction binding remains intact. An unpriced pending consequence evaluates its current entitlement under the applicable quest policy.
- Treat an automatic refill as one effect per authorized service entry, after any due rank review. Replayed callbacks or a restored settled entry cannot refill a second time. A new authorized visit can refill again if the player qualifies.
- For repairs, defer any minimum charge or explicitly free repair rule to the repair owner. An already repaired item does not become a paid repair because a membership adjustment applies.

## Required data, inputs, outputs, and events

Use stable guild, variant, provider, hall, membership and benefit identities, committed rank, applicable career trait, actual level and permanent skill, service or quest context, base amount, and any explicit stacking policy. Return access or denial, training terms, repair quote adjustment, recharge result, or settled reward amount. Vitals, service, and quest owners emit committed outcomes.

## Cross-system interactions

FACT-009/011/014 supply exact membership, rank and service authorization. LOC and MOVE own building entry. CORE-019 and TIME own rest safety and execution. CHAR-016 owns training and the vitals owner applies recharge. ECON and RULE-021 govern repair terms and payment. QUEST-019/022 own reward settlement and restoration. DATA and MOD validate benefit policies.

## Edge cases and failure conditions

- Rank 6 authorizes after-hours entry at a matching stock Fighters or Mages hall. It does not authorize a closed service. Rest permission cannot waive an unsafe rest condition.
- An unrelated membership supplies no discount or refill. A declared partner provider may offer the exact benefit its policy authorizes.
- A rank or membership change can alter an open repair quote. Existing committed repairs and settled quest rewards retain their terms.
- Missing required mappings or incompatible policy values yield explicit unavailability. A full magicka pool receives no change.

## Configuration and balancing

Validated policies may change benefit locations, audience, thresholds, training terms, and adjustment parameters. Explicit stacking can configure order and limits. Preserve owner bounds and arithmetic validation when a mod uses ranks outside the stock range.

## Save/load considerations

Restore membership and rank through their owners. Rebuild entitlement queries from current policy and provider state. Persist settled reward amounts and committed transaction outcomes where the owner supports recovery. Revalidate any retained uncommitted quote. Loading does not trigger entry benefits by itself.

## Technical constraints and consistency review

Keep entitlement read-only until the service owner commits an effect. Preserve FACT-014 access checks, CHAR-016 training terms, CORE-019 rest safety, RULE-021 renewed acceptance, and QUEST-019 settled reward identity. The complete stock library offering and specialized temple or order benefits remain with their applicable service definitions and features.

## Acceptance criteria

1. Stock hall access follows the stated ranks, and Fighters Guild rest still fails when unsafe. An authorized partner can supply an explicitly shared benefit.
2. At actual level 5, eligible stock training quotes 500 gold for members or 2,000 gold for nonmembers, with the inclusive permanent skill maximum of 50.
3. A qualifying Mages Guild visit refills only missing magicka. An ineligible visit or duplicate callback adds none.
4. At Fighters Guild rank 5 and base amount 100, stock repair yields 50 and eligible generated gold yields 150 before any applicable owner rule. Revalidation catches changed repair terms. A settled reward keeps its amount after rank changes or reload.
5. Multiple memberships do not combine by default. A validated stacking rule applies only to its declared context.

## Outstanding questions

Exact provider mapping coverage, specialized service profiles, and save schema remain integration details.
