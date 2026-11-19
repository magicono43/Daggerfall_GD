# QUEST-001 — Quest lists and packs

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-11 with “I approve”. See QUEST-001-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-001-interview-decisions).

## Gameplay purpose and intended player experience

Let authored quest packs add or curate the adventures available through guilds and social groups. Installing overlapping packs should preserve access to eligible work without increasing a quest's chance merely because several lists include it.

## Confirmed requirements

- Packs may explicitly add, patch, or remove entries by stable ID. They may also replace a whole list.
- When applicable lists overlap, each eligible quest gets one chance in the combined pool.

See QUEST-001-D01–D02 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-001-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Questing/QuestListsManager.cs` discovers loose `QuestList*.txt` files recursively and registers mod-contributed lists. `LoadQuestLists` rebuilds the indexes from Classic and DFU lists followed by registered lists. `ParseQuestList` appends qualifying rows to guild, social, or startup indexes. `SelectQuest` draws from eligible rows, so repeated eligible rows can change the odds. `LoadQuest` checks the row's loose script path and then searches mod assets by filename if the loose file is absent. These observations come from static inspection.

## Detailed rules and behaviors

- A pack can contribute a new list under a stable list ID. To edit an existing list, target that list explicitly. Add requires an unused entry ID within the list. Patch and removal require an existing entry ID within the list. An entry ID identifies the editable row. Its quest definition ID identifies the quest for pool deduplication. A whole-list replacement supplies the complete new list at that point in source order, and later authorized operations can edit the result.
- Apply DATA-003 precedence, provenance, and patch semantics. An omitted field retains its resolved value. Removing an entry removes only that list's contribution to the quest's availability. The definition and its entries in other lists remain available under their own rules.
- Validate the resulting lists and required references before publishing. Reject repeated quest definition IDs within the same resolved list. Multiple lists may reference the same definition. Reject invalid contributions as a whole and rebuild from the clean base after a supported configuration change or recovery.
- For one offer request, evaluate the applicable entries using the relevant eligibility rules. Include a definition once if at least one applicable entry for it passes. Keep the eligible source references so eligibility and provenance can be explained. Resolve the selected quest by stable definition ID through DATA-012.
- Return an empty candidate pool when no entries qualify. A pool lookup or rebuild has no acceptance, presentation, reward, or startup effects. Startup entries are handed to the startup owner under CORE-012 and QUEST-004.

## Formulas, parameters and balancing

Let `N` be the number of distinct eligible quest definition IDs in one combined offer pool. A uniform draw gives each candidate probability `1/N` when `N > 0`. The list contract supplies one slot per eligible definition. It introduces no custom weights or variants. Authors adjust availability through supported list operations and eligibility metadata. Selection timing, retries, and eligibility parameters remain with the applicable offer features.

## Required data, inputs, outputs and events

Inputs include the resolved package plan, list IDs, per-list stable entry IDs, quest definition references, applicable group and eligibility metadata, declared operations, provenance, and the offer context. Legacy list names and fields use the approved DATA-012 mapping where supported. Outputs are validated indexed lists or explicit source diagnostics, and a distinct eligible candidate pool for the requesting context. Catalog readiness permits queries. NPC and QUEST own presentation and acceptance events.

## Cross-system interactions

DATA-003 and DATA-012 own source precedence, validation publication and definition resolution. QUEST-002 and QUEST-003 own guild and social eligibility. QUEST-004 and CORE-012 own startup and one-time tracking. NPC-023 owns provider binding and retained offer presentation. RULE owns the randomness contract and SAVE coordinates restoration of authoritative quest records.

## Edge cases and failure conditions

- A missing edit target, colliding add ID, same-list duplicate quest, or unresolved required definition rejects its contribution through DATA recovery. A later pack can only edit an entry that exists at its point in the resolved order.
- If one membership fails eligibility and another passes, the quest appears once. Removing one membership leaves the quest eligible through any other passing membership. Overlapping lists cannot multiply the draw slots.
- Two unrelated quests with matching filenames remain distinct if they have distinct resolved definition IDs. Multiple references to the same definition collapse to one slot even when the source lists differ.
- Runtime binding or generation can still fail after source validation. The offer owner defines the outcome and retry behavior. A catalog rebuild cannot replace the quest behind an already settled offer.

## Save/load considerations

Rebuild derived indexes from the validated content plan. Restore supported settled offers, active quest state and durable history through the owning features, using stable references. Apply explicit compatibility or recovery if a required saved reference is missing or incompatible. Restoring or rebuilding lists cannot reroll an existing offer, clear one-time history, or start fresh-character quests.

## Technical constraints

Target Godot 4.7.2. Keep source resolution, list composition, eligibility queries, and quest instantiation separate. Use approved deterministic source ordering. Validation and index construction must be side-effect-free and publish a coherent catalog.

## Acceptance criteria

1. A pack can add, patch and remove entries by stable ID and can replace an entire list. An unrelated list referencing the same quest remains intact.
2. Invalid edits or references reject the whole contribution with source context. Rebuilding the same plan gives the same catalog without accumulating entries.
3. If two applicable lists contain Quest A and only one contains Quest B, with all entries eligible, the combined pool has two slots. A uniform draw gives each quest a 50% chance.
4. If only one of two applicable entries for a quest passes eligibility, the quest still has one slot. If both fail, it has none.
5. Indexing and save restoration do not start quests, change acceptance history or reroll settled offers.

## Compatibility review and outstanding questions

Reviewed against DATA-003 and DATA-012 for explicit edits, duplicate control and recovery, NPC-023 for offer continuity, and CORE-012 for startup. Entry-level removal is an explicit supported operation. Eligibility is evaluated per applicable entry before deduplication. Stable entry IDs are scoped to their list. A uniform draw is the baseline example.

Exact schema, legacy import mappings, and precedence for any future entry metadata that changes the terms of a single offer remain integration decisions. Guild and social thresholds, runtime failure retries, startup execution order, and save migration details remain with their owning features.
