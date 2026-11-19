# FACT-005 — Social reactions and quest reputation inputs

Approval status **Approved — finalized v1**  
Updated 2026-11-13.

The user approved Draft v1 on 2026-11-13 with “I approve”. See FACT-005-A01 in the [decision log](../../GAMEPLAY_DECISIONS.md#fact-005-interview-decisions).

## Gameplay purpose and intended player experience

Let personal reputation, social background, and temporary effects influence how an NPC receives the player. A favorable impression can open a conversation while faction work still requires earned standing. A quest author can explicitly make a condition depend on the NPC's current impression.

## Confirmed requirements

- Preserve DFU's distinct lookup for opening reaction and the FACT-001 organization lookup for faction greetings.
- Ordinary quest reputation gates use committed standing. An explicitly authored reaction condition can use the current impression. Rebuild live reaction modifiers from restored effects without counting them twice.
- Preserve the additive opening reaction formula and dialogue thresholds in NPC-018. See [the decision log](../../GAMEPLAY_DECISIONS.md#fact-005-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/TalkManager.cs#GetReactionToPlayer` sums faction standing, biography reaction, live reaction modifiers for the resolved faction's social group, and the applicable stored social-group standing. `TalkToStaticNPC` walks the faction hierarchy until it reaches a supported reaction type or the root. `TalkToMobileNPC` uses regional People. `GetNPCGreetingRecord` performs the distinct organization lookup.

`Game/Entities/PlayerEntity.cs#ChangeReactionMod` and `GetReactionMod` use a live modifier array. Enchantments such as GoodRepWith and BadRepWith contribute to it. `Game/Serialization/SerializablePlayer.cs` persists biography and stored group standing fields separately from live modifiers. `Game/Questing/Actions/WhenReputeWith.cs` reads stored faction standing for its inclusive minimum and returns false if the faction lookup fails. `ChangeReputeWith.cs` changes faction standing through the propagation path.

## Detailed rules and formulas

1. Resolve the speaker's affiliation using FACT-001 and NPC-017. For a placed NPC, use the first Group, Province, Temple, People, Court, or Individual faction encountered starting at the resolved faction and walking through its parents. Use the root if no earlier node qualifies. Ordinary wandering civilians use their regional People faction. Resolve faction greeting organization independently under FACT-001.
2. Calculate `openingReaction = factionStanding + biographyModifier + socialGroupStanding + liveSocialGroupModifiers` using the selected reaction faction and applicable social group. Add each applicable input once. Use the group's committed standing and the total of its admitted live modifiers. A missing required reference is an explicit resolution failure. When the authored context permits an absent component, its contribution is zero. An intentionally unaffiliated speaker can still have an explicitly authored social group.
3. Supply the calculated score and resolved context to NPC-018. Apply its opening refusal threshold of strictly below −20 and generic greeting bands starting at 0, 10, and 30. NPC-018 separately owns faction greeting checks, tone, answers, and retained refusal outcomes.
4. Ordinary reputation predicates and guild or social offer checks read committed standing for the authorized faction under FACT-002 and QUEST-002/003. They use their own threshold and level substitution rules. A quest that intentionally depends on the opening reaction score uses an explicit condition bound to an authorized speaker context. Evaluate it at the condition's declared check point and use the owning quest's revalidation rules. The calculation is read-only and does not open a conversation or draw a greeting roll.
5. Quest standing rewards and penalties use their authorized targets and FACT-002/003 under QUEST-019. The speaker's reaction faction and greeting organization have no authority to redirect a reward.

## Required data, inputs, outputs, and events

Use stable actor, faction, and social-group identities, authorized interaction context, faction type and ancestry, committed faction and social-group standing, biography modifier, and admitted live effect contributions. Return the selected reaction faction, applicable group, component values and total, or an explicit unavailable result. Quest standing checks receive the authorized faction's committed standing or the applicable failure. These queries emit no mutation events. Owners publish standing and effect lifecycle changes under their existing contracts.

## Cross-system interactions

FACT-001 resolves affiliation and organization. FACT-002/003 own faction changes. CHAR supplies biography and applicable character creation inputs. MAGIC supplies live modifiers through its effect admission, stacking, and lifecycle rules. NPC-017/018 own conversation context and reaction use. QUEST-002/003/019 own offer and consequence checks. LAW retains regional legal standing as a separate input domain.

## Edge cases and failure conditions

- An Individual under a guild can use personal standing for opening reaction while the faction greeting resolves the guild under FACT-001.
- A temporary bonus can move the opening score across the refusal threshold. A normal quest faction gate still sees the same committed standing.
- Intentional absence and a broken required faction or group reference produce distinct outcomes. Missing required context follows owner failure handling.
- When a live effect ends, its contribution disappears for subsequent evaluations. An already settled dialogue or quest outcome follows its owner's retention rules.

## Configuration and balancing

Author applicable social-group classification, biography inputs, and reaction effect values through their owning features. Keep NPC-018's approved thresholds and FACT-002's standing scale. The opening score is a sum and can exceed the faction standing bounds. Quest content chooses explicitly between a committed standing predicate and a reaction predicate.

## Save/load considerations

Persist authored or settled character biography inputs and durable social-group standing under their owner contracts. Restore admitted effects and rebuild the live modifier total once before gameplay queries can read it. Preserve any owner-retained quest or dialogue outcome under its save contract. Repeated reconstruction must produce the same modifiers for the same admitted effects.

## Technical constraints and consistency review

Use stable definition references and validate required context. Evaluate each calculation from a coherent view of the selected faction and applicable modifiers. Separate durable inputs from derived live totals. The draft preserves FACT-001's organization lookup, FACT-002's committed standing, NPC-018's opening formula and dialogue rules, and QUEST-002/003/019's authorized faction checks and outcomes.

## Acceptance criteria

1. A placed Individual under a guild uses personal standing for opening reaction and resolves its organization separately. A wandering civilian uses regional People.
2. Applicable components contribute once. Optional absent components contribute zero and a missing required reference yields explicit failure.
3. With standing −25 and a temporary +10 modifier, the opening score is −15 when other contributions are zero. An ordinary standing predicate still reads −25 and an explicit reaction predicate can read −15.
4. Expiry removes the live contribution. Save and reload preserve admitted effects and reconstruct the same total without duplicating the bonus.
5. Quest standing changes reach the authorized target even when the reaction faction and greeting organization differ.

## Outstanding questions

Exact social-group key encoding, the inventory of imported biography and group values, and the quest condition schema remain integration details under DATA, CHAR, and QUEST.
