# RULE numeric interfaces — IMP-006 increment 1

`pcg32.gd.create(initstate, initseq)` takes exactly four little-endian unsigned
16-bit limbs for each unsigned 64-bit input. Invalid limbs return null. Use
`unsigned64.gd.from_int` for signed bit patterns or `from_bytes` for little-endian
bytes. Constructors are not initialized sources; use the checked factories.
`raw()` returns `{ok, value}` (unsigned 32-bit integer in Godot's signed 64-bit
integer). `bounded(b)` accepts integer 1..4294967295 and returns `{ok, value,
raw_requests}`. Failed input validation draws nothing. `raw_count` excludes the
two initialization transitions; `logical_count` counts successful bounded draws.
Callers observe these counters; they must not modify source internals.

Unsigned PCG arithmetic uses four 16-bit limbs: each multiplication column fits
within 64 signed bits, carry is explicit, and high limbs are discarded. Logical
shifts never shift negative signed values. XSH-RR truncates before rotating.
The two initialization transitions match the PCG reference. No global RNG exists.

`seed_derivation.gd.derive(material, purpose)` accepts exactly 32 PackedByteArray
bytes and one of combat/progression/loot/quest; it returns checked seed limbs and
a fresh independent source. Uppercase/unknown purposes fail. `material_from_os()`
uses Godot OS.get_entropy, the OS-backed cryptographic entropy
boundary, and fails if it does not produce exactly 32 bytes. There is no fallback.
Fixtures pass explicit material. This increment does not call it during CORE
session entry or load; lifecycle publication is increment 2.

`random_mapping.gd.percentile(integer_chance, explicit_random_source)` returns
original/effective chance, inclusive roll 1..100, success and complementary failure.
Both observations reuse that value. It accepts the declared random_source.gd
interface, checks raw and bounded values, and returns explicit errors. Sources
are trusted in-process objects, not sandboxed executable providers. Classic is
intentionally not a percentile source. Gameplay owners authorize checks and retain
results; this module applies no consequences and supplies no universal history.

`classic_random.gd.create(seed)` requires integer 0..4294967295 including zero.
Each operation has its own private source. `range_value(a,b,inclusive=false)` uses
signed 32-bit endpoints and positive signed 32-bit width (1..2147483647). Invalid,
reversed, empty and overflowing widths reject before drawing. Inclusive singleton
ranges draw once. Every valid range uses exactly one raw draw and classic remainder
mapping. Raw values are 0..32767; wider ranges do not cover every position. Use
`range_value(0,max)` for DFU's one-argument exclusive form.

The retained low 32 bits are mathematically sufficient: reduction modulo 2^32
commutes with recurrence multiplication/addition; higher state bits cannot affect
bits 16..30 now or on later transitions. The product plus increment stays below
signed 64-bit maximum. Verified against local DFU numeric source, not original DOS.
No SaveSeed/RestoreSeed global or public checkpoint/save format is introduced.

PCG adaptation: Melissa O'Neill's pcg-c-basic pcg_basic.c, Apache 2.0, inspected
2026-11-20. Reference multiplier 6364136223846793005, XSH-RR shifts 18/27/59;
`PCG_LICENSE.txt` carries the license. DFU DFRandom source SHA-256
`7f2a7a7e54168b254c6da18db55de66e1e4df2e84c3e7058c712c5eddfd5047b`, local
1.1.1 release snapshot (exact Git commit unavailable), MIT in `DFU_LICENSE.txt`.
License texts are included in Windows export. No new library/native adapter.

Numeric fixture `IMP-006-numeric-v1`, scenario `randomness`, selection fixture
`randomness-v1`, runs through the shared production scene. Fixed 108 assertions.
Additional JSON vectors were independently calculated using Python arbitrary
precision masking and hashlib on 2026-11-20, after reproducing published 42/54
outputs; they include bytes 00..1f, all-ff material and unsigned seed boundaries.
These are data fixtures, not runtime RNG implementations. Every numeric expected
and actual value and logical/raw draw count is retained by the shared report.
No clock or input is used. Seed/clock/input overrides remain explicitly incomplete;
this fixed multi-seed suite cannot reinterpret a scalar seed as its fixture material.
Session ownership, successful-load preparation, retained-result integration and
formula dispatch remain gated increments 2/3; no later owner gate closes here.
