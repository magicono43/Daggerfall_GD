# Geographic baseline provenance

`profile.json` is project-authored identity/mapping metadata for the observed
`C:/Games/Daggerfall/arena2` installation, inventoried 2026-11-22. It does not
redistribute MAPS.BSA, WOODS.WLD, CLIMATE.PAK or POLITIC.PAK. Exact lengths/hashes,
counts, independent pins and discovery flag counts are recorded in
`tests/geography_source_observation.json`. No claim of original-release
authenticity is made. Required classic data stays external and read-only.

Region names and climate labels/encoding evidence derive from read-only DFU
1.1.1 Release snapshot `reference_material/daggerfall-unity-1.1.1-cve-2025`,
`Assets/Scripts/API/{MapsFile,WoodsFile,PakFile,DFLocation,DFRegion}.cs` and
`Utility/ContentReader.cs`. DFU is Copyright (C) 2009–2023 Daggerfall Workshop,
MIT licensed; its license is included as `DFU_LICENSE.txt` and explicitly
exported/read from the PCK. The exact snapshot commit is unavailable. Independent
GDScript readers implement documented formats; no procedural terrain sampler,
Unity scale, default climate fallback or source mutation is adopted.

Source choice follows PROJECT-DATA-D01: external classic geographic content with
DFU's region labels and checked format/alignment evidence gives a coherent,
moddable baseline. No packaged geographic correction is required to publish this
profile. Discovery copies raw source flags with an explicit unresolved gameplay
qualification; no forgotten-graveyard reveal is fabricated. The POLITIC unused
71-byte creator attribution is recognized exactly and has no gameplay effect.
All sample and climate overrides remain authoritative after baseline resolution.

IDs were assigned once and frozen in this versioned profile. Rerunning
`tools/observe_geography.py` verifies the same selected edition; it refuses to
rewrite a changed profile. Future editions need curated explicit mappings,
not renumbering by source order, name or position. Profile edits require updating
the pinned hash and independent fixture evidence deliberately.
