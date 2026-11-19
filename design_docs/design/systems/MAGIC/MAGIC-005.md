# MAGIC-005 — Touch, projectile and area targeting

Approval status: **Approved — finalized v1.** User approved the complete Draft v1 on 2026-11-09: “I approve”.
Updated: 2026-11-09.

## Gameplay purpose

Resolve spell aim, origins and potentially eligible recipients while preserving checked physical delivery, stable released power and independent per-effect admission.

## Intended player experience

Aim can change during wind-up. Touch needs valid close contact; ranged spells may be fired without an acquired actor. Areas affect valid recipients independently without default strength division or falloff. Walls shield actors, ordinary projectiles do not track targets, and targeting does not reveal hidden defenses. Explicit validated mods can change supported targeting/flight/area profiles.

## Confirmed requirements

MAGIC-005-D01–D09 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md) confirm release-time player aim, empty-space ranged casting, caster-area origin/empty-area legality, potential touch eligibility, baseline area strength, explicit NPC aim, captured caster power, current recipient eligibility and nondisclosing feedback. The complete specification is approved under MAGIC-005-A01.

Approved COMBAT-014 supplies contact, obstruction, per-actor delivery deduplication, area candidate ordering, collision-versus-effect eligibility, modded lingering/repeated delivery and native persistence. MAGIC-003/004 supply readiness, release checks/payment and once-only commitment. These are inherited requirements, not reopened recommendations.

## Existing Daggerfall Unity behavior — reference only

Baseline: local DFU 1.1.1 Release snapshot; exact commit unavailable per [repository overview](../../../analysis/00_REPOSITORY_OVERVIEW.md). Static inspection only; runtime/classic parity and native geometry fixtures unverified. Reference source unchanged. Symbols below are in reference `Assets/Scripts/Game/`.

- `MagicAndEffects/EntityEffectManager.cs#CastReadySpell` checks player touch range before animation; release later dispatches self effects or a DaggerfallMissile. `InstantiateSpellMissile` selects an elemental prefab.
- `DaggerfallMissile.cs#GetEntityTargetInTouchRange` spherecasts TouchRange=3.0 with radius 0.25 and backward origin adjustment 0.1. `DoTouch` queries aim again, excludes caster and shows an impact flash even with no recipient.
- `DoMissile` obtains aim and places the missile at aim position plus ArmLength. The caster's collider is ignored. Default spawn offset alone does not establish a checked path through near geometry.
- `DoAreaOfEffect` overlap-queries ExplosionRadius, excluding caster for caster-centered area but not ordinarily ranged explosions. It has no explicit obstruction check here; temporary collection can repeat actors with multiple colliders before AddRange.
- `AssignPayloadToTargets` sends bundles to effect managers and silently skips a missing manager. Target technical failures instead require explicit handling under approved COMBAT-014/MAGIC-004.

Source behavior does not automatically approve backward touch reach, duplicate application or wall-penetrating areas.

## Detailed rules and behaviors

### Aim and mode origins

Ordinary player spells sample current authoritative aim at release, allowing changes during unpaid wind-up. Do not lock onto the actor initially pointed at. Touch resolves current forward contact; ranged launches along current aim. Cosmetic origin offsets cannot bypass collision. Exact camera/cursor aim integration and collision masks require native fixtures under MOVE/COMBAT contracts.

NPC casting uses explicit AI-provided release aim and the same checked world/contact rules. Ordinary flight retains released trajectory; later AI target changes cannot steer it. Prediction, aim error, lock-on and homing require explicit AI/spell profiles rather than hidden target following. Modded lock-on/homing may differ from ordinary player aim under a declared validated contract.

Caster-only effects apply to their caster through normal MAGIC admission. One-shot area-around-caster originates at caster position at release, not selection position. It excludes caster by COMBAT-014 default, independently of the caster-only mode. Empty areas remain valid paid releases; recipient count cannot become a hidden-actor detector through cast rejection.

