# RULE-004 — Formula override priority

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Allow supported mod formula hooks to alter declared gameplay rules with predictable provider selection, validation and failure handling.

## Intended player experience

Players resolve competing replacements through the configured mod order before configuration locks. Valid replacements work without conflict popups. Invalid contributions identify their source and require deliberate recovery; gameplay cannot silently switch formulas after a callback fails.

## Confirmed requirements

RULE-004-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish explicit supported hooks, preflight validation, last-valid-provider replacement priority, explicit invalid-contribution recovery, same-mod replacement duplicate rejection, a run-long registry lock, declared additive composition, safe runtime failure handling and ordinary built-in defaults.

## Existing Daggerfall Unity behavior — reference only

Source: `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/Game/Formulas/FormulaHelper.cs`.

- `RegisterOverride<TDelegate>` takes a Mod provider, string formula name and callback. It checks null name/callback and whether the callback is a delegate. A strictly higher provider LoadPriority replaces the current registration; equal priority retains the existing registration.
- `TryGetOverride<TDelegate>` checks the selected callback's expected signature at invocation. On mismatch it logs the formula/provider/signatures, removes the winner and returns false so the caller uses built-in behavior. It does not restore a previously displaced valid registration.
- Most inspected formula hooks return the override result directly. `IsItemStackable` instead returns early only when its override returns true; false falls through to built-in permission rules. Thus a single registration mechanism supports differing semantic contracts.
- `CalculateAttackDamage` illustrates a top-level replacement bypassing a built-in operation with side effects. Formula extension is not inherently pure numeric calculation.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete hook inventory, executable activation and runtime mod combinations remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Explicit hook contracts

Expose a defined set of supported hooks with stable identifiers, expected inputs/output and declared replacement, extension or observation semantics. Do not assume every internal method is public or overridable. Concrete hook inventory, schema/versioning and API representation remain owner/MOD dependencies.

Each hook must document allowed inputs, output domain, mutation permissions, random-source use and failure obligations before release. This documents existing owner rules rather than authorizing arbitrary side effects. A whole-operation replacement and a numeric adjustment are different contracts; consumers cannot infer one from a method name.

### Preflight and validation

Validate hook identity, provider eligibility and callback signature before priority selection can displace a valid candidate. Unknown hooks, invalid providers and incompatible signatures fail explicitly with provider/hook context. Reject multiple registrations by the same mod for the same replacement hook. Do not use incidental registration timing to choose among them.

Build candidate registrations separately from the published registry. Invalid contributions block configuration completion even when another valid candidate could otherwise win. Explain the error and offer explicit omission of that mod's formula-hook contribution or return to configuration. Omission applies to the contribution, not arbitrary silent removal of one bad callback while retaining a partly valid set. MOD must define the contribution boundary and safe activation/rollback mechanics.

After omission, revalidate dependencies, remaining registrations and selection. If dependencies cannot be satisfied, completion remains blocked. This does not automatically disable the entire mod, unload executable code or authorize unsafe in-process retries. Safe pre-menu rebuilding and executable activation are MOD-owned requirements; where unavailable, use explicit recovery/restart rather than publish partial configuration.

### Replacement selection and defaults

For a replacement hook, select the last valid provider in resolved enabled-mod order. Use the resolved order, not callback arrival order or a second independently maintained priority scheme. Retain all relevant candidate/winner provenance for diagnostics. MOD must provide a stable resolved order before selection; unresolved ordering ambiguity cannot be hidden by whichever callback arrives first.

When no replacement is registered, use the built-in rule normally. This also applies after explicit omission and successful revalidation leaves no replacement. If omission exposes an earlier valid replacement, that replacement wins instead. Default selection and valid conflicts require diagnostics without blocking popups. A default chosen at preflight is distinct from an automatic fallback after runtime failure.

### Additive and multi-provider semantics

Each additive hook explicitly declares whether it selects one winning provider or combines multiple providers. Define combination order, baseline participation, result meaning, duplicate/provider rules and any short-circuit behavior before exposing that hook. Permission extension, numeric accumulation and observation cannot share an assumed universal combination policy.

No general callback chain, multi-provider arithmetic or universal additive priority rule is approved here. A replacement registration cannot silently become an additive contribution. Item stacking remains ITEM/RULE-025 scope; DFU's true-only extension behavior is reference evidence rather than approval of a target stacking rule.

### Lock and lifetime

Finalize and validate the registry before actual main-menu entry. Once entered, keep registrations and winning providers fixed for the application run, including returns to menu, character changes and loads. DATA-003's enabled-mod/order lock remains binding. Supported individual settings may change only under their owning rules and cannot silently replace providers or change composition membership.

Application-level registration identity is distinct from session-owned gameplay objects. Callbacks must use valid current-session/operation inputs and cannot retain ended-session references. CORE/MOD must coordinate binding, teardown and readiness. Loading cannot activate new providers or unlock configuration.

### Invocation and failure

Invoke the selected hook under its declared input/output/effect contract. If it throws or produces a detectable out-of-contract value, stop the affected operation and enter explicit owner recovery. Do not automatically try an earlier provider, remove the winner and continue, or run the built-in operation.

The callback may already have consumed randomness or mutated state. Error handling cannot assume rollback occurred. Record hook/provider and failure context without repeatedly invoking the callback to diagnose it. Owners determine whether recovery must suspend gameplay, abandon an uncommitted operation or require session/application restart under CORE rules. This feature does not approve a generic undo mechanism or continuation from partial mutations.

RULE-003 technical retries must reuse already resolved results rather than reroll. That rule does not authorize automatically retrying a failed callback whose application status is unknown. Follow owner recovery and exactly-once consequence rules.

