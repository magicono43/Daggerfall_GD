param([string]$Zig = "$PSScriptRoot/.toolchain/zig-windows-x86_64-0.13.0/zig.exe")
$ErrorActionPreference = 'Stop'
$source = [IO.Path]::GetFullPath("$PSScriptRoot/../native/media")
$fluid = "$PSScriptRoot/.toolchain/fluidsynth-2.4.7"
$ffmpeg = "$PSScriptRoot/.toolchain/ffmpeg-8.1/ffmpeg-n8.1.3-39-g660b5aa7db-win64-lgpl-shared-8.1"
if (!(Test-Path -LiteralPath $Zig) -or (& $Zig version) -ne '0.13.0') { throw 'Pinned Zig 0.13.0 is required.' }
$pins = @{
    "$PSScriptRoot/.toolchain/fluidsynth-2.4.7.zip" = '86f14aa05b9045585f61b76600cba24aca7b596fd12b163610f47a2805375560'
    "$PSScriptRoot/.toolchain/ffmpeg-8.1.zip" = '18e83bac40326f054226b20fde94301ba40e22d4f2d752517867f2d8d15cbe9f'
    "$PSScriptRoot/.toolchain/GeneralUser-GS-2.0.3.sf2" = '9575028c7a1f589f5770fccc8cff2734566af40cd26ed836944e9a5152688cfe'
}
foreach ($pin in $pins.GetEnumerator()) {
    if (!(Test-Path -LiteralPath $pin.Key) -or (Get-FileHash -LiteralPath $pin.Key -Algorithm SHA256).Hash.ToLowerInvariant() -ne $pin.Value) { throw "Missing/mismatched dependency: $($pin.Key)" }
}
Expand-Archive -LiteralPath "$PSScriptRoot/.toolchain/fluidsynth-2.4.7.zip" -DestinationPath $fluid -Force
Expand-Archive -LiteralPath "$PSScriptRoot/.toolchain/ffmpeg-8.1.zip" -DestinationPath "$PSScriptRoot/.toolchain/ffmpeg-8.1" -Force
New-Item -ItemType Directory -Force "$source/bin" | Out-Null
$priorGlobal = $env:ZIG_GLOBAL_CACHE_DIR
$priorLocal = $env:ZIG_LOCAL_CACHE_DIR
try {
    $env:ZIG_GLOBAL_CACHE_DIR = "$source/.zig-cache/global"
    $env:ZIG_LOCAL_CACHE_DIR = "$source/.zig-cache/local"
    & $Zig c++ -std=c++17 -target x86_64-windows-gnu -O2 -g -shared "$source/media_windows.cpp" "-I$fluid/include" "-I$ffmpeg/include" -o "$source/bin/media_windows.dll" -lbcrypt
    if ($LASTEXITCODE -ne 0) { throw 'Native media adapter build failed.' }
    foreach ($dll in @('libfluidsynth-3.dll','libglib-2.0-0.dll','libgobject-2.0-0.dll','libgthread-2.0-0.dll','libinstpatch-2.dll','libintl-8.dll','SDL3.dll','sndfile.dll')) {
        Copy-Item -LiteralPath "$fluid/bin/$dll" -Destination "$source/bin/$dll"
    }
    foreach ($dll in @('avformat-62.dll','avcodec-62.dll','avutil-60.dll','swscale-9.dll','swresample-6.dll')) {
        Copy-Item -LiteralPath "$ffmpeg/bin/$dll" -Destination "$source/bin/$dll"
    }
    $lock = Get-Content -LiteralPath "$source/dependencies.lock.json" -Raw | ConvertFrom-Json
    foreach ($dependency in $lock.runtime) {
        if ((Get-FileHash -LiteralPath "$source/bin/$($dependency.file)" -Algorithm SHA256).Hash.ToLowerInvariant() -ne $dependency.sha256) { throw "Extracted runtime differs from the pin: $($dependency.file)" }
    }
    $bankRoot = "$PSScriptRoot/../content/media/banks"
    @('# native-media-runtime-v1') + @($lock.runtime | ForEach-Object { $_.sha256 + '  ' + $_.file }) | Set-Content -LiteralPath "$source/bin/media-runtime.sha256" -Encoding ascii
    New-Item -ItemType Directory -Force $bankRoot | Out-Null
    Copy-Item -LiteralPath "$PSScriptRoot/.toolchain/GeneralUser-GS-2.0.3.sf2" -Destination "$bankRoot/generaluser-gs-2.0.3.sf2"
} finally {
    $env:ZIG_GLOBAL_CACHE_DIR = $priorGlobal
    $env:ZIG_LOCAL_CACHE_DIR = $priorLocal
}
