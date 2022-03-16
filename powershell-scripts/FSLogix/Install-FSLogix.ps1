# Author        : Angelo Miranda (CloudPoints Consulting Pte Ltd)
# Creation Date : 10-03-2022
# Updated       : 15-03-2022
# Purpose       : Install and Configure FsLogix (via Intune Script Deployment)

#Set Variables
#FSLogix installation variables
$softwareDirectoryPath = "C:\Software"
$FSLogixDownloadURI    = 'https://aka.ms/fslogix_download'
$FSLogixInstallerName  = "FSLogix_Apps"
$FSLogixDisplayName    = "Microsoft FSLogix Apps"

#Kerberos registry setting variables
$regsetting_kerberos_CloudKerberosTicketRetrievalEnabled = "1"

#FSLogix Profiles registry setting variables
<<<<<<< HEAD
$regsetting_profiles_VHDLocations                         = "\\<storageaccountname>.file.core.windows.net\<file-share-name>"
=======
$regsetting_profiles_VHDLocations                         = "\\<storageaccountname>.file.core.windows.net\<file-share-name"
>>>>>>> c62cebea4767d3769924cc1efbb01428395a9808
$regsetting_profiles_ProfileType                          = "3"
$regsetting_profiles_Enabled                              = "1"
$regsetting_profiles_IsDynamic                            = "1"
$regsetting_profiles_DeleteLocalProfileWhenVHDShouldApply = "1"
$regsetting_profiles_FlipFlopProfileDirectoryName         = "1"
$regsetting_profiles_VolumeType                           = "VHDX"

#FSLogix O365 registry setting variables
$regsetting_ODFC_VHDLocations                  = "\\<storageaccountname>.file.core.windows.net\<file-share-name>"
$regsetting_ODFC_NumSessionVHDsToKeep          = "3"
$regsetting_ODFC_VolumeType                    = "VHDX"
$regsetting_ODFC_IncludeSharepoint             = "1"
$regsetting_ODFC_Enabled                       = "1"
$regsetting_ODFC_VHDAccessMode                 = "3"
$regsetting_ODFC_IncludeOutlookPersonalization = "1"
$regsetting_ODFC_IsDynamic                     = "1"
$regsetting_ODFC_IncludeOneNote                = "1"
$regsetting_ODFC_IncludeTeams                  = "1"
$regsetting_ODFC_IncludeOfficeActivation       = "1"
$regsetting_ODFC_IncludeOutlook                = "1"
$regsetting_ODFC_IncludeOneDrive               = "1"
$regsetting_ODFC_FlipFlopProfileDirectoryName  = "1"

#FSLogix installation process
#Check if FSLogix is already installed
$isInstalled = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | where {$_.DisplayName -eq $FSLogixDisplayName}) -ne $null

