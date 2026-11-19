# RULE-002 — Classic seeded sequence

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Provide repeatable classic-compatible random sequences for explicitly designated content-generation features, without coupling them to unrelated gameplay randomness.

## Intended player experience

Features that adopt compatibility can reproduce their expected generated content from a seed and defined content/rules. Assigned persistent results remain stable across saves and updates. This does not remove RULE-001's option to reload for fresh unresolved gameplay rolls.

## Confirmed requirements

RULE-002-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm an opt-in classic generator, operation-owned state, classic valid-range mapping/draw order, explicit invalid-range rejection, reference verification, explicit 32-bit seeds, persistent assigned results and versioned reconstruction/migration.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`.

- `API/DFRandom.cs#rand` advances static unsigned 64-bit state by multiplication by 1103515245 and addition of 12345, then returns bits 16–30 as an unsigned value 0–32767. Initial state is 1.
- `Seed` exposes only the low 32 bits of state; `srand(int)` converts a signed seed to unsigned 32 bits, while `srand(uint)` directly sets it.
- `random_range` uses remainder selection for exclusive ranges; `random_range_inclusive` includes the upper endpoint. Inclusive equal bounds consume a draw and return the bound. Exclusive equal bounds divide by zero. No explicit input validation protects these helpers.
- `SaveSeed`/`RestoreSeed` use one static full-state slot; nested saves overwrite it. This is distinct from the truncated public Seed property.
- `Game/Formulas/FormulaHelper.cs#GenerateBuildingName` seeds the classic source and consumes draws according to building type, including an intentional extra draw in a macro path. The same file uses DFRandom in health growth and an enemy attack-component check. `Game/Utility/NameHelper.cs` uses it to select name parts. These observed uses do not approve their target behavior automatically.

Baseline: local DFU 1.1.1 Release snapshot, exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Original DOS parity, complete caller coverage and executable reference vectors remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Explicit compatibility scope

Retain a classic generator as a compatibility capability. Each feature owner must explicitly designate its use, seed derivation, content version, draw order and expected output. This specification does not automatically select classic generation for every DFU DFRandom caller or approve building/name mappings.

The generator reproduces the inspected DFU sequence and valid supported range mapping. Exact original-game equivalence requires separate evidence. Ordinary RULE-001 percentile checks retain their unbiased mapping and fresh-load policy; this compatibility generator is not their universal replacement.

### Seeds, sequence and operation ownership

Require an explicit unsigned 32-bit seed in 0–4294967295, including zero. Missing seeds are errors, with no implicit default, clock or frame-count seed. Legacy signed inputs require explicit adapter conversion to the corresponding unsigned 32-bit representation rather than implicit acceptance of arbitrary negative inputs.

Each classic generation operation owns its state. Given the same seed, algorithm version and draw requests, it produces the same numeric sequence across supported platforms. Given the same content/rules as well, a compatible consumer produces the same output. Generating one name must not advance combat, presentation or another operation's source. Multiple draws within one operation advance that operation normally; do not reseed before each draw.

Do not depend on DFU's global SaveSeed/RestoreSeed slot. If an owner later requires nested generation or suspension, its operation states must remain independently owned. A public checkpoint API or serialization format is not selected here.

### Range semantics

For valid supported ranges, preserve classic remainder-based selection, its slight distribution bias and logical draw order. Replacing it with rejection sampling would alter compatible results and is not permitted within a designated classic mapping. This exception does not weaken RULE-001's unbiased percentile contract.

Reject empty exclusive ranges, reversed bounds, unsupported numeric bounds/widths and arithmetic-overflow cases explicitly before drawing. Do not silently swap bounds, clamp a malformed range or substitute zero. Inclusive equal bounds are valid: consume one draw and return that bound. A single-argument exclusive range requires a valid positive maximum.

Concrete supported integer domains must be documented by the adapter and verified against DFU fixtures. The raw generator has only 32768 possible outputs; modulo selection over a wider interval cannot reach all positions. A feature requiring full coverage of larger collections must select an explicitly approved different mapping or reject unsupported content; this feature does not silently modernize the classic algorithm.

### Persistent assignment and updates

Once assigned, persistent names and other owner-designated persistent results survive saves, reloads and content updates. Retain the result or sufficient versioned reconstruction inputs to reproduce it exactly. A seed alone is insufficient if content ordering, banks, draw order or the generator changes.

Changed algorithms/content rules cannot silently regenerate established content. Use explicit version handling or migration for affected reconstruction while preserving assigned results. Missing required versions/reconstruction data invoke explicit owner/SAVE recovery, not fresh random substitution. Future generation after an update follows the owner's approved content/version policy.

RULE-001 fresh gameplay initialization after successful load does not reseed persistent identities, replace retained rewards or force classic content to change. Conversely this feature does not mandate restoring a session-wide gameplay random sequence.

## Relevant formulas and parameters

Reference transition, under explicitly defined unsigned wrap semantics:

- State S starts at the supplied 32-bit seed.
- Snext = (S × 1103515245 + 12345) mod 2^64.
- Raw draw U = (Snext >> 16) & 32767.
- Exclusive range [a,b): a + U mod (b−a).
- Inclusive range [a,b]: a + U mod (b−a+1).
- Exclusive [0,b): U mod b.

