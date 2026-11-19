<# 
.SYNOPSIS
    OPENS THE GUI VERSION OF PSCHECK
.DESCRIPTION
    LOG FILTERING, RUN MENU AND REAL TIME LOG READING
.LINK
    --
.EXAMPLE
    ./gui.ps1 // RUN THROUGH launcher.bat
.NOTES
#>

# NET CLASSES
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName Microsoft.VisualBasic
Add-Type -AssemblyName System.Windows.Forms

# XAML OBJECTS AND READER
[xml]$xaml = Get-Content ".\ui.xml" -Raw

$reader = New-Object System.Xml.XmlNodeReader $xaml

$window = [Windows.Markup.XamlReader]::Load($reader)


# WINDOW NOT RESIZABLE
$window.ResizeMode = [System.Windows.ResizeMode]::NoResize

# WINDOW CONTENT
$text_b = $window.FindName("tbOutput")
$auto_r = $window.FindName("autorefresh")

# USING DISPATCHER TIME TO READ THE LOG AT THE SAME TIME AS DISPLAYING THE WINDOW
# USED FOR AUTO-REFRESH
$timer = New-Object Windows.Threading.DispatcherTimer
$timer.Interval = [timespan]::FromSeconds(1)

# LOG_FILE
$logFile = Join-Path $PSScriptRoot "..\logs\exec_$(Get-Date -Format "dd-MM-yyyy").log"

function read_log{

    $log_text = Get-Content -Raw -Encoding ascii -Path $logFile -ErrorAction SilentlyContinue
    $text_b.Text  = $log_text

    # SET LOG NOT FOUND IF VAR LOG TEXT IT'S NULL // EMPTY
    if($null -eq $log_text -or $log_text -eq "" ){
        $text_b.Text = "Log not found"
    }
    
}

function start-script{
    param(
        [string]$script,
        [switch]$admin=$false
    )

    if($admin){
        Start-Process $version -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -NoProfile -NoExit -File", (Join-Path $PSScriptRoot $scriptPath)
    }

    else{
        Start-Process $version -ArgumentList "-ExecutionPolicy Bypass -NoProfile -NoExit -File", (Join-Path $PSScriptRoot $scriptPath)
    }
    
}

if($PSVersionTable.PSVersion.Major -lt 7){
    $version = "powershell"

    $ver_warn = [System.Windows.Forms.MessageBox]::Show(
                "It's recommended to use Powershell 7`nYou're currently using version $($PSVersionTable.PSVersion)`nContinue?",
                "Powershell version",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
    if($ver_warn -eq [System.Windows.Forms.DialogResult]::No){
        exit
    }

}
else{
    $version = "pwsh"
}

read_log

# AUTOREFRESH WITH AUTO_R BUTTON
$timer.Add_Tick({
    if($auto_r.IsChecked){
        read_log
    }
})

$timer.Start()

# BUTTONS AND SCRIPT PATHS
$path_f = @{
        "process" = "..\scripts\process.ps1"
        "services" = "..\scripts\services.ps1"
        "execution" = "..\scripts\execution.ps1"
        "files" = "..\scripts\files.ps1"
        "firewall" = "..\scripts\firewall.ps1"
        "network" = "..\scripts\network.ps1"
        "hidden" = "..\scripts\hidden.ps1"
        "windows" =  "..\scripts\windows.ps1"
        "auto" =  "..\scripts\auto.ps1"
        "report" =  "..\scripts\report.ps1"
            }


# EXECUTION OF SCRIPTS
foreach ($path in $path_f.Keys) {
    $window.FindName($path).Add_Click({
        param($sender, $e)

        $buttonName = $sender.Name
        $scriptPath = $path_f[$buttonName]


        if($buttonName -eq "windows"){
            start-script -script $scriptPath -admin
        }
        
        elseif($buttonName -eq "files"){
            
            # CUSTOM DIR OPTION DIALOG
            $files_option = [System.Windows.Forms.MessageBox]::Show(
                "Custom path?",
                "Files path",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Question
            )

            if ($files_option -eq [System.Windows.Forms.DialogResult]::Yes) {   

                # CUSTOM DIR BROWSER DIALOG
                $directory = New-Object System.Windows.Forms.FolderBrowserDialog
                $directory.ShowNewFolderButton = $true

                if ($directory.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                    $path = $directory.SelectedPath
                    Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -NoProfile -NoExit -File `"$scriptPath`" -path $path"
                }
            }

            else{
                start-script -script $scriptPath
            }
        }
        
        else{
            start-script -script $scriptPath
        }
    })
}

# START THE WINDOW
$window.ShowDialog() | Out-Null
