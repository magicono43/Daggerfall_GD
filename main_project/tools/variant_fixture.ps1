# Independent inventory; never accept a terminal report on count alone.
function Test-VariantInventory($Result,[string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/variant_inventory.json" -Raw | ConvertFrom-Json
    if ($inventory.schema -cne 'variant-inventory-v1' -or $Result.fixture -cne $inventory.fixture -or $Mode -notin @('headless','rendered','reload')) { return $false }
    $expected = @($inventory.$Mode)
    $actual = @($Result.checks.scenario)
    return $expected.Count -gt 0 -and $actual.Count -eq $expected.Count -and
        @($actual | Select-Object -Unique).Count -eq $actual.Count -and
        @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
function Get-VariantExpectedCount([string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/variant_inventory.json" -Raw | ConvertFrom-Json
    return @($inventory.$Mode).Count
}
