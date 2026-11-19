# COMBAT-004 — Attack frames, fatigue and practice

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Make a committed swing or arrow release take effect once, with predictable fatigue drain and skill-use tallies independent of rendered frame delivery. Melee swings can cleave nearby enemies by default; each distinct eligible enemy reached can provide practice, while the swing costs fatigue once. Costs, practice and interruption must remain coherent under low fatigue, weapon breakage, pauses and loading.

## Confirmed requirements

COMBAT-004-D01–D17 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record six interviews. D13/D16/D17 explicitly supersede D11's original once-per-attack melee-practice limit with per-eligible-enemy contact awards; the once-per-swing fatigue rule remains. D11 also establishes default cleaving, with exact acquisition/geometry deferred to COMBAT-005. The complete specification is approved under COMBAT-004-A01. COMBAT-001/002/003 and CHAR/RULE ownership remain binding.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths are relative to reference `Assets/Scripts/`.

- `Game/WeaponManager.cs#Update` checks current animation frame against hit frame, using isDamageFinished to guard the branch. It dispatches melee or bow release, drains swingWeaponFatigueLoss=11, then conditionally tallies skills.
- `Game/FPSWeapon.cs#GetHitFrame` returns frame 2 for non-bows and frame 5 for bows. These are animation markers, not universal elapsed durations. Exact rendered-frame equality is not the target delivery mechanism.
- MeleeDamage selects contact through spherecast/environment handling and a conditional ray fallback. WeaponDamage can return true for an enemy after CalculateAttackDamage even when damage is zero. The practice branch awards +1 active weapon skill or HandToHand and +1 CriticalStrike for such enemy contact.
- The bow branch creates a projectile and consumes an arrow; its later skill-tally branch executes without waiting for projectile impact. Local projectile/ammunition failures are not comprehensively guarded. Target release must validate and report explicit success/failure.
- The inspected player melee path selects one contact rather than providing the desired multi-enemy cleave contract. The user's DOS Daggerfall cleaving observation is context, not independently verified classic behavior or a source for invented cost rules.

## Detailed rules and behaviors

### Attack start and commitment

An admitted attack captures its identity/source, weapon or unarmed practice skill, configured fatigue cost, practice policy and RULE-015 timing at attack start. Later equipment/presentation/settings/effect changes cannot redirect those captured values. This does not freeze target state or every damage modifier; actual contact and target eligibility are checked at resolution under the captured policy.

Each attack has one explicit gameplay commitment marker synchronized with its visible strike or arrow release. Deliver it once when eligible gameplay progression reaches/crosses the marker, even if rendering never displays the exact frame. Animation/mod profiles may configure markers. Marker delivery itself is not permission to bypass readiness/source/release validation or deliver effects from a canceled attack.

COMBAT-001 precommit cancellation consumes no attack fatigue/ammunition; after commitment preserve completed costs/results. Canceled work cannot deliver a later strike/release. Pause freezes progressing attack time; load cancels unfinished attack portions under COMBAT-001 without replaying committed consequences. COMBAT-003 input recognition/admission alone grants no practice or costs.

### Fatigue and exhaustion ordering

Each committed melee swing or successfully released bow shot drains 11 internal fatigue units by default, regardless of hit/miss. Charge once per attack, including cleave, not once per target/collider. This is 11/64 of a displayed fatigue unit and is additional to independently owned ordinary activity drain. Fatigue cost is moddable and captured at attack start.

Use CHAR-018 saturating drain, explicitly permitting an otherwise eligible attack with less than its full drain available. Reach zero without overdraft. Already-zero fatigue remains subject to exhaustion restrictions; this rule does not permit attacking through an active collapse/death state.

For depletion caused by this attack's fatigue drain, settle its committed strike/release and eligible practice before processing resulting exhaustion consequences. The exhausting attack still takes effect, while collapse/death can block subsequent attacks. Coordinate depletion notification/consequence processing with CHAR rather than invoking death midway through eligible practice reports. This ordering exception applies to this drain, not arbitrary unrelated death or invalid actors. CHAR-012 still requires a qualifying living character/context; do not award practice to an already-dead character merely by retaining an old attack reference.

### Melee contact practice

Each distinct eligible enemy actually reached by the attack's resolution grants +1 captured weapon skill, or Hand-to-Hand for unarmed, and +1 Critical Strike. Contact eligibility does not require a successful accuracy roll, positive damage or actual health loss. An invulnerable/material-immune combat actor can qualify. Shield-hand unarmed attacks use the captured unarmed source under COMBAT-002, not a shield weapon skill unless an explicit mod changes the attack policy.

Default qualifying targets are living combat actors, including currently peaceful/pacified ones. Corpses, ordinary civilian NPCs, doors, scenery and empty air do not qualify. Attacking peaceful targets still has applicable hostility/legal consequences. Target eligibility and supported practice amounts/cadence are moddable.

Award each target at most once per attack identity, deduplicating by actor identity rather than collider. Targets skipped by interruption grant nothing. A true new swing may award again: no baseline per-target cooldown or diminishing returns is added. CHAR-012 owns capped raw counters, duplicate-report protection and separation from skill advancement. A raw +1 report need not increase a counter already at its cap and is not an immediate skill-level increase.

