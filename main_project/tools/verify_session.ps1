param(
    [ValidateSet('headless', 'rendered')][string]$Mode = 'headless',
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe'
)
$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$run = "$project/tests/.runs/session-$Mode-$([Guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Force $run | Out-Null
@{ sandbox = $run.Replace('\', '/'); mode = 'session' } | ConvertTo-Json | Set-Content "$run/fixture.json"
# Isolate engine-created editor/cache files too, independently of the game root.
$priorRoaming = $env:APPDATA
$priorLocal = $env:LOCALAPPDATA
try {
$env:APPDATA = "$run/engine-roaming"
$env:LOCALAPPDATA = "$run/engine-local"
New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
& $Godot --headless --path $project --editor --import --quit *> "$run/import.log"
if ($LASTEXITCODE -ne 0) { throw "Project import failed; evidence: $run" }
$arguments = @('--path', $project, '--max-fps', '60', '--quit-after', '1800', '--', "--startup-fixture=$run/fixture.json")
if ($Mode -eq 'headless') { $arguments = @('--headless') + $arguments }
& $Godot @arguments *> "$run/console.log"
if ($LASTEXITCODE -ne 0 -or !(Test-Path "$run/result.json")) {
    Get-Content "$run/console.log"
    throw "Session suite failed; evidence: $run"
}
$result = Get-Content "$run/result.json" -Raw | ConvertFrom-Json
if (!$result.ok) { throw "Session assertions failed; evidence: $run" }
Write-Output "$Mode PASS: $($result.count) assertions; evidence: $run"
} finally {
    $env:APPDATA = $priorRoaming
    $env:LOCALAPPDATA = $priorLocal
}

