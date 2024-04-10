#
# Build file to prepare the module
#

function Get-FunctionsToExport {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        $Path
    )

    Process {
        $Token = $null
        $ParserErr = $null

        $Ast = [System.Management.Automation.Language.Parser]::ParseFile(
            $Path,
            [ref]$Token,
            [ref]$ParserErr
        )

        if ($ParserErr) {
            throw $ParserErr
        } else {
            foreach ($name in 'Begin', 'Process', 'End') {
                foreach ($Statement in $Ast."${name}Block".Statements) {
                    if (
                        [String]::IsNullOrWhiteSpace($Statement.Name) -or
                        $Statement.Extent.ToString() -notmatch
                        ('function\W+{0}' -f $Statement.Name)
                    ) {
                        continue
                    }

                    $Statement.Name
                }
            }
        }
    }
}

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$FunctionPath = "$PSScriptRoot" | ForEach-Object {$_}

$Manifest = @{
    Path = "$ScriptDir\SailpointConfigManager.psd1"

    Author = 'Raghunath Anne'
    CompanyName = 'SailPoint Developer Community'
    Description = 'SailpointConfigManager - the PowerShell module for IdentityNow'

    ModuleVersion = '1.0.0'

    RootModule = 'SailpointConfigManager.psm1'
    Guid = '31c323c5-4a04-4703-8b3b-4d3daa44b7d2' # Has to be static, otherwise each new build will be considered different module

    PowerShellVersion = '6.2'

    FunctionsToExport = $FunctionPath | Get-ChildItem -Filter *.ps1 | Get-FunctionsToExport

    VariablesToExport = @()
    AliasesToExport = @()
    CmdletsToExport = @()

}

New-ModuleManifest @Manifest

#Get-ChildItem $targetPath | Compress-Archive -DestinationPath "$targetPath.zip"
