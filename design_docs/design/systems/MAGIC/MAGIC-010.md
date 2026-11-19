# MAGIC-010 — Effect persistence and HUD state

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Restore authoritative ongoing magic without replaying gameplay and present its surviving contributions accurately through a derived active-effects HUD.

## Intended player experience

Saving/loading preserves effect power, timing, suppression and source relationships. Missing original casters do not erase otherwise self-sufficient effects. Required incompatibilities have meaningful recovery; missing cosmetic icons use fallback. Players can inspect overlapping contributions, see overflow and recognize impending loss of protection without misleading countdowns or mandatory blinking.

## Confirmed requirements

MAGIC-010-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm saved-state authority, declared source dependencies, derived HUD/cosmetic fallback, contribution details/overflow/warnings, versioned provider compatibility, reference-link readiness and coherent save boundaries. The complete specification is approved under MAGIC-010-A01.

MAGIC-003/004 ready/casting restoration, MAGIC-006/007 retained admission/defense outcomes, MAGIC-008 timing migration/continuation, MAGIC-009 contributions and CORE-013 native-entry safeguards remain binding.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; full effect-specific serialization/runtime ordering unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/`.

- `MagicAndEffects/EntityEffectManager.cs#GetInstancedBundlesSaveData` and `GetEffectSaveData` export bundle metadata/source item IDs and effect keys/settings, remaining rounds, chance success, modifiers, incumbent/variant/ended state and effect-specific payload.
- `RestoreInstancedBundleSaveData` wipes current bundles, relinks caster/items, skips missing held-item sources, instantiates known effects, calls Resume/RestoreSaveData and skips unknown keys/empty restored bundles. Those lossy skips are not adopted as native required-content policy.
- `UpdateHUDSpellIcons` delegates to HUD ActiveSpells when enabled.
- `UserInterface/HUDActiveSpells.cs` refreshes on rounds/assignment/removal/incumbent updates/load, uses a 24-icon pool, tooltip/display name and expiring flag, and blinks expiring non-item icons. Its helper finds maximum remaining rounds across a bundle; target mixed-effect detail must not imply every entry shares that expiry.

## Detailed rules and behaviors

### Authoritative state and reconstruction

Save authoritative resolved effect power, retained chance/save outcomes, source/contribution relationships, suppression/merge state, lifetime/tick progress and required effect-specific state. Do not recast, reroll admission or recompute captured power from current caster stats on restore.

Reconstruct derived modifiers/capabilities from saved valid contributions under MAGIC-009 and CHAR-011/018; do not add saved live totals on top of reconstructed bonuses. Explicit live dependencies remain live, including MAGIC-007 absorption-level policy. A live dependency is declared behavior, not a generic excuse to refresh all saved powers.

Retain completed initial/application/tick/defense facts needed to avoid replay. Reconstruction is not a fresh cast: no payment, practice, initial damage/heal, grant, charge refresh or history update. MAGIC-003/004 govern uncast readiness/cast cancellation/recovery separately; active-effect restoration cannot restart those casts.

### References and required sources

Use stable caster/source/actor/item/contribution identities. Keep original attribution even if original actor representation is gone. A missing original caster does not terminate an effect whose saved power/attribution suffice. Effects needing ongoing access must explicitly declare that dependency.

Distinguish not-yet-linked from confirmed absent. Establish required actor/item identities and link phases before declaring a missing source. Required equipped-item/source failures need explicit recovery, not silent bundle skipping. Validate that a linked source is the correct item and satisfies declared active/equipped/source rules, rather than binding another item with the same name/template.

Legitimate source removal during play follows MAGIC-009 scoped cleanup. A coherent save should reflect those committed removals; corrupt/incompatible missing dependencies on restore are not permission to invent removal history or discard unrelated effects.

### Provider compatibility and migration

Each provider declares versioned effect-state representation and supported migrations. Stable effect ID alone is not proof of compatible behavior/payload. Validate required provider/version/state compatibility and supported migration before replacing the current session, following CORE-013. Exact schema/version encoding is technical scope.

Favor supported migration preserving consequences, contribution ownership and timing. For timing changes, preserve MAGIC-008 documented migration-first and disclosed supported saved-profile continuation. Saved profile metadata is not executable code; required providers must actually be available. Configuration restoration is offered where migration/continuation is unsupported; no silent effect deletion, timer reset or guessed payload substitution.

No automatic migration of arbitrary custom code state is promised. Invalid required state remains actionable recovery without destroying the current session in preflight. Later required failures follow CORE cleanup/recovery, not false loaded success.

