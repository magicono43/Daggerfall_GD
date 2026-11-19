# ITEM feature catalog

Static decomposition of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Sources are relative to `Assets/Scripts/` and symbols follow `#`. Complexity estimates review scope. Confidence rates the sampled trace.

## ITEM-001 — Template and instance identity

- **Parent subsystem** — Definitions
- **Purpose** — Represent distinct owned items.
- **Existing implementation** — ItemBuilder creates items from groups and templates. ItemHelper loads packaged template lists. Collection identity uses item UID while lookup can use group/template or quest linkage.
- **Source** — `Game/Items/ItemBuilder.cs#CreateItem`, `Game/Items/ItemHelper.cs#LoadItemTemplates`, `Game/Items/ItemCollection.cs#Contains`
- **Inputs and outputs** — Template and instance data → item and lookup identity
- **Dependencies** — DATA-010, SAVE, QUEST
- **Edge cases and interactions** — A duplicate UID is logged on the nonmerge add path. Verify copy and reconstruction identity.
- **Design questions** — Which item fields identify a template versus an instance?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-001 specification](../../design/systems/ITEM/ITEM-001.md) and ITEM-001-A01.

### My Intended Specification

[Approved ITEM-001 specification](../../design/systems/ITEM/ITEM-001.md).

## ITEM-002 — Custom item types and use hooks

- **Parent subsystem** — Definitions
- **Purpose** — Allow content-defined extensions.
- **Existing implementation** — ItemHelper exposes custom item and use-handler registration. ItemCollection restores registered class names by constructing the type and populating its data, otherwise constructs a base item.
- **Source** — `Game/Items/ItemHelper.cs#RegisterCustomItem`, `Game/Items/ItemHelper.cs#RegisterItemUseHandler`, `Game/Items/ItemCollection.cs#DeserializeItems`
- **Inputs and outputs** — Template registration, type and save record → extended item or fallback
- **Dependencies** — MOD, SAVE
- **Edge cases and interactions** — Verify missing mods, renamed classes and handler collisions.
- **Design questions** — How should unsupported custom items survive a reload?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-002 specification](../../design/systems/ITEM/ITEM-002.md) and ITEM-002-A01.

### My Intended Specification

[Approved ITEM-002 specification](../../design/systems/ITEM/ITEM-002.md).

## ITEM-003 — Material, armor and clothing construction

- **Parent subsystem** — Definitions
- **Purpose** — Instantiate equipment variants.
- **Existing implementation** — ItemBuilder has separate weapon and armor creation and material methods. Armor and clothing construction includes gender, race, variant or dye inputs. Random equipment uses level inputs.
- **Source** — `Game/Items/ItemBuilder.cs#CreateWeapon`, `Game/Items/ItemBuilder.cs#ApplyWeaponMaterial`, `Game/Items/ItemBuilder.cs#CreateArmor`, `Game/Items/ItemBuilder.cs#ApplyArmorSettings`, `Game/Items/ItemBuilder.cs#CreateRandomClothing`
- **Inputs and outputs** — Template, material, morphology and variant → equipment item
- **Dependencies** — DATA, RULE-026, CHAR, COMBAT
- **Edge cases and interactions** — Verify allowed material ranges and variant fallback with original assets.
- **Design questions** — Which changes alter mechanics versus appearance?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-003 specification](../../design/systems/ITEM/ITEM-003.md) and ITEM-003-A01.

### My Intended Specification

[Approved ITEM-003 specification](../../design/systems/ITEM/ITEM-003.md).

## ITEM-004 — Magic item and consumable construction