Match observable DFU draws even if an implementation uses a smaller mathematically equivalent state representation; establish equivalence with reference vectors rather than relying on host integer behavior. Low-level state representation is not a promised save format. Preserve one raw draw per valid range request, including singleton ranges. Seeds and boundaries require explicit validation before arithmetic/draws.

## Required data

Explicit seed; private operation state; algorithm/version identity; validated range request; feature-selected seed derivation and draw schedule; content/rule version where outputs depend on content; and persistent assigned output or sufficient reconstruction metadata. Stable world/entity identities are owned separately and must not be inferred from potentially duplicated generated names.

## Inputs, outputs and events

Inputs: explicit valid seed, authorized draw/range requests and consumer-owned generation context. Outputs: raw/ranged value with advanced local state, or explicit validation failure without a draw. Assignment and persistent state mutation belong to the requesting owner. No mandatory global event, gameplay effect or public checkpoint interface is introduced.

## Cross-system interactions

RULE-003 defines broader source lifetimes and stream coordination. RULE-027/LOC and DATA-017/name consumers decide whether exact classic generation is needed and define seeds/content/draw order. DATA-003 validates supported mod contributions; DATA-004/007 supply stable identity independently from generated text. SAVE retains assigned outcomes/reconstruction versions. CORE gates readiness and prevents stale operations from committing. UI/AV/DEV observations and previews cannot advance live operations or gameplay randomness.

## Edge cases and failure conditions

- Zero and maximum unsigned 32-bit seeds are valid; missing/out-of-domain seeds fail explicitly. Signed legacy conversion must be intentional and documented.
- Invalid ranges fail before state advances; equal inclusive bounds advance once. Overflow cannot turn malformed widths into usable ranges.
- Interleaving independent operations leaves each operation's sequence unchanged. Nested work cannot overwrite a shared saved-state slot.
- Duplicate names/results are permitted unless an owner explicitly defines uniqueness and its draw policy.
- Changed content ordering can change future outputs despite identical seeds; retained assignments remain stable.
- Missing required reconstruction versions/data cannot silently regenerate a different result.
- Reference compatibility does not imply every value in an arbitrary large range is reachable, nor that this generator is suitable for all gameplay probabilities.

## Configuration and balancing options

Owners may explicitly choose compatibility for their feature and define validated seed derivation, content and ranges. Classic constants, valid-range remainder mapping and raw output width are compatibility semantics, not ordinary balance knobs. Changing them requires explicit version/compatibility handling. No universal player seed control, gameplay difficulty setting, mod API or automatic uniqueness reroll is approved here.

## Save/load considerations

Persist assigned results or exact versioned reconstruction inputs under their owners. Preserve saved prepared creation/progression outcomes under existing CHAR rules. If a future owner requires resuming an unfinished generation operation, define sufficient operation state, version and exactly-once assignment through that owner's SAVE contract; universal mid-operation save support is not introduced. Missing required data follows explicit recovery. Loading must not consume unrelated gameplay draws to reconstruct content. RULE-001 still initializes future gameplay randomness afresh after successful loads.

## Technical constraints

Target: Godot 4.7.2. Keep classic compatibility arithmetic isolated and portable; do not rely on implicit signed overflow, engine-default RNG algorithms or global seed swapping. Verify logical shifts, wrap behavior and range mapping against the inspected source. Generator/content interfaces, operation identity, schemas and optimization remain engineering choices. No game implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Known explicit seeds produce matching raw sequences against reference vectors derived from the inspected DFU source, including zero and maximum seeds and sequences long enough to exercise overflow behavior.
2. Valid supported exclusive/inclusive requests match reference mapped values and draw order, including singleton ranges.
3. Invalid/missing seeds and invalid/unsupported ranges produce explicit failures; invalid range requests leave operation state unchanged.
4. Identical seed/version/request schedules match across supported platforms; matching feature outputs additionally require matching content/rules.
5. Interleaved/nested independent operations do not alter each other's sequences or gameplay/presentation randomness.
6. Each adopted feature supplies seed/draw/content fixtures before claiming compatible generated output. No unsupported DOS parity claim is made.
7. Save/load and content updates retain assigned persistent outputs; changed reconstruction requires explicit version handling/migration without silent reassignment.
8. RULE-001 gameplay reload-to-reroll behavior and previously retained CHAR rewards remain intact.
9. Supported range/collection limits and failure recovery are explicit; large collections cannot silently claim full coverage from a 15-bit modulo draw.

These are future verification criteria. Reference vectors, runtime tests and implementation have not been produced or authorized in this design interview.

## Consistency review

No direct contradiction identified with approved RULE-001, DATA-017, CHAR-006/008/015 and CORE-017. Classic modulo bias is confined to explicitly designated compatibility uses; RULE-001 remains unbiased. Stable assigned results and prepared rewards coexist with fresh unresolved gameplay rolls after load. DATA-017 preserves names across content changes, and DATA identity remains separate from generated display names. RULE-AR-01/GAD-06 remain proposals beyond the portions explicitly chosen here; full stream topology and consumer parity are not approved automatically.

## Outstanding questions and approval

No blocking player-policy question remains for this compatibility capability. Before implementation: define concrete numeric range support, reference vectors, portable state arithmetic, version schema, operation lifecycle/error interfaces and any resumable-operation persistence. Each consumer must separately approve compatibility use, seed derivation, draw order/content fixtures and update policy. These dependencies cannot waive the confirmed isolation, range validation or persistent-assignment rules.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-002-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and consumer-specific dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
