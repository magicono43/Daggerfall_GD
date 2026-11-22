$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/variant_fixture.ps1"
$inventory = Get-Content -LiteralPath "$PSScriptRoot/../tests/variant_inventory.json" -Raw | ConvertFrom-Json
$checks = @()
foreach ($mode in @('headless','rendered','reload')) {
    $valid = @{ fixture='variant-inputs-v1'; checks=@($inventory.$mode | ForEach-Object { @{scenario=$_} }) }
    $checks += @{ id="$mode-valid"; expected=$true; actual=(Test-VariantInventory $valid $mode) }
    $missing = @{fixture=$valid.fixture; checks=@($valid.checks | Select-Object -Skip 1)}
    $checks += @{ id="$mode-missing"; expected=$false; actual=(Test-VariantInventory $missing $mode) }
    $duplicate = @{fixture=$valid.fixture; checks=@($valid.checks | Select-Object -Skip 1)+@($valid.checks[1])}
    $checks += @{ id="$mode-duplicate"; expected=$false; actual=(Test-VariantInventory $duplicate $mode) }
    $unknown = @{fixture=$valid.fixture; checks=@($valid.checks | Select-Object -Skip 1)+@(@{scenario='unknown-terminal'})}
    $checks += @{ id="$mode-unknown"; expected=$false; actual=(Test-VariantInventory $unknown $mode) }
    $wrong = @{fixture='wrong-fixture'; checks=$valid.checks}
    $checks += @{ id="$mode-wrong-fixture"; expected=$false; actual=(Test-VariantInventory $wrong $mode) }
}
$ok = @($checks | Where-Object { $_.expected -ne $_.actual }).Count -eq 0
$out = "$PSScriptRoot/../tests/.runs/variant-inventory-qualification.json"
@{schema='variant-inventory-qualification-v1'; ok=$ok; checks=$checks} | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $out
if (!$ok) { throw 'Variant inventory validator failed qualification' }
Write-Output "Passed $($checks.Count) inventory-validator vectors: $out"
