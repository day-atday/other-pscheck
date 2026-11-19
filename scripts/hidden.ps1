<# 
.SYNOPSIS
    CHECKS FOR HIDDEN FOLDERS
.DESCRIPTION
    FOR DEFAULT IT SEARCHES ON AppData\Roaming AND AppData\Local\Temp
    TO SPECIFY A DIFFERENT PATH MUST USE THE -path ARGUMENT
.LINK
    --
.EXAMPLE
     ./pscheck.ps1 -hidden // ./pscheck.ps1 -hidden -path "C:\Example\Example"
.NOTES
#>
param(
    [string]$path
)

# CHECKS FOR HIDDEN FOLDERS AND FILES ONCE

Import-Module (Join-Path $PSScriptRoot ".\mod.psm1")

$username = $env:username

$dir_list = @('AppData\Roaming','AppData\Local\Temp')

function SearchHidden {

    Write-Log '[H] SearchHidden started'

    foreach($folder in $dir_list){

        $directory = Join-Path -Path "C:Users\$username" "$folder"
 
    if($path -eq ''){
        $hidden = Get-ChildItem $directory -Hidden -ErrorAction SilentlyContinue

        Write-Log "[H] -- Checking $folder"
        Write-Host "[H] Checking $folder" -ForegroundColor Yellow
        }
        
    else{
        $hidden = Get-ChildItem $path -Hidden -ErrorAction SilentlyContinue
        Write-Log "[H] -- Checking $path"
        Write-Host "[H] Checking $path" -ForegroundColor Yellow
    }
    
    foreach($item in $hidden){
        Write-Log "[H] -- HIDDEN ITEM $($item.Name) {DIR: $($item.Directory)}"
        Write-Host "[H] HIDDEN ITEM $($item.Name) {DIR: $($item.Directory)}" -ForegroundColor Green
    }

    }

}

SearchHidden
