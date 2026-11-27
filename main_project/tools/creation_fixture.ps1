function Get-CreationOptionalMediaNames([string]$ClassicSource) {
    foreach ($name in @('SPOP.RCI','BUTTONS.RCI','FONT0002.FNT','FONT0003.FNT','BUTN01I0.IMG','BUTN02I0.IMG','PICK00I0.IMG','CHAR02I1.IMG','CUST01I0.IMG','CUST02I0.IMG','CUST03I0.IMG','ANIM0000.VID','ANIM0011.VID','DAG2.VID')) {
        if (Test-Path -LiteralPath (Join-Path $ClassicSource $name) -PathType Leaf) { $name }
    }
}

function Get-CreationAppearanceNames {
    foreach ($race in 0..7) {
        'SCBG{0:00}I0.IMG' -f $race
        foreach ($gender in 0..1) {
            'FACE{0}{1}I0.CIF' -f $gender,$race
            foreach ($clothed in 0..1) { 'BODY{0}{1}I{2}.IMG' -f $gender,$race,$clothed }
        }
    }
}

function Get-CreationBookNames {
    $policy = Get-Content -LiteralPath "$PSScriptRoot/../content/char/biography.json" -Raw | ConvertFrom-Json
    foreach ($id in $policy.entries[0].value.books) { 'BOOKS/BOK{0:00000}.TXT' -f [int]$id }
}

function Test-CreationInventory($Result, [string]$Mode) {
    $inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/creation_inventory.json" -Raw | ConvertFrom-Json
    $expected = @($inventory.$Mode)
    $actual = @($Result.checks.scenario)
    return $inventory.schema -ceq 'creation-inventory-v1' -and $Result.fixture -ceq $inventory.fixture -and $Result.count -eq $expected.Count -and $actual.Count -eq $expected.Count -and @($actual | Select-Object -Unique).Count -eq $actual.Count -and @(Compare-Object -ReferenceObject $expected -DifferenceObject $actual -CaseSensitive).Count -eq 0
}