Ranged spells may release into empty space without a crosshair actor or distant hit. Subsequent miss/expiration is a paid outcome. Ordinary area-at-range detonates at checked impact under its profile; arbitrary crosshair-point detonation is not introduced. A near launch obstruction receives released impact rather than being bypassed by visual spawn offset. MAGIC-004 preparation failures remain distinct from normal valid world impacts.

### Touch eligibility and activation

Touch requires one potentially eligible actor within reach with unobstructed valid forward contact at release. Include close overlaps without reaching behind caster or extending effective range through acquisition width. Caster is excluded from ordinary touch; use caster-only mode for self effects. Solid blockers cannot be searched through to find a farther actor.

An actor is potentially eligible if at least one active effect can address it under declared applicability, such as relationship/type restrictions. Mixed bundles are not rejected merely because some entries cannot apply. Do not test hidden immunity, roll resistance/chance or run effect startup as acquisition. An acquired actor resisting all effects later is a normal paid result.

At actual application, each effect checks current relationship and living/dead eligibility. Corpse targeting requires explicit effect support. Changed eligibility cannot redirect to another actor or refund committed release. Independently eligible effects in a mixed bundle may still apply. A physically blocking but effect-ineligible actor is not automatically transparent.

MOVE-018 remains binding: non-touch readied spells own activation; touch gets first refusal on eligible in-range contact, otherwise permitted environmental interaction may proceed. Accepted/blocked spell attempts cannot also interact. Exact native blocker/ineligible-contact arbitration must preserve this contract without silent search-through or partial-action fall-through.

### Ranged collision and areas — inherited COMBAT-014 rules

Ordinary ranged delivery stops at first valid blocking actor/world contact. Resistance does not grant pass-through. Check origin-to-offset and traveled segments, use nearest valid blocker and declared tie rules, and respect closed doors/effective world blocking. Explicit profiles may change collision/pass-through/flight; arrow-only policies are not copied automatically.

Areas use configured shape/radius with no default recipient cap. Deduplicate by stable actor identity, including multiple colliders and direct-hit-plus-area inclusion: one bundle delivery per actor per delivery event. Clear path from area origin to a valid contact is required by default; walls/closed doors shield actors. Obstruction is moddable; geometry tolerances cannot leak through a wall or arbitrarily move an explosion across it.

Freeze each one-shot candidate set, qualify contacts, sort nearest valid contact then stable actor identity, and revalidate before each delivery. Skip removed/ineligible/out-of-range/blocked recipients without adding later arrivals or repeating completed ones. Query overflow needs complete collection or explicit recovery, not a hidden cap.

Caster-centered area excludes caster by default; ranged explosions may include caster if otherwise valid. Explicit spell/mod policies may override inclusion and ally/passive applicability. Harmful friendly fire and beneficial delivery remain distinct, with NPC/LAW owning classification/consequences.

Ordinary areas apply normal effect strength independently to each eligible recipient without dividing among targets or reducing with distance. Support explicit validated falloff/distribution profiles. Exact formulas, units and distribution/frozen-set semantics for those nondefault profiles must be documented before use; no default curve is selected. Per-effect defenses and normal randomness may still produce different outcomes.

Lingering/pulsed/entry-driven areas remain explicitly supported mod profiles under COMBAT-014. Define lifetime, shape, cadence/entry rules, origin anchoring versus following, recipients and stack/refresh behavior. Each pulse has a fresh candidate set and distinct delivery identity. No implicit indefinite field, every-frame application or unrestricted stacking is approved.

### Released payload and current defenses

Capture resolved spell settings, caster level, relevant school skills and source-owned effect-power modifiers at release. Retain stable caster/source attribution even if the caster later changes, dies or leaves scene. Later caster changes cannot rewrite airborne offense. Each cast/payload has independent state; mutable global last-spell data cannot supply its power.

Target defenses and recipient eligibility are current at application under RULE-017 and MAGIC admission. This snapshot does not pre-roll every recipient's outcome, define magnitude formulas or force identical random results across recipients. Specialized effects needing ongoing caster state must declare an explicit owner-supported exception; missing source cannot silently bind to a replacement actor/item.

