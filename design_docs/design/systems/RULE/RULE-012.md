# RULE-012 — Attack eligibility and route

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-06: “I approve”.
Updated: 2026-11-06.

## Gameplay purpose

Select weapon, humanoid hand-to-hand or monster natural attack paths, enforce selected-route material eligibility and sequence monster component gates before hit/damage resolution.

## Intended player experience

Enemies use the stronger baseline natural option where configured. An ineffective selected weapon gives a distinct material failure rather than a random miss or hidden second attack. Unarmed attacks normally bypass material requirements, with explicit mod customization. Monster components resolve in stable order without one failed component cancelling the remainder.

## Confirmed requirements

RULE-012-D01–D09 in [the decision log](../../GAMEPLAY_DECISIONS.md) confirm moddable stronger-average selection, route-before-material ordering/no automatic fallback, moddable weapon requirements and unarmed bypass, three vanilla ordered components with modded lists, inactive-slot skipping, explicit modded unarmed eligibility, gate→hit→damage order and continuation after ordinary component failure.

CHAR-010 already approves reflex gate probabilities 70/60/50/40/30% from Very High through Very Low, distinct from final hit chance. RULE-001/003 govern unbiased percentile resolution and owned randomness; RULE-004 governs supported hook validation/selection/failure.

## Existing Daggerfall Unity behavior — reference only

Source: `daggerfall-unity-1.1.1-cve-2025/Assets/Scripts/Game/Formulas/FormulaHelper.cs#CalculateAttackDamage`.

- Null attacker/target returns zero. A top-level mod override returns directly, bypassing built-in routing and side effects.
- Armed EnemyEntity attackers compare integer averages of weapon base min/max and first natural min/max. Strictly greater natural average clears the local weapon reference; ties retain weapon. Comments explicitly describe this as a classic deviation.
- Selected weapons below target MinMetalToHit return zero, with player feedback. No selected weapon uses HandToHand skill; player/humanoid enemy-class attackers use a hand-to-hand path, while unarmed monsters loop three natural slots.
- Monster slots draw DFRandom.rand()%100 against a reflex chance before checking positive minimum damage and the hit helper. Thus even empty slots consume a preliminary draw. Hits draw damage and can invoke monster effects; later equipment/enchantment callbacks also occur in the broader method.

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; complete caller reachability, runtime effect order and DOS parity remain unverified. Source remains unchanged.

## Detailed rules and behaviors

### Route selection

COMBAT first authorizes an attack and supplies valid attacker/target/weapon context. A legitimate absent weapon differs from a missing required weapon reference. This helper cannot silently turn invalid state into an unarmed attack.

For an armed enemy eligible for the baseline policy, compare Wavg=floor((Wmin+Wmax)/2) and Navg=floor((N1min+N1max)/2). Valid ranges are nonnegative and ordered; compute without overflow. Use only the first natural component's authored base range, not the sum of all natural damage. Exclude Strength, enchantments, armor, material effectiveness and predicted final hit/damage from this baseline comparison.

Choose natural/unarmed only if Navg>Wavg; ties retain weapon. If the first natural slot is absent, it contributes no stronger natural option; explicit active/absent metadata must prevent an invalid range becoming a selection score. A legitimate unarmed enemy still uses its authorized unarmed/natural route. NPC/content owners must validate route availability and model identity.

The preference policy is moddable through supported validated policy/parameter definitions or an explicit RULE-004 selection hook. It does not automatically apply to player weapon choices or approve NPC equipment AI generally. An explicit alternative policy may consider material or other inputs, but must not create an undeclared second attack.

After route selection, selected weapons use their declared weapon-skill path. Unarmed players/humanoid enemy classes use the hand-to-hand path; unarmed monsters use their ordered natural components. NPC/content adapters must explicitly identify these models rather than infer missing data as a model.

### Material eligibility

Evaluate material eligibility for the selected route before its hit/damage resolution. Vanilla selected-weapon rule: weapon material rank must meet or exceed target minimum required rank. Equality passes. Native material/category ordering must be explicitly mapped and validated; do not treat arbitrary mod enum/integer values as automatically ordered.

