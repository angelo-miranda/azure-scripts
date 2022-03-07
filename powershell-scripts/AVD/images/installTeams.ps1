# Author        : Angelo Miranda
# Creation Date : 03-07-2022
# Purpose       : Install Teams (made for Azure Image Builder)

#Set Variables
$softwareDirectoryPath        = "C:\Software\Teams"
$vcRedistDownloadURI          = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$TeamsWebSocketsDownloadURI   = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWQ1UW"
$TeamsDownloadURI             = "https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
$vcRedistInstallerName        = "VC_redist.x64.exe"
$TeamsWebSocketsInstallerName = "MsRdcWebRTCSvc.msi"
$TeamsInstallerName           = "Teams_windows_x64.msi"

#Set IsWVDEnvironment registry key
Write-Host 'AIB Customization: Setting IsWVDEnvironment registry key to 1'
New-Item -Path HKLM:\SOFTWARE\Microsoft -Name "Teams"
New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Teams -Name "IsWVDEnvironment" -Type "Dword" -Value "1"
Write-Host 'AIB Customization: Registry key configured'

#Install Teams pre-requisites
Write-Host "AIB Customization: Creating directory: "$softwareDirectoryPath
New-Item $softwareDirectoryPath -ItemType Directory -ErrorAction SilentlyContinue
Set-Location $softwareDirectoryPath
Write-Host "AIB Customization: Directory created: "$softwareDirectoryPath

#Download required software: vc_redist.x64
Write-Host "AIB Customization: Downloading "$vcRedistInstallerName" to "$softwareDirectoryPath
Invoke-WebRequest -Uri $vcRedistDownloadURI -OutFile "$softwareDirectoryPath\$vcRedistInstallerName"
Write-Host "AIB Customization: Downloaded: "$softwareDirectoryPath"\"$vcRedistInstallerName

#Download required software: Teams WebSocket Service
Write-Host "AIB Customization: Downloading Teams WebSocket Service installer to "$softwareDirectoryPath
Invoke-WebRequest -Uri $TeamsWebSocketsDownloadURI -OutFile "$softwareDirectoryPath\$TeamsWebSocketsInstallerName"
Write-Host "AIB Customization: Teams WebSocket Service installer downloaded: "$softwareDirectoryPath"\"$TeamsWebSocketsInstallerName

#Download required software: Teams
Write-Host "AIB Customization: Downloading Teams installer to "$softwareDirectoryPath
Invoke-WebRequest -Uri $TeamsDownloadURI -OutFile "$softwareDirectoryPath\$TeamsInstallerName"
Write-Host "AIB Customization: Teams installer downloaded: "$softwareDirectoryPath"\"$TeamsInstallerName

#Install vc_redist.x64
Write-Host "AIB Customization: Installing Microsoft Visual C++ Redistributable"
Start-Process `
    -FilePath "$softwareDirectoryPath\$vcRedistInstallerName" `
    -ArgumentList "/install /quiet /norestart" `
    -Wait `
    -Verbose
write-host "AIB Customization: Microsoft Visual C++ Redistributable installation process completed"

#Install Teams WebSocket Service
Write-Host 'AIB Customization: Install the Teams WebSocket Service'
Start-Process `
    -FilePath msiexec.exe `
    -ArgumentList "/i $softwareDirectoryPath\$TeamsWebSocketsInstallerName /quiet /norestart" `
    -Wait `
    -Verbose
Write-Host "AIB Customization: Finished Install the Teams WebSocket Service"

#Install Teams
Write-Host "AIB Customization: Install MS Teams"
Start-Process `
    -FilePath msiexec.exe `
    -ArgumentList "/i $softwareDirectoryPath\$TeamsInstallerName /quiet /norestart ALLUSER=1 ALLUSERS=1" `
    -Wait `
    -Verbose
Write-Host "AIB Customization: Finished Install MS Teams"