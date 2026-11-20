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
