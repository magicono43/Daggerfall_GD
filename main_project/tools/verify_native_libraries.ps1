param(
    [ValidateSet('headless','rendered')][string]$Mode = 'headless',
    [string]$ClassicSource = '',
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe',
    [string]$ExportDirectory = '',
    [switch]$BankRecovery
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/assertion_values.ps1"
$project = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$run = "$project/tests/.runs/native-libraries-$Mode-$([Guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Force $run | Out-Null
$priorRoaming = $env:APPDATA
$priorLocal = $env:LOCALAPPDATA
$priorZigGlobal = $env:ZIG_GLOBAL_CACHE_DIR
$priorZigLocal = $env:ZIG_LOCAL_CACHE_DIR
$guards = @()
$report = [ordered]@{ schema = 'native-library-verification-v1'; status = 'incomplete'; mode = $Mode; fixture = 'native-libraries-v1'; root = $run; cases = @(); checks = @(); count = 0; classic_source = $ClassicSource; source_before = @{}; source_after = @{}; export_directory = $ExportDirectory }
if ($BankRecovery) { $report.fixture = 'native-banks-v1' }
function Copy-NativeLibraryResources([string]$Source,[string]$Destination) {
    New-Item -ItemType Directory -Force $Destination | Out-Null
    foreach ($entry in Get-ChildItem -LiteralPath $Source) {
        if ($entry.PSIsContainer) {
            if ($entry.Name -in @('.godot','.runs','tools','.zig-cache','zig-out')) { continue }
            Copy-NativeLibraryResources $entry.FullName "$Destination/$($entry.Name)"
        } elseif ($entry.Extension -notin @('.pdb','.lib')) { Copy-Item -LiteralPath $entry.FullName -Destination "$Destination/$($entry.Name)" }
    }
}
function Invoke-LibraryEngine([string]$Executable,[string[]]$EngineArguments,[string]$Directory,[string]$Name) {
    $quoted = @($EngineArguments | ForEach-Object { '"' + $_.Replace('"','\"') + '"' })
    $priorPath = $env:PATH
    try {
        $env:PATH = "$env:SystemRoot/System32;$env:SystemRoot"
        $child = Start-Process -FilePath $Executable -ArgumentList $quoted -WindowStyle Hidden -PassThru -RedirectStandardOutput "$Directory/$Name.stdout.log" -RedirectStandardError "$Directory/$Name.stderr.log"
    } finally { $env:PATH = $priorPath }
    if (!$child.WaitForExit(60000)) { $child.Kill($true); $child.WaitForExit(); throw "Library fixture timed out: $Name" }
    $child.WaitForExit()
    return $child.ExitCode
}
function Set-ExportBankFault([string]$PackFile,[string]$Action) {
    # Failure fixture only: the original export is never modified. Directory
    # layout follows Godot 4.7.2 core/io/file_access_pack.cpp (plain PCK v3/v4).
    $absolute = [IO.Path]::GetFullPath($PackFile)
    $boundary = [IO.Path]::GetFullPath($run)+[IO.Path]::DirectorySeparatorChar
    if (!$absolute.StartsWith($boundary,[StringComparison]::OrdinalIgnoreCase)) { throw 'PCK fault must stay in this disposable run.' }
    $stream = [IO.File]::Open($absolute,[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    $reader = [IO.BinaryReader]::new($stream,[Text.Encoding]::UTF8,$true)
    try {
        if ($reader.ReadUInt32() -ne 0x43504447) { throw 'Not a standalone Godot PCK.' }
        $version = $reader.ReadUInt32()
        if ($version -notin @(3,4)) { throw 'Unqualified PCK fixture version.' }
        [void]$reader.ReadBytes(12)
        $flags = $reader.ReadUInt32()
        if (($flags -band 1) -or ($flags -band 4)) { throw 'Encrypted/sparse PCK faults are not this fixture.' }
        $fileBase = $reader.ReadUInt64()
        $directory = $reader.ReadUInt64()
        $stream.Position = $directory
        $count = $reader.ReadUInt32()
        if ($count -gt 100000) { throw 'Unexpected PCK directory count.' }
        $entry = $null
        for ($index=0; $index -lt $count; $index++) {
            $length = $reader.ReadUInt32()
            if ($length -gt 16384) { throw 'Unexpected PCK path length.' }
            $pathAt = $stream.Position
            $name = [Text.Encoding]::UTF8.GetString($reader.ReadBytes($length)).TrimEnd([char]0)
            $offset = $reader.ReadUInt64(); $size = $reader.ReadUInt64()
            $digestAt = $stream.Position
            [void]$reader.ReadBytes(16)
            $entryFlags = $reader.ReadUInt32()
            if ($name.Replace('res://','') -ceq 'content/media/banks/generaluser-gs-2.0.3.sf2') {
                if ($entry -or $entryFlags -ne 0) { throw 'Ambiguous or non-plain bank entry.' }
                $entry = @{ path=$name; path_at=$pathAt; offset=$fileBase+$offset; size=$size; digest_at=$digestAt }
            }
        }
        if (!$entry -or $entry.size -ne 32319396 -or $entry.offset+$entry.size -gt $stream.Length) { throw 'Pinned bank PCK entry absent or out of bounds.' }
        $stream.Position = $entry.offset
        $bank = $reader.ReadBytes([int]$entry.size)
        $digest = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bank)).ToLowerInvariant()
        if ($digest -cne '9575028c7a1f589f5770fccc8cff2734566af40cd26ed836944e9a5152688cfe') { throw 'PCK bank differs from qualified input before fault.' }
        if ($Action -eq 'missing') {
            $renamed = [Text.Encoding]::UTF8.GetBytes($entry.path.Substring(0,$entry.path.Length-1)+'x')
            $stream.Position = $entry.path_at; $stream.Write($renamed,0,$renamed.Length)
        } elseif ($Action -eq 'corrupt') {
            $bank[256] = $bank[256] -bxor 1
            $stream.Position = $entry.offset; $stream.Write($bank,0,$bank.Length)
            # Preserve the pack's file checksum so only the bank's authoritative
            # application identity fails, not the PCK container itself.
            $md5 = [Security.Cryptography.MD5]::HashData($bank)
            $stream.Position = $entry.digest_at; $stream.Write($md5,0,$md5.Length)
        } else { throw 'Unknown PCK bank fault.' }
    } finally { $reader.Dispose(); $stream.Dispose() }
}
try {
    if (!$ClassicSource -or !(Test-Path -LiteralPath $ClassicSource -PathType Container)) { throw 'Explicit available -ClassicSource required for real recording publication.' }
    foreach ($name in @('ARCH3D.BSA','BLOCKS.BSA','MAPS.BSA','DAGGER.SND')) {
        $path = Join-Path $ClassicSource $name
        $report.source_before[$name] = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
        $guards += [IO.File]::Open($path,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
    }
    $engine = $Godot.Replace('_console.exe','.exe')
    $zig = "$PSScriptRoot/.toolchain/zig-windows-x86_64-0.13.0/zig.exe"
    $env:ZIG_GLOBAL_CACHE_DIR = "$run/zig-global"
    $env:ZIG_LOCAL_CACHE_DIR = "$run/zig-local"
    & $zig cc -target x86_64-windows-gnu -shared "$project/native/media/incompatible_fixture.cpp" -o "$run/incompatible.dll"
    if ($LASTEXITCODE -ne 0) { throw 'Incompatible ABI fixture build failed.' }
    $faults = @(
        @{ id='missing-midi'; file='libfluidsynth-3.dll'; action='missing'; stack='midi'; midi=$false; video=$true; reason='missing/unreadable' },
        @{ id='corrupt-midi'; file='libfluidsynth-3.dll'; action='corrupt'; stack='midi'; midi=$false; video=$true; reason='integrity/identity' },
        @{ id='missing-video'; file='avcodec-62.dll'; action='missing'; stack='video'; midi=$true; video=$false; reason='missing/unreadable' },
        @{ id='corrupt-video'; file='avcodec-62.dll'; action='corrupt'; stack='video'; midi=$true; video=$false; reason='integrity/identity' },
        @{ id='unsupported-abi'; file='avcodec-62.dll'; action='abi'; stack='video'; midi=$true; video=$false; reason='Unsupported runtime ABI' },
        @{ id='invalid-runtime-manifest'; file='media-runtime.sha256'; action='manifest'; stack='midi'; midi=$false; video=$false; reason='manifest malformed' }
    )
    if ($BankRecovery) {
        $faults = @(
            @{ id='missing-default-bank'; file='generaluser-gs-2.0.3.sf2'; action='missing'; bank=$true; stack='midi'; midi=$true; video=$true; reason='is missing'; failure_kind='default_bank_missing' },
            @{ id='corrupt-default-bank'; file='generaluser-gs-2.0.3.sf2'; action='corrupt'; bank=$true; stack='midi'; midi=$true; video=$true; reason='identity differs'; failure_kind='default_bank_invalid' }
        )
    }
    foreach ($fault in $faults) {
        $case = "$run/$($fault.id)"
        New-Item -ItemType Directory -Force $case | Out-Null
        $env:APPDATA = "$case/roaming"
        $env:LOCALAPPDATA = "$case/local"
        New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
        if ($ExportDirectory) {
            $runtime = "$case/export"
            Copy-NativeLibraryResources ([IO.Path]::GetFullPath($ExportDirectory)) $runtime
            $executable = "$runtime/Startup.exe"
            $libraryRoot = $runtime
            if (!(Test-Path -LiteralPath "$libraryRoot/media_windows.dll")) {
                $adapter = Get-ChildItem -LiteralPath $runtime -Filter media_windows.dll -Recurse | Select-Object -First 1
                if (!$adapter) { throw 'Exported native adapter missing.' }
                $libraryRoot = $adapter.DirectoryName
            }
        } else {
            $runtime = "$case/project"
            Copy-NativeLibraryResources $project $runtime
            $executable = $engine
            $libraryRoot = "$runtime/native/media/bin"
        }
        $library = "$libraryRoot/$($fault.file)"
        if ($BankRecovery) { $library = if ($ExportDirectory) { "$runtime/Startup.pck" } else { "$runtime/content/media/banks/$($fault.file)" } }
        if ($BankRecovery -and $ExportDirectory) { Set-ExportBankFault $library $fault.action }
        else { switch ($fault.action) {
            'missing' { Move-Item -LiteralPath $library -Destination "$library.disabled" }
            'corrupt' { $bytes = [IO.File]::ReadAllBytes($library); $bytes[256] = $bytes[256] -bxor 1; [IO.File]::WriteAllBytes($library,$bytes) }
            'abi' {
                Copy-Item -LiteralPath "$run/incompatible.dll" -Destination $library -Force
                $identity = (Get-FileHash -LiteralPath $library -Algorithm SHA256).Hash.ToLowerInvariant()
                $manifestPath = "$libraryRoot/media-runtime.sha256"
                $text = [IO.File]::ReadAllText($manifestPath)
                $text = [regex]::Replace($text,'[0-9a-f]{64}  avcodec-62\.dll',$identity+'  avcodec-62.dll')
                [IO.File]::WriteAllText($manifestPath,$text)
            }
            'manifest' { [IO.File]::WriteAllText($library,'invalid incomplete manifest') }
        } }
        if (!$ExportDirectory) {
            $importExit = Invoke-LibraryEngine $engine @('--headless','--path',$runtime,'--import','--quit-after','60') $case 'import'
            if ($importExit -ne 0 -or !(Test-ScriptDiagnostics @((Get-Item "$case/import.*.log").FullName) 'native-libraries' $null)) { throw 'Native failure import emitted an unrelated diagnostic.' }
        }
        $sandbox = "$runtime/tests/.runs/library-case"
        New-Item -ItemType Directory -Force $sandbox | Out-Null
        @{ sandbox=$sandbox.Replace('\','/'); mode='native-library'; fixture=$report.fixture; inputs=@{}; classic_source=$ClassicSource.Replace('\','/'); native_fault=$fault } | ConvertTo-Json -Depth 5 | Set-Content "$case/fixture.json"
        $arguments = @('--max-fps','60','--quit-after','900','--',"--startup-fixture=$case/fixture.json")
        if (!$ExportDirectory) { $arguments = @('--path',$runtime)+$arguments }
        if ($Mode -eq 'headless') { $arguments = @('--headless')+$arguments }
        $exit = Invoke-LibraryEngine $executable $arguments $case 'console'
        if (!(Test-Path -LiteralPath "$sandbox/result.json")) { throw 'Native library child did not produce a terminal report.' }
        $result = Get-Content -LiteralPath "$sandbox/result.json" -Raw | ConvertFrom-Json
        $expectedIds = @('actual independent capabilities','attributable dependency failure','recording-only real menu admission','recording production request independent','recording actual game audio active','native request classified unavailable','recording cleanup independent','no native workers leaked') | ForEach-Object { $fault.id+'/'+$_ }
        if ($result.fixture -cne $report.fixture -or $result.count -ne 8 -or $result.checks.Count -ne 8 -or @(Compare-Object $expectedIds @($result.checks.scenario) -CaseSensitive).Count -ne 0) { throw 'Native library terminal inventory incomplete.' }
        if (!(Test-ScriptDiagnostics @((Get-Item "$case/console.*.log").FullName) 'native-libraries' $result)) { throw 'Native library child emitted an unrelated diagnostic.' }
        if ($exit -ne 0 -or !$result.ok -or @($result.checks | Where-Object { !(Test-AssertionValue $_.expected $_.actual) }).Count -ne 0) { $report.status='failed'; throw "Native library assertion failed: $($fault.id)" }
        if (!$result.native_cleanup.ok -or $result.engine.major -ne 4 -or $result.engine.minor -ne 7 -or $result.engine.patch -ne 2) { throw 'Native library cleanup or target engine unavailable.' }
        if ($Mode -eq 'rendered' -and (!$result.display -or $result.display -eq 'headless')) { throw 'Rendered native dependency check has no rendered display.' }
        $report.cases += @{ id=$fault.id; process_exit=$exit; report="$sandbox/result.json"; capabilities=$result.capabilities; engine=$result.engine; display=$result.display }
        $report.cases[-1].fault = $fault
        $report.cases[-1].runtime_path = 'Windows system directories only'
        $report.cases[-1].adapter_sha256 = (Get-FileHash -LiteralPath "$libraryRoot/media_windows.dll" -Algorithm SHA256).Hash
        $report.cases[-1].fault_file_sha256 = if (Test-Path -LiteralPath $library) { (Get-FileHash -LiteralPath $library -Algorithm SHA256).Hash } else { 'missing' }
        $report.checks += $result.checks
    }
    $report.count = $report.checks.Count
    if (!(Test-NativeFaultInventory ([pscustomobject]$report) $(if ($BankRecovery) { 'banks' } else { 'libraries' }))) { throw 'Native fault inventory incomplete.' }
    $inventory = Get-Content -LiteralPath "$project/tests/native_fault_inventory.json" -Raw | ConvertFrom-Json
    $selection = if ($BankRecovery) { $inventory.banks } else { $inventory.libraries }
    if ($inventory.schema -cne 'native-media-fault-inventory-v1' -or $selection.fixture -cne $report.fixture -or
        @($report.checks.scenario | Select-Object -Unique).Count -ne $report.count -or
        @(Compare-Object @($selection.ids) @($report.checks.scenario) -CaseSensitive).Count -ne 0) { throw 'Native fault inventory differs from frozen IDs.' }
    $expectedCases = if ($BankRecovery) { 2 } else { 6 }
    if ($report.count -ne $expectedCases*8 -or $report.cases.Count -ne $expectedCases) { throw 'Native library aggregate inventory incomplete.' }
    $report.status = 'passed'
} catch { $report.error = $_.Exception.Message }
finally {
    foreach ($guard in $guards) { $guard.Dispose() }
    foreach ($name in $report.source_before.Keys) {
        $report.source_after[$name] = (Get-FileHash -LiteralPath (Join-Path $ClassicSource $name) -Algorithm SHA256).Hash
        if ($report.source_after[$name] -ne $report.source_before[$name]) { $report.status='failed'; $report.error='Classic source changed.' }
    }
    $env:APPDATA=$priorRoaming
    $env:LOCALAPPDATA=$priorLocal
    $env:ZIG_GLOBAL_CACHE_DIR=$priorZigGlobal
    $env:ZIG_LOCAL_CACHE_DIR=$priorZigLocal
    $report | ConvertTo-Json -Depth 12 | Set-Content "$run/report.json"
}
Write-Output "Native library $Mode $($report.status): $run/report.json"
if ($report.status -eq 'passed') { exit 0 }
if ($report.status -eq 'failed') { exit 1 }
exit 2
