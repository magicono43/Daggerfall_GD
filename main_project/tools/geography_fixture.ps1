# Frozen terminal assertion IDs, independent of the expected total count.
function Test-GeographyInventory($Result,[string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/geography_inventory.json" -Raw | ConvertFrom-Json
    if ($inventory.schema -cne 'geography-inventory-v1' -or $Result.fixture -cne $inventory.fixture) { return $false }
    $expected = @($inventory.$Mode)
    $actual = @($Result.checks.scenario)
    return $expected.Count -gt 0 -and $actual.Count -eq $expected.Count -and
        @($actual | Select-Object -Unique).Count -eq $actual.Count -and
        @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
