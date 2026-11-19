# UI feature catalog

Static decomposition of the local Daggerfall Unity 1.1.1 snapshot. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Source paths are relative to `Assets/Scripts/`. A symbol follows `#`. Confidence rates the sampled source trace.

## UI-001 — Window stack and modal lifecycle

- **Parent subsystem** — Runtime
- **Purpose** — Layer screens and restore the previous view.
- **Existing implementation** — Push calls OnPush, clears gameplay actions and an active fade, then signals window change. Pop runs OnPop and OnReturn. A HUD on top is protected from ordinary removal.
- **Source** — `Game/UserInterface/UserInterfaceManager.cs#PushWindow`, `Game/UserInterface/UserInterfaceManager.cs#RemoveWindow`, `Game/UserInterface/UserInterfaceManager.cs#ChangeWindow`
- **Inputs and outputs** — Window request → stack and lifecycle callbacks
- **Dependencies** — CORE-015, CORE-016, MOVE
- **Edge cases and interactions** — Resume depends on stack count and HUD setting. Test nested prompts and stack replacement.
- **Design questions** — Which windows should pause or clear input?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-001 — Window stack and modal lifecycle](../../design/systems/UI/UI-001.md)

## UI-002 — Message routing and shortcut dispatch

- **Parent subsystem** — Runtime
- **Purpose** — Route commands to the active screen or global UI.
- **Existing implementation** — Top window gets first chance to process queued messages, then global dispatch dequeues one. The queue holds ten entries and overflow clears pending messages before retaining the newest.
- **Source** — `Game/DaggerfallUI.cs#Update`, `Game/DaggerfallUI.cs#ProcessMessages`, `Game/UserInterface/UserInterfaceManager.cs#PostMessage`, `Game/DaggerfallUIMessages.cs`
- **Inputs and outputs** — UI message or gameplay shortcut → handler or screen
- **Dependencies** — CORE-018, MOVE
- **Edge cases and interactions** — Test bursts and messages posted by callbacks.
- **Design questions** — Which commands should survive queue overflow?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-002 — Message routing and shortcut dispatch](../../design/systems/UI/UI-002.md)

## UI-003 — Window creation and replacement

- **Parent subsystem** — Runtime
- **Purpose** — Resolve screen types and reusable instances.
- **Existing implementation** — UIWindowFactory registers custom window types and instantiates windows by type and arguments. DaggerfallUI has separate persistent-window initialization and recreation paths.
- **Source** — `Game/UserInterfaceWindows/UIWindowFactory.cs#RegisterCustomUIWindow`, `Game/UserInterfaceWindows/UIWindowFactory.cs#GetInstanceWithArgs`, `Game/DaggerfallUI.cs#InstantiatePersistentWindowInstances`
- **Inputs and outputs** — Window type and constructor inputs → instance
- **Dependencies** — MOD, CORE
- **Edge cases and interactions** — Check which direct constructors bypass the factory and which state survives recreation.
- **Design questions** — Which screens should retain state between visits?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-003 — Window creation and replacement](../../design/systems/UI/UI-003.md)

## UI-004 — Frame rendering and input ownership

- **Parent subsystem** — Runtime
- **Purpose** — Update and draw the active screen.
- **Existing implementation** — DaggerfallUI updates the top window with custom mouse position and clears frame key state. OnGUI draws the top window. Window components provide panels, buttons, labels and input controls.
- **Source** — `Game/DaggerfallUI.cs#Update`, `Game/DaggerfallUI.cs#OnGUI`, `Game/UserInterface/Panel.cs`, `Game/UserInterface/BaseScreenComponent.cs`
- **Inputs and outputs** — Frame, pointer and input state → screen drawing and input handling
- **Dependencies** — MOVE, AV
- **Edge cases and interactions** — Verify scaling, focus and controller cursor with Unity assets and device fixtures.
- **Design questions** — How should scaling and focus work across input devices?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-004 — Frame rendering and input ownership](../../design/systems/UI/UI-004.md)

## UI-005 — Modal messages and text entry

