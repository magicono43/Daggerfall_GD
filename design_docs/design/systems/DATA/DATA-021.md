# DATA-021 — Classic meshes and model substitution

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Convert supported classic models into usable geometry and resolve validated replacement resources without changing placed-object identity or silently altering required gameplay contracts.

## Intended player experience

Original models retain intended placement and surfaces. Validated visual replacements appear consistently in the world and compatible automap/collision representations. Missing required geometry fails preparation clearly; invalid selected replacements do not silently disappear behind classic fallback. Repeated instances remain independent.

## Confirmed requirements

DATA-021-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish verified classic conversion; stable resource versus placement identity; explicit visual/gameplay replacement boundaries; absent-versus-invalid replacement recovery; deterministic compatible context variants; and source/conversion-aware reusable caches with separate instance state.

## Existing Daggerfall Unity behavior — reference only

Source anchors are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `MeshReader.cs#GetModelData` resolves classic model IDs through `API/Arch3dFile.cs`, rejects missing/zero-vertex results, converts vertex/index data and caches ModelData by model ID.
- `MeshReader#GetMesh` creates Unity meshes with vertices, normals, UVs and submesh triangles, resolving materials and original texture keys separately. Optional tangent/lightmap-UV generation is supported. `GlobalScale = 0.025f` is this implementation's conversion constant, not an approved Godot scale.
- `MeshReader#ClearCache` clears decoded model cache. Actual memory/performance and invalidation across all consumers require measurement.
- `Utility/AssetInjection/MeshReplacement.cs#ImportCustomGameobject` imports a replacement object, applies placement position/rotation and multiplies existing scale by placement scale, finalizes materials and adds automap handling when requested.
- Replacement helpers also support flats/nature with special positioning/collider behavior. Some paths use shared Unity randomness. Prefab/component substitution is therefore broader than pure mesh decoding; it does not establish safe target gameplay ownership.
- `Utility/RMBLayout.cs`, `Utility/RDBLayout.cs` and `Internal/DaggerfallInterior.cs` consume replacements in assembly contexts. Complete per-caller collision/action behavior still requires deeper inspection.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Conversion, patch, automap/collision and rendered fixtures were not tested. Source remains unchanged.

## Detailed rules and behaviors

### Classic conversion

Preserve supported classic geometry, scale/orientation, surface/material references and placement relationships as the baseline. Godot mesh representation may differ. Verify winding, normals, UVs, scale and alignment against representative sources rather than approximate visual resemblance alone. Exact unit/axis conversions, tolerances, triangulation and optional derived attributes require documented DATA/AV/WORLD contracts.

Separate classic record decoding, interpreted model data, engine resource construction and placement assembly. DATA supplies supported source mappings and conversion inputs; AV owns engine mesh/material resources, LOC/WORLD assemble instances and MOVE/LOC own relevant collision/interaction integration. This feature does not approve a particular mesh library, normal smoothing rule or collider-generation algorithm.

### Identity and replacement scope

Use stable model-resource IDs with explicit classic mappings and validated mod additions. Model identity is distinct from DATA-005's location/placement/record identity. Changing a resource's appearance does not create a new door, building or quest object. Reusable meshes may be shared; mutable instance state must not be.

Distinguish visual replacement from changes to collision, interaction bounds, markers or action behavior. Visual substitution must preserve required gameplay contracts. Gameplay-affecting changes need an explicit supported definition and owner validation; do not automatically inherit gameplay authority from arbitrary imported scene components. MOD/owners retain executable-provider registration and lifecycle.

Preserving a model ID does not alone establish compatibility of saved placement/action state after gameplay-affecting replacement. SAVE/LOC/QUEST apply their existing compatibility contracts; no proximity/name/model-shape matching or state reset is introduced here.

### Resolution and failures

