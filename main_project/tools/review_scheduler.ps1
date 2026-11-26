param(
    [string]$ClassicSource = 'C:/Games/Daggerfall/arena2',
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe',
    [switch]$SmokeTest
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/assertion_values.ps1"
if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'Run this launcher using installed PowerShell 7 (pwsh.exe).' }
$runs = [IO.Path]::GetFullPath("$PSScriptRoot/../tests/.runs")
$existing = @((Get-ChildItem -LiteralPath $runs -Directory).FullName)
Write-Output 'Building and verifying the scheduler review; the interactive shell opens after checks pass.'
& "$PSScriptRoot/verify_rendered.ps1" -Suite calendar-clock -Fixture calendar-clock-v1 -ClassicSource $ClassicSource -Godot $Godot -TimeoutSeconds 240
if ($LASTEXITCODE -ne 0) { throw 'Calendar preparation failed; inspect the printed report.' }
$selected = $null
foreach ($candidate in Get-ChildItem -LiteralPath $runs -Directory -Filter 'verification-rendered-*' | Where-Object { $_.FullName -notin $existing }) {
    $report = Get-Content -LiteralPath "$($candidate.FullName)/report.json" -Raw | ConvertFrom-Json
    if ($report.suite -eq 'calendar-clock' -and $report.status -eq 'passed') { $selected = $report }
}
if ($null -eq $selected) { throw 'New qualified review build unavailable.' }
$case = $selected.scenarios[0].root
$fixture = Get-Content -LiteralPath "$case/fixture.json" -Raw | ConvertFrom-Json
$fixture.mode = 'calendar-scheduler-review'
$fixture.sandbox = "$case/human-review"
$fixture | Add-Member -NotePropertyName review_smoke -NotePropertyValue ([bool]$SmokeTest)
New-Item -ItemType Directory -Force $fixture.sandbox | Out-Null
$fixture | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath "$case/human-review.json"
@{owner='IMP-014 scheduler review';expiry='Close the engine after review, preserve evidence, then compact this reproducible build. Rebuild with review_scheduler.ps1.'} | ConvertTo-Json | Set-Content -LiteralPath "$($selected.root)/ACTIVE-HUMAN-REVIEW.json"
$engine = $Godot.Replace('_console.exe','.exe')
if (!(Test-Path -LiteralPath $engine)) { $engine = $Godot }
$engineArgs = @('--path',$selected.runtime_project,'--',"--startup-fixture=$case/human-review.json")
$quoted = @($engineArgs | ForEach-Object { '"' + $_.Replace('"','\"') + '"' })
$launch = @{FilePath=$engine;ArgumentList=$quoted;PassThru=$true;Wait=$true;RedirectStandardOutput="$($fixture.sandbox)/engine.stdout.log";RedirectStandardError="$($fixture.sandbox)/engine.stderr.log"}
if ($SmokeTest) { $launch.WindowStyle = 'Hidden' }
$priorRoaming = $env:APPDATA
$priorLocal = $env:LOCALAPPDATA
try {
    $env:APPDATA = "$case/human-engine-roaming"
    $env:LOCALAPPDATA = "$case/human-engine-local"
    New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
    $process = Start-Process @launch
} finally { $env:APPDATA = $priorRoaming; $env:LOCALAPPDATA = $priorLocal }
if ($process.ExitCode -ne 0) { throw "Scheduler review failed: $($fixture.sandbox)" }
if ($SmokeTest) {
    $result = Get-Content -LiteralPath "$($fixture.sandbox)/result.json" -Raw | ConvertFrom-Json
    if (!$result.ok -or !$result.review_smoke -or $result.human_pass -or $result.count -ne 6) { throw 'Scheduler review smoke failed.' }
    if (!(Test-ScriptDiagnostics @("$($fixture.sandbox)/engine.stdout.log","$($fixture.sandbox)/engine.stderr.log") '' $result)) { throw 'Scheduler review reported an unexpected engine diagnostic.' }
}
Move-Item -LiteralPath "$($selected.root)/ACTIVE-HUMAN-REVIEW.json" -Destination "$($selected.root)/CLOSED-HUMAN-REVIEW.json"
Write-Output "Scheduler review closed. Evidence: $($fixture.sandbox)"

