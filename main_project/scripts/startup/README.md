# Application settings extensions

IMP-011 increment 3 extends controls response with compatible smoothing-time
defaults and validated live view/cursor edits. The stock staged handlers publish
input and view coherently; failed disk saves retain effective response with UNSAVED
and Retry. Recreated view consumers receive effective values. The
[view contract](../input/VIEW_CURSOR.md) documents bounds, recovery and ownership.

`StartupSettingsOwner` owns versioned settings.ini recovery, accepted/effective/
persisted values, staging verification, backups and publication. Declare settings,
groups and extension hooks before `initialize`. Unknown entries are preserved
without application. Live consumers return true only after applying a complete
unit; false must retain the previous working unit. `apply().application` and
`rejected` describe consumer acceptance; `ok`/`unsaved` describe disk publication.
A successful save alone does not establish that an edit became effective.

IMP-011 increment 2 adds two owner extension contracts:

- `declare_format_guard(id, guard)`: false for a recognized unsupported owner
  version makes the file incompatible before mutation, reusing explicit reset
  and recovery-copy behavior. Missing/invalid ordinary values still use declared
  validation/recovery. The controls guard rejects integer versions other than 1.
- `declare_upgrade(id, upgrade)`: for supported files, returns
  `{value: compatible_value, resets: Array[String]}` before ordinary validation.
  The owner preserves unknown entries and explicitly empty values. Reset IDs enter
  the existing recovery summary. Quiet additions return no reset IDs. This hook
  does not authorize guessing unsupported format migrations or mutating defaults.

`StartupController.controls` declares the complete binding setting, initializes
the effective controls, and presents conflict notices from compatible new action
defaults. Its staged editor never writes directly to storage. Runtime apply uses
the existing live-consumer callback, then independently saves accepted values.
Disk failure retains applied controls and permits `save_accepted` retry. Required
startup publication/preservation failures still block startup with Retry/Quit.

See [the input contract](../input/README.md) for binding schema, compatible action
group repair, conflicts, recovery routes and consumer freshness. The owner is
application-wide and never participates in character SAVE restoration.
