$ErrorActionPreference = 'Stop'
$Fixture = 'location-assembly-v1'
$DungeonMarkers = $false
$DungeonContext = $false
. "$PSScriptRoot/dungeon_fixture.ps1"
$inventory = Get-Content "$PSScriptRoot/../tests/location_inventory.json" -Raw | ConvertFrom-Json
$checks = @()
foreach ($mode in @('headless','rendered','reload-headless','reload-rendered')) {
    foreach ($case in @('complete','missing','duplicate','unknown','wrong-fixture')) {
        $names = @($inventory.$mode)
        $fixtureName = $Fixture
        switch ($case) {
            'missing' { $names = $names[1..($names.Count-1)] }
            'duplicate' { $names[-1] = $names[0] }
            'unknown' { $names[-1] = 'not-a-declared-scenario' }
            'wrong-fixture' { $fixtureName = 'unsupported-fixture' }
        }
        $result = [pscustomobject]@{ fixture=$fixtureName; checks=@($names | ForEach-Object { [pscustomobject]@{ scenario=$_ } }) }
        $actual = Test-DungeonInventory $result $mode
        $checks += @{ scenario="$mode/$case"; expected=($case -eq 'complete'); actual=$actual }
    }
}
$LocationAssembly = $true
# The export runner uses a fixture dictionary; PowerShell variable names are
# case-insensitive. The explicit switch must select every expected count.
$Fixture = @{ fixture='location-assembly-v1' }
foreach ($mode in @('headless','rendered','reload-headless','reload-rendered')) {
    $checks += @{ scenario="export-switch/$mode"; expected=@($inventory.$mode).Count; actual=(Get-DungeonExpectedCount $mode) }
}
$ok = @($checks | Where-Object { $_.expected -ne $_.actual }).Count -eq 0
$report = @{ schema='location-inventory-policy-v1'; ok=$ok; count=$checks.Count; checks=$checks }
$report | ConvertTo-Json -Depth 6 | Set-Content "$PSScriptRoot/../tests/.runs/imp013-inventory-policy.json"
if (!$ok) { throw 'Location inventory policy failed.' }
Write-Output "Location inventory policy passed: $($checks.Count) checks."
