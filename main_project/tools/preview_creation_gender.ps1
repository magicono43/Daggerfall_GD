param(
 [string]$ClassicSource='C:/Games/Daggerfall/arena2',
 [string]$Godot='C:/Godot/Godot_v4.7.2-stable_win64/Godot_v4.7.2-stable_win64_console.exe',
 [switch]$SmokeTest,
 [switch]$ClassMethod,
 [switch]$ClassPicker,
 [switch]$CloseTest,
 [switch]$CustomSheet,
 [switch]$Reputation,
 [switch]$CustomExit,
 [switch]$HelpMenu,
 [switch]$Traits,
 [switch]$Disadvantages
)
$ErrorActionPreference='Stop'
if($SmokeTest -and $CloseTest){throw 'Choose SmokeTest or CloseTest, not both.'}
if($PSVersionTable.PSVersion.Major -lt 7){throw 'Use PowerShell 7.'}
. "$PSScriptRoot/assertion_values.ps1"
. "$PSScriptRoot/run_artifacts.ps1"
$project=[IO.Path]::GetFullPath("$PSScriptRoot/..")
$root=Assert-RunArtifactPath (Join-Path $script:RunArtifactBase ('verification-rendered-'+[guid]::NewGuid().ToString('N')))
$runtime=Join-Path $root 'project'
$case=Join-Path $runtime 'tests/.runs/preview'
$sandbox=Join-Path $case 'storage'
$engine=$Godot.Replace('_console.exe','.exe')
if(!(Test-Path $engine)){$engine=$Godot}
function Copy-Preview([string]$From,[string]$To){
 New-Item -ItemType Directory -Force $To|Out-Null
 foreach($entry in Get-ChildItem -LiteralPath $From){
  if($entry.PSIsContainer){
   if($entry.Name -notin @('.godot','.runs','tools','.zig-cache','zig-out')){Copy-Preview $entry.FullName (Join-Path $To $entry.Name)}
  }elseif($entry.Extension -notin @('.pdb','.lib')){Copy-Item -LiteralPath $entry.FullName -Destination (Join-Path $To $entry.Name)}
 }
}
function Child([string[]]$Arguments,[string]$Name,[int]$Seconds){
 $quoted=@($Arguments|ForEach-Object {'"'+$_.Replace('"','\"')+'"'})
 $options=@{FilePath=$engine;ArgumentList=$quoted;PassThru=$true;RedirectStandardOutput="$case/$Name.stdout.log";RedirectStandardError="$case/$Name.stderr.log"}
 if($Seconds -gt 0){$options.WindowStyle='Hidden'}
 $p=Start-Process @options
 if($Seconds -gt 0){if(!$p.WaitForExit($Seconds*1000)){$p.Kill($true);$p.WaitForExit();throw "Owned $Name timed out: $root"}}else{$p.WaitForExit()}
 $p.WaitForExit()
 if($p.ExitCode -ne 0){throw "Owned $Name failed: $root"}
 return $p
}
$report=[ordered]@{schema=1;mode='rendered';suite='creation-popup-preview';fixture='creation-popup-preview-v1';root=$root;runtime_project=$runtime;status='incomplete';scope='Focused rendered preview only; broad suites and exports deferred';human_pass=$false;scenarios=@(@{root=$case});build=@{sources=@{}};classic_source=$ClassicSource}
New-Item -ItemType Directory -Force $case,$sandbox|Out-Null
$report.build.source_revision=(& git -C $project rev-parse HEAD)
$report.build.working_tree=@(& git -C $project status --short)
$scope=@('project.godot','content/char/creation.json','scripts/ui/creation_popup.gd','scripts/ui/creation_class_method.gd','scripts/ui/classic_list_picker.gd','scripts/char/creation_career_view.gd','scripts/char/creation_view.gd','scripts/data/classic_access.gd','scripts/av/creation_art.gd','tests/creation_popup_preview.gd','tests/creation_picker_preview.gd','tests/creation_review.gd')
$scope+=@('content/ui/classic/VScrollThumbTop.png','content/ui/classic/VScrollThumbBody.png','content/ui/classic/VScrollThumbBottom.png','content/ui/classic/DFU_LICENSE.txt','content/ui/classic/README.md')
$scope+=@('scripts/startup/startup_shell.gd')
$scope+=@('scripts/ui/creation_custom_sheet.gd','scripts/ui/creation_difficulty_dagger.gd','tests/creation_custom_sheet_preview.gd')
$scope+=@('scripts/ui/creation_hp_repeat.gd')
$scope+=@('scripts/ui/creation_reputation.gd','tests/creation_reputation_preview.gd')
$scope+=@('scripts/ui/creation_custom_messages.gd','tests/creation_custom_exit_preview.gd')
$scope+=@('scripts/ui/creation_traits.gd','tests/creation_traits_preview.gd','scripts/char/custom_career.gd','scripts/data/creation_career.gd','scripts/data/classic_font.gd','scripts/av/creation_art.gd','content/char/career.json')
$scope+=@('scripts/ui/creation_help.gd','tests/creation_help_preview.gd')
foreach($file in $scope){$report.build.sources[$file]=(Get-FileHash (Join-Path $project $file)).Hash}
$originals=@{}
foreach($file in @('FONT0002.FNT','CUST01I0.IMG','CUST02I0.IMG','FONT0003.FNT','BUTTONS.RCI','SPOP.RCI','ART_PAL.COL','TMAP00I0.IMG','BUTN01I0.IMG','BUTN02I0.IMG','PICK00I0.IMG','CUST00I0.IMG','CUST08I0.IMG','CHAR02I1.IMG','CUST03I0.IMG','TEXT.RSC')){$originals[$file]=(Get-FileHash (Join-Path $ClassicSource $file)).Hash}
$priorRoaming=$env:APPDATA;$priorLocal=$env:LOCALAPPDATA;$child=$null
try{
 Write-Output 'Preparing a fresh focused preview; full suites and exports are deferred.'
 Copy-Preview $project $runtime
 $env:APPDATA="$root/engine-roaming";$env:LOCALAPPDATA="$root/engine-local"
 New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA|Out-Null
 $started=[DateTime]::UtcNow
 $null=Child @('--headless','--path',$runtime,'--import','--quit-after','60') 'import' 90
 if((Get-Content "$case/import.stderr.log" -Raw) -match 'SCRIPT ERROR|Parse Error'){throw "Preview import reported script errors: $root"}
 foreach($file in $scope){if((Get-FileHash (Join-Path $runtime $file)).Hash -cne $report.build.sources[$file] -or (Get-FileHash (Join-Path $project $file)).Hash -cne $report.build.sources[$file]){throw 'Source changed during preview preparation; rerun.'}}
 @{mode='creation-review';fixture='creation-popup-preview-v1';sandbox=$sandbox.Replace('\','/');classic_source=([IO.Path]::GetFullPath($ClassicSource)).Replace('\','/');popup_preview=$true;class_method_preview=[bool]$ClassMethod;class_picker_preview=[bool]$ClassPicker;custom_sheet_preview=[bool]$CustomSheet;reputation_preview=[bool]$Reputation;custom_exit_preview=[bool]$CustomExit;help_preview=[bool]$HelpMenu;traits_preview=[bool]($Traits -or $Disadvantages);disadvantages_preview=[bool]$Disadvantages;review_smoke=[bool]$SmokeTest;preview_close_test=[bool]$CloseTest}|ConvertTo-Json|Set-Content "$case/fixture.json"
 @{owner='IMP-015 focused gender preview';expiry='Until this preview engine closes; preserve evidence then compact.'}|ConvertTo-Json|Set-Content "$root/ACTIVE-HUMAN-REVIEW.json"
 $arguments=@('--path',$runtime)
 if($CloseTest){$arguments+='--verbose'}
 $arguments+=@('--',"--startup-fixture=$case/fixture.json")
 $child=Child $arguments 'preview' $(if($SmokeTest -or $CloseTest){150}else{0})
 $resultPath=if($SmokeTest){"$sandbox/result.json"}else{"$sandbox/preview-state.json"}
 $result=Get-Content $resultPath -Raw|ConvertFrom-Json
 if(!$result.ok -or $result.human_pass){throw "Focused checks failed: $resultPath"}
 if(!(Test-ScriptDiagnostics @("$case/preview.stdout.log","$case/preview.stderr.log") '' $result)){
  $details=@(Select-String -Path "$case/preview.stdout.log","$case/preview.stderr.log" -Pattern '^ERROR:|^WARNING:|SCRIPT ERROR:|Leaked instance:' | Where-Object {$_.Line -cne 'ERROR: Failed to read the root certificate store.'} | Select-Object -First 4 -ExpandProperty Line)
  throw "Unexpected preview diagnostics: $($details -join ' | '). Logs: $case. Evidence: $root"
 }
 foreach($file in $originals.Keys){if((Get-FileHash (Join-Path $ClassicSource $file)).Hash -cne $originals[$file]){throw 'Original asset hash changed'}}
 $report.status='passed';$report.result=$result;$report.source_hashes=$originals;$report.elapsed_seconds=([DateTime]::UtcNow-$started).TotalSeconds
}catch{
 $report.status='failed';$report.error=$_.Exception.Message
 throw
}finally{
 $env:APPDATA=$priorRoaming;$env:LOCALAPPDATA=$priorLocal
 $report|ConvertTo-Json -Depth 15|Set-Content "$root/report.json"
 if(Test-Path "$root/ACTIVE-HUMAN-REVIEW.json"){Move-Item -LiteralPath "$root/ACTIVE-HUMAN-REVIEW.json" -Destination "$root/CLOSED-HUMAN-REVIEW.json"}
}
Complete-ReviewArtifacts -Root $root -OwnedChild $child
Write-Output "Focused preview passed ($($result.count) checks). Evidence: $root"
