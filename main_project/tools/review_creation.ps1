param(
    [string]$ClassicSource = 'C:/Games/Daggerfall/arena2',
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe',
    [switch]$SmokeTest,
    [switch]$RaceCareer,
    [switch]$BiographyRolls
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/assertion_values.ps1"
if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'Run this launcher using installed PowerShell 7 (pwsh.exe).' }
$runs = [IO.Path]::GetFullPath("$PSScriptRoot/../tests/.runs")
$existing = @((Get-ChildItem -LiteralPath $runs -Directory).FullName)
Write-Output 'Building and verifying the creation review; the interactive shell opens after checks pass.'
& "$PSScriptRoot/verify_rendered.ps1" -Suite creation-draft -Fixture creation-draft-v1 -ClassicSource $ClassicSource -Godot $Godot -TimeoutSeconds 240
if ($LASTEXITCODE -ne 0) { throw 'Creation preparation failed; inspect the printed report.' }
$selected = $null
foreach ($candidate in Get-ChildItem -LiteralPath $runs -Directory -Filter 'verification-rendered-*' | Where-Object { $_.FullName -notin $existing }) {
    $report = Get-Content -LiteralPath "$($candidate.FullName)/report.json" -Raw | ConvertFrom-Json
    if ($report.suite -eq 'creation-draft' -and $report.status -eq 'passed') { $selected = $report }
}
if ($null -eq $selected) { throw 'New qualified review build unavailable.' }
$case = $selected.scenarios[0].root
$fixture = Get-Content -LiteralPath "$case/fixture.json" -Raw | ConvertFrom-Json
$fixture.mode = 'creation-review'
$fixture.sandbox = "$case/human-review"
$fixture | Add-Member -NotePropertyName review_smoke -NotePropertyValue ([bool]$SmokeTest)
$fixture | Add-Member -NotePropertyName career_review -NotePropertyValue ([bool]$RaceCareer)
$fixture | Add-Member -NotePropertyName biography_review -NotePropertyValue ([bool]$BiographyRolls)
New-Item -ItemType Directory -Force $fixture.sandbox | Out-Null
$fixture | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath "$case/human-review.json"
@{owner='IMP-015 creation review';expiry='Close the engine after review, preserve evidence, then compact this reproducible build. Rebuild with review_creation.ps1.'} | ConvertTo-Json | Set-Content -LiteralPath "$($selected.root)/ACTIVE-HUMAN-REVIEW.json"
$engine = $Godot.Replace('_console.exe','.exe')
if (!(Test-Path -LiteralPath $engine)) { $engine = $Godot }
$engineArgs = @('--path',$selected.runtime_project,'--',"--startup-fixture=$case/human-review.json")
$quoted = @($engineArgs | ForEach-Object { '"' + $_.Replace('"','\"') + '"' })
$launch = @{FilePath=$engine;ArgumentList=$quoted;PassThru=$true;Wait=$true;RedirectStandardOutput="$($fixture.sandbox)/engine.stdout.log";RedirectStandardError="$($fixture.sandbox)/engine.stderr.log"}
if ($SmokeTest) { $launch.WindowStyle = 'Hidden'; $launch.Wait = $false }
$priorRoaming = $env:APPDATA
$priorLocal = $env:LOCALAPPDATA
$process = $null
try {
    $env:APPDATA = "$case/human-engine-roaming"
    $env:LOCALAPPDATA = "$case/human-engine-local"
    New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
    $process = Start-Process @launch
    if ($SmokeTest) {
        if (!$process.WaitForExit(120000)) {
            $process.Kill($true)
            $process.WaitForExit()
            throw 'Creation review smoke timed out; the owned child was stopped.'
        }
        $process.WaitForExit()
    }
} finally {
    $env:APPDATA = $priorRoaming
    $env:LOCALAPPDATA = $priorLocal
    if (($null -eq $process -or $process.HasExited) -and (Test-Path -LiteralPath "$($selected.root)/ACTIVE-HUMAN-REVIEW.json")) {
        Move-Item -LiteralPath "$($selected.root)/ACTIVE-HUMAN-REVIEW.json" -Destination "$($selected.root)/CLOSED-HUMAN-REVIEW.json"
    }
}
if ($process.ExitCode -ne 0) { throw "Creation review failed: $($fixture.sandbox)" }
if ($SmokeTest) {
    $result = Get-Content -LiteralPath "$($fixture.sandbox)/result.json" -Raw | ConvertFrom-Json
    $expectedSmoke = if ($BiographyRolls) { 6 } else { 4 }
    if (!$result.ok -or !$result.review_smoke -or $result.human_pass -or $result.count -ne $expectedSmoke) { throw 'Creation review smoke failed.' }
    if (!(Test-ScriptDiagnostics @("$($fixture.sandbox)/engine.stdout.log","$($fixture.sandbox)/engine.stderr.log") '' $result)) { throw 'Creation review reported an unexpected engine diagnostic.' }
}
. "$PSScriptRoot/run_artifacts.ps1"
Complete-ReviewArtifacts -Root $selected.root -OwnedChild $process
Write-Output "Creation review closed. Evidence: $($fixture.sandbox)"

