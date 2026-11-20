param(
	[ValidateSet('debug','release')][string]$Configuration = 'debug',
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe',
    [string]$Templates = "$env:APPDATA/Godot/export_templates/4.7.2.stable"
)
$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$run = "$project/tests/.runs/export-$([Guid]::NewGuid().ToString('N'))"
$build = "$run/build"
New-Item -ItemType Directory -Force $build | Out-Null
$priorRoaming = $env:APPDATA
$priorLocal = $env:LOCALAPPDATA
try {
$env:APPDATA = "$run/engine-roaming"
$env:LOCALAPPDATA = "$run/engine-local"
New-Item -ItemType Directory -Force "$env:APPDATA/Godot/export_templates",$env:LOCALAPPDATA | Out-Null
# Installed templates are read-only build inputs; editor state goes to the run.
New-Item -ItemType Junction -Path "$env:APPDATA/Godot/export_templates/4.7.2.stable" -Target $Templates | Out-Null
$exportOption = "--export-$Configuration"
& $Godot --headless --path $project $exportOption 'Windows Desktop' "$build/Startup.exe" *> "$run/export.log"
if ($LASTEXITCODE -ne 0 -or !(Test-Path "$build/Startup.exe")) {
    Get-Content "$run/export.log" -Tail 30
    throw "Windows export failed: $run"
}
$checks = @()
foreach ($mode in @('headless','rendered')) {
    $sandbox = "$build/tests/.runs/$mode"
    New-Item -ItemType Directory -Force $sandbox | Out-Null
    @{ sandbox = $sandbox.Replace('\', '/'); mode = 'route_only'; expected_route = 'mandatory_setup' } |
        ConvertTo-Json | Set-Content "$sandbox/fixture.json"
    $arguments = @('--max-fps','60','--quit-after','900','--',"--startup-fixture=$sandbox/fixture.json")
    if ($mode -eq 'headless') { $arguments = @('--headless') + $arguments }
    & "$build/Startup.console.exe" @arguments *> "$run/$mode.log"
    if ($LASTEXITCODE -ne 0 -or !(Test-Path "$sandbox/result.json")) {
        Get-Content "$run/$mode.log" -Tail 30
        throw "Exported startup failed: $mode; $run"
    }
    $result = Get-Content "$sandbox/result.json" -Raw | ConvertFrom-Json
    if (!$result.ok) { throw "Exported startup assertions failed: $mode; $run" }
    $checks += @{ scenario = "exported-$mode"; actual = 'pass'; assertions = $result.count }
}
@{ ok = $true; fixture = 'IMP-001-Windows-export-v1'; configuration = $Configuration; checks = $checks } |
    ConvertTo-Json -Depth 8 | Set-Content "$run/result.json"
Write-Output "Windows $Configuration export PASS: headless and rendered startup; evidence: $run"
} finally {
    $env:APPDATA = $priorRoaming
    $env:LOCALAPPDATA = $priorLocal
}
