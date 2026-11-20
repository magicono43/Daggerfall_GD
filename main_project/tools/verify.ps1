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
    $child = Start-Process -FilePath $engineExecutable -ArgumentList $quoted -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput "$Directory/$Name.stdout.log" -RedirectStandardError "$Directory/$Name.stderr.log"
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
try {
    $env:APPDATA = "$run/engine-roaming"
    $env:LOCALAPPDATA = "$run/engine-local"
    New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
    $versionRun = Invoke-Engine @('--headless','--version') $run 'version'
    $report.engine = (Get-Content "$run/version.stdout.log" -Raw).Trim()
    if ($versionRun.exit -ne 0 -or $report.engine -notmatch '^4\.7\.2\.stable') { throw 'Godot 4.7.2 stable is required' }
    foreach ($path in @('project.godot','native/storage/bin/storage_windows.dll')) {
        $report.build[$path] = (Get-FileHash "$project/$path" -Algorithm SHA256).Hash
    }
    $report.build.source_revision = (& git -C $project rev-parse HEAD)
    $report.build.working_tree = @(& git -C $project status --short)
    $report.build.sources = @{}
    foreach ($source in Get-ChildItem "$project/scripts","$project/tests","$project/tools","$project/config","$project/native/storage" -File -Recurse |
        Where-Object { $_.FullName -notmatch '[\\/](\.runs|\.toolchain|bin|\.zig-cache|zig-out)[\\/]' -and $_.Extension -in @('.gd','.ps1','.cpp','.ini','.gdextension') }) {
        $report.build.sources[[IO.Path]::GetRelativePath($project,$source.FullName)] = (Get-FileHash $source.FullName -Algorithm SHA256).Hash
    }
    Copy-VerificationResources $project $runtimeProject
    $import = Invoke-Engine @('--headless','--path',$runtimeProject,'--import','--quit-after','60') $run 'import'
    if ($import.timed_out -or $import.exit -ne 0) { throw 'Project import did not complete successfully' }
    $selected = $Scenario
    if ($selected.Count -eq 0) {
        $selected = switch ($Suite) {
            'm1' { @('qualification','startup','session') }
            'qualification' { @('qualification') }
            'startup' { @('startup') }
            'session' { @('session') }
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
        if ($id -notin @('qualification','startup','session','classic')) {
            $item.reason = 'Required scenario unavailable; real owner/provider not registered'
            continue
        }
        if (($id -eq 'classic' -and $Fixture -ne 'classic-v1') -or ($id -ne 'classic' -and ($Fixture -notin @('m1-v1','assert-fail-v1') -or ($Fixture -eq 'assert-fail-v1' -and $id -ne 'qualification')))) {
            $item.reason = 'Fixture unavailable for selected scenario'
            continue
        }
        if ($null -ne $Seed -or $null -ne $Clock -or $InputSequence -ne '') {
            $item.reason = 'Selected M1 scenarios use fixed owner vectors and consume no RNG or game clock; explicit controls require a future owner scenario'
            continue
        }
        # Fresh process AND roots reset all session/static state between scenarios.
        $env:APPDATA = "$caseRoot/engine-roaming"
        $env:LOCALAPPDATA = "$caseRoot/engine-local"
        New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
        $classicLock = $null
        $sourceReadGuards = @()
        $sourceBefore = @{}
        $unreadable = "$caseRoot/locked/ARENA2"
        if ($id -eq 'classic') {
            if (!$ClassicSource -or !(Test-Path -LiteralPath $ClassicSource -PathType Container)) {
                $item.reason = 'Explicit available -ClassicSource is required'; continue
            }
            $selectedRoot = [IO.Path]::GetFullPath($ClassicSource)
            if ((Split-Path $selectedRoot -Leaf) -ine 'ARENA2') { $selectedRoot = Join-Path $selectedRoot 'ARENA2' }
            $item.selected_source = $selectedRoot
            foreach ($name in @('ARCH3D.BSA','BLOCKS.BSA','MAPS.BSA','DAGGER.SND')) {
                $sourceBefore[$name] = (Get-FileHash -LiteralPath (Join-Path $selectedRoot $name) -Algorithm SHA256).Hash
                $sourceReadGuards += [IO.File]::Open((Join-Path $selectedRoot $name), [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
            }
            $item.source_access_guard = 'Windows read handles sharing READ only held across child: source write opens denied'
            New-Item -ItemType Directory -Force $unreadable | Out-Null
            foreach ($name in @('ARCH3D.BSA','BLOCKS.BSA','MAPS.BSA','DAGGER.SND')) {
                # Valid one-record numeric BSA; never copy or alter classic inputs.
                [IO.File]::WriteAllBytes("$unreadable/$name", [byte[]]@(1,0,0,2,42,232,3,0,0,1,0,0,0))
            }
            $classicLock = [IO.File]::Open("$unreadable/ARCH3D.BSA", [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
        }
        @{ sandbox = $caseRoot.Replace('\','/'); mode = $(if ($id -eq 'startup') { 'suite' } else { $id })
            fixture = $Fixture; inputs = $report.inputs; classic_source = $(if ($id -eq 'classic') { $selectedRoot.Replace('\','/') } else { '' }); unreadable_root = $unreadable.Replace('\','/') } | ConvertTo-Json -Depth 10 | Set-Content "$caseRoot/fixture.json"
        $arguments = @('--path',$runtimeProject,'--max-fps','60','--quit-after','1800','--',"--startup-fixture=$caseRoot/fixture.json")
        if ($Mode -eq 'headless') { $arguments = @('--headless') + $arguments }
        try { $outcome = Invoke-Engine $arguments $caseRoot 'console' }
        finally {
            if ($null -ne $classicLock) { $classicLock.Dispose() }
            foreach ($guard in $sourceReadGuards) { $guard.Dispose() }
            $sourceReadGuards = @()
        }
        if ($id -eq 'classic') {
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
        $expectedCounts = if ($Mode -eq 'headless') { @{ qualification = 2; startup = 84; session = 263; classic = 97 } } else { @{ qualification = 3; startup = 92; session = 264; classic = 100 } }
        $item.expected_assertions = $expectedCounts[$id]
        $scriptErrors = Select-String -Path "$caseRoot/console.*.log" -Pattern 'SCRIPT ERROR:' -Quiet
        if ($scriptErrors -contains $true) {
            $item.reason = 'Engine reported a script error; terminal assertions cannot qualify this run'; continue
        }
        if ($null -eq $result.ok -or $result.count -ne $item.expected_assertions -or $result.checks.Count -ne $result.count -or !$result.engine -or
            ($Mode -eq 'rendered' -and $result.display -eq 'headless')) {
            $item.reason = 'Incomplete report or unavailable renderer'; continue
        }
        $failed = @($result.checks | Where-Object { $_.expected -cne $_.actual })
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
