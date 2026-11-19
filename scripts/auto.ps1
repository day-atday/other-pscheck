<# 
.SYNOPSIS
    STARTS MOST OF THE SCRIPTS

    AT THE END PROCESS.PS1 ITS OPENED IN A DIFFERENT WINDOW 
    NETWORK OPENS AND SEARCHES NEW ACTIVE CONNECTIONS

.DESCRIPTION
    --
.LINK
    https://www.learningtree.com/blog/powershell-console-one-touch-menus/
.EXAMPLE
    ./network.ps1
.NOTES
#>


Import-Module (Join-Path $PSScriptRoot "..\scripts\mod.psm1")

# EXECUTING SCRIPTS
#Write-Host -ForegroundColor Yellow "Starting scripts"

# STARTING WINDOWS IF STARTED W/ ADMIN PRIVILEGES
if(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    ../windows/windows.ps1
}

../scripts/services.ps1 

Start-Sleep 0.7

../scripts/hidden.ps1 

Start-Sleep 0.8

../scripts/execution.ps1 

Start-Sleep 0.9

../scripts/firewall.ps1 

Start-Sleep 0.7   

Start-Process powershell.exe -ArgumentList "-executionpolicy bypass -file ../scripts/process.ps1"

Start-Sleep 1.2   

../scripts/network.ps1

