# IMP-016 increment 4 review — 2026-11-24

Increment 4 implements death/prevention and actual vitals/effects presentation
through the existing CHAR, CORE, DATA, AV, MOVE-view and UI composition. It awaits
explicit user acceptance. Increments 1–3 remain accepted; parent IMP-016 and M2
remain open. Changes are uncommitted for GitHub Desktop review.

## Authoritative behavior

Ordinary lethal health damage and exhaustion now use the same indexed CHAR
resolver. Required unavailable prevention remains pending and save gated.
A ready empty catalog permits death. Sources sort by checked priority then
identity; decisions and success-cost receipts retain committed prefixes across
technical retries. Benefit owners retain their RNG decisions and costs; CHAR
does not implement faction rank/chance, inventory or effects gameplay.

The default successful prevention debits the actual damage and restores
`max(1,floor(maximum/10))`, capped at maximum. Those changes publish coherently.
The retained result exposes requested/applied/remainder/restored/final values.
Exhaustion preserves historical pending receipts, unresolved zero-fatigue
episodes and independent holds. Filling fatigue alone cannot settle an episode.

Death publishes once before CORE confirmation and notifications. CORE checks
the composed CHAR owner and retained death fact. Ordinary late gameplay rejects.
Diagnostic reconstruction validates typed raw and cross-ledger schemas, detaches
the request before foreign callbacks and cannot reroll, charge, refill or replay
death/presentation. It does not qualify ordinary dead saves or native SAVE.

## Visible behavior

The committed-death observer uses an independent clock: two-second HUD fade and
three-second initial return interval by default. Cosmetic view lowering leaves
MOVE physical pose unchanged. Default audio is decoded classic sound ordinal
405; race/form voice selection remains open. Missing camera/audio cannot trap
return. Busy CORE operations retain priority; the observer waits with scoped
intent and yields its cover to recovery UI.

CORE routes one original ANIM0012.VID attempt through real delivered AV.
Qualification decodes original movie frames, deliberately skips with fresh input,
and retries a failed menu without replaying the movie. It does not claim an
unskipped whole-movie review or full IMP-035 delivery. Held initial/movie inputs
remain release fenced through handoff and cannot activate the menu.

The actual stock HUD shows health/fatigue/magicka at full capacity, safe empty
zero maxima, exact status values and CHAR-owned breath visibility. MAGIC supplies
only disclosed grouped effects. Effective unsuppressed warnings take priority;
steady markers, stable ordering, generic icons, reachable overflow and component
details preserve disclosure. Missing disclosure is explicitly unavailable.
Reads, resize, pause/hide/reveal and details cannot advance gameplay or consume RNG.

The checked DATA seam supports targeted labels/order/visibility/format/height/
RGBA/anchor/width/capacity and complete replacement with either supported
data-defined bars or numbers template. MOD and captured-loose precedence are
exercised. Arbitrary executable view factories/shapes and package loading are not
enabled by these two supported templates.

## Remaining named integrations

- Real complete FACT/MAGIC/ITEM prevention and equipment/effect combinations:
  IMP-018/032/034/058. The labelled controlled directory qualifies the owner
  contract, including missing required owners; it cannot certify those systems.
- Real MAGIC-010 disclosed-effect production, actual combat/casting, MOVE/TIME
  activity/catch-up, trait/threat/recovery producers and breath consumption/
  drowning retain their existing owner obligations.
- Native SAVE/restore and persistent identity: IMP-023/GAD-01. Typed diagnostic
  checkpoints are test inputs only.
- Race/form death voice selection, full cinematic handling and complete entry:
  named AV/identity and IMP-035 integrations.

See [execution evidence](IMP-016-increment-4-2026-11-24.md),
[machine audit](IMP-016-increment-4-2026-11-24.audit.json),
[lethal contract](../../../main_project/scripts/char/DEATH.md) and
[UI contract](../../../main_project/scripts/char/VITALS_VIEW.md).

## Reviewed rendered frames

![death-vitals-status](../../../main_project/tests/.runs/imp016-increment4-final/review/death-vitals-status.png)

![death-vitals-narrow-enlarged](../../../main_project/tests/.runs/imp016-increment4-final/review/death-vitals-narrow-enlarged.png)

![original-death-movie](../../../main_project/tests/.runs/imp016-increment4-final/review/original-death-movie.png)

All 12 selected commands passed (6,884 assertions); exact counts and limitations are in the execution audit.
