param()
$ErrorActionPreference = 'Stop'
$cache = "$PSScriptRoot/.toolchain"
$manifest = Get-Content -LiteralPath "$PSScriptRoot/../native/media/dependencies.lock.json" -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Force $cache | Out-Null
function Get-PinnedMediaFile([string]$Url,[string]$Path,[string]$Sha256) {
    if (!(Test-Path -LiteralPath $Path)) { Invoke-WebRequest -Uri $Url -OutFile $Path }
    if ((Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $Sha256) { throw "Dependency hash mismatch: $Path" }
}
Get-PinnedMediaFile $manifest.fluidsynth.archive "$cache/fluidsynth-2.4.7.zip" $manifest.fluidsynth.sha256
Get-PinnedMediaFile $manifest.ffmpeg.archive "$cache/ffmpeg-8.1.zip" $manifest.ffmpeg.sha256
$bankUrl = 'https://raw.githubusercontent.com/mrbumpy409/GeneralUser-GS/' + $manifest.bank.revision + '/GeneralUser-GS.sf2'
Get-PinnedMediaFile $bankUrl "$cache/GeneralUser-GS-2.0.3.sf2" $manifest.bank.sha256
Expand-Archive -LiteralPath "$cache/fluidsynth-2.4.7.zip" -DestinationPath "$cache/fluidsynth-2.4.7" -Force
Expand-Archive -LiteralPath "$cache/ffmpeg-8.1.zip" -DestinationPath "$cache/ffmpeg-8.1" -Force
Write-Output 'Pinned media SDKs and default SF2 are ready for build_media.ps1.'
