# SAVE-015 — Quest, faction and exploration sidecars

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Loading preserves quests, faction standing, conversation consequences, notebook entries, and what the player has discovered. The destination uses the saved world variant. When changed content makes an eligible map record unavailable, the game explains the effect and retains the record for possible recovery.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#LoadGame` reads separate faction, quest, conversation, notebook, discovery, and world-variant files. It restores applicable variants before position restoration and clears discovery if the discovery payload is empty or absent. It attempts to restore automap data after object state and logs failures from that path. The separate files have different fallback behavior.

## Confirmed requirements inherited from approved specifications

- [CORE-013](../CORE/CORE-013.md) and [SAVE-007](SAVE-007.md) require validated authoritative state and declared recovery for missing or invalid data.
- [QUEST-022](../QUEST/QUEST-022.md), [FACT-018](../FACT/FACT-018.md), and [NPC-024](../NPC/NPC-024.md) govern their durable state and reference dependencies.
- [WORLD-018](../WORLD/WORLD-018.md) and [LOC-020](../LOC/LOC-020.md) permit declared recovery for eligible map-only references and require validation of world, layout, and gameplay dependencies.
- [SAVE-005](SAVE-005.md) governs recovery disclosure. [SAVE-006](SAVE-006.md) publishes one coherent generation.

## Detailed rules and behaviors

1. Capture cross-system records in the same committed generation as player and local state. The owner declares each record's required dependencies, whether its absence is valid for the source format, and supported recovery. The physical file layout does not determine whether a record is required.
2. Treat authoritative quest progress and obligations, faction and membership facts, committed dialogue outcomes, and any discovery or variant facts required by gameplay as required where applicable. Preserve saved notebook and exploration knowledge as owner state. A valid empty collection, a format-defined omission, and a failed read have distinct meanings.
3. During preflight, validate required sections and references with their owners. Prepare explicit migrations and declared optional recovery. If a required record or dependency cannot be restored, fail before replacement where detectable. Do not silently replace unreadable records with fresh state or carry state forward from the current session.
4. Supply the resolved variants, discovery, factions, access facts, and other early dependencies before their consumers run under SAVE-011. Restore quest identities, committed outcomes, and required claims before dependent population and links. Apply conversation, notebook, and other records when the required sources are available. Restore progress without replaying quest starts, rewards, discovery events, or dialogue consequences.
5. Restore automap knowledge and personal labels through their owners. Rebuild disposable render data from compatible layout and saved knowledge. For eligible map-only records with unavailable references, retain inactive records with their original identity and provenance and disclose the effect before replacement. Carry those records through later saves and reactivate only when the intended identity and applicable disclosure rights validate. Required gameplay references follow required recovery rules.

## Parameters, required data, and configuration

No new gameplay formulas or settings apply. Required inputs include stable generation and owner identities, world and layout variants, owner state and required references, saved discovery and map knowledge, record classifications, and format and migration context. Exact serialization and physical layout remain SAVE implementation choices.

## Inputs, outputs, and events

Inputs include prepared owner records, content availability and migration results, and destination and binding readiness. Outputs include restored owner state, regenerated map presentation, eligible inactive records, recovery disclosures, or required failure. Publish owner readiness into CORE-013 coordination.

## Cross-system interactions

QUEST owns ongoing and settled quest facts. FACT and related owners supply faction and membership state. NPC owns dialogue history and retained context. WORLD and LOC supply variants, discovery and map ownership. SAVE-011/012 coordinate early dependencies and reconstruction. CORE-013 governs failure and readiness.

## Edge cases and failure conditions

- Missing required quest state or an unresolved required variant fails through the approved recovery flow. A required failure discovered after replacement starts uses CORE cleanup.
- A damaged disposable map cache can be rebuilt. Lost or incompatible player knowledge uses declared owner handling.
- An inactive map label cannot reveal a location by itself, reactivate an expired grant, or satisfy a quest reference.
- A restored conversation topic or notebook entry cannot trigger a fresh consequence merely because it was restored.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Bind each owner record to the selected generation. Validate section dependencies before application and preserve the source save. Distinguish required state, optional owner state, and disposable caches. Rebuild derived presentation without granting discoveries.

## Acceptance criteria

1. Quest, faction, conversation, notebook, and exploration state restore with their original committed consequences.
2. The correct world variant and required context are ready before dependent placement and population. A detected unresolved required dependency preserves the current session.
3. Discarded map render caches rebuild from compatible geometry and saved knowledge without revealing additional areas.
4. Eligible unavailable map-only records are disclosed and carried forward inactive. Required references cannot use that recovery path.

## Outstanding questions and approval

Exact owner field lists, section encodings, and concrete failure fixtures remain follow-on work. The existing owner specifications supply the player-facing recovery rules. See [SAVE-015-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-015-review-decision).
