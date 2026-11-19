# COMBAT-014 — Magical contact and payload delivery

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-08: “I approve”.
Updated: 2026-11-08.

## Gameplay purpose and intended player experience

Deliver touch, ranged and area spell payloads to their actual valid recipients, respecting obstruction and per-spell eligibility without duplicate applications. Area effects can affect multiple actors. Support modded lingering areas, repeating deliveries and collision policies with explicit lifetime, stacking and persistence contracts.

## Confirmed requirements

COMBAT-014-D01–D16 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) record five interviews. D01 means once per actor per delivery, not one recipient per area. D10–D12 support nonvanilla modded lingering areas; each pulse has its own candidate set/delivery identity. The complete specification is approved under COMBAT-014-A01. MAGIC owns casting, costs, effect formulas, eligibility/resistance and stacking; COMBAT owns checked contact/delivery coordination.

## Existing Daggerfall Unity behavior — reference only

Local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity unverified. Source unchanged. Paths below are relative to reference `Assets/`.

- `Scripts/Game/DaggerfallMissile.cs#GetEntityTargetInTouchRange` spherecasts with TouchRange=3.0 and SphereCastRadius=0.25, offsetting origin backward 0.1. DoTouch excludes caster and shows impact even without a recipient. Target retains close-contact support but does not approve unsafe backward reach or effect from cosmetic flash.
- Target modes route ByTouch to DoTouch, SingleTargetAtRange/AreaAtRange to DoMissile, and AreaAroundCaster to DoAreaOfEffect(caster position,true). Impact area otherwise uses default ignoreCaster=false.
- `DoAreaOfEffect` overlap-queries ExplosionRadius without an explicit obstruction check. It checks targetEntities but appends newly collected entities only afterward, so multiple colliders for a newly found actor can enter its temporary list more than once. Target explicitly deduplicates by stable actor identity.
- `AssignPayloadToTargets` obtains an EntityEffectManager and calls AssignBundle. Payload assignment differs from arrow damage; missing target effect manager is silently skipped in this source path, not a complete target failure policy.
- Fire/Cold/Magic/Poison/Shock missile prefabs configure speed 25, ColliderRadius 0.45, ExplosionRadius 4 and lifetime 8. Exact native rendering/contact behavior and original assets require fixtures; source values are initial balance defaults rather than universal spell dimensions.

## Detailed rules and behaviors

### Committed payload and owner boundaries

At committed spell delivery capture spell definition, caster identity and relevant caster power inputs. Later caster buffs/debuffs/death or selection of another spell cannot rewrite released payload. MAGIC must define exact captured fields, effect formulas and source-cost/mutation requirements. This is payload capture, not preselection of all future recipients or a universal pre-roll of resistance.

Recipients use current eligibility/resistance at application under their declared effect policies and RULE-017. Actual actor/contact identity and retained delivery results must not depend on caster's later sensed target. Source attribution remains stable after scene removal; any mutation requiring extant source must address original identity through owner rules, never a replacement actor/item.

Delivery does not set spell cost/refund timing, magic skill practice, casting interruption, resistance formula or stacking. MAGIC/CHAR own those. COMBAT-001 readied/casting and MOVE-018 single-input arbitration remain binding: contacting an actor is not permission to both cast and perform ordinary activation.

### Touch delivery

Ordinary touch selects one eligible forward actor within configured reach, with unobstructed path to a valid combat/effect contact. Include very close overlapping actors; exclude caster from ordinary touch. Solid walls/closed blocking doors prevent contact. Broad acquisition thickness cannot authorize contact beyond reach or behind caster.

Use deterministic contact/collider mapping so an actor center behind a gap does not automatically negate a valid exposed contact, while solid barriers remain blocking. Nearest-contact/ineligible-actor and decorative-collider arbitration require explicit native masks/fixtures; do not search through a solid blocker for a farther recipient. Self-target spells remain a separate MAGIC mode. A no-recipient touch result and its optional flash are not successful effect application; cast costs/feedback remain MAGIC policy.

### Ranged collision and impact

