# ECON feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Paths are relative to `Assets/Scripts/`. Symbols follow `#`. Complexity estimates review scope. Confidence rates the sampled source trace.

## ECON-001 — Merchant routing and access

- **Parent subsystem** — Commerce
- **Purpose** — Route building and NPC context to a shop or service.
- **Existing implementation** — PlayerActivate resolves building unlock context. Merchant and guild popups provide distinct interaction entry points. Services maps NPC faction/service IDs and supports custom merchant callbacks.
- **Source** — `Game/PlayerActivate.cs#BuildingIsUnlocked`, `Game/UserInterfaceWindows/DaggerfallMerchantServicePopupWindow.cs`, `Game/Guilds/Services.cs#RegisterMerchantService`
- **Inputs and outputs** — Building, actor and service ID → available interaction
- **Dependencies** — MOVE-020, NPC, FACT-014, MOD
- **Edge cases and interactions** — Verify shop hours, guild exemptions and custom service precedence.
- **Design questions** — Which services should require a location, NPC or open building?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

See [ECON-001 — Merchant routing and access](../../design/systems/ECON/ECON-001.md).

## ECON-002 — Stock sourcing and item eligibility

- **Parent subsystem** — Commerce
- **Purpose** — Determine what each merchant can transact.
- **Existing implementation** — Shop shelves use building-based stocking. Trade maintains merchant and basket collections with local and remote filtering. Guild magic stock has a dedicated retrieval path.
- **Source** — `Internal/DaggerfallLoot.cs#StockShopShelf`, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#FilterLocalItems`, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#FilterRemoteItems`, `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#GetMerchantMagicItems`
- **Inputs and outputs** — Shop context and item collections → displayed stock and eligible selections
- **Dependencies** — ITEM-021, FACT, TIME
- **Edge cases and interactions** — Verify restock persistence, accepted item categories and generated guild stock.
- **Design questions** — Which stock should refresh and which merchants should buy each category?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-13

### My Intended Specification

See [ECON-002 — Stock sourcing and item eligibility](../../design/systems/ECON/ECON-002.md).

## ECON-003 — Basket and price quotation

- **Parent subsystem** — Commerce
- **Purpose** — Stage an offer before committing it.
- **Existing implementation** — Trade maintains a basket and exposes separate price, display and selection-clear paths. Shared formula inputs include regional adjustment, shop quality, Mercantile and Personality.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#GetTradePrice`, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#UpdateCostAndGold`, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#ClearSelectedItems`, `Game/Formulas/FormulaHelper.cs#CalculateTradePrice`
- **Inputs and outputs** — Selected items, mode and merchant/player context → quote
- **Dependencies** — RULE-021, ITEM, CHAR, UI
- **Edge cases and interactions** — Check quantity, cancellation, region lookup and price changes between quote and confirmation.
- **Design questions** — Should confirmation lock the quoted amount?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-003 — Basket and price quotation](../../design/systems/ECON/ECON-003.md).

## ECON-004 — Purchase settlement

- **Parent subsystem** — Commerce
- **Purpose** — Exchange payment for selected stock.
- **Existing implementation** — On buy confirmation the trade window recomputes price, deducts player funds, raises a trade notification and transfers the basket to player inventory. Confirmed trade also tallies Mercantile.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#DoModeAction`, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#ConfirmTrade_OnButtonClick`, `Game/Entities/PlayerEntity.cs#DeductGoldAmount`
- **Inputs and outputs** — Basket, payment and confirmation → debit, trade event and items
- **Dependencies** — ITEM-007, ITEM-009, CHAR-012, UI
- **Edge cases and interactions** — Notification occurs before transfer. Verify affordability and carry checks across quote and commit.
- **Design questions** — When should the purchase become observable to listeners?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-004 — Purchase settlement](../../design/systems/ECON/ECON-004.md).

## ECON-005 — Sale settlement and credit payout

- **Parent subsystem** — Commerce
- **Purpose** — Pay for accepted items.
- **Existing implementation** — Sell and SellMagic pay coin when its weight fits. Otherwise they issue a letter of credit at the trade price. The event is raised before clearing the sold collection.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#ConfirmTrade_OnButtonClick`, `Game/Items/ItemBuilder.cs#CreateItem`
- **Inputs and outputs** — Sold items, trade value and carry limit → coin or credit and item removal
- **Dependencies** — ITEM-008, ITEM-009, RULE-021, UI
- **Edge cases and interactions** — Verify weight calculation when the sold items were carried or in the wagon.
- **Design questions** — Should the seller choose payout type?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-005 — Sale settlement and credit payout](../../design/systems/ECON/ECON-005.md).

## ECON-006 — Shop theft alternative

