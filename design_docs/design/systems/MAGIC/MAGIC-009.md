# MAGIC-009 — Incumbents, constant effects and expiration

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Resolve overlapping effect contributions through explicit family policies, maintain constant capabilities safely, and remove expired or invalid contributions without erasing surviving sources or replaying consequences.

## Intended player experience

Recasts follow predictable extension/refresh/replacement rules. Weaker strongest-only buffs can resume if still valid when stronger ones end. Unequipping one item or losing one spell does not remove another source's protection. Saving/loading preserves overlap and timing without free refills, lost effects or repeated payloads.

## Confirmed requirements

MAGIC-009-D01–D12 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm family-declared stacking, retained source provenance, scoped immediate cleanup, standard extension/refresh, aging suppressed contributions, source-bound lifetime, checked replacement, independent bundle entries, strongest ties, idempotent rebuild and native reconstruction. The complete specification is approved under MAGIC-009-A01.

Inherited CHAR-011 source-owned modifiers, CHAR-018 vital reconciliation, MAGIC-006 accepted-only merging and MAGIC-008 explicit timing/migration remain binding. Individual family baseline stacking inventories are not approved merely by this framework.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete family/cleanup/runtime fixtures unverified. Reference source unchanged. Paths relative to reference `Assets/Scripts/Game/MagicAndEffects/`.

- `IncumbentEffect.cs#AttachHost` makes the first matching instance incumbent; later instances call AddState and do not persist/tick as separate effects. `FindIncumbent` requires same bundle type plus family IsLikeKind matching. Resume restores incumbent flag.
- `Effects/Illusion/ConcealmentEffect.cs#AddState` adds remaining rounds. Start/Resume/ConstantEffect set concealment flags; End clears its flag directly. That illustrates potential overlap cleanup concerns rather than proving all surviving-source combinations fail.
- SpellAbsorption, SpellReflection and SpellResistance similarly add incumbent duration in their inspected classes; their target baseline family selections remain review dependencies.
- `EntityEffectManager.cs#DoConstantEffects` clears/rebuilds constant state and reconciles magicka after the pass. `UpdateEntityMods` aggregates live modifiers. `RemoveBundle` calls End on all entries before removing the bundle; individual round expiry can also call End.

Source matching/storage and direct flag-clearing are not mandatory native implementation details.

## Detailed rules and behaviors

### Contributions and family policies

Track stable contribution/source/recipient identity separately from the effective aggregated capability. Spell, potion and equipment contributions remain identifiable even where a permitted merge presents one incumbent. Preserve enough provenance/lifetime ownership for selective removal and attribution. Aggregation must not silently transfer all contributions to whichever caster/item arrived first.

Each family explicitly declares matching keys, eligible source domains and combination policy. Supported validated mod policies include independent instances, duration extension, refresh, replacement and strongest-only. Matching can include effect/variant/stat/source criteria where declared; names, list positions or arbitrary arrival callbacks are not identity.

No universal cross-source stacking or exact family default is approved here. Inventory/verify family baseline behavior and seek review where new gameplay choices are needed. Independent instances do not automatically stack every numeric capability: owner combination rules still apply.

### Admission before combination

Perform MAGIC-006 eligibility/defense/chance/save acceptance before modifying an incumbent. Failed admission leaves prior contributions unchanged. Authored ordering remains binding; an accepted merge/replacement can affect state seen by later entries. A merge is an explicit accepted outcome, not another initial tick by default.

Policies must specify valid power/lifetime inputs and timing compatibility. Unknown references, unsupported comparisons or invalid numeric state fail explicitly, preserving consistent prior state where possible. Technical partial mutation requires retained progress/recovery rather than replay or silent fallback to another stacking policy.

### Standard extension and refresh

Standard duration extension adds accepted incoming remaining lifetime while preserving incumbent power and next-tick progress. It grants no additional initial application. Retain constituent provenance sufficient for owner-selected removal; exact allocation of consumed extension time among constituent sources must be explicitly specified before implementation rather than losing ownership.

Standard refresh sets remaining lifetime to max(current remaining lifetime, accepted incoming lifetime), preserving power and next-tick progress, with no extra initial application. It neither shortens the effect nor adds the whole incoming lifetime as extension. Explicit alternative profiles may replace power, reset phase or use another duration rule; those are not implicit standard refresh behavior.

Cross-profile lifetime combination requires explicit supported unit/semantic conversion. MAGIC-008's old-profile continuation does not authorize adding seconds to rounds as raw numbers. If combination is unsupported, return an explicit policy/recovery outcome rather than silently merging or dropping the new contribution.

### Replacement

