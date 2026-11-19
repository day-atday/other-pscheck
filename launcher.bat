SET mypath=%~dp0
SET file=\pscheck.ps1

IF NOT EXIST %mypath%%file% (
    cmd /c start powershell -NoExit -Command Write-Warning "ERROR:Launcher_NotIn_PSCHECK_Folder"
    exit
)

cd gui

:: cmd /c start /min "" pwsh -WindowStyle Hidden -ExecutionPolicy Bypass -File "gui.ps1"

SET "SCRIPT_PATH=gui.ps1"

where pwsh >nul 2>&1

if not errorlevel 1 (
    cmd /c start /min "" pwsh -WindowStyle Hidden -ExecutionPolicy Bypass -File %SCRIPT_PATH%
) else (
    cmd /c start /min "" powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File %SCRIPT_PATH%
)

exit