- **Parent subsystem** — Runtime
- **Purpose** — Present formatted choices and collect user input.
- **Existing implementation** — MessageBox supports text and classic tokens. InputMessageBox exposes token prompts and a return-input callback with push/pop lifecycle handling.
- **Source** — `Game/DaggerfallUI.cs#MessageBox`, `Game/UserInterfaceWindows/DaggerfallMessageBox.cs`, `Game/UserInterfaceWindows/DaggerfallInputMessageBox.cs#SetTextTokens`, `Game/UserInterfaceWindows/DaggerfallInputMessageBox.cs#ReturnPlayerInputEvent`
- **Inputs and outputs** — Message, choices and typed input → dismissal, choice or text
- **Dependencies** — DATA-015, DATA-016, MOVE
- **Edge cases and interactions** — Verify cancel policy, IME restoration and callbacks opening another window.
- **Design questions** — Which prompts should allow cancel and default selection?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-005 — Modal messages and text entry](../../design/systems/UI/UI-005.md)

## UI-006 — Vitals and effects display

- **Parent subsystem** — HUD
- **Purpose** — Expose immediate character state.
- **Existing implementation** — HUD update drives the active gameplay display. Dedicated components exist for vitals, breath, active spells and large HUD mode.
- **Source** — `Game/UserInterfaceWindows/DaggerfallHUD.cs#Update`, `Game/UserInterface/HUDVitals.cs`, `Game/UserInterface/HUDBreathBar.cs`, `Game/UserInterface/HUDActiveSpells.cs`
- **Inputs and outputs** — Character pools and effects → HUD indicators
- **Dependencies** — CHAR-018, MAGIC-010, MOVE-014
- **Edge cases and interactions** — Check display while paused, underwater or after effect restore.
- **Design questions** — Which information should remain visible in compact mode?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-006 — Vitals and effects display](../../design/systems/UI/UI-006.md)

## UI-007 — Navigation, interaction and temporary notices

- **Parent subsystem** — HUD
- **Purpose** — Show orientation and feedback during play.
- **Existing implementation** — HUD includes compass, crosshair and interaction mode components. DaggerfallUI exposes timed HUD text and mid-screen notifications. Validated data is required for the initial HUD push.
- **Source** — `Game/DaggerfallUI.cs#Update`, `Game/DaggerfallUI.cs#AddHUDText`, `Game/UserInterfaceWindows/DaggerfallHUD.cs#SetMidScreenText`, `Game/UserInterface/HUDCompass.cs`, `Game/UserInterface/HUDInteractionModeIcon.cs`
- **Inputs and outputs** — Orientation, mode and messages → transient or persistent indicators
- **Dependencies** — MOVE-019, WORLD, AV
- **Edge cases and interactions** — Verify message overlap with large HUD and fades.
- **Design questions** — Which notices should queue, replace or persist?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-007 — Navigation, interaction and temporary notices](../../design/systems/UI/UI-007.md)

## UI-008 — Setup, title and cinematic transitions

- **Parent subsystem** — Session
- **Purpose** — Enter the title flow and recover after death.
- **Existing implementation** — Global messages open setup, initialize the title path or initialize death return using a separate video. CORE owns scene choice and startup modes.
- **Source** — `Game/DaggerfallUI.cs#ProcessMessages`, `Game/UserInterfaceWindows/DaggerfallUnitySetupGameWizard.cs`, `Game/UserInterfaceWindows/DaggerfallStartWindow.cs`, `Game/UserInterfaceWindows/DaggerfallVidPlayerWindow.cs`
- **Inputs and outputs** — Startup/death message and media settings → title or setup flow
- **Dependencies** — CORE-004, CORE-008, AV
- **Edge cases and interactions** — Check missing or disabled videos and retained input on title return.
- **Design questions** — When should videos be skippable?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-008 — Setup, title and cinematic transitions](../../design/systems/UI/UI-008.md)

## UI-009 — Pause options and configuration

- **Parent subsystem** — Session
- **Purpose** — Expose in-session settings and control profiles.
- **Existing implementation** — Global dispatch opens pause and controls windows. Dedicated mouse, controller, advanced and game effects configuration windows separate settings surfaces.
- **Source** — `Game/DaggerfallUI.cs#ProcessMessages`, `Game/UserInterfaceWindows/DaggerfallPauseOptionsWindow.cs`, `Game/UserInterfaceWindows/DaggerfallControlsWindow.cs`, `Game/UserInterfaceWindows/DaggerfallAdvancedSettingsWindow.cs`, `Game/UserInterfaceWindows/GameEffectsConfigWindow.cs`
- **Inputs and outputs** — Player action and profile → settings interaction
- **Dependencies** — CORE-003, CORE-006, MOVE-002, AV
- **Edge cases and interactions** — Verify immediate application, persistence and cancel behavior per screen.
- **Design questions** — Which settings require preview or confirmation?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-009 — Pause options and configuration](../../design/systems/UI/UI-009.md)