- **Parent subsystem** — Definitions
- **Purpose** — Instantiate items carrying magic data.
- **Existing implementation** — ItemBuilder exposes regular magic item construction and creates potion items from recipe keys, with distinct random and classic potion paths. Soul traps and ingredients have dedicated generators.
- **Source** — `Game/Items/ItemBuilder.cs#CreateRegularMagicItem`, `Game/Items/ItemBuilder.cs#CreatePotion`, `Game/Items/ItemBuilder.cs#CreateRandomClassicPotion`, `Game/Items/ItemBuilder.cs#CreateRandomlyFilledSoulTrap`
- **Inputs and outputs** — Template, recipe, level or generated soul → item instance
- **Dependencies** — MAGIC, DATA-010, RULE
- **Edge cases and interactions** — Trace classic versus custom payload conversion and unknown recipe keys.
- **Design questions** — What should a saved consumable retain if its recipe changes?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-004 specification](../../design/systems/ITEM/ITEM-004.md) and ITEM-004-A01.

### My Intended Specification

[Approved ITEM-004 specification](../../design/systems/ITEM/ITEM-004.md).

## ITEM-005 — Stack matching and insertion

- **Parent subsystem** — Collections
- **Purpose** — Combine compatible item instances.
- **Existing implementation** — AddItem looks for an existing stack and adds count unless noStack is requested. Otherwise it inserts by UID and requested position. RULE-025 describes stack eligibility separately.
- **Source** — `Game/Items/ItemCollection.cs#AddItem`, `Game/Items/ItemCollection.cs#FindExistingStack`, `Game/Formulas/FormulaHelper.cs#IsItemStackable`
- **Inputs and outputs** — Item, collection and noStack flag → merged count or inserted item
- **Dependencies** — RULE-025, SAVE
- **Edge cases and interactions** — The source flags max stack limits as TODO. Audit per-item matching keys, especially quest and conjured variants.
- **Design questions** — Which instance fields prevent merging?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-005 specification](../../design/systems/ITEM/ITEM-005.md) and ITEM-005-A01.

### My Intended Specification

[Approved ITEM-005 specification](../../design/systems/ITEM/ITEM-005.md).

## ITEM-006 — Stack splitting and one-unit removal

- **Parent subsystem** — Collections
- **Purpose** — Move or consume part of a stack.
- **Existing implementation** — SplitStack validates membership and amount. A full-count request returns the same item. A partial request copies it, adds the copy without merging and reduces source count. RemoveOne handles one-unit removal separately.
- **Source** — `Game/Items/ItemCollection.cs#SplitStack`, `Game/Items/ItemCollection.cs#RemoveOne`
- **Inputs and outputs** — Stack and quantity → split item or updated count
- **Dependencies** — UI, COMBAT-008, MAGIC
- **Edge cases and interactions** — Test zero, over-count and full-count requests. Verify custom subclass behavior on copy.
- **Design questions** — When should splitting preserve or create identity?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-006 specification](../../design/systems/ITEM/ITEM-006.md) and ITEM-006-A01.

### My Intended Specification

[Approved ITEM-006 specification](../../design/systems/ITEM/ITEM-006.md).

## ITEM-007 — Collection transfer and selective retrieval

- **Parent subsystem** — Collections
- **Purpose** — Move items across ownership boundaries.
- **Existing implementation** — ItemCollection provides transfer, bulk transfer, copy and replacement paths. Template lookup can exclude enchanted or quest items and prioritize conjured items.
- **Source** — `Game/Items/ItemCollection.cs#Transfer`, `Game/Items/ItemCollection.cs#TransferAll`, `Game/Items/ItemCollection.cs#CopyAll`, `Game/Items/ItemCollection.cs#GetItem`
- **Inputs and outputs** — Source, destination and filters → moved items or selected instance
- **Dependencies** — QUEST, COMBAT, SAVE, UI
- **Edge cases and interactions** — Check duplicate IDs, merged destinations and transfer from the same collection.
- **Design questions** — Which transfers preserve item identity and ordering?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-007 specification](../../design/systems/ITEM/ITEM-007.md) and ITEM-007-A01.

### My Intended Specification

[Approved ITEM-007 specification](../../design/systems/ITEM/ITEM-007.md).

## ITEM-008 — Carry and wagon capacity

