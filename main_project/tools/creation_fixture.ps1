function Test-CreationInventory($Result, [string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/creation_inventory.json" -Raw | ConvertFrom-Json
    $expected = @($inventory.$Mode)
    $actual = @($Result.checks.scenario)
    return $inventory.schema -ceq 'creation-inventory-v1' -and $Result.fixture -ceq $inventory.fixture -and $Result.count -eq $expected.Count -and $actual.Count -eq $expected.Count -and @($actual | Select-Object -Unique).Count -eq $actual.Count -and @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
