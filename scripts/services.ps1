<# 
.SYNOPSIS
    SCANS SERVICES OUT OF WINDOWS FOLDER
.DESCRIPTION
    CHECKS FOR NON WINDOWS SERVICES AND COMPARES THE
    HASH WITH THE ONES INSIDE THE LIST
.LINK
    --
.EXAMPLE
     ./pscheck.ps1 -services
.NOTES
#>


Import-Module (Join-Path $PSScriptRoot ".\mod.psm1")

# LISTA DE HASHES SOSPECHOSOS, EXTRAIDA DE GitHub
$sus_hash = @(Get-Content (Join-Path $PSScriptRoot "..\lists\sus_hash.txt"))

$sus_hash = Get-Content (Join-Path $PSScriptRoot "..\lists\sus_hash.txt")

function SearchService{

    Write-Log "[S] [I] SearchService started...."

    $service_comm = Get-WmiObject win32_service | Select-Object Name,PathName,StartMode,StartName | Where-Object {$_.PathName -notmatch "C:\\WINDOWS"} |
    Select-Object -ExpandProperty PathName

    foreach($path in $service_comm){

        $service_path = [regex]::Match($path, '"(.*?)"').Groups[1].Value
        $service_hash =  Get-FileHash $service_path | Select-Object hash, Path
        
        $certificate = Get-AuthenticodeSignature "$service_path" -ErrorAction SilentlyContinue |Select-Object -ExpandProperty Status

        if($service_hash.hash -and $sus_hash.Contains($service_hash.hash)){
            Write-Host "[!!!] SUSPICIOUS SERVICE HASH: $service_hash" -ForegroundColor Red
            Write-Log "[S] [!!!] SUSPICIOUS SERVICE HASH: $service_hash"
        }

        elseif($certificate -eq "Valid"){
            Write-Host "[S] $service_hash; [V] CERTIFICATE STATUS: $certificate" -ForegroundColor Green
        }
        elseif($certificate -eq "NotSigned"){
            Write-Host "[S] $service_hash; [X] CERTIFICATE STATUS: $certificate" -ForegroundColor Red
        }
        
        Write-Log "[S] $service_hash; CERTIFICATE STATUS: $certificate"

    }
}

SearchService
