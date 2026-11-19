# CHAR-019 — Live race and transformation grants

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Connect transformation conditions and current form to effective racial capabilities, appearance and source-owned grants without erasing birth identity or unrelated character progress.

## Intended player experience

Become a vampire or werewolf/wereboar under the responsible condition rules, see the correct effective identity/form and receive its supported abilities. Curing/reverting removes only appropriate transformation contributions. Loading restores the same condition/form without duplicated powers or replayed acquisition.

## Confirmed requirements

CHAR-019-D01–D06 in [the decision log](../../GAMEPLAY_DECISIONS.md) establish birth/condition/form separation, initial transformation types with mod support, idempotent source-owned grants, default exclusivity with declared compatibility extensions, explicit birth-trait inheritance and validated transitions/cure.

CHAR-002 preserves birth race, CHAR-007 chosen portrait/gender context, CHAR-011 source-based modifiers and CHAR-018 max-pool reconciliation. CHAR-017/SAVE restore authoritative sources without replay. Infection timing, feeding, curse schedules and cure quests remain MAGIC/QUEST and other mechanics-owner rules, not approved wholesale by this identity/grant feature. DFU/classic import remains outside current scope under CORE-013.

## Existing Daggerfall Unity behavior — reference only

Source paths are relative to `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/`:

- `Game/Entities/PlayerEntity.cs#GetLiveRaceTemplate` returns active RacialOverrideEffect.CustomRace or the birth template. BirthRaceTemplate is separately exposed.
- `Game/MagicAndEffects/Effects/Special/RacialOverrideEffect.cs` is a permanent-until-removed incumbent effect intended for one active override. It exposes custom portrait/body/background/voice and behavior hooks. These hooks do not individually establish approved gameplay policy.
- `VampirismEffect.CreateCompoundRace` clones birth template, changes its display name and adds disease/paralysis immunity plus sunlight/holy-damage flags. Its portrait logic selects vampire heads by birth race/gender. Cure deletes vampire-tagged spells and ends vampire quests; detailed cure/effect mechanics remain owner review.
- `LycanthropyEffect` records infection type and isTransformed separately. Constant effects include disease immunity and form-dependent minimum-metal-to-hit logic; presentation and equipment/voice behavior depend on form. Exact combat/stat changes are not approved merely by this trace.
- `PlayerEntity.AssignPlayerVampireSpells` assigns common Levitate/Charm Mortal/Calm Humanoid plus clan grants through classic spell records. AssignVampireSpell marks minimum casting cost and a vampire tag. Clan mappings include Vraseth/Nimbleness, Khulari/Paralysis, Montalion/Recall, Thrafey/Heal, Garlythi/Shield, Selenu/elemental resistances, Lyrezi/Silence and Invisibility, Haarvenu/Ice Storm and Wildfire; full record/other clan behavior needs verification.
- `AssignPlayerLycanthropySpell` loads record 92, removes a leading name marker, and assigns minimum-cost/no-casting-animation/tag settings. Missing lookup/conversion returns silently in these helper paths; intended required-grant failure is explicit.

Baseline: local DFU 1.1.1 Release snapshot; exact Git commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete effect/grant/cure interactions and original assets remain verification dependencies. Source remains unchanged.

## Detailed rules and behaviors

### Identity and form

Maintain persistent birth race, chosen birth portrait and gender independently of active condition identity and current physical form. Transformation does not rewrite those birth fields simply to drive appearance or a race-name label. Being a lycanthrope is distinct from currently being a beast; reverting form is not necessarily cure.

Initial supported condition families are vampirism and werewolf/wereboar lycanthropy. Validated definitions declare effective identity, appearance mappings and grants. Supported mod additions use explicit stable condition/form identities and complete owner contracts rather than extending a display-name switch alone.

Consumers must explicitly select birth identity, condition state or effective form according to their owner rule. A condition label cannot automatically change demographic/name-bank identity, erase biography or grant every behavior associated with a different race. Exact UI labels and condition/form inspection remain presentation scope, using actual resolved state.

### Inheritance and compatibility

Inherit birth-race traits by default. Transformation definitions explicitly identify traits they add, replace or suppress and applicable current-form conditions. Do not infer wholesale replacement from a new display name or portrait. MAGIC/COMBAT/MOVE and other owners resolve resistance/ability stacking, precedence and special-case eligibility; source template cloning alone does not settle those mechanics.

