# ITEM-020 — Loot tables and random additions

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Generate declared loot through explicit context and retained outcomes, preserving existing possessions and avoiding rerolls or partial publication.

## Intended player experience

Loot follows its declared source/level profile and stays fixed once resolved. Opening, saving and retries cannot reroll rewards. Valid empty loot is distinct from a generation error, and required quest additions cannot silently vanish.

## Confirmed requirements

- **ITEM-020-D01:** Loot profiles explicitly declare table, eligible pools, level/scaling inputs and appearance context. Support player/location/enemy/fixed level profiles without implicit current-player context for every source.
- **ITEM-020-D02:** Stable generation identity retains resolved contents across reopening, scene reload and technical retries. New generation requires authorized spawn/restock. Previews/diagnostics use isolated randomness without changing live loot.
- **ITEM-020-D03:** Prepare/validate complete result before publication. Existing possessions/quest additions cannot be cleared absent explicit authorized replacement/disposition. Required-content failures use recovery, not partial/default loot or rerolls.
- **ITEM-020-D04:** Initial model uses independent category rolls, repeating with chance halved after each item. Approved RULE semantics: 0% never, 100% always. Explicit alternative count/weighted-pool models moddable.
- **ITEM-020-D05:** Initial profile scales gold quantity and C1/C2/P1/P2 ingredient chances by declared generation level; other category chances unscaled. Equipment materials use RULE-026 with that level. Fixed/alternative scaling profiles supported; not every source implicitly player-scaled.
- **ITEM-020-D06:** Map/potion/recipe additions are explicit stages with chances/pools. Quest/authored guaranteed additions remain distinct from random rolls and survive category failure. All additions use one validated publication.
- **ITEM-020-D07:** Inspected DFU matrices/dungeon-type mappings are initial data baseline, with validated replacements/additions and approved native probability semantics, not claimed classic parity. Enemy/quest/other sources explicitly select table/profile.
- **ITEM-020-D08:** Preserve raw scaled chance, test at most 100%, halve raw after success. Baseline truncates each tested whole-percent chance and stops at zero without draw. Thus 200% gives guaranteed first/second then 50%. Explicit finer-fraction alternatives supported.
- **ITEM-020-D09:** Validate finite pools, numeric ranges and bounded generation before publication. Exceeded configured safety bounds/provider errors fail with retained recovery, not silent reward truncation/reroll. Legitimate empty result recorded as valid.
- **ITEM-020-D10:** Loot-changing extensions run as declared ordered pre-publication stages. Post-publication notifications report completed loot, not independent rerolls/repeated additions. Later rewards are separate authorized operations.
- **ITEM-020-D11:** Profiles explicitly define quantity, worn condition, identification and special contents through approved constructors. Player capacity limits acquisition, not world-container loot amount. Actual destination limits need declared overflow/recovery, no silent reward deletion.
- **ITEM-020-D12:** Persist generation identity/context/resolved contents including emptiness and completed publication/addition facts. No load regeneration from current level/changed tables. Missing definitions/interrupted publication need retained-result migration/recovery, no duplicate quest additions/fresh rolls.

User confirmed all three recommendations with “1. Yes / 2. Yes / 3. Yes” to the first interview. See [the decision log](../../GAMEPLAY_DECISIONS.md).

Second interview confirmed D04–D06 with “1. Yes / 2. Yes / 3. Yes”.

Third interview confirmed D07–D09 with “1. Yes / 2. Yes / 3. Yes”.

Fourth interview confirmed D10–D12 with “1. Yes / 2. Yes / 3. Yes”.

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Items/LootTables.cs#GenerateRandomLoot`: gold range ×player level; C1/C2/P1/P2 ingredient chances ×player level; repeated category success with halving chance. Equipment uses player level/gender/race. It reseeds Unity Random from a temporary list hash.
- Location table generation adds separate map/potion/recipe rolls for selected keys and raises OnLootSpawned with collection access.
- `Internal/DaggerfallLoot.cs#GenerateItems` resolves a matrix, generates items then imports/replaces contents. Random addition helpers select maps/potions/recipes; their source pool semantics differ.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Distribution/classic parity and runtime fixtures unverified; source unchanged. Source comments about classic chance boundaries are not verified native requirements.