Once-only payment, practice and history belong to MAGIC-004. Delivery/impact cannot award release practice again. Missing required effect managers/definitions or partial target application is explicit technical recovery under COMBAT-014, not ordinary immunity or permission to replay the whole area.

### Feedback and preview

Failed touch attempts provide ordinary contact/reach/declared-restriction feedback without exposing hidden immunity/resistance. No mandatory aim highlight is added. Valid empty caster areas and empty-space ranged releases cannot reject to reveal concealed recipients.

Validated mod indicators may customize targeting presentation while respecting visibility/knowledge rules. Preview/acquisition cannot roll defenses, mutate gameplay, consume resources or disclose otherwise hidden actors. Exact wording/contact diagnostics and indicator schemas remain UI/owner integration work rather than a generic popup layer.

## Relevant formulas and parameters

Inherited COMBAT-014 initial profile defaults: touch reach 3.0/acquisition radius 0.25; missile speed 25 reference units per eligible second, collision radius 0.45, lifetime 8 eligible seconds; area radius 4.0. Per-spell/mod overrides and native-scale verification remain required. Acquisition thickness cannot extend true reach.

Default area strength multiplier is 1 per recipient independent of count/distance, before effect-specific evaluation/defenses. One delivery/actor has at most one bundle delivery; each declared pulse is a new delivery. No default falloff, target cap, pulse interval, homing turn rate or caster-scaling formula is introduced.

## Required data

Stable spell/cast/caster/source/delivery/actor identity; resolved target/element and profile; release aim/origin; captured power inputs; current contact/obstruction/relationship/living-state data; ordered candidate set and completion results; per-effect applicability; lifetime/trajectory/area pulse state; mod policy provenance and optional indicators. Exact numeric domains, contact masks, snapshot schema and profile/version representation remain dependencies.

## Inputs, outputs and events

Inputs: authorized release preparation, current aim/geometry/actors, resolved targeting profile, captured caster context, eligible simulation time and admission results. Outputs: prepared delivery or explicit invalid target/technical failure, checked impact/candidate set, once-only per-actor bundle submissions, retained results and optional feedback. Concrete APIs/signals remain unselected. Target acquisition does not itself constitute effect application or payment.

## Cross-system interactions

COMBAT-014 owns checked contact/delivery coordination; MAGIC-003/004 own preparation/commitment/timing/payment/practice/history. MAGIC-006/007 and RULE-017 own chance, immunity/defenses and per-effect outcomes. MAGIC-008–010 own effect lifetime/stacking/restore. NPC supplies aim/current relationships; LAW owns harmful consequences. MOVE-018/021 and CORE own activation/world blocking, location and suspension. DATA/MOD supply validated locked profiles/stable identities. UI/AV present optional feedback; SAVE links delivery/payload state through CORE-013 before simulation resumes.

## Edge cases and failure conditions

- Aim changes during wind-up: use release aim, not old actor. Invalid touch at release retains readiness with no payment/practice/history under MAGIC-004.
- Empty-space ranged cast or empty caster-area: valid paid release; no hidden-recipient disclosure through rejection.
- Near wall/door: receive checked impact; no spawn-through or area leak to far-side actors.
- Many colliders/direct hit plus explosion: actor receives at most one bundle for the event; separate pulses remain intentional repeats.
- Target relationship/death changes before application: revalidate effects, no substitute target/refund. Existing physical blocking remains separate.
- Caster skill/power/source changes after release: retained snapshot governs ordinary payload; target defenses remain current.
- Technical delivery/query failure: explicit recovery retaining completed outcomes, no silent truncated area or whole-area retry.
- Modded falloff, homing or moving lingering area: supported only with complete explicit profile; no guessed formula or indefinite lifetime.

## Configuration and balancing options

Support COMBAT-014 per-spell reach/shape/radius, obstruction, inclusion/applicability, collision/pass-through, flight and lingering profiles; additionally explicit falloff/distribution and AI/lock-on/homing profiles where supported. Snapshot exceptions require declared effect-owner behavior. Individual profiles/formulas and UI settings are not approved wholesale. Broader player-friendly-fire toggles, corpse effects or universal damage curves are not introduced.

## Save/load considerations