### Restore readiness and coherent saves

Keep gameplay suspended until required reference linking, source validation, effect-state restoration, derived modifier/capability reconstruction, vital-limit reconciliation and HUD model rebuild finish. Rebuild surviving contributions coherently before clamping vitals; no transient clear-all capacity loss/free refill. Required underlying effect failure blocks readiness; cosmetic icon failure alone does not.

Save at coherent effect boundaries. If ongoing application/merge/removal cannot yet be serialized safely, temporarily delay or reject save with explanation. Supported partial-operation snapshots may retain enough committed progress/random results/obligations to resume once. Never silently omit pending work, record half-applied state as complete or replay initial operations to approximate it.

Exact bounded delay/cancel UI, save eligibility and partial-operation schemas belong to SAVE/owners. This policy is not permission for indefinite invisible waiting or blanket disabling of saves whenever any ordinary effect is active.

### HUD authority, grouping and inspection

Derive icons/details from authoritative surviving effects, not serialized UI objects. Hiding HUD/icons cannot end an effect; absence from compact display cannot mean gameplay absence. Presentation observers cannot apply effects, roll RNG or perform cleanup.

Group related effects by spell/source while retaining inspectable per-contribution details: source, remaining lifetime and effective/suppressed state. Mixed-duration components cannot be represented as if one countdown described all of them. Suppressed contributions may be omitted from compact icons but remain in details; internal bookkeeping effects may remain hidden under explicit presentation rules.

Respect source knowledge/visibility policies. A detail's source label must not invent a known caster or expose otherwise hidden information; exact labeling of unknown causes remains UI/effect-family work. Grouping cannot collapse provenance needed for removal or strongest-only explanation.

When compact capacity is exceeded, provide an overflow count or expandable list rather than silently truncating. Display capacity never caps active gameplay effects. Exact layout, sort and navigation remain UI dependencies, without approving DFU's fixed icon pool as a gameplay limit.

### Lifetimes, warnings and fallback

Use profile-appropriate round or second units and truthful remaining lifetime. Source-bound effects show their dependency instead of a fake countdown. Suppressed expiry alone cannot imply currently effective protection is ending. Where effective coverage changes among contributions, warning semantics must reflect surviving state, not simply the first entry's timer.

Default expiry warning is nonblinking. Optional blinking and validated moddable thresholds are supported; exact default threshold/styling remains UI configuration work. UI warning timers cannot advance gameplay clocks. Duration/phase remains frozen under ordinary pause/load as approved; inspecting details cannot consume ticks.

Missing cosmetic icons may use a generic fallback while gameplay survives unchanged. Required missing effect definitions/state are content failures, not cosmetic fallback cases. Fallback/hidden icons cannot mask unresolved mandatory load dependencies. HUD reconstruction publishes current state without replaying startup messages as new applications.

## Relevant formulas and parameters

No gameplay magnitude/save/cost formula is introduced. Timing units/countdowns follow resolved MAGIC-008 profiles. No fixed active-effect cap, universal expiry threshold, 24-icon limit, numeric blink rate or save-delay timeout is selected. Remaining state and compatibility are authoritative, not derived from visible icon count or a bundle's maximum timer alone.

## Required data

Versioned provider/effect IDs and payload; stable caster/source/item/contribution identities; resolved power/admission/defense results; merge constituents/suppression/order; timing profile/lifetime/phase; explicit live/required-source dependency declarations; completed/pending operation facts; compatibility/migration provenance. Derived display data includes group/source labels, contribution lifetimes, effective/suppressed state, source dependency, cosmetic icon/fallback and overflow/warning policy. Exact schema remains SAVE/MAGIC/provider work.

## Inputs, outputs and events

Inputs: coherent native snapshot, resolved providers/profiles, compatibility/migration results, actor/item linking, owner reconstruction and effect lifecycle changes. Outputs: validated restored effect state, rebuilt modifiers/vitals/HUD, completed readiness or explicit recovery, details/overflow/warnings and safe-save result. Concrete APIs/signals remain unselected. Restore completion is emitted only for actual required readiness, not merely started deserialization.

## Cross-system interactions

