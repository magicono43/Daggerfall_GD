# MAGIC-001 — Effect registration and discovery

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose

Provide consistent identifiable effect definitions for spells, crafting, items and native saves. Prevent conflicting or unavailable effect providers from silently changing usable content.

## Intended player experience

Supported effects resolve consistently across gameplay and crafting. Browsing effects never applies them. Invalid content explains its missing/conflicting dependencies and offers established recovery rather than silently changing a spell or losing a saved effect. Discovery here means system lookup and availability, not player learning or unlock progression.

## Confirmed requirements

MAGIC-001-D01–D06 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm stable effect/variant identity; explicit replacement and jointly validated indexes; separate runtime support and per-service crafting eligibility; a run-long definition lock after main-menu entry; explicit missing-provider recovery; and side-effect-free inspection with separate mutable application state. The complete specification is approved under MAGIC-001-A01.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/mod-combination behavior unverified. Reference source remains unchanged. Source paths below are relative to reference `Assets/Scripts/Game/MagicAndEffects/`.

- `EntityEffectBroker.cs#Start` discovers BaseEntityEffect classes reflectively, skips empty keys/disabled discovery, registers templates, explicitly registers the MageLight demo and raises the custom-effect registration event.
- `RegisterEffectTemplate` indexes string keys, expands variants, and invokes recipe/classic indexing. A duplicate effect key is rejected unless allowReplacement is true.
- `MapClassicKey` maps supported nonzero classic spell-effect keys. Duplicate mappings log errors without necessarily failing the overall template registration. `IndexEffectRecipes` similarly indexes recipe hashes with optional replacement. This does not establish atomic registration across indexes.
- `GetGroupNames`, `GetSubGroupNames`, `GetEffectTemplates` and `GetEnchantmentEffectTemplates` filter templates by crafting-station eligibility. Registration does not itself mean every service offers an effect.
- `GetEffectTemplate` returns templates; `InstantiateEffect` constructs a new executable instance and assigns settings/variant, returning null for an unknown key.

These are reference observations, not automatic adoption of DFU reflection, hashing, baseline eligibility or executable mod APIs.

## Detailed rules and behaviors

### Identity and resolution

Every effect and separately referenceable variant has a stable domain-scoped ID independent of display name, class name and collection order. Maintain explicit classic effect mappings separately from native identity. Classic mappings are not permission to import classic/DFU saves. Renaming or reordering alone does not change identity.

Record provider/contributor provenance sufficient to diagnose conflicts and missing dependencies. A data declaration alone does not establish executable support: an effect must resolve to supported behavior before dependent content is usable. Exact ID syntax, variant encoding and executable registration mechanism remain technical dependencies.

### Addition, replacement and publication

Reject duplicate additions. Allow explicitly declared replacement according to resolved mod order and applicable DATA-003 contribution rules, retaining contributing and winning provenance. Accidental collisions must not become replacements merely because a package loads later.

Validate the candidate effect definition, variant references, classic mappings and recipe indexes together before publication. Failure publishes no partial registration or inconsistent secondary indexes. Rebuild/revalidate affected references against the resolved candidate; no stale mappings or recipe entries may survive a replacement merely because they belonged to the previous definition. This is a consistency requirement, not a selected incremental-update algorithm or new recipe-conflict winner rule.

Use existing whole-contribution rejection and explicit recovery under DATA-003. Continuation after deliberate omission requires the remaining required definitions/dependencies to validate. Ordinary valid overrides remain diagnosable without blocking popups. Exact schemas, supported patch operations and classic/recipe collision validation must be documented before implementation; ambiguity cannot be silently resolved by enumeration order.

### Availability and inspection

Keep runtime effect support separate from eligibility for spellmaking, enchanting and potion crafting. Service queries respect explicit eligibility. An effect can support enemies, quests or artifacts without automatically being selectable by the player. Individual baseline eligibility, learn/unlock conditions, spell composition and recipes remain their respective MAGIC/content reviews; this feature does not approve specific lists.

Listing, previews and validation do not cast, apply bonuses, consume resources or advance effect timers. Actual application uses separate mutable state rather than mutating reusable definitions or another actor's application state. Intentional stacking/merging remains MAGIC-009 scope, not accidental shared state. Instance creation is not itself approval to apply an effect before MAGIC admission succeeds.

### Configuration and lifetime

Build and validate effect definitions/mappings before actual main-menu entry. Pre-menu data configuration follows DATA-003's candidate rebuild and validation flow. Once the actual main menu is entered, keep definitions and mappings fixed for the rest of the application run, including returning from gameplay or changing characters. Adding/replacing registered definitions after this lock requires restart.

Live effects may still change duration, magnitude and other supported instance state under their owner rules. That does not modify registered definitions. MOD owns executable-provider discovery, activation and unloading limitations; pre-menu data rebuild does not promise that already running executable mods can be unloaded.

### Missing effects and failure

Required spell, item or saved-effect references to unavailable effects report the missing ID and provider where identifiable and require recovery. Do not silently remove an effect, substitute another or expose a reduced spell as usable. Unknown provenance must be reported truthfully rather than guessing a provider.

Recovery may restore the required provider or use an explicitly supported, validated migration. Content/setup failures use DATA/CORE readiness and recovery. Native-load dependency failures use CORE-013 preflight so the current session remains intact where failure is detectable before replacement. No arbitrary continuation with required dependencies missing is approved.

## Relevant formulas and parameters

No casting, cost, duration, magnitude, chance or balancing formula is selected here. Service eligibility is explicit per service. Identity and valid replacement precedence do not depend on display ordering. No fixed effect count, discovery timeout or recipe hash algorithm is approved.

## Required data

