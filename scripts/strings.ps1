<# 
.SYNOPSIS
    LIKE SYSINTERNALS STRINGS  
.DESCRIPTION
    CHECKS FOR STRINGS IN ANY FILE
.LINK
    --
.EXAMPLE
     ./pscheck.ps1 -strings
.NOTES
#>

param(
    [string]$path=''
)

Import-Module (Join-Path $PSScriptRoot ".\mod.psm1")

# Checks for strings in any file

function strings{
   
    if ($path -ne ''){

        $filename = Split-Path $path -Leaf

        Write-Host "[Strings] Reading file $path" -ForegroundColor Green
        Write-Host "[Strings] output = /log/strings_$filename.log" -ForegroundColor Yellow

        $get_file_strings = Get-Content -Encoding Ascii $path 
        
        [regex]::split($get_file_strings,'\W') | Where-Object {$_ -ne '' } | Out-File (Join-Path $PSScriptRoot "..\logs\strings_$filename.log")
        
        }

    else{
        Write-Warning "Invalid path"
    }
    
    }

strings