- **Parent subsystem** — Commerce
- **Purpose** — Handle taking stock outside a sale.
- **Existing implementation** — Trade has a separate DoSteal path and can assign Theft. Detection math is separate from settlement and the downstream legal response belongs to LAW.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#DoSteal`, `Game/Formulas/FormulaHelper.cs#CalculateShopliftingChance`
- **Inputs and outputs** — Selected stock and detection context → theft result or charge
- **Dependencies** — LAW-004, RULE-010, ITEM
- **Edge cases and interactions** — Verify the handling of a partially selected basket and what happens to stock on detection.
- **Design questions** — When should merchants identify an attempted theft?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-006 — Shop theft alternative](../../design/systems/ECON/ECON-006.md).

## ECON-007 — Repair payment and collection

- **Parent subsystem** — Item services
- **Purpose** — Pay for repair and retrieve serviced items.
- **Existing implementation** — Repair confirmation deducts funds and either sets full condition for instant repairs or commits timed repair work. The window can interrupt or collect repairs through separate paths.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#ConfirmTrade_OnButtonClick`, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#UpdateRepairTimes`, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#TakeItemFromRepair`, `Game/Items/ItemRepairData.cs#Collect`
- **Inputs and outputs** — Selected items, quote, repair setting and elapsed time → paid repair or collection
- **Dependencies** — ITEM-014, RULE-023, FACT-015, TIME
- **Edge cases and interactions** — Check whether interrupting retains partial work, and how wrong-location pickup is handled.
- **Design questions** — Should repairs be prepaid, refundable or interruptible?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-007 — Repair payment and collection](../../design/systems/ECON/ECON-007.md).

## ECON-008 — Paid identification

- **Parent subsystem** — Item services
- **Purpose** — Reveal selected item properties for a fee.
- **Existing implementation** — Identify mode deducts the trade price and calls IdentifyItem for each remote item before notifying trade listeners. The rule can apply guild pricing or holiday relief.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#ConfirmTrade_OnButtonClick`, `Game/Items/DaggerfallUnityItem.cs#IdentifyItem`, `Game/Formulas/FormulaHelper.cs#CalculateItemIdentifyCost`
- **Inputs and outputs** — Selection, fee, guild and calendar → identified items
- **Dependencies** — ITEM-019, RULE-023, FACT, TIME
- **Edge cases and interactions** — Verify already identified items, zero-price services and cancellation.
- **Design questions** — Should identification be per item, stack or entire selection?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-008 — Paid identification](../../design/systems/ECON/ECON-008.md).

## ECON-009 — Regional coin deposits and withdrawals

- **Parent subsystem** — Banking
- **Purpose** — Move coin between player and regional account.
- **Existing implementation** — Deposit checks carried plus wagon coin, credits the account and debits carried coin before wagon coin. Withdrawal checks balance and player encumbrance. MakeTransaction checks region index and emits a result event.
- **Source** — `Game/DaggerfallBankManager.cs#MakeTransaction`, `Game/DaggerfallBankManager.cs#DepositGold`, `Game/DaggerfallBankManager.cs#WithdrawGold`
- **Inputs and outputs** — Region, amount, cash and carry limit → balance and coin changes
- **Dependencies** — ITEM-008, ITEM-009, UI, SAVE
- **Edge cases and interactions** — Direct methods and UI may have different validation. Test nonpositive amounts and max-weight boundary.
- **Design questions** — Which balances should be accessible away from their region?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-009 — Regional coin deposits and withdrawals](../../design/systems/ECON/ECON-009.md).

## ECON-010 — Letters of credit

- **Parent subsystem** — Banking
- **Purpose** — Convert regional deposits to portable credit.
- **Existing implementation** — Withdraw_LOC charges commission, requires at least 100 and creates a credit item. DepositAll_LOC loops through inventory credits, adds face value to the selected account and removes each item.
- **Source** — `Game/DaggerfallBankManager.cs#Withdraw_LOC`, `Game/DaggerfallBankManager.cs#DepositAll_LOC`, `Game/Items/ItemCollection.cs#GetCreditAmount`
- **Inputs and outputs** — Account, amount or credit items → portable credit or deposit
- **Dependencies** — ITEM-009, UI, SAVE
- **Edge cases and interactions** — Commission is truncated to int. Deposit consumes all matching letters in the player collection.
- **Design questions** — Should credit support partial redemption or issuer restrictions?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-010 — Letters of credit](../../design/systems/ECON/ECON-010.md).

## ECON-011 — Loan issue and repayment

