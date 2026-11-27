# Shared Windows review/evidence maintenance. Dot-source; no work on import.
# Never follow a reparse point, infer inactivity from report status alone, or
# remove child evidence to remove a copied runtime. All paths stay inside .runs.
$script:RunArtifactProject = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$script:RunArtifactBase = Join-Path $script:RunArtifactProject 'tests/.runs'

function Assert-RunArtifactPath([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path)
    $base = [IO.Path]::GetFullPath($script:RunArtifactBase)
    if (!$full.StartsWith($base+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase) -or $full.Substring(2).Contains(':')) { throw "Outside run storage: $full" }
    $cursor = $full
    while ($cursor) {
        if (Test-Path -LiteralPath $cursor) {
            if ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Reparse path deferred: $cursor" }
        }
        $cursor = [IO.Path]::GetDirectoryName($cursor)
    }
    return $full
}

function Get-RunArtifactFiles([string]$Path) {
    $checked = Assert-RunArtifactPath $Path
    $stack = [Collections.Generic.Stack[string]]::new(); $stack.Push($checked)
    while ($stack.Count) {
        foreach ($entry in Get-ChildItem -LiteralPath $stack.Pop() -Force) {
            if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Reparse subtree deferred: $($entry.FullName)" }
            if ($entry.PSIsContainer) { $stack.Push($entry.FullName) } else { $entry }
        }
    }
}

function Initialize-RunArtifactNative {
    if ('RunArtifactNative' -as [type]) { return }
    Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
public static class RunArtifactNative {
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool GetFileInformationByHandleEx(IntPtr h, int kind, byte[] data, uint size);
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] static extern uint GetCompressedFileSizeW(string path, out uint high);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool DeviceIoControl(IntPtr h, uint code, ref ushort input, uint inputSize, IntPtr output, uint outputSize, out uint returned, IntPtr overlapped);
    public sealed class Storage {
        public long Allocated; public string Identity; public uint Links;
    }
    static Storage ReadInfo(FileStream stream, string path) {
        var standard = new byte[24]; var id = new byte[24];
        IntPtr handle = stream.SafeFileHandle.DangerousGetHandle();
        if (!GetFileInformationByHandleEx(handle,1,standard,24) || !GetFileInformationByHandleEx(handle,18,id,24)) throw new Win32Exception(Marshal.GetLastWin32Error());
        long size = BitConverter.ToInt64(standard,0);
        var attrs = File.GetAttributes(path);
        if ((attrs & (FileAttributes.Compressed|FileAttributes.SparseFile)) != 0) {
            uint high; uint low = GetCompressedFileSizeW(path,out high);
            if (low == UInt32.MaxValue && Marshal.GetLastWin32Error()!=0) throw new Win32Exception(Marshal.GetLastWin32Error());
            size = checked((long)(((ulong)high<<32)|low));
        }
        return new Storage {Allocated=size,Identity=Convert.ToHexString(id),Links=BitConverter.ToUInt32(standard,16)};
    }
    public static Storage Info(string path) {
        using(var stream=new FileStream(path,FileMode.Open,FileAccess.Read,FileShare.ReadWrite|FileShare.Delete)) return ReadInfo(stream,path);
    }
    static string Hash(FileStream stream) {stream.Position=0; return Convert.ToHexString(SHA256.HashData(stream));}
    public sealed class Compression {public string Sha256;public long Bytes;public long Before;public long After;public bool Compressed;}
    public static Compression Compress(string path) {
        using(var stream=new FileStream(path,FileMode.Open,FileAccess.ReadWrite,FileShare.Read)) {
            string beforeHash=Hash(stream); long bytes=stream.Length; var before=ReadInfo(stream,path);
            ushort format=1; uint returned;
            if (!DeviceIoControl(stream.SafeFileHandle.DangerousGetHandle(),0x9C040,ref format,2,IntPtr.Zero,0,out returned,IntPtr.Zero)) throw new Win32Exception(Marshal.GetLastWin32Error());
            stream.Flush(true); string afterHash=Hash(stream); var after=ReadInfo(stream,path);
            if(beforeHash!=afterHash || bytes!=stream.Length) throw new IOException("Compression changed logical bytes");
            return new Compression {Sha256=afterHash,Bytes=bytes,Before=before.Allocated,After=after.Allocated,Compressed=(File.GetAttributes(path)&FileAttributes.Compressed)!=0};
        }
    }
}
'@
}