Default allows one active racial transformation condition. Reject an incompatible second condition with an explanation, preserving the existing one. Do not silently replace, cure or partially merge it. Infection exposure/latency can be separately modeled by MAGIC; a latent infection is not automatically a second active condition under this rule.

Validated mod definitions may declare compatible combinations and precedence, including which source controls effective form, presentation and overlapping grants/traits. Compatibility must be complete and deterministic; simultaneous conditions do not imply multiple simultaneous physical forms. Ambiguous/unsupported combinations cannot be published as a valid effective identity. This does not approve arbitrary hybrid balance or a universal condition-priority algorithm.

### Grants and removal

Track each transformation's ability entitlement by stable owning source. Reapplying/restoring an existing source is idempotent. Retain independently learned spells and grants from other sources even when they share the same ability definition. Whether the spellbook displays one entry or multiple variants is MAGIC/UI scope, but removal of one entitlement must not remove surviving access.

On cure or source termination, remove only that source's grants, modifiers, suppressions and presentation contribution. Recompute remaining valid sources/birth traits under the compatibility policy. Form reversion removes form-scoped contributions only; condition-scoped powers remain if the condition persists. Avoid deleting all abilities merely by matching a localized name or broad tag.

Exact spell effects, costs, no-animation flags, clan tables, transformation bonuses, cure quest cleanup and irreversible acquisition consequences require their mechanics-owner specifications. The source baseline is evidence to verify, not permission to apply every grant helper flag without review. Do not roll back unrelated skill growth, rewards or learned spells when curing.

### Transition validation and consistency

Before acquisition, form change, reversion or cure, validate required condition/form definitions, compatible state, appearance resources, abilities and owner prerequisites. Required missing/invalid content blocks the operation with actionable explanation. Prevalidation is not permission to leave partial state if a later owner operation fails; use explicit recovery and keep affected gameplay gated until consistent.

Publish condition/form, source contributions, ability entitlements and presentation consistently. Repeated callbacks cannot duplicate grants or cure another session. The prior valid state must not be silently replaced by a default form/portrait when validation fails. Exact transaction/staging mechanics remain engineering choices; arbitrary irreversible quest effects need an explicit owner settlement contract.

Vital maximum changes reconcile under CHAR-018: increases do not heal/refill, decreases clamp only when necessary. Transformation/cure does not automatically fill vitals or reverse past health damage. Explicitly approved owner effects may separately heal, damage or grant permanent changes; none is invented here.

On full removal of all relevant sources, use preserved birth appearance/traits again, subject to valid required-resource restoration. A later missing birth portrait follows CHAR-007 explicit recovery rather than selecting an unrelated face. Cure is not a general portrait editor.

## Relevant formulas and parameters

No new numerical stat bonus, resistance percentage, spell cost, infection delay or cure probability is approved here. Effective identity derives from birth state plus validated active condition/form declarations and their explicit compatibility/inheritance rules.

Ability access persists while independently learned or supplied by at least one valid owning source. Source reapplication does not multiply entitlements; removing a source leaves all others intact. Exact entitlement key/variant matching is MAGIC-owned and must be specified before implementation.

## Required data

Stable birth identity/portrait/gender; condition/form/clan/type identities; authoritative source/lifecycle state; declared inheritance/suppression and compatibility/precedence; required asset/ability references; learned versus granted entitlement provenance; transition context/results and save compatibility metadata. Concrete schemas are DATA/MAGIC/SAVE dependencies.

## Inputs, outputs and events

Inputs: owner-authorized acquisition/form/reversion/cure requests, validated definitions/source state and restoration. Outputs: coherent effective identity/form, scoped grants/modifiers/presentation, source-removal results or actionable failure. These are conceptual contracts, not API/signal names. Loading/querying identity is not a new acquisition event or quest trigger.

## Cross-system interactions

CHAR-002/007 preserve birth identity/appearance; CHAR-011 combines valid modifiers; CHAR-018 reconciles pools. MAGIC owns infection, condition lifecycle, abilities/stacking and spellbook access. QUEST/FACT own authored cure/clan/social consequences; MOVE/COMBAT own form-specific behavior; ITEM owns equipment restrictions/ownership; UI/AV render supported forms. DATA/MOD validate extensions, CORE scopes transitions/readiness and CHAR-017/SAVE reconstruct sources safely.