Validate/admit incoming replacement before removing old contribution. Switch coherently without exposing a missing intermediate bonus/capability, refilling vitals or replaying grants. Failed admission preserves the old effect. Replacement policy explicitly states initial payload and new tick phase; no universal extra initial tick or phase reset is selected by this framework.

Only affected matching contributions are replaced under declared policy, not unrelated sources or spell entries. Repeated callback delivery cannot replace twice or apply the replacement's payload twice.

### Strongest-only

Families explicitly define strength comparison; magnitude alone is not a universal comparator. Equal strength keeps the currently effective contribution. With no effective incumbent, stable application order resolves ties. Exact representation/order key is technical scope, but engine enumeration cannot decide outcomes.

Retain weaker accepted contributions and let their lifetime/tick phase advance while suppressed. They contribute no suppressed capability or periodic payload and accrue no missed ticks to replay. If the stronger source ends and a weaker one remains valid, recompute it as effective without another initial payload or tick-phase restart. A later genuine due tick may execute normally. Alternative suppression/aging models require explicit policy.

Do not convert switching into a fresh cast, practice event or new RNG roll. Current-validity reevaluation and declared dynamic strength rules must be documented if a family supports them rather than inventing live power recomputation for captured effects.

### Source-bound lifetime and independent removal

Held/equipped effects normally exist only while their declared required source remains valid and active. Unequip/break/removal clears only that contribution without restarting surviving effects. An ordinary timed cast does not disappear merely because its caster later unequips an unrelated item; source dependency is explicit.

Individual entries within a mixed spell expire/remove independently. Other entries remain unless an explicit rule selects the whole bundle. Dispel/cure/source owners choose affected contributions; this feature defines safe removal, not universal dispel eligibility or cure strength.

Expiry, dispelling and valid source loss clear only affected contributions and immediately/coherently recompute surviving capabilities/modifiers before further gameplay observes state. Repeated cleanup is harmless and cannot replay damage, grants or initial application. Cleanup must not blindly clear a shared flag still provided by another valid source.

MAGIC-008 defines default round expiry boundaries and alternative lifetime policies. Zero-duration instant effects use declared one-shot behavior, not an accidental permanent source; source-bound continuous effects are explicitly declared rather than inferred from a zero timer. Exact family zero-duration/termination rules remain inventory dependencies.

### Constant state and vital reconciliation

Constant modifier/capability reconstruction is idempotent. No rebuild RNG, charge consumption, practice, periodic damage or startup reward. Such actions belong to explicit accepted application/tick/owner operations. Queries, UI refresh and restored derived-state rebuilding cannot repeat them.

Combine all valid effective source contributions coherently before reconciling live stats and vital limits under CHAR-011/018. Do not expose a temporary clear-all capacity drop that clamps away magicka/health before remaining bonuses are restored. Capacity increase does not itself refill current resource. Remove/re-add cannot recover previously clamped-away amounts without an explicit owner recovery effect.

Committed changes publish truthful effective/removed/suppressed state; observers cannot independently rerun owner effects. Pending technical cleanup failure must stay explicit, not falsely report fully removed while required gameplay contributions remain.

## Relevant formulas and parameters

Standard extension remaining lifetime T'=T+Tin in compatible declared units; refresh T'=max(T,Tin). Safe arithmetic and validated bounds required. Both preserve incumbent power/next tick and add no initial payload. Strongest-only uses declared comparator, incumbent-retaining ties and stable application order. No global stack cap, power-summing rule, replacement payload or cross-unit conversion constant is introduced.

## Required data

Stable application/contribution/recipient/source identities; effect family/matching key/source domain; resolved power and policy/version; timing profile/lifetime/tick phase; incumbent/effective/suppressed state; comparison/order key; accepted merge constituents and removal ownership; source validity/dependency; committed initial/tick/cleanup state and recovery obligations. Exact schemas and constituent-time allocation remain dependencies.

## Inputs, outputs and events

Inputs: accepted contribution, due expiry/source validity changes, owner-selected dispel/cure/removal, declared policy, derived-state rebuild and native restore. Outputs: independent/new/extended/refreshed/replaced/suppressed/effective contributions, coherent modifiers/capabilities, scoped removal or explicit failure/recovery. Notifications describe committed state, not new application authority. API/signal names remain unselected.

## Cross-system interactions

MAGIC-006 admits before merge; MAGIC-008 owns clocks/expiry/migration; MAGIC-010 and SAVE preserve state. MAGIC-007 defense families retain their declared captured/live scaling and require baseline merge review. CHAR-011/018 combine valid modifiers/reconcile vitals; ITEM supplies equipment/source changes; COMBAT/MAGIC-004 preserve released versus required-source distinctions. Dispel/cure/transformation families select cleanup under their own rules. DATA/MOD validate locked policies; UI reflects surviving contributions without replay.

