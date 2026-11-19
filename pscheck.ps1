<# 
.SYNOPSIS
    SCANS WINDOWS
.DESCRIPTION

.LINK
    --
.EXAMPLE
    ./pscheck.ps1 -argument

    ARGUMENT LIST:

        -process
        -service
        -execution
        -file
        -strings
        -hidden
        -network
        -sys

.NOTES
    HASH LIST EXTRACTED FROM GitHub, LGOG

    Link:
    https://github.com/LGOG/Flagged_Hash_list/blob/main/Flagged_Hash_List.csv

#>

# ==========================
# WANT TO ADD A  NEW SCRIPT?
# ==========================

# [1] - Add a [switch]$yourname in the params
# [2] - Add the path to $script_paths
# [3] - For additional parameters you'll have to tweak the MainExec function

# ============================================================================

# [1] - Add a new [switch] parameter for your script below.
#
# >    [switch]$custom
#       
#      Add a new parameter if necessary

param(
    [switch]$process,
    [switch]$service,
    [switch]$execution,
    [switch]$file,
    [switch]$strings,
    [switch]$hidden,
    [switch]$network,
    [switch]$win,
    [string]$path='',
    [int]$sleep_time=2
)

# [2] - Add your path below, name of key must be equal to name of the [switch]
#
#>      custom = ".\YOUR-PATH\custom.ps1"

$script_paths = @{
        process = ".\scripts\process.ps1"
        service = ".\scripts\services.ps1"
        execution = ".\scripts\execution.ps1"
        file = ".\scripts\files.ps1"
        strings = ".\scripts\strings.ps1"
        hidden = ".\scripts\hidden.ps1"
        network = ".\scripts\network.ps1"
        win = ".\scripts\windows.ps1"
    }


function MainExec {
    foreach ($item in $script_paths.GetEnumerator()) {

        $name = $item.Key
        $scriptPath = $item.Value

        if (Get-Variable -Name $name -ValueOnly) {

            # [3] - Insert below the arguments of your script, separated by '`' in the end of the last line (if unmodified == sleep_time)
            & $scriptPath `
                -path $path `
                -sleep_time $sleep_time 
            
            
        }
    }

    return
}

MainExec