## Existing approved constraints

RULE-003 owns purpose-separated randomness, retained resolved results/retry reuse and isolated diagnostics. RULE-026 owns material-selection policies. ITEM-003/004 require explicit construction context/pools, valid state/providers and artifact authorization; ITEM-005–009 checked publication/currency. MOVE-022 prohibits inspection/reopen rerolls. ITEM-021 owns shop/household restock details, not finalized by this feature.

## Detailed rules and behaviors

### Profiles and context

Every authorized generation names a stable source/generation identity and resolved profile/table/pools, declared level/scaling inputs, appearance and relevant source/location context. Support player-, enemy-, location- and fixed-level profiles explicitly. Do not implicitly use current player level/gender/race for every container or actor. The caller/source owner chooses which supported profile applies; this feature does not assign one universal scaling mode to all enemies/dungeons.

Initial data baseline is the inspected `LootTables.DefaultLootTables` matrix entries and dungeon-type key mapping in `LootTables.cs` of the recorded local snapshot. Preserve explicit classic mappings while using native stable profile IDs. Validated DATA/MOD additions/replacements are supported. This adopts those data entries, not source shared-RNG reseeding, mutable callbacks, unchecked replacement or a claim of exact classic output parity. Complete extracted baseline fixtures/mappings remain required before implementation is complete.

Item pools declare supported candidates rather than automatically including all registered definitions. ITEM-003/004 constructors validate material/appearance, actual magic/potion/soul contents, quantity, initial condition and identification. Artifacts require explicit authorization and are excluded from ordinary regular-magic pools under ITEM-004. Currency follows ITEM-009 explicit denomination/gold-unit mapping.

### Baseline category generation

Draw gold inclusively from the selected matrix minimum/maximum, then multiply by declared generation level; publish coins only for positive valid result. Scale C1/C2/P1/P2 category chances by that level. Other matrix category chances remain unscaled. Equipment material selection uses RULE-026 with declared level. These are initial profile rules, with explicit fixed/alternative policies supported.

Categories roll independently. Retain raw starting chance; test whole-percent truncation capped at 100. On success generate the declared category item and halve raw chance; on failure end that category. A tested zero stops without a draw. Approved RULE semantics make zero impossible and 100 certain. Raw values above 100 are not discarded before halving: 200 yields guaranteed first/second then a 50% attempt. Explicit finer-fraction/count/weighted-pool alternatives declare their own semantics and compatibility.

Preserve specified stage order and owned RNG context; do not normalize the chance matrix into weights or turn independent categories into one mutually exclusive pick. Negative/malformed chances, invalid level/ranges or arithmetic overflow are explicit errors, not hidden clamps/fallback tables. Concrete supported numeric domains and quantization representation require fixtures.

### Supplemental and authored additions

Map, potion and recipe additions are explicit stages with declared chances/eligible pools. Source location-key helpers are evidence of candidate baseline supplemental data, not blanket adoption of every helper's different classic/all-registered recipe pool. Concrete supported profiles must resolve these choices explicitly before support is claimed.

Guaranteed quest/authored additions remain distinguishable from random outcomes and cannot be discarded because a category roll fails or yields empty. Coordinate their protection/custody with QUEST owners. Generation does not itself complete quests, teach recipes, identify hidden items or activate enchanted payloads.

Loot-changing mod providers participate as declared ordered generation stages before final validation/publication, with resolved precedence/provenance. Missing required content/provider failure is not a failed chance roll. Post-publication notifications describe committed loot; they cannot reroll or repeat authoritative additions. A genuinely later reward is another authorized operation with its own identity/commitment, not mutation repeated on every observer refresh.

