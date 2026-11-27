param(
    [string]$ClassicSource = 'C:/Games/Daggerfall/arena2',
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe',
    [switch]$SmokeTest
)
& "$PSScriptRoot/review_creation.ps1" -ClassicSource $ClassicSource -Godot $Godot -Presentation -RacePopup -SmokeTest:$SmokeTest
exit $LASTEXITCODE
