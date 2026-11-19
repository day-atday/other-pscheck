# MODULE FOR WRITING THE LOGS

$modulePath = if ($PSScriptRoot) {
    $PSScriptRoot
}

else {
    Split-Path -Parent $MyInvocation.MyCommand.Path
}

$fileday = Get-Date -Format "dd-MM-yyyy"

$script:logFile = Join-Path $modulePath "..\logs\exec_$fileday.log"

$logDir = Split-Path $script:logFile

if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

<#
.LINK
Write-Log > https://adamtheautomator.com/powershell-log-function/
#>

function Write-Log {
    param (
        [string]$message=''
    )

    $timestamp = Get-date -Format "HH:mm:ss"
    $logMessage = "$timestamp -- $message"

    Add-Content -Path $logFile -Value $logMessage
}