## Edge cases and failure conditions

- Latent infection, active condition and current beast form must not collapse into one Boolean.
- Second incompatible conditions fail without overwriting the incumbent; missing mod combination precedence cannot depend on enumeration order.
- Learned-plus-granted or multiple-source abilities survive removal of only one entitlement.
- Repeated grant/restore/cure delivery cannot create duplicates, strip unrelated abilities or replay quests.
- Reversion is not cure; form-only grants differ from condition grants.
- Missing required form/birth assets or abilities blocks consistent transition rather than silently substituting another identity.
- Source removal cannot erase permanent progression or auto-heal; ordinary pool clamping remains CHAR-018.
- All consumers must use the correct identity layer, especially race-based swimming/combat/naming checks.

## Configuration and balancing options

Validated mods may add supported condition/forms and declare appearance, ability entitlements, inheritance/suppression and compatibility/precedence under owner schemas. DATA-003 locking and validation remain binding. New executable effects, hybrid mechanics, resource fallbacks or modified infection/cure balance require explicit owner support. Default one-condition policy remains until valid alternatives are declared.

## Save/load considerations

Persist birth state separately from active condition/form/clan/type/lifecycle and source-owned grants. Restore authoritative sources and learned ability ownership before rebuilding effective state, without rerunning acquisition rewards, quest starts, infection rolls or cure transactions. Preserve ongoing owner timers/obligations under their specifications.

Missing required definitions/references or unsupported saved combinations require explicit SAVE migration/failure. Do not silently cure, reset form or delete grants. Derived presentation/combined templates are rebuildable from validated sources; they cannot replace saved birth identity or act as a second grant source. Full source cleanup and restore readiness remain CHAR-017/CORE contracts.

## Technical constraints

Target: Godot 4.7.2. Separate identity layers, condition lifecycle, physical-form selection, entitlement provenance and UI. Use stable IDs, source-specific cleanup and validated consistent transitions; avoid mutable birth-template rewrites and generic tag deletion as sole ownership. Exact schemas, transaction/API and resource conversion remain engineering choices. Reference source/content remain read-only; import work is not authorized.

## Acceptance criteria

1. Birth race/portrait/gender survive conditions/form changes; effective identity and physical form remain distinct.
2. Initial vampirism/werewolf/wereboar definitions resolve required supported appearance/grants without implicitly approving unrelated source mechanics.
3. Birth traits persist unless explicitly replaced/suppressed; owners resolve actual ability/resistance semantics.
4. Default incompatible second conditions reject unchanged; valid mod combinations have deterministic declared precedence and one coherent effective form.
5. Source grant/reapply/restore is idempotent; cure removes only owned contributions, preserving learned/other-source access and unrelated progress.
6. Form reversion retains condition-scoped state while removing form-only changes.
7. Required validation and coherent transition prevent partial presentation/grants; stale/duplicate callbacks cannot affect another character.
8. Pool changes follow CHAR-018 without automatic healing; missing birth portrait uses explicit CHAR-007 recovery.
9. Save/load rebuilds effective state from authoritative sources without acquisition/cure replay or silent missing-content repair.

These are future verification criteria. No implementation/runtime tests are authorized or claimed.

## Consistency review

Reviewed against approved CHAR-002/007/011/017/018, DATA-003 and relevant CORE-007/013 restoration constraints. No direct contradiction identified. Birth identity preservation and source-owned modifier cleanup carry earlier decisions forward. One-condition default explicitly permits declared mod extensions without implicit hybrid balance. Required transition validation preserves CHAR-007 recovery and does not authorize silent fallback. Detailed infection/cure/ability balance and broader architecture remain unapproved here.

## Outstanding questions and approval

No further blocking identity/grant policy question is identified. Before implementation is complete: verify full asset/grant/clan fixtures and cure cleanup; define exact resistance/ability inheritance/stacking and consumer identity contracts; finalize mod compatibility schemas, entitlement variants and owner transition settlements; establish SAVE lifecycle/migration/readiness contracts. Dependencies cannot waive preserved birth identity, source-specific removal or required-content validation.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1. Approval reference: CHAR-019-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented mechanics/entitlement/asset, MOD and SAVE dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
