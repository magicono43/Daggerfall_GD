function Test-ActorStateInventory($Result, [string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/actor_state_inventory.json" -Raw | ConvertFrom-Json
    $expected = @($inventory.$Mode)
    $actual = @($Result.checks.scenario)
    return $inventory.schema -ceq 'actor-state-inventory-v1' -and $Result.fixture -ceq 'IMP-016-actor-state-v1' -and $Result.count -eq $expected.Count -and $actual.Count -eq $expected.Count -and @($actual | Select-Object -Unique).Count -eq $actual.Count -and @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