SAVE/CORE-013 own preflight/current-session safety/version/entry; DATA/MOD supply compatible resolved content and provider activation. MAGIC-001/002 stable definitions, MAGIC-003/004 casting/history state, MAGIC-006/007 retained outcomes/budgets/chains, MAGIC-008 timing migration and MAGIC-009 source/suppression rebuild remain authoritative. CHAR-011/018 own modifiers/vital reconciliation; ITEM links equipment/source identity; UI/AV consume derived state with cosmetic fallback. Effect families own required payload/live dependency and presentation disclosure policies.

## Edge cases and failure conditions

- Original caster gone but sufficient snapshot: preserve effect/attribution; ongoing-required dependency instead uses explicit recovery.
- Item reference not loaded yet: wait for linking, do not silently drop held effect. Wrong/missing required item after linking is not cosmetic failure.
- Same ID/provider changed incompatible payload: supported migration/continuation or recovery, no guessed default.
- Suppressed effect omitted from compact row: still saved, aging and inspectable; load restores same strongest tie result.
- Mixed spell with short/long entries: per-entry detail, not misleading uniform countdown.
- Many effects: overflow navigation without gameplay truncation. Missing icon: fallback, not effect deletion.
- Restore bonus/max changes: rebuild coherent sources once before vital reconciliation, no free refill/transient resource loss.
- Save during partial merge/remove: safe boundary or supported once-only state, never omitted obligation/replayed grant.

## Configuration and balancing options

Support provider migrations, MAGIC-008 compatible timing continuation, explicit internal visibility rules, grouping/overflow and optional blinking/moddable warning thresholds. Presentation configuration cannot alter effect existence or admission. Exact UI/provider APIs, safe limits and default warning threshold remain dependencies. No player toggle for silently discarding required effects or bypassing native compatibility is approved.

## Save/load considerations

This feature concerns native saves of the Godot implementation; classic/DFU import remains outside scope. Preserve authoritative gameplay state and rebuild derived display. Required incompatible data follows recovery with migration-first preferences; restore never recasts, refreshes timers or replays completed checks. Provider payloads must explicitly define what is authoritative versus reconstructible, including compatibility checks and coherent partial-operation state. Timing/suppression/source state must not disappear merely because not visible in HUD.

## Technical constraints

Target Godot v4.7.2. Separate versioned durable effect data from scene pointers/UI widgets and reconstructible aggregate values. Use explicit linking/readiness phases, source validity and idempotent rebuild operations. Exact serialization, schema validation, migration registry, save admission and HUD layout remain implementation design. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Restore preserves captured power, outcomes, contributions/suppression/timing without recast/admission/initial replay; declared live dependencies remain live.
2. Missing original caster alone does not erase self-sufficient effects; unresolved linking is distinct from absent required source and identity substitution is prohibited.
3. Provider-version compatibility/migrations validate under CORE-013; timing migration/continuation preserves MAGIC-008 without silent required-effect loss.
4. Required reconstruction/linking/modifier/vital/HUD readiness precedes gameplay; icon fallback alone cannot block successful required restoration.
5. Coherent save boundaries or explicitly supported partial progress prevent half-applied/replayable operations; unsupported busy saves explain delay/rejection.
6. HUD is derived, source-grouped and inspectable per contribution, including suppression and truthful mixed lifetimes.
7. Overflow exposes extra displayable effects without capping gameplay; internal visibility is explicit and cosmetic fallback preserves state.
8. Nonblinking default warnings, optional blink/threshold policies and dependency displays respect timing units and surviving effective protection.
9. Opening details, toggling HUD and restoring UI cannot roll RNG, consume charges, retick effects or replay startup rewards/messages.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved MAGIC-006–009, CHAR-011/018 and CORE-013 safeguards plus recorded MAGIC-010-D01–D09. No direct contradiction identified. Durable snapshots preserve prior captured/live distinctions and source contributions; migration-first does not waive required compatibility. UI suppression/overflow is presentation only, and cosmetic fallback does not hide required gameplay failure. Coherent save policy resolves partial-state risks without promising every in-flight operation is serializable. Broader architecture proposals remain recommendations beyond confirmed behavior.

## Outstanding questions

No further blocking persistence/HUD player-policy choice is identified. Before implementation is complete: inventory per-provider state/version/migrations and required/live dependencies; define linking/owner rebuild order, coherent partial-save boundaries and validation; specify native result/budget/chain state; design HUD sort/navigation/unknown-source labels, warning coverage rules/default threshold and fallback resources. These dependencies cannot authorize silent effect loss, startup replay, premature readiness, gameplay icon caps or misleading lifetimes.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-010-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented provider schemas/migrations, source linking, restore ordering, coherent save boundaries and HUD presentation dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