function Compress-RunEvidence([string]$Path) {
    $checked = Assert-RunArtifactPath $Path
    Assert-RunEvidenceInactive $checked
    if ([IO.Path]::GetExtension($checked) -ine '.json') { throw 'Only JSON evidence is admitted for transparent compression.' }
    Initialize-RunArtifactNative
    return [RunArtifactNative]::Compress($checked)
}

function Assert-RunEvidenceInactive([string]$Path) {
    $checked = Assert-RunArtifactPath $Path
    $relative = [IO.Path]::GetRelativePath($script:RunArtifactBase,$checked)
    $root = Join-Path $script:RunArtifactBase ($relative.Split([IO.Path]::DirectorySeparatorChar)[0])
    if (Test-Path -LiteralPath $root -PathType Container) {
        if (@(Get-ChildItem -LiteralPath $root -File -Filter '*.json' | Where-Object {$_.Name -match 'ACTIVE|RETAIN|KEEP'}).Count -or (Test-Path -LiteralPath (Join-Path $root 'project/project.godot')) -or (Test-Path -LiteralPath (Join-Path $root 'build/Startup.exe'))) { throw 'Active/retained or unqualified full-build evidence deferred.' }
    }
}

function Merge-RunArchiveCopy {
    param([Parameter(Mandatory)][string]$Path,[Parameter(Mandatory)][string]$Canonical,[Parameter(Mandatory)][string]$Receipt)
    $target = Assert-RunArtifactPath $Path; $original = Assert-RunArtifactPath $Canonical
    $journal = Assert-RunArtifactPath $Receipt
    Assert-RunEvidenceInactive $target; Assert-RunEvidenceInactive $original
    if ([IO.Path]::GetExtension($target) -ine '.zip' -or [IO.Path]::GetExtension($original) -ine '.zip' -or $target -ceq $original -or (Test-Path -LiteralPath $journal)) { throw 'Distinct ZIPs and a fresh receipt are required.' }
    Initialize-RunArtifactNative
    $hash = (Get-FileHash -LiteralPath $original).Hash
    if ((Get-FileHash -LiteralPath $target).Hash -cne $hash) { throw 'Archive bytes differ; no consolidation allowed.' }
    $before = [RunArtifactNative]::Info($target)
    $canonicalInfo = [RunArtifactNative]::Info($original)
    if ($before.Identity -ceq $canonicalInfo.Identity) { return @{status='already_shared';path=$target;saved_bytes=0} }
    $backup = Assert-RunArtifactPath ($target+'.dedup-'+[guid]::NewGuid().ToString('N')+'.original')
    $record = [ordered]@{schema='run-archive-sharing-v1';path=$target;canonical=$original;backup=$backup;sha256=$hash;before_identity=$before.Identity;canonical_identity=$canonicalInfo.Identity;status='verified-before-link';saved_bytes=0L}
    $record | ConvertTo-Json -Compress | Set-Content -LiteralPath $journal
    # File-level rename/link/rollback only. Never delete a directory or the
    # canonical copy, and never remove the backup before path/hash/identity checks.
    $lock = [IO.File]::Open($original,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
    try {
        Move-Item -LiteralPath $target -Destination $backup
        try {
            New-Item -ItemType HardLink -Path $target -Target $original | Out-Null
            $after = [RunArtifactNative]::Info($target)
            if ($after.Identity -cne $canonicalInfo.Identity -or (Get-FileHash -LiteralPath $target).Hash -cne $hash -or (Get-FileHash -LiteralPath $backup).Hash -cne $hash) { throw 'Archive link verification failed.' }
            $checked = Assert-RunArtifactPath $backup
            Remove-Item -LiteralPath $checked -Force
            $record.status = 'shared-and-byte-verified'
            # Old archives are immutable inputs; guard against accidental in-place
            # writes now that paths share one file. Force-deleting an alias remains safe.
            (Get-Item -LiteralPath $target).IsReadOnly = $true
            $record.saved_bytes = if ($before.Links -eq 1) { $before.Allocated } else { 0L }
        } catch {
            if (Test-Path -LiteralPath $backup) {
                if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath (Assert-RunArtifactPath $target) -Force }
                Move-Item -LiteralPath $backup -Destination $target
            }
            $record.status='rolled-back'; $record.error=$_.Exception.Message
            $record | ConvertTo-Json -Compress | Set-Content -LiteralPath $journal
            throw
        }
    } finally { $lock.Dispose() }
    $record | ConvertTo-Json -Compress | Set-Content -LiteralPath $journal
    return $record
}

