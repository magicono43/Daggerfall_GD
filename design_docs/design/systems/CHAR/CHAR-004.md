# CHAR-004 — Custom career attributes and skill tiers

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Define a custom class's display name, base attribute allocation and primary/major/minor skill assignments. Produce a coherent career draft for later character creation without applying live-player effects.

## Intended player experience

Build a personal class by redistributing a fixed attribute budget and choosing twelve distinct skills across three tiers. Return to the builder without losing work. Validated mods can change attribute allocation parameters while retaining clear limits and truthful validation.

## Confirmed requirements

CHAR-004-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish vanilla attributes/budget, validated attribute overrides, fixed distinct skill-tier counts, a nonblank Unicode display name, no automatic skill swapping and retained drafts during backtracking.

CHAR-001 still requires full draft discard on Restart/exit, no discard confirmation and Restart for class changes from final summary. CHAR-003 supplies the Custom route. DATA-003/008 govern resolved definitions and validation. CHAR-005 owns hit points, special traits, reputation choices and advancement tradeoffs; CHAR-006 owns biography selection semantics.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/UserInterfaceWindows/CreateCharCustomClass.cs`, `Setup`, uses `StatsRollout(false, true)`, creates a DFCareer and exposes twelve skill slots. The picker removes selected skills from its available list and restores a slot's former skill when replaced.
- `Game/Entities/DaggerfallStats.cs`, `SetDefaults`, starts eight attributes at 50. `Game/UserInterface/StatsRollout.cs`, free-edit spinner handlers, use 10–75 limits and adjust an allocation pool. With ordinary editing and a zero pool at completion, the original total is 400.
- `CreateCharCustomClass.ExitButton_OnMouseClick` checks name length, filled skill labels, zero allocation pool and the CHAR-005 difficulty range before accepting. The hidden `ResetButton_OnKeyboardEvent` clears the pool without restoring attributes. Intended validation explicitly excludes that bypass.
- `Game/UserInterfaceWindows/DaggerfallStartNewGameWizard.cs`, `CreateCharCustomClassWindow_OnClose`, transfers name, attributes, career and reputation and calls `API/BiogFile.cs#GetClassAffinityIndex`. That function counts skill overlap with preset careers, keeping the earliest highest result; this is reference behavior, not an approved affinity rule.
- The wizard's `SetCustomClassWindow` constructs a new builder; intended retention across ordinary backtracking is an explicit requirement rather than presumed source behavior.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Runtime cancellation, mod combinations and allocation controls have not been tested. Source remains unchanged.

## Detailed rules and behaviors

### Attribute allocation

Vanilla attributes are Strength, Intelligence, Willpower, Agility, Endurance, Personality, Speed and Luck. Each starts at 50, may be redistributed within inclusive 10–75 bounds and must collectively total 400 before acceptance. These are class base attributes; later character attribute rolls and bonus allocation remain CHAR-008 scope.

Track the remaining budget from actual current values and the resolved required total. Permit redistribution, including a temporary over-allocation balance while editing as in the inspected free-edit control, but never accept an allocation outside bounds or with a nonzero balance. Changing or resetting a displayed pool cannot make an invalid actual allocation valid. Do not expose the hidden pool-clearing bypass as a way to increase the budget.

Mods may override starting values, per-attribute minimums/maximums and required total through validated definitions. Resolve those parameters through DATA-003/008, not incidental file order. Each minimum must not exceed its maximum; every starting value must be within its bounds. The required total must lie between the sum of minima and sum of maxima. Definition consumers must also validate supported numeric ranges and downstream compatibility before publication. An in-bounds starting allocation can require redistribution if its sum differs from the configured total; final acceptance always requires exact balance.

Invalid or impossible configurations require DATA recovery/validation failure rather than silent clamping, changing the budget or falling back to vanilla. No new attribute types are authorized here; adding types requires explicit support across character rules, UI, effects and persistence. Attribute overrides do not authorize changing global runtime stat caps without the owning contract.