- **Parent subsystem** — Collections
- **Purpose** — Limit how much can be transferred.
- **Existing implementation** — Inventory computes permitted quantity separately for player and wagon using unit weight and available capacity. Transfer handles quantity selection. Wagon access has a dungeon proximity path.
- **Source** — `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#CanCarryAmount`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#WagonCanHoldAmount`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#ComputeCanHoldAmount`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#CheckWagonAccess`
- **Inputs and outputs** — Item quantity, current load, capacity and location → accessible transfer amount
- **Dependencies** — CHAR, MOVE-022, TIME, UI
- **Edge cases and interactions** — Test rounding, zero-weight items and wagon access changing while inventory is open.
- **Design questions** — Should capacity block transfers or impose movement penalties?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-008 specification](../../design/systems/ITEM/ITEM-008.md) and ITEM-008-A01.

### My Intended Specification

[Approved ITEM-008 specification](../../design/systems/ITEM/ITEM-008.md).

## ITEM-009 — Gold and credit representation

- **Parent subsystem** — Collections
- **Purpose** — Track money in character and item paths.
- **Existing implementation** — PlayerEntity exposes gold amount and deduction. ItemBuilder can construct gold-piece items, collections total credit, and inventory supports dropping gold through a quantity input.
- **Source** — `Game/Entities/PlayerEntity.cs#GetGoldAmount`, `Game/Entities/PlayerEntity.cs#DeductGoldAmount`, `Game/Items/ItemBuilder.cs#CreateGoldPieces`, `Game/Items/ItemCollection.cs#GetCreditAmount`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#DropGoldPopup_OnGotUserInput`
- **Inputs and outputs** — Coin, credit and requested amount → money total, payment or dropped item
- **Dependencies** — ECON, CHAR, UI
- **Edge cases and interactions** — Trace order of deductions and coin weight versus credit.
- **Design questions** — Which forms of money should be interchangeable?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-009 specification](../../design/systems/ITEM/ITEM-009.md) and ITEM-009-A01.

### My Intended Specification

[Approved ITEM-009 specification](../../design/systems/ITEM/ITEM-009.md).

## ITEM-010 — Slot selection and hand conflicts

- **Parent subsystem** — Equipment
- **Purpose** — Equip a single item in an available slot.
- **Existing implementation** — EquipItem resolves a slot and can split a stack. It rejects arrows, clears both hands for two-handed weapons, and clears a right-hand two-handed weapon when a shield is equipped. Occupied slot handling uses alwaysEquip.
- **Source** — `Game/Items/ItemEquipTable.cs#EquipItem`, `Game/Items/ItemEquipTable.cs#GetEquipSlot`, `Game/Items/ItemEquipTable.cs#GetItemHands`
- **Inputs and outputs** — Item, slot state and replacement policy → equipment and displaced items
- **Dependencies** — COMBAT-002, CHAR, UI
- **Edge cases and interactions** — Hand cleanup and splitting can occur before the final occupied-slot check. Verify refusal paths.
- **Design questions** — Should failed equips leave every prior item and stack untouched?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-010 specification](../../design/systems/ITEM/ITEM-010.md) and ITEM-010-A01.

### My Intended Specification

[Approved ITEM-010 specification](../../design/systems/ITEM/ITEM-010.md).

## ITEM-011 — Equip restrictions and inventory presentation

