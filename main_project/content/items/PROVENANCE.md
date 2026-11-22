# Item baseline provenance — v1

The user authorized DFU packaged-template review and adoption on 2026-11-21,
and clarified that consistency with Daggerfall is the goal, rather than exact
parity with original files. This baseline is explicitly **DFU packaged data**.
No available FALL.EXE was examined and no original-executable equivalence is claimed.

Source: read-only local `reference_material/daggerfall-unity-1.1.1-cve-2025/`,
DFU 1.1.1 Release snapshot, exact upstream commit unavailable. Repository root
`LICENSE` is MIT, copyright 2009–2023 Daggerfall Workshop. Its complete notice is
preserved as `DFU_LICENSE.txt` (SHA-256
`6e5e22fa760938ab398743150787896bd20fcf4936aad0122704700bad1e669a`).
No new dependency or executable code from DFU is activated.

| Delivered input | Source / transformation | SHA-256 |
| --- | --- | --- |
| `dfu-item-templates.json` | Exact bytes of `Assets/Resources/ItemTemplates.txt`; 288 explicit indexes | `33f4d2703447f4eb8eeabc7b103d8d946115cffaf6490be78578f97db35693a9` |
| `dfu-item-mappings.json` | Numeric values from `Assets/Scripts/Game/Items/ItemEnums.cs`, following `ItemHelper.GetEnumArray` and ascending `Enum.GetValues` order; aliases retained | `4f6f11b4fe011e2477dc951fe53935bd7db09cf791ed0df8f8a589f75e492725` |

The source enum SHA-256 is
`312b1c1d9f34e5e3dc9c6666597fc57360c1eaf93ad29ece1b9b878453daefd8`;
`ItemHelper.cs` is
`5045637f39e15027e0bbc35e8e47bb60e0f32bce55c76f89e82d0c102a36275d`.
The evidence table has 297 group/index pairs. Groups 4 and 5 are intentionally
excluded: their subtype enums are contextual magic/artifact references rather
than direct item-template indexes. Deeds group 24's implicit enum values 0/1/2
alias gem templates; those three pairs remain in this evidence table but **are
not published as deed mappings**. Other 294 pairs are explicit source mappings,
not approval of item creation, book contents, clothing/equip or distribution rules.

`ItemHelper.LoadItemTemplates` identifies the packaged data as exported from
FALL.EXE. It also merges runtime mods; no such merged/runtime output is shipped.
`isNotRepairable` and `hasNoEncumbrance` are DFU extensions. The adapter moves
present extension values into `dfu_extensions`, invents no absent defaults and
does not execute their semantics.

The selected external `MAGIC.DEF` and `SPELLS.STD` are read in place, never shipped
or copied into fixtures. DFU's packaged `MagicItemTemplates.txt` was inspected
as comparison evidence (59 records, SHA-256
`7f1c527af0c2e953aeb1a8a67a115cfc4f7f24753144ad5e1307b24d34a155d4`);
it is not used as a fallback. Every selected magic-item base group/index resolves
against this packaged item baseline. All selected cast-enchantment spell
references resolve uniquely; the separate index-58 collision remains ambiguous.
No SpellRecords.json payload exists in this snapshot; the broker's merge call
does not establish a shipped patch set. No DFU spell correction is enabled.

The export include filter explicitly carries the JSON files and license in the
PCK. Reads use Godot FileAccess on `res://`, never an absolute filesystem reader.
The versioned reader contract is `scripts/data/ITEM_SPELL_INPUTS.md`.