### Cleaving

One melee swing can strike multiple nearby enemies by default. Fatigue is once per swing; practice is per distinct eligible enemy reached, as above. Cleave selection, reach, obstruction, target cap, geometry and authoritative target order remain COMBAT-005 decisions, not invented area/radius constants here. Cleave and award behavior must be moddable.

Each reached enemy receives independent hit/damage resolution. One miss, immunity or ineffective-material result does not automatically suppress other targets. If the active weapon breaks during one target's resolution, preserve that target's committed outcome and stop remaining strikes from the attack under COMBAT-001. Already resolved targets/results remain; skipped targets grant no practice. No replacement/unarmed continuation is implied.

Per-target effects, weapon wear, modifier snapshots/live rereads and consequence ordering remain RULE/COMBAT/ITEM contracts. Target order matters when breakage or other interruption occurs, so COMBAT-005 must define it before implementation. A single commitment marker can own an ordered multi-target operation; it does not authorize duplicate commitment per target. Multi-target failure recovery must retain completed target outcomes without blindly replaying them.

### Bow release and practice

Each successfully released arrow grants +1 Archery and +1 Critical Strike at release regardless of later contact, with no second award on impact. Empty-space practice remains allowed at ammunition/fatigue cost. Award amounts/eligibility are moddable. Bow impacts and multiple impacted colliders cannot repeat release practice.

Validate ammunition at release. Missing/invalid ammunition cancels without projectile, ammo consumption, attack fatigue or practice; retain captured bow cooldown under COMBAT-001. Technical projectile-creation failure enters explicit recovery, not false release success or a retry that duplicates costs. COMBAT-007/008/009 and ITEM must define safe release commitment, projectile activation and consumption order; do not claim universal rollback for a failure after mutation. Already committed facts require owner recovery, not reroll/re-release. Bow start/cooldown and in-flight persistence remain separate contracts.

## Relevant formulas and parameters

For captured nonnegative attack drain F (vanilla 11), current fatigue becomes max(0,current−F) once per committed attack, using CHAR units/validation. Do not scale F by target count, displayed-unit conversion or rendered frames.

For K distinct eligible melee enemies reached before interruption, submit K baseline +1 reports for captured weapon/Hand-to-Hand and K +1 reports for Critical Strike, each with attack/target identity. K=0 yields no melee practice. Each successful arrow release instead submits one +1 Archery and one +1 Critical Strike report, independent of later impacts. CHAR-012 applies saturation and rejects malformed reports. No per-target fatigue multiplier, practice diminishing-return formula or cleave radius/cap is selected here.

Reference non-bow/bow hit frames are 2/5. Target marker profiles must align with the actual authored animation and RULE-015 captured durations, handle crossing/idempotency, and remain valid under modded frame sequences. Timing representation and exact mod validation bounds remain engineering dependencies.

## Required data

Attack/session/character identity; captured attack source/skill, timing, marker and fatigue/practice policy; authoritative phase/commitment/cancellation state; release ammunition/projectile preparation; ordered actor identities/contact outcomes; per-target resolution/practice completion; once-only fatigue/release practice status; active weapon validity; eligible elapsed time and exhaustion consequence context. Use bounded lifetime-scoped completion records rather than unbounded global histories or raw collider references as durable identity.

## Inputs, outputs and events

Inputs: admitted attack, eligible progression crossing marker, contact/target state, damage outcomes, source breakage/interruption, ammunition/projectile preparation result and fatigue mutation. Outputs: committed melee or release outcome, one fatigue drain, qualifying raw practice reports, remaining-target cancellation, explicit failed release/recovery and deferred exhaustion consequence handoff. Concrete APIs/signals remain unselected. AV notifications/voice/sounds cannot independently commit gameplay or consume gameplay practice/randomness on refresh.

## Cross-system interactions

Confirmed extension: COMBAT-008-D13–D15 define optional modded multishot with one attack-level fatigue charge/cooldown and release practice per successfully released ammunition-bearing arrow, rather than one award for the entire volley. The baseline remains one arrow. See [COMBAT-008](COMBAT-008.md) for its separate approval status and detailed conservation/recovery contracts.

COMBAT-001 cancellation/cooldown/load; COMBAT-002 attack source and modded hands; COMBAT-003 input; COMBAT-005 cleave acquisition/order; COMBAT-007–009 release/projectiles; COMBAT-010 onward hit effects/intake/feedback; RULE-012–016 independent eligibility/damage/wear/timing; CHAR-012 practice, CHAR-013 advancement, CHAR-018 pools and CHAR-022/023 exhaustion/death; ITEM weapon/ammunition mutation; NPC/LAW target status/consequences; CORE eligibility/ordering; AV animation synchronization; SAVE committed state and MOD/DATA validated policies.

## Edge cases and failure conditions

Test marker crossing under slow rendering, duplicate callbacks, cancellation at commitment, weapon break during cleave, multi-collider targets, peaceful/invulnerable actors, previously dead targets and a target disappearing between acquisition and resolution. Contact must remain currently valid; a candidate list alone does not grant practice. Independent target failures are distinct from technical operation failure after mutation.

