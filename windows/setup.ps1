# admin excecution
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
}

# check if winget is installed
if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe){
    'Winget Already Installed'
}  
else{
    # installing winget from the Microsoft Store
	Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
	$nid = (Get-Process AppInstaller).Id
	Wait-Process -Id $nid
}

# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# install packages
winget import --accept-package-agreements --accept-source-agreements --ignore-versions --import-file .\software\winget_packages.json
choco install .\software\chocolatey_packages.config  --accept-license --confirm

# setup wsl
wsl --set-default-version 2
wsl --update
Clear-Host
(New-Object System.Net.WebClient).DownloadFile("https://github.com/nullpo-head/wsl-distrod/releases/latest/download/distrod_wsl_launcher-x86_64.zip","$env:APPDATA\distrod.zip")
Expand-Archive -Force -LiteralPath "$env:APPDATA\distrod.zip" -DestinationPath "$env:APPDATA\distrod"
Start-Process ("$env:APPDATA\distrod\distrod_wsl_launcher-x86_64\distrod_wsl_launcher.exe")