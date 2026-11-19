# MAGIC-003 — Ready spell and affordability

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Prepare a valid spell for a specific caster, present its current cost, and control the handoff to casting without spending resources during preparation or losing an existing selection on failed replacement.

## Intended player experience

Readying and canceling are free. Cost reflects current caster capabilities. Self spells cast on selection by default; other target types wait for activation, with moddable per-target/per-spell behavior. Failed attempts retain the selected spell and explain the problem without repeatedly trying to cast. Loading a save never unexpectedly casts a readied spell.

## Confirmed requirements

MAGIC-003-D01–D13 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm preparation without reservation/payment, safe replacement, configurable automatic casting across target types, current-cost commitment, independent silence permissions, NPC-specific affordability modes/precedence, failed-attempt retention, cancellation/busy handling and safe native restoration. D05 resolves the earlier fixed-versus-current-cost question; D08–D10 resolve the earlier policy-scope questions. The complete specification is approved under MAGIC-003-A01.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime timing/mod combinations unverified. Source remains unchanged. Paths relative to reference `Assets/Scripts/`.

- `Game/MagicAndEffects/EntityEffectManager.cs#SetReadySpell` rejects silence unless noSpellPointCost, a cast in progress, null spells and old versions. It calculates/stores a cost, checks full affordability for players except free/god-mode casts, and clears ready state when player affordability fails.
- Its default enemy cost calculation can use player skills. Full-cost enemy affordability is not enforced here; a comment describes classic positive-magicka AI behavior.
- `OnNewReadySpell` fires before no-cost and instant-cast flags are fully assigned. Caster-only targets set automatic casting; player Update also has a separate no-animation execution path. Animation suppression alone is not target permission in this specification.
- `AbortReadySpell` clears the ready reference/no-cost flag. `SilenceCheck` also clears the ready spell. `CastReadySpell` checks silence and player touch range, then deducts the cached cost before animation/release; it does not show a full current-affordability recheck at that point.
- `Game/WeaponManager.cs` provides the weapon-drawing interaction finalized separately in COMBAT-001.

These observations do not approve the cached-cost policy, coupling silence to free casting, permissive flags or incomplete readiness notifications.

## Detailed rules and behaviors

### Preparation and replacement

Accept an explicit caster/source context and completely supported spell definition under MAGIC-001/002 and DATA-011. Required provider/version/settings failures are explicit, not zero-cost or partial-spell success. Readiness does not grant ownership/permission to use a spell; spellbook, item and ability owners supply their applicable authorization.

Compute the ready-time quote through RULE-018 using the caster's own current context. Apply the resolved affordability and silence permissions. Readying neither spends nor reserves magicka and grants no practice or effects. Exact-equality ordinary affordability is valid under CHAR-018.

Validate a proposed replacement before changing existing ready state. Failed validation or affordability preserves the previous spell and provides clear feedback. The retained spell remains subject to current cast-time checks. On successful replacement, all quote/source/policy/automatic-attempt state must describe the new selection coherently before observers receive readiness notification; old selection flags cannot carry over.

Reject readying requests during actual casting without queuing. MAGIC-004 must define the precise transition from uncast-ready to actual casting; this feature does not approve replacing an in-progress cast.

### Automatic versus separate-input casting

Default player behavior: caster-only spells request casting immediately after successful selection; touch, single ranged, area around caster and area ranged wait for activation. Area around caster is distinct from caster-only.

Allow validated automatic/separate-input configuration per target type, with an explicit per-spell override taking priority over the target-type default. This policy covers every target type. Exact data representation remains deferred; it is a content policy under the locked configuration, not permission for live registry edits.

An automatic selection triggers one attempt using current aim and normal eligibility/target checks. It never acquires a target automatically, loops on failure or becomes a background pending cast that later fires when conditions improve. For player selection inside a modal/suspended UI, the handoff must obey input and gameplay eligibility; owner integration must consume the authorized selection once without interpreting stale menu input as another cast. No animation flag independently bypasses this policy.

NPC AI still decides when to request casts. Target-type selection policy is not authorization for new AI behavior, repeated automatic attacks or bypassing targeting. The NPC affordability rules below apply whenever an NPC enters readiness/commitment.

### Quote and commitment

The displayed ready-time cost is a quote. Reflect current cost changes in the UI without requiring another confirmation. At cast commitment, recalculate using current caster skills/modifiers and perform the resolved affordability check against that amount. Do not retain an expired temporary discount by holding a readied spell.

MAGIC-004 owns exact payment/animation/release ordering and once-only execution. Its handoff must preserve these requirements: preparation spends nothing, commitment uses current cost/eligibility, failed admission spends nothing, and duplicate requests cannot charge twice. This draft does not choose a release-frame versus cast-start commitment marker or post-commit refund policy.

