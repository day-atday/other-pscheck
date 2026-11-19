<# 
.SYNOPSIS
    SCANS VARIOUS WINDOWS FUNCTIONS
.DESCRIPTION
    CHECKS FOR EXCLUSIONS IN WINDOWS DEFENDER
    LOOKS FOR ITEMS IN THE REGISTRY ON RUNONCE AND RUN
    EASY TO ADD NEW REGISTRY LOCATIONS IN SearchReg

    IT ONLY READS, DOESN'T MAKE ANY CHANGE!
.LINK
    --
.EXAMPLE
    ./pscheck.ps1 -windows // ./windows.ps1 // Through launcher.bat (prompts the UAC)
    If used through the terminal, it needs Admin privileges.
.NOTES
#>

Import-Module (Join-Path $PSScriptRoot ".\mod.psm1")

If (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
    Write-Warning 'Requires Administrator privileges to run'
    exit 1
}

function SearchDef{

    Write-Log "[W] Search Defender exclusions started"

    $exc_list = Get-MpPreference | Select-Object -Property ExclusionPath | Select-Object -ExpandProperty ExclusionPath

    foreach($exclusion in $exc_list){
        Write-Log "[W] -- $exclusion"
        Write-Host "[WinDefender exclusion] $exclusion" -ForegroundColor Red
    }
    if( -not $exclusion){
        Write-Host "No exclusions detected in Windows Defender" -ForegroundColor Green
        Write-Log "[W] -- No exclusions detected in Windows Defender"
    }
}

function SearchReg {

    Write-Log "[W] SearchReg started "

    $regs = @{
    r = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run"
    ro = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    r_u = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
    ro_u = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    }
    
    foreach($n in $regs.Values){

        $registry_item = @()

        $comm = Get-ItemProperty -Path Registry::$n

        $registry_item += $comm -split ";"
 
        Write-host "`n$n" -ForegroundColor Green
        Write-Log "[W] -- $n"
        
        foreach($item in $registry_item){

            Write-Host $item -ForegroundColor Yellow
            Write-Log "[W] [R] -- $item"

        }

    }

}

SearchDef
SearchReg
