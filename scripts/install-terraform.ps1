<#
<#
install-terraform.ps1

Robust installer script for Terraform on Windows.

Features:
- Relaunches elevated if not run as Administrator.
- Attempts to fix common Chocolatey permission problems.
- Installs Terraform using `winget` if available, otherwise `choco`.
- If neither package manager is available, prints manual-install instructions.

Run from an elevated PowerShell (or allow the script to re-launch elevated).
Usage:
  PS> .\scripts\install-terraform.ps1
#>

function Test-IsElevated {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$scriptPath = $MyInvocation.MyCommand.Path
if (-not (Test-IsElevated)) {
    Write-Host 'Not running as Administrator — re-launching elevated...' -ForegroundColor Yellow
    Start-Process -FilePath (Get-Command powershell).Source -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath) -Verb RunAs
    exit 0
}

Write-Host 'Running as Administrator. Fixing Chocolatey permissions (if necessary)...' -ForegroundColor Green

$chocoData = 'C:\ProgramData\chocolatey'
if (Test-Path $chocoData) {
    try {
        Write-Host "Taking ownership of $chocoData..."
        & takeown /f $chocoData /r /d y | Out-Null
        Write-Host "Granting Administrators full control to $chocoData..."
        & icacls $chocoData /grant Administrators:(F) /t | Out-Null
        Write-Host "Permissions fixed on $chocoData (if issues existed)." -ForegroundColor Green
    }
    catch {
        Write-Warning ("Failed to adjust permissions on {0}: {1}" -f $chocoData, $_.Exception.Message)
    }
}
else {
    Write-Host "$chocoData does not exist; skipping permission fix." -ForegroundColor Yellow
}

Write-Host 'Checking for winget...' -NoNewline
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host ' found.' -ForegroundColor Green
    Write-Host 'Installing Terraform with winget...' -ForegroundColor Cyan
    winget install --id HashiCorp.Terraform -e --source winget
    if ($LASTEXITCODE -eq 0) { Write-Host 'winget install completed.' -ForegroundColor Green } else { Write-Warning ("winget install returned exit code {0}" -f $LASTEXITCODE) }
}
elseif (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host 'winget not found; using Chocolatey (choco) to install Terraform...' -ForegroundColor Yellow
    choco install terraform -y
    if ($LASTEXITCODE -eq 0) { Write-Host 'choco install completed.' -ForegroundColor Green } else { Write-Warning ("choco install returned exit code {0}" -f $LASTEXITCODE) }
}
else {
    Write-Host 'Neither winget nor choco found. Offering manual-install guidance.' -ForegroundColor Yellow
    Write-Host 'Please download Terraform from https://releases.hashicorp.com/terraform/ and extract terraform.exe to a folder on your PATH (e.g., C:\tools\terraform).' -ForegroundColor Cyan
    Write-Host "Example commands to create folder and add to user PATH:" -ForegroundColor Gray
    Write-Host "  New-Item -ItemType Directory -Path 'C:\tools\terraform' -Force" -ForegroundColor Gray
    Write-Host "  [Environment]::SetEnvironmentVariable('PATH', ([Environment]::GetEnvironmentVariable('PATH','User') + ';C:\tools\terraform'), 'User')" -ForegroundColor Gray
    exit 2
}

Write-Host 'Installation attempted. Close and re-open PowerShell to refresh PATH.' -ForegroundColor Cyan
Write-Host 'Verify by running: terraform -v' -ForegroundColor Cyan
install-terraform.ps1