Apply DATA-003's logical identity, declared operations, precedence, provenance and whole-contribution rejection to applicable replacement definitions. If no replacement is supplied, use supported classic geometry. A present but invalid selected replacement must report failure and follow explicit recovery rather than silently falling back to classic or an earlier same-target resource.

Explicit continuation without an invalid contribution is allowed only when the remaining configuration validates under DATA-003. Required source/index failures retain DATA-002 recovery; missing or unusable required geometry fails location preparation under DATA-005 rather than leaving holes or publishing false readiness. On-demand resource conversion remains allowed; failures detected later use LOC/CORE recovery without automatic suppression.

Distinguish replacement absence, source unavailability, invalid data and unsupported required behavior. Exact optional-decorative geometry exceptions require explicit owner policy; none is invented here. Material/texture requiredness is integrated with DATA-022/AV rather than assumed universally optional.

### Context variants and representations

Use explicit deterministic rules for supported climate, season or other model variants. Exact selectors, priority and supported inputs remain owner-defined. This does not authorize random visual variation through shared gameplay RNG or a universal climate variant for every model.

World rendering, collision and automap must use compatible representations of the same placed object. They need not use identical meshes, but must preserve required placement, navigational and interaction meaning. A visual variant cannot silently move interaction points or change gameplay geometry. Any intentional gameplay geometry change uses its explicit owner contract and validation.

Changing a live season/context may select an already resolved supported visual variant under its owner rules; it is distinct from installing/replacing assets. Variant lifetime/transition details remain TIME/AV/LOC scope. No live package reload is approved.

### Cache ownership and activation

Cache reusable geometry by stable model identity, resolved source and relevant conversion/variant inputs. Keep placement transforms/live state separate unless a declared cache key explicitly includes the applicable immutable inputs. Do not return mutable shared geometry that lets one instance corrupt others.

Invalidate affected candidate caches during DATA-003 pre-menu configuration rebuilds so old source winners, conversion results and variant lookups cannot survive as if current. Installed sources lock at actual main-menu entry; external edits/classic-source changes retain restart rules. Application-scope reusable caches may survive character/location changes under DATA-002 while instance state follows session/location ownership.

Memory budgets, eviction, preload/background work and detailed resource lifetime are measured implementation decisions. No fixed cache size or every-mesh-in-memory requirement is approved. Eviction/reconstruction must preserve valid semantics and references rather than altering model selection.

## Relevant formulas and parameters

No new Godot scale, collider tolerance, triangle limit, cache budget or variant priority formula is approved. DFU's scale and mesh flags are implementation observations. Conversion and transform composition must be explicit and fixture-verified with DATA-005/WORLD/AV; exact numeric parameters remain dependencies.

## Required data

Stable model/resource ID and classic mapping; source/package provenance; decoded vertices/topology/normals/UVs/submesh/material references; conversion context; replacement scope and required capabilities; variant selectors; resource/cache identity; scoped placement context and differentiated failure results. Live doors/actions/quest bindings remain separately owned. Exact model/replacement schemas and limits remain dependencies.

## Inputs, outputs and events

Inputs: model/legacy reference, active resolved content, conversion settings, placement/variant context and resource requests. Outputs: supported interpreted/engine geometry or replacement resource with provenance, compatible representation metadata and explicit missing/unavailable/invalid/unsupported outcomes. These are conceptual contracts, not APIs/signals. Geometry-ready is not location-ready, action-triggered or quest-object-created.

## Cross-system interactions

- DATA-001/002 retain source/readiness/failure rules. DATA-003 owns applicable replacement resolution and lock. DATA-005 owns structural reference fidelity and required-block preparation failure.
- DATA-004/006 provide stable location/geographic/climate context. DATA-007 separates appearance references from NPC/gameplay identity. DATA-022 will define texture/material data interfaces.
- AV owns engine geometry/material resources; WORLD/LOC assembly and MOVE/LOC collision/placement preserve required contracts. UI/automap consumes compatible representations.
- TIME/AV define context-driven visual transitions. MOD owns executable content/provider lifecycle. SAVE/LOC/QUEST validate changed gameplay geometry/state compatibility.

