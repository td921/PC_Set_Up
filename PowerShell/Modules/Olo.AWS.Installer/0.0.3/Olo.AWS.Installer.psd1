@{
    RootModule           = 'Olo.AWS.Installer.psm1'
    ModuleVersion        = '0.0.3'
    CompatiblePSEditions = @('Core')
    GUID                 = 'baacc6a1-e1b9-44a9-ae3b-bcf15af06a1c'
    Author               = 'Local Developer Experience'
    CompanyName          = 'Olo'
    Copyright            = '(c) Olo. All rights reserved.'
    Description          = 'Facilitates AWS Tools module installation'
    PowerShellVersion    = '7.0'
    FunctionsToExport    = @(
        'Initialize-AWSModule'
    )
    CmdletsToExport      = @()
    AliasesToExport      = @()
}
