$ErrorActionPreference='Stop'
. "$PSScriptRoot/../../tools/run_artifacts.ps1"
$base=[IO.Path]::GetFullPath("$PSScriptRoot/../.runs")
$output=Join-Path $base ('artifact-maintenance-tests-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $output | Out-Null
$nonce=[guid]::NewGuid().ToString('N'); $roots=@(); $checks=@()
function Check([string]$Name,$Expected,$Actual) {
    $script:checks+=@{name=$Name;expected=$Expected;actual=$Actual;ok=($Expected -ceq $Actual)}
    if($Expected -cne $Actual){throw "Assertion failed: $Name; expected $Expected, got $Actual"}
}
function Reject([string]$Name,[scriptblock]$Action) {
    $rejected=$false
    try{& $Action | Out-Null}catch{$rejected=$true}
    Check $Name $true $rejected
}
function Write-Fixture([string]$Path,[string]$Text) {
    New-Item -ItemType Directory -Force (Split-Path -Parent $Path) | Out-Null
    [IO.File]::WriteAllText($Path,$Text)
}
function Fixture {
    $root=Join-Path $base ('verification-rendered-'+[guid]::NewGuid().ToString('N'))
    $script:roots+=$root
    Write-Fixture "$root/artifact-test-tag.json" $nonce
    Write-Fixture "$root/project/project.godot" '[application]'
    Write-Fixture "$root/CLOSED-HUMAN-REVIEW.json" '{"owner":"disposable maintenance test"}'
    @{status='passed';mode='rendered';suite='creation-draft';root=$root;runtime_project="$root/project";scenarios=@(@{root="$root/project/tests/.runs/scenario-1"})} | ConvertTo-Json -Depth 6 | Set-Content "$root/report.json"
    Write-Fixture "$root/project/tests/.runs/scenario-1/result.json" '{"ok":true,"unique":"child evidence"}'
    return $root
}
$ok=$false
try {
    Reject 'workspace sibling rejected' {Assert-RunArtifactPath "$base/../authoritative.json"}
    Reject 'run storage root itself rejected' {Assert-RunArtifactPath $base}
    $active=Fixture
    Write-Fixture "$active/ACTIVE-HUMAN-REVIEW.json" '{}'
    Reject 'active review rejected before archiving' {Invoke-ReviewCompaction -Root $active}
    Check 'active project remains' $true (Test-Path "$active/project/project.godot")
    Check 'active source archive not created' $false (Test-Path "$active/review-source.zip")
    $failed=Fixture
    $report=Get-Content "$failed/report.json" -Raw | ConvertFrom-Json; $report.status='failed'; $report | ConvertTo-Json -Depth 6 | Set-Content "$failed/report.json"
    Reject 'failed preparation rejected' {Invoke-ReviewCompaction -Root $failed}
    Check 'failed project remains' $true (Test-Path "$failed/project/project.godot")
    $wrong=Fixture
    $report=Get-Content "$wrong/report.json" -Raw | ConvertFrom-Json; $report.runtime_project="$base/elsewhere"; $report | ConvertTo-Json -Depth 6 | Set-Content "$wrong/report.json"
    Reject 'foreign project binding rejected' {Invoke-ReviewCompaction -Root $wrong}
    # A UI checkpoint can start from a clean committed tree. Its receipt still
    # has to bind the explicit authorization, revision and terminal report.
    $checkpoint=Fixture
    $report=Get-Content "$checkpoint/report.json" -Raw | ConvertFrom-Json
    $report|Add-Member build @{source_revision=('1'*40);working_tree=@()}
    $report|ConvertTo-Json -Depth 6|Set-Content "$checkpoint/report.json"
    $closed=@{schema='closed-verification-v1';owner='IMP-015 UI checkpoint';authorization='User authorized combined creator regressions and temporary-build cleanup, 2026-11-27';source_revision=('1'*40);root=$checkpoint;report_sha256=(Get-FileHash "$checkpoint/report.json").Hash}
    foreach($field in @('owner','source_revision','report_sha256')){
        $badReceipt=$closed.Clone(); $badReceipt[$field]='invalid'
        $badReceipt|ConvertTo-Json|Set-Content "$checkpoint/CLOSED-VERIFICATION.json"
        Reject "checkpoint wrong $field rejected" {Invoke-ReviewCompaction -Root $checkpoint -ClosedVerification}
        Check "checkpoint wrong $field creates no archive" $false (Test-Path "$checkpoint/review-source.zip")
    }
    $closed|ConvertTo-Json|Set-Content "$checkpoint/CLOSED-VERIFICATION.json"
    $checkpointResult=Invoke-ReviewCompaction -Root $checkpoint -ClosedVerification
    Check 'clean committed checkpoint compacts' 'compacted' $checkpointResult.status
    Check 'clean checkpoint copied project removed' $false (Test-Path "$checkpoint/project/project.godot")
    Check 'clean checkpoint child evidence preserved' $true (Test-Path "$checkpoint/project/tests/.runs/scenario-1/result.json")
    $root=Fixture
    Write-Fixture "$root/project/scripts/owner.gd" 'extends RefCounted'
    Write-Fixture "$root/project/notes.custom" 'unique hand-authored input'
    Write-Fixture "$root/project/content/art.png" 'unique image bytes'
    Write-Fixture "$root/project/native/media/bin/media_windows.dll" 'older custom binary'
    Write-Fixture "$root/project/.godot/cache.bin" 'reproducible import'
    Write-Fixture "$root/engine-local/Godot/editor_doc_cache-4.7.res" 'reproducible editor cache'
    Write-Fixture "$root/project/tests/.runs/scenario-1/human-engine-roaming/notes.custom" 'unique review notes'
    Write-Fixture "$root/project/tests/.runs/scenario-1/shader_cache/cache.bin" 'reproducible shader'
    Write-Fixture "$root/project/tests/.runs/scenario-1/unique.raw" 'unique child input'
    New-Item -ItemType Directory -Force "$root/project/native/storage/bin" | Out-Null
    Copy-Item -LiteralPath "$script:RunArtifactProject/native/storage/bin/storage_windows.dll" -Destination "$root/project/native/storage/bin/storage_windows.dll"
    $evidence="$root/project/tests/.runs/scenario-1/result.json"
    $evidenceHash=(Get-FileHash $evidence).Hash
    $child=Start-Process -FilePath (Join-Path $PSHOME 'pwsh.exe') -ArgumentList @('-NoProfile','-Command','Start-Sleep -Seconds 2; exit 0') -WindowStyle Hidden -PassThru
    Reject 'live owned child rejected' {Invoke-ReviewCompaction -Root $root -OwnedChild $child}
    [void]$child.WaitForExit(15000); $child.WaitForExit()
    Check 'owned test child returned' 0 $child.ExitCode
    $result=Invoke-ReviewCompaction -Root $root -OwnedChild $child
    Check 'compaction completed' 'compacted' $result.status
    Check 'runnable copy removed' $false (Test-Path "$root/project/project.godot")
    Check 'original child result path preserved' $true (Test-Path $evidence)
    Check 'child result bytes preserved' $evidenceHash (Get-FileHash $evidence).Hash
    Check 'unique child input remains' 'unique child input' ([IO.File]::ReadAllText("$root/project/tests/.runs/scenario-1/unique.raw"))
    Check 'unique isolated review notes remain' 'unique review notes' ([IO.File]::ReadAllText("$root/project/tests/.runs/scenario-1/human-engine-roaming/notes.custom"))
    Check 'isolated editor cache removed' $false (Test-Path "$root/engine-local/Godot/editor_doc_cache-4.7.res")
    Check 'child shader cache removed' $false (Test-Path "$root/project/tests/.runs/scenario-1/shader_cache/cache.bin")
    $receipt=Get-Content $result.receipt -Raw | ConvertFrom-Json
    Test-RunSourceArchive $receipt.archive $receipt.source
    $zip=[IO.Compression.ZipFile]::OpenRead($receipt.archive)
    try {
        Check 'unknown source extension archived' $true ($null -ne $zip.GetEntry('notes.custom'))
        Check 'unique image archived' $true ($null -ne $zip.GetEntry('content/art.png'))
        Check 'older custom native bytes archived' $true ($null -ne $zip.GetEntry('native/media/bin/media_windows.dll'))
        Check 'verified current native copy omitted' $true ($null -eq $zip.GetEntry('native/storage/bin/storage_windows.dll'))
        Check 'regenerated import omitted' $true ($null -eq $zip.GetEntry('.godot/cache.bin'))
        Check 'child evidence not duplicated into archive' $true ($null -eq $zip.GetEntry('tests/.runs/scenario-1/result.json'))
    } finally {$zip.Dispose()}
    Check 'repeat cleanup is idempotent' 'already_compacted' (Invoke-ReviewCompaction -Root $root -OwnedChild $child).status
    Reject 'empty archive manifest rejected' {Test-RunSourceArchive $receipt.archive @()}
    $bad=@($receipt.source | ForEach-Object {@{path=$_.path;sha256=('0'*64)}})
    Reject 'archive recovery mismatch rejected' {Test-RunSourceArchive $receipt.archive $bad}
    $json=Join-Path $output 'large.json'
    Write-Fixture $json ('{"data":"'+('a'*2MB)+'"}')
    $jsonHash=(Get-FileHash $json).Hash
    $compressed=Compress-RunEvidence $json
    Check 'NTFS compression supported' $true $compressed.Compressed
    Check 'compression reduces actual storage' $true ($compressed.After -lt $compressed.Before)
    Check 'compression preserves SHA' $jsonHash (Get-FileHash $json).Hash
    Check 'ordinary JSON reader still works' (2MB) ((Get-Content $json -Raw | ConvertFrom-Json).data.Length)
    Check 'repeat compression preserves bytes' $jsonHash (Compress-RunEvidence $json).Sha256
    Reject 'active JSON compression rejected' {Compress-RunEvidence "$active/report.json"}
    $canonical=Join-Path $output 'source.zip'; $copy=Join-Path $output 'copy.zip'
    Copy-Item -LiteralPath $receipt.archive -Destination $canonical
    Copy-Item -LiteralPath $canonical -Destination $copy
    $archiveHash=(Get-FileHash $copy).Hash
    $link=Merge-RunArchiveCopy -Path $copy -Canonical $canonical -Receipt "$output/link.json"
    Check 'archive sharing completed' 'shared-and-byte-verified' $link.status
    Check 'archive path remains readable' $archiveHash (Get-FileHash $copy).Hash
    Check 'archive paths share file identity' ([RunArtifactNative]::Info($canonical).Identity) ([RunArtifactNative]::Info($copy).Identity)
    Check 'archive shares multiple links' $true ([RunArtifactNative]::Info($copy).Links -ge 2)
    Check 'archive sharing repeat is idempotent' 'already_shared' (Merge-RunArchiveCopy -Path $copy -Canonical $canonical -Receipt "$output/link-repeat.json").status
    Write-Fixture "$output/different.zip" 'different'
    Reject 'different archive bytes cannot be consolidated' {Merge-RunArchiveCopy -Path "$output/different.zip" -Canonical $canonical -Receipt "$output/link-different.json"}
    Check 'different archive remains unchanged' 'different' ([IO.File]::ReadAllText("$output/different.zip"))
    # Qualify the actual command's scoped discovery/grouping and plan/apply
    # behavior, not only its low-level operations. Never enumerate real evidence.
    Write-Fixture "$root/large-evidence.json" ('{"data":"'+('b'*2MB)+'"}')
    Copy-Item -LiteralPath $receipt.archive -Destination "$root/extra-source.zip"
    $beforeBatch=[RunArtifactNative]::Info("$root/large-evidence.json").Allocated
    & "$PSScriptRoot/../../tools/maintain_run_artifacts.ps1" -EvidenceRoots @($root) -CompressEvidence -ShareArchives -AuditDirectory "$output/batch-plan"
    Check 'plan leaves evidence allocation unchanged' $beforeBatch ([RunArtifactNative]::Info("$root/large-evidence.json").Allocated)
    Check 'plan leaves archive files distinct' $true ([RunArtifactNative]::Info($receipt.archive).Identity -cne [RunArtifactNative]::Info("$root/extra-source.zip").Identity)
    & "$PSScriptRoot/../../tools/maintain_run_artifacts.ps1" -EvidenceRoots @($root) -CompressEvidence -ShareArchives -Apply -AuditDirectory "$output/batch-apply"
    Check 'batch command compresses scoped evidence' $true ([RunArtifactNative]::Info("$root/large-evidence.json").Allocated -lt $beforeBatch)
    Check 'batch command shares scoped identical ZIPs' ([RunArtifactNative]::Info($receipt.archive).Identity) ([RunArtifactNative]::Info("$root/extra-source.zip").Identity)
    Check 'batch command preserves child result' $evidenceHash (Get-FileHash $evidence).Hash
    New-Item -ItemType Directory -Force "$output/protected" | Out-Null
    Write-Fixture "$output/protected/input.txt" 'protected'
    New-Item -ItemType Junction -Path "$output/reparse" -Target "$output/protected" | Out-Null
    Reject 'reparse traversal rejected' {Assert-RunArtifactPath "$output/reparse/input.txt"}
    Remove-Item -LiteralPath "$output/reparse" -Force # unlink only, never recurse
    Check 'junction target untouched' 'protected' ([IO.File]::ReadAllText("$output/protected/input.txt"))
    $ok=$true
} finally {
    @{schema='run-artifact-tests-v1';ok=$ok;count=$checks.Count;checks=$checks;fixtures=$roots;utc=[DateTime]::UtcNow.ToString('o')} | ConvertTo-Json -Depth 8 | Set-Content "$output/result.json"
    if($ok) {
        foreach($root in $roots) {
            $checked=Assert-RunArtifactPath $root
            if([IO.File]::ReadAllText("$checked/artifact-test-tag.json") -cne $nonce){throw 'Test cleanup ownership mismatch'}
            [void]@(Get-RunArtifactFiles $checked) # prove no reparse subtree
            Remove-Item -LiteralPath $checked -Recurse -Force
        }
        # Fixtures are reconstructible. Keep only compact assertions/receipts.
        foreach($entry in Get-ChildItem -LiteralPath $output -Force) {
            if($entry.Name -in @('result.json','link.json')){continue}
            $checked=Assert-RunArtifactPath $entry.FullName
            if($entry.PSIsContainer){[void]@(Get-RunArtifactFiles $checked);Remove-Item -LiteralPath $checked -Recurse -Force}else{Remove-Item -LiteralPath $checked -Force}
        }
    }
}
Write-Output "Artifact maintenance tests PASS: $($checks.Count); $output/result.json"
