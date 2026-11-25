param([string]$ClassicSource = 'C:/Games/Daggerfall/arena2', [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe', [switch]$SmokeTest, [Alias("ConnectorModel")][ValidateSet(0,61030,67027,67029)][int[]]$ConnectorModels = @(0), [string[]]$ConnectorPlacements = @())
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion.Major -lt 7) {
    throw 'Ground review requires PowerShell 7 (pwsh.exe). Windows PowerShell 5.1 (powershell.exe) can lose the engine exit code and falsely reject its version. Run the review with pwsh.exe -NoProfile -ExecutionPolicy Bypass -Command instead; see IMP-012-STEEP-CONNECTORS-REVIEW-2026-11-25.md for the complete command.'
}
$started = Get-Date
$runs = [IO.Path]::GetFullPath("$PSScriptRoot/../tests/.runs")
$existingRuns = @{}
foreach ($directory in @(Get-ChildItem -LiteralPath $runs -Directory -Filter 'verification-rendered-*')) { $existingRuns[$directory.FullName] = $true }
# Rebuild through the maintained DEV-014 runner, never launch a compacted archive.
Write-Output 'Preparing and verifying the ground review (usually a few minutes). The interactive course opens after verification passes.'
Write-Output 'You may use other windows during preparation; focus-loss gameplay checks are controlled by the automated fixture.'
& "$PSScriptRoot/verify_rendered.ps1" -Suite ground-movement -Fixture ground-movement-v1 -ClassicSource $ClassicSource -Godot $Godot -TimeoutSeconds 360
if ($LASTEXITCODE -ne 0) { throw 'Review preparation failed; no interactive review was launched. The report path printed above contains the failure and scenario log paths.' }
$candidates = @(Get-ChildItem -LiteralPath $runs -Directory -Filter 'verification-rendered-*' | Where-Object { !$existingRuns.ContainsKey($_.FullName) -and $_.CreationTime -ge $started } | Sort-Object CreationTime -Descending)
$selected = $null
foreach ($candidate in $candidates) {
    $path = Join-Path $candidate.FullName 'report.json'
    if (!(Test-Path -LiteralPath $path)) { continue }
    $report = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
    if ($report.suite -eq 'ground-movement' -and $report.status -eq 'passed') { $selected = $report; break }
}
if ($null -eq $selected) { throw 'Could not locate the newly qualified ground review build.' }
function Invoke-GroundHumanReview([int]$Model, [string]$Placement = "") {
$case = $selected.scenarios[0].root
$fixture = Get-Content -LiteralPath "$case/fixture.json" -Raw | ConvertFrom-Json
$fixture.mode = 'ground-review'
$reviewDirectory = if ($Model -gt 0) { 'human-review-' + $Model } else { 'human-review' }
if ($Placement) { $reviewDirectory = "human-review-source-" + $Placement.Replace("/","-") }
$fixture.sandbox = (Join-Path $case $reviewDirectory).Replace('\','/')
if ($Model -gt 0) { $fixture | Add-Member -NotePropertyName connector_model -NotePropertyValue $Model }
if ($Placement) {
    $fixture | Add-Member -NotePropertyName connector_source_placement -NotePropertyValue $Placement
    $fixture | Add-Member -NotePropertyName connector_full_block -NotePropertyValue $true
}
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
    Move-Item -LiteralPath "$($selected.root)/ACTIVE-HUMAN-REVIEW.json" -Destination "$($selected.root)/HUMAN-REVIEW-FAILED-$reviewDirectory.json"
    throw "Ground review exited unexpectedly (exit $reviewExit). Logs: $($fixture.sandbox)/engine.stderr.log and engine.stdout.log"
}
if ($SmokeTest) {
    $resultPath = "$($fixture.sandbox)/result.json"
    if (!(Test-Path -LiteralPath $resultPath)) { throw 'Ground review smoke did not return its required result.' }
    $result = Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json
    if (!$result.ok -or $result.review_smoke -ne $true) { throw "Ground review smoke failed: $resultPath" }
}
Move-Item -LiteralPath "$($selected.root)/ACTIVE-HUMAN-REVIEW.json" -Destination "$($selected.root)/HUMAN-REVIEW-CLOSED-$reviewDirectory.json"
if ($SmokeTest) { Write-Output "Ground review launch smoke passed; human review remains pending. Result: $resultPath" }
else { Write-Output "Human review closed; no automatic PASS. Review root: $($selected.root)" }

}
if ($PSBoundParameters.ContainsKey('ConnectorModels') -or $ConnectorPlacements.Count -eq 0) {
    foreach ($model in @($ConnectorModels | Select-Object -Unique)) { Invoke-GroundHumanReview $model }
}
if ($ConnectorPlacements.Count -gt 0) {
    $groundDefinition = Get-Content -LiteralPath (Join-Path $selected.runtime_project 'content/move/ground.json') -Raw | ConvertFrom-Json
    foreach ($placement in @($ConnectorPlacements | Select-Object -Unique)) {
        $matching = @($groundDefinition.entries[0].value.connectors | Where-Object { ($_.block + '/' + $_.record) -ceq $placement })
        if ($matching.Count -ne 1) { throw "Placement is not in the checked connector list: $placement" }
        Invoke-GroundHumanReview ([int]$matching[0].model) $placement
    }
}