### Resolve once and publish safely

Use RULE-003 purpose-owned randomness with no per-call reseeding from time/object hashes. Retain resolved outcomes and generated item state across technical retry/reopen/scene reconstruction/save. Fresh unresolved gameplay rolls after load remain RULE-003 behavior; they do not authorize rerolling resolved loot. Generation must not be triggered by hover, Info or diagnostic preview.

Prepare and validate the complete result, including additions/state/provider compatibility and destination admission, before publication. Preserve existing possessions and quest additions unless an explicitly authorized replacement names their disposition under ITEM-007. No clear-first generation, partial/default substitute or random retry to hide errors.

Player carrying capacity limits acquisition, not the amount present in a world loot source. Actual destination entry/quantity/other limits require explicit overflow/recovery policies with no silent reward deletion. Do not truncate a successful generated result to what the player can carry. ITEM-005–008 govern later split/merge/transfer and explicit take-what-fits.

Validate finite pools, safe arithmetic and bounded generation/provider work. Exceeded declared safety limits fail with retained recovery, not a successful shorter reward list. Baseline halving/whole-percent termination must remain finite under supported numeric inputs; arbitrary mod loops require their declared bounds. Legitimately empty generation is a successful persistent result, never a signal to regenerate.

Publication/addition phases retain operation identity and completion facts. Ordinary pre-publication failure exposes no partial loot and leaves existing state intact. If a technical boundary partially commits, record true progress/recovery instead of repeating grants or losing resolved outcomes. Concrete receipts and staging APIs remain design dependencies; no general transaction framework is mandated.

## Relevant formulas and parameters

- Gold G = inclusiveInteger(minGold,maxGold) × declaredLevel for valid initial profile inputs; G=0 produces no coin item.
- Starting chance r0 = matrix chance × level for C1/C2/P1/P2, otherwise matrix chance.
- Tested chance pk = min(100,trunc(rk)); pk=0 ends without draw; successful stage produces item then rk+1=rk/2, failed stage ends category.
- For r0=200: tested chances 100,100,50,25,12,6,3,1, then zero if every prior attempt succeeds.

No new universal generation level, total loot cap, category item weights, artifact rate, supplemental chance or default worn-condition amount is selected beyond the approved baseline/data scope. Explicit alternative policies require supported schemas and verified probability semantics.

## Required data

Stable source/generation/profile/table/pool/provider/location IDs; accepted context/level/appearance; matrix/scaling/order/quantization rules; candidate compatibility and quantity/state policies; guaranteed/supplemental stage provenance; resolved random/results/item identities including empty state; destination admission/disposition; publication/addition/recovery facts and compatibility versions. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: authorized new spawn/restock/reward request with context, resolved table/stages, owned random source, owner construction/admission results and restore/recovery. Outputs: retained complete generated result or valid empty result, committed publication or explicit rejection/recovery. Inspection/diagnostics return isolated distribution/results without live draws or grants. Notifications cannot repeat generation/additions. Concrete APIs/signals remain unselected.

## Cross-system interactions

RULE-001/003 own chance/random/retry semantics; RULE-026 material selection. DATA/MOD validate tables/pools/providers and deterministic contributions. ITEM-003/004 construct state, ITEM-005–009 publish/transfer/currency safely and ITEM-019 governs initial observer knowledge. NPC/LOC/WORLD/QUEST own source context and authorized additions; ITEM-021 restock/shop/household profiles remain separate. MOVE-022 prohibits inspection rerolls; SAVE/CORE retain coherent generation facts.

## Edge cases and failure conditions

