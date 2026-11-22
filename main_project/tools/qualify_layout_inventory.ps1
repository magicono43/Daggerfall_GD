$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/layout_fixture.ps1"
$inventory = Get-Content "$PSScriptRoot/../tests/layout_inventory.json" -Raw | ConvertFrom-Json
$checks = @()
foreach ($mode in @('headless','rendered','reload')) {
    $ids = @($inventory.$mode)
    $vectors = @(
        @{ id='complete'; expected=$true; fixture=$inventory.fixture; ids=$ids },
        @{ id='missing'; expected=$false; fixture=$inventory.fixture; ids=@($ids | Select-Object -Skip 1) },
        @{ id='duplicate'; expected=$false; fixture=$inventory.fixture; ids=@($ids[0]) + @($ids | Select-Object -Skip 1 | Select-Object -SkipLast 1) + @($ids[0]) },
        @{ id='unknown'; expected=$false; fixture=$inventory.fixture; ids=@($ids | Select-Object -Skip 1) + @('unknown-layout-assertion') },
        @{ id='wrong fixture'; expected=$false; fixture='other'; ids=$ids }
    )
    foreach ($vector in $vectors) {
        $result = @{ fixture=$vector.fixture; checks=@($vector.ids | ForEach-Object { @{ scenario=$_ } }) }
        $actual = Test-LayoutInventory $result $mode
        $checks += @{ mode=$mode; id=$vector.id; expected=$vector.expected; actual=$actual }
        if ($actual -ne $vector.expected) { throw "Inventory qualifier mismatch: $mode/$($vector.id)" }
    }
}
@{schema='layout-inventory-qualification-v1';ok=$true;checks=$checks} | ConvertTo-Json -Depth 8 | Set-Content "$PSScriptRoot/../tests/.runs/layout-inventory-qualification.json"
Write-Output 'Layout inventory: 15/15 qualification vectors passed.'
