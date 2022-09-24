# Author        : Angelo Miranda (CloudPoints Consulting Pte Ltd)
# Creation Date : 23-09-2022
# Updated       : 24-09-2022
# Purpose       : Install and Configure Universal Print Connector

$softwareDirectoryPath  = "C:\Software"
$UPConnectorDownloadURI = "https://aka.ms/UPConnector"
$UPConnectorInstallerName = "UniversalPrint"
$UPConnectorDisplayName = "Universal Print connector"

$isInstalled = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -eq $UPConnectorDisplayName}) -ne $null

If(-Not $isInstalled) {

    #Create software directory
    Write-Host "Creating directory: "$softwareDirectoryPath
    New-Item $softwareDirectoryPath -ItemType Directory -ErrorAction SilentlyContinue
    Write-Host "Directory created: "$softwareDirectoryPath

    #Download Universal Print Connector
    Write-Host "Downloading Universal Print Connector installer to "$softwareDirectoryPath
    Invoke-WebRequest -Uri $UPConnectorDownloadURI -OutFile "$softwareDirectoryPath\$UPConnectorInstallerName.exe"
    Write-Host "Universal Print Connector downloaded: "$softwareDirectoryPath

    #Add Windows Feature: .Net Framework
    If(-Not (Get-WindowsFeature -Name NET-Framework-45-Core).Installed) {
        Add-WindowsFeature -Name NET-Framework-45-Core
    }

    #Install Universal Print Connector
    Write-Host "Installing Universal Print Connector"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Set-Location "$softwareDirectoryPath"
    Start-Process `
        -FilePath "$softwareDirectoryPath\$UPConnectorInstallerName.exe" `
        -ArgumentList "/install /quiet" `
        -Wait `
        -Passthru `
        -Verbose
        Write-Host "Universal Print Connector installation process completed"
}

$isIESecurityEnabled = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Name IsInstalled

If($isIESecurityEnabled) {

    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Name IsInstalled -Value 0

    Stop-Process -Name explorer

}

Start-Process `
    -FilePath "C:\Program Files\PrintConnector\PrintConnectorApp.exe" `
    -Wait

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Name IsInstalled -Value 1

Stop-Process -Name explorer