- Zero/100/>100 chance: exact approved test/halving, no zero-percent floor chance.
- Empty versus missing table/pool/provider: valid empty recorded, required error explicit.
- Player levels up after loot resolves: retain assigned contents/material, no re-generation.
- Reopen/retry/scene reload: no new item IDs, extra guaranteed additions or fresh roll for resolved stages.
- Required constructor fails/safety bound exceeded: recover without truncated/default loot or random substitution.
- Existing container possessions/protected quest item: no unauthorized replacement/clear.
- World reward exceeds player capacity: retain loot, acquisition admission separately checked.
- Post-publication observer delivered twice: no additional reward mutation.

## Configuration and balancing options

Validated matrix/pool/mapping replacements, level inputs/scaling, alternative count/weighted/fractional models, explicit supplementary/guaranteed stages and initial item-state profiles are supported. No automatic all-mod inclusion, player-context inheritance, reroll-on-open or silently limited reward count is approved. Concrete source/table assignments and alternative profiles require explicit owner decisions.

## Save/load considerations

Persist generation identity/context, resolved contents/state/IDs or empty result, required profile compatibility and completed publication/addition facts. Loading cannot regenerate from changed player level/tables or repeat QUEST additions. Preserve partially resolved/committed operation facts where explicitly supported; no whole-operation reseed/retry.

Missing/changed definitions/providers require explicit migration/recovery using retained results, not ordinary empty loot/default replacement. Coherent or supported pending snapshots follow existing ITEM/CORE contracts; unsupported pending publication explains temporary save blocking. New session rejects old callbacks. Exact native schemas and fixture extraction remain dependencies.

## Technical constraints

Target Godot 4.7.2. Separate validated generation profiles, explicit source context, owned RNG, prepared results and authoritative publication. No global-player lookup, object-hash reseeding, clear-first import or mutable observer as the sole extension mechanism. Diagnostics isolate live RNG. Safe bounds and stable identities required without mandating a specific generator framework. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Explicit profile/table/pools/level/appearance support source-owned contexts without universal current-player inheritance.
2. Inspected matrix/dungeon mapping baseline works under approved native probability semantics with validated extensions.
3. Independent repeating categories halve raw chance with whole-percent test/cap/zero termination; gold/C1/C2/P1/P2 initial scaling and RULE-026 materials use declared level.
4. Explicit supplement/guaranteed stages preserve required authored additions and run in declared validated order.
5. Resolved results/IDs/emptiness survive reopen/retry/load without reroll or duplicated stage publication.
6. Full prepared validation precedes publication; existing/protected contents require explicit replacement disposition.
7. Invalid pools/providers/arithmetic/bounds produce recovery rather than partial/default/truncated rewards.
8. Player capacity affects taking, not world loot existence; actual destination overflow has an explicit safe policy.
9. Post-publication notifications and isolated diagnostics cannot mutate/reroll live loot or duplicate additions.
10. Native compatibility/recovery retains context/results/completion without changed-table regeneration or stale-session publication.

## Contradiction review

Reviewed against approved RULE-003/026, ITEM-001–019 and MOVE-022. No direct contradiction identified. Native zero/100 semantics deliberately avoid unverified classic comment behavior. Declared level/appearance inputs satisfy earlier constructor boundaries; matrix adoption does not adopt global RNG or unchecked import. Authored/QUEST additions are distinct from random reward generation. Restock authorization and detailed supplemental distributions remain source-owner/ITEM-021 dependencies, with no automatic new-content inclusion.

## Outstanding questions

No further blocking framework player-policy choice identified. Before implementation is complete: extracted matrix/mapping fixtures and stable schemas; source-specific level/table/pool/appearance policies; supplemental distributions/recipe pools; quantity/condition/knowledge profiles; numeric/provider work bounds; protected additions/destination overflow; publication/recovery receipts and native migrations. Concrete unresolved gameplay profiles require explicit owner decisions before support is claimed. These cannot waive retained outcomes, complete validation, valid empty results or no-duplicate publication.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-020-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented baseline fixtures/schemas, source-specific profiles, supplemental distributions, generated state, bounds, protected additions/overflow, publication recovery and native migration dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
