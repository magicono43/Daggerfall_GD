param([string]$ClassicSource = 'C:/Games/Daggerfall/arena2', [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe', [switch]$SmokeTest)
$ErrorActionPreference = 'Stop'
$started = Get-Date
# Rebuild through the maintained DEV-014 runner, never launch a compacted archive.
Write-Output 'Preparing and verifying the ground review (usually 1-2 minutes). The interactive course opens after verification passes.'
Write-Output 'You may use other windows during preparation; focus-loss gameplay checks are controlled by the automated fixture.'
& "$PSScriptRoot/verify_rendered.ps1" -Suite ground-movement -Fixture ground-movement-v1 -ClassicSource $ClassicSource -Godot $Godot -TimeoutSeconds 240
if ($LASTEXITCODE -ne 0) { throw 'Review preparation failed; no interactive review was launched. The report path printed above contains the failure and scenario log paths.' }
$runs = [IO.Path]::GetFullPath("$PSScriptRoot/../tests/.runs")
$candidates = @(Get-ChildItem -LiteralPath $runs -Directory -Filter 'verification-rendered-*' | Where-Object LastWriteTime -ge $started | Sort-Object LastWriteTime -Descending)
$selected = $null
foreach ($candidate in $candidates) {
    $path = Join-Path $candidate.FullName 'report.json'
    if (!(Test-Path -LiteralPath $path)) { continue }
    $report = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    if ($report.suite -eq 'ground-movement' -and $report.status -eq 'passed') { $selected = $report; break }
}
if ($null -eq $selected) { throw 'Could not locate the newly qualified ground review build.' }
$case = $selected.scenarios[0].root
$fixture = Get-Content -LiteralPath "$case/fixture.json" -Raw | ConvertFrom-Json
$fixture.mode = 'ground-review'
$fixture.sandbox = (Join-Path $case 'human-review').Replace('\','/')
if ($SmokeTest) { $fixture | Add-Member -NotePropertyName review_smoke -NotePropertyValue $true }
New-Item -ItemType Directory -Force $fixture.sandbox | Out-Null
$fixture | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath "$case/human-review.json"
@{owner='IMP-012 human ground review';root=$selected.root;expiry='Close engine after human review; then compact reproducible project. Rebuild with review_ground.ps1.'} | ConvertTo-Json | Set-Content -LiteralPath "$($selected.root)/ACTIVE-HUMAN-REVIEW.json"
# Running this script explicitly requests the visible interactive review window.
$priorRoaming = $env:APPDATA
$priorLocal = $env:LOCALAPPDATA
$engineExecutable = $Godot
if ($Godot.EndsWith('_console.exe')) {
    $pairedEngine = $Godot.Substring(0, $Godot.Length - '_console.exe'.Length) + '.exe'
    if (Test-Path -LiteralPath $pairedEngine) { $engineExecutable = $pairedEngine }
}
$reviewExit = $null
try {
    $env:APPDATA = "$case/human-engine-roaming"
    $env:LOCALAPPDATA = "$case/human-engine-local"
    New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
    $engineArguments = @('--path', $selected.runtime_project, '--', "--startup-fixture=$case/human-review.json")
    $quoted = @($engineArguments | ForEach-Object { '"' + $_.Replace('"','\"') + '"' })
    $launch = @{FilePath=$engineExecutable;ArgumentList=$quoted;PassThru=$true;Wait=$true;RedirectStandardOutput="$($fixture.sandbox)/engine.stdout.log";RedirectStandardError="$($fixture.sandbox)/engine.stderr.log"}
    if ($SmokeTest) { $launch.WindowStyle = 'Hidden' }
    $process = Start-Process @launch
    $reviewExit = $process.ExitCode
} finally { $env:APPDATA = $priorRoaming; $env:LOCALAPPDATA = $priorLocal }
if ($null -eq $reviewExit -or $reviewExit -ne 0) {
    Move-Item -LiteralPath "$($selected.root)/ACTIVE-HUMAN-REVIEW.json" -Destination "$($selected.root)/HUMAN-REVIEW-FAILED.json"
    throw "Ground review exited unexpectedly (exit $reviewExit). Logs: $($fixture.sandbox)/engine.stderr.log and engine.stdout.log"
}
if ($SmokeTest) {
    $resultPath = "$($fixture.sandbox)/result.json"
    if (!(Test-Path -LiteralPath $resultPath)) { throw 'Ground review smoke did not return its required result.' }
    $result = Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json
    if (!$result.ok -or $result.review_smoke -ne $true) { throw "Ground review smoke failed: $resultPath" }
}
Move-Item -LiteralPath "$($selected.root)/ACTIVE-HUMAN-REVIEW.json" -Destination "$($selected.root)/HUMAN-REVIEW-CLOSED.json"
if ($SmokeTest) { Write-Output "Ground review launch smoke passed; human review remains pending. Result: $resultPath" }
else { Write-Output "Human review closed; no automatic PASS. Review root: $($selected.root)" }
