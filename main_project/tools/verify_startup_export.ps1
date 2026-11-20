param(
	[ValidateSet('debug','release')][string]$Configuration = 'debug',
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe',
    [string]$Templates = "$env:APPDATA/Godot/export_templates/4.7.2.stable",
    [string]$ClassicSource = ''
)
$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$run = "$project/tests/.runs/export-$([Guid]::NewGuid().ToString('N'))"
$build = "$run/build"
$runtimeProject = "$run/project"
New-Item -ItemType Directory -Force $build | Out-Null
$priorRoaming = $env:APPDATA
$priorLocal = $env:LOCALAPPDATA
$report = @{ ok = $false; status = 'incomplete'; configuration = $Configuration; classic_source = $ClassicSource
    fixture = $(if ($ClassicSource) {'classic-v1'} else {'IMP-001-Windows-export-v1'}); checks = @()
    reproduction = @{ command = './main_project/tools/verify_startup_export.ps1'; arguments = @{
        Configuration = $Configuration; ClassicSource = $ClassicSource; Godot = $Godot; Templates = $Templates } } }
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
$env:APPDATA = "$run/engine-roaming"
$env:LOCALAPPDATA = "$run/engine-local"
New-Item -ItemType Directory -Force "$env:APPDATA/Godot/export_templates",$env:LOCALAPPDATA | Out-Null
# Installed templates are read-only build inputs; editor state goes to the run.
New-Item -ItemType Junction -Path "$env:APPDATA/Godot/export_templates/4.7.2.stable" -Target $Templates | Out-Null
$exportOption = "--export-$Configuration"
Copy-ExportResources $project $runtimeProject
& $Godot --headless --path $runtimeProject --import --quit-after 60 *> "$run/import.log"
if ($LASTEXITCODE -ne 0) { throw 'Export project import failed' }
& $Godot --headless --path $runtimeProject $exportOption 'Windows Desktop' "$build/Startup.exe" *> "$run/export.log"
if ($LASTEXITCODE -ne 0 -or !(Test-Path "$build/Startup.exe")) {
    Get-Content "$run/export.log" -Tail 30
    throw "Windows export failed: $run"
}
$checks = @()
foreach ($mode in @('headless','rendered')) {
    $sandbox = "$build/tests/.runs/$mode"
    New-Item -ItemType Directory -Force $sandbox | Out-Null
    $fixture = @{ sandbox = $sandbox.Replace('\', '/'); mode = 'route_only'; expected_route = 'mandatory_setup' }
    $guards = @()
    $before = @{}
    $classicLock = $null
    if ($ClassicSource) {
        $selectedRoot = [IO.Path]::GetFullPath($ClassicSource)
        if ((Split-Path $selectedRoot -Leaf) -ine 'ARENA2') { $selectedRoot = Join-Path $selectedRoot 'ARENA2' }
        $lockedRoot = "$sandbox/locked/ARENA2"
        New-Item -ItemType Directory -Force $lockedRoot | Out-Null
        foreach ($name in @('ARCH3D.BSA','BLOCKS.BSA','MAPS.BSA','DAGGER.SND')) {
            $before[$name] = (Get-FileHash -LiteralPath (Join-Path $selectedRoot $name) -Algorithm SHA256).Hash
            $guards += [IO.File]::Open((Join-Path $selectedRoot $name), [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
            [IO.File]::WriteAllBytes("$lockedRoot/$name", [byte[]]@(1,0,0,2,42,232,3,0,0,1,0,0,0))
        }
        $classicLock = [IO.File]::Open("$lockedRoot/ARCH3D.BSA", [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
        $fixture = @{ sandbox = $sandbox.Replace('\','/'); mode = 'classic'; fixture = 'classic-v1'; inputs = @{}
            classic_source = $selectedRoot.Replace('\','/'); unreadable_root = $lockedRoot.Replace('\','/') }
    }
    $fixture |
        ConvertTo-Json | Set-Content "$sandbox/fixture.json"
    $arguments = @('--max-fps','60','--quit-after','900','--',"--startup-fixture=$sandbox/fixture.json")
    if ($mode -eq 'headless') { $arguments = @('--headless') + $arguments }
    & "$build/Startup.console.exe" @arguments *> "$run/$mode.log"
    $engineExit = $LASTEXITCODE
    foreach ($guard in $guards) { $guard.Dispose() }
    $guards = @()
    if ($null -ne $classicLock) { $classicLock.Dispose() }
    if (!(Test-Path "$sandbox/result.json")) {
        Get-Content "$run/$mode.log" -Tail 30
        throw "Exported startup failed: $mode; $run"
    }
    $result = Get-Content "$sandbox/result.json" -Raw | ConvertFrom-Json
    if ($null -eq $result.ok -or !$result.engine -or $result.checks.Count -ne $result.count -or
        ($mode -eq 'rendered' -and $result.display -eq 'headless')) { throw 'Incomplete exported terminal report' }
    if (Select-String -Path "$run/$mode.log" -Pattern 'SCRIPT ERROR:' -Quiet) { throw 'Exported script error' }
    if (!$result.ok) { $report.status = 'failed'; throw "Exported startup assertions failed: $mode; $run" }
    if ($engineExit -ne 0) { throw 'Export process exited unsuccessfully' }
    $after = @{}
    foreach ($name in $before.Keys) {
        $after[$name] = (Get-FileHash -LiteralPath (Join-Path $selectedRoot $name) -Algorithm SHA256).Hash
        if ($after[$name] -ne $before[$name]) { throw 'Classic source changed' }
    }
    if ($ClassicSource -and $result.count -ne $(if ($mode -eq 'headless') {97} else {100})) { throw 'Incomplete classic export result' }
    $checks += @{ scenario = "exported-$mode"; actual = 'pass'; assertions = $result.count; process_exit = $engineExit
        source_before = $before; source_after = $after; result = "$sandbox/result.json" }
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
    foreach ($guard in $guards) { $guard.Dispose() }
    if ($null -ne $classicLock) { $classicLock.Dispose() }
    $env:APPDATA = $priorRoaming
    $env:LOCALAPPDATA = $priorLocal
    $report | ConvertTo-Json -Depth 12 | Set-Content "$run/result.json"
}
if ($report.status -eq 'passed') { exit 0 }
if ($report.status -eq 'failed') { exit 1 }
exit 2
