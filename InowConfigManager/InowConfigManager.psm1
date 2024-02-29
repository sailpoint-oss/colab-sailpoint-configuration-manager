#
# IdentityNow Git
# Use this utility to download the configuration using SP_config API and store them in a git
# Version: 1.0.0
#

#region Import functions

# define the following classes in PowerShell
try {
    Add-Type -AssemblyName System.Web -ErrorAction Ignore | Out-Null
    Add-Type -AssemblyName System.Net -ErrorAction Ignore | Out-Null
} catch {
    Write-Verbose $_
}

# set $ErrorActionPreference to 'Stop' globally
$ErrorActionPreference = 'Stop'

# store the API client's configuration
$Script:InowConfig = [System.Collections.HashTable]@{}

$Script:CmdletBindingParameters = @('Verbose','Debug','ErrorAction','WarningAction','InformationAction','ErrorVariable','WarningVariable','InformationVariable','OutVariable','OutBuffer','PipelineVariable')

. $PSScriptRoot\ExportSpConfig.ps1

. $PSScriptRoot\InowConfiguration.ps1

. $PsScriptRoot\ExecuteGitCommands.ps1
#endregion