Inherit COMBAT-014 native persistence for released spell missiles and supported lingering areas within the same location: preserve committed payload/caster snapshot, flight/area position/state, remaining lifetime, pulse/entry progress and completed target/effect outcomes. Freeze during pause/loading; restore geometry/actors/references before progression. Do not respend, retally practice, reroll completed defenses or create an immediate duplicate pulse.

Different-location exit discards remaining delivery objects by default; same-location streaming/rebase preserves them. Already-applied lasting effects remain MAGIC lifecycle state. Pending committed effect obligations cannot be erased by cleanup. MAGIC-004 cancels unfinished wind-up on load independently of released-object persistence. Exact mid-impact save admission, schema/migration and partial-operation recovery remain SAVE/MAGIC contracts; classic/DFU import is outside scope.

## Technical constraints

Target Godot v4.7.2; Unity collider callbacks/prefabs do not define native architecture. Keep stable actors distinct from collider handles, released power separate from current caster state, and preview separate from gameplay mutations. Exact world scale, aim integration, contact shape/tolerances, origin placement, NPC aim contract, snapshot fields and profile APIs require fixtures. Reference source remains read-only; no implementation authorized.

## Acceptance criteria

1. Ordinary player release uses current aim without initial actor lock; NPCs use explicit release aim and ordinary trajectory does not follow later target changes.
2. Touch requires eligible unobstructed forward contact within reach; targeting does not roll defenses or expose hidden immunity.
3. Empty-space ranged and empty caster-area releases are valid; caster-area uses release position and default inclusion follows COMBAT-014.
4. Near obstacles, segment collision and area shielding prevent geometry bypass; physical blocking remains independent of effect eligibility.
5. Multi-collider/direct-plus-area contacts deliver once per actor/event; frozen ordered areas revalidate without adding late arrivals or silently truncating.
6. Ordinary area strength is undivided and has no distance falloff; explicit validated alternative profiles can override it.
7. Release captures declared caster power inputs; later caster changes cannot rewrite ordinary payload, while current recipient eligibility/defenses apply independently.
8. Mixed bundles can target actors potentially eligible for one effect; later ineligible effects do not suppress independent eligible ones or redirect delivery.
9. Touch feedback/mod indicators respect knowledge/visibility; preview has no gameplay/RNG side effects.
10. Native released-object restore preserves lifetime/progression/completion without duplicate payment/practice/delivery, independently of canceled wind-up.

These are future verification criteria. No implementation or runtime tests were performed during specification.

## Consistency review

Reviewed against approved COMBAT-014, MAGIC-003/004, MOVE-018 and recorded MAGIC-005-D01–D09. No direct contradiction identified. This feature specifies aim/snapshot/applicability choices while preserving approved physical contact, recipient ordering, caster inclusion, modded delivery and persistence. Failed touch release remains unpaid under MAGIC-004, whereas valid empty ranged/area releases commit normally. Potential eligibility does not precompute defenses or weaken complete-definition validation. Snapshot capture preserves COMBAT-014's current-defense rule rather than universal prerolling. No new damage/stacking/legal formula is approved here.

## Outstanding questions

No further blocking targeting player-policy choice is identified. Before implementation is complete: fixture-verify native scale/contact geometry and baseline profile assets; specify aim/cursor/NPC interfaces, effect applicability metadata and exact captured power fields; define supported falloff/distribution/homing/anchoring schemas and precedence, current-defense observation timing, hidden-information feedback, and coherent native partial-impact/pulse saves. Specialized ongoing-caster exceptions and corpse-target effects need explicit owner review. These deferrals do not permit wall leaks, duplicate delivery, hidden-defense probing or guessed profile behavior.

## Approval status

**Approved — finalized v1.** The user approved the complete Draft v1 on 2026-11-09 with “I approve”. Approval reference: MAGIC-005-A01 in [the gameplay decision log](../../GAMEPLAY_DECISIONS.md). Documented geometry fixtures, aim/applicability/snapshot contracts, mod profiles, feedback and native-save dependencies remain open. Approval does not initiate implementation, coding tasks or another feature review automatically.
