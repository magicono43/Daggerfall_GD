# Independent rendered entry point. No headless fallback is permitted.
& "$PSScriptRoot/verify.ps1" -Mode rendered @args
exit $LASTEXITCODE
