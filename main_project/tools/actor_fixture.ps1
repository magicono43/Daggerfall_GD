# Explicit selected-source declaration. No recursive discovery or payload copies.
function Get-ActorSourceNames {
    @('FLATS.CFG','MONSTER.BSA','PAINT.DAT','BIO.DAT')
    0..18 | ForEach-Object { 'CLASS{0:D2}.CFG' -f $_ }
    0..17 | ForEach-Object { 'BIOG{0:D2}T0.TXT' -f $_ }
}

function Test-ActorInventory($Result,[string]$Mode) {
    $inventory=Get-Content -LiteralPath "$PSScriptRoot/../tests/actor_input_inventory.json" -Raw | ConvertFrom-Json
    if($inventory.schema -cne 'actor-input-inventory-v1' -or $Result.fixture -cne $inventory.fixture) { return $false }
    $expected=@($inventory.$Mode)
    $actual=@($Result.checks.scenario)
    return $expected.Count -gt 0 -and $actual.Count -eq $expected.Count -and
        @($actual | Select-Object -Unique).Count -eq $actual.Count -and
        @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
