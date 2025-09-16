Set-StrictMode -Version 3.0

# Helper variables to make it easier to work with the module
$PSModule = $ExecutionContext.SessionState.Module

# determine which net framework to use.  pwsh 7.2+ -> net6
$dllRelativePath = Join-Path "net6" "Olo.Localdev.dll"
$binaryModule = Join-Path $PSModule.ModuleBase "bin" -AdditionalChildPath $dllRelativePath |
    Import-Module -PassThru

# When the module is unloaded, remove the nested binary module that was loaded with it
$PSModule.OnRemove = {
    Remove-Module -ModuleInfo $binaryModule
}
