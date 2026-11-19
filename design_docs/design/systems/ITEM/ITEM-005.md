# ITEM-005 — Stack matching and insertion

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-10: “I approve”.
Updated: 2026-11-10.

## Gameplay purpose

Combine interchangeable items conveniently while preserving quantities, meaningful state, identity and authoritative custody.

## Intended player experience

Compatible possessions combine predictably without losing special contents, appearance or knowledge. Invalid insertion leaves possessions intact. Sorting, retries and loading cannot duplicate quantities, erase distinctions or reroll state.

## Confirmed requirements

- **ITEM-005-D01:** Merge only when both items are eligible and relevant gameplay state, contents, knowledge, expiry and provenance are compatible. Differences cannot be averaged, discarded or replaced by destination state. Custom types declare complete compatibility rules; unknown required state prevents merging.
- **ITEM-005-D02:** Validate identity, custody, quantity and request validity before any quantity change. Accidental insertion of an already-present item cannot increase quantity. Distinct objects claiming one identity fail explicitly.
- **ITEM-005-D03:** Return explicit inserted-separately, merged or rejected outcomes with surviving identity and quantity changes. Failure preserves original items/counts. Explicit no-stack insertion remains supported without bypassing identity/ownership validation.
- **ITEM-005-D04:** No gameplay stack cap by default. Explicit per-type/template caps are supported for mods/chosen balance rules. Quantities remain within validated numeric bounds; overflow rejects without changing counts.
- **ITEM-005-D05:** Automatic insertion selects among compatible stacks deterministically by stable item identity. Explicit destination requests are validated. Inventory sorting cannot change which stack survives.
- **ITEM-005-D06:** Different persistent styles/dyes remain separate unless the type explicitly supports preserving those differences within a stack. Wearer-dependent rendering alone does not make otherwise identical items incompatible.
- **ITEM-005-D07:** Automatic capped insertion fills compatible stacks in stable-identity order then creates separate capped stacks for the remainder. Validate the complete plan before mutation; inability to complete rejects the whole insertion. Splitting preserves ITEM-001 identity rules.
- **ITEM-005-D08:** An explicit single-destination request merges the entire requested quantity there or rejects. It cannot silently distribute elsewhere. Automatic distribution is a separate request mode.
- **ITEM-005-D09:** Load preserves distinct saved stacks without automatic merging. Unsupported saved stacks after cap/eligibility/compatibility changes require explicit migration/recovery preserving quantity and meaningful state; no silent truncation, discard or reinterpretation.
- **ITEM-005-D10:** Quantities are positive whole numbers. Zero, negative, fractional, out-of-range and over-available requests reject without mutation. Last-unit consumption removes/retires the stack; no zero-count live stacks. Detailed consumption remains ITEM-006.
- **ITEM-005-D11:** No-stack means no merging with existing entries, not cap bypass. Over-cap quantities become separate capped entries through all-or-nothing validation.
- **ITEM-005-D12:** Stacking cannot bypass weight, entry limits, access or custody. Transfer/grant owners validate admission against the planned result. Stacking itself compresses neither total weight nor value; special container effects require explicit external rules.

The user confirmed each of four interviews with “1. Yes / 2. Yes / 3. Yes”. See [the decision log](../../GAMEPLAY_DECISIONS.md).

## Existing Daggerfall Unity behavior — reference only

Sources relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Items/ItemCollection.cs#FindExistingStack` checks both items' eligibility, group/index, message, potion recipe key and disappearance time, returning the first matching entry.
- `AddItem` merges counts unless noStack is requested; otherwise inserts by UID/position. Duplicate UID validation occurs only on the nonmerge path. It returns void and lists maximum stack limits as TODO.
- `Game/Formulas/FormulaHelper.cs#IsItemStackable` and `DaggerfallUnityItem.cs#IsStackable` supply separate eligibility checks. Source matching fields are not an exhaustive target compatibility schema.

Static inspection of local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). No runtime/classic-parity verification; reference source unchanged.

## Existing approved constraints

RULE-025 owns moddable eligibility defaults/exclusions, pure queries and explicit saved-stack compatibility. ITEM-001 owns per-stack identity, destination survival/source retirement on merge, deliberate reference updates and custody/session safety. ITEM-002–004 require preservation of custom state, material/appearance and actual magic/potion/soul contents. Eligibility alone never proves pair compatibility. Unsafe referenced stacks remain separate; special-type restriction overrides require complete supported contracts, not a blanket permanent ban.

## Detailed rules and behaviors

### Eligibility and pair compatibility

First apply approved RULE-025 category/template/instance eligibility, including default restrictions and supported complete overrides. Both items must qualify. Eligibility is not permission to merge every item of the same type.

Use stable template identity and owner-defined compatibility for actual contents, provider/state versions, condition/resources, identification/knowledge, expiry, provenance and relevant bindings. Preserve persistent style/dye distinctions unless a validated type explicitly retains them within the stack. Wearer-dependent rendering alone is not a persistent distinction.

