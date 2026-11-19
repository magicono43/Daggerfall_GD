# FACT-007 — Political power, rulers, and war outcomes

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-007-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-007-interview-decisions).

## Gameplay purpose and intended experience

Factions gain and lose influence as the calendar advances. Players hear about new rulers, declarations of war, and peace or victory through regional news. Quests can respond to specific political events while accepted work keeps its established giver and obligations unless the quest explicitly defines a response.

## Confirmed requirements

- Process power every seven game days and diplomacy and war every 38 game days. Process every crossed boundary once in chronological order, with power first on ties. Faction power ranges from 1 to 100 and generated ruler bonuses range from 20 to 70.
- Evaluate each active war once per due war update. When a battle occurs, subtract losses on both sides and compare their remaining effective strengths.
- Supply regional rumors and notices for ruler succession, war declarations, and war outcomes. Routine power changes are exposed only where content explicitly uses them. Quests may check current or recorded political facts and must explicitly declare any response that changes their existing obligations. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-007-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Entities/PlayerEntity.cs#Update` invokes `RegionPowerAndConditionsUpdate(false)` every seven days and `RegionPowerAndConditionsUpdate(true)` every 38 days. Both invocations run the power pass before the condition-specific branch. Power draws on parent, ally and enemy power and the ruler bonus. The region pass can change relationships, generate replacement rulers, advance wars, and issue rumors. The war branch picks the first eligible enemy slot, adds two positive amounts named losses, and computes remaining strength differently for each side. `Game/Player/PersistentFactionData.cs#ChangePower` clamps power to 1–100. `SetNewRulerData` generates a bonus from 20 to 70 and a ruler name seed.

## Detailed rules and stock defaults

1. TIME delivers committed world-time advances. Count boundaries strictly after the start and through the destination. Process them in timestamp order and give the seven-day power pass precedence over the 38-day diplomacy pass on ties. The 38-day pass does not rerun routine power drift. Its battle and succession effects may change political state through their own rules. Replay each due boundary during rest, travel, or other committed game-time advances. Duplicate delivery, load, and backward time adjustments do not create new events. FACT-004's sentence exception applies to reputation normalization.
2. The stock power pass uses a percentile success threshold of `floor(parentPower / 10) + floor(allyPowerTotal / 10) + rulerBonus - floor(enemyPowerTotal / 10)`, bounded to 0–100. An absent parent contributes zero. Success adds one power and failure subtracts one, clamped to 1–100. Use native distinct outgoing links under FACT-006. On each 38-day pass, a ruler without replacement immunity has a replacement chance of `100 - (70 + floor(rulerBonus / 3))` percent, bounded to 0–100. A replacement commits its generated name identity and uniformly drawn integer bonus of 20–70 once. The succession fact identifies the previous and new ruler.
3. FACT-006 first validates and commits a declaration for an eligible province pair. The next due war update advances Beginning to Ongoing. Later due updates can resolve a battle. Resolve each war by stable identity once per boundary, independent of which province is visited first. A terminal result commits both sides together and hands cleanup to FACT-006. Native peace preserves independent rivalry.
4. The stock battle baseline gives each side effective strength equal to faction power plus the sum of allied faction power divided by five. Use integer division. For each side draw an independent integer loss from 1 through the greater of 1 and one tenth of the opposing effective strength, rounded down. Subtract each loss from its own faction power with the common clamp. Compare each side's pre-battle effective strength minus its own loss, floored at zero. A side wins when its remaining strength is strictly more than twice the opponent's. Otherwise the war continues. A tie, including two zero values, has no winner. The victory margin, battle frequency and any winner bonus are balance parameters. The stock policy retains the source's 95% battle opportunity for an ongoing war per due update and applies no automatic winner bonus.
5. Emit committed political facts with stable event identities. NPC-021 owns rumor and bulletin selection, scope and expiry. QUEST can read a current state or a recorded event through an explicitly authored condition. Preserve accepted quest context, including when a ruler is replaced. A quest that responds to a transition uses its own authored branch and established settlement rules.

## Required data, inputs, outputs, and events

Use stable faction, region, ruler and war identities, faction power, ruler bonus and immunity, parent and directional relationships, war phase and participants, time progress, validated policy parameters and retained random outcomes. Inputs include a committed time advance and authorized political state. Outputs include power changes, succession, declaration, progression and terminal outcome facts. Publish public news only from committed qualifying facts. Give QUEST the identity and scope it needs to evaluate a fact without replaying it.

## Cross-system interactions

TIME supplies boundaries and shared timestamp ordering. RULE governs random draws and retention. FACT-001 supplies identity, FACT-006 owns diplomacy, war eligibility and peace cleanup, and FACT-008 owns regional condition and market handoff. NPC-021 consumes public facts. QUEST owns conditional response and existing obligations. SAVE restores political state and progress.

## Edge cases and failure conditions

- A long advance processes the same due political boundaries as shorter advances with the same intervening inputs. Pause adds no elapsed game time.
- Both provinces can appear in one simulation pass. A stable war identity prevents a second battle in that pass.
- At a power cap, return the actual applied change. Use the specified battle comparison even if a power loss reaches the storage floor.
- Resolve required references before commitment. A missing required participant or invalid state follows explicit recovery without issuing partial war outcomes or duplicate news.

## Configuration and balancing

Stock cadences, power bounds and ruler bonus range follow the confirmed values. Keep power drift, succession, battle odds, loss ranges and victory thresholds inspectable in the selected policy. Public presentation controls remain with NPC-021. Regional economic effects are FACT-008 and ECON scope.

## Save/load considerations

Persist live power, ruler identity and bonus, war phase, recorded outcomes required by consumers, and enough time and draw progress to resume coherently. A reload cannot reroll a committed battle, generate a second ruler or repost an already committed political event.

## Technical constraints and consistency review

Derive due boundaries without scanning every minute. Process stable war identities and stage participant updates before publishing outcomes. Preserve FACT-006 relationship sources, FACT-004 normalization ownership, NPC-021 public news lifecycle, and QUEST's established binding and effect retention. Exact ordering with other domains at a shared timestamp remains a TIME contract.

## Acceptance criteria

1. A shared boundary runs routine power once before diplomacy and war. A long advance, duplicate delivery and exact endpoint follow the stated boundary rules.
2. Power stays in 1–100. A ruler immune to ordinary replacement retains their identity. A committed successor retains their identity and bonus across reload.
3. A war advances once per due update. A battle subtracts losses symmetrically. Equal effective strengths after losses yield no winner, and a winning outcome updates both sides coherently.
4. Succession, declarations and terminal war facts reach NPC-021 once. A routine power change appears only through explicit content. Accepted quests preserve their obligations unless authored response applies.
5. Save and reload preserve committed political outcomes, news identities and due progress.

## Outstanding questions

Candidate selection and transition odds for diplomacy, stock formula fixtures, the full TIME ordering, and persistence schemas remain integration details.
