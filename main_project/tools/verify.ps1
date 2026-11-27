param(
    [ValidateSet('headless','rendered')][string]$Mode = 'headless',
    [string]$Suite = 'm1',
    [string[]]$Scenario = @(),
    [string]$Fixture = 'm1-v1',
    [string]$ClassicSource = '',
    [Nullable[long]]$Seed,
    [Nullable[double]]$Clock,
    [string]$InputSequence = '',
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe',
    [ValidateRange(1,600)][int]$TimeoutSeconds = 120
)
$ErrorActionPreference = 'Stop'
if ($Scenario -contains 'native-libraries' -or $Suite -eq 'native-libraries' -or $Scenario -contains 'native-banks' -or $Suite -eq 'native-banks') {
    $banks = $Scenario -contains 'native-banks' -or $Suite -eq 'native-banks'
    if (($Fixture -ne $(if ($banks) { 'native-banks-v1' } else { 'native-libraries-v1' })) -or ($Scenario.Count -gt 1)) { throw 'Native dependency checks require their independent versioned selection.' }
    & "$PSScriptRoot/verify_native_libraries.ps1" -Mode $Mode -ClassicSource $ClassicSource -Godot $Godot -BankRecovery:$banks
    exit $LASTEXITCODE
}
. "$PSScriptRoot/mod_fixture.ps1"
. "$PSScriptRoot/assertion_values.ps1"
. "$PSScriptRoot/actor_fixture.ps1"
. "$PSScriptRoot/actor_state_fixture.ps1"
. "$PSScriptRoot/ground_fixture.ps1"
. "$PSScriptRoot/calendar_fixture.ps1"
. "$PSScriptRoot/creation_fixture.ps1"
. "$PSScriptRoot/item_spell_fixture.ps1"
. "$PSScriptRoot/faction_quest_fixture.ps1"
. "$PSScriptRoot/geography_fixture.ps1"
. "$PSScriptRoot/layout_fixture.ps1"
. "$PSScriptRoot/variant_fixture.ps1"
. "$PSScriptRoot/dungeon_fixture.ps1"
$project = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$run = "$project/tests/.runs/verification-$Mode-$([Guid]::NewGuid().ToString('N'))"
$runtimeProject = "$run/project"
# The Windows console launcher starts another executable. Own the actual engine
# process directly when its paired binary is available (also simplifies timeout
# and redirected-stream lifetime). Both binaries belong to the same distribution.
$engineExecutable = $Godot
if ($Godot.EndsWith('_console.exe')) {
    $pairedEngine = $Godot.Substring(0, $Godot.Length - '_console.exe'.Length) + '.exe'
    if (Test-Path -LiteralPath $pairedEngine) { $engineExecutable = $pairedEngine }
}
New-Item -ItemType Directory -Force $run | Out-Null
$priorRoaming = $env:APPDATA
$priorLocal = $env:LOCALAPPDATA
$report = [ordered]@{ schema = 1; mode = $Mode; suite = $Suite; fixture = $Fixture; root = $run
    status = 'incomplete'; scenarios = @(); classic_source = $ClassicSource; inputs = @{ seed = $Seed; clock = $Clock; input_sequence = $InputSequence }
    engine = $null; executable = $engineExecutable; runtime_project = $runtimeProject; build = @{}; reproduction = @{ command = "./main_project/tools/verify_$Mode.ps1"; arguments = @{
        Suite = $Suite; Scenario = $Scenario; Fixture = $Fixture; ClassicSource = $ClassicSource; Seed = $Seed; Clock = $Clock; InputSequence = $InputSequence; Godot = $Godot; TimeoutSeconds = $TimeoutSeconds } } }