- **Parent subsystem** — Equipment
- **Purpose** — Apply inventory-side eligibility and represent equipped items.
- **Existing implementation** — Inventory has distinct equip and unequip operations, paper doll slot lookup and accessory display. Inventory equip is a separate path from slot assignment.
- **Source** — `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#EquipItem`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UnequipItem`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#PaperDoll_GetItem`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UpdateAccessoryItemsDisplay`
- **Inputs and outputs** — Item and character state → inventory equip result and refreshed display
- **Dependencies** — CHAR, UI, MAGIC, ITEM-010
- **Edge cases and interactions** — Trace career restrictions, equip delays and bypasses from non-UI callers.
- **Design questions** — Which restrictions belong to every equip entry point?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-011 specification](../../design/systems/ITEM/ITEM-011.md) and ITEM-011-A01.

### My Intended Specification

[Approved ITEM-011 specification](../../design/systems/ITEM/ITEM-011.md).

## ITEM-012 — Armor and enchantment lifecycle

- **Parent subsystem** — Equipment
- **Purpose** — Update character effects when equipment changes.
- **Existing implementation** — Equipment exposes start/stop hooks and starts enchantments after assignment. Entity armor values have an explicit update method. Item break cleanup can remove the item from its slot and update armor values.
- **Source** — `Game/Items/ItemEquipTable.cs#StartEquippedItem`, `Game/Items/ItemEquipTable.cs#StopEquippedItem`, `Game/Entities/DaggerfallEntity.cs#UpdateEquippedArmorValues`, `Game/Items/DaggerfallUnityItem.cs#UnequipItem`
- **Inputs and outputs** — Equip or removal event → armor and enchantment state
- **Dependencies** — COMBAT, CHAR, MAGIC-016
- **Edge cases and interactions** — Check duplicate effect starts, forced unequip and load restoration order.
- **Design questions** — When should equipped effects become active or end?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-012 specification](../../design/systems/ITEM/ITEM-012.md) and ITEM-012-A01.

### My Intended Specification

[Approved ITEM-012 specification](../../design/systems/ITEM/ITEM-012.md).

## ITEM-013 — Condition loss and breakage

- **Parent subsystem** — Equipment
- **Purpose** — Resolve wear and broken item state.
- **Existing implementation** — LowerCondition subtracts wear, floors at zero and calls break handling. Break handling can unequip, show a message and invoke a break payload. Optional collection removal is gated by AllowMagicRepairs.
- **Source** — `Game/Items/DaggerfallUnityItem.cs#LowerCondition`, `Game/Items/DaggerfallUnityItem.cs#ItemBreaks`, `Game/Formulas/FormulaHelper.cs#DamageEquipment`
- **Inputs and outputs** — Wear, owner, collection and setting → condition, feedback or removal
- **Dependencies** — COMBAT-011, RULE-016, MAGIC-016, ECON
- **Edge cases and interactions** — Owner and removal collection are optional. Verify repeated wear at zero and nonphysical wear sources.
- **Design questions** — Which items should survive breakage and remain repairable?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-013 specification](../../design/systems/ITEM/ITEM-013.md) and ITEM-013-A01.

### My Intended Specification

[Approved ITEM-013 specification](../../design/systems/ITEM/ITEM-013.md).

## ITEM-014 — Repair jobs

- **Parent subsystem** — Equipment
- **Purpose** — Track an item left with a repair service.
- **Existing implementation** — ItemRepairData exposes start, finished checks, collection, estimates and save/restore. Repair price and duration are separate RULE inputs.
- **Source** — `Game/Items/ItemRepairData.cs#LeaveForRepair`, `Game/Items/ItemRepairData.cs#Collect`, `Game/Items/ItemRepairData.cs#IsRepairFinished`, `Game/Items/ItemRepairData.cs#GetSaveData`, `Game/UserInterfaceWindows/DaggerfallMerchantRepairPopupWindow.cs`
- **Inputs and outputs** — Item, repair location and time → pending or collectible job
- **Dependencies** — ECON, TIME, SAVE, RULE-023
- **Edge cases and interactions** — Verify pickup elsewhere, time advancement and disappearing service locations.
- **Design questions** — How should an overdue or inaccessible repair be recovered?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-014 specification](../../design/systems/ITEM/ITEM-014.md) and ITEM-014-A01.

### My Intended Specification

[Approved ITEM-014 specification](../../design/systems/ITEM/ITEM-014.md).

## ITEM-015 — Item action routing and extension order

