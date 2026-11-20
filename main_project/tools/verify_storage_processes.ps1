param([string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$run = "$project/tests/.runs/process-$([Guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Force $run | Out-Null
$priorRoaming = $env:APPDATA
$priorLocal = $env:LOCALAPPDATA
$env:APPDATA = "$run/engine-roaming"
$env:LOCALAPPDATA = "$run/engine-local"
New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
$checks = [Collections.Generic.List[object]]::new()
$children = [Collections.Generic.List[object]]::new()

function Start-Case([string]$Name, [string]$Sandbox, [string]$Mode, [string]$Expected, [string]$Alias = '', [string]$Checkpoint = '') {
    New-Item -ItemType Directory -Force $Sandbox | Out-Null
    if (Test-Path "$Sandbox/result.json") { Remove-Item -LiteralPath "$Sandbox/result.json" -Force }
    $fixture = "$run/$Name.json"
    @{ sandbox = $Sandbox.Replace('\', '/'); mode = $Mode; expected_route = $Expected; alias = $Alias; checkpoint = $Checkpoint } |
        ConvertTo-Json | Set-Content $fixture
    $arguments = @('--headless', '--path', ('"' + $project + '"'), '--max-fps', '60', '--quit-after', '3300', '--', ('"--startup-fixture=' + $fixture + '"'))
    $process = Start-Process -FilePath $Godot -ArgumentList $arguments -WindowStyle Hidden -PassThru `
        -RedirectStandardOutput "$run/$Name.stdout.log" -RedirectStandardError "$run/$Name.stderr.log"
    $children.Add($process)
    return $process
}
function Wait-Ready($Process, [string]$Sandbox) {
    $deadline = [DateTime]::UtcNow.AddSeconds(15)
    while (!(Test-Path "$Sandbox/ready.json")) {
        if ($Process.HasExited -or [DateTime]::UtcNow -gt $deadline) { throw "Lease holder failed: $run" }
        Start-Sleep -Milliseconds 100
    }
}
function Assert-Probe([string]$Name, $Process, [string]$Sandbox) {
    if (!$Process.WaitForExit(15000)) { throw "Lease probe timed out: $Name" }
    if ($Process.ExitCode -ne 0 -or !(Test-Path "$Sandbox/result.json")) { throw "Lease probe failed: $Name; $run" }
    $result = Get-Content "$Sandbox/result.json" -Raw | ConvertFrom-Json
    if (!$result.ok) { throw "Lease assertion failed: $Name; $run" }
    Copy-Item "$Sandbox/result.json" "$run/$Name.result.json"
    $checks.Add(@{ scenario = $Name; expected = 'pass'; actual = 'pass'; assertions = $result.count })
}
try {
    & $Godot --headless --path $project --editor --import --quit *> "$run/import.log"
    if ($LASTEXITCODE -ne 0) { throw "Project import failed: $run" }
    $shared = "$run/shared"
    $holder = Start-Case 'holder' $shared 'hold' 'mandatory_setup'
    Wait-Ready $holder $shared
    foreach ($alias in @('', 'dot', 'case')) {
        $name = "conflict-$alias"
        $probe = Start-Case $name $shared 'lease_probe' 'storage_recovery' $alias
        Assert-Probe $name $probe $shared
    }
    New-Item -ItemType Junction -Path "$shared/user-junction" -Target "$shared/user" | Out-Null
    $probe = Start-Case 'conflict-junction' $shared 'lease_probe' 'storage_recovery' 'junction'
    Assert-Probe 'conflict-junction' $probe $shared
    $distinct = "$run/distinct"
    $probe = Start-Case 'concurrent-distinct' $distinct 'lease_probe' 'mandatory_setup'
    Assert-Probe 'concurrent-distinct' $probe $distinct
    # Kill only the process object created by this fixture. Stale lease file remains.
    $holder.Kill()
    $holder.WaitForExit()
    $probe = Start-Case 'reacquire-after-termination' $shared 'lease_probe' 'mandatory_setup'
    Assert-Probe 'reacquire-after-termination' $probe $shared
    $probe = Start-Case 'reacquire-after-normal-exit' $shared 'lease_probe' 'mandatory_setup'
    Assert-Probe 'reacquire-after-normal-exit' $probe $shared
    foreach ($checkpoint in @('backup', 'settings_publish')) {
        $sandbox = "$run/interruption-$checkpoint"
        $writer = Start-Case "writer-$checkpoint" $sandbox 'interrupted_publication' '' '' $checkpoint
        Wait-Ready $writer $sandbox
        $writer.Kill()
        $writer.WaitForExit()
        $settings = "$sandbox/user/settings/settings.ini"
        if ((Get-Content $settings -Raw) -ne (Get-Content "$sandbox/expected-active.ini" -Raw)) {
            throw "Interrupted publication altered active settings: $checkpoint"
        }
        $probe = Start-Case "reopen-$checkpoint" $sandbox 'lease_probe' 'mandatory_setup'
        Assert-Probe "reopen-$checkpoint" $probe $sandbox
        if ((Get-Content $settings -Raw) -ne (Get-Content "$sandbox/expected-active.ini" -Raw)) {
            throw "Reopen promoted interrupted staging: $checkpoint"
        }
        $expectedBackup = if ($checkpoint -eq 'backup') { "$sandbox/expected-original.ini" } else { "$sandbox/expected-active.ini" }
        if ((Get-Content "$settings.backup" -Raw) -ne (Get-Content $expectedBackup -Raw)) {
            throw "Interrupted publication lost validated backup: $checkpoint"
        }
    }
    @{ ok = $true; fixture = 'IMP-001-Windows-process-v1'; checks = $checks } |
        ConvertTo-Json -Depth 8 | Set-Content "$run/result.json"
    Write-Output "Windows process PASS: $($checks.Count) scenarios; evidence: $run"
} finally {
    foreach ($child in $children) { if (!$child.HasExited) { $child.Kill(); $child.WaitForExit() } }
    $env:APPDATA = $priorRoaming
    $env:LOCALAPPDATA = $priorLocal
}
