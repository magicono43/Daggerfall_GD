# Actor input profile

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
