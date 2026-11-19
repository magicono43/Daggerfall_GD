# DATA-022 — Textures, images and material variants

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-05: “I approve”.
Updated: 2026-11-05.

## Gameplay purpose

Decode supported classic imagery and resolve validated image/material replacements and visual variants for world, UI and item consumers without changing authoritative gameplay state.

## Intended player experience

Classic imagery retains intended colors, transparency and animation. Supported replacements align correctly with models and UI. Visual variants remain consistent with their context, and changing one item's dye does not recolor unrelated instances. Invalid selected assets produce truthful recovery rather than disappearing behind silent fallback.

## Confirmed requirements

DATA-022-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish stable extensible image/material identity; supported classic decoding; explicit owner-controlled variants; distinct replacement scopes; absent-versus-invalid recovery; declared optional-map/animation rules; and complete cache identity with representative verification.

## Existing Daggerfall Unity behavior — reference only

Paths below are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Utility/TextureReader.cs#CreateFromAPIImage` tries whole-image and CIF/RCI replacements before converting image record/frame data with an alpha index. Other methods construct textures, atlases and terrain arrays and handle optional generated/imported normal and emission maps.
- `MaterialReader.cs#GetMaterial` and `GetCachedMaterial` resolve archive/record/frame resources. `MakeTextureKey` packs classic fields and cache group; `ChangeClimate` handles climate/season/window context. Complete effective cache correctness requires per-path verification rather than assuming one packed key includes every input.
- `Utility/AssetInjection/TextureReplacement.cs#TryImportMaterial`, `TryImportTexture` and image helpers expose separate replacement forms. `API/TextureFile.cs` and other image readers interpret distinct classic formats; a single decoder does not cover every family automatically.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only. Source remains unchanged. Image-family coverage, variant precedence, cache correctness and rendered output have not been fixture-verified here.

## Detailed rules and behaviors

### Identity and conversion

Use stable image/material IDs with explicit classic file/archive, record and frame mappings. Do not constrain new resources to classic packed-key bit widths. Preserve supported palette, transparency, source dimensions and animation structure as the baseline. Validated higher-resolution replacements are permitted when declared dimensional/UV/frame relationships remain compatible; source dimensions need not equal replacement pixel dimensions.

Keep source decoding, interpreted image data and engine texture/material construction distinct. DATA supplies source interpretation and references; AV owns rendering resources and realization. Exact palette interpretation, orientation, color spaces, alpha modes and source format coverage must be documented and verified rather than inferred from plausible appearance.

### Variants and instance isolation

Use explicit selectors for supported climate, season, dye and other visual variants. Exact combinations, priority and runtime transitions remain owner contracts. Selecting a visual does not rewrite DATA-006 climate definitions, change item identity or mutate gameplay state.

Shared textures/materials must not leak per-instance changes. Dyeing one item cannot recolor unrelated instances; immutable variants, instance parameters or another validated approach may satisfy this without mandating a separate texture for every item. DATA-021's visual/gameplay boundary remains binding.

### Replacement contracts

Distinguish replacing image pixels, supplying optional material maps and replacing a whole material. Declare required inputs and compatible dimensions, UV relationships, map roles and frame structure. Imported assets do not implicitly authorize arbitrary shaders or gameplay behavior; custom executable/provider support remains MOD/AV-owned.

Apply DATA-003's operations, precedence, provenance and whole-contribution rejection. Absent replacement uses supported classic imagery. A present but invalid selected replacement requires explicit recovery, not silent use of an earlier same-target asset. Explicit continuation without the invalid contribution is permitted only when the remaining configuration validates.

Missing required imagery fails affected preparation under DATA-002/005/021 and consumer recovery. Optional presentation can use only an explicitly approved owner fallback. No universal checkerboard-success or missing-texture exception is approved for required assets.

### Optional maps and animation

Absent optional normal/emission maps may use a declared material policy. This does not prescribe generated normals or default emission for every material. Incompatible supplied maps and missing required animation frames fail rather than being silently dropped.

Static replacement of animated content requires explicit supported semantics. Do not freeze a resource merely because only one frame loaded. Frame identity, required sequence, timing and replacement coverage must be validated with AV; no specific frame rate, blending rule or animation limit is approved here.

### Caches and activation

Cache identity includes resolved source and all inputs that change results, including palette, alpha, frame, dye, context variant and conversion settings where applicable. Equivalent immutable results may share resources; mutable placement/item state remains separate. Do not use a legacy packed key alone when relevant inputs differ.

Pre-menu configuration rebuilds invalidate affected candidate resources/indexes under DATA-003/021. Actual main-menu entry locks installed content; external edits and classic-source switches retain restart rules. Selecting an already resolved supported seasonal/visual variant is distinct from installing new assets. Application-scope reuse follows DATA-002 without retaining character mutations.

Filtering, compression, atlas/array strategy, resource eviction and budgets remain measured AV implementation choices. They must preserve required visual/structural semantics and cannot justify stale-source returns or incompatible UVs.

## Relevant formulas and parameters

No target packed-key width, palette table, alpha threshold, filter mode, compression format, animation timing, atlas size or memory budget is approved. Classic encodings are adapter facts. Exact dimensional scaling, UV conventions, color-space/map interpretation and variant priorities require owner contracts and fixtures.

