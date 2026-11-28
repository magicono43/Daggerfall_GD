function Test-ItemPersistenceInventory($Result,[string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/item_persistence_inventory.json" -Raw | ConvertFrom-Json
    $expected = @($inventory.$Mode)
    $actual = @($Result.checks.scenario)
    return $inventory.schema -ceq 'item-persistence-inventory-v1' -and $Result.fixture -ceq $inventory.fixture -and
        $expected.Count -gt 0 -and $actual.Count -eq $expected.Count -and
        @($actual | Select-Object -Unique).Count -eq $actual.Count -and
        @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
