param([Parameter(Mandatory)][string[]]$Names)
$ErrorActionPreference = 'Stop'
$runs = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../tests/.runs'))
if (@(Get-Process -Name '*Godot*','Startup','Startup.console' -ErrorAction SilentlyContinue).Count) { throw 'Defer cleanup while an engine is active.' }
$stamp = [Guid]::NewGuid().ToString('N')
$manifest = Join-Path $runs "variant-cleanup-$stamp.json"
$plan = @{schema='variant-run-cleanup-v1'; status='planned'; targets=@(); evidence=@(); files=@(); links=@(); bytes=0; deleted=@(); failures=@()}
foreach ($name in $Names) {
    if ($name -notmatch '^(verification-(headless|rendered)|export)-[a-f0-9]{32}$') { throw 'Unrecognized exact generated run name.' }
    $root = [IO.Path]::GetFullPath((Join-Path $runs $name))
    if (!$root.StartsWith($runs+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Escaping root.' }
    if ((Get-Item -LiteralPath $root).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked run root; defer.' }
    foreach ($child in @('project','build','engine-roaming','engine-local')) {
        $path = Join-Path $root $child
        if ((Test-Path -LiteralPath $path) -and ((Get-Item -LiteralPath $path).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Linked payload root; defer.' }
    }
    if (!(Test-Path -LiteralPath "$root/report.json") -and !(Test-Path -LiteralPath "$root/result.json")) { throw "Missing terminal runner report: $root" }
    # These are known runner payload directories. Preserve compact evidence first.
    foreach ($case in @('project/tests/.runs/scenario-1','build/tests/.runs/headless','build/tests/.runs/rendered')) {
        $source = Join-Path $root $case
        if (!(Test-Path -LiteralPath $source)) { continue }
        $destination = Join-Path $root ('evidence/'+(Split-Path $case -Leaf))
        New-Item -ItemType Directory -Force $destination | Out-Null
        foreach ($file in Get-ChildItem -LiteralPath $source -File) {
            if ($file.Extension -notin @('.json','.log','.png')) { continue }
            $target = Join-Path $destination $file.Name
            $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
            Copy-Item -LiteralPath $file.FullName -Destination $target -Force
            if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash -ne $hash) { throw 'Evidence recovery hash mismatch.' }
            $plan.evidence += @{original=$file.FullName; retained=$target; sha256=$hash}
        }
    }
    foreach ($child in @('project','build','engine-roaming','engine-local')) {
        $target = [IO.Path]::GetFullPath((Join-Path $root $child))
        if (!(Test-Path -LiteralPath $target)) { continue }
        if (!$target.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Escaping payload.' }
        foreach ($link in @(Get-ChildItem -LiteralPath $target -Recurse -Force -Attributes ReparsePoint)) {
            if ($link.FullName -notlike '*\export_templates\4.7.2.stable') { throw "Unknown link; defer: $($link.FullName)" }
            $plan.links += @{path=$link.FullName; target=$link.Target; action='unlink only; installed target protected'}
        }
        $plan.targets += $target
        foreach ($file in @(Get-ChildItem -LiteralPath $target -Recurse -Force -File | Where-Object { !($_.Attributes -band [IO.FileAttributes]::ReparsePoint) })) {
            $plan.files += @{path=$file.FullName; bytes=$file.Length}
            $plan.bytes += $file.Length
        }
    }
}
# Exact paths, evidence hashes, link policy and deletion inventory are durable
# before deletion begins. This manifest and root reports are never targets.
$plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifest
foreach ($link in $plan.links) { Remove-Item -LiteralPath $link.path -Force }
foreach ($target in $plan.targets) {
    try { Remove-Item -LiteralPath $target -Recurse -Force; $plan.deleted += $target }
    catch { $plan.failures += @{path=$target; reason=$_.Exception.Message} }
}
foreach ($evidence in $plan.evidence) {
    if ((Get-FileHash -LiteralPath $evidence.retained -Algorithm SHA256).Hash -ne $evidence.sha256) { throw 'Post-cleanup recovery hash mismatch.' }
}
$plan.status = if ($plan.failures.Count) {'incomplete'} else {'complete'}
$plan | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifest
Write-Output "$($plan.status): $($plan.files.Count) files / $($plan.bytes) bytes; $($plan.evidence.Count) evidence hashes verified; $manifest"
if ($plan.failures.Count) { exit 1 }
