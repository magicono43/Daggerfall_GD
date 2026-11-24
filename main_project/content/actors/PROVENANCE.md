# Actor input profile

## IMP-016 death and projections, 2026-11-24

`death.json` and `vitals.json` are project-authored CC0-1.0 policies encoding
approved CHAR-023/UI-006 defaults and bounded supported presentation choices.
They redistribute no classic sound/movie/texture bytes. Survival's 1/10 fraction
with minimum one intentionally corrects zero-health small-maximum prevention;
it is approved policy, not original-executable parity. Default fade/total return
are 2/3 presentation seconds. Default eight compact effects, coloured bars,
280-pixel width, generic diamond and camera lowering distances are project
engineering defaults, all within the documented supported interfaces.

Default audio `classic-ordinal-405` is grounded in read-only local DFU
`Assets/Scripts/Game/PlayerDeath.cs:31`, `SoundClips.cs:503` and
`API/SndFile.cs:GetSound`: WoodElfMalePain1 is 405 and sounds use physical BSA
ordinals, not directory record IDs. The existing classic reader retains both
identities. DFU's MIT notice remains at `scripts/rule/DFU_LICENSE.txt`.
Race/form-dependent voice selection is not inferred. ANIM0012.VID is requested
from the original external source once through the existing AV consumer;
unavailable playback is reported Failed, never substitute success or death text.

`profile.json` is project-authored structural format metadata, created 2026-11-21
for IMP-009 increment 1. Dedicated to the public domain under CC0-1.0. It contains
no copied classic payload, DFU biography text, gameplay values or executable code.
It is loaded with Godot FileAccess from `res://content/actors/profile.json`,
including in Windows debug/release PCK exports.

## IMP-016 focused baseline, 2026-11-24

`baseline.json` is project-authored CC0-1.0 numeric policy for CHAR-011: eight
approved attributes, 35 stable classic skill identities, permanent bounds 0..100,
attribute caps 100 and fatigue precision 64. No classic source bytes/text are
redistributed. These values remain replaceable through DATA/MOD/loose overrides.

Career skill ordinal mapping and multiplier extraction were inspected read-only
in local DFU 1.1.1 `Assets/Scripts/API/DFCareer.cs`: skill indices 0..34, spell
multiplier bit mask 0x1c00. Policy table keys are mask>>10 (0..7); ratios are
3/1, 2/1, 7/4, 3/2, 1/1, 1/2, 3/1, 3/1. Cases 6/7 explicitly adopt DFU's default
3x interpretation; they are not evidence of original-executable behavior. The
ratio representation avoids fractional truncation. DFU is MIT; its notice is
retained at `scripts/rule/DFU_LICENSE.txt` and included in existing export inputs.
Exact local source hashes and independently read CLASS00/01/02 hashes/fields are
in `tests/actor_state_observation.json`; exact upstream Git commit is unavailable.

RULE helpers implement the approved specification arithmetic, including floor on
negative modifiers and no original-game negative-healing adjustment. Health uses
career HP-per-level from the actual published class record, not a universal
default. CHAR qualifies only HP, multiplier and unique mapped progression groups;
all other career/creation/biography/appearance semantics remain external gates.
CLASS18/enemy source-only metadata, ambiguous FLATS alternatives and the accepted
guarded BIOG correction remain unchanged. No structural semantic_ready flag is
globally enabled. Original/reference/base inputs remain read-only.

## IMP-016 vital intake, 2026-11-24

The increment-2 request/retention schemas and admission/continuation interfaces
are project-authored engineering contracts implementing approved CHAR-018/023
and GAD-02/03/09. They add no source data, copied DFU code, balance parameter,
library or formula hook. Existing numeric DATA/MOD/loose precedence and licensing
remain unchanged. Unavailable lethal ownership rejects intake unchanged; this
does not qualify prevention, death, collapse, native SAVE or executable mods.

## IMP-016 activity policy foundation, 2026-11-24

`activity.json` is project-authored CC0-1.0 data encoding the approved CHAR-020
rates, priority, Athleticism ratios, jump cost, 0.25 simulated-second Running
cadence and CHAR-012 raw practice cap of 20,000. The specification documents
DFU's source baseline and intentional corrections to frame/minute accounting.
This adds no copied source code or classic bytes and makes no original-executable
parity claim. Existing DFU attribution/license remains above. All values use
the existing checked DATA/MOD/loose publication; numeric envelopes and exact
microsecond rational arithmetic are project engineering choices. This incomplete
foundation does not execute movement, checks, practice or collapse.

## IMP-016 increment 3 activity/collapse, 2026-11-24

The earlier incomplete foundation is now extended by the composed CHAR intake
and retained episode implementation. `recovery.json` is project-authored CC0-1.0
data encoding approved CHAR-021/022 coefficients (60/100 health terms, divisor
1000, pool divisor 8, minimum 1, Medical +1 and a single 60-minute safe hour).
Default exhaustion outcomes remain safe-hour on safe land and the normal lethal
request for swimming/threat. Breath recovery defaults instant; explicit gradual
rate/delay overrides use the supported scheduling contract. No consumption or
drowning cadence, threat distance, prevention chance or racial bonus is invented.

Recovery formulas follow the approved specification's DFU-derived integer
baseline; `activity_formulas.gd` is project-authored implementation, with the
existing DFU MIT attribution/notice retained. The corrected interval/remainder,
event-identity, completed-hour and once-only episode behavior are intentional
recreation differences, not original-executable verification. MOVE-012's approved
one-successful-transition rappel practice supersedes ambiguous per-update source
behavior. Classic/reference/base files remain unchanged and read-only. No new
library, native adapter, executable MOD language or globally enabled semantic
readiness is introduced.
