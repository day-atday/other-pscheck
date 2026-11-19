<# 
.SYNOPSIS
    SCANS THE NETWORK
.DESCRIPTION
    REWRITE
.LINK
    -fw parameter
.EXAMPLE
    ./network.ps1 // ./pscheck -network
.NOTES
#>

Import-Module (Join-Path $PSScriptRoot ".\mod.psm1")

function NetworkSearch {
    function formatlog {
        param(
            [Parameter(ValueFromPipeline)] $Connection,
            [string]$type
        )

        "< {0}:{1} To {2}:{3} Type [{4}] PID[{5}] ProcessName [{6}]>" -f `
            $Connection.LocalAddress,
            $Connection.LocalPort,
            $Connection.RemoteAddress,
            $Connection.RemotePort,
            $Connection.State,
            $Connection.OwningProcess,
            $Connection.ProcessName
    
    }
    function Get-TCPFiltered {
    
    param(
        [Parameter(Mandatory)]
        [string]$state
        # STATES:
        #   -Listen > Open ports, on listening mode
        #   -Established > Active connections
    )


    Get-NetTCPConnection  | Where-Object State -eq $State | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess,
        @{Name="ProcessName"; Expression={
            (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
        }
        }
    
    }
    
    Write-Log '[N] -- NetworkSearch started'

    # ACTIVE CONNECTIONS
    $internet = Get-TCPFiltered -state 'Established'
    # LISTENING CONNS
    $tcp_ports = Get-TCPFiltered -state 'Listen'

    # UDP ENDPOINTS
    $getnet_udp = @(Get-NetUDPEndpoint | Select-Object LocalAddress,LocalPort,OwningProcess,@{Name="ProcessName"; Expression={
    (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name}})


    Write-Host "`n[N] [TCP] Internet active connections" -ForegroundColor Yellow
    $internet | Format-Table

    Write-Host "`n[N] [TCP] Computer active ports" -ForegroundColor Yellow
    $tcp_ports | Format-Table

    Write-Host "`n[N] [UDP] UDP Ports ports" -ForegroundColor Yellow
    $getnet_udp | Format-Table


    $seenConnections = @{}

    foreach($item in $internet) {

        $key = "{0}:{1}:{2}" -f `
            $item.RemoteAddress,
            $item.LocalPort,
            $item.ProcessName

        $seenConnections[$key] = $true
    }


    foreach($item in $tcp_ports){
        $log = formatlog -Connection $item -type 'TCP'
        Write-Log "[N] [TCP] -- Computer open ports - $log"
    }

    foreach($item in $getnet_udp){
        $log = formatlog -Connection $item -type 'UDP'
        Write-log "[N] [UDP] UDP Endpoints -- $log"
    }

    $seenConnections = @{}

    while ($true) {
        
        $internet = Get-TCPFiltered -State 'Established'

        foreach ($item in $internet) {

            $key = "$($item.RemoteAddress):$($item.LocalPort):$($item.ProcessName)"

            if (-not $seenConnections.ContainsKey($key)) {

                $seenConnections[$key] = $true

                $log = formatlog -Connection $item -type 'TCP'
                Write-Log "[N] [TCP] [I] -- New Internet active connection - $log"
                Write-Host "[N] [TCP] [I] -- New Internet active connection - $log" -ForegroundColor Yellow

            }

        }

        Start-Sleep -Seconds 1
    }

}

NetworkSearch

