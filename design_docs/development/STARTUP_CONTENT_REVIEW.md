# Fresh-character startup review

Source inspection on 2026-11-18. Reference paths below are relative to the read-only DFU tree. The user approved the grant table, conditional lights, opening queue, exterior adaptation and M3 economy ownership on 2026-11-18.

## Baseline grants

Every character receives a spellbook, equipped gender/race-appropriate shirt and pants, randomized shirt dye and pants variant, and 100 gold, in addition to applicable biography outcomes. Five torches and two candles are conditional on DFU's PlayerTorchFromItems setting.

| Career | Equipment | Starting spells |
| --- | --- | --- |
| Mage | Steel shortsword | Fenrik's Door Jam (classic ID 1), Slowfalling (classic ID 37), Buoyancy (classic ID 2), Balyna's Balm (classic ID 97), Shock (classic ID 8) |
| Spellsword | Iron saber | Shock (classic ID 8), Chameleon (classic ID 44), Slowfalling (classic ID 37) |
| Battlemage | Iron saber | Shock (classic ID 8), Buoyancy (classic ID 2), Slowfalling (classic ID 37) |
| Sorcerer | Steel shortsword | Fenrik's Door Jam (classic ID 1), Slowfalling (classic ID 37), Buoyancy (classic ID 2), Balyna's Balm (classic ID 97), Shock (classic ID 8) |
| Healer | Iron mace | Balyna's Balm (classic ID 97), Buoyancy (classic ID 2), Fenrik's Door Jam (classic ID 1), Slowfalling (classic ID 37) |
| Nightblade | Iron shortsword | Chameleon (classic ID 44), Buoyancy (classic ID 2) |
| Bard | Iron shortsword | Slowfalling (classic ID 37) |
| Burglar | Steel tanto | None |
| Rogue | Iron saber | None |
| Acrobat | Iron shortsword | None |
| Thief | Iron shortsword | None |
| Assassin | Iron longsword | None |
| Monk | Steel staff | None |
| Archer | Iron long bow; steel battle axe; 24 iron arrows | None |
| Ranger | Steel battle axe | None |
| Barbarian | Iron warhammer | None |
| Warrior | Iron broadsword | None |
| Knight | Iron longsword | None |
| Custom | Iron longsword | Spellsword set if at least one primary or major magic skill, otherwise none |

Sources are Assets/Scripts/Game/Items/ItemHelper.cs#AssignStartingGear, Assets/Scripts/Game/Utility/StartGameBehaviour.cs#SetStartingSpells and Assets/Resources/StartingSpells.txt. Spell names are source labels; stable conversion and actual definitions remain governed by DATA/MAGIC.

Biography effects precede gear/spells in StartNewCharacter. The progression baseline is captured afterward. The approved creation draft must identify already represented effects to prevent duplicate application. Biography outcomes are data-dependent, so the selected draft's resolved effects and grants must be included in each startup fixture rather than adding a universal biography reward.

## Opening trace

StartNewCharacter initializes accounts/houses, regional data and weather, then starts _TUTOR__ before _BRISIEN. The source releases pause before those starts; the approved target retains entry gating through immediate presentations.

_TUTOR__ immediately prompts 1010. Accepting executes immediate 1012 and starts the next tutorial timer. _BRISIEN initializes its journal entry and immediately says 1025. This establishes invocation and script action order. Exact rendered queue order between the accepted tutorial continuation and already queued main-story message requires a controlled sequence fixture.

_BRISIEN's invitation clock has a 7–14 day range. Its reminders and later events retain authored timers and must not be awaited or accelerated at startup.

Approved deterministic immediate queue: tutorial accept/decline, main-story opening, then tutorial page 1 if accepted. Release player control after that immediate queue settles. Later tutorial pages retain their triggers.

## Approved exterior adaptation

Preserve the storm/Emperor mission context but replace claims that the player is currently sealed inside the cave with an explicit already-outside version. Keep general controls, equipment, spell and save guidance using effective binding labels. Replace the throne/lever and escape-door instructions with context-appropriate exterior orientation. Show travel guidance without requiring a dungeon-exit event. Preserve later city-entry trigger behavior. Exact replacement wording remains authoring work subject to this approved content policy.

## M3 initialization gap

Deliver an independently verified early account/property initialization increment under IMP-037's ECON ownership, shared by IMP-036. It produces the native initial account/property projection and no new deeds, possessions or entitlements by implication. IMP-045 later adds full account instruments, lending and deadline behavior against that projection. Compare source SetupAccounts/SetupHouses and approved ECON starting defaults before fixing the fixture values.

## Approval and fixtures

The user confirmed all choices, explicitly including five torches and two candles when item-based lighting is enabled. SetupAccounts and SetupHouses construct per-region default records in the source. The native initializer uses stable region keys and starts with zero deposits/debt and no property ownership, subject to explicit approved biography/start contributions. Pin class grant and startup payload fixtures to these tables and the selected draft before integration acceptance.
