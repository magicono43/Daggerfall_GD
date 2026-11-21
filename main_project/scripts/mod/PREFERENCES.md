# Application mod preferences — IMP-007 increment 4

DATA domain `mod.preferences`, resource `installed`, schema `mod-preferences-v1`
supports complete add/replace definitions through the existing ordered package and
loose contribution pipeline. A record's stable ID/mod_id must equal its original
owning package ID. Later explicit DATA replacements preserve that origin. No
executable package or callback is loaded by a definition. Registration precedes
source preparation; checked preference stores prepare before menu reservation;
commit is assignment-only inside CORE's existing synchronous menu transaction.
Legacy fixtures without explicit enablement retain their original composition.

Definitions contain positive integral `version`, localized `name`/`description`
references, `settings`, `groups`, and `presets`. Setting/group/preset IDs use existing
MOD stable identifier validation. Every name/description is `{collection,key}` and
must reference a resolved DATA text definition. Setting types are bool, bounded
32-bit int (`min`,`max`) or string (`max_length` 1..4096, optional unique `choices`).
Each setting declares a compatible typed default, group, labels and exact timing:
`live`, `next_session`, `next_location`, `restart`. Maximum 128 settings per mod.
Unknown definition/constraint fields reject. Group constraints currently support
explicit same-group integer `["less_equal",low,high]`; defaults must satisfy them.
Other interdependent constraints need a versioned extension, never executable input.
Presets have labels and a partial validated `values` map. A preset need not replace
omitted staged values. Apply still validates the resulting whole group.

Effective group timing defers all members when any member requires restart. Live
members otherwise join a declared next session/location group. A mixed next-session
and next-location group without restart rejects as incompatible; no guessed scene
recreation or relabeled `next_launch` boundary is used.

## Storage, application and recovery

One application store per stable mod ID uses
`<selected-root>/settings/mod_preferences/<mod-id>/settings.ini`. Profiles in that
root share it; separately selected standard/portable roots do not. Character saves
never contain this owner's preferences. `preference_store.gd` reuses CORE's actual
ConfigFile clone/value/put/validate/apply/save/recovery/backup/staging/verification/
native-publication interfaces. Active validated definition defaults extend the
packaged `config/mod_preferences.ini`; no guessed packaged defaults are introduced.
Shared CORE timing spellings and existing callers remain unchanged.

Metadata contains CORE format 1 plus exact mod ID and integral definition version.
No migration is inferred. A different definition version blocks with the inherited
incompatible/explicit-preserved-reset recovery policy. Compatible unknown sections/
keys round-trip but are not applied. Invalid declared values/groups recover only
their defaults under CORE's existing preservation/validated-backup rules and expose
the recovery summary. Unreadable/malformed stores, preservation, backup or startup
write failures follow CORE's blocking policy. No unrelated mod's file is reset.

The editor stages values separately. Confirmed Reset stages **all** selected-mod
defaults; canceling confirmation preserves edits; closing discards unapplied edits
for the editor. Reset is never Apply. Apply uses whole CORE group validation and
accepts only successful live groups; independent groups can succeed. Rejected
groups retain old accepted/effective state. Successful application followed by a
write failure stays accepted/effective, unsaved and retryable. Cancel cannot undo
accepted groups. Retry only saves, without replaying consumers or activating pending
requests. Quit attempts accepted-store persistence and uses existing unsaved recovery.

`bind(mod,group,consumer,ticket)` requires synchronous checked `preferences_current`
and `apply_preferences` methods. Initial binding/recreation receives **effective**
values, including old values while newer saved requests remain pending. False must
retain/restore the previous working group; a failed safe restoration belongs to
CORE service-loss recovery, not a fabricated successful rollback. Bindings are weak,
epoch-scoped, copied-ticket checked before/after delivery. No async completion queue
or arbitrary script callback from content exists. Trusted consumer correctness is
an owner contract; these services cannot undo arbitrary external owner side effects.

CORE's actual successful new/load readiness boundary invokes `next_session` before
ready publication. Current original lifecycle operation/scope/generation must match;
failed required activation uses normal incomplete-session cleanup. Next-location
requires an explicitly registered authority with `preferences_boundary_current` and
an original ticket containing the authority's stable scope/operation/generation.
WORLD is not implemented here: controlled authority tests do not certify a real
location transition. Obsolete/canceled callbacks reject; repeated valid deliveries
return retained results without reapplying. Restart requests become eligible only
when a new application owner loads the persisted store; the normal consumer bind
then establishes effective values. No automatic reload/restart is requested.

## UI and remaining integration boundaries

Normal menu/session UI exposes **Mod Preferences**, listing active DATA definitions.
It shows staged, accepted, saved, effective, pending, rejected and unsaved states,
partial presets, confirmed Reset, Apply, retry and Cancel. Missing actual consumers
reject live application visibly rather than activate executable mods. Localized
setting/preset labels use accepted DATA fallback and actual-font glyph diagnostics.
Live locale refresh replaces labels/font assignments in place, preserving stable
selection, draft controls, caret/focus and reset confirmation. Modal scopes hold
requester-owned CORE gates; stale scope/busy locale plans reject. Nothing unlocks
MOD/DATA or rebuilds installed definitions. English remains the only offered locale;
`zz-Test` is synthetic fixture content.

Controlled consumers and location authorities verify interfaces only. Production
QUEST/CHAR/WORLD/SAVE/executable mods, real location providers, IMP-030/056 and M1
acceptance remain open. No preference editor creates gameplay owners or saves.

## Reference evidence

Read-only DFU 1.1.1 snapshot, exact upstream commit unavailable:

| Path below `Assets/Game/Addons/ModSupport/` | SHA-256 | Inspected helpers |
| --- | --- | --- |
| `Mod.cs` | `2fd8e6cd440b54fb31fa1220e2888223a83571878ce29e4cb400e2ca1e6fb775` | `GetSettings`, `LoadSettings`, `LoadSettingsCallback`, `Localize` |
| `ModSettings/PresetPicker.cs` | `74ef6328ef2b32e23daac5cce4aafa544f977636f9a7c2983cdc8037eb6a692c` | `Setup`, `ListBox_OnSelectItem`, `LoadButton_OnMouseClick`, `ApplyPreset` call |

These establish read-only settings access, explicit callback use, localized labels
and preset UI reference behavior. DFU's direct ApplyChangesCallback does not grant
permission to bypass this project's approved staging/confirmation/group boundaries.
No DFU file or classic input was changed.
