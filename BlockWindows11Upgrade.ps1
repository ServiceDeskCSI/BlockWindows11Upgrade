# Ensure the script is run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator!" -ForegroundColor Red
    exit
}

# Registry keys to block Windows 11 upgrade
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
)

# Ensure registry paths exist
foreach ($path in $registryPaths) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
}

# Set registry values to block the upgrade
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name "TargetReleaseVersion" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name "TargetReleaseVersionInfo" -Value "22H2" -Type String
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" -Name "AllowOSUpgrade" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "DisableOSUpgrade" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ProductVersion" -Value "Windows 10" -Type String

# Block Windows 11 update in Group Policy (if available)
$policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
if (!(Test-Path $policyPath)) {
    New-Item -Path $policyPath -Force | Out-Null
}
Set-ItemProperty -Path $policyPath -Name "TargetReleaseVersion" -Value 1 -Type DWord
Set-ItemProperty -Path $policyPath -Name "TargetReleaseVersionInfo" -Value "22H2" -Type String

# Restart Windows Update Service
Write-Host "Restarting Windows Update Service..." -ForegroundColor Yellow
Restart-Service wuauserv -Force

Write-Host "Windows 11 upgrade has been blocked successfully!" -ForegroundColor Green