Ordinary ranged spells stop at first valid blocking actor/world contact and deliver there or produce their configured area impact. A contacted actor resisting every effect does not permit pass-through. Physical collider eligibility and effect applicability are separate explicit policies: an ally excluded from effects still blocks unless a pass-through policy is declared.

Use checked origin-to-visual-spawn-offset paths, then full traveled-segment collision each eligible step, selecting nearest valid blocker. Solid world geometry wins effectively tied contacts, with stable identity for remaining ties under an explicit tolerance contract. A near wall receives released spell impact rather than being bypassed by an offset. Exact collision shape, initial overlap, moving-actor coverage and safe impact-origin placement need native fixtures.

Respect effective world/door blocking under MOVE-021, not merely interaction targetability. Mod policies may specify collision eligibility, piercing or alternative delivery/flight. Arrow-only exclusions/physical damage/recovery are not copied automatically onto spells; spell-specific caster/projectile masks and MAGIC behavior need explicit profiles. Cosmetic impact/audio cleanup cannot trigger another delivery or decide resistance.

### Area recipients, obstruction and ordering

Area spells can affect all valid actors in the configured impact area/range, with no default gameplay target cap. Radius/shape belong to particular spell/profile; not every spell has the same footprint. Deduplicate by stable actor identity across multiple colliders and direct-contact-plus-area inclusion: one impact delivers one bundle at most once per actor.

Require a clear path from area origin to a valid target contact point. Solid walls/closed blocking doors shield actors; overlap alone is insufficient. Obstruction policy is moddable. Contact sampling/geometry boundary tolerances must avoid an impact on a wall leaking to its far side or self-occluding all near-side recipients; exact method is engineering work, not permission to move explosions arbitrarily through geometry.

At each one-shot impact, freeze the candidate set, qualify contact/range/obstruction, sort nearest valid contact first and stable actor identity on ties. Revalidate each before delivery; removed/ineligible/out-of-area/blocked recipients are skipped without adding new arrivals or rerunning completed recipients. Exact observation/state timing must be declared. Technical query overflow requires complete collection or explicit recovery, never silent truncation masquerading as a gameplay cap.

Default caster-centered area excludes caster. Ranged explosions may include caster if otherwise valid inside blast. Explicit spell/mod policies may override caster inclusion; self-targeting remains separately defined. Allies, peaceful actors and civilians are candidates alongside enemies, but each spell/effect declares applicability. Support explicit policies excluding allies/passive creatures or including them. Harmful effects may cause friendly fire; beneficial area delivery is not inherently hostile. Relationship classification/legal consequences remain MAGIC/NPC/LAW contracts.

### Bundle application and independent outcomes

Pass each valid recipient a retained payload/delivery context through MAGIC's effect manager contract. MAGIC owns effect-level ordering, eligibility, resistance, absorption/reflection, duration and stacking. No second physical hit/material check is added merely because this is COMBAT delivery. Damage components eventually use their typed CHAR/COMBAT-013 intake without duplicate mitigation.

Ordinary resistance/ineligibility for one effect/recipient does not suppress other independently applicable bundle effects or valid area recipients. Retain per-effect/target results so technical retry cannot reroll resistance or reapply effects. Required missing definitions/managers and partial application errors need explicit recovery; they are not silent ordinary immunity and cannot trigger whole-area replay or provider fallback.

### Modded lingering areas and repeated delivery

Lingering areas after impact are supported mod behavior, not a vanilla default. Definition must explicitly provide duration, shape/radius, pulse interval and/or entry-trigger policy, caster/alliance eligibility, and effect stack/refresh/replace rules. Validate required numeric/cadence/state contracts; missing data cannot imply indefinite duration, every-frame damage or unrestricted stacking.

Each pulse has a distinct delivery identity and fresh candidate acquisition/revalidation. Once per actor per pulse permits the same actor on later pulses; the original impact's frozen candidate set does not persist across pulses. Entry-driven modes must declare reentry/cooldown/once-only counting rules. MAGIC decides whether repeated applications stack, refresh, replace or resist. Duplicate trigger callbacks cannot become intentional extra pulses. Exact schemas, supported timing/activation variants and bounded work policy remain MAGIC/MOD integration.

## Relevant formulas and parameters

