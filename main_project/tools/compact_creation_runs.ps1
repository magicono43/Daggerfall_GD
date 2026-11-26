param([Parameter(Mandatory)][string[]]$Roots)
$ErrorActionPreference = 'Stop'
if (@(Get-Process -Name 'Godot*','Startup*','ffmpeg*' -ErrorAction SilentlyContinue).Count) { throw 'An engine/export/media child is active; defer compaction.' }
$runs = [IO.Path]::GetFullPath("$PSScriptRoot/../tests/.runs")
$audit = Join-Path $runs 'imp015-increment3-audit'
New-Item -ItemType Directory -Force $audit | Out-Null
$journal = Join-Path $audit ('cleanup-' + [Guid]::NewGuid().ToString('N') + '.json')
$manifest = [ordered]@{schema='creation-cleanup-v1';roots=@();removed_files=0;removed_bytes=0;status='planned'}
function Files([string]$Path) {
    $stack = [Collections.Generic.Stack[string]]::new(); $stack.Push($Path)
    while ($stack.Count) {
        foreach ($entry in Get-ChildItem -LiteralPath $stack.Pop() -Force) {
            if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Reparse target deferred: $($entry.FullName)" }
            if ($entry.PSIsContainer) { $stack.Push($entry.FullName) } else { $entry }
        }
    }
}
foreach ($root in $Roots) {
    $absolute = [IO.Path]::GetFullPath($root)
    if (![IO.Path]::GetDirectoryName($absolute).Equals($runs,[StringComparison]::OrdinalIgnoreCase)) { throw 'An exact direct run child is required.' }
    if (Test-Path -LiteralPath (Join-Path $absolute 'ACTIVE-HUMAN-REVIEW.json')) { throw 'Active human review is protected.' }
    $report = Get-Content -LiteralPath (Join-Path $absolute 'report.json') -Raw | ConvertFrom-Json -AsHashtable
    if ($report.suite -notin @('creation','creation-draft') -or !(@($report.build.working_tree) -match 'starting_rolls|creation_biography')) { throw 'Not an owned increment-3 creation run.' }
    $project = Join-Path $absolute 'project'
    if (!(Test-Path -LiteralPath $project)) { continue }
    $files = @(Files $project)
    $source = @($files | Where-Object { [IO.Path]::GetRelativePath($project,$_.FullName) -notmatch '(^|[\\/])(\.godot|\.runs)([\\/]|$)' -and $_.Extension -in @('.gd','.json','.csv','.tscn','.tres','.godot','.gdextension','.cfg','.uid') })
    if (!$source.Count) { throw 'No executed source found; refuse cleanup with an empty source archive.' }
    $zipPath = Join-Path $absolute 'executed-source.zip'
    $zip = [IO.Compression.ZipFile]::Open($zipPath,[IO.Compression.ZipArchiveMode]::Create)
    $sourceHashes = [ordered]@{}
    try {
        foreach ($file in $source) {
            $relative = [IO.Path]::GetRelativePath($project,$file.FullName).Replace('\','/')
            [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$file.FullName,$relative,[IO.Compression.CompressionLevel]::Optimal)
            $sourceHashes[$relative]=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
        }
    } finally { $zip.Dispose() }
    $verify = [IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        foreach ($entry in $verify.Entries) {
            $stream=$entry.Open(); $hash=[Security.Cryptography.SHA256]::Create()
            try { $actual=[Convert]::ToHexString($hash.ComputeHash($stream)) } finally { $stream.Dispose(); $hash.Dispose() }
            if ($actual -cne $sourceHashes[$entry.FullName]) { throw 'Executed-source archive recovery mismatch.' }
        }
        if ($verify.Entries.Count -ne $sourceHashes.Count) { throw 'Executed-source archive count mismatch.' }
    } finally { $verify.Dispose() }
    $preserved = @()
    foreach ($file in $files | Where-Object { $_.FullName -match '[\\/]tests[\\/]\.runs[\\/]scenario-' -and $_.Extension -in @('.json','.log','.png','.bin','.ini','.txt','.csv','.zip') }) {
        $relative = [IO.Path]::GetRelativePath($project,$file.FullName)
        $destination = Join-Path (Join-Path $absolute 'evidence') $relative
        New-Item -ItemType Directory -Force ([IO.Path]::GetDirectoryName($destination)) | Out-Null
        Copy-Item -LiteralPath $file.FullName -Destination $destination
        $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
        if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -cne $hash) { throw 'Evidence preservation hash mismatch.' }
        $preserved += @{path=$relative;sha256=$hash;bytes=$file.Length}
    }
    $item = @{root=$absolute;payload=$project;files=$files.Count;bytes=($files | Measure-Object Length -Sum).Sum;source_archive=@{file=$zipPath;sha256=(Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash;entries=$sourceHashes.Count};preserved=$preserved;deleted=$false;cache_bytes=0;cache_files=0}
    $manifest.roots += $item
    $manifest | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $journal
    foreach ($target in @($project,(Join-Path $absolute 'engine-roaming'),(Join-Path $absolute 'engine-local'))) {
        if (!(Test-Path -LiteralPath $target)) { continue }
        $checked = [IO.Path]::GetFullPath($target)
        if (!$checked.StartsWith($absolute+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Resolved deletion target left the owned run.' }
        $payload = @(Files $checked)
        if ($checked -ne $project) { $item.cache_bytes += ($payload | Measure-Object Length -Sum).Sum; $item.cache_files += $payload.Count }
        Remove-Item -LiteralPath $checked -Recurse -Force
    }
    $item.deleted = !(Test-Path -LiteralPath $project)
    $manifest.removed_files += $item.files+$item.cache_files
    $manifest.removed_bytes += $item.bytes+$item.cache_bytes
    Write-Output "Compacted $([IO.Path]::GetFileName($absolute))"
}
$manifest.status='compacted'
$manifest | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $journal
Write-Output $journal
