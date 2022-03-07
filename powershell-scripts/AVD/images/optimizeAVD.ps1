# Author        : Angelo Miranda
# Creation Date : 03-07-2022
# Purpose       : Install OS Optimizations for WVD image (made for Azure Image Builder)

Write-Host 'AIB Customization: Starting OS Optimizations for WVD'

#Set Variables
$optimizeDirectoryPath     = 'C:\Optimize'
$osOptimizationDownloadURI = 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip'
$osOptimizationFileName    = 'Virtual-Desktop-Optimization-Tool-main'

#Create optimize directory
Write-Host "AIB Customization: Creating directory: "$optimizeDirectoryPath
New-Item $optimizeDirectoryPath -ItemType Directory -ErrorAction SilentlyContinue
Set-Location $optimizeDirectoryPath
Write-Host "AIB Customization: Directory created: "$optimizeDirectoryPath

#Download OS optimization files
Write-Host "AIB Customization: Downloading OS optimization files to "$optimizeDirectoryPath
Invoke-WebRequest -Uri $osOptimizationDownloadURI -OutFile "$optimizeDirectoryPath\$osOptimizationFileName.zip"
Write-Host "AIB Customization: OS optimization files downloaded: "$optimizeDirectoryPath"\"$osOptimizationFileName".zip"

#Extract OS optimization files
Write-Host "AIB Customization: Extracting files from "$osOptimizationFileName".zip to "$optimizeDirectoryPath
Unblock-File -LiteralPath "$optimizeDirectoryPath\$osOptimizationFileName.zip"
Expand-Archive `
    -LiteralPath "$optimizeDirectoryPath\$osOptimizationFileName.zip" `
    -DestinationPath $optimizeDirectoryPath `
    -Force `
    -Verbose
Set-Location -LiteralPath "$optimizeDirectoryPath\$osOptimizationFileName"
Write-Host "AIB Customization: Extracting files from "$osOptimizationFileName".zip to "$optimizeDirectoryPath

# Execute script
Write-Host 'AIB Customization: Executing OS Optimizations script'
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\Windows_VDOT.ps1 -AcceptEULA -Verbose
Write-Host 'AIB Customization: Finished OS Optimizations script' 