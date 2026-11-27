# IMP-015 — Class-method presentation iteration

Started November 26, 2026 at 10:19:28 PM EST after the user committed the prior
polish. User explicitly chose DFU's two-button method screen, with Custom in the
next class list. Parent/increment acceptance and milestone gates remain pending.

The normal optional classic image reader now admits `BUTN01I0.IMG` (headerless
184×144, already supported by the image decoder), registered as replaceable media
target `creation.class-method`. It supplies the original frame and baked yellow
bitmap lettering. Source assets stay external/read-only; palette ART_PAL.COL and
existing classic image provenance apply. Geometry evidence is pinned DFU's
`CreateCharChooseClassGen.cs`: list rectangle (8,41,167,43), questions rectangle
(8,100,167,34). Recreation code uses real Godot buttons over those image regions,
semantic labels/tooltips, keyboard focus and original click feedback. Optional
missing art falls back to labeled ordinary buttons.

The stock class-method page retains the map background. Both choices edit through
existing owner/navigation APIs and advance on success; redundant Next is hidden.
The extra direct custom shortcut is removed from this view; existing Custom in
the class list continues to call the normal career-route request. CHAR choices
and routes are unchanged. Render-generation, busy/context and summary locks guard
callbacks. The maintained career fixture follows the new immediate transition.

Focused preview (PowerShell, from any folder):

```powershell
& 'C:/Users/Kirk/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe' -NoProfile -File 'C:/Godot/Projects/Daggerfall_GD/main_project/tools/preview_creation_gender.ps1' -ClassMethod
```

Add `-SmokeTest` for actual list/custom/Back, focused Enter questionnaire,
obsolete-callback and click-count checks. The preview follows actual race and
gender controls into this screen with disposable storage. Copied source hashes
include the new UI script; external source freshness includes BUTN01I0.IMG.
Full creation regressions and Windows exports are deferred to the combined
presentation checkpoint under fast-ui-polish. Changes remain uncommitted;
user visual approval and physical audibility are not automated check claims.

Completed November 26 at 10:23:48 PM EST (about four minutes). Focused rendered
run `verification-rendered-05525c92a5874a46b4df4beaf73e74ea` passed all 35 checks
on Godot 4.7.2. Authentic `class-method.png` visually inspected. The owned copied
build/cache was compacted (214,862,459 bytes removed); compact reports, logs,
review captures and source archive retained. No broad regression/export claimed.