- **Parent subsystem** — Use
- **Purpose** — Dispatch use to the appropriate behavior.
- **Existing implementation** — Inventory calls item virtual use first, handles quest use next, tries a registered template handler, then runs built-in branches. Enchanted use closes inventory before dispatching the payload.
- **Source** — `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem`, `Game/Items/DaggerfallUnityItem.cs#UseItem`, `Game/Items/ItemHelper.cs#GetItemUseHandler`
- **Inputs and outputs** — Item, collection and handlers → consumed action, UI or effect
- **Dependencies** — UI, QUEST, MOD, MAGIC-016
- **Edge cases and interactions** — A handled virtual or custom use can return early. Closing inventory before artifact UI is a deliberate DFU departure.
- **Design questions** — Which handlers may consume use or run in combination?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-015 specification](../../design/systems/ITEM/ITEM-015.md) and ITEM-015-A01.

### My Intended Specification

[Approved ITEM-015 specification](../../design/systems/ITEM/ITEM-015.md).

## ITEM-016 — Books, maps and spellbooks

- **Parent subsystem** — Use
- **Purpose** — Open readable content or discover locations.
- **Existing implementation** — Regular books attempt the reader and can show unavailable feedback. Map use records a location then removes the item. Spellbook use opens the spell list or shows no-spells feedback.
- **Source** — `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#RecordLocationFromMap`, `Game/LocalizedBook.cs#OpenBookFile`
- **Inputs and outputs** — Item type and context → reader, discovery or spellbook
- **Dependencies** — DATA-018, WORLD, MAGIC-011, UI
- **Edge cases and interactions** — Artifact books bypass the regular book branch. Verify invalid map targets and unavailable book content.
- **Design questions** — Which knowledge items should be consumed?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-016 specification](../../design/systems/ITEM/ITEM-016.md) and ITEM-016-A01.

### My Intended Specification

[Approved ITEM-016 specification](../../design/systems/ITEM/ITEM-016.md).

## ITEM-017 — Potions, drugs and recipe items

- **Parent subsystem** — Use
- **Purpose** — Apply or decline consumable use.
- **Existing implementation** — Inventory hands potions to the effect manager then removes one. Drugs use a poison mapping and are removed. Potion recipes take a cannot-use branch in inventory.
- **Source** — `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem`, `Game/MagicAndEffects/EntityEffectManager.cs#DrinkPotion`, `Game/Formulas/FormulaHelper.cs#InflictPoison`
- **Inputs and outputs** — Item and collection → effect, consumption or feedback
- **Dependencies** — MAGIC-013, MAGIC-014, MAGIC-020, CHAR
- **Edge cases and interactions** — Test missing recipe or rejected effect and whether consumption still occurs.
- **Design questions** — Should failed application consume the item?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-017 specification](../../design/systems/ITEM/ITEM-017.md) and ITEM-017-A01.

### My Intended Specification

[Approved ITEM-017 specification](../../design/systems/ITEM/ITEM-017.md).

## ITEM-018 — Light source and lantern fuel

- **Parent subsystem** — Use
- **Purpose** — Equip or refuel a portable light.
- **Existing implementation** — Inventory toggles the active light source if its condition is positive. Oil refuels a nonquest lantern if the whole oil condition amount fits, consuming one unit.
- **Source** — `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem`, `Game/EnablePlayerTorch.cs`, `Game/Entities/PlayerEntity.cs`
- **Inputs and outputs** — Light item, current condition and fuel → active source or refueled lantern
- **Dependencies** — AV, TIME, CHAR, SAVE
- **Edge cases and interactions** — Check fuel depletion and what happens when the active source leaves inventory. Refuel declines if the full amount cannot fit.
- **Design questions** — Should partial refueling be possible?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-018 specification](../../design/systems/ITEM/ITEM-018.md) and ITEM-018-A01.

### My Intended Specification

[Approved ITEM-018 specification](../../design/systems/ITEM/ITEM-018.md).

## ITEM-019 — Identification and item display

