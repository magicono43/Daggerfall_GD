# AV feature catalog

Static analysis of Daggerfall Unity 1.1.1. See the [master catalog](../01_MASTER_SYSTEMS_CATALOG.md). Paths are relative to `Assets/Scripts/`. Symbols follow `#`. Confidence rates the sampled source trace.

## AV-001 — Model and material presentation

- **Parent subsystem** — World visuals
- **Purpose** — Render classic geometry in the scene.
- **Existing implementation** — MeshReader provides Unity meshes and model caching. MaterialReader resolves archive, record and frame materials and can change climate variants. DATA owns decoding and replacement precedence.
- **Source** — `MeshReader.cs#GetMesh`, `MaterialReader.cs#GetMaterial`, `MaterialReader.cs#ChangeClimate`
- **Inputs and outputs** — Model and surface identity → scene mesh and material
- **Dependencies** — DATA-021, DATA-022, LOC
- **Edge cases and interactions** — Compare scale, UVs and replacement geometry with real assets.
- **Design questions** — Which original visual properties should be preserved?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16 (AV-001-A01).

### My Intended Specification

[AV-001 — Model and material presentation](../../design/systems/AV/AV-001.md)

## AV-002 — Billboard batching and animation

- **Parent subsystem** — World visuals
- **Purpose** — Render flats and scenery efficiently.
- **Existing implementation** — DaggerfallBillboardBatch groups items by material, builds mesh data and updates animated billboards through a coroutine.
- **Source** — `Internal/DaggerfallBillboardBatch.cs#SetMaterial`, `Internal/DaggerfallBillboardBatch.cs#Apply`, `Internal/DaggerfallBillboardBatch.cs#AnimateBillboards`
- **Inputs and outputs** — Flat records and positions → batched visual geometry
- **Dependencies** — WORLD-011, LOC, DATA
- **Edge cases and interactions** — Test animated atlas boundaries, replacements and unloading.
- **Design questions** — Which sprites need independent animation or rendering?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16 (AV-002-A01).

### My Intended Specification

[AV-002 — Billboard batching and animation](../../design/systems/AV/AV-002.md)

## AV-003 — Sky rendering and time context

- **Parent subsystem** — World visuals
- **Purpose** — Display the exterior sky across time and weather.
- **Existing implementation** — DaggerfallSky loads day and night sky frames, applies time and space context and draws in post-render. It exposes sky fog color handling.
- **Source** — `Internal/DaggerfallSky.cs#ApplyTimeAndSpace`, `Internal/DaggerfallSky.cs#LoadDaySky`, `Internal/DaggerfallSky.cs#LoadNightSky`, `Internal/DaggerfallSky.cs#DrawSky`
- **Inputs and outputs** — Time, context and sky images → sky layers and color
- **Dependencies** — TIME-006, TIME-007, DATA
- **Edge cases and interactions** — Verify horizon seams, camera setup and replacement texture fallback.
- **Design questions** — How should sky changes follow time and weather?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-16 (AV-003-A01).

### My Intended Specification

[AV-003 — Sky rendering and time context](../../design/systems/AV/AV-003.md)

## AV-004 — Lighting, fog and underwater view

- **Parent subsystem** — World visuals
- **Purpose** — Convey location and weather visually.
- **Existing implementation** — SunlightManager updates lighting. WeatherManager configures fog and sunlight scale. PlayerEnterExit updates underwater fog using the dungeon block water level.
- **Source** — `Game/SunlightManager.cs#Update`, `Game/WeatherManager.cs#SetFog`, `Game/WeatherManager.cs#SetSunlightScale`, `Game/PlayerEnterExit.cs#Update`, `Game/UnderwaterFog.cs`
- **Inputs and outputs** — Time, weather and water level → visibility and lighting
- **Dependencies** — TIME-006, TIME-007, LOC-012, MOVE-014
- **Edge cases and interactions** — Check transitions between blocks and interior/exterior fog. Gameplay sun exposure is separate.
- **Design questions** — Which visibility changes should affect gameplay?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17 (AV-004-A01).

### My Intended Specification

[AV-004 — Lighting, fog and underwater view](../../design/systems/AV/AV-004.md)

## AV-005 — Retro resolution and HUD composition

- **Parent subsystem** — Display
- **Purpose** — Present a lower-resolution view with HUD-aware framing.
- **Existing implementation** — RetroRenderer targets 320×200 or 640×400 textures and selects separate targets for docked large HUD. Disabled mode clears the camera target. RetroPresentation provides an OnRenderImage path.
- **Source** — `Utility/RetroRenderer.cs#UpdateRenderTarget`, `Utility/RetroPresentation.cs#OnRenderImage`
- **Inputs and outputs** — Retro mode and HUD settings → camera target and presentation
- **Dependencies** — UI, CORE-006
- **Edge cases and interactions** — Verify asset availability, aspect ratio and toggling during play.
- **Design questions** — Which retro modes and scaling options should be supported?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17 (AV-005-A01).

