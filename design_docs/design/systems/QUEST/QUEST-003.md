# QUEST-003 — Social offer eligibility

Approval status **Approved — finalized v1**

The user approved Draft v1 on 2026-11-12 with “I approve”. See QUEST-003-A01 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-003-interview-decisions).

## Gameplay purpose and intended player experience

Let players find work through civilians whose social role and faction fit the assignment. Social work normally arrives as a single offer. Authors can also create work that gives a player in bad standing a chance to repair a relationship.

## Confirmed requirements

- Preserve stock DFU level-or-reputation checks and quest-giver restrictions through explicit moddable requirements. Use the dedicated mature quest content setting from QUEST-002.
- Default to one random offer from the distinct eligible pool. Make the selection and presentation policy moddable, including an optional picker for debugging or authored use.
- Default to trying another eligible candidate after a recoverable, world-dependent generation failure before the offer settles and before any effects commit. Make the failure policy moddable, including a single-attempt option.
- Support signed reputation requirements, including an upper bound so authors can reserve redemption work for the intended reputation range.

See QUEST-003-D01–D04 in the [gameplay decision log](../../GAMEPLAY_DECISIONS.md#quest-003-interview-decisions).

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/UserInterfaceWindows/DaggerfallQuestOfferWindow.cs#GetQuest` takes the giver's faction and gender, looks up the player's reputation with that faction, and passes these along with the social group and player level to `QuestListsManager.cs#GetSocialQuest`. The latter matches the giver's gender code or the unrestricted code, applies the stock level-or-reputation check, and filters adult and previously accepted one-time rows. `SelectQuest` draws one eligible row and tries to load it. Failure can produce no offer. These findings come from static inspection.

## Detailed rules and formulas

1. Use the authorized provider and existing opportunity under NPC-023. Resolve the giver's social group and authored giver restrictions, plus the applicable faction reputation and player level. The stock gender codes map to unrestricted, male giver, or female giver. Apply provider reservations and authorization before selection.
2. For imported stock rows with threshold `T`, pass the progression check when `reputation >= T` or when `T < 10` and `level >= T`. Authored entries can declare a minimum player level, a reputation requirement, or an explicit level-or-reputation alternative. Apply the mature quest setting and prior one-time acceptance checks, then deduplicate by quest definition ID under QUEST-001.
3. Reputation requirements can specify an inclusive signed minimum, maximum, or both. Validate against the FACT reputation domain and require `minimum <= maximum` when both exist. For example, a maximum of `-10` reserves work for reputation `-10` or worse. A range of `-40` through `-10` also excludes characters whose standing has fallen below `-40`. An authored reputation-only condition prevents player level from bypassing that range. Quest rewards and faction changes remain authored outcomes.
4. For stock selection, draw uniformly from the remaining distinct eligible candidates. A successful generation settles one offer under the current provider and opportunity. When an attempt fails solely because of a recoverable world condition and has committed no effects, exclude that candidate from further draws for this request. Continue until one offer settles or the pool is exhausted. Each candidate is attempted at most once per request. An empty pool and exhausted generation attempts are distinct outcomes.
5. Invalid content follows DATA-003 and DATA-012 validation and recovery. An ambiguous or partially committed operation uses explicit owner recovery. If an offer has settled, presentation retry uses the same offer and terms. If eligibility changes before acceptance, revalidate and use the owner unavailable outcome. Duplicate callbacks and redraws reuse the request state and do not restart selection.

## Required data, inputs, outputs and events

Inputs include the authorized provider and opportunity ID, social group, giver restrictions, faction and reputation, player level, resolved list entries, mature quest preference, one-time history, selection and failure policies, and classified generation outcomes. Outputs include a distinct eligible pool, an offer candidate, a settled offer, no eligible work, or an explicit failure. Filtering has no acceptance or reward effects. Offer presentation, deferral and acceptance are separate owner events.

## Cross-system interactions

NPC-023 owns opportunity, provider identity and presentation lifetime. MOVE-023 owns interaction routing and consequential choices. QUEST-001 and DATA-012 supply resolved entries and deduplication. QUEST-002 supplies the mature quest setting contract. QUEST-004 owns one-time acceptance history. FACT supplies faction identity and signed reputation. CHAR supplies level. RULE-003 owns draws and retention. LOC and WORLD supply runtime placement readiness, and SAVE coordinates recovery.

## Edge cases and failure conditions

- A negative minimum alone still admits characters with better standing. Use a maximum or a bounded range to reserve redemption work. A higher level satisfies a reputation gate only where the entry explicitly supplies a level alternative.
- Two lists that qualify the same quest still yield one candidate and at most one generation attempt for that request. A stale picker choice cannot point to a different quest after a refresh.
- Generation failure before settlement does not spend the NPC opportunity. The same request retains attempted candidates and its outcome. A failed presentation after settlement retains the same offer. A successful stock presentation spends the opportunity under NPC-023.
- An invalid definition, failed generation after effects commit, or missing required context uses the appropriate failure path. Fallback is limited to the recoverable pre-settlement generation case.

## Configuration and balancing

Support validated selection and presentation policies, including the stock random offer and an optional eligible-only picker. A picker selection requests generation of the chosen quest. Any alternative after that choice requires an explicit interaction. Support validated failure policies including the stock bounded fallback and a single-attempt policy. Extensions preserve provider authorization, unique pool entries, request identity and settled-offer continuity.

## Save/load considerations

Rebuild derived eligibility from the current content plan and restored context. Retain supported settled offers, spent status and one-time history through NPC, QUEST and SAVE. A supported unfinished request retains its attempted candidates and settled outcomes so restoration does not replay attempts or reroll resolved work. Exact snapshot and recovery boundaries remain owner integration decisions.

## Technical constraints

Target Godot 4.7.2. Keep filtering, candidate selection, generation and presentation distinct. Validate signed reputation bounds. Require a classified generation result before fallback. Keep stable definition, provider and operation identity across supported retries.

## Acceptance criteria

1. Stock social rows preserve giver restrictions and threshold behavior. At threshold 9, level 9 can qualify despite lower reputation. At threshold 10, reputation must reach 10.
2. A maximum of `-10` passes at `-10` and `-11`, and fails at `-9`. A bounded negative range rejects values outside both bounds. Higher level cannot bypass a reputation-only rule.
3. Mature and one-time filtering apply before the distinct pool is drawn. The default settles at most one offer, and an enabled picker shows only eligible candidates.
4. A recoverable generation failure can lead to a different eligible candidate under the default policy. No candidate is attempted twice in the request. Single-attempt mode stops after the first failed draw.
5. Invalid content and partially committed generation follow recovery. A settled offer is never replaced by fallback, and duplicate calls or reload cannot spend the opportunity twice.

## Compatibility review and outstanding questions

The specification follows QUEST-001 pool deduplication, QUEST-002's mature quest preference, DATA-012 validation, NPC-023 offer continuity and RULE-003 retained outcomes. Exact FACT reputation limits, generation failure classifications, extension interfaces, and SAVE support for unfinished requests remain integration decisions.