Fail with an ineffective-material outcome, distinct from a random miss. Do not automatically retry natural/unarmed attacks after a chosen weapon fails. Target requirements and the supported material-eligibility hook are moddable. Selection itself precedes this gate; the baseline does not inspect material to choose another route.

Unarmed/natural attacks bypass this weapon material requirement by default. Bypass behavior is moddable. Disabling it requires explicit validated unarmed/natural material-equivalent data or an eligibility rule. Missing data cannot silently make the target immune or permit damage. Concrete per-actor/per-component representation and hooks remain ITEM/NPC/COMBAT contracts.

Material pass/bypass authorizes proceeding to later resolution, not guaranteed damage. No weapon-poison/enchantment exception, cost/practice outcome or immunity-breaking rule is approved merely by a hook's availability.

### Monster component sequence

Retain three ordered vanilla natural slots and support validated finite modded component lists. Preserve authored order. Mark absent slots inactive; skip them without reflex/hit/damage draws. Active components require positive minimum damage, maximum>=minimum and supported safe numeric values. Invalid components fail validation rather than silently becoming inactive.

For each active component of an eligible monster natural attack:

1. Resolve one preliminary RULE-001 reflex gate using the current fixed character reflex setting and resolved approved parameters.
2. If the gate passes, perform that component's hit check under RULE-013.
3. Only a hit proceeds to RULE-014 damage calculation and owner-controlled effects.

Baseline gate probabilities are 70/60/50/40/30% from Very High through Very Low under CHAR-010; they are not the final hit chance. Use unbiased RULE-001 draws from explicit combat randomness rather than DFRandom modulo. A failed gate consumes no downstream hit/damage draws for that component. Inactive slots consume none. Gate/hit failure proceeds to the next active component rather than cancelling the sequence.

COMBAT owns termination when target validity, death or interruption changes, and the exact boundaries where updated live state must be reread. This specification does not approve continuing attacks against dead targets, precomputing all effects from stale state or restarting a partially applied sequence. Retain resolved component results/application progress for technical retries under RULE-003. No whole-attack reroll or duplicate effect application is permitted.

Body-part selection/reuse, actual hit formula, damage modifiers/minimums, per-hit versus aggregate effects and equipment/poison/enchantment timing remain RULE-013/014/016 and COMBAT reviews. The component order here does not silently select those details.

## Relevant formulas and parameters

- Wavg=floor((Wmin+Wmax)/2); Navg=floor((N1min+N1max)/2).
- Baseline natural preference iff Navg>Wavg; equality retains weapon.
- Selected weapon eligible iff resolved material rank>=target minimum rank, unless explicit supported policy says otherwise.
- Vanilla unarmed material bypass=true.
- Three vanilla natural slots; explicitly inactive slots skip all draws.
- Active slot reflex gate: 70/60/50/40/30% for Very High→Very Low, before its independent hit check.

Example: weapon 3–6 averages 4, natural 4–5 averages 4, so retain weapon despite different unrounded averages. Natural 5–7 averages 6 and wins over that weapon. A retained ineffective weapon does not trigger automatic fallback. Active component gate failure skips only that component's downstream resolution.

## Required data

Stable attack/attacker/target identity and validity; explicit attack model; selected weapon/skill; validated weapon/first-natural base ranges; material ranks/requirements/bypass-equivalent policy; ordered active components/ranges; fixed reflex identity/resolved probabilities; policy/hook provenance; owned source and retained component resolution/application progress. Concrete schemas/rank mappings remain dependencies.

## Inputs, outputs and events

Inputs: authorized coherent attack context, validated route/material/component definitions and permitted resolution requests. Outputs: selected route/skill, material pass/bypass/ineffective outcome, ordered component gate outcomes or explicit invalid-state failure. This feature does not directly remove health, apply poison, consume charges or award practice. Concrete APIs/events remain unselected; COMBAT owns committed mutation/notifications.

## Cross-system interactions

NPC supplies enemy model/ranges and selection context; ITEM supplies weapon/material definitions; COMBAT authorizes attacks and owns resolution/termination/effect application. CHAR-010 supplies reflex parameters; RULE-013/014/016 own subsequent calculations/effects. RULE-001/003 provide probabilities/source/retry rules; RULE-004/DATA-003 validate locked mod policies. UI/AV distinguish ineffective material from miss; SAVE/CORE preserve valid session/operation state without replay.

