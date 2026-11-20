# Verifies the harness reports AND process-level exit codes. Deliberate failures
# remain failed scenario results; only their qualification assertions pass here.
param([string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$evidence = "$project/tests/.runs/qualification-$([Guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Force $evidence | Out-Null
$records = @()
foreach ($mode in @('headless','rendered')) {
    foreach ($kind in @('pass','fail','missing')) {
        $selection = if ($kind -eq 'missing') { 'native-failed-restore' } else { 'qualification' }
        $fixture = if ($kind -eq 'fail') { 'assert-fail-v1' } else { 'm1-v1' }
        $entry = "$PSScriptRoot/verify_$mode.ps1"
        $argsList = @('-NoProfile','-File', ('"' + $entry + '"'), '-Scenario',$selection,'-Fixture',$fixture,'-Godot',('"' + $Godot + '"'))
        $child = Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList $argsList -WindowStyle Hidden -PassThru `
            -RedirectStandardOutput "$evidence/$mode-$kind.stdout.log" -RedirectStandardError "$evidence/$mode-$kind.stderr.log"
        $child.WaitForExit()
        $stdout = Get-Content "$evidence/$mode-$kind.stdout.log" -Raw
        $reportPath = ($stdout.Trim() -split ': ',2)[1]
        $report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
        $expectedStatus = @{ pass = 'passed'; fail = 'failed'; missing = 'incomplete' }[$kind]
        $expectedExit = @{ pass = 0; fail = 1; missing = 2 }[$kind]
        if ($child.ExitCode -ne $expectedExit -or $report.status -ne $expectedStatus) { throw "Qualification mismatch: $mode $kind" }
        if ($kind -eq 'fail') {
            $assertion = @($report.scenarios[0].result.checks | Where-Object scenario -eq 'qualification value')[0]
            if ($assertion.expected -ne 1 -or $assertion.actual -ne 0 -or $report.scenarios[0].process_exit -ne 1) { throw 'Failure values or engine exit mismatch' }
        }
        if (!$report.reproduction.command -or !$report.engine -or !$report.build.sources) { throw 'Missing reproduction/build identity' }
        if ($records.root -contains $report.root) { throw 'Disposable root reused' }
        $records += @{ mode = $mode; case = $kind; expected_exit = $expectedExit; actual_exit = $child.ExitCode
            expected_status = $expectedStatus; actual_status = $report.status; report = $reportPath; root = $report.root }
        $records | ConvertTo-Json -Depth 10 | Set-Content "$evidence/result.json"
        Write-Output "$mode $kind qualified: exit $($child.ExitCode), $reportPath"
    }
}
Write-Output "Qualification evidence: $evidence/result.json"
