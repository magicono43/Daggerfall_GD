# Qualify the combined inventory independently of the engine and source data.
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/assertion_values.ps1"
$inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/m1_composition_inventory.json" -Raw | ConvertFrom-Json
$checks = @()
foreach ($mode in @('headless','rendered','reload-headless','reload-rendered')) {
    foreach ($fixture in @('m1-composition-v1','m1-v1')) {
        foreach ($case in @('complete','missing','duplicate','unknown','fixture')) {
            $ids = @($inventory.$mode)
            if ($case -eq 'missing') { $ids = @($ids | Select-Object -Skip 1) }
            if ($case -eq 'duplicate') { $ids[-1] = $ids[0] }
            if ($case -eq 'unknown') { $ids[-1] = 'undeclared terminal ID' }
            $result = [pscustomobject]@{ fixture = $(if ($case -eq 'fixture') {'wrong-v1'} else {$fixture}); checks = @($ids | ForEach-Object { [pscustomobject]@{scenario=$_} }) }
            $checks += @{ mode=$mode;fixture=$fixture;case=$case;expected=($case -eq 'complete');actual=(Test-CompositionInventory $result $mode) }
        }
    }
}
$ok = @($checks | Where-Object { $_.expected -ne $_.actual }).Count -eq 0
$root = "$PSScriptRoot/../tests/.runs/m1-composition-inventory-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Force $root | Out-Null
@{schema='m1-composition-inventory-qualification-v1';ok=$ok;checks=$checks} | ConvertTo-Json -Depth 8 | Set-Content "$root/result.json"
Write-Output "M1 composition inventory qualification $ok : $root/result.json"
if (!$ok) { exit 1 }
