<#
.SYNOPSIS
Initializes an AWS Tools module or its equivalent

.DESCRIPTION
Unless AWSPowerShell(.NetCore) is already installed, this initializes an AWS Tools module

.PARAMETER Name
The AWS Tools Module name to initialize

.EXAMPLE
Initialize-AWSModule -Name Common

.EXAMPLE
Initialize-AWSModule -Name AWS.Tools.Common

#>
function Initialize-AWSModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $Name
    )
    begin {
        @('AWS.Tools.Installer') |
        ForEach-Object {
            if (-not (Get-InstalledModule -Name $_ -EA Ignore)) {
                Install-Module $_ -Scope CurrentUser -Repository PSGallery
            }
            Import-Module $_
        }
    }
    process {
        $FullName = $Name | ForEach-Object { $_ -like 'AWS.Tools.*' ? $_ : "AWS.Tools.$_" }
        $local:WarningPreference = 'Ignore'
        if ($FullName.Count -gt (Get-InstalledModule -Name $FullName -EA Ignore)?.Count) {
            Install-AWSToolsModule -Name $FullName -Scope CurrentUser -SkipPublisherCheck -AllowClobber
        }
        $local:ErrorActionPreference = 'Ignore'
        Import-Module $FullName -Global -Force
    }
}
