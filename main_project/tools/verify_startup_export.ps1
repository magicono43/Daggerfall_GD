param(
	[ValidateSet('debug','release')][string]$Configuration = 'debug',
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe',
    [string]$Templates = "$env:APPDATA/Godot/export_templates/4.7.2.stable",
    [string]$ClassicSource = '',
    [switch]$ModDiscovery,
    [switch]$DependencyPlanning,
    [switch]$DefinitionPublication,
    [switch]$TextCatalog,
    [switch]$StructuredText,
    [switch]$LocaleFonts,
    [switch]$TranslationPreferences,
    [switch]$ClassicMedia,
    [switch]$MediaReplacements,
    [switch]$NativeMedia,
    [switch]$Randomness,
    [switch]$RandomnessSession,
    [switch]$Formula,
    [switch]$FormulaFault,
    [switch]$FormulaExtraError
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/mod_fixture.ps1"
. "$PSScriptRoot/assertion_values.ps1"
function Invoke-IsolatedExport([string]$Executable,[string[]]$EngineArguments,[string]$Log) {
    $priorPath = $env:PATH
    try {
        $env:PATH = "$env:SystemRoot/System32;$env:SystemRoot"
        & $Executable @EngineArguments *> $Log
        return $LASTEXITCODE
    } finally { $env:PATH = $priorPath }
}
$project = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$run = "$project/tests/.runs/export-$([Guid]::NewGuid().ToString('N'))"
$build = "$run/build"
$runtimeProject = "$run/project"
New-Item -ItemType Directory -Force $build | Out-Null
$priorRoaming = $env:APPDATA
$priorLocal = $env:LOCALAPPDATA
$report = @{ ok = $false; status = 'incomplete'; configuration = $Configuration; classic_source = $ClassicSource
    fixture = $(if ($FormulaExtraError) {'formula-extra-error-v1'} elseif ($Formula -or $FormulaFault) {'formula-v1'} elseif ($RandomnessSession) {'randomness-session-v1'} elseif ($Randomness) {'randomness-v1'} elseif ($DefinitionPublication) {'publication-v1'} elseif ($DependencyPlanning) {'planning-v1'} elseif ($ModDiscovery) {'mods-v1'} elseif ($ClassicSource) {'classic-v1'} else {'IMP-001-Windows-export-v1'}); checks = @()
    reproduction = @{ command = './main_project/tools/verify_startup_export.ps1'; arguments = @{
        Configuration = $Configuration; ClassicSource = $ClassicSource; ModDiscovery = [bool]$ModDiscovery; DependencyPlanning = [bool]$DependencyPlanning; DefinitionPublication = [bool]$DefinitionPublication; Randomness = [bool]$Randomness; RandomnessSession = [bool]$RandomnessSession; Formula = [bool]$Formula; FormulaFault = [bool]$FormulaFault; FormulaExtraError = [bool]$FormulaExtraError; Godot = $Godot; Templates = $Templates } } }
function Copy-ExportResources([string]$Source, [string]$Destination) {
    New-Item -ItemType Directory -Force $Destination | Out-Null
    foreach ($entry in Get-ChildItem -LiteralPath $Source) {
        if ($entry.PSIsContainer) {
            if ($entry.Name -in @('.godot','.runs','tools','.zig-cache','zig-out')) { continue }
            Copy-ExportResources $entry.FullName "$Destination/$($entry.Name)"
        } elseif ($entry.Extension -notin @('.pdb','.lib')) {
            Copy-Item -LiteralPath $entry.FullName -Destination "$Destination/$($entry.Name)"
        }
    }
}
try {
if ($NativeMedia) { $report.fixture = 'native-v1'; $report.reproduction.arguments.NativeMedia = $true }
if ($MediaReplacements) { $report.fixture = 'replacements-v1'; $report.reproduction.arguments.MediaReplacements = $true }
if ($ClassicMedia) { $report.fixture = 'media-v1'; $report.reproduction.arguments.ClassicMedia = $true }
if ($ClassicMedia -and !$ClassicSource) { throw 'Classic media checks require an explicit real -ClassicSource' }
if ($TranslationPreferences) { $report.fixture = 'translation-preferences-v1'; $report.reproduction.arguments.TranslationPreferences = $true }
if ($LocaleFonts) { $report.fixture = 'locale-fonts-v1'; $report.reproduction.arguments.LocaleFonts = $true }
if ($StructuredText) { $report.fixture = 'structured-text-v1'; $report.reproduction.arguments.StructuredText = $true }
if ($TextCatalog) { $report.fixture = 'text-v1'; $report.reproduction.arguments.TextCatalog = $true }
if ($FormulaExtraError -and !$FormulaFault) { throw 'Additional formula errors require the explicit fault scenario' }
if (($NativeMedia -or $MediaReplacements -or $TranslationPreferences -or $LocaleFonts -or $StructuredText -or $TextCatalog -or $ModDiscovery -or $DependencyPlanning -or $DefinitionPublication -or $Formula -or $FormulaFault) -and !$ClassicSource) { throw 'Mod checks require an explicit real -ClassicSource' }
if (@($NativeMedia,$MediaReplacements,$ClassicMedia,$TranslationPreferences,$LocaleFonts,$StructuredText,$TextCatalog,$ModDiscovery,$DependencyPlanning,$DefinitionPublication,$Randomness,$RandomnessSession,$Formula,$FormulaFault | Where-Object { $_ }).Count -gt 1) { throw 'Select one owner scenario per export invocation' }
$env:APPDATA = "$run/engine-roaming"
$env:LOCALAPPDATA = "$run/engine-local"
New-Item -ItemType Directory -Force "$env:APPDATA/Godot/export_templates",$env:LOCALAPPDATA | Out-Null
# Installed templates are read-only build inputs; editor state goes to the run.
New-Item -ItemType Junction -Path "$env:APPDATA/Godot/export_templates/4.7.2.stable" -Target $Templates | Out-Null
$exportOption = "--export-$Configuration"
Copy-ExportResources $project $runtimeProject
& $Godot --headless --path $runtimeProject --import --quit-after 60 *> "$run/import.log"
if ($LASTEXITCODE -ne 0) { throw 'Export project import failed' }
if (!(Test-ScriptDiagnostics @("$run/import.log") '' $null)) { throw 'Export import unexpected engine error' }
& $Godot --headless --path $runtimeProject $exportOption 'Windows Desktop' "$build/Startup.exe" *> "$run/export.log"
if ($LASTEXITCODE -ne 0 -or !(Test-Path "$build/Startup.exe") -or !(Test-ScriptDiagnostics @("$run/export.log") '' $null)) {
    Get-Content "$run/export.log" -Tail 30
    throw "Windows export failed: $run"
}
$checks = @()
$licenseRoot = "$build/licenses/native-media"
New-Item -ItemType Directory -Force $licenseRoot | Out-Null
Copy-Item -LiteralPath "$project/native/media/notices" -Destination "$licenseRoot/notices" -Recurse
Copy-Item -LiteralPath "$project/native/media/provenance" -Destination "$licenseRoot/provenance" -Recurse
Copy-Item -LiteralPath "$project/native/media/dependencies.lock.json","$project/native/media/README.md" -Destination $licenseRoot
Copy-Item -LiteralPath "$project/content/media/banks/GENERALUSER_LICENSE.txt" -Destination $licenseRoot
$report.native_media_sha256 = (Get-FileHash "$project/native/media/bin/media_windows.dll").Hash
foreach ($mode in @('headless','rendered')) {
    $sandbox = "$build/tests/.runs/$mode"
    New-Item -ItemType Directory -Force $sandbox | Out-Null
    $fixture = @{ sandbox = $sandbox.Replace('\', '/'); mode = 'route_only'; expected_route = 'mandatory_setup' }
    $guards = @()
    $before = @{}
    $classicLock = $null
    $modLock = $null
    if ($ClassicSource) {
        $selectedRoot = [IO.Path]::GetFullPath($ClassicSource)
        if ((Split-Path $selectedRoot -Leaf) -ine 'ARENA2') { $selectedRoot = Join-Path $selectedRoot 'ARENA2' }
        $lockedRoot = "$sandbox/locked/ARENA2"
        New-Item -ItemType Directory -Force $lockedRoot | Out-Null
        foreach ($name in (@('ARCH3D.BSA','BLOCKS.BSA','MAPS.BSA','DAGGER.SND') + $(if ($ClassicMedia -or $NativeMedia) { @('MIDI.BSA','TEXTURE.321','TEXTURE.024','TEXTURE.002','INVE00I0.IMG','APAINT.CIF','BUTTONS.RCI','ART_PAL.COL','ANIM0011.VID') } else { @() }) + $(if ($TranslationPreferences -or $StructuredText -or $LocaleFonts) { @('TEXT.RSC') } else { @() }))) {
            $before[$name] = (Get-FileHash -LiteralPath (Join-Path $selectedRoot $name) -Algorithm SHA256).Hash
            $guards += [IO.File]::Open((Join-Path $selectedRoot $name), [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
            [IO.File]::WriteAllBytes("$lockedRoot/$name", [byte[]]@(1,0,0,2,42,232,3,0,0,1,0,0,0))
        }
        $classicLock = [IO.File]::Open("$lockedRoot/ARCH3D.BSA", [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
        $fixture = @{ sandbox = $sandbox.Replace('\','/'); mode = 'classic'; fixture = 'classic-v1'; inputs = @{}
            classic_source = $selectedRoot.Replace('\','/'); unreadable_root = $lockedRoot.Replace('\','/') }
    }
    if ($ModDiscovery) {
        $fixture.mode = 'mods'
        $fixture.fixture = 'mods-v1'
        $modLock = New-ModFixture $sandbox
    }
    if ($DependencyPlanning) {
        $fixture.mode = 'planning'
        $fixture.fixture = 'planning-v1'
    }
    if ($DefinitionPublication) {
        $fixture.mode = 'publication'
        $fixture.fixture = 'publication-v1'
    }
    if ($StructuredText) { $fixture.mode = 'structured-text'; $fixture.fixture = 'structured-text-v1' }
    if ($LocaleFonts) { $fixture.mode = 'locale-fonts'; $fixture.fixture = 'locale-fonts-v1' }
    if ($TranslationPreferences) { $fixture.mode = 'translation-preferences'; $fixture.fixture = 'translation-preferences-v1' }
    if ($NativeMedia) { $fixture.mode = 'native'; $fixture.fixture = 'native-v1' }
    if ($MediaReplacements) { $fixture.mode = 'replacements'; $fixture.fixture = 'replacements-v1' }
    if ($ClassicMedia) { $fixture.mode = 'media'; $fixture.fixture = 'media-v1' }
    if ($TextCatalog) {
        $fixture.mode = 'text'
        $fixture.fixture = 'text-v1'
    }
    if ($Randomness) {
        if ($ClassicSource) { throw 'Numeric randomness does not use a classic content source' }
        $fixture = @{ sandbox = $sandbox.Replace('\','/'); mode = 'randomness'; fixture = 'randomness-v1'; inputs = @{} }
    }
    if ($RandomnessSession) {
        if ($ClassicSource) { throw 'Session randomness does not use a classic content source' }
        $fixture = @{ sandbox = $sandbox.Replace('\','/'); mode = 'randomness-session'; fixture = 'randomness-session-v1'; inputs = @{} }
    }
    if ($Formula -or $FormulaFault) {
        $fixture.mode = if ($FormulaFault) { 'formula-fault' } else { 'formula' }
        $fixture.fixture = if ($FormulaExtraError) { 'formula-extra-error-v1' } else { 'formula-v1' }
    }
    $fixture |
        ConvertTo-Json | Set-Content "$sandbox/fixture.json"
    $arguments = @('--max-fps','60','--quit-after','900','--',"--startup-fixture=$sandbox/fixture.json")
    if ($NativeMedia) { $arguments[3] = '12000' }
    if ($mode -eq 'headless') { $arguments = @('--headless') + $arguments }
    $engineExit = Invoke-IsolatedExport "$build/Startup.console.exe" $arguments "$run/$mode.log"
    if (($NativeMedia -or $MediaReplacements -or $TranslationPreferences -or $LocaleFonts -or $ModDiscovery -or $DependencyPlanning -or $DefinitionPublication -or $RandomnessSession) -and $engineExit -eq 0) {
        $fixture.mode = if ($NativeMedia) { 'native_reload' } elseif ($MediaReplacements) { 'replacements_reload' } elseif ($TranslationPreferences) { 'translation-preferences_reload' } elseif ($LocaleFonts) { 'locale-fonts_reload' } elseif ($RandomnessSession) { 'randomness-session_reload' } elseif ($DefinitionPublication) { 'publication_reload' } elseif ($DependencyPlanning) { 'planning_reload' } else { 'mods_reload' }
        if ($LocaleFonts) { $fixture.sandbox = "$sandbox/relaunch".Replace('\','/') }
        $fixture | ConvertTo-Json -Depth 10 | Set-Content "$sandbox/reload-fixture.json"
        $reloadArguments = @('--max-fps','60','--quit-after','900','--',"--startup-fixture=$sandbox/reload-fixture.json")
        if ($mode -eq 'headless') { $reloadArguments = @('--headless') + $reloadArguments }
        $reloadExit = Invoke-IsolatedExport "$build/Startup.console.exe" $reloadArguments "$run/$mode-reload.log"
        $reloadReport = if ($LocaleFonts) { "$sandbox/relaunch/reload-result.json" } else { "$sandbox/reload-result.json" }
        if (!(Test-Path $reloadReport)) { throw 'Missing exported fresh-process result' }
        $reloadResult = Get-Content $reloadReport -Raw | ConvertFrom-Json
        if ($MediaReplacements -and !(Test-ReplacementInventory $reloadResult 'reload')) { throw 'Incomplete exported replacement reload terminal inventory' }
        if ($NativeMedia -and !(Test-NativeInventory $reloadResult 'reload')) { throw 'Incomplete exported native reload inventory' }
        $reloadExpected = if ($NativeMedia) { Get-NativeExpectedCount 'reload' } elseif ($MediaReplacements -or $TranslationPreferences -or $LocaleFonts) { 10 } elseif ($RandomnessSession) { 15 } else { 8 }
        if ($null -eq $reloadResult.ok -or $reloadResult.count -ne $reloadExpected -or $reloadResult.checks.Count -ne $reloadExpected -or !$reloadResult.engine -or
            ($mode -eq 'rendered' -and $reloadResult.display -eq 'headless') -or
            !(Test-ScriptDiagnostics @("$run/$mode-reload.log") '' $reloadResult)) { throw 'Exported fresh-process restore incomplete' }
        if (!$reloadResult.ok -or @($reloadResult.checks | Where-Object { !(Test-AssertionValue $_.expected $_.actual) }).Count -gt 0) {
            $report.status = 'failed'; throw 'Exported fresh-process assertion failure'
        }
        if ($reloadExit -ne 0) { throw 'Exported fresh process exited unsuccessfully' }
    }
    foreach ($guard in $guards) { $guard.Dispose() }
    $guards = @()
    if ($null -ne $classicLock) { $classicLock.Dispose() }
    if ($null -ne $modLock) { $modLock.Dispose() }
    if (!(Test-Path "$sandbox/result.json")) {
        Get-Content "$run/$mode.log" -Tail 30
        throw "Exported startup failed: $mode; $run"
    }
    $result = Get-Content "$sandbox/result.json" -Raw | ConvertFrom-Json
    $report.engine = $result.engine
    if ($NativeMedia -and !(Test-NativeInventory $result $mode)) { throw 'Incomplete exported native terminal inventory' }
    if ($MediaReplacements -and !(Test-ReplacementInventory $result $mode)) { throw 'Incomplete exported replacement terminal inventory' }
    if ($ClassicMedia -and !(Test-MediaInventory $result $mode)) { throw 'Incomplete or changed exported media terminal inventory' }
    $report.native_sha256 = (Get-FileHash "$project/native/storage/bin/storage_windows.dll" ).Hash
    $report.executable_sha256 = (Get-FileHash "$build/Startup.exe" ).Hash
    if ($null -eq $result.ok -or !$result.engine -or $result.checks.Count -ne $result.count -or
        ($mode -eq 'rendered' -and $result.display -eq 'headless')) { throw 'Incomplete exported terminal report' }
    $diagnosticScenario = if ($NativeMedia) { 'native' } elseif ($FormulaFault) { 'formula-fault' } else { '' }
    if (!(Test-ScriptDiagnostics @("$run/$mode.log") $diagnosticScenario $result)) { throw 'Exported unexpected or unmatched script error' }
    if (!$result.ok -or @($result.checks | Where-Object { !(Test-AssertionValue $_.expected $_.actual) }).Count -gt 0) { $report.status = 'failed'; throw "Exported startup assertions failed: $mode; $run" }
    if ($engineExit -ne 0) { throw 'Export process exited unsuccessfully' }
    $after = @{}
    foreach ($name in $before.Keys) {
        $after[$name] = (Get-FileHash -LiteralPath (Join-Path $selectedRoot $name) -Algorithm SHA256).Hash
        if ($after[$name] -ne $before[$name]) { throw 'Classic source changed' }
    }
    $expected = if ($NativeMedia) { Get-NativeExpectedCount $mode } elseif ($MediaReplacements) { if ($mode -eq 'headless') {168} else {173} } elseif ($ClassicMedia) { if ($mode -eq 'headless') {119} else {136} } elseif ($TranslationPreferences) { if ($mode -eq 'headless') {149} else {164} } elseif ($LocaleFonts) { if ($mode -eq 'headless') {419} else {441} } elseif ($StructuredText) { if ($mode -eq 'headless') {284} else {294} } elseif ($TextCatalog) { if ($mode -eq 'headless') {121} else {127} } elseif ($DefinitionPublication) { if ($mode -eq 'headless') {111} else {117} } elseif ($DependencyPlanning) { if ($mode -eq 'headless') {87} else {101} } elseif ($ModDiscovery) { if ($mode -eq 'headless') {119} else {136} } else { if ($mode -eq 'headless') {97} else {100} }
    $formulaExpected = if ($FormulaFault) { 18 } elseif ($mode -eq 'headless') { 82 } else { 84 }
    if (($Formula -or $FormulaFault) -and $result.count -ne $formulaExpected) { throw 'Incomplete formula export inventory' }
    $sessionExpected = if ($mode -eq 'headless') { 115 } else { 116 }
    if ($RandomnessSession -and $result.count -ne $sessionExpected) { throw 'Incomplete session random export inventory' }
    if ($Randomness -and $result.count -ne 108) { throw 'Incomplete numeric export inventory' }
    if ($ClassicSource -and !$Formula -and !$FormulaFault -and $result.count -ne $expected) { throw 'Incomplete owner export result' }
    $checks += @{ scenario = "exported-$mode"; actual = 'pass'; assertions = $result.count; process_exit = $engineExit
        source_before = $before; source_after = $after; result = "$sandbox/result.json" }
    if ($NativeMedia -or $MediaReplacements -or $TranslationPreferences -or $LocaleFonts -or $ModDiscovery -or $DependencyPlanning -or $DefinitionPublication -or $RandomnessSession) { $checks[-1].reload = @{ assertions = $reloadExpected; process_exit = $reloadExit; result = $reloadReport } }
    if ($NativeMedia) {
        if (!$result.native_cleanup.ok) { throw 'Exported native consumer cleanup failed.' }
        $checks[-1].capabilities = $result.observations.capabilities
        $pwsh = (Get-Process -Id $PID).Path
        & $pwsh -NoProfile -File "$PSScriptRoot/verify_native_libraries.ps1" -Mode $mode -ClassicSource $ClassicSource -ExportDirectory $build
        if ($LASTEXITCODE -ne 0) { throw 'Exported isolated dependency fault matrix failed.' }
        & $pwsh -NoProfile -File "$PSScriptRoot/verify_native_libraries.ps1" -Mode $mode -ClassicSource $ClassicSource -ExportDirectory $build -BankRecovery
        if ($LASTEXITCODE -ne 0) { throw 'Exported PCK default-bank fault matrix failed.' }
    }
    $report.checks = $checks
}
$report.ok = $true
$report.status = 'passed'
$report.native_sha256 = (Get-FileHash "$project/native/storage/bin/storage_windows.dll").Hash
$report.executable_sha256 = (Get-FileHash "$build/Startup.exe").Hash
$report.engine = $result.engine
Write-Output "Windows $Configuration export PASS: headless and rendered startup; evidence: $run"
} catch {
    $report.error = $_.Exception.Message
    Write-Output "Windows $Configuration export $($report.status): $run/result.json"
} finally {
    if ($null -ne $modLock) { $modLock.Dispose() }
    foreach ($guard in $guards) { $guard.Dispose() }
    if ($null -ne $classicLock) { $classicLock.Dispose() }
    $env:APPDATA = $priorRoaming
    $env:LOCALAPPDATA = $priorLocal
    $report | ConvertTo-Json -Depth 12 | Set-Content "$run/result.json"
}
if ($report.status -eq 'passed') { exit 0 }
if ($report.status -eq 'failed') { exit 1 }
exit 2