# Only this helper owns child lifetime. No shell-built command or unrelated process kill.
function Invoke-Engine([string[]]$EngineArguments, [string]$Directory, [string]$Name) {
    $quoted = @($EngineArguments | ForEach-Object { '"' + $_.Replace('"','\"') + '"' })
    $priorPath = $env:PATH
    try {
        $env:PATH = "$env:SystemRoot/System32;$env:SystemRoot"
        $child = Start-Process -FilePath $engineExecutable -ArgumentList $quoted -WindowStyle Hidden -PassThru `
            -RedirectStandardOutput "$Directory/$Name.stdout.log" -RedirectStandardError "$Directory/$Name.stderr.log"
    } finally { $env:PATH = $priorPath }
    if (!$child.WaitForExit($TimeoutSeconds * 1000)) {
        $child.Kill($true)
        $child.WaitForExit()
        return @{ exit = $null; timed_out = $true }
    }
    $child.WaitForExit()
    return @{ exit = $child.ExitCode; timed_out = $false }
}

# Snapshot current game resources, including the built native adapter. Never
# copy caches, prior evidence or toolchains; import only inside this disposable
# tree. This is a launch copy of the existing project, not another source project.
function Copy-VerificationResources([string]$Source, [string]$Destination) {
    New-Item -ItemType Directory -Force $Destination | Out-Null
    foreach ($entry in Get-ChildItem -LiteralPath $Source) {
        if ($entry.PSIsContainer) {
            if ($entry.Name -in @('.godot','.runs','tools','.zig-cache','zig-out')) { continue }
            Copy-VerificationResources $entry.FullName "$Destination/$($entry.Name)"
        } else {
            # Runtime DLLs are sufficient. Godot's Windows editor renames nearby
            # debug PDBs; build-only libraries/symbols and prior rename copies
            # must not be inputs to a disposable resource import.
            if ($entry.Extension -in @('.pdb','.lib')) { continue }
            Copy-Item -LiteralPath $entry.FullName -Destination "$Destination/$($entry.Name)"
        }
    }
}
function Get-VerificationSourceFiles([string]$Directory) {
    foreach ($entry in Get-ChildItem -LiteralPath $Directory) {
        if ($entry.PSIsContainer) {
            if ($entry.Name -notin @('.runs','.toolchain','bin','.zig-cache','zig-out','.godot')) {
                Get-VerificationSourceFiles $entry.FullName
            }
        } else { $entry }
    }
}
try {
    $env:APPDATA = "$run/engine-roaming"
    $env:LOCALAPPDATA = "$run/engine-local"
    New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
    $versionRun = Invoke-Engine @('--headless','--version') $run 'version'
    $report.engine = (Get-Content "$run/version.stdout.log" -Raw).Trim()
    if ($versionRun.exit -ne 0 -or $report.engine -notmatch '^4\.7\.2\.stable') { throw 'Godot 4.7.2 stable is required' }
    foreach ($path in @('project.godot','native/storage/bin/storage_windows.dll','native/media/bin/media_windows.dll','native/media/bin/media-runtime.sha256','content/media/banks/generaluser-gs-2.0.3.sf2')) {
        $report.build[$path] = (Get-FileHash "$project/$path" -Algorithm SHA256).Hash
    }
    $report.build.source_revision = (& git -C $project rev-parse HEAD)
    $report.build.working_tree = @(& git -C $project status --short)
    $report.build.sources = @{}
    foreach ($source in @('scripts','tests','tools','config','content','native/storage','native/media') | ForEach-Object { Get-VerificationSourceFiles "$project/$_" } |
        Where-Object { $_.FullName -notmatch '[\\/](\.runs|\.toolchain|bin|\.zig-cache|zig-out)[\\/]' -and $_.Extension -in @('.gd','.gdshader','.ps1','.cpp','.hpp','.ini','.gdextension','.json','.txt','.csv','.import','.ttf','.bytes','.py') }) {
        $report.build.sources[[IO.Path]::GetRelativePath($project,$source.FullName)] = (Get-FileHash $source.FullName -Algorithm SHA256).Hash
    }
    Copy-VerificationResources $project $runtimeProject
    $import = Invoke-Engine @('--headless','--path',$runtimeProject,'--import','--quit-after','60') $run 'import'
    if ($import.timed_out -or $import.exit -ne 0) { throw 'Project import did not complete successfully' }
    if (!(Test-ScriptDiagnostics @((Get-Item "$run/import.*.log").FullName) '' $null)) { throw 'Project import reported an unexpected engine error' }
    $selected = $Scenario
    if ($selected.Count -eq 0) {
        $selected = switch ($Suite) {
            'm1' { @('qualification','startup','session','m1-composition') }
            'qualification' { @('qualification') }
            'startup' { @('startup') }
            'session' { @('session') }
            'dungeon-context' { @('dungeon-assembly') }
            'dungeon-markers' { @('dungeon-assembly') }
            'location-assembly' { @('dungeon-assembly') }
            default { @($Suite) }
        }
    }
    $index = 0
    foreach ($id in $selected) {
        $index++
        $caseRoot = "$runtimeProject/tests/.runs/scenario-$index"
        New-Item -ItemType Directory -Force $caseRoot | Out-Null
        $item = [ordered]@{ scenario = $id; fixture = $Fixture; root = $caseRoot; inputs = $report.inputs
            status = 'incomplete'; reason = ''; process_exit = $null; result = $null }
        $report.scenarios += $item
        if ($id -notin @('dungeon-assembly','view-cursor','binding-config','action-input','qualification','startup','session','m1-composition','variant-inputs','layout-inputs','geography-inputs','faction-quest-inputs','item-spell-inputs','actor-inputs','creation-draft','calendar-clock','ground-movement','actor-state','formula','formula-fault','randomness-session','randomness','native','replacements','media','classic','mods','planning','publication','text','structured-text','locale-fonts','translation-preferences')) {
            $item.reason = 'Required scenario unavailable; real owner/provider not registered'
            continue
        }
        if (($id -eq 'creation-draft' -and $Fixture -ne 'creation-draft-v1') -or ($id -eq 'calendar-clock' -and $Fixture -ne 'calendar-clock-v1') -or ($id -eq 'ground-movement' -and $Fixture -ne 'ground-movement-v1') -or ($id -eq 'dungeon-assembly' -and $Fixture -notin @('dungeon-assembly-v1','dungeon-context-v1','dungeon-markers-v1','location-assembly-v1')) -or ($id -eq 'view-cursor' -and $Fixture -ne 'view-cursor-v1') -or ($id -eq 'binding-config' -and $Fixture -ne 'binding-config-v1') -or ($id -eq 'action-input' -and $Fixture -ne 'action-input-v1') -or ($id -eq 'm1-composition' -and $Fixture -notin @('m1-composition-v1','m1-v1')) -or ($id -eq 'variant-inputs' -and $Fixture -ne 'variant-inputs-v1') -or ($id -eq 'layout-inputs' -and $Fixture -ne 'layout-inputs-v1') -or ($id -eq 'geography-inputs' -and $Fixture -ne 'geography-inputs-v1') -or ($id -eq 'faction-quest-inputs' -and $Fixture -ne 'faction-quest-inputs-v1') -or ($id -eq 'item-spell-inputs' -and $Fixture -ne 'item-spell-inputs-v1') -or ($id -eq 'actor-state' -and $Fixture -ne 'actor-state-v1') -or ($id -eq 'actor-inputs' -and $Fixture -ne 'actor-inputs-v1') -or ($id -eq 'native' -and $Fixture -ne 'native-v1') -or ($id -eq 'replacements' -and $Fixture -ne 'replacements-v1') -or ($id -eq 'media' -and $Fixture -ne 'media-v1') -or ($id -eq 'translation-preferences' -and $Fixture -ne 'translation-preferences-v1') -or ($id -eq 'locale-fonts' -and $Fixture -ne 'locale-fonts-v1') -or ($id -eq 'structured-text' -and $Fixture -ne 'structured-text-v1') -or ($id -eq 'text' -and $Fixture -ne 'text-v1') -or ($id -eq 'formula' -and $Fixture -ne 'formula-v1') -or ($id -eq 'formula-fault' -and $Fixture -notin @('formula-v1','formula-extra-error-v1')) -or ($id -eq 'randomness-session' -and $Fixture -ne 'randomness-session-v1') -or ($id -eq 'randomness' -and $Fixture -ne 'randomness-v1') -or ($id -eq 'publication' -and $Fixture -ne 'publication-v1') -or ($id -eq 'planning' -and $Fixture -ne 'planning-v1') -or ($id -eq 'mods' -and $Fixture -ne 'mods-v1') -or ($id -eq 'classic' -and $Fixture -ne 'classic-v1') -or ($id -notin @('dungeon-assembly','view-cursor','binding-config','action-input','m1-composition','variant-inputs','layout-inputs','geography-inputs','faction-quest-inputs','item-spell-inputs','actor-inputs','creation-draft','calendar-clock','ground-movement','actor-state','formula','formula-fault','randomness-session','randomness','native','replacements','media','classic','mods','planning','publication','text','structured-text','locale-fonts','translation-preferences') -and ($Fixture -notin @('m1-v1','assert-fail-v1') -or ($Fixture -eq 'assert-fail-v1' -and $id -ne 'qualification')))) {
            $item.reason = 'Fixture unavailable for selected scenario'
            continue
        }
        # One named, fixed IMP-012 policy fixture is supported. This does not
        # admit arbitrary replay input, seeds or clocks to fixed owner suites.
        $fixedAirCapSelection = $id -ceq 'ground-movement' -and $Fixture -ceq 'ground-movement-v1' -and $InputSequence -cin @('air-cap-2','calendar-rate-3')
        if ($null -ne $Seed -or $null -ne $Clock -or ($InputSequence -ne '' -and !$fixedAirCapSelection)) {
            $item.reason = 'Selected fixture uses fixed owner inputs; explicit seed/clock/input overrides are unsupported for this selection'
            continue
        }
        # Fresh process AND roots reset all session/static state between scenarios.
        $env:APPDATA = "$caseRoot/engine-roaming"
        $env:LOCALAPPDATA = "$caseRoot/engine-local"
        New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
        $classicLock = $null
        $modLock = $null
        $sourceReadGuards = @()
        $sourceBefore = @{}
        $unreadable = "$caseRoot/locked/ARENA2"
        if ($id -in @('dungeon-assembly','m1-composition','creation-draft','calendar-clock','ground-movement','actor-state','variant-inputs','layout-inputs','geography-inputs','faction-quest-inputs','item-spell-inputs','actor-inputs','creation-draft','calendar-clock','ground-movement','actor-state','native','replacements','media','classic','mods','planning','publication','text','structured-text','locale-fonts','translation-preferences','formula','formula-fault')) {
            if (!$ClassicSource -or !(Test-Path -LiteralPath $ClassicSource -PathType Container)) {
                $item.reason = 'Explicit available -ClassicSource is required'; continue
            }
            $selectedRoot = [IO.Path]::GetFullPath($ClassicSource)
            if ((Split-Path $selectedRoot -Leaf) -ine 'ARENA2') { $selectedRoot = Join-Path $selectedRoot 'ARENA2' }
            $item.selected_source = $selectedRoot
            foreach ($name in ($(if ($id -eq 'creation-draft') { @('CHAR00I0.IMG','CHAR01I0.IMG','CHAR02I0.IMG','CHAR03I0.IMG','CHAR04I0.IMG','CHAR05I0.IMG','TMAP00I0.IMG','CHGN00I0.IMG','BIOG00I0.IMG','CUST00I0.IMG','CUST08I0.IMG','ART_PAL.COL','MAP.PAL','TAMRIEL2.IMG','CLASSES.DAT') + @(Get-CreationAppearanceNames) + @(Get-CreationBookNames) + @(Get-CreationOptionalMediaNames $selectedRoot) } else { @() }) + $(if ($id -in @('dungeon-assembly','variant-inputs','layout-inputs')) { @('TEXTURE.199','TEXTURE.210') } else { @() }) + $(if ($id -in @('dungeon-assembly','m1-composition','creation-draft','calendar-clock','ground-movement','actor-state','variant-inputs','layout-inputs','geography-inputs')) { @('WOODS.WLD','CLIMATE.PAK','POLITIC.PAK') } else { @() }) + $(if ($id -in @('dungeon-assembly','m1-composition','creation-draft','calendar-clock','ground-movement','actor-state','variant-inputs','layout-inputs','geography-inputs','item-spell-inputs','faction-quest-inputs')) { @('SPELLS.STD','MAGIC.DEF') } else { @() }) + $(if ($id -in @('dungeon-assembly','m1-composition','creation-draft','calendar-clock','ground-movement','actor-state','variant-inputs','layout-inputs','geography-inputs','actor-inputs','creation-draft','calendar-clock','ground-movement','actor-state','item-spell-inputs','faction-quest-inputs')) { Get-ActorSourceNames } else { @() }) + @('ARCH3D.BSA','BLOCKS.BSA','MAPS.BSA','DAGGER.SND') + $(if ($id -in @('media','native')) { @('MIDI.BSA','TEXTURE.321','TEXTURE.024','TEXTURE.002','INVE00I0.IMG','APAINT.CIF','BUTTONS.RCI','ART_PAL.COL','ANIM0011.VID') } else { @() }) + $(if ($id -in @('dungeon-assembly','m1-composition','creation-draft','calendar-clock','ground-movement','actor-state','structured-text','locale-fonts','translation-preferences')) { @('TEXT.RSC') } else { @() }))) {
                $sourceBefore[$name] = (Get-FileHash -LiteralPath (Join-Path $selectedRoot $name) -Algorithm SHA256).Hash
                $sourceReadGuards += [IO.File]::Open((Join-Path $selectedRoot $name), [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
            }
            if ($id -in @('dungeon-assembly','m1-composition','creation-draft','calendar-clock','ground-movement','actor-state')) {
                $contextSources = Get-Content -LiteralPath "$project/content/layouts/dungeon_context.json" -Raw | ConvertFrom-Json
                if ($Fixture -in @('dungeon-context-v1','dungeon-markers-v1')) {
                    $observation = Get-Content -LiteralPath "$project/tests/dungeon_context_observation.json" -Raw | ConvertFrom-Json
                    foreach ($block in $observation.fixture_blocks.PSObject.Properties.Value) {
                        foreach ($archive in $block.texture_archives) { $contextSources.resource_sources += @{file=('TEXTURE.{0:000}' -f $archive);format='classic-texture-v1'} }
                    }
                }
                if ($id -in @('dungeon-assembly','m1-composition','creation-draft','calendar-clock','ground-movement','actor-state')) {
                    $locationSources = Get-Content -LiteralPath "$project/tests/location_source_observation.json" -Raw | ConvertFrom-Json
                    $contextSources.resource_sources += $locationSources.resource_sources
                }
                foreach ($source in $contextSources.resource_sources) {
                    $name = $source.file
                    if ($sourceBefore.ContainsKey($name)) { continue }
                    $sourceBefore[$name] = (Get-FileHash -LiteralPath (Join-Path $selectedRoot $name) -Algorithm SHA256).Hash
                    $sourceReadGuards += [IO.File]::Open((Join-Path $selectedRoot $name), [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
                }
            }
            $item.source_access_guard = 'Windows read handles sharing READ only held across child: source write opens denied'
            New-Item -ItemType Directory -Force $unreadable | Out-Null
            foreach ($name in @('ARCH3D.BSA','BLOCKS.BSA','MAPS.BSA','DAGGER.SND')) {
                # Valid one-record numeric BSA; never copy or alter classic inputs.
                [IO.File]::WriteAllBytes("$unreadable/$name", [byte[]]@(1,0,0,2,42,232,3,0,0,1,0,0,0))
            }
            $classicLock = [IO.File]::Open("$unreadable/ARCH3D.BSA", [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
        }
        if ($id -eq 'mods') { $modLock = New-ModFixture $caseRoot }
        @{ sandbox = $caseRoot.Replace('\','/'); mode = $(if ($id -eq 'startup') { 'suite' } else { $id })
            fixture = $Fixture; inputs = $report.inputs; classic_source = $(if ($id -in @('dungeon-assembly','m1-composition','creation-draft','calendar-clock','ground-movement','actor-state','variant-inputs','layout-inputs','geography-inputs','faction-quest-inputs','item-spell-inputs','actor-inputs','creation-draft','calendar-clock','ground-movement','actor-state','native','replacements','media','classic','mods','planning','publication','text','structured-text','locale-fonts','translation-preferences','formula','formula-fault')) { $selectedRoot.Replace('\','/') } else { '' }); unreadable_root = $unreadable.Replace('\','/') } | ConvertTo-Json -Depth 10 | Set-Content "$caseRoot/fixture.json"
        $arguments = @('--path',$runtimeProject,'--max-fps','60','--quit-after','1800','--',"--startup-fixture=$caseRoot/fixture.json")
        if ($id -eq 'native') { $arguments[5] = '12000' }
        if ($Mode -eq 'headless') { $arguments = @('--headless') + $arguments }
        try {
            $outcome = Invoke-Engine $arguments $caseRoot 'console'
            if ($sourceBefore.Count -gt 0) {
                $item['child_source_samples'] = @(@{ child='primary'; before=$sourceBefore; after=(Get-LayoutSourceHashes $sourceBefore $selectedRoot) })
            }
            if ($id -in @('creation-draft','ground-movement','actor-state','dungeon-assembly','view-cursor','binding-config','m1-composition','variant-inputs','layout-inputs','native','replacements','mods','planning','publication','randomness-session','locale-fonts','translation-preferences') -and $outcome.exit -eq 0) {
                $reloadFixture = Get-Content "$caseRoot/fixture.json" -Raw | ConvertFrom-Json
                $reloadFixture.mode = $id + '_reload'
                if ($id -eq 'locale-fonts') { $reloadFixture.sandbox = "$caseRoot/relaunch".Replace('\','/') }
                if ($id -eq 'actor-state') {
                    $reloadFixture.sandbox = "$caseRoot/relaunch".Replace('\','/')
                    $reloadFixture | Add-Member -NotePropertyName restore_from -NotePropertyValue "$caseRoot/activity-checkpoint.bin".Replace('\','/')
                    New-Item -ItemType Directory -Force $reloadFixture.sandbox | Out-Null
                }
                $reloadFixture | ConvertTo-Json -Depth 10 | Set-Content "$caseRoot/reload-fixture.json"
                $reloadArguments = @('--path',$runtimeProject,'--max-fps','60','--quit-after','1800','--',"--startup-fixture=$caseRoot/reload-fixture.json")
                if ($Mode -eq 'headless') { $reloadArguments = @('--headless') + $reloadArguments }
                if ($sourceBefore.Count -gt 0) { $reloadSourceBefore = Get-LayoutSourceHashes $sourceBefore $selectedRoot }
                $reloadOutcome = Invoke-Engine $reloadArguments $caseRoot 'reload-console'
                if ($sourceBefore.Count -gt 0) { $item.child_source_samples += @{ child='reload'; before=$reloadSourceBefore; after=(Get-LayoutSourceHashes $sourceBefore $selectedRoot) } }
                $item.reload_process_exit = $reloadOutcome.exit
            }
        }
        finally {
            if ($null -ne $modLock) { $modLock.Dispose() }
            if ($null -ne $classicLock) { $classicLock.Dispose() }
            foreach ($guard in $sourceReadGuards) { $guard.Dispose() }
            $sourceReadGuards = @()
        }
        if ($id -in @('dungeon-assembly','m1-composition','creation-draft','calendar-clock','ground-movement','actor-state','variant-inputs','layout-inputs','geography-inputs','faction-quest-inputs','item-spell-inputs','actor-inputs','creation-draft','calendar-clock','ground-movement','actor-state','native','replacements','media','classic','mods','planning','publication','text','structured-text','locale-fonts','translation-preferences','formula','formula-fault')) {
            $item.source_before = $sourceBefore
            $item.source_after = @{}
            foreach ($name in $sourceBefore.Keys) {
                $item.source_after[$name] = (Get-FileHash -LiteralPath (Join-Path $selectedRoot $name) -Algorithm SHA256).Hash
                if ($item.source_after[$name] -ne $sourceBefore[$name]) { throw 'Classic source changed during verification' }
            }
        }
        $item.process_exit = $outcome.exit
        if ($outcome.timed_out -or !(Test-Path "$caseRoot/result.json")) {
            $item.reason = 'Timed out, crashed or missing terminal report'
            continue
        }
        try { $result = Get-Content "$caseRoot/result.json" -Raw | ConvertFrom-Json } catch {
            $item.reason = 'Malformed terminal report'; continue
        }
        $item.result = $result
        if ($id -in @('creation-draft','ground-movement','actor-state','dungeon-assembly','view-cursor','binding-config','m1-composition','variant-inputs','layout-inputs','native','replacements','mods','planning','publication','randomness-session','locale-fonts','translation-preferences') -and $result.ok) {
            $reloadReport = if ($id -in @('locale-fonts','actor-state')) { "$caseRoot/relaunch/reload-result.json" } else { "$caseRoot/reload-result.json" }
            if (!(Test-Path $reloadReport)) { $item.reason = 'Missing fresh-process terminal result'; continue }
            $reloadResult = Get-Content $reloadReport -Raw | ConvertFrom-Json
			if ($id -eq 'creation-draft' -and !(Test-CreationInventory $reloadResult 'reload')) { $item.reason = 'Incomplete creation preference fresh-process inventory'; continue }
            if ($id -eq 'ground-movement' -and !(Test-GroundInventory $reloadResult 'reload')) { $item.reason = 'Incomplete ground reload inventory'; continue }
            if ($id -eq 'actor-state' -and !(Test-ActorStateInventory $reloadResult ('reload-' + $Mode))) { $item.reason = 'Incomplete actor reconstruction inventory'; continue }
            if ($id -eq 'dungeon-assembly' -and !(Test-DungeonInventory $reloadResult ('reload-' + $Mode))) { $item.reason = 'Incomplete dungeon restart inventory'; continue }
            if ($id -in @('binding-config','view-cursor')) {
                $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/$(if ($id -eq 'view-cursor') { 'view_cursor' } else { 'binding_config' })_inventory.json" -Raw | ConvertFrom-Json
                $expected = @($inventory.reload)
                $actual = @($reloadResult.checks.scenario)
                if ($reloadResult.fixture -cne $inventory.fixture -or $actual.Count -ne $expected.Count -or
                    @($actual | Select-Object -Unique).Count -ne $actual.Count -or
                    @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -ne 0) {
                    $item.reason = 'Incomplete binding reload inventory'; continue
                }
            }
            if ($id -eq 'variant-inputs' -and !(Test-VariantInventory $reloadResult 'reload')) { $item.reason = 'Incomplete variant reload inventory'; continue }
            if ($id -eq 'layout-inputs' -and !(Test-LayoutInventory $reloadResult 'reload')) { $item.reason = 'Incomplete layout reload inventory'; continue }
            if ($id -eq 'replacements' -and !(Test-ReplacementInventory $reloadResult 'reload')) { $item.reason = 'Incomplete replacement reload terminal inventory'; continue }
            if ($id -eq 'native' -and !(Test-NativeInventory $reloadResult 'reload')) { $item.reason = 'Incomplete native reload terminal inventory'; continue }
            if ($id -eq 'm1-composition' -and !(Test-CompositionInventory $reloadResult ('reload-' + $Mode))) { $item.reason = 'Incomplete M1 composition relaunch inventory'; continue }
            $item.reload_result = $reloadResult
            $reloadExpected = if ($id -eq 'ground-movement') { Get-GroundExpectedCount 'reload' } elseif ($id -eq 'actor-state') { @((Get-Content "$PSScriptRoot/../tests/actor_state_inventory.json" -Raw | ConvertFrom-Json).('reload-' + $Mode)).Count } elseif ($id -eq 'dungeon-assembly') { Get-DungeonExpectedCount ('reload-' + $Mode) } elseif ($id -eq 'm1-composition') { Get-CompositionExpectedCount ('reload-' + $Mode) } elseif ($id -eq 'variant-inputs') { Get-VariantExpectedCount 'reload' } elseif ($id -eq 'layout-inputs') { 15 } elseif ($id -eq 'native') { Get-NativeExpectedCount 'reload' } elseif ($id -in @('replacements','locale-fonts','translation-preferences')) { 10 } elseif ($id -eq 'randomness-session') { 15 } else { 8 }
            if ($reloadOutcome.timed_out -or $null -eq $reloadResult.ok -or $reloadResult.count -ne $reloadExpected -or $reloadResult.checks.Count -ne $reloadExpected -or
                !$reloadResult.engine -or ($Mode -eq 'rendered' -and $reloadResult.display -eq 'headless') -or
                !(Test-ScriptDiagnostics @((Get-Item "$caseRoot/reload-console.*.log").FullName) $(if ($id -eq 'actor-state') { 'actor-state' } else { '' }) $reloadResult)) {
                $item.reason = 'Fresh-process restore incomplete'; continue
            }
            if (!$reloadResult.ok -or @($reloadResult.checks | Where-Object { !(Test-AssertionValue $_.expected $_.actual) }).Count -gt 0) {
                $item.status = 'failed'; $item.reason = 'Fresh-process restore assertion failure'; continue
            }
            if ($reloadOutcome.exit -ne 0) { $item.reason = 'Fresh process exited unsuccessfully'; continue }
        }
        $expectedCounts = if ($Mode -eq 'headless') { @{ 'layout-inputs' = 369; 'geography-inputs' = 200; 'faction-quest-inputs' = 132; 'item-spell-inputs' = 160; 'calendar-clock' = 1; 'ground-movement' = 1; 'actor-state' = 1; 'actor-inputs' = 236; 'view-cursor' = 1; 'binding-config' = 72; 'action-input' = 119; qualification = 2; startup = 84; session = 263; formula = 82; 'formula-fault' = 18; randomness = 108; 'randomness-session' = 115; native = 1; replacements = 168; media = 119; classic = 97; mods = 119; planning = 87; publication = 111; text = 121; 'structured-text' = 284; 'locale-fonts' = 419; 'translation-preferences' = 149 } } else { @{ 'layout-inputs' = 372; 'geography-inputs' = 202; 'faction-quest-inputs' = 134; 'item-spell-inputs' = 162; 'calendar-clock' = 1; 'ground-movement' = 1; 'actor-state' = 1; 'actor-inputs' = 238; 'view-cursor' = 1; 'binding-config' = 73; 'action-input' = 124; qualification = 3; startup = 92; session = 265; formula = 84; 'formula-fault' = 18; randomness = 108; 'randomness-session' = 116; native = 1; replacements = 173; media = 136; classic = 100; mods = 136; planning = 101; publication = 117; text = 127; 'structured-text' = 294; 'locale-fonts' = 441; 'translation-preferences' = 164 } }
        $item.expected_assertions = $expectedCounts[$id]
        if ($id -eq 'dungeon-assembly') {
            $item.expected_assertions = Get-DungeonExpectedCount $Mode
            if (!(Test-DungeonInventory $result $Mode)) { $item.reason = 'Incomplete dungeon assembly inventory'; continue }
        }
        if ($id -eq 'view-cursor') {
            $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/view_cursor_inventory.json" -Raw | ConvertFrom-Json
            $expected = @($inventory.$Mode)
            $actual = @($result.checks | ForEach-Object { $_.scenario })
            $item.expected_assertions = $expected.Count
            if ($inventory.schema -cne 'view-cursor-inventory-v1' -or $result.fixture -cne $inventory.fixture -or
                $actual.Count -ne $expected.Count -or @($actual | Select-Object -Unique).Count -ne $actual.Count -or
                @($expected | Where-Object { $_ -cnotin $actual }).Count -gt 0) {
                $item.reason = 'Incomplete view cursor inventory'; continue
            }
        }
        if ($id -eq 'binding-config') {
            $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/binding_config_inventory.json" -Raw | ConvertFrom-Json
            $expected = @($inventory.$Mode)
            $actual = @($result.checks.scenario)
            $item.expected_assertions = $expected.Count
            if ($inventory.schema -cne 'binding-config-inventory-v1' -or $result.fixture -cne $inventory.fixture -or
                $actual.Count -ne $expected.Count -or @($actual | Select-Object -Unique).Count -ne $actual.Count -or
                @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -ne 0) {
                $item.reason = 'Incomplete binding configuration inventory'; continue
            }
        }
        if ($id -eq 'action-input') {
            $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/action_input_inventory.json" -Raw | ConvertFrom-Json
            $expected = @($inventory.$Mode)
            $actual = @($result.checks.scenario)
            if ($inventory.schema -cne 'action-input-inventory-v1' -or $result.fixture -cne $inventory.fixture -or
                $actual.Count -ne $expected.Count -or @($actual | Select-Object -Unique).Count -ne $actual.Count -or
                @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -ne 0) {
                $item.reason = 'Incomplete logical action input inventory'; continue
            }
        }
        if ($id -eq 'creation-draft') { $item.expected_assertions = $result.count; if (!(Test-CreationInventory $result $Mode)) { $item.reason = 'Incomplete creation inventory'; continue } }
        if ($id -eq 'calendar-clock') { $item.expected_assertions = $result.count; if (!(Test-CalendarInventory $result $Mode)) { $item.reason = 'Incomplete calendar inventory'; continue } }
        if ($id -eq 'ground-movement') { $item.expected_assertions = $result.count; if (!(Test-GroundInventory $result $Mode)) { $item.reason = 'Incomplete ground inventory'; continue } }
        if ($id -eq 'actor-state') { $item.expected_assertions = $result.count; if (!(Test-ActorStateInventory $result $Mode)) { $item.reason = 'Incomplete actor state inventory'; continue } }
        if ($id -eq 'm1-composition') {
            $item.expected_assertions = Get-CompositionExpectedCount $Mode
            if (!(Test-CompositionInventory $result $Mode)) { $item.reason = 'Incomplete M1 composition inventory'; continue }
        }
        if ($id -eq 'variant-inputs') { $item.expected_assertions = Get-VariantExpectedCount $Mode; if (!(Test-VariantInventory $result $Mode)) { $item.reason = 'Incomplete variant inventory'; continue } }
        if ($id -eq 'layout-inputs' -and !(Test-LayoutInventory $result $Mode)) { $item.reason = 'Incomplete layout assertion inventory'; continue }
        if ($id -eq 'geography-inputs' -and !(Test-GeographyInventory $result $Mode)) { $item.reason = 'Incomplete geographic assertion inventory'; continue }
        if ($id -eq 'faction-quest-inputs' -and !(Test-FactionQuestInventory $result $Mode)) { $item.reason = 'Incomplete faction/quest assertion inventory'; continue }
        if ($id -eq 'item-spell-inputs' -and !(Test-ItemSpellInventory $result $Mode)) { $item.reason = 'Incomplete item/spell assertion inventory'; continue }
        if ($id -eq 'actor-inputs' -and !(Test-ActorInventory $result $Mode)) { $item.reason = 'Incomplete actor input assertion inventory'; continue }
        if ($id -eq 'native') { $item.expected_assertions = Get-NativeExpectedCount $Mode }
        if ($id -eq 'native' -and !(Test-NativeInventory $result $Mode)) { $item.reason = 'Incomplete native terminal inventory'; continue }
        if ($id -eq 'replacements' -and !(Test-ReplacementInventory $result $Mode)) { $item.reason = 'Incomplete replacement terminal inventory'; continue }
        if ($id -eq 'media' -and !(Test-MediaInventory $result $Mode)) {
            $item.reason = 'Incomplete or changed classic media terminal inventory'; continue
        }
        $scriptErrors = @(Get-Item "$caseRoot/console.*.log" | ForEach-Object FullName)
        if (!(Test-ScriptDiagnostics $scriptErrors $id $result)) {
            $item.reason = 'Engine reported a script error; terminal assertions cannot qualify this run'; continue
        }
        if ($null -eq $result.ok -or $result.count -ne $item.expected_assertions -or $result.checks.Count -ne $result.count -or !$result.engine -or
            ($Mode -eq 'rendered' -and $result.display -eq 'headless')) {
            $item.reason = 'Incomplete report or unavailable renderer'; continue
        }
        $failed = @($result.checks | Where-Object { !(Test-AssertionValue $_.expected $_.actual) })
        # Legacy assertions report pass/FAIL; qualification reports typed expected/actual.
        if (!$result.ok -or $failed.Count -gt 0) {
            $item.status = 'failed'; $item.reason = 'Assertion failure'
        } elseif ($outcome.exit -ne 0) {
            $item.reason = 'Process exited unsuccessfully despite reported assertions'
        } else { $item.status = 'passed' }
    }
    if (@($report.scenarios | Where-Object status -eq 'incomplete').Count -gt 0) { $report.status = 'incomplete' }
    elseif (@($report.scenarios | Where-Object status -eq 'failed').Count -gt 0) { $report.status = 'failed' }
    elseif ($report.scenarios.Count -gt 0) { $report.status = 'passed' }
} catch {
    $report.status = 'incomplete'
    $report.error = $_.Exception.Message
} finally {
    if ($null -ne $modLock) { $modLock.Dispose() }
    if ($null -ne $classicLock) { $classicLock.Dispose() }
    foreach ($guard in $sourceReadGuards) { $guard.Dispose() }
    $env:APPDATA = $priorRoaming
    $env:LOCALAPPDATA = $priorLocal
    $report | ConvertTo-Json -Depth 40 | Set-Content "$run/report.json"
    Write-Output "$Mode $($report.status): $run/report.json"
}
if ($report.status -eq 'passed') { exit 0 }
if ($report.status -eq 'failed') { exit 1 }
exit 2
