# Author        : Angelo Miranda
# Creation Date : 03-07-2022
# Purpose       : Install FsLogix (made for Azure Image Builder)

#Set Variables
$softwareDirectoryPath = "C:\Software"
$FSLogixDownloadURI    = 'https://aka.ms/fslogix_download'
$FSLogixInstallerName  = "FSLogix_Apps"

#Create software directory
Write-Host "AIB Customization: Creating directory: "$softwareDirectoryPath
New-Item $softwareDirectoryPath -ItemType Directory -ErrorAction SilentlyContinue
Write-Host "AIB Customization: Directory created: "$softwareDirectoryPath

#Download FSLogix
Write-Host "AIB Customization: Downloading FSLogix installer to "$softwareDirectoryPath
Invoke-WebRequest -Uri $FSLogixDownloadURI -OutFile "$softwareDirectoryPath\$FSLogixInstallerName.zip"
Write-Host "AIB Customization: FSLogix installer downloaded: "$softwareDirectoryPath"\"$FSLogixInstallerName".zip"

#Extract FSLogix files
Write-Host "AIB Customization: Extracting files from "$FSLogixInstallerName".zip to "$softwareDirectoryPath"\"$FSLogixInstallerName
Expand-Archive `
    -LiteralPath "$softwareDirectoryPath\$FSLogixInstallerName.zip" `
    -DestinationPath "$softwareDirectoryPath\$FSLogixInstallerName" `
    -Force `
    -Verbose
Write-Host "AIB Customization: Extracted files from "$FSLogixInstallerName".zip to "$softwareDirectoryPath"\"$FSLogixInstallerName 

#Install FSLogix
Write-Host "AIB Customization: Installing FSLogix"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-Location "$softwareDirectoryPath\$FSLogixInstallerName" 
$install_status = Start-Process `
    -FilePath "$softwareDirectoryPath\$FSLogixInstallerName\x64\Release\FSLogixAppsSetup.exe" `
    -ArgumentList "/install /quiet" `
    -Wait `
    -Passthru `
    -Verbose
Write-Host "AIB Customization: FSLogix installation process completed"