# DATA-024 — World-data replacement and variants

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Supply validated alternate world records and explicit scoped variant resolution for location assembly, while keeping session selection, transitions and restoration under their authoritative owners.

## Intended player experience

World variants consistently affect the intended place and preserve character isolation. Supported in-game changes use safe transitions rather than exposing partial geometry. Saves restore the selected layout before placement, and missing required variants do not silently substitute another world state.

## Confirmed requirements

DATA-024-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish separate definitions/session selections; stable explicit scoped identity; restore-before-reconstruction; validated gated runtime transitions among installed variants; separate definition/scope precedence; and explicit validated baseline reset rather than missing-data reset.

## Existing Daggerfall Unity behavior — reference only

Paths below are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Utility/AssetInjection/WorldDataReplacement.cs` resolves replacement/additional location, block and building data, with filename/index conventions and caches. Some new-location variant load failure can fall back to nonvariant data in that path.
- `Utility/AssetInjection/WorldDataVariants.cs` stores selected location/block/building variants. Several lookups depend on mutable lastLocationKey, while explicit-context overloads also exist. General and location-scoped selections coexist.
- Variant setters clear RMB layout cache. SetLocationVariant's return convention differs from its documented new-selection meaning and other setters; a boolean alone is not a reliable target transition result.
- `Game/Serialization/SaveLoadManager.cs#LoadGame` restores WorldVariationData before RestorePositionHelper. Its exception path warns/logs and attempts continuation without variants. That is not the intended required-variant policy here.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Complete resolution ordering, missing-sidecar state isolation and runtime geometry/quest behavior were not fixture-tested. Source remains unchanged.

## Detailed rules and behaviors

### Definitions, selection and identity

Installed replacement/variant definitions are reusable content resolved and validated by DATA. WORLD/LOC own each session's selected variants and changes; SAVE persists required selections. Character/session replacement must not inherit prior-character selection state. Reading definitions or resolving a query does not itself change selection.

Use stable variant IDs with explicit location, block-placement and building-record context under DATA-004/005. Definition identity, target placement identity and selected variant remain distinguishable. No lookup depends on which location was queried last. Repeated placements may select independently where declared scope permits; this does not require every variant schema to support every possible scope.

Legacy region/index/block-name conventions require explicit mappings rather than becoming durable target identities by accident. A stable variant ID alone does not prove layout/record compatibility after a definition change.

### Definition precedence and selection scope

DATA-003 decides the winning definition for an explicit logical variant target using declared operations, precedence and provenance. Its contribution validation and explicit recovery remain binding. Installed definitions lock at actual main-menu entry; changing selected runtime state is distinct from changing those definitions or mod order.

For an applicable target, explicit placement-specific selection overrides a declared location-wide/global default. Exact specificity among supported location/global scopes and combinations must be documented by WORLD/LOC. Do not infer arbitrary cross-level layout merging: incompatible overlapping changes fail validation. A building selection cannot silently repair or replace incompatible records removed by a containing block/location variant.

Baseline/default is a declared resolution outcome, not a synonym for missing content. Detailed block/location/building schemas must define supported targeting, required references and combination rules before implementation is complete.

### Runtime transitions

WORLD/LOC may select among already installed, validated variants during play through an explicit transition operation. Validate proposed geometry, player placement, quest bindings and persistent object state before declaring success. Gate affected gameplay during reconstruction and publish readiness only when required owner work completes under CORE lifecycle/transition contracts.

This does not require complete eager construction of every alternative at startup, nor promise a universal rollback engine. Owners must define preflight versus post-replacement failure and safe recovery. Do not resume partial world state or report success merely because a selection dictionary changed or a cache was cleared.

Use explicit source/target context and operation identity for deferred work so stale completions cannot apply to another session or newer transition. Invalidate/rebuild affected definition/layout/resource caches coherently; retain unrelated reusable content where safe. Exact transition API, cancellation, persistence timing and simulation coverage remain WORLD/LOC/CORE dependencies.

### Restore and compatibility

Validate and restore required saved variant selections before constructing affected geometry, binding quest resources or placing the player. Restore early world context/selection before dependent reconstruction, then rebuild and validate owner references under SAVE/LOC/QUEST contracts. Loading cannot adopt a previous session's selections when saved state is missing or invalid.

Missing or incompatible required variants need explicit supported migration or load failure; do not continue silently with a different layout. Package disappearance and changed records remain compatibility problems even when a stable location/variant ID is unchanged. DATA-005's explicit record mapping/migration policy applies rather than guessed proximity or model matching.

Exact legacy-save representation and absence semantics must be versioned: a declared baseline selection is distinct from missing required selection data. Optional selection loss may use only an explicitly approved owner policy; none is invented here. This feature does not approve classic/DFU save import.

### Explicit clearing

Returning to baseline/default is an explicit validated transition accounting for saved objects, quest references and player placement. It uses the same required readiness/failure principles as any variant change. Missing selected content never becomes an implicit request to clear it. Removing an override/default may expose another applicable default under the declared scope contract; exact reset semantics must be documented rather than inferred from empty strings or dictionary deletion.

## Relevant formulas and parameters

No fixed numeric variant key, reset sentinel, transition timeout or universal scope-merge formula is approved. Stable identity/context, declared specificity and validated compatibility determine resolution. DFU's empty-string/-8 conventions are reference details, not required target formats.

