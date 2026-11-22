# DFU faction and quest source profile v1

Selected under PROJECT-DATA-D01 for IMP-009 increment 3 on 2026-11-21.
Source: read-only `reference_material/daggerfall-unity-1.1.1-cve-2025/Assets/StreamingAssets/`.
This is the repository's local DFU 1.1.1 Release snapshot (exact upstream commit
unavailable). `DFU_LICENSE.txt` reproduces its root MIT license, copyright
2009–2023 Daggerfall Workshop, SHA-256
`6e5e22fa760938ab398743150787896bd20fcf4936aad0122704700bad1e669a`.
Authored comments and credits, including Template 1.11 / Donald Tipton table
attribution and individual quest authors, remain in the complete source text.
This records the snapshot's license/provenance; it does not claim new ownership
of underlying Daggerfall content or authorize redistribution of external ARENA2.

All 278 selected text files are byte-for-byte copies: one faction source,
265 quests, two selection lists, ten shared tables. The authoritative explicit
identity/hash assignment is `profile.json`, SHA-256
`cf66ec631c3462417eae0ea6aa7fbe3797d4fa9232e9f1eaaed3cf894962ac56`.
Its quest IDs are fixed assignments, not a runtime sorted-filename convention.
Changing a filename, display name or array order cannot change the assignment.
Local `.gitattributes` disables line-ending conversion for pinned text/profile
bytes so their original hashes survive commit and a fresh checkout.
There are 366 faction records, 188 list rows (187 Classic + 1 DFU), and 1,270
shared-table rows. This profile intentionally includes unlisted demonstration,
main-story and tutorial source files without offering/executing/registering them.
`QuestPacks/` has no authored pack in this snapshot: only a readme instructing
users to extract packs there, `.gitignore`, and Unity metadata. None is treated
as a successful empty quest pack.

DFU's `Utility/ContentReader.cs` explicitly selects packaged FACTION.TXT.
`API/FactionFile.cs` supplies tag parsing, tab hierarchy and OR-combined repeated
flags evidence. `Game/Questing/QuestMachine.cs`, `QuestListsManager.cs` and
`Utility/Table.cs` establish text/list/table transport and field evidence. Their
RNG, numeric custom-ID allocation, mutable faction merging, basename resolver,
lenient executable parser and live quest creation are not adopted.

The original selected `C:/Games/Daggerfall/arena2/FACTION.TXT` has 366 blocks,
74,224 bytes, SHA-256
`9ffe5cad99a61e15764e9cf8535ab562ce599dde52ce5d23bf5b4f82ad773c5e`.
Packaged FACTION.TXT has SHA-256
`365cb347fa3e93b99c1646e06009955dc9510fc4143eeca447f5f835bce00cb5`.
119 block payloads differ (including hierarchy/whitespace and authored fields).
The complete original/selected block comparison inventory is retained in
`tests/faction_quest_source_observation.json`: per-ID comparison payload hashes,
line counts and changed tag names, without copying original classic payloads.
The comparison algorithm is recorded there. It does not assert that every change
has the same mechanical significance.
The coherent DFU baseline deliberately adopts these packaged changes together.
No further faction value correction or script rewriting is applied. Case-folded
tags and repeated-flag OR are documented format interpretation, with original
tag values/lines preserved in receipts.

The selected installation also contains 306 QBN and 303 QRC files. Those are
original binary quest transports, unselected here. They are neither DFU text
scripts nor claimed semantically equivalent. No binary decompiler, alternate
installation or fabricated text substitution is used. Main actors/items/spells
retain their accepted source profiles and independent semantic gates.

Only these copied resources and their license/profile are included in the PCK.
Read them via Godot `FileAccess` at `res://content/faction_quest/`, never through
the absolute-filesystem contribution reader. Later package/loose JSON envelopes
can replace declared data through the normal checked DATA/MOD pipeline; shipped
fingerprints never override a validated later contribution.