function Test-RunSourceArchive([string]$Archive, [array]$Entries) {
    $checked = Assert-RunArtifactPath $Archive
    if (!$Entries.Count) { throw 'Empty source archive refused.' }
    $zip = [IO.Compression.ZipFile]::OpenRead($checked)
    try {
        if ($zip.Entries.Count -ne $Entries.Count) { throw 'Source archive count mismatch.' }
        foreach ($entry in $Entries) {
            $member = $zip.GetEntry($entry.path)
            if ($null -eq $member) { throw 'Source archive entry missing.' }
            $stream = $member.Open()
            try { $sha = (Get-FileHash -InputStream $stream -Algorithm SHA256).Hash } finally { $stream.Dispose() }
            if ($sha -cne $entry.sha256) { throw 'Source archive recovery hash mismatch.' }
        }
    } finally { $zip.Dispose() }
}

function Test-RunCachePath([string]$Relative) {
    $normalized = $Relative.Replace([char]92,[char]47)
    return $normalized -match '(^|/)(\.godot|\.zig-cache|shader_cache)(/|$)' -or $normalized -match '(^|/)(engine-local|human-engine-local)/Godot/editor_doc_cache-[^/]+\.res$'
}

function Invoke-ReviewCompaction {
    param([Parameter(Mandatory)][string]$Root,[Diagnostics.Process]$OwnedChild,[switch]$ClosedVerification)
    $rootPath = Assert-RunArtifactPath $Root
    $rootPattern = if ($ClosedVerification) { '^verification-(headless|rendered)-[a-f0-9]{32}$' } else { '^verification-rendered-[a-f0-9]{32}$' }
    if ([IO.Path]::GetDirectoryName($rootPath) -cne [IO.Path]::GetFullPath($script:RunArtifactBase) -or [IO.Path]::GetFileName($rootPath) -notmatch $rootPattern) { throw 'Exact recognized verification root required.' }
    $markers = @(Get-ChildItem -LiteralPath $rootPath -File -Filter '*.json')
    $closedPattern = if ($ClosedVerification) { '^CLOSED-VERIFICATION\.json$' } else { '^(CLOSED-HUMAN-REVIEW|HUMAN-REVIEW-CLOSED)' }
    if (@($markers | Where-Object {$_.Name -match 'ACTIVE|RETAIN|KEEP|FAILED'}).Count -or !@($markers | Where-Object {$_.Name -match $closedPattern}).Count) { throw 'Active, exceptional, failed or unclosed review deferred.' }
    if ($ClosedVerification -and $null -ne $OwnedChild) { throw 'Closed verification requires the independent no-engine activity check.' }
    if ($null -ne $OwnedChild) {
        if (!$OwnedChild.HasExited -or $OwnedChild.ExitCode -ne 0) { throw 'Owned review child has not exited successfully.' }
        $activity = "Owned synchronous child $($OwnedChild.Id) exited 0; launcher admits only its own root after all review children returned."
    } else {
        if (@(Get-Process -Name '*Godot*','Startup*','ffmpeg*' -ErrorAction SilentlyContinue).Count) { throw 'Engine/decoder activity present; batch review cleanup deferred.' }
        $activity = 'No Godot/Startup/FFmpeg process; closed review marker and terminal report checked.'
    }
    $marker = Join-Path $rootPath $(if ($ClosedVerification) { 'VERIFICATION-COMPACTION.json' } else { 'REVIEW-COMPACTION.json' })
    if (Test-Path -LiteralPath $marker) {
        $prior = Get-Content -LiteralPath $marker -Raw | ConvertFrom-Json
        if ($prior.status -cne 'compacted' -or (Get-FileHash -LiteralPath $prior.archive).Hash -cne $prior.archive_sha256) { throw 'Incomplete or changed previous compaction; inspect its receipt.' }
        return @{status='already_compacted';root=$rootPath;receipt=$marker}
    }
    $report = Get-Content -LiteralPath (Join-Path $rootPath 'report.json') -Raw | ConvertFrom-Json -AsHashtable
    if ($ClosedVerification) {
        $closed = Get-Content -LiteralPath (Join-Path $rootPath 'CLOSED-VERIFICATION.json') -Raw | ConvertFrom-Json
        $incrementOwner = $closed.owner -ceq 'IMP-015 increment 4' -and (@($report.build.working_tree) -match 'creation_identity|creation_view')
        # A checkpoint may start from a clean committed tree. Its explicit receipt
        # binds authorization and revision instead of requiring old uncommitted files.
        $checkpointOwner = $closed.owner -ceq 'IMP-015 UI checkpoint' -and $closed.authorization -ceq 'User authorized combined creator regressions and temporary-build cleanup, 2026-11-27' -and $closed.source_revision -ceq $report.build.source_revision
        if ($closed.schema -cne 'closed-verification-v1' -or !($incrementOwner -or $checkpointOwner) -or $closed.root -cne $rootPath -or $closed.report_sha256 -cne (Get-FileHash -LiteralPath (Join-Path $rootPath 'report.json')).Hash -or $report.status -notin @('passed','failed','incomplete') -or $report.suite -notin @('creation','creation-draft','session','replacements','native','locale-fonts') -or $report.mode -notin @('headless','rendered')) { throw 'Explicit owned closed creation verification receipt required.' }
    } elseif ($report.status -cne 'passed' -or $report.mode -cne 'rendered' -or $report.suite -notin @('creation-draft','creation-popup-preview','calendar-clock','ground-movement')) { throw 'Known passed review preparation required.' }
    if ([IO.Path]::GetFullPath($report.root) -cne $rootPath) { throw 'Report root binding changed.' }
    $project = Assert-RunArtifactPath (Join-Path $rootPath 'project')
    if ([IO.Path]::GetFullPath($report.runtime_project) -cne $project -or !(Test-Path -LiteralPath "$project/project.godot")) { throw 'Review project binding missing.' }
    foreach ($scenario in $report.scenarios) {
        $case = Assert-RunArtifactPath $scenario.root
        if (!$case.StartsWith((Join-Path $project 'tests/.runs')+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Child evidence binding escaped review.' }
    }
    $files = @(Get-RunArtifactFiles $rootPath) # Reject *all* reparse descendants before mutation.
    $archive = Join-Path $rootPath 'review-source.zip'
    if (Test-Path -LiteralPath $archive) { throw 'Existing source archive needs recovery review.' }
    $record = [ordered]@{schema='review-compaction-v1';utc=[DateTime]::UtcNow.ToString('o');root=$rootPath;activity=$activity;status='archiving';archive=$archive;archive_sha256='';source=@();reproducible=@();retained=@();payloads=@();removed_files=0;removed_bytes=0L;compressed=@();compression_deferred=@()}
    $zip = [IO.Compression.ZipFile]::Open($archive,[IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in $files) {
            if (!$file.FullName.StartsWith($project+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { continue }
            $relative = [IO.Path]::GetRelativePath($project,$file.FullName).Replace([char]92,[char]47)
            if ($relative.StartsWith('tests/.runs/') -or (Test-RunCachePath $relative)) { continue }
            $sha = (Get-FileHash -LiteralPath $file.FullName).Hash
            # Discard copied native/bank/tool files only if exact authoritative
            # bytes still exist. Preserve older/custom binaries and every unknown
            # extension as unique archive input rather than guessing provenance.
            $authoritative = Join-Path $script:RunArtifactProject $relative
            if (($relative -match '^native/[^/]+/bin/' -or $relative -match '^content/media/banks/.*\.sf2$' -or $relative.StartsWith('tools/.toolchain/')) -and (Test-Path -LiteralPath $authoritative -PathType Leaf) -and (Get-FileHash -LiteralPath $authoritative).Hash -ceq $sha) {
                $record.reproducible += @{path=$relative;bytes=$file.Length;sha256=$sha}
                continue
            }
            [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip,$file.FullName,$relative,[IO.Compression.CompressionLevel]::Optimal) | Out-Null
            $record.source += @{path=$relative;bytes=$file.Length;sha256=$sha}
        }
    } finally { $zip.Dispose() }
    Test-RunSourceArchive $archive $record.source
    $record.archive_sha256 = (Get-FileHash -LiteralPath $archive).Hash
    $payloads = @()
    foreach ($entry in Get-ChildItem -LiteralPath $project -Force) {
        if ($entry.Name -ceq 'tests' -and $entry.PSIsContainer) {
            foreach ($child in Get-ChildItem -LiteralPath $entry.FullName -Force) { if ($child.Name -cne '.runs') { $payloads += $child.FullName } }
        } else { $payloads += $entry.FullName }
    }
    # Only recognizable regenerated cache files are removed outside the project
    # payload. Leave every log, capture, typed input and unfamiliar file in place.
    foreach ($file in $files) {
        $relative = [IO.Path]::GetRelativePath($rootPath,$file.FullName).Replace([char]92,[char]47)
        if (Test-RunCachePath $relative) {
            if (!@($payloads | Where-Object {$file.FullName -eq $_ -or $file.FullName.StartsWith($_+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)}).Count) { $payloads += $file.FullName }
        }
    }
    foreach ($path in $payloads) {
        $checked = Assert-RunArtifactPath $path
        $item = Get-Item -LiteralPath $checked
        $members = @(if ($item.PSIsContainer) { Get-RunArtifactFiles $checked } else { $item })
        $record.payloads += @{path=[IO.Path]::GetRelativePath($rootPath,$checked);files=$members.Count;bytes=[long](($members | Measure-Object Length -Sum).Sum)}
    }
    foreach ($file in $files) {
        if (@($payloads | Where-Object {$file.FullName -eq $_ -or $file.FullName.StartsWith($_+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)}).Count) { continue }
        $record.retained += @{path=[IO.Path]::GetRelativePath($rootPath,$file.FullName);sha256=(Get-FileHash -LiteralPath $file.FullName).Hash}
    }
    $record.status = 'archive-and-evidence-verified'
    $record | ConvertTo-Json -Depth 12 -Compress | Set-Content -LiteralPath $marker
    if ($null -eq $OwnedChild -and @(Get-Process -Name '*Godot*','Startup*','ffmpeg*' -ErrorAction SilentlyContinue).Count) { throw 'Engine activity began; deletion deferred.' }
    foreach ($payload in $record.payloads) {
        $checked = Assert-RunArtifactPath (Join-Path $rootPath $payload.path)
        if ((Get-Item -LiteralPath $checked).PSIsContainer) { Remove-Item -LiteralPath $checked -Recurse -Force }
        else { Remove-Item -LiteralPath $checked -Force }
        $record.removed_files += $payload.files; $record.removed_bytes += $payload.bytes
    }
    foreach ($retained in $record.retained) {
        if ((Get-FileHash -LiteralPath (Join-Path $rootPath $retained.path)).Hash -cne $retained.sha256) { throw 'Retained evidence hash mismatch.' }
    }
    foreach ($file in Get-RunArtifactFiles $rootPath) {
        if ($file.Extension -ieq '.json' -and $file.Length -ge 1MB -and $file.FullName -cne $marker) {
            try {
                $compressed = Compress-RunEvidence $file.FullName
                $record.compressed += @{path=[IO.Path]::GetRelativePath($rootPath,$file.FullName);bytes=$compressed.Bytes;before=$compressed.Before;after=$compressed.After;sha256=$compressed.Sha256}
            } catch { $record.compression_deferred += @{path=$file.FullName;reason=$_.Exception.Message} }
        }
    }
    $record.status = 'compacted'
    $record | ConvertTo-Json -Depth 12 -Compress | Set-Content -LiteralPath $marker
    Write-Host "Review compacted: $rootPath ($($record.removed_bytes) copied/cache bytes removed; original child evidence paths retained)."
    return @{status='compacted';root=$rootPath;receipt=$marker;removed_bytes=$record.removed_bytes}
}

function Complete-ReviewArtifacts([string]$Root, [Diagnostics.Process]$OwnedChild) {
    Write-Host 'Review engine closed; preserving evidence and compacting its copied build. Please let this finish before closing the terminal.'
    try { Invoke-ReviewCompaction -Root $Root -OwnedChild $OwnedChild | Out-Null }
    catch { Write-Warning "Review closed; artifact compaction deferred for $Root : $($_.Exception.Message). Preserve this build until maintenance resolves the recorded reason." }
}