## Edge cases and failure conditions

- Replacement absent: classic model is the intended source, not an error. Replacement invalid: explicit recovery, not silent classic substitution.
- Same resource used repeatedly: share immutable geometry while keeping placement/actions/instance state independent.
- Replacement has non-unit transform: validated conversion/placement composition must preserve intended scale and alignment; do not copy an unverified Unity transform convention blindly.
- Winding/UVs/normals differ after conversion: fixtures must detect this even if a screenshot looks approximately correct.
- Visual variant changes a door/marker/collision footprint: reject as purely visual or require the explicit gameplay-change contract.
- Automap representation differs in detail: allow only compatible navigational/placement meaning under its owner validation.
- Candidate order changes: invalidate affected old-winner caches. Seasonal variant changes do not unlock installed packages.
- Required resource decode fails after partial assembly: LOC preparation remains failed and uses cleanup/recovery, not a location with missing geometry.

## Configuration and balancing options

Validated resource additions/replacements and supported context variants follow declared schemas. Performance/cache options remain measured implementation choices; no silent-invalid-replacement toggle or imported-scene gameplay bypass is approved. Geometry-affecting gameplay/balance changes need owner review, not visual-substitution approval alone.

## Save/load considerations

Persist stable model references where owners require them alongside scoped placement/live state, not engine mesh handles or cache slots. Appearance changes alone preserve placed identity; gameplay geometry/action changes still need compatibility checks. Loads rebuild reusable resources without replaying actions or mutating other instances. Exact source/version metadata and migration remain SAVE/LOC/QUEST contracts.

## Technical constraints

Target engine: Godot 4.7.2. Keep source decoding, engine resources, replacement resolution and mutable placement state separate. Original inputs remain read-only; cache keys and publication reflect current validated content. Concrete formats, APIs, conversion/math, resource lifetimes and rendering/collision algorithms remain implementation choices; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Supported classic conversion preserves geometry/scale/orientation/surface/placement meaning with structural and rendered winding/normal/UV/alignment checks.
2. Stable resource IDs/classic mappings remain separate from placed-object identity and mutable state.
3. Visual replacement preserves gameplay contracts; collision/interaction/marker/action changes require explicit owner validation.
4. Absent replacement uses classic geometry; present invalid replacement uses explicit DATA-003 recovery. Required geometry failure prevents location readiness.
5. Variant selection is explicit/deterministic and world/collision/automap remain compatible without unapproved gameplay changes.
6. Cache identity includes source and relevant conversion/variant inputs; pre-menu rebuilds invalidate affected results and shared resources do not leak instance mutations.
7. Content locks/restart rules and read-only sources remain intact. Save references do not depend on mesh handles or stale cache entries.
8. Representative classic/replacement, repeated-placement, variant, invalid-resource and automap/collision fixtures verify contracts before implementation is complete.

These are future verification criteria. No implementation, source-model fixtures or runtime/rendered tests were performed during specification.

## Consistency review

Reviewed against DATA-001–020 and approved CORE lifecycle/readiness/load contracts. No contradiction identified. Resource identity refines DATA-005 placement separation without replacing it. Absent replacement is supported baseline selection; invalid-present fallback remains explicitly governed by DATA-003. Context-driven validated variants do not constitute package reload. Application cache reuse retains DATA-002 while mutable instance state remains scoped.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: supported model/patch schema and classic mappings; coordinate/topology/material conversion fixtures; replacement capability/behavior validation; variant rules; automap/collision/interaction compatibility; resource/cache lifetime and measured budgets; DATA-022 material requiredness; SAVE migration and representative fixtures. These deferrals do not waive conversion fidelity, explicit failure or visual/gameplay scope boundaries.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-021-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including conversion fidelity, representation compatibility, variant/cache rules and save contracts. Approval does not initiate implementation, coding tasks or another feature review.
