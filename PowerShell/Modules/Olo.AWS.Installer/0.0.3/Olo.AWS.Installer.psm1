Set-StrictMode -Version 3.0

$PSScriptRoot |
Get-ChildItem -Include public, private -Recurse |
Get-ChildItem -File -Filter *.ps1 -Recurse |
ForEach-Object {
    . $_.FullName
}
