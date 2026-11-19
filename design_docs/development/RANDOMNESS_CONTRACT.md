# Randomness contract

Selected for IMP-006 on 2026-11-18 under approved GAD-06 and the user's instruction to select the remaining algorithm. Windows is the initial verification target. These numeric contracts apply to future platform adapters.

## Selection and alternatives

Use **PCG32 XSH-RR 64/32**, identified in project records as pcg32-xsh-rr-v1. Its reference defines a 64-bit state, stream selection, initialization and rejection-based bounded output. A scratch calculation reproduced the published fixed-seed sequence. Preserve upstream attribution and license obligations when adapting implementation. [Reference implementation](https://github.com/imneme/pcg-c-basic/blob/master/pcg_basic.c), [published sample output](https://www.pcg-random.org/using-pcg-c-basic.html)

xoshiro256++ is a documented alternative with a larger state and jump facilities. The initial four purpose streams require reproducible integer draws and a small independently initialized state. PCG32 meets that need with direct reference vectors. No performance superiority is claimed. [Author's generator comparison](https://prng.di.unimi.it/)

## Numeric rules

Match the reference initialization and output functions with explicitly unsigned arithmetic, 64-bit wraparound and 32-bit output truncation and rotation. A language with signed integers must emulate those operations and pass the same vectors.

The bounded primitive accepts an integer bound b in 1 through 2^32−1. Compute t = 2^32 modulo b. Draw unsigned 32-bit values until r ≥ t, then return r modulo b. The raw primitive covers the full unsigned 32-bit range. Invalid bounds fail without a draw. RULE-001 obtains its percentile with bound 100 and adds 1. Larger ranges require a separately specified consumer adapter.

Rejecting an internal raw value is part of one logical bounded draw. A bound of 1 still consumes one raw value. Retained outcomes preserve the logical resolution rather than re-running it.

## Seed derivation

Seed contract rpg-rng-v1 takes exactly 32 bytes of session initialization material M. Normal new-session and successful-load initialization obtain fresh material from the platform's operating-system entropy service. Report initialization failure explicitly if it is unavailable. Fixtures supply M directly.

For each purpose p, compute SHA-256 over the concatenation of ASCII rpg-rng-v1, one zero byte, M, one zero byte, and the lowercase ASCII purpose. Initial purposes are combat, progression, loot and quest. Interpret digest bytes 0–7 as little-endian initstate. Interpret bytes 8–15 as little-endian and clear the highest bit to obtain initseq. Use the reference PCG initialization. Derivation consumes zero gameplay draws. Additional purposes require a distinct recorded key and the same independent derivation.

SHA-256 domain separation is the selected project seed policy. It does not guarantee that different streams have disjoint outputs or that fresh loads produce different rolls. Keep initialization material available to local test reproduction as required by DEV-014. Ordinary save data retains owner-required results and reconstruction inputs under RULE-002/003.

## Verification vectors

Reference seed initstate = 42 and initseq = 54 produces these first six hexadecimal unsigned outputs.

| Draw | Output |
| --- | --- |
| 1 | a15c02b7 |
| 2 | 7b47f409 |
| 3 | ba1d3330 |
| 4 | 83d2f293 |
| 5 | bfa4784b |
| 6 | cbed606e |

Restarting from that seed and making six bound-100 draws plus 1 produces 84, 98, 25, 56, 56, 67. Each raw output in this fixture exceeds the threshold of 96.

Project derivation fixtures use M = 32 zero bytes. Values below were calculated with Python integer masking and hashlib on 2026-11-18 after reproducing the upstream sequence. They verify the project derivation, with actual engine verification pending implementation.

| Purpose | initstate hexadecimal | initseq hexadecimal | First six raw outputs hexadecimal |
| --- | --- | --- | --- |
| combat | 2039abc61c3ee2dd | 01c2283509471122 | 863b652e 78d434fe 4231b50f 9bde62af 1404fe92 56575055 |
| progression | be16b5af20eec12f | 46fe8ea4d1103224 | ff0b25f6 8e983a84 62fc69c9 0e66c3a5 dbd3a6dd 92396db2 |
| loot | 2a2fbaee860b4fab | 6825f3e0b47b0bf3 | 75503fb1 6e1b6c39 32e421f2 c05d3b04 e8e299bf 596e4412 |
| quest | c200bbe304e500f1 | 17bd7651824d7846 | ed178ad9 b2f009c0 2c2b9c5f 610284ca 018b5f81 9709605b |

Use a controlled raw source containing 0, 95, 96, 199 for bound 100. The first bounded result is 96 after three raw requests, and the next is 99 after one. Verify invalid bounds leave source state intact and guaranteed percentile checks still consume one logical draw. Interleave any number of combat draws and compare the other three streams against their untouched vectors.

Classic compatibility retains RULE-002's separate generator, seed and mapping. Domain owners retain assigned results, attempt identity, eligibility and draw ordering. The selected algorithm alone provides no guarantee of identical outcomes after gameplay order or content changes.