- **Parent subsystem** — Use
- **Purpose** — Reveal item identity and describe current state.
- **Existing implementation** — Items expose an identification operation. ItemHelper resolves names and inventory imagery, and inventory renders item information and hover state.
- **Source** — `Game/Items/DaggerfallUnityItem.cs#IdentifyItem`, `Game/Items/ItemHelper.cs#ResolveItemLongName`, `Game/Items/ItemHelper.cs#GetInventoryImage`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#ShowInfoPopup`
- **Inputs and outputs** — Item metadata, identity and display context → name, image and info
- **Dependencies** — DATA, UI, MAGIC, ECON
- **Edge cases and interactions** — Verify unidentified name/value visibility, dye/variant assets and artifact disclosure.
- **Design questions** — What should be visible before identification?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-019 specification](../../design/systems/ITEM/ITEM-019.md) and ITEM-019-A01.

### My Intended Specification

[Approved ITEM-019 specification](../../design/systems/ITEM/ITEM-019.md).

## ITEM-020 — Loot tables and random additions

- **Parent subsystem** — World items
- **Purpose** — Populate loot collections.
- **Existing implementation** — LootTables resolves a chance matrix and generates loot using player context. DaggerfallLoot has helpers for generation and random map, potion and recipe additions.
- **Source** — `Game/Items/LootTables.cs#GetMatrix`, `Game/Items/LootTables.cs#GenerateRandomLoot`, `Internal/DaggerfallLoot.cs#GenerateItems`, `Internal/DaggerfallLoot.cs#RandomlyAddMap`
- **Inputs and outputs** — Table key, player and RNG → generated item collection
- **Dependencies** — RULE, LOC, NPC, DATA
- **Edge cases and interactions** — Compare table distributions and quest loot additions with fixtures.
- **Design questions** — Which loot rolls should depend on player or location level?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-020 specification](../../design/systems/ITEM/ITEM-020.md) and ITEM-020-A01.

### My Intended Specification

[Approved ITEM-020 specification](../../design/systems/ITEM/ITEM-020.md).

## ITEM-021 — Shop shelves and household stock

- **Parent subsystem** — World items
- **Purpose** — Populate context-specific containers.
- **Existing implementation** — DaggerfallLoot has separate shop shelf and house container stock methods and a stocked date calculation. Stock generation uses discovered building data.
- **Source** — `Internal/DaggerfallLoot.cs#CreateStockedDate`, `Internal/DaggerfallLoot.cs#StockShopShelf`, `Internal/DaggerfallLoot.cs#StockHouseContainer`
- **Inputs and outputs** — Building and date context → container contents
- **Dependencies** — ECON, TIME, LOC, RULE
- **Edge cases and interactions** — Trace restock schedule and what survives revisits, theft or save/load.
- **Design questions** — Which stock should be persistent and what should refresh?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved — finalized v1 on 2026-11-10; see [ITEM-021 specification](../../design/systems/ITEM/ITEM-021.md) and ITEM-021-A01.

### My Intended Specification

[Approved ITEM-021 specification](../../design/systems/ITEM/ITEM-021.md).

## ITEM-022 — Container, corpse and dropped item access

- **Parent subsystem** — World items
- **Purpose** — Expose items across world and inventory.
- **Existing implementation** — PlayerActivate opens loot containers. Inventory manages remote items, transfers and drop presentation. EnemyDeath transfers items into a corpse. Private property has a theft path.
- **Source** — `Game/PlayerActivate.cs#ActivateLootContainer`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#DoTransferItem`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#AttemptPrivatePropertyTheft`, `Game/EnemyDeath.cs#CompleteDeath`
- **Inputs and outputs** — Container, property state and transfer request → inventory change or legal handoff
- **Dependencies** — MOVE-022, COMBAT-021, LAW, LOC, UI
- **Edge cases and interactions** — Check empty corpse cleanup, quest loot and closing inventory after a partial transfer.
- **Design questions** — When should a container disappear or trigger theft?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved and finalized v1 on 2026-11-10 under ITEM-022-A01.

### My Intended Specification

[Approved ITEM-022 specification](../../design/systems/ITEM/ITEM-022.md)

## ITEM-023 — Quest items and orphan cleanup

