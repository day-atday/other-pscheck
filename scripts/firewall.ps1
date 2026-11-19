<# 
.SYNOPSIS
    CHECKS THE FIREWALL CONFIGURATION
.DESCRIPTION
    --
.LINK
    --
.EXAMPLE
    ./network.ps1
.NOTES
#>

Import-Module (Join-Path $PSScriptRoot ".\mod.psm1")

function FirewallOut {
    
    # ENABLED ALLOW OUTBOUND RULES
    $firewall_allow_out = Get-NetFirewallRule | Select-Object Direction, Enabled, Name, Description, Action | Where-Object {$_.Direction -eq "Outbound" -and $_.Enabled -eq $true -and $_.Action -eq "Allow" }

    Write-Host "[N] [FW] Outbound firewall enabled rules"
    Write-Log "[N] [FW] Outbound firewall enabled rules"
    
    foreach($item in $firewall_allow_out){
        Write-host "[N] [FW] NAME:", $item.Name, $item.Description
        Write-Log "[N] [FW] NAME:", $item.Name, $item.Description
    }
    
}

FirewallOut