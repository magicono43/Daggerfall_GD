# Forward all named arguments to the shared project runner; preserve its exit code.
& "$PSScriptRoot/verify.ps1" -Mode headless @args
exit $LASTEXITCODE
