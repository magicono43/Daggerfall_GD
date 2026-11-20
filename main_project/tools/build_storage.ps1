param([string]$Zig = "$PSScriptRoot/.toolchain/zig-windows-x86_64-0.13.0/zig.exe")
$ErrorActionPreference = 'Stop'
$source = [IO.Path]::GetFullPath("$PSScriptRoot/../native/storage")
if (!(Test-Path $Zig)) { throw 'Install pinned Zig 0.13.0 as described in native/storage/README.md' }
if ((& $Zig version) -ne '0.13.0') { throw 'This adapter build is pinned to Zig 0.13.0' }
New-Item -ItemType Directory -Force "$source/bin" | Out-Null
$priorGlobalCache = $env:ZIG_GLOBAL_CACHE_DIR
$priorLocalCache = $env:ZIG_LOCAL_CACHE_DIR
Push-Location $source
try {
	$env:ZIG_GLOBAL_CACHE_DIR = "$source/.zig-cache/global"
	$env:ZIG_LOCAL_CACHE_DIR = "$source/.zig-cache/local"
    & $Zig c++ -std=c++17 -target x86_64-windows-gnu -O2 -g -shared storage_windows.cpp -o bin/storage_windows.dll -lshell32 -lole32
    if ($LASTEXITCODE -ne 0) { throw 'Storage adapter build failed' }
} finally {
    $env:ZIG_GLOBAL_CACHE_DIR = $priorGlobalCache
    $env:ZIG_LOCAL_CACHE_DIR = $priorLocalCache
    Pop-Location
}
