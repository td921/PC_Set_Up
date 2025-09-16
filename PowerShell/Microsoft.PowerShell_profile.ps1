function Start-LocalDev {
    Start-Process -Verb RunAs pwsh -ArgumentList '-command pushd \code\configuration\localdev; git fetch origin; git checkout origin/main; .\olo-localdev.ps1 -start -transformConfigsOnly -dockerhost 10.211.55.2 -sqlserver 10.211.55.2; pause'
}

Set-Alias sld Start-LocalDev
function Rebase-Develop {git rebase origin/develop}
Set-Alias rd Rebase-Develop

function Rebase-Main {git rebase origin/main}
Set-Alias rm Rebase-Main

function Force-Push {git push --force}
Set-Alias fp Force-Push

function Normal-Push {git push}
Set-Alias np Normal-Push

function Cd-Platform {cd C:\code\platform}
Set-Alias cdp Cd-Platform

function Pull-Develop {git pull origin develop}
Set-Alias pd Pull-Develop

function Pull-Main {git pull origin main}
Set-Alias pm Pull-Main

function Update-Builder {dotnet tool update olo-builder --global}
Set-Alias ub Update-Builder

function Close-AllProcesses {
    Get-Process |Where-Object {$_.MainWindowTitle -ne "" -and $_.Id -ne $PID -and $_.ProcessName -ne "explorer"} | Stop-Process -Force
}

function Stop-AllContainers {
    docker stop $(docker ps -a -q)
}

Set-Alias sac Stop-AllContainers

function Remove-MergedBranches
{
  git branch --merged |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -NotMatch "^\*" } |
    Where-Object { -not ( $_ -Like "*master" -or $_ -Like "*main" -or $_ -Like "*develop" ) } |
    ForEach-Object { git branch -d $_ }
}

Set-Alias rmb Remove-MergedBranches

function letsdothis 
{
    Start-Process -FilePath "C:\Program Files\Slack\slack.exe"
    Start-Process "https://www.gmail.com"
    Start-Process "https://calendar.google.com/calendar/u/0/r"
    Start-Process "https://ololabs.atlassian.net/jira/your-work"
    Start-Process "https://oloprod.cloudflareaccess.com/cdn-cgi/access/refresh-identity"
    Start-Process "https://olo.login.duosecurity.com/central/"
    Start-Process "https://github.com/orgs/ololabs/sso?return_to=%2F"
    dotnet tool update olo-builder --global
}

function goodwork 
{
    docker stop $(docker ps -a -q)
    Stop-Process -Name "slack"
    Stop-Process -Name "firefox"
    Stop-Process -Name "rider64"
    Stop-Process -Name "dbeaver"
    Stop-Process -Name "explorer"
    Stop-Process -Name "Code"
    Stop-Process -Name "Docker Desktop"
    Stop-Process -Name "Postman"
    exit
}

Set-Alias cdp Cd-Platform

Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1

Set-Location C:\code\platform
Import-Module posh-git

function ConvertFrom-Base64() 
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$True,
        Position=0)]
        [string] $Base64
    )

    $PlainText =  [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($Base64));
    Write-Output $PlainText;
}

function ConvertTo-Base64() 
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$True,
        Position=0)]
        [string] $PlainText
    )

    $Base64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($PlainText))
    Write-Output $Base64
}

function Decrypt-Secret {
    Param
    (
         [Parameter(Mandatory=$true)]
         [string] $cipherText,
         [Parameter(Mandatory=$true)]
         [string] $awsProfile

    )
    aws kms decrypt --ciphertext-blob $cipherText --output text --query Plaintext --profile $awsProfile --region "us-east-1" | ConvertFrom-Base64
}

Set-Alias ds Decrypt-Secret

function Encrypt-Secret {
    Param
    (
        [Parameter(Mandatory=$true)]
        [string] $environment,
        [Parameter(Mandatory=$true)]
        [string] $plainText,
        [Parameter(Mandatory=$true)]
        [string] $awsProfile

    )
    aws kms encrypt --key-id "alias/consul/${environment}" --plaintext $plainText --output text --query CiphertextBlob --cli-binary-format raw-in-base64-out --profile $awsProfile
}

Set-Alias es Encrypt-Secret