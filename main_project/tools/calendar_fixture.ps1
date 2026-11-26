function Test-CalendarInventory($Result, [string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/calendar_inventory.json" -Raw | ConvertFrom-Json
    $expected = @($inventory.$Mode)
    $scheduler = Get-Content -LiteralPath "$PSScriptRoot/../tests/scheduler_inventory.json" -Raw | ConvertFrom-Json
    if ($scheduler.schema -cne 'calendar-scheduler-inventory-v1' -or $Result.scheduler_fixture -cne $scheduler.fixture) { return $false }
    $expected += @($scheduler.checks)
    $activity = Get-Content -LiteralPath "$PSScriptRoot/../tests/activity_policy_inventory.json" -Raw | ConvertFrom-Json
    if ($activity.schema -cne 'calendar-activity-inventory-v1' -or $Result.activity_fixture -cne $activity.fixture) { return $false }
    $expected += @($activity.checks)
    if ($Mode -eq 'rendered') { $expected += @($scheduler.rendered_additional) }
    $actual = @($Result.checks.scenario)
    return $inventory.schema -ceq 'calendar-inventory-v1' -and $Result.fixture -ceq $inventory.fixture -and $Result.count -eq $expected.Count -and $actual.Count -eq $expected.Count -and @($actual | Select-Object -Unique).Count -eq $actual.Count -and @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