## Relevant formulas and parameters

For replacement hook h with validated candidates V_h, winner(h) is the last candidate in resolved enabled-mod order. If V_h is empty, use the built-in rule. Invalid contributions block publication until explicit recovery and revalidation; filtering invalid candidates is not silent permission to continue.

This feature defines no gameplay formula constants, universal additive arithmetic, numeric hook domains or independent priority numbers. Those belong to each hook's approved owner contract.

## Required data

Stable hook identifier; expected signature/input/output contract; provider identity and resolved order; contribution identity; semantics/composition policy; validated registrations; selected provider or built-in designation; provenance/errors; and immutable published registry identity. Concrete version identifiers, schema and saved compatibility metadata remain MOD/SAVE dependencies.

## Inputs, outputs and events

Inputs: supported hook definitions, enabled-provider contributions, resolved order, explicit omission/reconfiguration and authorized invocations. Outputs: validated locked registry, winner/default diagnostics, invocation result or explicit preflight/runtime failure. Event/API names are unselected. Registration must not be treated as permission to execute gameplay calculations or consume live gameplay randomness during validation.

## Cross-system interactions

MOD owns package identity, dependency/order resolution, executable activation and safe registration staging. DATA-003 supplies the approved configuration lock/order model; its loose-file precedence does not automatically create executable hook providers. Domain owners declare semantics and recovery, including COMBAT/ITEM/MAGIC effects. RULE-001/002/003 retain probability, classic compatibility and source ownership rules. CORE supplies lifecycle/readiness/failure gates; DEV/UI provide provenance and recovery presentation. SAVE validates compatibility without changing the locked provider set.

## Edge cases and failure conditions

- A malformed higher-order candidate cannot displace a valid one and then disappear silently at first use; configuration remains blocked until explicit recovery.
- Same-mod replacement duplicates fail even if callbacks have identical signatures. Cross-mod valid replacements resolve by order without a popup.
- Missing/ineligible providers and unknown hook IDs are explicit errors, not successful no-ops.
- Rebuilding candidate configuration cannot leave old candidate registrations/provenance mixed into the next build. Executable side-effect cleanup must be demonstrated by MOD before permitting safe rebuild.
- A callback returning a well-typed but out-of-domain value fails when its declared contract can detect it. Validation cannot prove arbitrary executable behavior correct; required owner checks remain necessary.
- A runtime failure after a draw/mutation cannot silently trigger a fallback or second application. Missing recovery support cannot be treated as permission to continue partially functioning gameplay.
- Session changes do not replace application registry winners or permit stale references to affect a new character.

## Configuration and balancing options

Players choose enabled mods/order only within the approved editable configuration stage. Explicit omission is a deliberate invalid-contribution recovery choice with dependency revalidation. Hook exposure and supported settings are owner-defined; no universal runtime provider switch, priority slider, automatic conflict-merging system or unrestricted override of every formula is introduced.

## Save/load considerations

Load under the locked provider set; do not register saved callbacks or silently select another winner to match an old save. MOD/SAVE must define provider/content identity and compatibility checks for saves affected by changed rules. Incompatible or missing required contributions use explicit preflight recovery rather than silent defaults. This feature does not select a save schema or promise automatic migration. Persisted outcomes and pending resolved results retain their existing owner contracts; a new provider cannot reroll them by implication.

## Technical constraints

Target: Godot 4.7.2. Use stable, explicitly validated hook contracts; concrete callable/type implementation is unselected. Separate candidate resolution from published invocation state, keep provenance, and bind callbacks to valid lifetimes. A small owner-specific hook surface is sufficient; no universal rule interpreter, scripting sandbox or generic extension framework is approved. No game implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Supported hook identities/provider eligibility/signatures validate before winner selection; unknown/incompatible contributions block completion with contextual diagnostics.
2. Same-mod duplicate replacement registrations fail explicitly. Reversing callback arrival order without changing resolved mod order cannot change the winner.
3. The last valid replacement provider in resolved enabled-mod order wins; no candidates selects built-in behavior. Valid conflicts/default selection cause no blocking popup.
4. Invalid contributions require explicit omission or return to configuration; omission/rebuild revalidates dependencies and does not publish partial/stale registrations.
5. Each additive hook specifies single/multiple-provider selection, order and combination semantics before use; no universal composition is assumed.
6. Actual main-menu entry locks registrations/winners for the run; returning to menu, loading and settings changes cannot silently replace them.
7. Callback errors/out-of-contract results stop the affected operation and invoke owner recovery without automatic provider/default fallback or duplicate effects/draws.
8. Lifecycle binding rejects stale-session work and missing required dependencies under CORE recovery; executable staging/rebuild is only allowed when safe cleanup is supported.
9. Saved compatibility checks cannot silently activate providers or regenerate retained outcomes. Diagnostics identify candidates/winner and failures without rerunning gameplay callbacks.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed DATA-003, CORE-005/007 and RULE-001/002/003. Resolved mod order and the run-long lock remain binding. Explicit omission parallels deliberate invalid-contribution recovery without assuming executable unload safety. Runtime failures do not bypass retained-result, random-source or exactly-once rules. RULE-AR-02 and MOD-AR-04 remain proposals beyond the choices recorded here; individual hook inventory/semantics and executable activation are not approved automatically.

## Outstanding questions and approval

No blocking player-policy question remains for shared selection/validation behavior. Before implementation: establish supported hook inventory/versioning, concrete signatures/domains/effects, additive policies, provider/contribution identity, executable activation/cleanup, dependency/omission handling, failure recovery and save compatibility. These cannot waive explicit validation/recovery, resolved-order priority, locked selection or no automatic runtime fallback.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-004-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