## UI-010 — Save selection and legacy load entry

- **Parent subsystem** — Session
- **Purpose** — Choose a save or create a new slot.
- **Existing implementation** — Native save UI has distinct modes, refreshes the list and selected-save info and calls save/load handlers. Classic loading uses a separate window.
- **Source** — `Game/UserInterfaceWindows/DaggerfallUnitySaveGameWindow.cs#UpdateSavesList`, `Game/UserInterfaceWindows/DaggerfallUnitySaveGameWindow.cs#UpdateSelectedSaveInfo`, `Game/UserInterfaceWindows/DaggerfallUnitySaveGameWindow.cs#SaveLoadEventHandler`, `Game/UserInterfaceWindows/DaggerfallLoadClassicGameWindow.cs`
- **Inputs and outputs** — Mode, slot and confirmation → save or load request
- **Dependencies** — SAVE, CORE-013, CORE-014
- **Edge cases and interactions** — Verify refresh after errors, inaccessible slots and focus after cancellation.
- **Design questions** — How should failures and incompatible slots appear?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-010 — Save selection and legacy load entry](../../design/systems/UI/UI-010.md)

## UI-011 — Character creation navigation

- **Parent subsystem** — Character
- **Purpose** — Collect choices before session startup.
- **Existing implementation** — The wizard uses ordered windows and close handlers, backs up on cancellation and passes the accepted document into the start flow. CHAR owns choices and allocation rules.
- **Source** — `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#StartNewGame`, `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs#SummaryWindow_OnClose`, `Game/UserInterfaceWindows/CreateCharSummary.cs`
- **Inputs and outputs** — Window choices and confirmation → character document and startup handoff
- **Dependencies** — CHAR-001, CORE-011
- **Edge cases and interactions** — Check retained choices on backtracking and restart.
- **Design questions** — Which steps can be revisited from summary?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-011 — Character creation navigation](../../design/systems/UI/UI-011.md)

## UI-012 — Character sheet and progression prompts

- **Parent subsystem** — Character
- **Purpose** — Show current character state and allocate rewards.
- **Existing implementation** — Character sheet refreshes live stat labels and launches allocation when ReadyToLevelUp is set. It gates closing until allocation completes or stats are maxed. A separate history window displays character history.
- **Source** — `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#UpdatePlayerValues`, `Game/UserInterfaceWindows/DaggerfallCharacterSheetWindow.cs#CheckIfDoneLeveling`, `Game/UserInterfaceWindows/DaggerfallPlayerHistoryWindow.cs`
- **Inputs and outputs** — Character state and pending reward → displayed stats and allocation
- **Dependencies** — CHAR-011, CHAR-015
- **Edge cases and interactions** — Opening the screen can change level and health. Verify modal interruptions.
- **Design questions** — Should the sheet itself commit progression?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-012 — Character sheet and progression prompts](../../design/systems/UI/UI-012.md)

## UI-013 — Inventory panes and contextual actions

- **Parent subsystem** — Character
- **Purpose** — Let players inspect and act on owned or remote items.
- **Existing implementation** — Inventory filters local and remote panes, switches tab and action mode, and routes item/paper-doll clicks to equip, use or transfer operations.
- **Source** — `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#SelectTabPage`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#SelectActionMode`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#PaperDoll_OnMouseClick`, `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#TransferItem`
- **Inputs and outputs** — Selected pane, mode and item → action or refresh
- **Dependencies** — ITEM-008, ITEM-011, ITEM-015
- **Edge cases and interactions** — Check right-click modes, remote ownership, quantity prompts and selection after refresh.
- **Design questions** — Which actions need direct shortcuts?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-013 — Inventory panes and contextual actions](../../design/systems/UI/UI-013.md)

## UI-014 — Reading and spell selection

