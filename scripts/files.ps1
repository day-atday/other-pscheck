<# 
.SYNOPSIS
    SCANS FOR NEW FOLDERS
.DESCRIPTION
    BY DEFAULT IT SCANS TEMP
    TO CHOOSE A DIFFERENT PATH USE -path ARGUMENT
.LINK
    --
.EXAMPLE
    ./pscheck.ps1 -file // ./pscheck.ps1 -file -path "C:\Example\Example" // ./pscheck.ps1 -file -path (sys32|temp)
.NOTES
#>

param(
    [string]$path,
    [int]$sleep_time
)

# CHECKS FOR NEW FILES IN A FOLDER 

$sus_hash = Get-Content (Join-Path $PSScriptRoot "..\lists\sus_hash.txt")

Import-Module (Join-Path $PSScriptRoot ".\mod.psm1")

function FileSearch {

    Write-Host -ForegroundColor Yellow "[Sleep-Time] $sleep_time seconds"
    Write-Host -ForegroundColor Green 'CTRL+C to exit'

    $seen = @{}

    if($path -eq 'sys32'){
        $path = "C:\Windows\System32"
    }

    elseif($path -eq 'temp' -or $path -eq '' ){
        $path = Join-Path $env:LOCALAPPDATA "Temp"
    }

    Write-Log "[F] Searching $path"

    Get-ChildItem -Recurse $path -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName | ForEach-Object { $seen[$_] = $null }

    Write-Host "Reading $path"

    while($true){

        $current = Get-ChildItem -Recurse $path -File -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

        Start-Sleep $sleep_time

        $newFiles = $current | Where-Object { -not $seen.ContainsKey($_) }

        if($newFiles){

            foreach($file in $newFiles){

                $seen[$file] = $null

                $hash = Get-FileHash $file

                Write-Host "[!!!] NEW FILE $file" -ForegroundColor Yellow
                Write-Host "[HASH] $($hash.Hash)" -ForegroundColor Green

                Write-Log "[F] -- NEW FILE $file {HASH:$($hash.Hash)}"

                if($sus_hash.Contains($hash.Hash)){
                    Write-Host "[!!!] HASH FOUND"
                    Write-Log "[F] -- FILE HASH IS IN LIST $file"
                }

                if($file -match '\.exe$'){

                    Write-Host "[I] EXECUTABLE FOUND... $($file)" -ForegroundColor Yellow
                    Write-Log "[F] -- [I] EXECUTABLE FOUND... $($file)"
                }

                elseif($file -match '\.(ps1|bat|cmd|vbs|js|jse|hta|wsf|wsh|py|psm1|vbe|sct)$'){
                    
                    Write-Host "[I] SCRIPT FOUND $file" -ForegroundColor Red
                    Write-Log "[F] -- Script Found [Path] $file"

                    }

                }
            
            }
        }
        

        
}


FileSearch -Path $path
