# SAVE-002 — Slot metadata and preview

**Approval status — Approved, finalized v1.** The user approved Draft v1 on 2026-11-17 with “I approve”. Updated 2026-11-17.

## Gameplay purpose and intended player experience

Players can identify the intended save before loading or overwriting it. The screenshot and location give a quick visual reference, and the two clocks distinguish when the player saved from when the character was in the world.

## Existing Daggerfall Unity behavior

In the local DFU 1.1.1 snapshot, `Assets/Scripts/Game/Serialization/SaveLoadManager.cs#SaveGame` builds save info from the snapshot with the character and slot names, a real-world timestamp and game time, the save-format version, and the DFU version. It waits for two end-of-frame yields, reads the full screen, and writes `Screenshot.jpg`. UI hiding is commented out. `GetSaveScreenshot` reads the JPEG separately when requested.

## Confirmed requirements

- **SAVE-002-D01.** Use a world-only thumbnail representing the saved state. Exclude menus, HUD, and transient overlays. If a matching view cannot be captured, show the placeholder and allow the save to succeed.
- **SAVE-002-D02.** Show slot name, character name, local real-world save date and time, in-game date and time, and the contextual location name known to the player when available. Keep technical version information available for diagnostics and compatibility messages.

## Detailed rules and behaviors

1. Associate metadata and any thumbnail with the same stable character, slot, and generation identity under SAVE-001. Derive game time and known location from the accepted snapshot. Keep the committed real-world timestamp as an absolute instant for catalog ordering. Display it in the viewer's local time and format in-game time using the applicable game calendar.
2. Present available labels and clock values through UI-010. Use the location name the character knows in the saved state where available. If information is unavailable or unreadable, leave it absent or display it as unknown under UI-010. Preserve recognized slot identity and availability when only display fields are affected.
3. Capture the saved viewpoint from a frame that represents the accepted snapshot. Preserve the world's visible context, such as the saved location and weather. Exclude menus, gameplay HUD, and transient overlays. Capture may use an existing matching render or a dedicated render. It must leave normal gameplay and UI presentation intact and add no simulated game time.
4. Treat screenshot capture, storage, read, and decode as optional. A missing, unreadable, mismatched, or failed preview uses the approved placeholder. A newer generation cannot inherit the previous generation's image. An otherwise successful save still reports success if only its screenshot fails.
5. Provide save-format version information for native compatibility handling and diagnostics. Keep technical version details out of the ordinary slot fields. Catalog metadata and thumbnails support selection independently of CORE-013 preflight.

## Parameters, required data, and configuration

No gameplay formulas or balance parameters apply. Required inputs are stable character, slot, and generation identities, the committed timestamp, save-format version, and the accepted snapshot's available player-facing labels and game clock. The snapshot also supplies the context for a matching rendered view when available. Thumbnail dimensions, encoding, and storage layout remain implementation choices.

## Inputs, outputs, and events

Inputs include an accepted save snapshot, capture result, publication outcome, and a picker preview request scoped to a selected generation. Outputs include the generation's metadata and either its matching thumbnail or a placeholder state. Ignore late preview results for a retired picker scope or another selection. SAVE's publication outcome governs save success.

## Cross-system interactions

[SAVE-001](SAVE-001.md) owns catalog discovery and generation identity. [UI-010](../UI/UI-010.md) owns selection, placeholder presentation, and newest-first ordering based on the committed timestamp. [CORE-013](../CORE/CORE-013.md) owns native load preflight. [TIME-018](../TIME/TIME-018.md) and the relevant world and location owners supply the clock and context recorded in the snapshot. The preview is descriptive and does not participate in restoring those values.

## Edge cases and failure conditions

- A menu, HUD, overlay, or world transition obscures the matching frame. Use a clean matching capture if available, or the placeholder.
- A successful overwrite has no usable screenshot. Show the new generation's available metadata and the placeholder.
- An image response arrives after selection changed. Leave the current preview intact.
- An unknown location name or invalid display field leaves the remaining metadata usable. Calendar or local time presentation must preserve the saved instant used for catalog ordering.

## Save/load considerations and technical constraints

Target Godot 4.7.2. Persist metadata tied to the corresponding committed save generation. Browse metadata and request thumbnails without reconstructing the gameplay session. Preview work must have bounded costs and respect the current picker scope. Exact publication and recovery rules belong to the SAVE write pipeline.

## Acceptance criteria

1. A committed slot displays its available names, contextual known location, local real-world save time, and saved in-game date and time. Changing the viewer's time zone changes display only.
2. A captured preview shows the saved view with menus, HUD, and transient overlays excluded. The capture advances no game time.
3. Capture, read, or decode failure shows a placeholder and leaves an otherwise valid save usable. An overwrite never displays the preceding generation's image.
4. Late preview responses cannot replace the current selection's image. Technical version details are available for diagnostics and applicable compatibility messages.
5. Browsing metadata or previews never reconstructs a session or bypasses native load preflight.

## Outstanding questions and approval

Thumbnail encoding and dimensions remain implementation choices. Save generation publication and recovery are owned by follow-on SAVE specifications. See [SAVE-002-A01 in the gameplay decision log](../../GAMEPLAY_DECISIONS.md#save-002-interview-decisions).