- **Parent subsystem** — Banking
- **Purpose** — Create and service regional debt.
- **Existing implementation** — BorrowLoan checks minimum and max-loan rule, adds repayment value to debt, credits principal and sets due date. RepayLoan supports account-only or player funds with account remainder, caps overpayment and clears the date when settled.
- **Source** — `Game/DaggerfallBankManager.cs#BorrowLoan`, `Game/DaggerfallBankManager.cs#RepayLoan`, `Game/Formulas/FormulaHelper.cs#CalculateMaxBankLoan`, `Game/Formulas/FormulaHelper.cs#CalculateBankLoanRepayment`
- **Inputs and outputs** — Region, principal, funds and clock → debt, balance, due date and result
- **Dependencies** — RULE-024, TIME, ITEM-009, SAVE
- **Edge cases and interactions** — Check additional borrowing and whether UI blocks cases manager accepts. Repayment tests available funds before capping overpayment.
- **Design questions** — Should additional borrowing reset the due date?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-011 — Loan issue and repayment](../../design/systems/ECON/ECON-011.md).

## ECON-012 — Reminders and default

- **Parent subsystem** — Banking
- **Purpose** — Process overdue debt and its legal handoff.
- **Existing implementation** — LoanChecker checks reminder month crossings. Overdue handling attempts repayment from the account and flags default once if debt remains, then applies regional legal reputation loss.
- **Source** — `Game/LoanChecker.cs#OverdueLoan`, `Game/LoanChecker.cs`, `Game/DaggerfallBankManager.cs#GetLoanDueDate`, `Game/Entities/PlayerEntity.cs#LowerRepForCrime`
- **Inputs and outputs** — Debt, account funds and elapsed time → notice, automatic repayment or default
- **Dependencies** — TIME, LAW-006, SAVE
- **Edge cases and interactions** — Verify time jumps, partially funded accounts and new debt after a previous default. Classic flag use is uncertain in source comments.
- **Design questions** — How should overdue debt be communicated and cured?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-012 — Reminders and default](../../design/systems/ECON/ECON-012.md).

## ECON-013 — House deeds and ownership

- **Parent subsystem** — Property
- **Purpose** — Acquire or sell a persistent house.
- **Existing implementation** — Bank manager exposes house price, purchase, allocation, sale and ownership checks. Knightly Order has a separate house reward entry point.
- **Source** — `Game/DaggerfallBankManager.cs#GetHousePrice`, `Game/DaggerfallBankManager.cs#PurchaseHouse`, `Game/DaggerfallBankManager.cs#AllocateHouseToPlayer`, `Game/DaggerfallBankManager.cs#SellHouse`, `Game/Guilds/KnightlyOrder.cs#ReceiveHouse`
- **Inputs and outputs** — Building, region, payment or reward → ownership and account changes
- **Dependencies** — FACT-017, LOC, MOVE-020, SAVE
- **Edge cases and interactions** — Check eligible sale inventory, possessions left inside and reward conflicts.
- **Design questions** — What should transfer with the deed?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-013 — House deeds and ownership](../../design/systems/ECON/ECON-013.md).

## ECON-014 — Ship deeds and transport entitlement

- **Parent subsystem** — Property
- **Purpose** — Buy or sell ship access.
- **Existing implementation** — Bank manager has ship types, prices, sale pricing, assignment and coordinates. TransportManager consumes ship context separately from the deed transaction.
- **Source** — `Game/DaggerfallBankManager.cs#PurchaseShip`, `Game/DaggerfallBankManager.cs#SellShip`, `Game/DaggerfallBankManager.cs#AssignShipToPlayer`, `Game/DaggerfallBankManager.cs#GetShipCoords`, `Game/TransportManager.cs#IsOnShip`
- **Inputs and outputs** — Ship type, region and funds → deed/entitlement and transport context
- **Dependencies** — TIME, MOVE-016, SAVE, LOC
- **Edge cases and interactions** — Test replacement, sale while on ship and persistent ship storage.
- **Design questions** — Should ships be owned individually or as a single current deed?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-014 — Ship deeds and transport entitlement](../../design/systems/ECON/ECON-014.md).

## ECON-015 — Rent and extend a room

- **Parent subsystem** — Tavern
- **Purpose** — Buy time-limited lodging tied to a specific inn.
- **Existing implementation** — Tavern calculates a rental offer and has a confirmation path. RentRoom assigns a random rest marker index for a new room, stores building and expiry, and marks the scene permanent. Renewal extends expiry.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTavernWindow.cs#ConfirmRenting_OnButtonClick`, `Game/UserInterfaceWindows/DaggerfallTavernWindow.cs#RentRoom`, `Game/Entities/PlayerEntity.cs#RemoveExpiredRentedRooms`
- **Inputs and outputs** — Inn, rental duration, bed markers and current time → rental and scene persistence
- **Dependencies** — TIME, LOC, FACT-017, SAVE
- **Edge cases and interactions** — No rest marker is a fixture case. Index identity assumes marker ordering remains stable.
- **Design questions** — What rights should a room grant and when do they expire?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-015 — Rent and extend a room](../../design/systems/ECON/ECON-015.md).

