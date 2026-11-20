# Compare JSON structures recursively, preserving legacy numeric equality (9 == 9.0)
# and case-sensitive strings. PowerShell collection comparison is not deep equality.
function Test-AssertionValue($Expected, $Actual) {
    if ($null -eq $Expected -or $null -eq $Actual) { return $null -eq $Expected -and $null -eq $Actual }
    if ($Expected -is [Array] -or $Actual -is [Array]) {
        if ($Expected -isnot [Array] -or $Actual -isnot [Array] -or $Expected.Count -ne $Actual.Count) { return $false }
        for ($i = 0; $i -lt $Expected.Count; $i++) {
            if (!(Test-AssertionValue $Expected[$i] $Actual[$i])) { return $false }
        }
        return $true
    }
    if ($Expected -is [pscustomobject] -or $Actual -is [pscustomobject]) {
        if ($Expected -isnot [pscustomobject] -or $Actual -isnot [pscustomobject]) { return $false }
        $names = @($Expected.PSObject.Properties | ForEach-Object { $_.Name })
        if ($names.Count -ne @($Actual.PSObject.Properties | ForEach-Object { $_.Name }).Count) { return $false }
        foreach ($name in $names) {
            $property = $Actual.PSObject.Properties[$name]
            if ($null -eq $property -or !(Test-AssertionValue $Expected.$name $property.Value)) { return $false }
        }
        return $true
    }
    if ($Expected -is [string] -or $Actual -is [string]) {
        return $Expected -is [string] -and $Actual -is [string] -and $Expected -ceq $Actual
    }
    return $Expected -ceq $Actual
}

# The pinned fault fixture must match every captured parser/VM error and log site.
# Release compiles out the VM access check; the parser failure remains observable.
function Test-ScriptDiagnostics([string[]]$Logs, [string]$Scenario, $Result) {
    $lines = @(Select-String -Path $Logs -Pattern '^SCRIPT ERROR: ' -CaseSensitive)
    if ($Scenario -cne 'formula-fault') { return $lines.Count -eq 0 }
    if ($Result.fixture -cne 'IMP-006-formula-fault-v1' -or $Result.contract -cne 'integer-formula-v1' -or $Result.debug_build -isnot [bool]) { return $false }
    $checked = @($Result.checked_callback_errors)
    $expectedCount = if ($Result.debug_build) { 2 } else { 1 }
    $scriptCount = if ($Result.debug_build) { 1 } else { 0 }
    $nativeText = "Parse JSON failed. Error at line 0: Expected '}'"
    $nativeCode = 'Condition "error != Error::OK" is true. Returning: Variant()'
    if ($checked.Count -ne $expectedCount -or $lines.Count -ne $scriptCount -or
        $checked[0].kind -ne 0 -or $checked[0].function -cne 'parse_string' -or
        $checked[0].source -cne 'core/io/json.cpp' -or $checked[0].line -le 0 -or
        $checked[0].rationale -cne $nativeText -or $checked[0].code -cne $nativeCode) { return $false }
    $nativeLines = @(Select-String -Path $Logs -Pattern '^ERROR: Parse JSON failed\.' -CaseSensitive)
    $nativeSite = 'at: parse_string (core/io/json.cpp:' + $checked[0].line + ')'
    if ($nativeLines.Count -ne 1 -or $nativeLines[0].Line -cne ('ERROR: ' + $nativeText) -or
        @(Select-String -Path $Logs -SimpleMatch $nativeSite).Count -ne 1) { return $false }
    if (!$Result.debug_build) { return $true }
    $code = "Invalid access to property or key 'missing_fixture_value' on a base object of type 'Nil'."
    if ($checked[1].kind -ne 2 -or $checked[1].function -cne 'FormulaCaseCallbacks.throws' -or
        $checked[1].source -cne 'res://tests/formula_case_callbacks.gd' -or $checked[1].line -le 0 -or
        $checked[1].code -cne $code -or $lines[0].Line -cne ('SCRIPT ERROR: ' + $code)) { return $false }
    $location = 'at: FormulaCaseCallbacks.throws (res://tests/formula_case_callbacks.gd:' + $checked[1].line + ')'
    return @(Select-String -Path $Logs -SimpleMatch $location).Count -eq 1
}
