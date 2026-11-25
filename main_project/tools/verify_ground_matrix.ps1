param([string]$ClassicSource = 'C:/Games/Daggerfall/arena2', [switch]$GroundOnly)
$ErrorActionPreference = 'Stop'
$runs = [IO.Path]::GetFullPath("$PSScriptRoot/../tests/.runs")
$auditPath = Join-Path $runs ('imp012-matrix-' + [Guid]::NewGuid().ToString('N') + '.json')
$jobs = @(
    @{tool='verify_headless.ps1';parameters=@{Suite='ground-movement';Fixture='ground-movement-v1';ClassicSource=$ClassicSource;TimeoutSeconds=240}},
    @{tool='verify_rendered.ps1';parameters=@{Suite='ground-movement';Fixture='ground-movement-v1';ClassicSource=$ClassicSource;TimeoutSeconds=240}},
    @{tool='verify_headless.ps1';parameters=@{Suite='action-input';Fixture='action-input-v1'}},
    @{tool='verify_headless.ps1';parameters=@{Suite='binding-config';Fixture='binding-config-v1'}},
    @{tool='verify_rendered.ps1';parameters=@{Suite='view-cursor';Fixture='view-cursor-v1'}},
    @{tool='verify_headless.ps1';parameters=@{Suite='actor-state';Fixture='actor-state-v1';ClassicSource=$ClassicSource;TimeoutSeconds=240}},
    @{tool='verify_rendered.ps1';parameters=@{Suite='actor-state';Fixture='actor-state-v1';ClassicSource=$ClassicSource;TimeoutSeconds=240}},
    @{tool='verify_headless.ps1';parameters=@{Suite='session';Fixture='m1-v1'}},
    @{tool='verify_headless.ps1';parameters=@{Suite='formula';Fixture='formula-v1';ClassicSource=$ClassicSource}},
    @{tool='verify_headless.ps1';parameters=@{Suite='randomness';Fixture='randomness-v1'}},
    @{tool='verify_headless.ps1';parameters=@{Suite='randomness-session';Fixture='randomness-session-v1'}},
    @{tool='verify_headless.ps1';parameters=@{Suite='m1-composition';Fixture='m1-composition-v1';ClassicSource=$ClassicSource;TimeoutSeconds=240}},
    @{tool='verify_headless.ps1';parameters=@{Suite='location-assembly';Fixture='location-assembly-v1';ClassicSource=$ClassicSource;TimeoutSeconds=240}},
    @{tool='verify_startup_export.ps1';parameters=@{Configuration='debug';GroundMovement=$true;ClassicSource=$ClassicSource}},
    @{tool='verify_startup_export.ps1';parameters=@{Configuration='release';GroundMovement=$true;ClassicSource=$ClassicSource}}
)
if ($GroundOnly) { $jobs = @($jobs | Where-Object { $_.parameters.Suite -eq 'ground-movement' -or $_.parameters.GroundMovement }) }
$audit = [ordered]@{schema='IMP-012-increment-1-matrix-v1';ground_only=[bool]$GroundOnly;started=[DateTime]::UtcNow.ToString('o');source_revision=(& git -C "$PSScriptRoot/../.." rev-parse HEAD);commands=@();status='running'}
Write-Output "Ground matrix audit: $auditPath"
foreach ($job in $jobs) {
    $before = @(Get-ChildItem -LiteralPath $runs -Directory | Select-Object -ExpandProperty Name)
    $entry = [ordered]@{tool=$job.tool;parameters=$job.parameters;started=[DateTime]::UtcNow.ToString('o');status='running';reports=@()}
    $audit.commands += $entry
    $audit | ConvertTo-Json -Depth 16 | Set-Content -LiteralPath $auditPath
    $parameters = $job.parameters
    & (Join-Path $PSScriptRoot $job.tool) @parameters
    $entry.exit = $LASTEXITCODE
    $entry.finished = [DateTime]::UtcNow.ToString('o')
    $entry.reports = @(Get-ChildItem -LiteralPath $runs -Directory | Where-Object Name -NotIn $before | ForEach-Object {
        $reportPath = Join-Path $_.FullName 'report.json'
        if (Test-Path -LiteralPath $reportPath) { $reportPath } else { Join-Path $_.FullName 'result.json' }
    } | Where-Object { Test-Path -LiteralPath $_ })
    $entry.status = if ($entry.exit -eq 0) { 'passed' } else { 'failed' }
    $audit | ConvertTo-Json -Depth 16 | Set-Content -LiteralPath $auditPath
    if ($entry.exit -ne 0) { $audit.status='failed'; $audit | ConvertTo-Json -Depth 16 | Set-Content -LiteralPath $auditPath; throw "Ground matrix stopped at $($job.tool); $auditPath" }
}
$audit.status='passed'
$audit.finished=[DateTime]::UtcNow.ToString('o')
$audit | ConvertTo-Json -Depth 16 | Set-Content -LiteralPath $auditPath
Write-Output "Ground matrix passed: $auditPath"