- **Parent subsystem** — Character
- **Purpose** — Present item-backed information and casting options.
- **Existing implementation** — Inventory dispatches books to the reader and spellbook requests to global UI. Dedicated spellbook and use-magic-item windows provide selection surfaces.
- **Source** — `Game/UserInterfaceWindows/DaggerfallInventoryWindow.cs#UseItem`, `Game/UserInterfaceWindows/DaggerfallBookReaderWindow.cs`, `Game/UserInterfaceWindows/DaggerfallSpellBookWindow.cs`, `Game/UserInterfaceWindows/DaggerfallUseMagicItemWindow.cs`
- **Inputs and outputs** — Readable item or spell selection → reader, ready spell or use request
- **Dependencies** — DATA-018, MAGIC-003, MAGIC-011, ITEM-016
- **Edge cases and interactions** — Test missing book content, empty list and blocked spell readiness.
- **Design questions** — How should failed selection return focus?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-014 — Reading and spell selection](../../design/systems/UI/UI-014.md)

## UI-015 — Talk topics and service menus

- **Parent subsystem** — Conversation
- **Purpose** — Navigate NPC questions and available services.
- **Existing implementation** — Talk window is the conversation surface for TalkManager topics and tones. Merchant and guild popups route service interactions separately.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTalkWindow.cs`, `Game/TalkManager.cs#StartNewConversation`, `Game/UserInterfaceWindows/DaggerfallGuildServicePopupWindow.cs#DoGuildService`, `Game/UserInterfaceWindows/DaggerfallMerchantServicePopupWindow.cs`
- **Inputs and outputs** — NPC context, topic or service choice → response or service screen
- **Dependencies** — NPC-017, NPC-019, FACT-014, ECON-001
- **Edge cases and interactions** — Verify return focus and quest interruption of ordinary dialogue.
- **Design questions** — Should dialogue and service options appear together?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-015 — Talk topics and service menus](../../design/systems/UI/UI-015.md)

## UI-016 — Quest offers, journal and notebook

- **Parent subsystem** — Conversation
- **Purpose** — Present quest decisions and retained records.
- **Existing implementation** — Quest offer and popup windows present authored prompts. Journal has active, finished, notebook and message views, with handlers for note entry and location lookup.
- **Source** — `Game/UserInterfaceWindows/DaggerfallQuestOfferWindow.cs`, `Game/UserInterfaceWindows/DaggerfallQuestPopupWindow.cs`, `Game/UserInterfaceWindows/DaggerfallQuestJournalWindow.cs#SetTextActiveQuests`, `Game/UserInterfaceWindows/DaggerfallQuestJournalWindow.cs#SetTextNotebook`, `Game/UserInterfaceWindows/DaggerfallQuestJournalWindow.cs#FindPlace_OnButtonClick`
- **Inputs and outputs** — Quest state, messages and notes → player choices and journal entries
- **Dependencies** — QUEST-018, NPC-022, WORLD
- **Edge cases and interactions** — Verify old entries, missing destinations and input focus after prompts.
- **Design questions** — Which quest records should be editable or searchable?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-016 — Quest offers, journal and notebook](../../design/systems/UI/UI-016.md)

## UI-017 — Merchant, banking and property screens

- **Parent subsystem** — Transactions
- **Purpose** — Quote and confirm economic actions.
- **Existing implementation** — Trade window shows cost and gold and confirms mode actions. Banking and purchase popups provide separate account and deed flows.
- **Source** — `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#UpdateCostAndGold`, `Game/UserInterfaceWindows/DaggerfallTradeWindow.cs#ConfirmTrade_OnButtonClick`, `Game/UserInterfaceWindows/DaggerfallBankingWindow.cs`, `Game/UserInterfaceWindows/DaggerfallBankPurchasePopUp.cs`
- **Inputs and outputs** — Selected items or transaction and amount → confirmation and result
- **Dependencies** — ECON-003, ECON-009, ECON-013
- **Edge cases and interactions** — Verify cancellation, quote refresh and result messages on failed operations.
- **Design questions** — Which transactions should share a confirmation pattern?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-017 — Merchant, banking and property screens](../../design/systems/UI/UI-017.md)

## UI-018 — Magic crafting screens

