# Disposable Windows filesystem vectors, shared by editor and export runners.
function New-ModFixture([string]$Sandbox) {
    $root = "$Sandbox/user/Mods"
    $outside = "$Sandbox/link-target"
    New-Item -ItemType Directory -Force "$root/link-package",$outside,"$Sandbox/locked-mods" | Out-Null
    '{"manifest_version":1,"id":"linked-package","name":"Linked package","version":"1.0.0"}' | Set-Content "$root/link-package/mod.json" -NoNewline
    '{"manifest_version":1,"id":"outside","name":"Outside","version":"1.0.0"}' | Set-Content "$outside/mod.json" -NoNewline
    New-Item -ItemType Junction -Path "$root/group-link" -Target $outside | Out-Null
    New-Item -ItemType Junction -Path "$root/link-package/escape" -Target $outside | Out-Null
    New-Item -ItemType Directory -Force "$root/hardlink-package" | Out-Null
    '{"manifest_version":1,"id":"hardlinked","name":"Hard linked package","version":"1.0.0"}' | Set-Content "$root/hardlink-package/mod.json" -NoNewline
    New-Item -ItemType HardLink -Path "$root/hardlink-package/linked.json" -Target "$outside/mod.json" | Out-Null
    [IO.File]::WriteAllBytes("$Sandbox/locked-mods/locked.zip", [byte[]]@(80,75,5,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
    return [IO.File]::Open("$Sandbox/locked-mods/locked.zip", [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
}
