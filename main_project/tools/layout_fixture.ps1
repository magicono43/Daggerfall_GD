# Frozen inventories are independent of terminal counts and order.
function Test-LayoutInventory($Result,[string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/layout_inventory.json" -Raw | ConvertFrom-Json
    if ($inventory.schema -cne 'layout-inventory-v1' -or $Result.fixture -cne $inventory.fixture) { return $false }
    $expected = @($inventory.$Mode)
    $actual = @($Result.checks.scenario)
    return $expected.Count -gt 0 -and $actual.Count -eq $expected.Count -and
        @($actual | Select-Object -Unique).Count -eq $actual.Count -and
        @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}

function Get-LayoutSourceHashes($Expected,[string]$Root) {
    $actual = @{}
    foreach ($name in $Expected.Keys) {
        $actual[$name] = (Get-FileHash -LiteralPath (Join-Path $Root $name) -Algorithm SHA256).Hash
        if ($actual[$name] -ne $Expected[$name]) { throw "Required source changed: $name" }
    }
    return $actual
}
