# Pure inventory qualification; wrappers independently reject missing results,
# wrong counts, crashes, unavailable inputs/renderers and unmatched diagnostics.
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/assertion_values.ps1"
$inventory = Get-Content "$PSScriptRoot/../tests/replacement_inventory.json" -Raw | ConvertFrom-Json
$checks = @()
foreach ($mode in @('headless','rendered','reload')) {
    $ids = @($inventory.$mode)
    foreach ($case in @('complete','missing','duplicate','unknown','fixture')) {
        $changed = @($ids)
        if ($case -eq 'missing') { $changed = @($ids | Select-Object -Skip 1) }
        if ($case -eq 'duplicate') { $changed[-1] = $changed[0] }
        if ($case -eq 'unknown') { $changed[-1] = 'undeclared terminal ID' }
        $result = [pscustomobject]@{ fixture = $(if ($case -eq 'fixture') {'wrong-v1'} else {'replacements-v1'}); checks = @($changed | ForEach-Object { [pscustomobject]@{ scenario = $_ } }) }
        $actual = Test-ReplacementInventory $result $mode
        $expected = $case -eq 'complete'
        $checks += @{ mode=$mode; case=$case; expected=$expected; actual=$actual }
    }
}
$root = "$PSScriptRoot/../tests/.runs/replacement-inventory-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Force $root | Out-Null
$ok = @($checks | Where-Object { $_.expected -ne $_.actual }).Count -eq 0
@{schema='media-replacement-inventory-qualification-v1';ok=$ok;checks=$checks} | ConvertTo-Json -Depth 8 | Set-Content "$root/result.json"
Write-Output "Replacement inventory qualification $ok : $root/result.json"
if (!$ok) { exit 1 }