- **Parent subsystem** — Transactions
- **Purpose** — Guide composition and preview before committing.
- **Existing implementation** — Dedicated spellmaker, potion maker and item maker windows expose separate design and crafting flows. Potion mixing and item enchant confirmation have their own handlers.
- **Source** — `Game/UserInterfaceWindows/DaggerfallSpellMakerWindow.cs`, `Game/UserInterfaceWindows/DaggerfallPotionMakerWindow.cs#MixCauldron`, `Game/UserInterfaceWindows/DaggerfallItemMakerWindow.cs#EnchantButton_OnMouseClick`, `Game/UserInterfaceWindows/DaggerfallEffectSettingsEditorWindow.cs`
- **Inputs and outputs** — Effects, ingredients or enchantments → preview and crafting action
- **Dependencies** — MAGIC-012, MAGIC-013, MAGIC-015
- **Edge cases and interactions** — Check rejected combinations and what editing state survives closing subwindows.
- **Design questions** — Which costs and restrictions should update during editing?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-018 — Magic crafting screens](../../design/systems/UI/UI-018.md)

## UI-019 — Exterior, dungeon and travel maps

- **Parent subsystem** — Navigation
- **Purpose** — Provide different views for exploration and destination choice.
- **Existing implementation** — Separate automap and exterior map windows expose local geometry. TravelMap handles destination search and selection before opening trip confirmation.
- **Source** — `Game/UserInterfaceWindows/DaggerfallAutomapWindow.cs`, `Game/UserInterfaceWindows/DaggerfallExteriorAutomapWindow.cs`, `Game/UserInterfaceWindows/DaggerfallTravelMapWindow.cs#HandleLocationPickEvent`, `Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs`
- **Inputs and outputs** — World context and map input → exploration view or trip setup
- **Dependencies** — WORLD-016, LOC-018, TIME-012
- **Edge cases and interactions** — Verify input, visibility and map return state across transitions.
- **Design questions** — Which controls should be consistent across maps?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-019 — Exterior, dungeon and travel maps](../../design/systems/UI/UI-019.md)

## UI-020 — Rest, travel and transport dialogs

- **Parent subsystem** — Navigation
- **Purpose** — Present time and movement choices.
- **Existing implementation** — Dedicated rest and travel popups expose modes and confirmation. Transport window provides a separate local mode selector. TIME owns elapsed time and journey rules.
- **Source** — `Game/UserInterfaceWindows/DaggerfallRestWindow.cs#Update`, `Game/UserInterfaceWindows/DaggerfallTravelPopUp.cs#BeginButtonOnClickHandler`, `Game/UserInterfaceWindows/DaggerfallTransportWindow.cs`
- **Inputs and outputs** — Mode, time or destination selection → action request and feedback
- **Dependencies** — TIME-010, TIME-014, MOVE-016
- **Edge cases and interactions** — Verify interruptibility and return path after denied actions.
- **Design questions** — Which choices should be available during danger?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Behavioral baseline approved and finalized as v1 on 2026-11-16. Travel presentation remains provisional pending playtesting and revision.

### My Intended Specification

[UI-020 — Rest, travel and transport dialogs](../../design/systems/UI/UI-020.md)

## UI-021 — Court and incarceration presentation

- **Parent subsystem** — Consequences
- **Purpose** — Lead the player through pleas and release.
- **Existing implementation** — Court runs a state-based UI, shows plea and defense prompts and drives a prison countdown. LAW owns sentencing and consequences.
- **Source** — `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#HandleCourtLogic`, `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#DebateLie_OnButtonClick`, `Game/UserInterfaceWindows/DaggerfallCourtWindow.cs#UpdatePrisonScreen`
- **Inputs and outputs** — Charge, verdict and response → court panels and release handoff
- **Dependencies** — LAW-011, LAW-013, LAW-015
- **Edge cases and interactions** — Verify input lockout and dismissal on all verdict paths.
- **Design questions** — Which court outcomes need explicit player confirmation?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-16.

### My Intended Specification

[UI-021 — Court and incarceration presentation](../../design/systems/UI/UI-021.md)

## Classic provenance and review sequence

- Classic formatted text records and graphics supply portions of the interface. DATA documents token fallback and localization. The window stack, global message queue, Unity drawing and factory are observable DFU code. Compare actual classic screens and assets to establish layout and interaction parity.
- Start with nested modal windows, checking input clearing, pause ownership, callback order and queue overflow. Then follow inventory, dialogue, save/load and travel from entry through cancellation and success. Check scaling, controller navigation, localized text and missing media with runtime fixtures.
- Scope separates shared UI behavior and player-facing handoffs from domain rules. Individual screen layouts, full shortcut and modal combinations, mod replacements and original-game parity remain open.