- **Parent subsystem** — Lifecycle
- **Purpose** — Tie an owned item to its quest resource.
- **Existing implementation** — Items can link a quest UID and symbol and clear that linkage when made permanent. Collections expose quest export and orphan cleanup. Inventory use can signal a watched quest resource or show a quest message.
- **Source** — `Game/Items/DaggerfallUnityItem.cs#LinkQuestItem`, `Game/Items/DaggerfallUnityItem.cs#MakePermanent`, `Game/Items/ItemCollection.cs#ExportQuestItems`, `Game/Items/ItemCollection.cs#RemoveOrphanedItems`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem`
- **Inputs and outputs** — Quest UID, symbol and item action → resource event or lifecycle change
- **Dependencies** — QUEST, SAVE, UI
- **Edge cases and interactions** — Use throws if its owning quest is missing. Test stash, transfer and end-of-quest cleanup.
- **Design questions** — Which items should persist after the quest ends?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved and finalized v1 on 2026-11-10 under ITEM-023-A01.

### My Intended Specification

[Approved ITEM-023 specification](../../design/systems/ITEM/ITEM-023.md)

## ITEM-024 — Summoned items and expiry

- **Parent subsystem** — Lifecycle
- **Purpose** — Remove temporary items after their lifetime.
- **Existing implementation** — Collections expose removal of expired items and allow priority lookup for conjured items. PlayerEntity invokes expiration removal in its changed-minute update. Bow use distinguishes summoned ammo.
- **Source** — `Game/Items/ItemCollection.cs#RemoveExpiredItems`, `Game/Items/ItemCollection.cs#GetItem`, `Game/Entities/PlayerEntity.cs#Update`, `Game/WeaponManager.cs#Update`
- **Inputs and outputs** — Item expiry time and game clock → removal or prioritized use
- **Dependencies** — MAGIC, TIME, COMBAT-008, SAVE
- **Edge cases and interactions** — Verify wagon/remote expiration, equipped items and elapsed-time jumps.
- **Design questions** — Should expired items disappear from every owner simultaneously?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved and finalized v1 on 2026-11-10 under ITEM-024-A01.

### My Intended Specification

[Approved ITEM-024 specification](../../design/systems/ITEM/ITEM-024.md)

## ITEM-025 — Inventory and equipment persistence

- **Parent subsystem** — Lifecycle
- **Purpose** — Reconstruct item records and slot references.
- **Existing implementation** — ItemCollection writes ItemData_v1 records and reloads without merging. ItemEquipTable serializes slot UIDs and restores references against a collection. Player and loot have separate serialization consumers.
- **Source** — `Game/Items/ItemCollection.cs#SerializeItems`, `Game/Items/ItemCollection.cs#DeserializeItems`, `Game/Items/ItemEquipTable.cs#SerializeEquipTable`, `Game/Items/ItemEquipTable.cs#DeserializeEquipTable`, `Game/Serialization/SerializablePlayer.cs`, `Game/Serialization/SerializableLootContainer.cs`
- **Inputs and outputs** — Item records and slot UIDs → inventory and equipped references
- **Dependencies** — SAVE, MOD, MAGIC
- **Edge cases and interactions** — Test missing IDs, stale enchantments and classic import with separate fixtures.
- **Design questions** — Which item states should be repaired during load?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved and finalized v1 on 2026-11-10 under ITEM-025-A01.

### My Intended Specification

[Approved ITEM-025 specification](../../design/systems/ITEM/ITEM-025.md)

## Classic provenance and review sequence

- Packaged item templates, classic item/save records and original imagery are separate evidence sources. Review their actual values before attributing pricing, material, variants or loot distributions to original Daggerfall. Source explicitly identifies closing inventory for enchanted use and some break-message wording as DFU differences.
- Start with ITEM-001 and ITEM-005 through ITEM-012. Trace stack identity across split, transfer, equip and restore, including failed equip. Then review condition and break payloads, a potion and a light source, followed by shop, corpse and quest containers.
- Scope separates construction, collection mechanics, equipment, use and persistence. MAGIC owns crafting and effect semantics. RULE owns formulas. ECON owns service eligibility and transactions. Full template and loot table provenance, classic save fixtures, Unity visuals and runtime behavior remain unverified.