Initial default profile values: touch reach 3.0/acquisition radius 0.25; ordinary missile speed 25 reference units per eligible second, collision radius 0.45, lifetime 8 eligible seconds; area radius 4.0. Per-spell/mod overrides supported; native world-scale/contact verification required. Width/collision radius must not secretly extend declared touch reach or area membership. Exact primitive/tolerance definitions remain engineering contracts.

For one delivery identity and actor, bundle delivery count<=1; total distinct recipients is not capped by that rule. Each pulse creates a new delivery identity. No default area damage falloff, fixed pulse interval, lingering duration or repeated-effect stacking formula is selected. MAGIC/RULE-017 own actual magnitude/resistance; source defaults do not authorize one universal spell range/radius or arrow speed.

## Required data

Cast/delivery/projectile/area/pulse and session/location identity; committed spell/caster power/configuration context; current target identities/contact geometry/eligibility; shape/range/obstruction/caster/alliance policies; frozen ordered per-delivery candidate set; per-target/effect completion and retained results; flight/area lifetime and next pulse/entry state; source attribution and owner costs; partial failure/restore status. Raw colliders/current caster fields are not durable delivery identity.

## Inputs, outputs and events

Inputs: MAGIC-authorized committed delivery, configured mode/profile, current geometry/actors, eligible flight/pulse time, effect manager results and lifecycle/save events. Outputs: no-contact/blocked/eligible recipient list, one checked bundle delivery per actor/event, retained effect outcomes, next pulse/expiration or explicit recovery, and optional presentation. Concrete APIs/signals remain unselected. Preview/acquisition cannot cast, spend magicka, grant practice, consume resistance RNG or apply effects.

## Cross-system interactions

MAGIC cast/definition/cost/payload/stacking/absorption/reflection; RULE-017 effect resistance and RULE-003 retained owned randomness; MOVE-018 touch/activation arbitration and MOVE-003 aim; MOVE-021 doors; COMBAT-009 projectile safety concepts, COMBAT-010/011 typed ordered outcomes and COMBAT-013 health intake. CHAR vitals/practice/death; NPC/LAW relations/legal consequences; LOC/WORLD geometry/location scope; AV optional impact presentation; CORE eligibility and SAVE native persistence; MOD/DATA validated profiles. MAGIC-specific target effect compatibility is not inferred from a collider alone.

## Edge cases and failure conditions

Verify multi-collider actors, actor in both direct/area collection, large/very close targets, barred openings, wall/door impacts, caster inside blast and effect exclusions separate from projectile pass-through. Area geometry must not leak through barriers or silently omit valid exposed contacts; sampling coverage requires fixtures.

Verify allied/passive exclusions for beneficial/harmful spells, changing relationship/status before application, disappearing/dead actors and independent per-effect resistance. No default corpse-target effect is invented; each effect eligibility remains MAGIC-owned. One target failing legitimately does not cancel the whole area; required technical failure does not rerun completed targets.

Verify lingering reentry/pulses, caster death, pause, long/slow frames, source changes, modded simultaneous pulse/expiry and query overflow. No catch-up from paused wall time, uncontrolled every-frame pulses or duplicate entry events. Explicit supported pulses can advance with valid simulation backlog under CORE; exact bounded overload policy must preserve delivery accounting.

## Configuration and balancing options

Moddable per-spell range/shape/radius and obstruction, caster/ally/passive eligibility, projectile blocking/pass-through, alternative delivery, repeating pulse/entry and lingering definitions. Initial values are confirmed defaults, not universal fixed constants. Exact schemas/provider precedence, caster snapshot fields, valid numeric limits, effect ordering/stacking and required manager contracts remain MAGIC/DATA/MOD dependencies. No vanilla lingering fields, friendly-fire toggle UI or global target cap is introduced.

## Save/load and location lifetime

Released spell missiles and supported lingering areas persist in native saves within the same location. Save committed payload/source, position/flight state, remaining lifetime, pulse/entry progression and target/effect completion sufficient to avoid repeated casts/costs/practice/completed deliveries. Freeze during pause/loading; restore world/actor references/geometry before eligible progression.

