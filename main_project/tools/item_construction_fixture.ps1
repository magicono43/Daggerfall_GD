function Get-ItemConstructionSourceNames {
    @(207,233,234,235,236,237,238,239,240,241,242,245,246,247,248,249,250,251,252) | ForEach-Object { 'TEXTURE.{0:000}' -f $_ }
}
function Test-ItemConstructionInventory($Result,[string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/item_construction_inventory.json" -Raw | ConvertFrom-Json
    $expected = @($inventory.$Mode)
    $actual = @($Result.checks.scenario)
    return $inventory.schema -ceq 'item-construction-inventory-v1' -and $Result.fixture -ceq $inventory.fixture -and
        $expected.Count -gt 0 -and $actual.Count -eq $expected.Count -and
        @($actual | Select-Object -Unique).Count -eq $actual.Count -and
        @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
