
Import-Module (Join-Path $PSScriptRoot ".\mod.psm1")

$comm = @()

# Checks the PowerShell History, logs Files opened, downloads and file reads

function ExecutionSearch {

    $history = Get-Content "C:\Users\$env:username\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    
    foreach($item in $history){

        # FILES 
        if($item -match '^\.\\.*\.[A-Za-z0-9]+$'){
            $comm += "[E] [File_Opened] -- $item`n"
        }
        
        # DOWNLOADS
        elseif($item -match '^(curl|wget|Invoke-WebRequest|iwr|Start-BitsTransfer|bitsadmin|ftp|sftp|scp|aria2c|axel|fetch|lwp-download|powershell\s+Invoke-WebRequest|powershell\s+Start-BitsTransfer)\b.*'){
            $comm += "[E] [Download] -- $item`n"
        }

        # READING
        elseif ($item -match '^(type|Get-Content|gc|cat|more|less|bat|head|tail|nano|vim|vi|notepad|notepad\+\+|subl|open|start|powershell\s+Get-Content|cmd\s+type|cmd\s+more)\b.*') {
        $comm += "[E] [Read] -- $item`n"
        }

    }

    # OUTPUT
    Write-host $comm -ForegroundColor Yellow

    # LOGS
    Write-Log "[E] -- Execution Started"
    Write-Log "[E] TERMINAL FILE HISTORY`n$comm"


}

ExecutionSearch