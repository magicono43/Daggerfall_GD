param(
    [string]$ClassicSource = 'C:/Games/Daggerfall/arena2',
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe',
    [switch]$SmokeTest
)
Write-Output 'IMP-015 increment 2: real race/career mechanics; explicitly assigned later stages; no playable entry or grants.'
& "$PSScriptRoot/review_creation.ps1" -ClassicSource $ClassicSource -Godot $Godot -RaceCareer -SmokeTest:$SmokeTest
exit $LASTEXITCODE
