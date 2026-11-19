# RULE-025 — Stack eligibility

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Determine whether a valid item may participate in stacking through explicit moddable policies, without conflating eligibility with pairwise compatibility or inventory mutation.

## Intended player experience

Ordinary consumables/currency and other declared categories stack when compatible. Special items retain important state instead of losing identity through accidental merging. Mods can enable or disable eligibility with clear reasons; loading changed policies cannot silently lose quantities.

## Confirmed requirements

RULE-025-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) approve moddable defaults/exclusions, bidirectional template/type policies, separate compatibility, category→template→instance precedence, explicit saved-stack migration and pure explainable queries.

RULE-004/DATA-003 govern validated locked providers/definitions. ITEM-005 owns matching/insertion/splitting/limits/UIDs/quantity conservation; eligibility does not approve those mechanics automatically.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Formulas/FormulaHelper.cs#IsItemStackable` permits ingredients, potions, books, gold pieces, arrows and oil. Its override returns early only for true; false falls through to built-in categories.
- `Game/Items/DaggerfallUnityItem.cs#IsStackable` first excludes summoned nonarrows, then equipped/quest/enchanted items, before calling the helper. Source comments say summoned arrows should only stack together.
- `Game/Items/ItemCollection.cs#FindExistingStack` separately compares group/template index, message, potion recipe key and disappearance time and requires both items stackable. `AddItem` adds counts unless noStack requested; `SplitStack` and duplicate UID handling are separate paths. The source notes maximum stack limits as TODO.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; exhaustive mutable-state compatibility, runtime stack safety and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Policy resolution

Resolve type/category eligibility defaults, then explicit template eligibility overrides, then applicable instance-state restrictions. Preserve default allow categories: ingredients, potions, books, gold, arrows and oil. Other categories are ineligible unless supported policy enables them. A valid item outside the allow set differs from an item with missing required identity/definitions.

Allow explicit true/false template/type policies so mods can disable built-in eligible categories as well as add new ones. Use stable IDs and validated category/template mappings; display names or loose array positions are not policy identity. Conflicts among contributing definitions/providers follow DATA-003/RULE-004; callback registration timing cannot invent a precedence layer.

The defined precedence describes semantic layers, not unrestricted execution order of arbitrary hooks. Each supported hook declares its layer, inputs, replacement/additive meaning and output validation before exposure. A template override can change category eligibility but does not implicitly replace instance restrictions.

### Instance-state restrictions

Default deny equipped, quest and enchanted items. Summoned nonarrows are ineligible; summoned arrows are the supported default exception to that summoned restriction, while still subject to other restrictions and compatibility.

Restrictions are moddable only through explicit supported contracts. Enabling stacking for equipped/quest/enchanted or other special items requires ITEM to define how relevant charges, effects, condition, ownership, provenance and identity are preserved. Merely setting template eligible=true is insufficient and cannot discard unique state. Invalid/incomplete alternative contracts fail validation rather than silently enabling unsafe stacks.

No new permanent ban on those mod use cases is introduced: the extension must be possible when its owner supplies complete supported semantics. This feature does not approve a universal enchanted-item stack representation or quest identity merger.

### Eligibility versus pair compatibility

An eligible item may participate in a compatible stack, but two eligible items do not automatically merge. ITEM-005 separately validates relevant instance equality/merge semantics. Template/category equality alone cannot prove compatibility.

Summoned arrows cannot merge with ordinary arrows or with incompatible expiry/provenance. Potions/books and other types need their own relevant state keys rather than a universal template-only match. The source's message/recipe/expiry comparisons are evidence, not an exhaustive approved compatibility schema. Condition/charges/identification/custom data and added-type fields must be considered by their owner before safe merging is implemented.

Stack eligibility does not set a stack cap, choose a destination, combine counts, split items, assign a UID, transfer inventory, authorize use or permit equipping a stack. Those are ITEM action contracts. Explicit no-stack insertion can retain separate compatible entries where the owner supports it; exact UI controls are not selected here.

### Query behavior and lifecycle

Return eligible/ineligible with inspectable reason and policy provenance, or a distinct invalid-state/definition error. Queries are deterministic and side-effect-free. They do not consume randomness, allocate rewards, alter counts, repair definitions or migrate existing items.

Changing valid instance state such as equipment/quest/enchantment applicability changes subsequent eligibility queries under the resolved policy. The item operation that changes state must preserve quantity and handle any necessary split/revalidation explicitly under ITEM; a getter cannot silently split/merge a stack to make state legal.

DATA-003's run-long content lock remains binding; this feature does not add hot reload. Supported mod settings changing eligibility need an explicit owner lifecycle/migration contract rather than immediate destructive query-time repair.