### Skill tiers

Require exactly three Primary, three Major and six Minor skill assignments. Each selected skill must be supported and appear in only one of the twelve slots. Remaining skills stay outside those chosen tiers under their owner rules.

Already-assigned skills are unavailable for another slot. Replacing a slot with an available skill releases its former skill; do not automatically swap assignments. Validate actual skill identities and counts, not labels or picker state alone. No new class-specific skill eligibility restrictions are introduced here.

Skill-tier counts remain fixed in this specification. Attribute mod support does not implicitly approve modifiable tier counts. Initial skill ranges, practice, advancement and level-up calculations remain CHAR-009/012–015 and related owner rules; class creation must pass tier identity without inventing those formulas.

### Name and draft lifetime

Require a nonblank custom-class name, allowing spaces and Unicode text. Whitespace-only input cannot satisfy the requirement. Names need not be unique against presets or other custom classes. Keep stable internal class/draft identity distinct from display text; renaming cannot change which definition or draft is selected. Exact text-length, normalization and rendering contracts remain UI/DATA technical dependencies.

Keep name, attributes, skill choices and CHAR-005 selections while returning through ordinary creation backtracking. Preserve the draft separately from the preset class definitions and live player. Returning from nested trait/reputation panels must not reset the chassis. Selecting a preset cannot inherit stale custom traits; retaining a custom draft for navigation does not apply it to another career.

Restart or leaving creation clears the entire draft under CHAR-001, without discard confirmation. This is not persistent class-template storage or unfinished-draft resumption across launches. From final summary, changing class still requires Restart.

### Acceptance and handoff

Accept only a nonblank name, valid resolved attribute configuration, balanced in-range allocation, twelve distinct valid tier assignments and valid CHAR-005 results. Show actionable field/section errors for invalid input. Validation belongs to the authoritative creation rules and must apply regardless of which UI submitted the draft.

Pass the completed custom career and its custom identity to the next creation stage. Biography affinity/mapping requires the explicit CHAR-006 rule under DATA-008; do not silently select the first preset on a missing match. Browsing, editing and acceptance do not grant starting items, spells or biography effects; CORE-012 and owners apply initialization once.

## Relevant formulas and parameters

- Vanilla: eight attributes; initial value 50 each; inclusive minimum 10 and maximum 75; total T = 400.
- Remaining budget B = T − sum(current base attributes). Accept only B = 0 and min_i ≤ value_i ≤ max_i for every attribute.
- Configuration feasibility: sum(min_i) ≤ T ≤ sum(max_i), with valid supported bounds and starting values. Validity also requires downstream owner compatibility.
- Tier counts: Primary = 3, Major = 3, Minor = 6; distinct assigned skills = 12.

These do not define advancement multipliers, health gains, later rolls or biography affinity scores.

## Required data

Resolved attribute starting/minimum/maximum values and total, actual allocation, supported skill IDs and twelve tier slots, class display name and separate internal identity, CHAR-005 candidate/results and validation state. Preserve source provenance/version context sufficient for diagnostics and owner compatibility. Exact schemas remain implementation dependencies.

## Inputs, outputs and events

Inputs: Custom entry, name edits, attribute adjustments, skill-slot selections, CHAR-005 edits/results, Back/Next, Restart/exit and resolved content. Outputs: retained isolated draft, allocation balance, available-skill set, actionable errors or validated custom-career handoff. These are conceptual contracts, not approved API/signal names.

## Cross-system interactions

CHAR-001 owns creation navigation/discard; CHAR-003 supplies Custom entry. CHAR-005 owns special traits/HP/reputation and advancement legality. CHAR-006 determines custom biography selection. CHAR-008/009 consume base attributes/tiers for later rolls. Progression owners consume tier assignments; DATA-003/008 resolve and validate overrides; UI presents controls/errors; CORE-007/011/012 coordinate completed entry and grants; SAVE owns durable completed-character state.