### My Intended Specification

[AV-005 — Retro resolution and HUD composition](../../design/systems/AV/AV-005.md)

## AV-006 — Palette, depth and post-processing settings

- **Parent subsystem** — Display
- **Purpose** — Offer configurable presentation effects.
- **Existing implementation** — RetroRenderer exposes depth material and post-processing controls and builds palette LUTs. The effects window registers core and custom configuration pages.
- **Source** — `Utility/RetroRenderer.cs#InitLut`, `Utility/RetroRenderer.cs#UpdateDepthProcessMaterial`, `Utility/RetroRenderer.cs#TogglePostprocessing`, `Game/UserInterfaceWindows/GameEffectsConfigWindow.cs#AddCorePages`, `Game/UserInterfaceWindows/GameEffectsConfigWindow.cs#AddConfigPage`
- **Inputs and outputs** — Effect settings, shaders and render targets → processed output
- **Dependencies** — CORE-006, UI, MOD
- **Edge cases and interactions** — Check missing shaders, sky exclusion and interaction with Unity Post Processing.
- **Design questions** — Which effects should be independently configurable?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17 (AV-006-A01).

### My Intended Specification

[AV-006 — Palette, depth and post-processing settings](../../design/systems/AV/AV-006.md)

## AV-007 — First-person weapons and cast visuals

- **Parent subsystem** — Feedback
- **Purpose** — Show attack and cast state.
- **Existing implementation** — FPSWeapon draws and animates weapon sprites, loads atlases and exposes hit frames. FPSSpellCasting handles the visual cast release used by the effect manager.
- **Source** — `Game/FPSWeapon.cs#OnGUI`, `Game/FPSWeapon.cs#LoadWeaponAtlas`, `Game/FPSWeapon.cs#GetHitFrame`, `Game/FPSSpellCasting.cs`, `Game/MagicAndEffects/EntityEffectManager.cs#PlayerSpellCasting_OnReleaseFrame`
- **Inputs and outputs** — Weapon or spell state and art → animation and release signal
- **Dependencies** — COMBAT-004, MAGIC-004, DATA
- **Edge cases and interactions** — Verify replacement frames, handedness and frame timing under low frame rates.
- **Design questions** — Should gameplay timing be tied to presentation frames?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17 (AV-007-A01).

### My Intended Specification

[AV-007 — First-person weapons and cast visuals](../../design/systems/AV/AV-007.md)

## AV-008 — Impact, missile and movement cues

- **Parent subsystem** — Feedback
- **Purpose** — Present combat and traversal feedback.
- **Existing implementation** — Missiles have billboard animation, light and impact sound paths. Enemy hit handling can show blood and choose sounds. Footsteps and camera bobbing supply movement cues.
- **Source** — `Game/DaggerfallMissile.cs#UseSpellBillboardAnims`, `Game/DaggerfallMissile.cs#UpdateLight`, `Game/DaggerfallMissile.cs#PlayImpactSound`, `Game/EnemyBlood.cs`, `Game/PlayerFootsteps.cs`, `Game/Player/HeadBobber.cs`
- **Inputs and outputs** — Impact and motion state → visuals, sound and camera offsets
- **Dependencies** — COMBAT-012, MOVE-017, MAGIC-005
- **Edge cases and interactions** — Test effect overlap and settings that suppress voices or camera motion.
- **Design questions** — Which cues need accessibility controls?
- **Complexity** — Medium
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17 (AV-008-A01).

### My Intended Specification

[AV-008 — Impact, missile and movement cues](../../design/systems/AV/AV-008.md)

## AV-009 — Clip playback and spatial sound

- **Parent subsystem** — Audio
- **Purpose** — Play sound cues with appropriate placement.
- **Existing implementation** — DaggerfallAudioSource resolves sound IDs or indices, applies presets and exposes one-shot and position-based playback.
- **Source** — `Internal/DaggerfallAudioSource.cs#SetSound`, `Internal/DaggerfallAudioSource.cs#PlayOneShot`, `Internal/DaggerfallAudioSource.cs#PlayClipAtPoint`, `SoundReader.cs#GetAudioClip`
- **Inputs and outputs** — Sound key, position and gain → playback
- **Dependencies** — DATA-023, COMBAT, LOC, UI
- **Edge cases and interactions** — Verify missing clips, gain and spatial attenuation in actual prefabs.
- **Design questions** — Which sounds should be positional versus screen-space?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17 (AV-009-A01).

### My Intended Specification

[AV-009 — Clip playback and spatial sound](../../design/systems/AV/AV-009.md)

## AV-010 — Ambient loops, weather and spot effects