Separate no-magicka-cost permission from silence bypass. Free spells obey silence unless their source explicitly authorizes bypass. Individual item/innate/developer exceptions require owner contracts; no blanket permission is inferred from DFU flags. No-cost casting still requires valid supported content and normal non-resource eligibility.

### NPC affordability modes

Use the NPC's own explicit cost context; never silently substitute player skills. Ordinary mode requires full cost just as player ordinary spending does. Supported NPC exceptions are validated mod policies:

| Mode | Readiness and commitment admission | Magicka debit at commitment |
| --- | --- | --- |
| Full cost, default | Current magicka M must be at least current cost C | C |
| Positive magicka | M must be greater than zero | min(M,C), leaving max(0,M−C) |
| No magicka cost | No magicka threshold | 0 |

Costs must be valid nonnegative RULE-018 results. Positive-magicka mode requires M>0 even if C=0; choosing that mode is an explicit threshold policy. It permits an underfunded NPC cast by explicit owner exception, not overdraft or negative magicka. CHAR must expose the authorized operation without weakening ordinary spending. No mode independently bypasses silence.

Resolve NPC affordability precedence: enemy's particular-spell override → enemy-wide override → spell-wide NPC affordability override → full-cost default. Here “spell-wide” is the NPC policy field, not permission to apply NPC exceptions to a player. Enemy-specific overrides never affect player casting. Exact enemy template/instance selector schema remains a technical dependency and cannot silently broaden a rule's target population.

### Failed attempts and cancellation

If an accepted readied spell cannot cast due to silence, insufficient magicka or invalid target, retain it with clear feedback, without resource spend, practice or automatic retry. This includes failed selection-triggered automatic attempts. Require fresh cast input/request to try again. NPC retry cadence remains AI-owned rather than a retained automatic loop.

Distinguish failed replacement from failed casting: replacement failure retains the old spell; a successful replacement followed by a failed automatic attempt retains the new spell. Clearing silence, restoring magicka or moving a target into range never casts by itself.

Explicit cancellation clears the uncast spell, its associated flags and pending automatic attempt without cost. It grants no practice. Under approved COMBAT-001, eligible Ready Weapon cancels an uncast spell and ends with weapons drawn; preparation temporarily hides weapons without changing stored readiness. Once actual casting starts, Ready Weapon is ignored without queuing. Forced interruption of actual casting remains MAGIC-004 scope.

Honor MOVE-018 arbitration: non-touch readied spells own activation; touch spells get first refusal on eligible in-range entities, otherwise permitted environmental interaction can proceed. One input cannot both cast and interact. This draft does not redefine detailed touch eligibility or grant generic interaction fall-through after a blocked non-touch cast.

## Relevant formulas and parameters

C is the current validated RULE-018 quote; M is current authoritative magicka. Full-cost admission M≥C; positive-magicka admission M>0 and debit min(M,C); no-cost debit 0. No resource reservation, readying fee, cancellation fee, retry interval or additional spell minimum is introduced. Current quote changes do not change the locked definition/override plan.

## Required data

Stable spell identity and resolved supported settings; caster/source identity and authorization; current quote/context; ready versus casting state; target-type/per-spell automatic policy; applicable NPC affordability mode/provenance; independent silence-bypass permission; one-attempt automatic state; validation/block reason; session/request identity sufficient to reject stale work. Persist gameplay state rather than held keys, UI objects or engine pointers. Exact schemas remain dependencies.

## Inputs, outputs and events

Inputs: selection/replacement/cancel requests, cast attempts, current caster resources/skills/status, target/aim checks, resolved policies, weapon-ready interaction and native restoration. Outputs: coherent ready selection/quote, failed replacement preserving prior state, retained blocked spell, canceled preparation, or one admitted handoff to MAGIC-004. Notifications describe committed readiness state and cannot independently authorize payment/application. API/signal names are not selected.

## Cross-system interactions

- MAGIC-001/002 and DATA-011 establish provider support, stable identities and complete definitions. DATA-003/MOD resolve validated policies before the application-run lock.
- RULE-018 supplies current explicit-caster costs; CHAR-011 supplies live modifiers, CHAR-018 owns spending. NPC owns pool construction, policy selectors and AI retry decisions.
- MAGIC-004 owns cast boundary/payment/execution/history; MAGIC-005 owns targeting; MAGIC-006 owns effect admission; MAGIC-022 owns detailed silence rules. No-cost and silence-bypass permissions remain independent.
- COMBAT-001 governs weapon readiness during preparation/casting. MOVE-001/018 and CORE-016 govern input/suspension/arbitration. UI shows current quote and truthful failures.
- SAVE/CORE-013 coordinate native reference validation and restoration. Spellbook, item and innate-ability owners define source eligibility rather than readiness inventing grants or bypasses.

## Edge cases and failure conditions