## Required data

Stable image/material identity and classic mappings; source/provenance; decoded dimensions/palette/transparency/frame structure; map roles and requiredness; replacement scope; supported variant inputs; conversion settings; material/resource compatibility and cache context; differentiated outcomes. Mutable item/instance state remains outside shared definitions.

## Inputs, outputs and events

Inputs: image/material reference, active content, palette/alpha/frame and supported context/dye/conversion requests. Outputs: usable decoded data or engine resources through AV, provenance and explicit missing/unavailable/invalid/unsupported failures. These are conceptual contracts, not APIs/signals. Resource-ready does not mean location-ready, item-dyed or gameplay state committed.

## Cross-system interactions

- DATA-001/002 retain source/readiness/failure rules; DATA-003 controls installed contributions and lock.
- DATA-006 supplies climate identity without visual selection rewriting it. DATA-007 separates appearance/gameplay definitions. DATA-010/ITEM own dye/item state.
- DATA-021 supplies model surfaces/UV context and visual/gameplay boundaries. WORLD/LOC own affected preparation; AV owns engine textures/materials, animation and presentation.
- UI/text/font consumers retain readable-control and supported-format requirements under DATA-013–019. MOD owns executable providers; SAVE/domain owners persist gameplay state rather than engine cache handles.

## Edge cases and failure conditions

- Higher-resolution replacement: permitted only with validated layout/UV relationships, not automatic changed world scale.
- Same image under different palette/alpha/dye/frame inputs: do not return a cached result for a different effective request.
- No optional map: use its declared policy. Supplied incompatible map: report invalid data rather than silently treating it absent.
- Animated resource has incomplete required frames: fail; static substitution requires explicit support.
- Invalid selected replacement: explicit recovery; absent replacement: classic baseline. Required source failure cannot be relabeled optional.
- One instance changes dye or visual parameters: others remain unaffected. Climate visual changes do not mutate geographic climate or item identity.
- Atlas conversion changes seams/UVs or transparency: fixtures must catch semantic output errors despite successful decoding.

## Configuration and balancing options

Validated images/maps/materials and supported variants follow declared schemas. No silent invalid-replacement skip, accidental static-animation fallback or unapproved shader behavior is introduced. Visual performance/preferences remain AV/CORE contracts; there are no approved new gameplay balance formulas.

## Save/load considerations

Persist owner-defined stable resource references and mutable item/context state where required, not GPU handles/cache slots. Reconstruct presentation without changing identity, replaying effects or losing per-instance dye. SAVE/owners validate changed definitions where gameplay-relevant references are affected; identical resource ID alone does not establish all compatibility. Exact visual snapshot/version policies remain deferred.

## Technical constraints

Target engine: Godot 4.7.2. Separate classic decoding, source resolution, engine resources and instance state. Keep inputs read-only, resource publication coherent and cache identity complete. Concrete formats, APIs, shaders, atlas strategy and budgets remain choices to verify; broader architecture proposals are not approved wholesale.

## Acceptance criteria

1. Stable IDs/classic mappings support validated resources beyond legacy packed limits while preserving supported source color/alpha/dimension/animation interpretation.
2. Explicit variants preserve authoritative climate/item/gameplay state and per-instance dye isolation.
3. Pixel, optional-map and whole-material replacements have declared compatibility and requiredness without arbitrary inferred behavior.
4. Absent replacements use classic data; present invalid selections use DATA-003 recovery. Required missing imagery fails affected preparation.
5. Missing optional maps follow declared policy; incompatible maps/required missing frames fail. Animated-to-static substitution is explicit.
6. Cache identity covers source and all result-changing inputs; pre-menu rebuilds invalidate affected results without instance leakage.
7. Representative image families and combinations verify orientation, colors, transparency, animation, UV alignment and isolation through structural/rendered fixtures.
8. Installed-content locks, source read-only rules and truthful owner readiness remain intact; optimization does not alter these outcomes.

These are future verification criteria. No implementation, image fixtures or runtime/rendered tests were performed during specification.

## Consistency review

Reviewed against DATA-001–021 and approved CORE lifecycle/readiness/load contracts. No contradiction identified. Higher resolution preserves compatibility rather than forcing classic pixel dimensions. Optional-map absence is a declared capability policy, not silent invalid-contribution skipping. Climate variants and dye remain presentation of owner state; resource caching complements DATA-021 without merging mutable instances.

## Outstanding questions and approval

No further blocking player-policy choice is currently identified. Dependencies before implementation is complete: supported image/map/material schemas; legacy mappings; palette/color-space/alpha/UV interpretation; variant selection and animation timing; optional-map/static-substitution policies; custom shader/provider validation; cache/resource budgets and lifetimes; consumer requiredness/SAVE references and representative fixtures. These deferrals do not waive truthful failure, complete cache identity or instance isolation.

The user explicitly approved the complete Draft v1 on 2026-11-05 with “I approve”. This specification is finalized v1. Approval reference: DATA-022-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open, including format schemas, variant/animation rules, AV/provider contracts and verification fixtures. Approval does not initiate implementation, coding tasks or another feature review.