- **Parent subsystem** — Audio
- **Purpose** — Make spaces audible outside combat.
- **Existing implementation** — AmbientEffectsPlayer has interior/exterior presets and separate loop, local and distant playback paths. Lightning and cemetery effects have dedicated routines. Location and video events are wired separately.
- **Source** — `Game/AmbientEffectsPlayer.cs#ApplyPresets`, `Game/AmbientEffectsPlayer.cs#PlayEffects`, `Game/AmbientEffectsPlayer.cs#PlayLightningEffects`, `Game/AmbientEffectsPlayer.cs#PlayCemeteryEffects`, `Game/AmbientEffectsPlayer.cs#AmbientEffectsPlayer_OnVideoStart`
- **Inputs and outputs** — Location, weather and event context → ambience and spot sounds
- **Dependencies** — TIME, WORLD, LOC
- **Edge cases and interactions** — Check scene transition overlap, muting and timer reset.
- **Design questions** — How should ambience crossfade between locations?
- **Complexity** — Large
- **Analysis confidence** — Medium
- **Review status** — Approved, finalized v1 on 2026-11-17 (AV-010-A01).

### My Intended Specification

[AV-010 — Ambient loops, weather and spot effects](../../design/systems/AV/AV-010.md)

## AV-011 — Context-driven music selection

- **Parent subsystem** — Audio
- **Purpose** — Choose a playlist and refresh songs as context changes.
- **Existing implementation** — SongManager updates environment, weather, time and arrest context. Changes in playlist, day or location can request another song. It can restart playback when nothing is playing.
- **Source** — `Game/SongManager.cs#UpdateSong`, `Game/SongManager.cs#AssignPlaylist`, `Game/SongManager.cs#PlayerMusicUpdateContext`
- **Inputs and outputs** — Player context and playback state → song request
- **Dependencies** — TIME, LAW, WORLD, LOC
- **Edge cases and interactions** — Verify context precedence and repetition with actual playlists.
- **Design questions** — Which changes should interrupt the current song?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17 (AV-011-A01).

### My Intended Specification

[AV-011 — Context-driven music selection](../../design/systems/AV/AV-011.md)

## AV-012 — Song replacements and MIDI synthesis

- **Parent subsystem** — Audio
- **Purpose** — Play selected songs through clip or synthesized paths.
- **Existing implementation** — SongPlayer initializes synthesis before selecting an imported audio clip or loading MIDI into a sequencer. It exposes an audio filter callback and video lifecycle handlers.
- **Source** — `Internal/DaggerfallSongPlayer.cs#Play`, `Internal/DaggerfallSongPlayer.cs#InitSynth`, `Internal/DaggerfallSongPlayer.cs#OnAudioFilterRead`, `AudioSynthesis/Sequencer/MidiFileSequencer.cs`, `AudioSynthesis/Sf2/SoundFont.cs`
- **Inputs and outputs** — Song ID, replacement or MIDI, and synthesis inputs → audio playback
- **Dependencies** — DATA-023, MOD, UI
- **Edge cases and interactions** — Check unavailable sound fonts, custom clip readiness and video interruption.
- **Design questions** — Which playback formats and fallback should be supported?
- **Complexity** — Large
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17 (AV-012-A01).

### My Intended Specification

[AV-012 — Song replacements and MIDI synthesis](../../design/systems/AV/AV-012.md)

## AV-013 — Cinematics, replacements and skip events

- **Parent subsystem** — Media
- **Purpose** — Play and exit full-screen videos.
- **Existing implementation** — VidPlayerWindow tries a replacement first and otherwise sets up a classic 320×200 player. Back, configured any-key skip and completion lead to disposal, cursor restoration and finish/end events.
- **Source** — `Game/UserInterfaceWindows/DaggerfallVidPlayerWindow.cs#Setup`, `Game/UserInterfaceWindows/DaggerfallVidPlayerWindow.cs#Update`, `Game/UserInterface/DaggerfallVideo.cs`, `Utility/AssetInjection/VideoReplacement.cs#TryImportMovie`
- **Inputs and outputs** — Video key and input → playback or completion events
- **Dependencies** — UI-008, CORE-008, DATA-023
- **Edge cases and interactions** — Verify missing media, replacement start timing and exact callback order.
- **Design questions** — Should skipping and playback failure produce the same lifecycle events?
- **Complexity** — Medium
- **Analysis confidence** — High
- **Review status** — Approved, finalized v1 on 2026-11-17 (AV-013-A01).

### My Intended Specification

[AV-013 — Cinematics, replacements and skip events](../../design/systems/AV/AV-013.md)

## Classic provenance and next review steps

Classic graphics, sky frames, sounds and videos provide reference media. Unity camera composition, billboard batching, spatial playback and synthesis are observable DFU paths. Actual assets, shader output, mix and fidelity to classic presentation remain unverified.

Review native and retro rendering with docked HUD first, then trace exterior-to-interior lighting, ambient audio and playlist changes. Exercise a MIDI song, a replacement and a skipped cinematic. Check the attack and cast release cues at different frame rates. DATA owns format conversion and source resolution. UI owns screen interaction. This pass sampled rendering and audio entry points and did not execute Unity.
