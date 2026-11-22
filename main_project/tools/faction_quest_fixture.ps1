# Exact reviewed terminal inventory; independent headless/rendered/export entry points.
function Test-FactionQuestInventory($Result,[string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/faction_quest_inventory.json" -Raw | ConvertFrom-Json
    if ($inventory.schema -cne 'faction-quest-inventory-v1' -or $Result.fixture -cne $inventory.fixture) { return $false }
    $expected = @($inventory.$Mode)
    $actual = @($Result.checks.scenario)
    return $expected.Count -gt 0 -and $actual.Count -eq $expected.Count -and
        @($actual | Select-Object -Unique).Count -eq $actual.Count -and
        @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
