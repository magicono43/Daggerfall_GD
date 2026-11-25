param([Parameter(Mandatory)][string[]]$Roots)
$ErrorActionPreference = 'Stop'
if (@(Get-Process -Name 'Godot*' -ErrorAction SilentlyContinue).Count -gt 0) { throw 'An engine is active; defer compaction.' }
$runs = [IO.Path]::GetFullPath("$PSScriptRoot/../tests/.runs")
$journal = Join-Path $runs ('imp012-cleanup-' + [Guid]::NewGuid().ToString('N') + '.json')
$manifest = [ordered]@{schema='ground-cleanup-v1';roots=@();removed_files=0;removed_bytes=0;preserved=@();status='planned'}
foreach ($root in $Roots) {
    $absolute = [IO.Path]::GetFullPath($root)
    if (![IO.Path]::GetDirectoryName($absolute).Equals($runs,[StringComparison]::OrdinalIgnoreCase)) { throw 'Cleanup root must be an exact direct run child.' }
    if (Test-Path -LiteralPath (Join-Path $absolute 'ACTIVE-HUMAN-REVIEW.json')) { throw 'Protected human review root.' }
    $report = Get-Content -LiteralPath (Join-Path $absolute 'report.json') -Raw | ConvertFrom-Json
    if ($report.suite -notin @('ground-movement','action-input') -or !(@($report.build.working_tree) -match 'ground_coordinator')) { throw 'Not an owned ground implementation run.' }
    $project = Join-Path $absolute 'project'
    if (!(Test-Path -LiteralPath $project)) { continue }
    $nodes = [Collections.Generic.Stack[string]]::new()
    $nodes.Push($project)
    $files = @()
    while ($nodes.Count -gt 0) {
        $directory = $nodes.Pop()
        foreach ($entry in Get-ChildItem -LiteralPath $directory -Force) {
            if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Reparse point in cleanup payload; defer.' }
            if ($entry.PSIsContainer) { $nodes.Push($entry.FullName) } else { $files += $entry }
        }
    }
    if (![IO.Path]::GetFullPath($project).StartsWith($runs+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Payload outside runs.' }
    $preserve = @($files | Where-Object { $_.FullName -like '*\tests\.runs\scenario-*' -and $_.Extension -in @('.json','.log','.png','.bin','.ini','.txt') })
    $copies = @()
    foreach ($file in $preserve) {
        $relative = [IO.Path]::GetRelativePath($project,$file.FullName)
        $destination = Join-Path (Join-Path $absolute 'evidence') $relative
        New-Item -ItemType Directory -Force ([IO.Path]::GetDirectoryName($destination)) | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $destination
        $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
        if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -cne $hash) { throw 'Preservation hash mismatch.' }
        $copies += @{path=$relative;sha256=$hash;bytes=$file.Length}
    }
    $item = @{root=$absolute;payload=$project;files=$files.Count;bytes=($files | Measure-Object Length -Sum).Sum;preserved=$copies;deleted=$false}
    $manifest.roots += $item
    $manifest | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $journal
    Remove-Item -LiteralPath $project -Recurse -Force
    $item.deleted = !(Test-Path -LiteralPath $project)
    if (!$item.deleted) { throw 'Payload deletion incomplete.' }
    $manifest.removed_files += $item.files
    $manifest.removed_bytes += $item.bytes
}
$manifest.status = 'compacted'
$manifest | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $journal
Write-Output $journal
