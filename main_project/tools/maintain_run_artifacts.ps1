param(
    [string[]]$ReviewRoots=@(),
    [string[]]$ProtectedRoots=@(),
    [string[]]$EvidenceRoots=@(),
    [switch]$CompressEvidence,
    [switch]$ShareArchives,
    [switch]$ClosedVerification,
    [switch]$Apply,
    [string]$AuditDirectory=''
)
$ErrorActionPreference='Stop'
. "$PSScriptRoot/run_artifacts.ps1"
if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'This maintenance tool qualifies Windows run artifacts only.' }
if (!$AuditDirectory) { $AuditDirectory=Join-Path $script:RunArtifactBase ('storage-maintenance-'+[guid]::NewGuid().ToString('N')) }
$audit=Assert-RunArtifactPath $AuditDirectory
New-Item -ItemType Directory -Force $audit | Out-Null
$journal=Join-Path $audit ('maintenance-'+[guid]::NewGuid().ToString('N')+'.json')
$record=[ordered]@{schema='run-storage-maintenance-v1';utc=[DateTime]::UtcNow.ToString('o');apply=[bool]$Apply;status='planning';protected=@();reviews=@();compressed=@();shared=@();deferred=@();compression_saved_bytes=0L;archive_saved_bytes=0L;removed_copied_bytes=0L}
$evidenceScope=@($EvidenceRoots | ForEach-Object {Assert-RunArtifactPath $(if([IO.Path]::IsPathRooted($_)){$_}else{Join-Path $script:RunArtifactBase $_})})
foreach($name in $ProtectedRoots) {
    $path=if([IO.Path]::IsPathRooted($name)){$name}else{Join-Path $script:RunArtifactBase $name}
    $record.protected+=Assert-RunArtifactPath $path
}
function Save-Maintenance { $record | ConvertTo-Json -Depth 12 -Compress | Set-Content -LiteralPath $journal }
function Protected([string]$Path) {
    foreach($prefix in @($record.protected)+@($audit)) {
        if($Path -ceq $prefix -or $Path.StartsWith($prefix+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){return $true}
    }
    return $false
}
Save-Maintenance
# A bulk sweep has no owned-child proof. Never replace that proof with a
# privileged process query or infer inactivity from a GUID/terminal report.
if(@(Get-Process -Name '*Godot*','Startup*','ffmpeg*' -ErrorAction SilentlyContinue).Count) {
    $record.status='deferred-active-engine'; Save-Maintenance
    Write-Output "Maintenance deferred: engine/decoder activity present. $journal"
    exit 0
}
foreach($name in $ReviewRoots) {
    $path=Assert-RunArtifactPath $(if([IO.Path]::IsPathRooted($name)){$name}else{Join-Path $script:RunArtifactBase $name})
    if(Protected $path){$record.deferred+=@{path=$path;reason='explicit protection'};continue}
    if(!$Apply){$record.reviews+=@{root=$path;status='candidate-requires-qualified-compaction'};continue}
    try {
        $result=Invoke-ReviewCompaction -Root $path -ClosedVerification:$ClosedVerification
        $record.reviews+=$result
        if($result.status -ceq 'compacted'){$record.removed_copied_bytes+=$result.removed_bytes}
    } catch { $record.deferred+=@{path=$path;reason=$_.Exception.Message} }
    Save-Maintenance
}

$candidates=@()
$entries=@()
if($CompressEvidence -or $ShareArchives) {
    $entries=if($evidenceScope.Count){@($evidenceScope | ForEach-Object {Get-Item -LiteralPath $_ -Force})}else{@(Get-ChildItem -LiteralPath $script:RunArtifactBase -Force)}
}
foreach($entry in $entries) {
    $full=Assert-RunArtifactPath $entry.FullName
    if(Protected $full){continue}
    if($evidenceScope.Count -and $full -notin $evidenceScope){continue}
    if(!$entry.PSIsContainer) {
        if($entry.Extension -ieq '.json' -and $entry.Name -match 'cleanup|compaction|retention|audit|inventory'){$candidates+=$entry}
        continue
    }
    # Unknown/hand-authored work areas and explicit review exceptions are not
    # admitted by a broad directory glob. Preserve them without modification.
    if($entry.Name -notmatch '^(verification-(headless|rendered)-[a-f0-9]{32}|export-[a-f0-9]{32}|imp[0-9]+.*audit|m1-.*(audit|remediation)|project-space-audit-[0-9-]+)$'){continue}
    try { Assert-RunEvidenceInactive (Join-Path $full 'qualification.json'); $candidates+=@(Get-RunArtifactFiles $full | Where-Object {$_.Extension -iin @('.json','.zip')}) }
    catch {$record.deferred+=@{path=$full;reason=$_.Exception.Message}}
}
if($CompressEvidence) {
    $count=0
    foreach($file in $candidates | Where-Object {$_.Extension -ieq '.json' -and $_.Length -ge 1MB}) {
        if($file.Attributes -band [IO.FileAttributes]::Compressed){continue}
        if(!$Apply){$record.compressed+=@{path=$file.FullName;bytes=$file.Length;status='candidate'};continue}
        try {
            $result=Compress-RunEvidence $file.FullName
            $record.compressed+=@{path=$file.FullName;bytes=$result.Bytes;sha256=$result.Sha256;before=$result.Before;after=$result.After}
            $record.compression_saved_bytes+=$result.Before-$result.After
        } catch {$record.deferred+=@{path=$file.FullName;reason=$_.Exception.Message}}
        $count+=1
        if($count%25 -eq 0){Save-Maintenance;Write-Host "Compressed/verified $count JSON files; $($record.compression_saved_bytes) allocation bytes saved."}
    }
    Save-Maintenance
}
if($ShareArchives) {
    foreach($sizeGroup in @($candidates | Where-Object {$_.Extension -ieq '.zip'} | Group-Object Length | Where-Object {$_.Count -gt 1})) {
        $hashes=@{}
        foreach($file in $sizeGroup.Group) {
            try {
                $hash=(Get-FileHash -LiteralPath $file.FullName).Hash
                if(!$hashes.ContainsKey($hash)){$hashes[$hash]=@()}
                $hashes[$hash]+=$file.FullName
            } catch {$record.deferred+=@{path=$file.FullName;reason=$_.Exception.Message}}
        }
        foreach($sha in $hashes.Keys) {
            $members=@($hashes[$sha])
            if($members.Count -le 1){continue}
            $ordered=@($members | Sort-Object); $canonical=$ordered[0]
            foreach($target in $ordered | Select-Object -Skip 1) {
                if(!$Apply){$record.shared+=@{path=$target;canonical=$canonical;status='identical-candidate'};continue}
                try {
                    $receipt=Join-Path $audit ('archive-link-'+[guid]::NewGuid().ToString('N')+'.json')
                    $result=Merge-RunArchiveCopy -Path $target -Canonical $canonical -Receipt $receipt
                    $record.shared+=@{path=$target;canonical=$canonical;status=$result.status;receipt=$receipt;saved_bytes=$result.saved_bytes}
                    $record.archive_saved_bytes+=$result.saved_bytes
                } catch {$record.deferred+=@{path=$target;reason=$_.Exception.Message}}
            }
        }
        Save-Maintenance
    }
}
$record.status=if($Apply){'completed'}else{'planned-no-payload-changes'}
Save-Maintenance
Write-Output "Run storage maintenance $($record.status): copied=$($record.removed_copied_bytes), JSON=$($record.compression_saved_bytes), shared ZIP=$($record.archive_saved_bytes) bytes saved; deferred=$($record.deferred.Count). $journal"
