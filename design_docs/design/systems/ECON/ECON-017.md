# ECON-017 — Spell, magic item and potion commerce

**Approval status** — Approved, finalized v1 on 2026-11-14. See ECON-017-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#econ-017-interview-decisions).

## Gameplay purpose and intended player experience

Players can learn offered spells, buy ready-made magical goods, or access a maker through an authorized provider. Each route shows what it offers and what the player must pay before granting the goods or spell knowledge.

## Confirmed requirements

Stock potion purchase services generate fresh stock on each new opening. Keep skill-linked spell prices with applicable Witches Festival relief and buy bargaining. Stock spell purchases grant no Mercantile practice. Mods can change stock and pricing policies and award spell purchase practice using the committed price and currency unit. See [interview decisions](../../GAMEPLAY_DECISIONS.md#econ-017-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#DoGuildService` routes spell, potion, magic-item and soul gem purchases separately from maker services. `GetMerchantPotions` generates fresh stock on entry, with a loop that produces quality plus one entries for nonnegative quality. `DaggerfallSpellBookWindow.cs` bases the spell price on four times calculated spell-point cost, halves the basis on Witches Festival with a one-gold floor in that branch, then applies buy bargaining. It checks for a spellbook and deducts funds and adds the current selection on confirmation. That handler has no Mercantile award. These are static source observations.

## Detailed rules and behaviors

1. **Authorize offers.** Bind each route to the exact provider, guild or variant, and service context. Use FACT-014's approved entitlement and visibility policies, including stock nonmember access where offered. Resolve spell catalogs and physical stock through their declared sources. Maker routes hand off to the approved MAGIC service owners for custom creation and payment.
2. **Stock potions.** Each newly opened authorized potion purchase interaction generates fresh stock for its declared source using the stock DFU pool and quantity profile. Retain that result within the interaction. Selection changes, confirmation cancellation, list refresh and technical retry reuse the same stock. Leaving and deliberately reopening permits a new stock draw, including after loading into a fresh interaction. Preserve completed purchases and prevent stale callbacks from operating on the new stock. Mods can replace this cadence with retained daily or other authorized stock.
3. **Magic items and soul gems.** Use ECON-002's retained daily stock and shared depletion when routes expose the same source. Physical purchases follow ECON-003/004 for selection, full tender, capacity, stock transfer and paid-basket Mercantile practice. Magic-item resale follows ECON-002/005.
4. **Learn a spell.** Bind each quote to the exact offered spell and the authorized provider. Apply MAGIC-011's stock spellbook requirement and known-spell checks. Display the accepted spell, price and eligible tender. Use ordinary carried gold and eligible carried credit under ITEM-009. Revalidate at commitment, with renewed acceptance for changed price or material terms. Commit full payment and learning together. A known or invalid offer produces no charge. Publish the completed purchase after both sides commit.
5. **Practice.** Stock learning purchases award zero Mercantile practice. A validated mod award policy may use the immutable final committed spell price and currency unit through CHAR-012. Bind its outcome to the purchase identity for duplicate-safe recovery.

## Formulas, parameters and configuration

For stock spell offers, calculate spell-point cost through RULE-018 with live supported inputs. Multiply by four. If the provider region's Witches Festival applies, halve that basis with whole-gold truncation and a minimum basis of one. Apply RULE-021's buy bargaining stage using the authorized provider quality and the resulting basis. Use shared approved final price boundaries. Mods can change the basis, holiday and bargaining policies through validated profiles. Keep casting cost, purchase price and maker valuation separate.

The stock potion count is shop quality plus one for valid nonnegative stock quality. Use declared DFU potion construction pools with compatible ITEM/MAGIC generation rules. Mods may vary pools, counts, stock scope and refresh cadence.

## Required data, inputs, outputs and events

Use stable service, provider, region, offer, spell, stock source, interaction and operation identities, current entitlement and spellbook state, exact selection, policy and valuation context, stock quantities and tender. Return eligible offers, a quote, revised terms or denial, committed learning or goods transfer, or explicit recovery. Viewing a spell does not teach or cast it. Publish only committed facts.

## Cross-system interactions

FACT-014 and ECON-001 supply service access. ECON-002/003/004/005 supply physical stock and settlement. MAGIC-011 owns spell knowledge and book gates. MAGIC-012/013/015 own applicable maker services. RULE-018/021 supply valuation and bargaining. RULE-003 owns generation draws, TIME and RULE-028 supply holiday context, ITEM-009 owns tender, and CHAR-012 records modded practice.

## Edge cases and failure conditions

- A learned spell, lost spellbook or stale provider blocks its pending purchase before payment.
- Live casting cost, holiday, eligibility or tender changes require revalidation. A stale confirmation cannot learn a different offer with the same display name or price.
- Stock potion reopening intentionally allows additional shopping opportunities. A retry within the same interaction cannot regenerate stock.
- If a technical failure crosses a mutation boundary, preserve actual completed facts and recover through the relevant owners without duplicate payment, learning, stock transfer or practice.

## Save/load and technical constraints

Target Godot 4.7.2. Persist learned spells, committed financial and inventory facts, retained daily stock and mod stock state when required by its profile. Stock per-opening potion stock and uncommitted offers are transient. Invalidate pre-load callbacks. Restore supported recovery facts without repeating completed effects or generating stock as part of loading.

## Acceptance criteria

1. An eligible player can reach the declared purchase or maker route through the exact authorized provider. Locked services follow FACT-014.
2. A genuine potion service reopening generates fresh stock. Refresh, cancellation and retry within the same opening preserve its remaining quantities. A mod can select retained daily stock.
3. Guild magic items and soul gems preserve ECON-002 depletion. Physical purchases follow ECON-004 practice and settlement.
4. Stock spell quotes follow the accepted skill-linked and holiday order. The exact valid spell learns only after full payment. Known spells and stale terms cannot charge.
5. Stock spell purchases grant zero practice. A mod can evaluate the committed price and currency unit. Repeated callbacks and load cannot duplicate learning, payment or practice.

## Compatibility review and outstanding questions

The specification follows FACT-014, MAGIC-011 and the approved physical-stock rules. Per-opening refresh applies to stock potions, while ECON-002 retains daily stock for guild magic items and soul gems. Exact stock pool fixtures, spell pricing adapter fixtures and recovery interfaces remain open.
