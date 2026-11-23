param([Parameter(Mandatory=$true)][string]$VerifiedRun)
$ErrorActionPreference = 'Stop'
$source = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$runs = [IO.Path]::GetFullPath("$source/tests/.runs")
$verified = [IO.Path]::GetFullPath($VerifiedRun)
if (!$verified.StartsWith($runs + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Expected a disposable verification root' }
$report = Get-Content -LiteralPath "$verified/report.json" -Raw | ConvertFrom-Json
if ($report.status -ne 'passed' -or $report.suite -ne 'binding-config') { throw 'A passing binding-config run is required' }
foreach ($property in $report.build.sources.PSObject.Properties) {
    $relative = $property.Name.Replace('\','/')
    if ($relative -notmatch '^(scripts/|tests/binding_|config/)') { continue }
    if ((Get-FileHash -LiteralPath "$source/$($property.Name)" -Algorithm SHA256).Hash -ne $property.Value) { throw "Source changed since verification: $($property.Name)" }
}
$review = Join-Path $runs 'imp011-binding-review-2026-11-23'
if (Test-Path -LiteralPath $review) { throw 'Existing review package is protected; do not overwrite human inputs' }
function Copy-Resources([string]$From,[string]$To) {
    New-Item -ItemType Directory -Force $To | Out-Null
    foreach ($entry in Get-ChildItem -LiteralPath $From) {
        if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Unexpected resource link' }
        if ($entry.PSIsContainer) {
            if ($entry.Name -in @('.godot','.runs','tools','.zig-cache','zig-out')) { continue }
            Copy-Resources $entry.FullName "$To/$($entry.Name)"
        } elseif ($entry.Extension -notin @('.pdb','.lib')) {
            Copy-Item -LiteralPath $entry.FullName -Destination "$To/$($entry.Name)"
        }
    }
}
Copy-Resources "$verified/project" "$review/project"
$oldRoaming = $env:APPDATA
$oldLocal = $env:LOCALAPPDATA
try {
    $env:APPDATA = "$review/import-roaming"
    $env:LOCALAPPDATA = "$review/import-local"
    New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
    $engine = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64.exe'
    $import = Start-Process -FilePath $engine -ArgumentList @('--headless','--path',('"'+$review+'/project"'),'--import','--quit-after','60') -WindowStyle Hidden -PassThru -RedirectStandardOutput "$review/import.stdout.log" -RedirectStandardError "$review/import.stderr.log"
    if (!$import.WaitForExit(120000)) { $import.Kill($true); throw 'Review import timed out' }
    $import.WaitForExit()
    if ($import.ExitCode -ne 0 -or (Select-String -LiteralPath "$review/import.stderr.log" -Pattern 'SCRIPT ERROR|Parse Error|Failed to load')) { throw 'Review import failed' }
} finally { $env:APPDATA = $oldRoaming; $env:LOCALAPPDATA = $oldLocal }
Copy-Item -LiteralPath "$PSScriptRoot/binding_review_launch.ps1" -Destination "$review/Launch.ps1"
@{ schema='binding-review-v1'; verified_report="$verified/report.json"; verified_report_sha256=(Get-FileHash "$verified/report.json").Hash
    revision=$report.build.source_revision; sources=$report.build.sources; expiry='2026-11-30'
    purpose='Outstanding human keyboard/mouse binding-editor review. Controlled CORE provider only; no movement/camera or physical controller/IME acceptance.'
    preserve='All project/tests/.runs/review-* human state and logs before removing reproducible payload.' } | ConvertTo-Json -Depth 10 | Set-Content "$review/BUILD.json"
Write-Output $review