## Edge cases and failure conditions

- Empty or whitespace-only names, incomplete/duplicate skills, invalid bounds, wrong totals and invalid CHAR-005 results block completion.
- UI pool edits, hidden shortcuts, repeated clicks and cached labels cannot bypass validation of actual values/IDs.
- A localized skill name collision must not merge distinct identities or allow duplicate IDs.
- Mod budgets can be feasible yet incompatible with later stat rules; do not announce usable configuration before required compatibility validation.
- Replacing skills releases only the prior slot value and never duplicates or automatically moves another assignment.
- Backtracking retains work; Restart/exit remove it, including cached custom traits. Draft previews cannot mutate live players or preset definitions.
- A missing biography mapping is an explicit owner failure, not permission to select an arbitrary preset.

## Configuration and balancing options

Attribute starts, per-attribute limits and required total are mod-configurable as approved; vanilla defaults remain the initial balance. There is no approved unlimited-budget mode, runtime content reload, new attribute type or variable tier-count option. Mod precedence and configuration locking follow DATA-003. CHAR-005 balance remains separately reviewed.

## Save/load considerations

Unfinished drafts are transient under CHAR-001. Completed characters must preserve their actual custom career, attributes, tier identities and relevant resolved-definition context through SAVE; later loading must not reconstruct the career from its display name or rerun generation. Compatibility with changed/missing mod definitions requires explicit SAVE/DATA policy, not silent replacement or clamping. Original content and existing saves remain unchanged.

## Technical constraints

Target: Godot 4.7.2. Keep class draft, shared definitions, rule validation and UI state distinct. Use stable skill/attribute identity and arithmetic that validates totals safely. Avoid accepting UI labels, mutable pool displays or localized names as authoritative state. Concrete representation, APIs, widgets and schema numeric ranges remain engineering decisions; original source remains read-only.

## Acceptance criteria

1. Vanilla defaults start all eight attributes at 50; valid redistribution stays within 10–75 and totals 400 at acceptance.
2. Validated mod starting values, bounds and total are respected consistently by controls, display and final validation. Impossible or incompatible configurations cannot silently fall back or pass.
3. Pool-clearing/forged UI state cannot accept an allocation whose actual values violate the resolved rules.
4. Exactly 3/3/6 valid distinct skills are required. Already-assigned skills are unavailable elsewhere; replacing a slot releases its old value without automatic swapping.
5. Nonblank Unicode class names with spaces are accepted, including duplicate display names; whitespace-only names fail. Internal identities remain distinct.
6. Ordinary backtracking retains chassis and CHAR-005 choices; Restart/exit discard all draft state without confirmation. Final-summary restrictions remain CHAR-001 compliant.
7. Invalid chassis or CHAR-005 state produces actionable errors and cannot reach completed-career handoff.
8. Editing/acceptance does not mutate live characters or shared presets, duplicate grants or silently invent biography affinity.
9. Completed saves preserve custom-career identity/values without name-based reconstruction or generation reruns.

These are future verification criteria; no implementation or runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-001–003, DATA-003/008 and relevant CORE-007/011/012 constraints, plus the character architecture review. No direct contradiction identified. Attribute modability is explicitly scoped; fixed tier counts are not broadened by implication. Backtracking retention deliberately improves on the inspected builder reconstruction. Draft retention does not override full Restart/exit discard or DATA configuration locking. Custom biography mapping and CHAR-005 balance remain separate owner decisions.

## Outstanding questions and approval

No further blocking chassis-policy question is identified. Before implementation is complete: finalize override schemas/numeric compatibility; confirm UI name-length/Unicode handling; complete CHAR-005 legality and CHAR-006 affinity; define downstream stat/skill and SAVE compatibility contracts. These dependencies cannot waive exact total/distinct-skill validation or authorize hidden budget bypasses.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-004-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented CHAR-005/006, schema/UI and save-compatibility dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
