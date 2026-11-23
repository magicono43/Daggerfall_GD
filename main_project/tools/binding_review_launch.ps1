param([switch]$ResumeLast)
$ErrorActionPreference = 'Stop'
$project = Join-Path $PSScriptRoot 'project'
$prior = @((Get-ChildItem -LiteralPath "$project/tests/.runs" -Directory -Filter 'review-*' -ErrorAction SilentlyContinue) | Sort-Object Name)
$sandbox = if ($ResumeLast -and $prior.Count) { $prior[-1].FullName } else { Join-Path $project ('tests/.runs/review-' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss')) }
New-Item -ItemType Directory -Force $sandbox,"$sandbox/engine-roaming","$sandbox/engine-local" | Out-Null
@{sandbox=$sandbox.Replace('\','/');mode='binding-review';fixture='binding-review-v1'} | ConvertTo-Json | Set-Content "$sandbox/fixture.json"
$oldRoaming = $env:APPDATA
$oldLocal = $env:LOCALAPPDATA
try {
    $env:APPDATA = "$sandbox/engine-roaming"
    $env:LOCALAPPDATA = "$sandbox/engine-local"
    $engine = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64.exe'
    $child = Start-Process -FilePath $engine -ArgumentList @('--path',('"'+$project+'"'),'--',('"--startup-fixture='+$sandbox+'/fixture.json"')) -PassThru -RedirectStandardOutput "$sandbox/console.stdout.log" -RedirectStandardError "$sandbox/console.stderr.log"
    @{pid=$child.Id;sandbox=$sandbox;human_result='Not supplied'} | ConvertTo-Json | Set-Content "$sandbox/launch.json"
    Write-Output "Review PID $($child.Id). Disposable human state: $sandbox"
} finally { $env:APPDATA = $oldRoaming; $env:LOCALAPPDATA = $oldLocal }