## Required data

Stable variant and target identities; source/package/version provenance; explicit supported scopes and defaults; validated alternate records/reference requirements; session-selected variants; transition source/target and operation context; affected cache/layout context; saved selection and compatibility metadata. Complete schemas, specificity/reset behavior and persistence representation remain dependencies.

## Inputs, outputs and events

Inputs: active resolved definitions, explicit scoped queries, owner selection/reset requests, saved selections and geometry/quest/placement/state validation results. Outputs: resolved alternate records, proposed/committed selection outcomes or explicit missing/invalid/incompatible failure. These are conceptual contracts, not APIs/signals. Definition resolution, selection mutation, geometry ready, placement ready and completed transition are distinct milestones.

## Cross-system interactions

- DATA-001/002 retain source/readiness/failure contracts. DATA-003 owns installed resolution/pre-menu lock; runtime selections do not unlock it.
- DATA-004 supplies location identity/geography; DATA-005 supplies block/placement/record references and structural compatibility. DATA-006 shared extent/coordinate rules remain binding for expanded worlds.
- DATA-021/022 provide compatible model/material resources and cache context, without converting layout changes into unvalidated visual overrides.
- WORLD/LOC own selection, assembly and persistent layout state. MOVE validates placement; QUEST validates resources/bindings; relevant ITEM/NPC owners restore scoped instance state.
- SAVE coordinates early selection restore and compatibility. CORE-005/007/010/011/013 retain scope isolation, transitions, placement and safe load recovery. MOD owns package identity/lifecycle.

## Edge cases and failure conditions

- Queries for two locations interleave: explicit context prevents one query changing the other's resolution.
- Same block definition appears twice: scoped placement selection does not unintentionally change both unless the declared broader scope applies.
- Definition precedence selects a mod's variant while placement specificity selects its use: treat these as separate decisions with provenance.
- Building override targets a record absent in the selected block: fail incompatible combination rather than assemble a partial hybrid.
- Runtime transition fails after partial reconstruction: use owner-safe recovery without false readiness or uncontrolled gameplay.
- Saved required variant/package is missing: migration or load failure, not baseline fallback or prior-session state reuse.
- Explicit reset requested: validate baseline/default compatibility first. Missing data alone never triggers reset.
- Pre-menu definitions change or runtime selection changes: invalidate affected stale caches/context; ended-session callbacks cannot commit selection.

## Configuration and balancing options

Validated installed variants may be selected through supported owner operations. No live mod reload, automatic missing-variant reset, arbitrary layout merge or silent compatibility bypass is approved. Gameplay triggers, availability, transition pacing and variant balance remain owner specifications.

## Save/load considerations

Persist required selections with stable target/variant references and enough versioned context for compatibility. Definitions remain installed content; selected variants are session-owned world state. Restore the selection set before dependent reconstruction and distinguish baseline from missing/invalid data. SAVE/WORLD/LOC/QUEST must define snapshots, migrations, save-during-transition policy and commit timing; no concrete serialization or rollback format is selected here.

## Technical constraints

Target engine: Godot 4.7.2. Separate definition resolution, explicit scoped selection, validated transition and restoration. Keep original sources read-only and publish coherent ready outcomes. Avoid hidden last-location state or ambiguous setter booleans as authority. Concrete registry/key/reset representation, cache graph, transition API and persistence remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Installed definitions remain separate from session selections; new/loaded characters cannot inherit stale selection state.
2. Stable variant/placement/record identities and explicit query context support independent declared placements without last-location dependence.
3. DATA-003 definition precedence and declared selection specificity remain distinct; incompatible overlaps fail rather than merge accidentally.
4. Runtime changes among installed variants use explicit gated transitions, validating geometry, placement, quests and persistent state before success.
5. Required saved selections validate/restore before dependent geometry/bindings/player placement. Missing/incompatible required content uses migration or load failure, never silent alternate layout.
6. Baseline/default reset is explicit and validated; missing data never implicitly clears a selection.
7. Affected caches and stale work are invalidated/rejected coherently; content lock and source read-only rules remain intact.
8. Representative interleaved-query/repeated-placement, overlap, transition-failure, missing-variant, reset and sequential-save fixtures verify contracts before implementation is complete.

These are future verification criteria. No implementation, world-variant fixtures or runtime tests were performed during specification.

## Consistency review

Reviewed against DATA-001–023 and approved CORE lifecycle/start/load contracts. No contradiction identified. Runtime selection among installed definitions is an approved state transition, not an exception allowing DATA-003 package changes. Restore-before-reconstruction refines early context requirements without approving universal rollback. Scoped variant identity preserves DATA-004/005 references while explicit compatibility remains necessary. Baseline reset is deliberate, distinct from missing required content.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: complete variant/target/schema and legacy mappings; exact scope/default/reset semantics and supported combinations; WORLD/LOC transition/preflight/recovery and cache contracts; placement/quest/object-state compatibility; SAVE schema/absence/version/migration/save-during-transition policy and representative fixtures. These deferrals do not waive explicit context, safe readiness or required saved-layout preservation.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-024-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including scope schemas, transition/cache behavior and save compatibility. Approval does not initiate implementation, coding tasks or another feature review.
