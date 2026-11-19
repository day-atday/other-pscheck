param(
    [string]$path=""
)

Add-Type -AssemblyName System.Windows.Forms

if($PSVersionTable.PSVersion.Major -lt 7){

    Clear-Host

    Write-Output "Powershell version"
    $PSVersionTable.PSVersion, "`n"

    Write-Warning "
    It's recommended to use PowerShell 7 with this script.
    It would be way faster and consume less.

    pwsh.exe -file .\report.ps1
    "

    Write-Host 'Press any key to execute anyway'
    $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown') *> $null

    Clear-Host
}

 # CUSTOM DIR OPTION DIALOG
$custom_path = [System.Windows.Forms.MessageBox]::Show(
    "Custom path?",
    "Files path",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)

if ($custom_path -eq [System.Windows.Forms.DialogResult]::Yes) {   

    # CUSTOM DIR BROWSER DIALOG
    $directory = New-Object System.Windows.Forms.OpenFileDialog

    $directory.Filter = "Log files (*.log)|*.log"
    $directory.Multiselect = $false
    $directory.InitialDirectory = $PSScriptRoot


    if ($directory.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $log_path = $directory.FileName
    }
}

$date = Get-Date -Format "dd-MM-yyyy"

if($log_path -eq "" -or $null -eq $log_path){
    $log_path = Join-Path $PSScriptRoot "..\logs\exec_$($date).log"
}


$data = @{
    "p_snap_running_name" = @()
    "p_commandline" = @()
    "p_new" = @()
    "services" = @()
    "hidden" = @()
    "n_fw" = @()
    "n_tcp" = @()
    "n_udp" = @()
    "files" = @()
    "w_def" = @()
    "w_reg" = @()

}


# REGEX GROUPS
# GROUP 0 HAS THE HOUR
# GROUP 2 THE NAME

$regsearch = @{
    '(\S+)(?:.*?)\[R\]\s(\w+.*)' = "p_snap_running_name"
    '.*\[P\].*\[C\].*' = "p_commandline"
    '.*\[P\].*\[NEW\].*' = "p_new"
    '.*\[S\] @.*' = "services"
    '.*\[H\] --.*' = "hidden"
    '.*\[E\] \[.*\].*' = "exe"
    '.*\[N\] \[FW\].*' = "n_fw"
    '.*\[N\] \[TCP\] --.*' = "n_tcp"
    '.*\[N\] \[UDP\].*' = "n_udp"
    '.*\[N\].*\[I\].*' = "n_new"
    '.*\[F\] --.*' = "files"
    '.*\[W\] --.*' = "w_def"
    '.*\[W\] \[R\].*' = "w_reg"

}

$rep_path = Join-Path $PSScriptRoot "..\$($date)_report.txt"

function write-rep{
    param(
        [string[]]$text
    )
    
    foreach ($line in $Text) {
        Add-Content -Path $rep_path -Value $line
    }
    
}

Write-Output "Making the report...`n$($rep_path)"

$log_read = @(Get-Content -Path $log_path -Raw)

foreach($item in $regsearch.GetEnumerator()){
    $value  = $item.Value
    $key = $item.Key

    $data[$value] += ( [regex]::Matches($log_read, $key)  | ForEach-Object { $_.Groups.Value } )
}


#foreach($item in $data.GetEnumerator()){
#
#    $count = $data[$item.key] | Measure-Object | Select-Object -ExpandProperty Count
#    write-rep -text $item.Key 
#    write-rep -text "`nITEM COUNT: $count`n"
#    write-rep -text $data[$item.Key]
#
#}

$data | Set-Content -Path $rep_path

exit

