param([Parameter(Mandatory)][string[]]$Names)
$ErrorActionPreference = 'Stop'
$runs = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../tests/.runs'))
if (@(Get-Process -Name '*Godot*','Startup','Startup.console' -ErrorAction SilentlyContinue).Count) { throw 'Defer cleanup while an engine exists.' }
$journal = @{ schema='dungeon-run-cleanup-v1'; roots=[Collections.Generic.List[object]]::new(); files=[Collections.Generic.List[object]]::new(); evidence=[Collections.Generic.List[object]]::new(); links=[Collections.Generic.List[object]]::new(); removed_bytes=0; failures=@() }
$journalPath = Join-Path $runs ('dungeon-cleanup-'+[Guid]::NewGuid().ToString('N')+'.json')
function Inventory([string]$Path) {
    $entry = Get-Item -LiteralPath $Path -Force
    if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        if ($entry.FullName -notmatch '[\\/]engine-roaming[\\/]Godot[\\/]export_templates[\\/]4\.7\.2\.stable$') { throw "Unknown link; defer $Path" }
        $journal.links.Add(@{ path=$entry.FullName; target=@($entry.Target) })
        return
    }
    if (!$entry.PSIsContainer) { $journal.files.Add(@{ path=$entry.FullName; bytes=$entry.Length }); return }
    foreach ($child in Get-ChildItem -LiteralPath $Path -Force) { Inventory $child.FullName }
}
foreach ($name in $Names) {
    if ($name -notmatch '^(verification-(headless|rendered)|export)-[a-f0-9]{32}$') { throw 'Exact owned run names required.' }
    $root = [IO.Path]::GetFullPath((Join-Path $runs $name))
    if (!$root.StartsWith($runs+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Root escaped workspace runs.' }
    if ((Get-Item -LiteralPath $root -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Run root is a link.' }
    if (!(Test-Path -LiteralPath "$root/report.json") -and !(Test-Path -LiteralPath "$root/result.json")) { throw 'Owned terminal report required.' }
    $journal.roots.Add($root)
    # Preserve every deterministic child report/log/capture, including reloads.
    foreach ($relative in @('project/tests/.runs','build/tests/.runs')) {
        $childRoot = Join-Path $root $relative
        if (!(Test-Path -LiteralPath $childRoot)) { continue }
        $links = @(Get-ChildItem -LiteralPath $childRoot -Recurse -Force -Attributes ReparsePoint)
        if ($links.Count) { throw 'Defer child evidence with links.' }
        foreach ($file in Get-ChildItem -LiteralPath $childRoot -Recurse -File -Force) {
            if ($file.Extension -notin @('.json','.log','.png','.wav')) { continue }
            # User/setup roots are reproduced by fixed fixtures, never human state.
            if ($file.FullName -match '[\\/](user|engine-local|engine-roaming|locked)[\\/]') { continue }
            $target = Join-Path "$root/evidence/$($relative.Split('/')[0])" ([IO.Path]::GetRelativePath($childRoot,$file.FullName))
            New-Item -ItemType Directory -Force (Split-Path $target -Parent) | Out-Null
            $hash = (Get-FileHash -LiteralPath $file.FullName).Hash
            Copy-Item -LiteralPath $file.FullName -Destination $target
            if ((Get-FileHash -LiteralPath $target).Hash -ne $hash) { throw 'Evidence copy changed.' }
            $journal.evidence.Add(@{ original=$file.FullName; retained=$target; sha256=$hash })
        }
    }
    foreach ($payload in @('project','build','engine-local','engine-roaming')) {
        $target = [IO.Path]::GetFullPath((Join-Path $root $payload))
        if (!$target.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Payload escaped exact root.' }
        if (Test-Path -LiteralPath $target) { Inventory $target }
    }
}
$journal | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $journalPath
# The plan is durable before deletion; never recurse through a link target.
foreach ($link in $journal.links) { Remove-Item -LiteralPath $link.path -Force }
foreach ($file in $journal.files) {
    Remove-Item -LiteralPath $file.path -Force
    $journal.removed_bytes += $file.bytes
}
foreach ($root in $journal.roots) {
    foreach ($payload in @('project','build','engine-local','engine-roaming')) {
        $target = [IO.Path]::GetFullPath((Join-Path $root $payload))
        if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
    }
}
foreach ($evidence in $journal.evidence) {
    if ((Get-FileHash -LiteralPath $evidence.retained).Hash -ne $evidence.sha256) { throw 'Retained evidence changed after cleanup.' }
}
$journal | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $journalPath
Write-Output $journalPath
Write-Output ('Removed '+$journal.files.Count+' files / '+$journal.removed_bytes+' bytes; retained '+$journal.evidence.Count+' child evidence files.')
