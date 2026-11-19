# other-pscheck
Check sysinfo with gui
"Old" project i had, may be useful.

## Usage
Recommended to use pwsh // PowerShell 7 way faster!

All information it's stored in the log folder created by the scripts, it should be inside pscheck folder.

### Script List
**Process**
Captures information about processes
Compares the hash of the file of the process against the ones in the list
Compares the name of the process for sus names like: conhöst, сonhost (Cyrillic 'c'), expIorer, ....
Refreshes and captures processes in "real time"

**Network**
Checks current Active TCP connections and UDP Endpoints -- Refreshes

**auto**
Execute most of the Scripts, keeps Process and Network running. -- Refreshes

**Services**
Checks services with executables outside the Windows folder
Compares the hash of the file linked to the service to the ones in the list
Checks if the file of the service has signature

**Hidden**
Checks for hidden files in a directory

**Firewall**
Looks for outbound firewall enabled rules

**Windows**
Looks at Run and RunOnce Windows Registry keys and Windows Defender exclusions

**Files**
Looks for files or new files in a directory and compares the hash with the ones in the list -- Refreshes

**Execution**
Checks the PowerShell commandline history.

**Strings**
Reads strings from a file

### GUI
Open launcher.bat or gui.ps1 (pscheck/gui)
```
powershell -ep bypass -f ./gui.ps1
```

### Terminal
```
powershell -ep bypass -f ./pscheck.ps1 -argument

```
ARGUMENT LIST:
-process
-service
-execution
-file
-strings
-hidden
-network
-sys