Do not average condition, reset cooldowns, replace potion/enchantment payloads, extend expiry, reveal hidden knowledge or discard provenance by copying destination state. Unknown required custom state prevents merging. Complete supported custom representations can preserve differing state only through explicit validated contracts; a blanket eligible flag is insufficient. Unsafe quest/effect/reference bindings remain separate under ITEM-001/RULE-025.

Summoned and ordinary arrows remain separate, as do incompatible expiry/provenance groups. Retain COMBAT-008 ammo payload and per-shot provenance obligations. Potion/recipe keys alone cannot establish equal actual contents after content changes. Book/content, oil and other categories require their own complete compatibility keys.

Compatibility queries are pure and explainable: no item mutation, randomness, automatic merging or access authorization. Source message/recipe/expiry comparisons are evidence, not an exhaustive schema.

### Admission and planning

Validate item identity, active context, custody/access, positive integral quantities and availability before mutation or stack search can cause a merge. Self/repeated insertion cannot increase quantity; distinct items claiming one identity fail explicitly. Normal item references to one authoritative item are not additional possessions. Retry handling must return retained outcomes or reject rather than repeat committed counts.

No default gameplay cap is imposed. Supported explicit type/template caps must be valid positive integral limits with deterministic resolved policy. Numeric representation bounds still apply. Validate counts and arithmetic before commitment; overflow rejects without mutation, never wraps or truncates. No particular integer width is selected.

Transfer/grant owners validate destination admission against the entire planned result, including weight, entry limits and access. Stacking grants no capacity bypass and no implicit reduction of total weight/value. Exact capacity exceptions, paid grants and custody transfer APIs remain their owners' contracts.

### Insertion modes

- **Automatic:** select compatible accepting stacks in stable item-identity order, independent of UI sorting or collection iteration. Fill their available capacity, then create separate capped entries for any remainder. Uncapped mode is still bounded by validated numeric limits; arithmetic overflow is rejection rather than implicit spill to evade the numeric bound.
- **Explicit destination:** validate the requested stack and merge the whole requested quantity there, or reject. No silent retargeting/distribution if incompatible, full or invalid.
- **No-stack:** do not merge into existing entries. Insert separately, splitting over-cap quantities into separate capped entries through the same complete-plan validation. This does not bypass eligibility representation, identity, custody or numeric bounds.

Validate the full plan before changing quantities/custody. If any required part cannot complete, reject the whole insertion with original items/counts intact. Implementation must ensure a failure cannot leave a partially applied multi-stack plan; concrete staging/commit/recovery design remains open. This is not authorization for arbitrary external side effects inside insertion.

### Identity, references and results

Follow ITEM-001: merging retains each destination identity and retires a source identity when that source is fully merged away. Partial splits preserve the original on its remainder and allocate fresh identities for separated quantities; full-stack movement preserves identity. A multi-destination plan must express these steps and resulting identities coherently rather than duplicating the incoming identity across entries. Detailed split mechanics remain ITEM-006.

Existing references stay with the original stack on split. Retired-source references never silently alias to a destination. Report all changed/surviving/new/retired identities and quantities as applicable, so callers deliberately adopt valid resulting references. If a caller needs one destination, use explicit-destination mode rather than assuming automatic distribution produces a single survivor. Historical released-effect/ammo attribution remains governed by its owner, without resurrecting retired items.

Return inserted-separately, merged, a combined insertion/distribution outcome where applicable, or rejected, with complete quantity changes and identities. The combined case reports both already approved insertion behaviors, not a partial-success permission. Failure leaves the original items/counts unchanged. Notifications describe committed facts and cannot repeat insertion.

## Relevant formulas and parameters

For a successful insertion, total participating quantity before equals total participating quantity after. For a capped compatible destination, available space = cap − current count and planned merge = min(remaining input, available space), using validated arithmetic and stable destination order. Fresh entries receive at most their resolved cap. All live counts and caps are positive integers. No default gameplay cap, numeric width, maximum entry count or capacity formula is introduced. Out-of-range arithmetic rejects before mutation.

## Required data

Stable template/item/session/operation identities; custody and available quantities; resolved eligibility/compatibility policies with reasons/provenance; owner-required contents/state/knowledge/style/expiry/bindings; resolved caps/numeric bounds; requested mode/destination; complete planned count/identity/custody changes; admission and retained operation results. Exact schemas remain integration dependencies.

## Inputs, outputs and events

Inputs: validated item insertion/merge request, mode/optional destination, authorized context, current collection and resolved policies. Outputs: pure compatibility explanations, complete committed insertion result or explicit identity/quantity/access/compatibility/capacity/overflow rejection. Committed notifications do not authorize observers to repeat count changes. Concrete APIs/signals and recovery receipts are unselected.

## Cross-system interactions

RULE-025 governs eligibility; DATA/MOD/RULE-004 govern validated locked definitions/providers and policy resolution. ITEM-001 governs identity/custody/session/reference safety; ITEM-002–004 provide custom/material/magic content preservation. ITEM-006 owns split/removal mechanics, ITEM-007 transfers and ITEM-008/009 relevant collection capacity/currency integration. COMBAT-008 and MAGIC owners require retained ammo/source/expiry and contents. UI sorting cannot select authoritative destinations. SAVE/ITEM-025 restore coherent stacks and handle migration; exact integrations remain open.