Low-fatigue attacks may cause exhaustion; practice/strike settle before that drain's consequences, without granting immunity to unrelated interruptions. Genuine repeated target attacks and empty-space arrow practice are accepted balance choices, not bugs to silently suppress. Mods can alter declared policies.

Bow release with changed/missing ammo must not consume nonexistent ammunition or create a cost-free successful shot. Repeated delivery/recovery cannot duplicate fatigue, release, target effects or practice. Partial-operation failure needs explicit owner recovery; presentation failure cannot repeat completed gameplay work.

## Configuration and balancing options

Moddable marker profiles, fatigue amounts, practice amounts/eligibility/cadence, cleave and per-target award policies. Baseline cleave is enabled; melee practice is contact-based per enemy, bow practice release-based; neither requires positive damage. Exact schemas/allowed numeric bounds/provider precedence and supported alternative exhaustion ordering remain owner contracts; no general arbitrary callback API or vanilla anti-grinding policy is introduced.

## Save/load considerations

COMBAT-001 cancels unfinished attacks on load while retaining committed results/costs and applicable cooldown. Save enough authoritative completion state or constrain save boundaries through SAVE so loading cannot repeat a fatigue drain, target strike, practice report or projectile release. Do not restore animation equality as evidence that commitment should run again.

Multi-target operations and depletion ordering require a coherent snapshot boundary; exact mid-operation save admission/representation is unresolved SAVE integration work, not approval to abandon a pending exhaustion obligation or replay resolved targets. Captured configuration/timing must not be recomputed from later settings. Practice counters persist under CHAR-012. Released-projectile persistence remains separately owned.

## Technical constraints

Target Godot 4.7.2. Gameplay commitment must survive crossed/skipped visual frames and execute at most once per attack. Keep ordered target resolution, cost/practice mutation, interruption and exhaustion notification distinct but coherently sequenced. Use stable source/target identities, typed outcomes and checked owner operations. No universal transaction/rollback framework is mandated. Native scheduler, atomicity/recovery, schemas and animation fixtures require verification. No implementation or coding tasks are authorized.

## Acceptance criteria

1. An accepted attack commits once at its synchronized marker even when rendering skips it; rejected/canceled-before-marker attacks never commit later.
2. Every committed swing/released arrow drains captured fatigue once, vanilla 11 internal units, regardless of miss or cleave target count.
3. Insufficient positive fatigue saturates to zero; the attack and eligible practice settle before that drain's exhaustion consequences. Already-exhausted/dead actors cannot exploit stale attacks.
4. Each reached living eligible combat actor grants +1 captured weapon/Hand-to-Hand and +1 Critical Strike even on failed accuracy/zero damage; peaceful/invulnerable eligibility is preserved.
5. Empty-air/environment/civilian/corpse contacts grant no default melee practice. Target eligibility/amounts support explicit validated mod policies.
6. Cleave can resolve multiple nearby enemies under COMBAT-005's eventual geometry/order; each has independent accuracy/damage and per-target practice, but fatigue remains once.
7. Repeated colliders/callbacks cannot multiply a target's practice within one attack. Genuine new swings can practice again without a hidden cooldown/penalty.
8. Weapon break retains current target's committed outcome, stops remaining targets and grants nothing for skipped targets; no replacement-source continuation occurs.
9. Successful arrow release grants one Archery/Critical Strike award without requiring a hit; impacts cannot award it again.
10. Missing/invalid ammo cancels release without projectile/cost/practice but keeps bow cooldown; technical failures use explicit recovery without duplicated consequences.
11. Captured source/cost/practice policy survives later changes; actual target eligibility is checked at resolution. Pause/load/retries do not replay costs/effects/practice or erase required exhaustion outcomes.

## Contradiction review

Reviewed against approved COMBAT-001/002/003, CHAR-012/018/020/022, RULE-015 and relevant RULE-012–016 combat ownership, plus the COMBAT feature catalog/architecture. No direct contradiction identified. Saturating attack drain is an explicit owner-approved exception to ordinary sufficient-resource spending. Depletion consequence ordering preserves CHAR's qualifying-living-character rule rather than authorizing post-death practice. D13/D16 explicitly replace the earlier once-per-attack melee award with per-target awards. Default cleave is a new confirmed intended behavior; COMBAT-005's unreviewed single-contact analysis does not override it. Active-weapon break still invokes COMBAT-001 cancellation. Architecture proposals remain Proposed outside confirmed requirements.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation, COMBAT-005 must establish cleave geometry/reach/obstruction/cap/order; owners must settle per-target effects/wear and interruption order, release atomicity/recovery, marker/profile schemas, numeric bounds, fatigue/practice/exhaustion handoff and save boundaries. These dependencies cannot silently revert cleave to single-target, per-target practice to once-per-swing, or contact eligibility to successful-damage-only. Classic parity remains unverified.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-004-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented cleave targeting, ordering, release/recovery, exhaustion handoff, save and native verification dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