## ECON-016 — Training, donation and disease treatment routing

- **Parent subsystem** — Guild services
- **Purpose** — Offer paid character services at eligible guild NPCs.
- **Existing implementation** — Guild popup routes training, donation and cure to separate windows. Training contributes practice under CHAR-016. Donation and cure are distinct service entry points from temple benefit calculation.
- **Source** — `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#DoGuildService`, `Game/UserInterfaceWindows/DaggerfallGuildServiceTraining.cs`, `Game/UserInterfaceWindows/DaggerfallGuildServiceDonation.cs`, `Game/UserInterfaceWindows/DaggerfallGuildServiceCureDisease.cs`
- **Inputs and outputs** — Guild service and player condition/resources → service interaction
- **Dependencies** — FACT-014, FACT-016, CHAR-016, MAGIC-021
- **Edge cases and interactions** — Trace donation input, no-disease case and membership discounts independently.
- **Design questions** — Which services should permit nonmembers or partial payment?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-016 — Training, donation and disease treatment routing](../../design/systems/ECON/ECON-016.md).

## ECON-017 — Spell, magic item and potion commerce

- **Parent subsystem** — Guild services
- **Purpose** — Route magical offers and crafting services.
- **Existing implementation** — Guild service dispatch distinguishes buying spells, potions, magic items or soul gems from opening spellmaking, potion making and itemmaking. Magic stock can be requested with a soul-gem filter.
- **Source** — `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#DoGuildService`, `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#GetMerchantMagicItems`, `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#MakePotionService`
- **Inputs and outputs** — Service type, guild and stock → trade or crafting entry
- **Dependencies** — MAGIC-011, MAGIC-012, MAGIC-013, MAGIC-015, FACT-014
- **Edge cases and interactions** — Verify offer inventory, shop pricing and membership paths. Effect composition belongs to MAGIC.
- **Design questions** — Which goods should be sold versus crafted on demand?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-017 — Spell, magic item and potion commerce](../../design/systems/ECON/ECON-017.md).

## ECON-018 — Travel, summoning and nontrade services

- **Parent subsystem** — Guild services
- **Purpose** — Offer specialized guild interactions.
- **Existing implementation** — The guild service switch routes teleport, Daedra summoning, quest offers, spymaster and order rewards through distinct cases.
- **Source** — `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#DoGuildService`, `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#OfferQuest`, `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#ReceiveHouseService`, `Game/UserInterfaceWindows/DaggerfallDaedraSummonedWindow.cs`
- **Inputs and outputs** — Service ID and NPC context → specialized window, offer or reward
- **Dependencies** — QUEST, TIME, FACT-017, RULE-024, MAGIC
- **Edge cases and interactions** — Trace summoning calendar, service fees and failure behavior before design review.
- **Design questions** — Which specialized services should be available by rank, date or location?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-018 — Travel, summoning and nontrade services](../../design/systems/ECON/ECON-018.md).

## ECON-019 — Accounts, deeds and service state restoration

- **Parent subsystem** — Persistence
- **Purpose** — Keep financial and property state across sessions.
- **Existing implementation** — Startup initializes accounts and houses, and classic startup imports native bank records. SaveLoadManager restores deed context. Repair and room states have separate lifecycle paths.
- **Source** — `Game/Utility/StartGameBehaviour.cs#StartNewCharacter`, `Game/Utility/StartGameBehaviour.cs#StartFromClassicSave`, `Game/DaggerfallBankManager.cs#ReadNativeBankData`, `Game/Serialization/SaveLoadManager.cs#RestoreHousesData`, `Game/Items/ItemRepairData.cs#RestoreRepairData`
- **Inputs and outputs** — Native or classic records, location IDs and time → restored accounts, deeds and services
- **Dependencies** — SAVE, CORE-012, CORE-014, ITEM-014, LOC
- **Edge cases and interactions** — Verify region mapping, expired jobs and ownership when location content changes.
- **Design questions** — Which financial state should be repaired or rejected on load?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-14

### My Intended Specification

See [ECON-019 — Accounts, deeds and service state restoration](../../design/systems/ECON/ECON-019.md).

## Classic provenance and review sequence

- Classic saves provide bank records. Building stock, localized prompts and content values need original and packaged fixtures. DFU exposes its own settings for instant repairs and room marker persistence. Static source establishes current behavior at sampled entry points.
- Start with one buy, one sale that pays by credit and one regional bank transfer. Then follow borrowing through partial repayment and default, and verify a house, ship and inn rental across save/reload. Check available and denied services for member and nonmember NPCs.
- RULE owns numeric formulas, ITEM owns ownership and equipment records, FACT owns rank and eligibility, and LAW owns legal consequences. Full shop category tables, UI validation boundaries, specialized service effects and original-game parity remain open.