## Edge cases and failure conditions

- Same item inserted twice or source aliases destination: cannot multiply quantity.
- Distinct objects share identity: explicit failure before merge, not silent renumbering.
- Same template with different potion payload/knowledge/dye/condition/expiry: remain separate unless an explicit complete contract preserves distinctions.
- Full/incompatible explicit destination: reject, do not choose another stack.
- Capped automatic plan needs new entries but admission fails: reject whole insertion without partial fill.
- No-stack over cap: plan separate capped entries; reject whole plan if unsupported or admission fails.
- Numeric overflow or invalid amount: reject unchanged, never wrap/truncate.
- Last-unit consumption: remove/retire under ITEM-006, no zero-count live entry.
- Changed eligibility/cap/state representation on load: explicit migration/recovery preserving quantity and state.

## Configuration and balancing options

No gameplay cap by default; supported type/template caps and validated compatibility policies are configurable under locked content rules. Special-type stacking remains extensible with complete state/identity preservation contracts. No UI control, automatic restacking service, overflow deletion, weight compression or cap bypass is approved. Persistent cosmetic differences remain meaningful unless explicitly preserved by a supported type representation.

## Save/load considerations

Restore distinct saved stacks without automatic merging or fresh identities. Preserve quantities, actual contents, knowledge, resources, bindings, style and expiry/provenance. Do not mutate stacks merely by querying new eligibility. Changed caps/eligibility/compatibility may require explicit migration or recovery, never truncation, deletion or silent reinterpretation. A saved oversized/unsupported stack is not permission to ignore its incompatibility or to split it silently during lookup.

Persist coherent committed insertion/custody and sufficient retained operation facts to prevent retry duplication. Unsupported partial mutation must not be exposed as a normal successful save. Exact admission/partial-operation persistence and migration protocols remain SAVE/owner work under existing ITEM-002/CORE rules. New sessions invalidate old callbacks; reconstructing displays cannot merge or repeat grants.

## Technical constraints

Target Godot 4.7.2. Separate pure eligibility/pair queries, deterministic planning, owner admission and authoritative commitment. Stable identity ordering needs an explicit representation-independent comparison contract before implementation. Do not use engine handles, display order or raw legacy list indexes as authoritative identity. Complete all-or-nothing multi-entry updates without mandating a generalized transaction framework. Reference source unchanged; no implementation/coding tasks authorized.

## Acceptance criteria

1. Eligible compatible items merge without losing gameplay/content/knowledge/expiry/provenance or unsupported cosmetic distinctions; unknown required state prevents merge.
2. Identity/custody/quantity checks precede changes; repeated/self insertion and duplicate identities cannot inflate counts.
3. No default gameplay cap; configured caps apply, and numeric overflow/invalid quantities reject unchanged.
4. Automatic distribution uses stable identity order, fills compatible capacity then creates capped remainder entries; UI sorting does not change survivors.
5. Explicit destination accepts the whole requested amount there or rejects without retargeting.
6. No-stack preserves separation while respecting caps and admission; inability to complete any plan leaves all items/counts unchanged.
7. Successful results conserve quantity and report every relevant surviving/new/retired identity and count change, without silent reference redirection.
8. Weight/access/custody/entry restrictions remain enforced against the planned result; stacking does not compress weight/value.
9. Restore preserves distinct stacks; changed rules require explicit quantity/state-preserving migration/recovery, not automatic merge/truncation/discard.
10. Last-unit removal retires the stack, and retries/load/observer notifications cannot duplicate counts or replay insertion.

## Contradiction review

Reviewed against approved RULE-025 and ITEM-001–004, with COMBAT-008 ammo constraints. No direct contradiction identified. Eligibility remains separate from pair compatibility and mutation. Supported special-item stacking still requires complete contracts rather than a permanent ban. Multi-destination results refine ITEM-001's survivor reporting without silent aliasing; ITEM-006 must implement its approved split identity rules. Loading preserves distinct records and changes require migration, consistent with prior native compatibility rules. No broader architecture proposal or future feature is finalized here.

## Outstanding questions

No further blocking player-policy choice identified. Before implementation is complete: exhaustive per-type compatibility/state schemas and special-item representations; stable-ID comparator and numeric/cap policy schemas; multi-destination split/identity receipts; whole-plan admission/commit/retry guarantees; capacity/custody integration; migration and native persistence fixtures. These dependencies cannot waive quantity conservation, state preservation, whole-plan rejection or explicit reference handling.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-10 with “I approve”. Approval reference: ITEM-005-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented per-type compatibility, numeric/cap and identity schemas, multi-destination receipts, whole-plan commitment/retry, admission/custody and native migration/persistence dependencies remain open. Approval does not automatically initiate implementation, coding tasks or another feature review.
