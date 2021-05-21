<##################################################################################################

    Created:  By Randy Bordeaux
    Date Created:  5/20/2021
    Date Modified: 
    Description: Install the MMA agents on remote servers for an Azure migration or log collection
    This only works on windows based computers, and needs to be run as admin from an account that 
    has admin to the remote computer.

##################################################################################################>

<# Agent Download files  
Download Windows Agent (64 bit)     https://go.microsoft.com/fwlink/?LinkId=828603 Download Windows Agent (64 bit)
Download Windows Agent (32 bit)     https://go.microsoft.com/fwlink/?LinkId=828604
#>

<# Error handling #>
$error.Clear()
$ErrorActionPreference = 'silentlycontinue'

<# Variables #> 
$RemoteServer  = 'SERVERNAME' # name of remote server 
$WorkspaceId   = '11111111-1111-1111-1111-111111111111' # enter your workspace ID for the log analytics workspace
$WorkspaceKey  = '111111111111111111111111111111111111111111111111111111111111' # enter your workspace key 

<# Check for the existence of C:\temp\MMASetup first and if it doesn't exist then create it #>
$Path = Test-Path -Path "\\$RemoteServer\c$\temp\mmasetup"
    if ( $Path -eq $false ) { 
        Invoke-Command `
        -Session $Session `
        -ScriptBlock {New-Item -ItemType Directory -Path c:\temp\mmasetup 
        } 
    }

<# Create a PSSession to the RemoteServer #>
$Session = New-PSSession -ComputerName $RemoteServer

<# Copy the agent from where we are executing the script to the target server #> 
$LocalFile = "C:\Temp\MMASetup\MMA_installer.exe"
Copy-Item `
    -Path $LocalFile `
    -Destination "\\$RemoteServer\c$\temp\MMASetup\MMA_installer.exe"

# Unpack files 
Invoke-Command -Session $Session {Start-Process -FilePath C:\temp\mmasetup\MMA_installer.exe -ArgumentList '/c /t:c:\temp\mmasetup'}

# Install agent 
Invoke-Command -Session $Session {Start-Process -FilePath c:\temp\mmasetup\setup.exe -ArgumentList '/qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 AcceptEndUserLicenseAgreement=1'}


<# Configure the Microsoft Monitoring Agent with the Log Analytics workspace information #>
Invoke-Command `
    -Session $Session `
    -ScriptBlock {    
        $Mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
        $AddWorkspace = $Mma.AddCloudWorkspace($Using:WorkspaceId, $Using:WorkspaceKey)
        $AddWorkspace
        $ReloadConfig = $Mma.ReloadConfiguration()
        $ReloadConfig
    }

<# Create log file #> 
$Error | out-file c:\temp\mmasetup\install_log.txt



