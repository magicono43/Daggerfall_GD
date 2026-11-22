param([string[]]$AdditionalNames = @())
$ErrorActionPreference = 'Stop'
# Exact inactive roots owned by the exploratory increment-2 runs. Standing cleanup
# authorization applies; this list deliberately excludes every other task's runs.
$runs = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../tests/.runs'))
$names = @(
    'verification-headless-441edc5cc3f84d1896698e23eaf5d5fc',
    'verification-headless-4daeded27d964f8ca2bffff2c1b969bb',
    'verification-headless-5b5e440dcb234bf79d66338c5a220417',
    'verification-headless-40707b75429c4fddadada0a5f6bfe923',
    'verification-headless-65f315e724ee4225ab4b072fced9cc03',
    'verification-headless-415bce02e6884499a4d8f6c411795361',
    'verification-headless-9730a09dd2304491b02a3a1d4089f6df',
    'verification-rendered-a0397ede3cb0475f9781582950441d73',
    'verification-headless-f08817e924e144d6b569ffb2e0f6564a',
    'verification-headless-80a1a61f30884a4d8343ca85dc48612b',
    'verification-headless-86f250c7b18f4baabd11b888f91fac70'
) + $AdditionalNames
if (@(Get-Process -Name '*Godot*','Startup','Startup.console' -ErrorAction SilentlyContinue).Count -gt 0) {
    throw 'Defer cleanup while an engine process exists.'
}
$report = @{ schema='layout-run-cleanup-v1'; roots=@(); evidence=@(); removed_files=@(); bytes=0 }
$previousReport = Join-Path $runs 'layout-exploratory-cleanup.json'
if (Test-Path -LiteralPath $previousReport) {
    $prior = Get-Content -LiteralPath $previousReport -Raw | ConvertFrom-Json
    $report.roots = @($prior.roots)
    $report.evidence = @($prior.evidence)
    $report.removed_files = @($prior.removed_files)
    $report.bytes = $prior.bytes
}
foreach ($name in $names) {
    if ($name -notmatch '^(verification-(headless|rendered)|export)-[a-f0-9]{32}$') { throw 'Unrecognized exact task run name' }
    $root = [IO.Path]::GetFullPath((Join-Path $runs $name))
    $project = [IO.Path]::GetFullPath((Join-Path $root 'project'))
    if (!$project.StartsWith($runs + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or
        (Split-Path $project -Leaf) -ne 'project' -or
        !(Test-Path -LiteralPath $(if ($name.StartsWith('export-')) { "$root/result.json" } else { "$root/report.json" }))) {
        throw 'Unverified cleanup target'
    }
    if (!(Test-Path -LiteralPath $project)) { continue }
    $links = @(Get-ChildItem -LiteralPath $project -Recurse -Force -Attributes ReparsePoint)
    if ($links.Count -gt 0) { throw "Defer target with reparse points: $project" }
    $case = Join-Path $project 'tests/.runs/scenario-1'
    $evidence = Join-Path $root 'evidence/scenario-1'
    New-Item -ItemType Directory -Force $evidence | Out-Null
    foreach ($file in $(if (Test-Path -LiteralPath $case) { Get-ChildItem -LiteralPath $case -File } else { @() })) {
        if ($file.Extension -notin @('.json','.log','.png')) { continue }
        $target = Join-Path $evidence $file.Name
        $before = (Get-FileHash -LiteralPath $file.FullName).Hash
        Copy-Item -LiteralPath $file.FullName -Destination $target
        if ((Get-FileHash -LiteralPath $target).Hash -ne $before) { throw 'Evidence copy differs' }
        $report.evidence += @{ original=$file.FullName; retained=$target; sha256=$before }
    }
    if ($name.StartsWith('export-')) {
        foreach ($mode in @('headless','rendered')) {
            $case = Join-Path $root "build/tests/.runs/$mode"
            $evidence = Join-Path $root "evidence/$mode"
            if (!(Test-Path -LiteralPath $case)) { continue }
            New-Item -ItemType Directory -Force $evidence | Out-Null
            foreach ($file in Get-ChildItem -LiteralPath $case -File) {
                if ($file.Extension -notin @('.json','.log','.png')) { continue }
                $target = Join-Path $evidence $file.Name
                $before = (Get-FileHash -LiteralPath $file.FullName).Hash
                Copy-Item -LiteralPath $file.FullName -Destination $target
                if ((Get-FileHash -LiteralPath $target).Hash -ne $before) { throw 'Export evidence copy differs' }
                $report.evidence += @{ original=$file.FullName; retained=$target; sha256=$before }
            }
        }
    }
    $files = @(Get-ChildItem -LiteralPath $project -Recurse -Force -File)
    foreach ($file in $files) {
        $report.removed_files += @{ path=$file.FullName; bytes=$file.Length }
        $report.bytes += $file.Length
    }
    $report.roots += $project
    # Both resolved paths and every reparse-point check above precede recursion.
    Remove-Item -LiteralPath $project -Recurse -Force
    foreach ($child in @('build','engine-roaming','engine-local')) {
        $target = [IO.Path]::GetFullPath((Join-Path $root $child))
        if (!(Test-Path -LiteralPath $target)) { continue }
        if (!$target.StartsWith($root + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Escaping child target' }
        # Export-template junctions point at installed tools. Unlink the workspace
        # entry without recursion, never enumerate or remove their targets.
        foreach ($link in @(Get-ChildItem -LiteralPath $target -Recurse -Force -Attributes ReparsePoint)) {
            if ($link.FullName -notlike '*\export_templates\4.7.2.stable') { throw 'Unknown reparse point; defer target' }
            Remove-Item -LiteralPath $link.FullName -Force
        }
        foreach ($file in @(Get-ChildItem -LiteralPath $target -Recurse -Force -File)) {
            $report.removed_files += @{path=$file.FullName;bytes=$file.Length}
            $report.bytes += $file.Length
        }
        $report.roots += $target
        Remove-Item -LiteralPath $target -Recurse -Force
    }
}
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $runs 'layout-exploratory-cleanup.json')
Write-Output "Removed $($report.removed_files.Count) files / $($report.bytes) bytes; compact evidence retained."