## Edge cases and failure conditions

- Rejected recast: no duration/power/phase change.
- Refresh shorter than current remaining: no shortening; extension preserves phase/power.
- Suppressed effect expires first: remove it without affecting stronger source. Stronger expires first: resume valid weaker contribution without initial tick or backlog.
- Equal strengths: stable incumbent/tie behavior across reload, not enumeration flicker.
- Unequipping invisibility item while timed invisibility survives: concealment remains until its own source ends.
- One bundle entry ends: unrelated components remain; explicit whole-bundle removal still available to owner rules.
- Rebuild after replacement: no transient vital clamp/free refill, RNG or reward.
- Cross-profile continuation/merge: require documented compatibility and provenance, no raw-unit addition or old-state deletion.
- Repeated End/removal or partial cleanup failure: no removal of another source, no duplicate effects; retain explicit recovery where incomplete.

## Configuration and balancing options

Validated family matching/source domains, listed combination policies, comparisons, suppression alternatives and explicit duration/power/phase rules are moddable. This does not approve every effect family's baseline stacking or arbitrary universal duplication. Exact API/schema/selector precedence and numeric limits remain owner work. Individual effect inventories should state defaults and permitted overrides before implementation is considered complete.

## Save/load considerations

Preserve contribution/source identities and dependencies, constituent merge state, effective/suppressed status, resolved power, lifetime and tick phase. Rebuild same effective state without rerunning admission, initial payload, practice, charges or grants. Stable strongest ties must survive restoration; suppressed contributions cannot vanish merely because absent from visible HUD.

Timing differences use MAGIC-008 explicit migration or disclosed supported old-profile continuation. Cross-profile merge needs declared conversion. Required missing-source/state incompatibility uses CORE-013 recovery rather than silent loss or invented permanent effects. Exact coherent transition save boundaries, schema/versioning and migrations remain MAGIC-010/SAVE scope; classic/DFU import outside scope.

## Technical constraints

Target Godot v4.7.2. Distinguish authoritative contributions from aggregated flags/live values; native architecture need not reproduce IncumbentEffect inheritance or per-frame rebuild. Preserve coherent owner operations, safe math and once-only lifecycle. Exact merge-time ownership, comparator types, cleanup contracts and persistence schema need design/fixtures. Reference source read-only; no implementation authorized.

## Acceptance criteria

1. Family-declared policies/matching govern overlap; missing/invalid policy fails explicitly rather than guessing stacking.
2. Source provenance survives permitted merges, enabling scoped removal without erasing unrelated capabilities.
3. Standard extension/refresh preserve power/phase and grant no new initial application; formulas and compatible units are respected.
4. Replacement validates first and commits coherently with declared initial/phase behavior; failure leaves old state intact.
5. Strongest-only suppressed contributions age without payload/backlog; resumption does not reinitialize; ties persist deterministically.
6. Source-bound effects end on valid dependency loss while unrelated timed effects survive; mixed entries remove independently unless owner explicitly selects whole bundle.
7. Rebuild/cleanup are idempotent and free of RNG/rewards/ticks; surviving sources recompute before vital reconciliation without transient loss/refill.
8. Native load preserves source/merge/suppression/power/timing/tie state without admission or startup replay; timing migration follows MAGIC-008.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved CHAR-011/018, MAGIC-006/008 and recorded MAGIC-009-D01–D12, with MAGIC-004/007 source/defense boundaries. No direct contradiction identified. Accepted-only merging and no accidental initial ticks remain intact; timing-profile coexistence is not implicit merge compatibility. Scoped recomputation preserves CHAR ownership and capacity semantics. Framework standard policies are approved choices only when complete draft approved; individual families' assignment to those policies remains unreviewed. Architecture proposals beyond confirmed behavior remain recommendations.

## Outstanding questions

No further blocking framework player-policy choice is identified. Before implementation is complete: inventory/approve family defaults and like-kind/source-domain matching; define merged-lifetime constituent consumption/removal ownership, strongest comparison and replacement initial/phase profiles; specify zero-duration/source-bound termination and cleanup failures; define cross-profile migration/merge and coherent SAVE schemas. These dependencies cannot authorize source provenance loss, hidden stack defaults, suppressed backlog, duplicate initial application or transient resource clamping.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-009-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented family-default inventories, merge-provenance ownership, comparison/replacement policies, cleanup contracts and native persistence/migration dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
