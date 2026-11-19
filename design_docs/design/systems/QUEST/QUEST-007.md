# QUEST-007 — Localized messages and macro expansion

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-007-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-007-interview-decisions).

## Gameplay purpose and intended player experience

Present quest titles, instructions, choices and journal entries in the player's language with accurate details. Switching languages preserves the meaning of an open prompt and the facts recorded in the journal. Quest authors can preview translated messages and see what topics the game is intended to reveal when it shows a clue.

## Confirmed requirements

- Allow natural rephrasing and placeholder reordering. Preserve required details, choice IDs and the gameplay references behind placeholders. Fall back for the requested message and variant if the translation omits required information or lacks the selected variant.
- Retranslate historical journal entries when a compatible template is available, using the facts recorded when each entry was written. Use the retained readable entry when usable retranslation is unavailable.
- Extend author testing with message previews that can switch locales, show fallback and placeholder or variant diagnostics, and list authored dialogue reveals.

See QUEST-007-D01–D03 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-007-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/QuestMachine.cs#ParseLocalizedQuestText` searches mod assets and the quest text directory. `ParseQuest` can set a localized display name, and `Quest.cs` requests localization restoration for a restored quest. `Message.cs#GetTextTokens` can select a random variant, then invokes `Utility/QuestMacroHelper.cs#ExpandQuestMessage`. The popup path allows macro expansion to reveal linked dialogue resources. These findings come from static inspection.

## Detailed rules and behaviors

1. Address a quest message and its variants by stable IDs within the quest's message scope. Use explicit mappings for imported message and variant identities. Resolve titles through the same localization policy. Translation changes presentation while preserving choice IDs, intended effects and bound resources.
2. Validate translations against the message contract for required details, allowed macros, typed substitutions and essential controls. Translators can reorder placeholders and rephrase text. A required destination or choice that is missing makes that translated candidate unusable. Diagnostics identify the message, variant, locale, source and issue where available.
3. Apply DATA-013/015 fallback in order: selected language, declared base language, then explicit source fallback. Resolve the same message and retained variant at each tier. If a required value is missing in every candidate, route to the owner's recovery path. Failure to render an essential prompt leaves its choices uncommitted. Declared optional defaults and suppression follow DATA-016.
4. The requesting owner selects a variant once using its approved policy and provides scoped, retained context. Macro expansion preserves bound referents and follows DATA-016 rules for typed outputs, literal insertion and supported nesting. Rerender, locale change and preview reuse the selected variant and resolved values without consuming gameplay randomness.
5. Record journal entries with their message and variant identity, historical facts needed for retranslation, and readable fallback text. On language change, render a compatible template using those recorded facts. For example, an entry that named an inn still describes that inn after the target relocates. If no usable compatible template remains after lookup, show the retained text.
6. Use NPC-022's explicit reveal operation for dialogue topics. Successful presentation of an authorized clue can reveal its linked topics under the authored policy. Preview, fallback lookup, journal reopening, translation refresh and redraw do not replay that reveal. A translation cannot add a reveal by mentioning another resource.

## Author preview

The QUEST-005 workflow can preview a selected message and variant in supported locales using supplied quest context or a test fixture. Show the selected fallback tier and source, missing placeholders or variants, and the intended dialogue links and reveal boundary. Preview reports intended effects without committing them. In-world testing can exercise the actual presentation and reveal path in the approved test context.

## Required data, inputs, outputs and events

Inputs include stable quest, message, variant and choice IDs, locale and fallback mappings, structured templates with provenance, required placeholder contracts, retained context values and authored reveal references. Historical journal entries also carry the facts needed for compatible retranslation and a readable fallback. Outputs include usable text and presentation structure or explicit failure diagnostics. UI acknowledges successful presentation through the relevant owner, which commits any authorized reveal separately.

## Cross-system interactions

DATA-013/014 own localization and translation validation, DATA-015 owns structured formatting and variants, and DATA-016 owns macro expansion contracts. QUEST-005 supplies author testing and diagnostic provenance. QUEST-018 and UI own message and journal presentation. NPC-022 owns dialogue reveals and retirement. RULE-003 governs retained random outcomes. SAVE and the requesting owners govern persistence of message context and interaction state.

## Edge cases and failure conditions

- A translation has the correct message ID but lacks the selected variant. Try the next fallback tier for that variant. Keep the resolved offer and choices intact.
- Two bound people share a display name. Their stable resource identities and dialogue links remain distinct.
- A template remains available after a content update but can no longer render the recorded journal facts faithfully. Treat it as incompatible and show the retained entry if no usable fallback exists.
- A reveal request arrives after a clue retires or repeats after success. Apply NPC-022 authorization and duplicate protection. Preview can list the authored intent without making the topic available.

## Configuration and balancing

Authors configure translations, supported optional placeholders, message variants, and authorized reveal policy through the relevant owners. Locale selection changes presentation. This feature adds no new balance formulas or variant probabilities.

## Save/load considerations

Persist journal records and the context needed to restore supported pending messages. Use stable message and variant IDs and retain historical facts and readable fallback as required above. Restore owner-managed reveal and choice state before allowing consequential interactions. Retranslation and restoration do not reroll variants, replay dialogue reveals or recommit choices.

## Technical constraints

Target Godot 4.7.2. Keep reusable templates, retained message context, and authoritative presentation outcomes separate. Validate translated structure and macro contracts, and treat substituted names as literal data under DATA-016. Exact template compatibility and snapshot schemas remain integration decisions.

## Acceptance criteria

1. A translation can reorder placeholders while keeping the intended people, places, items and choices. A missing required detail or selected variant invokes fallback for the same message and variant.
2. Refreshing the language preserves the selected variant, resolved values and choice IDs. It consumes no gameplay randomness.
3. A journal entry can be retranslated with its original facts after a quest resource moves. If no compatible template can render it, the retained entry remains readable.
4. A preview shows locale, fallback, relevant diagnostics and intended reveal links without modifying gameplay. An authorized live presentation can reveal the topic once under NPC-022.
5. An essential message that exhausts fallback enters owner recovery without accepting, declining or completing the interaction.

## Compatibility review and outstanding questions

The specification follows DATA-013 through DATA-016, NPC-022 and QUEST-005. Exact legacy variant mappings, journal compatibility metadata, and the preview interface remain open.
