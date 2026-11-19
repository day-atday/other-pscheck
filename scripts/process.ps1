<# 
.SYNOPSIS
    SCANS NEW PROCESSES SINCE ITS EXECUTION
.DESCRIPTION
    --
.LINK
    --
.EXAMPLE
    ./pscheck.ps1 -process // ./pscheck.ps1 -process -sleep_time 5 
.NOTES
#>

param(
    [int]$sleep_time
)

# SUSPICIOUS PROCESSES NAMES
$sus_proc = Get-Content (Join-Path $PSScriptRoot "..\lists\sus_proc.txt")

# SUSPICIOUS HASH NAMES
$sus_hash = Get-Content (Join-Path $PSScriptRoot "..\lists\sus_hash.txt")


Import-Module (Join-Path $PSScriptRoot ".\mod.psm1")

Write-Host -ForegroundColor Yellow "[Sleep-Time] $sleep_time seconds"
Write-Host -ForegroundColor Green 'CTRL+C to exit'

function ProcessSnap{
   
    <#
    
    LOGS:

    CURRENT RUNNING PROCESSES

    COMMANDLINE START OF PROCESSES

    #>

    # COMMANDLINE START OF THE PROCESSES
    $proc_snap_comm = Get-WmiObject win32_process | Select-Object commandline

    # SNAP OF CURRENTLY RUNNING PROCESSES
    $proc_snap = Get-Process | Select-Object Name, Id

    foreach($proc in $proc_snap_comm.commandline){

        if($null -ne $proc){
            Write-Log "[P] [SNAP] [C]",$proc
        }

    }

    foreach($proc in $proc_snap){
        Write-Log "[P] [SNAP] [R]", $proc.Name , " [PID] ", $proc.Id
    }
}

function SearchProcess{

    $seen = @{}

    # ADDING PID AND PATH TO SEEN
    Get-Process | ForEach-Object{
        if ($_.Path) {
            $seen[$_.Id] = $_.Path
        }
    }

    Write-Host "[*] Monitoring new processes..." -ForegroundColor Yellow
    Write-Log "[P] -- SearchProcess started"

    while($true){

        $process_comm = Get-Process

        foreach ($process in $process_comm) {

            $process_path = $process.Path

            if([string]::IsNullOrWhiteSpace($process_path)) {
                continue
            }

            elseif($seen.ContainsKey($process.Id)){
                continue
            }

            # ADDING PROCESS PATH TO $SEEN[PROCESS ID] -> $SEEN == < PID = C:\XXX... >
            $seen[$process.Id] = $process_path

            $process_hash = Get-FileHash $process_path -Algorithm SHA256 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Hash

            Write-Host "[P] [NEW PROCESS] $($process.Name)" -ForegroundColor Green

            Write-Log "[P] [NEW] -- $($process.Name) -- $process_path"


            if($process_hash -and ($sus_hash -contains $process_hash)){

                Write-Host "[P] [!!!] SUSPICIOUS HASH`n" -ForegroundColor Red

                Write-Host "PROCESS: $process.Name`n[PATH: $process_path]`n{HASH: $process_hash}"

                Write-Log "[P] [!!!] -- HASH DETECTED IN LIST -- $process_hash"
            }


            if($sus_proc -contains $process.Name){

                Write-Host "[P] [!] SUSPICIOUS PROCESS NAME`n" -ForegroundColor Yellow

                Write-Host -ForegroundColor Red "PROCESS: $process.Name`n[PATH: $process_path]`n{HASH: $process_hash}"

                Write-Log "[P] [!] -- SUSPICIOUS PROCESS NAME -- $($process.Name)"
            }
        }

        Start-Sleep -Seconds $sleep_time
    }
}

ProcessSnap
SearchProcess