## Edge cases and failure conditions

- Missing attacker/target/required weapon/model is an explicit invalid-context outcome, not an ordinary miss or silent hand-to-hand fallback.
- Ties and odd min/max sums follow integer floor; extended ranges cannot overflow comparison arithmetic.
- An absent first natural component cannot accidentally score as a valid strong attack; later components are not summed into baseline preference.
- Material equality passes; unknown ranks/required unarmed equivalent fail validation rather than become universal bypass/immunity.
- Inactive components differ from malformed active ranges. Mod lists must be finite/within supported bounds and preserve declared order.
- Gate failure/miss does not abort later components; actual death/interruption still follows COMBAT's explicit termination policy.
- Failed hooks or partial effect application require explicit recovery without silent vanilla fallback or whole-operation retry.

## Configuration and balancing options

Support moddable enemy selection policy, target material requirements, eligibility hook, unarmed bypass/equivalent rule and ordered component lists. Reflex overrides remain CHAR-010's validated parameters rather than duplicated contradictory settings. Explicit hooks must declare replacement/side-effect boundaries under RULE-004. No player automatic weapon switching, universal immunity workaround, unlimited component count or generic combat scripting framework is approved here.

## Save/load considerations

Restore authoritative actor/equipment/target facts and locked policy identity; derive route eligibility for future authorized attacks. Do not use fresh RNG to replay committed components/effects on load. Retained in-flight resolution/application state, cancellation and projectile/equipment capture timing require COMBAT/SAVE contracts; universal mid-attack save support is not introduced. RULE-003 fresh future randomness cannot duplicate saved effects or erase already retained results. Missing required definitions use explicit migration/recovery.

## Technical constraints

Target: Godot 4.7.2. Separate route selection, material gating, ordered component resolution and mutations. Use safe integer averages, explicit material mappings and owned unbiased combat draws. Do not retain DFU's zero-return ambiguity, mixed global RNGs or empty-slot draws. APIs, snapshots/live reread boundaries and persistence remain engineering/owner dependencies. No implementation or coding tasks are authorized by this draft.

## Acceptance criteria

1. Baseline armed enemies prefer strictly higher first-natural integer average; ties retain weapon and no unrelated modifiers influence comparison.
2. Selected-route material checks precede hit/damage; ineffective selected weapons yield a distinct outcome without automatic natural fallback.
3. Default unarmed bypass works; disabling it requires valid explicit equivalent data/rule, and unknown ranks/data fail rather than invent eligibility.
4. Three vanilla ordered slots and validated mod lists distinguish inactive/malformed components; inactive slots consume no draws.
5. Each active component uses unbiased reflex gate→hit→damage order, skipping downstream checks on failure without cancelling remaining active components.
6. COMBAT explicitly handles invalidation/death/interruption and exactly-once application; retries reuse resolved results rather than rerolling the sequence.
7. Mod policies/hooks validate before play; inspection/restore cannot apply damage/practice/effects or activate different locked providers.

These are future verification criteria. No implementation or runtime tests were performed or authorized in this interview.

## Consistency review

No direct contradiction identified with reviewed CHAR-010 and RULE-001/003/004. Approved reflex probabilities retain their separate preliminary role, now using unbiased combat draws. Empty-slot draw removal and purpose-owned randomness deliberately do not preserve DFU sequence coupling. Modded unarmed eligibility does not change the default bypass. Hit/damage/effect rules and COMBAT mutation/save boundaries remain unapproved by this feature rather than inferred from source.

## Outstanding questions and approval

No blocking gameplay policy question remains for routing/gating. Before implementation: finalize model/material adapters, policy/hook domains, component identity/list limits, source/order integration, hit/damage/body-part/effect boundaries, target invalidation/termination and resumable SAVE handling. These cannot waive integer-average/tie rules, route-before-material/no fallback, moddable unarmed bypass or active-component ordering.

The user explicitly approved the complete Draft v1 on 2026-11-06 with “I approve”. This specification is finalized v1 under RULE-012-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented engineering and combat-owner dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