### Persistence and changed policy

Preserve authoritative quantities and required item state on load. If a changed policy makes an existing saved stack invalid, require explicit ITEM/SAVE migration/recovery. Do not silently delete excess, merge unlike items, split identities or make saved quantity one simply because eligibility is now false.

Migration must preserve supported quantity/state/identity obligations and explain incompatibility where safe conversion is unavailable. Exact conversion, maximum counts, UID rules and save versioning remain ITEM-005/SAVE dependencies. Querying an old stack does not itself authorize migration.

## Relevant formulas and parameters

Conceptually E=resolved instance restrictions applied to explicit template override, otherwise type/category default. Both allow and deny are meaningful policy values; missing data is not false by default when a required definition is absent.

Merge permission additionally requires ITEM-005 compatibility and valid collection operation. No quantity arithmetic or numerical stack limit is approved here. Gold eligibility does not automatically equate an inventory entry with bank/currency balance representation.

## Required data

Stable item/template/type/category identity; equipped/quest/enchantment/summoned state; eligibility definitions and provenance; explicit supported restriction overrides; owner-required compatibility/unique-state context; saved quantities and migration metadata. Concrete policy/schema/reason identifiers remain dependencies.

## Inputs, outputs and events

Inputs: valid item state and resolved locked policy. Outputs: explained eligibility or explicit error. No mutation/event/stack operation is performed by querying. ITEM owns state changes/notifications and collection APIs; concrete names remain unselected.

## Cross-system interactions

ITEM-005 owns compatibility/insertion/split/merge/counts; ITEM equipment/use/quest item owners manage state transitions. MAGIC supplies enchantment/summon/expiry semantics; QUEST provenance; DATA stable templates/validated contributions. RULE-004/DATA-003 govern hooks/locking; SAVE explicit migrations. ECON/theft/weight consumers must not equate fewer collection entries with fewer units without their own contracts. UI/DEV inspect reasons without mutation.

## Edge cases and failure conditions

- Two identical-looking items can be incompatible; type permission cannot erase custom state.
- A summoned arrow exception does not override equipped/quest/enchanted denial by accident.
- Explicit template deny beats category allow; category/template allow still passes instance restrictions unless explicitly replaced.
- Invalid IDs, missing required definitions or failed hooks are errors, not successful false/true fallbacks.
- Existing stacked special items and changed policies require explicit transition/migration rather than silent quantity loss.

## Configuration and balancing options

Support type/category/template allow/deny and explicitly scoped state-restriction replacements through validated schemas/hooks. Added item types require eligibility plus complete compatibility/collection contracts. No universal stack size, automatic weight/value compression, quest deduplication or currency conversion is introduced.

## Save/load considerations

Restore authoritative item/quantity/source state and rebuild eligibility without mutating stacks. Changed required policies or incompatible unique-state representation use explicit migration/recovery. Duplicate reconstruction cannot multiply counts or merge unrelated UIDs. Missing required mod definitions cannot silently become ordinary eligible items or discarded stacks. Atomic collection persistence remains ITEM/SAVE scope.

## Technical constraints

Target: Godot 4.7.2. Separate pure explained eligibility from pairwise matching and collection mutation. Use stable IDs, declared precedence and safe owner-controlled quantity transitions. Interfaces/schema/UID widths remain dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Vanilla categories and state exclusions/summoned-arrow exception match baseline through explicit policies.
2. Type/template mods can enable or disable; template permission cannot accidentally bypass instance restrictions.
3. Explicit restriction overrides require complete validated owner contracts rather than discard unique state.
4. Eligibility never substitutes for pairwise compatibility; summoned/ordinary/incompatible-expiry arrows remain separate.
5. Queries expose reasons/provenance/errors without randomness/count/state mutation or transfer authorization.
6. Saved quantity/state survives restoration or explicit migration; no query-time silent deletion/split/merge occurs.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed RULE-004, DATA-003 and the separation in ITEM-005 analysis. Bidirectional mod policies intentionally differ from DFU permission-only fallback. Collection-entry versus unit counts remain distinct for RULE-010/021 consumers; eligibility does not silently normalize their baskets. Save/migration safeguards preserve unique state rather than assume source matching fields are exhaustive.

## Outstanding questions and approval

No blocking eligibility-policy question remains. Before implementation: finalize stable policy/reason/hook schemas, added-type compatibility, state-transition/split rules, quantity/UID/limits and SAVE migrations under ITEM-005. These cannot waive both-direction modding, precedence, pure queries or unique-state/quantity preservation.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-025-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented ITEM-005 compatibility/quantity and SAVE migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