if(-Not $isInstalled) {

    #Create software directory
    Write-Host "Creating directory: "$softwareDirectoryPath
    New-Item $softwareDirectoryPath -ItemType Directory -ErrorAction SilentlyContinue
    Write-Host "Directory created: "$softwareDirectoryPath

    #Download FSLogix
    Write-Host "Downloading FSLogix installer to "$softwareDirectoryPath
    Invoke-WebRequest -Uri $FSLogixDownloadURI -OutFile "$softwareDirectoryPath\$FSLogixInstallerName.zip"
    Write-Host "FSLogix installer downloaded: "$softwareDirectoryPath"\"$FSLogixInstallerName".zip"

    #Extract FSLogix files
    Write-Host "Extracting files from "$FSLogixInstallerName".zip to "$softwareDirectoryPath"\"$FSLogixInstallerName
    Expand-Archive `
        -LiteralPath "$softwareDirectoryPath\$FSLogixInstallerName.zip" `
        -DestinationPath "$softwareDirectoryPath\$FSLogixInstallerName" `
        -Force `
        -Verbose
    Write-Host "Extracted files from "$FSLogixInstallerName".zip to "$softwareDirectoryPath"\"$FSLogixInstallerName 

    #Install FSLogix
    Write-Host "Installing FSLogix"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Set-Location "$softwareDirectoryPath\$FSLogixInstallerName" 
    Start-Process `
        -FilePath "$softwareDirectoryPath\$FSLogixInstallerName\x64\Release\FSLogixAppsSetup.exe" `
        -ArgumentList "/install /quiet" `
        -Wait `
        -Passthru `
        -Verbose
    Write-Host "FSLogix installation process completed"

}
else {
    Write-Host "FSLogix already installed; script will continue to configure FSLogix settings.`r`n"
}

#FSLogix configuration process (via registry)
Write-Host "Configuring Kerberos settings"
Push-Location HKLM:\SYSTEM

#Enable Kerberos ticket retrieval
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters -Name "CloudKerberosTicketRetrievalEnabled" -Type DWord -Value $regsetting_kerberos_CloudKerberosTicketRetrievalEnabled

Pop-Location

Write-Host "Configuring FSLogix settings"
Push-Location HKLM:\SOFTWARE

#Configure FSLogix Profile Container settings
New-Item -Path HKLM:\SOFTWARE\FSLogix -Name "Profiles" -Force

Set-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles -Name "VHDLocations" -Type String -Value $regsetting_profiles_VHDLocations
Set-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles -Name "ProfileType" -Type DWord -Value $regsetting_profiles_ProfileType
Set-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles -Name "Enabled" -Type DWord -Value $regsetting_profiles_Enabled
Set-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles -Name "IsDynamic" -Type DWord -Value $regsetting_profiles_IsDynamic
Set-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles -Name "DeleteLocalProfileWhenVHDShouldApply" -Type DWord -Value $regsetting_profiles_DeleteLocalProfileWhenVHDShouldApply
Set-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles -Name "FlipFlopProfileDirectoryName" -Type DWord -Value $regsetting_profiles_FlipFlopProfileDirectoryName
Set-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles -Name "VolumeType" -Type String -Value $regsetting_profiles_VolumeType

#Configure FSLogix Office Container settings
New-Item -Path HKLM:\SOFTWARE\Policies -Name "FSLogix" -Force
New-Item -Path HKLM:\SOFTWARE\Policies\FSLogix -Name "ODFC" -Force

Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "VHDLocations" -Type String -Value $regsetting_ODFC_VHDLocations
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "NumSessionVHDsToKeep" -Type DWord -Value $regsetting_ODFC_NumSessionVHDsToKeep
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "VolumeType" -Type String -Value $regsetting_ODFC_VolumeType
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "IncludeSharepoint" -Type DWord -Value $regsetting_ODFC_IncludeSharepoint
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "Enabled" -Type DWord -Value $regsetting_ODFC_Enabled
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "VHDAccessMode" -Type DWord -Value $regsetting_ODFC_VHDAccessMode
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "IncludeOutlookPersonalization" -Type DWord -Value $regsetting_ODFC_IncludeOutlookPersonalization
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "IsDynamic" -Type DWord -Value $regsetting_ODFC_IsDynamic
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "IncludeOneNote" -Type DWord -Value $regsetting_ODFC_IncludeOneNote
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "IncludeTeams" -Type DWord -Value $regsetting_ODFC_IncludeTeams
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "IncludeOfficeActivation" -Type DWord -Value $regsetting_ODFC_IncludeOfficeActivation
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "IncludeOutlook" -Type DWord -Value $regsetting_ODFC_IncludeOutlook
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "IncludeOneDrive" -Type DWord -Value $regsetting_ODFC_IncludeOneDrive
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\FSLogix\ODFC -Name "FlipFlopProfileDirectoryName" -Type DWord -Value $regsetting_ODFC_FlipFlopProfileDirectoryName

Pop-Location

#END
Write-Host "FSLogix settings applied"