Stable effect and separately referenceable variant IDs; supported behavior/provider references; display/group metadata used by consumers; explicit classic mappings; per-service crafting eligibility; applicable recipe references/indexes; declared addition/replacement operations; source/winner provenance; candidate validation results and unresolved dependencies. Exact schema, capabilities and compatibility/version representation remain implementation dependencies.

## Inputs, outputs and events

Inputs: shipped definitions, resolved mod contributions, applicable overrides, provider registrations, candidate configuration changes, lookup/filter requests, instance settings and required-reference validation requests.

Outputs: validated resolved definitions/mappings, service-filtered results, separate instances or explicit resolution/creation failure, provenance and actionable validation outcomes. Candidate publication/readiness must reflect successful required validation. These are conceptual contracts, not selected API or signal names. Lookup/creation is not casting or successful application.

## Cross-system interactions

- DATA-003 supplies deterministic contribution resolution, provenance, whole-contribution failure, pre-menu rebuild and the main-menu lock. MOD supplies resolved provider/package order and executable lifecycle constraints.
- DATA-011 supplies stable spell identities and complete conversion requirements. Effect identity is distinct from spell identity; unsupported active effects cannot be silently dropped.
- MAGIC-002/006 consume mappings and instantiate/admit supported effects. MAGIC-009 owns stacking; MAGIC-010 owns active-effect restore. MAGIC-011–016 own offers, crafting, recipes and item triggers.
- ITEM validates enchantment references. SAVE/MAGIC/ITEM validate changed definitions and required providers. CORE-013 gates native restore; CORE-012 preserves required starting-grant failure rules.
- UI presents service availability and recovery without executing effects. CHAR retains source-owned modifier state; registry inspection must not alter that state.

## Edge cases and failure conditions

- Duplicate add versus explicit replace: reject the former; validate the latter under resolved precedence.
- Variant, classic mapping or recipe-index failure after a valid primary ID: reject the candidate contribution without partial publication.
- Replacement changes/removes secondary references: no dangling or stale published indexes; affected dependencies must validate.
- Repeated pre-menu rebuild: no accumulated prior contributions or shared live effect state.
- Supported runtime effect is crafting-ineligible: remain available to valid runtime consumers without exposing a crafting choice.
- Two actors use the same definition: duration/settings changes in one application cannot mutate the other.
- Provider missing on native load: fail required dependency validation with recovery, without dropping effects or silently substituting content.
- Same effect ID but incompatible behavior/state schema: identity alone cannot prove save compatibility or authorize timer resets.
- Attempts to replace definitions after main-menu entry: retain the locked plan; require restart for registration changes.

## Configuration and balancing options

Validated definitions/replacements can change supported metadata and service eligibility where owner schemas permit. No live registry-editing switch, silent-skip mode or specific baseline eligibility table is approved. Individual effect balance and crafting restrictions remain owner specifications.

## Save/load considerations

Persist native effect references using stable identity and the owner-required compatibility information. Definitions are application content, separate from active mutable effect state. Loading cannot change the locked configuration. DATA-011 and CORE-013 require compatibility checks rather than treating matching IDs as permission to overwrite saved settings, restart timers or discard unsupported effects.

SAVE/MAGIC/MOD must define exact provider/version checks, definition-versus-snapshot rules and supported migrations. This feature does not choose those representations, authorize legacy save import or replace MAGIC-010's detailed restoration contract.

## Technical constraints

Target Godot v4.7.2; behavior need not reproduce Unity reflection/Activator or concrete broker classes. Use supported executable behavior and validated definitions without selecting a universal scripting language, plugin sandbox or factory implementation here. Required validation and lookup must be deterministic under the resolved content plan. Reference source is analysis-only and remains unchanged.

## Acceptance criteria

1. Renaming/reordering an effect preserves its stable identity; separately referenceable variants remain independently resolvable through explicit mappings.
2. Duplicate additions fail; valid explicit replacements follow resolved precedence with diagnosable provenance.
3. A failure in any required variant/classic/recipe index publishes none of the invalid contribution. Replacement leaves no stale secondary references.
4. Rebuilding a pre-menu candidate repeatedly produces equivalent validated results without accumulated stale entries.
5. Crafting-ineligible effects can resolve for permitted runtime use while being excluded from the relevant service query.
6. Listing, previewing and validation leave resources, modifiers and timers unchanged. Separate applications cannot accidentally share mutable state.
7. Required missing providers report ID/provider context and block the dependent readiness/load outcome; no reduced spell, dropped saved effect or unrelated substitute is reported as success.
8. Entering the actual main menu locks definitions/mappings for the application run; changing characters or returning to menu does not unlock them.
9. Same-ID incompatible changes require supported compatibility/migration or explicit failure, preserving approved native-load safeguards.

These are future verification criteria. No implementation or runtime tests were performed for this specification.

## Consistency review

Reviewed against approved DATA-003, DATA-011 and CORE-013 specifications and recorded MAGIC-001 decisions. No direct contradiction identified: data rebuild remains pre-menu, executable unload support is not assumed, complete conversion is preserved, and missing required native-save dependencies cannot be silently lost. Source MAGIC-AR-01 and global architecture proposals remain recommendations except where these feature decisions explicitly confirm behavior. Individual effect/crafting balance is not approved through registry policy.

## Outstanding questions

No further blocking player-policy choice is identified for this registry scope. Before implementation is complete, owners must settle ID syntax/normalization, variant/mapping inventories, precise schemas/operations, recipe identity/conflict rules, provider lifecycle, concrete creation/failure contracts, service metadata/eligibility inventories, and native compatibility/migration representation. Any resulting new gameplay or recovery policy requires review rather than being inferred from these technical deferrals.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-08 with “I approve”. Approval reference: MAGIC-001-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented technical and cross-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