- Cost rises after preparation: commitment rechecks current cost; insufficient funds retain blocked readiness without debit. Cost falls: use the lower current quote.
- Failed replacement while the prior spell is already blocked: preserve it; do not manufacture eligibility.
- Accepted new automatic spell fails targeting: new spell remains selected, no automatic retry.
- No-cost but silenced: block unless separately authorized. Invalid content never becomes legal through no-cost mode.
- NPC has M<C but M>0: full-cost mode rejects; positive mode admits and drains only available magicka; no-cost mode spends none. Repeated requests cannot duplicate payment.
- Two overlapping NPC policies: resolve the specified hierarchy and retain source diagnostics; player use ignores NPC-only policy fields.
- Switching between target types or cancel/reselect: no stale automatic/silence/cost flags from prior selections.
- Load, focus/menu return or unblocking status: never execute a restored/stale automatic attempt. Ordinary authorized selection-triggered casting still needs a defined eligible UI handoff.

## Configuration and balancing options

Validated mods may choose automatic/separate-input casting per target type and override it per spell. NPC affordability supports the three modes and stated enemy/spell hierarchy. Exact configuration schemas and supported enemy selectors remain dependencies, not a chosen executable hook API. Defaults remain automatic caster-only selection and full-cost NPC casting with own skills. Enemy pools/frequency and individual free/silence exceptions require their owner reviews; no baseline rebalance is approved here.

## Save/load considerations

Native saves preserve an uncast readied spell and source context where valid. Restore validates required references/compatibility, reconstructs readiness and recalculates its quote without payment, practice or automatic casting. Require fresh input after load even if that spell normally casts automatically on selection. Restoration is not a new selection event.

Insufficient magicka or silence may leave the restored spell readied but blocked; required missing content follows CORE-013 recovery rather than discarding the spell. Do not persist replayable automatic attempts or physical key holds. Ready state has no reserved resource to refund. SAVE/MAGIC-004 retain ownership of saves made after actual casting starts; uncast restoration does not authorize abandoning or replaying a committed cast. Classic/DFU save import remains outside scope.

## Technical constraints

Target Godot v4.7.2. Preserve explicit caster and session context, stable content identity and coherent ready-state publication; do not require Unity fields/classes. Exact commitment ordering, quote refresh notifications, UI handoff, NPC selectors, permission schemas, stale-request handling and native serialization remain technical/cross-owner contracts. Reference source remains unchanged. No implementation or coding tasks are authorized.

## Acceptance criteria

1. Readying/canceling spends/reserves no magicka and grants no practice; ordinary exact-cost preparation is affordable.
2. Failed replacement preserves the complete prior selection; successful replacement publishes coherent state before observers act.
3. Default caster-only selection requests one cast; other target types wait. Per-spell automatic policy overrides target policy for every supported target type without target acquisition or retry loops.
4. Current-cost changes update the quote; commitment recalculates and checks current affordability rather than using an expired discount.
5. Free casting never implies silence bypass; invalid required definitions fail regardless of cost mode.
6. NPC calculations use own context and resolve the specified override hierarchy. Each mode's threshold/debit is correct with zero, exact and insufficient magicka; resources never become negative.
7. Failed cast attempts retain readiness, explain failure, spend/grant nothing and require fresh input, including automatic-attempt failures.
8. Cancellation clears uncast flags/attempts; actual-casting ready requests are rejected without queuing. COMBAT-001 weapon behavior and MOVE-018 one-input arbitration hold.
9. Native restore preserves valid uncast readiness/quote without automatic casting; blocked affordability/silence differs from required missing-content failure.
10. Duplicate/stale attempts, restored state and UI/context transitions cannot cast or charge unexpectedly. Exact execution-boundary checks are completed with MAGIC-004 integration.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved RULE-018, CHAR-018, COMBAT-001, MOVE-018 and CORE-013 contracts, MAGIC-001/002, and D01–D13. No direct contradiction identified. NPC positive-magicka mode is an explicit owner exception allowed by CHAR-018, not a change to ordinary spending. Current caster quoting follows RULE-018. Uncast spell restore answers COMBAT-001's open spell-restoration dependency without selecting actual-cast restore/interruption. Automatic selection remains subordinate to input/target gates and never replays on native load. Architecture proposals beyond these confirmed behaviors remain unapproved.

## Outstanding questions

No further blocking readiness player-policy choice is identified. Before implementation is complete: MAGIC-004 must specify casting/commitment and post-start interruption/refund boundaries; MAGIC-005/022 define exact target/silence rules; MOD/DATA/NPC define policy schemas, enemy template/instance selectors and permissions; UI/CORE define the once-only eligible selection handoff and quote updates; SAVE defines native state/version compatibility and active-cast handling. No automatic retry, partial ordinary spend or silent missing-content recovery may be inferred from these deferrals.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-003-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented casting/payment boundaries, target/silence contracts, policy schemas/selectors, UI handoff and native-save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
