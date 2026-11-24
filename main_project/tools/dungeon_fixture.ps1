function Get-DungeonExpectedCount([string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/$(if ($DungeonMarkers -or $Fixture -eq 'dungeon-markers-v1') { 'dungeon_marker_inventory.json' } elseif ($DungeonContext -or $Fixture -eq 'dungeon-context-v1') { 'dungeon_context_inventory.json' } else { 'dungeon_inventory.json' })" -Raw | ConvertFrom-Json
    return @($inventory.$Mode).Count
}
function Test-DungeonInventory($Result,[string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/$(if ($Result.fixture -eq 'dungeon-markers-v1') { 'dungeon_marker_inventory.json' } elseif ($Result.fixture -eq 'dungeon-context-v1') { 'dungeon_context_inventory.json' } else { 'dungeon_inventory.json' })" -Raw | ConvertFrom-Json
    if ($inventory.schema -cne 'dungeon-assembly-inventory-v1' -or $Result.fixture -cne $inventory.fixture -or
        (Get-FileHash -LiteralPath "$PSScriptRoot/../tests/dungeon_source_observation.json").Hash -ine $inventory.source_observation_sha256 -or
        (Get-FileHash -LiteralPath "$PSScriptRoot/../content/layouts/dungeon_assembly.json").Hash -ine $inventory.annotation_sha256) { return $false }
    if ($Result.fixture -in @('dungeon-context-v1','dungeon-markers-v1') -and (
        (Get-FileHash -LiteralPath "$PSScriptRoot/../tests/dungeon_context_observation.json").Hash -ine $inventory.context_observation_sha256 -or
        (Get-FileHash -LiteralPath "$PSScriptRoot/../content/layouts/dungeon_context.json").Hash -ine $inventory.context_annotation_sha256)) { return $false }
    if ($Result.fixture -eq 'dungeon-markers-v1' -and (
        (Get-FileHash -LiteralPath "$PSScriptRoot/../tests/dungeon_marker_resolved_observation.json").Hash -ine $inventory.marker_observation_sha256 -or
        (Get-FileHash -LiteralPath "$PSScriptRoot/../tests/dungeon_opening_geometry_observation.json").Hash -ine $inventory.opening_geometry_observation_sha256 -or
        (Get-FileHash -LiteralPath "$PSScriptRoot/../tests/dungeon_opening_floor_observation.json").Hash -ine $inventory.opening_floor_observation_sha256 -or
        (Get-FileHash -LiteralPath "$PSScriptRoot/../tests/classic_unknown_action_observation.json").Hash -ine $inventory.unknown_action_observation_sha256 -or
        (Get-FileHash -LiteralPath "$PSScriptRoot/../tests/classic_action_axes_observation.json").Hash -ine $inventory.action_axes_observation_sha256 -or
        (Get-FileHash -LiteralPath "$PSScriptRoot/../content/layouts/dungeon_arrivals.json").Hash -ine $inventory.arrival_annotation_sha256)) { return $false }
    $expected = @($inventory.$Mode)
    $actual = @($Result.checks.scenario)
    return $expected.Count -gt 0 -and $actual.Count -eq $expected.Count -and
        @($actual | Select-Object -Unique).Count -eq $actual.Count -and
        @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