Different-location exit discards remaining delivery objects by default, matching COMBAT-009's bounded location scope. Same-location streaming/rebase preserves coherent state and cannot treat unready collision as empty space. Already-applied lasting effects remain governed by MAGIC lifecycle, not removed merely because delivery object despawns. Pending committed effect obligations require settlement/recovery and cannot be erased by object cleanup.

Exact mid-impact/pulse save admission, effect-result schemas/migration and partial-operation recovery remain SAVE/MAGIC contracts. Restore cannot create an immediate duplicate pulse, reroll completed saves/resistance, respend magicka or revive old input. Player health reconstruction remains consequence-free under CHAR-017/COMBAT-013.

## Technical constraints

Target Godot 4.7.2. Separate source snapshot, contact/candidate acquisition, effect applicability, per-target delivery, pulse scheduling and optional rendering. Stable actor/delivery identities and retained outcomes must cover direct-plus-area deduplication and partial retries. Explicit collision/query/ordering contracts replace physics enumeration or target-list membership bugs. Native geometry, timing, persistence and mod-definition fixtures require verification. No implementation or coding tasks are authorized.

## Acceptance criteria

1. One impact/pulse can affect multiple valid actors but delivers its bundle at most once to each distinct actor, including direct-plus-area overlap.
2. Ordinary touch selects one eligible forward noncaster within 3.0 initial reach/0.25 acquisition, supporting close contact without wall bypass.
3. Area recipients require configured area membership and unobstructed contact; closed solid barriers shield by default and overrides are explicit.
4. Caster-centered area excludes caster, ranged blast may include caster; allies/passive/civilian eligibility is explicit per spell/effect and moddable.
5. Ordinary ranged impact stops at first valid blocker despite resistance, with blocking separate from effect exclusion and checked spawn/swept-segment safety.
6. Committed payload/caster power remains stable while current recipient eligibility/resistance resolves through MAGIC.
7. Area collection has no default gameplay cap, uses nearest/stable order and per-recipient revalidation without adding newcomers during one event; overflow is never silent truncation.
8. Legitimate per-effect resistance/ineligibility permits independent effects/targets; technical failure preserves completion and enters recovery without full replay.
9. Modded lingering fields require explicit lifetime/cadence/eligibility/stacking; later pulses reacquire targets and can affect previous actors once each per pulse.
10. Default missile values are 25 speed/0.45 radius/8 eligible seconds and area radius 4, overridable per profile with native scale validation.
11. Native same-location saves preserve delivery/pulse state without repeated costs/results; pause freezes, location exit discards delivery objects but not independently applied lasting effects.

## Contradiction review

Reviewed against approved MOVE-018, RULE-017, COMBAT-001/009–013 and CORE suspension/load ownership plus source/catalog/architecture. No direct contradiction identified. Area multiplicity and per-actor deduplication are compatible; per-pulse identity explicitly extends one-shot candidate freezing. Ally effect exclusion and collision pass-through are distinct confirmed policies. Area obstruction intentionally differs from source overlap-only behavior. Spell capture/current resistance does not adopt weapon physical formulas or arrow recovery. Lasting effects retain MAGIC lifecycle across delivery-object cleanup. Broader architecture proposals remain Proposed outside confirmed contracts.

## Outstanding questions

No further player-facing choice is identified as blocking this draft. Before implementation: MAGIC captured field/effect/stack definitions; touch/collider arbitration; contact sampling/impact-origin tolerance; flight masks/initial overlaps; event/recipient ordering and complete queries; pulse/entry numeric bounds/overload schemas; resistance/technical-failure recovery; location/streaming and native save fixtures. These cannot reduce areas to one target, duplicate bundles, leak through walls, silently equate ally exclusion with pass-through or invent unbounded lingering damage. Casting-cost and effect-content MAGIC reviews remain separate work.

## Approval status

The user explicitly approved the complete Draft v1 on 2026-11-08 with “I approve”. This specification is finalized v1 under COMBAT-014-A01 in [the decision log](../../GAMEPLAY_DECISIONS.md). Documented MAGIC definitions, contact/collision fixtures, pulse policies, recovery and native persistence dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review.
