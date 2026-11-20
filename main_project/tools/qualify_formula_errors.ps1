param(
    [Parameter(Mandatory)][string]$ClassicSource,
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe'
)
$ErrorActionPreference = 'Stop'
$project = [IO.Path]::GetFullPath("$PSScriptRoot/..")
$root = "$project/tests/.runs/formula-qualification-$([Guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Force $root | Out-Null
$records = @()
foreach ($mode in @('headless','rendered')) {
    foreach ($fixture in @('formula-v1','formula-extra-error-v1')) {
        $name = "$mode-$fixture"
        $entry = "$PSScriptRoot/verify_$mode.ps1"
        $arguments = @('-NoProfile','-File',('"'+$entry+'"'),'-Scenario','formula-fault','-Fixture',$fixture,
            '-ClassicSource',('"'+$ClassicSource+'"'),'-Godot',('"'+$Godot+'"'))
        $child = Start-Process -FilePath (Get-Process -Id $PID).Path -ArgumentList $arguments -WindowStyle Hidden -PassThru `
            -RedirectStandardOutput "$root/$name.stdout.log" -RedirectStandardError "$root/$name.stderr.log"
        $child.WaitForExit()
        $reportPath = ((Get-Content "$root/$name.stdout.log" -Raw).Trim() -split ': ',2)[1]
        $report = Get-Content -LiteralPath $reportPath -Raw | ConvertFrom-Json
        $scenario = $report.scenarios[0]
        $expectedExit = if ($fixture -eq 'formula-v1') { 0 } else { 2 }
        $expectedStatus = if ($fixture -eq 'formula-v1') { 'passed' } else { 'incomplete' }
        $expectedErrors = if ($fixture -eq 'formula-v1') { 1 } else { 2 }
        $errors = @(Select-String -Path "$($scenario.root)/console.*.log" -Pattern '^SCRIPT ERROR: ' -CaseSensitive)
        if ($child.ExitCode -ne $expectedExit -or $report.status -ne $expectedStatus -or
            $scenario.process_exit -ne 0 -or !$scenario.result.ok -or $scenario.result.count -ne 18 -or
            $scenario.result.checked_callback_errors.Count -ne 2 -or $errors.Count -ne $expectedErrors -or
            !$report.build.sources -or $records.root -contains $report.root) { throw "Formula diagnostic qualification failed: $name" }
        $records += @{ mode=$mode; fixture=$fixture; expected_exit=$expectedExit; actual_exit=$child.ExitCode;
            expected_status=$expectedStatus; actual_status=$report.status; script_errors=$errors.Count;
            root=$report.root; report=$reportPath }
        $records | ConvertTo-Json -Depth 10 | Set-Content "$root/result.json"
        Write-Output "$name qualified: exit $($child.ExitCode), $reportPath"
    }
}
Write-Output "Formula diagnostic qualification: $root/result.json"
