#$powershell
cd s:\
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
import-module .\KnownFolderPath.ps1
$oldprof = "c:\users\fmoore"
$newprof = "e:\home\fmoore"
$dirs = @("desktop","downloads" ,"favorites" ,"music" ,"pictures","videos","documents"  ,"roamingappdata")

foreach ($d in $dirs) {
    $path=""
    Get-KnownFolderPath $d ([ref]$path)
    $newpath = $path.tolower().replace($oldprof,$newprof).tolower()
    if (-not(test-path $newpath)) {new-item -path $newpath -itemtype directory | out-null}
    robocopy /zb /mir $path $newpath /xj /xf "Desktop.ini" | out-null
    
    # Handle junctions
    $dirOutput = cmd /c dir "$path" /a
    $junctions = $dirOutput -split '\r\n' | Where-Object { $_ -match '<JUNCTION>' }
    foreach ($junction in $junctions) {
        if ($junction -match '(?<=<JUNCTION>\s+)([^[]+).*\[(.*)\]') {
            $name = $matches[1].Trim()
            $oldTarget = $matches[2].Trim().tolower()
            $newTarget = $oldTarget.Replace($oldprof, $newprof).tolower()

            # Create the junction in the new location
            $newJunctionPath = "$newpath\$name"
            cmd /c mklink /J "$newJunctionPath" "$newTarget"
            
            # Get the attributes of the original junction with /L flag
            $oldJunctionPath = "$path\$name"
            $attributesLink = ((cmd /c attrib "$oldJunctionPath" /L) -split '(?=[a-zA-Z]:|\\\\)', 2)[0].Trim()
            $attributesTarget = ((cmd /c attrib "$oldJunctionPath") -split '(?=[a-zA-Z]:|\\\\)', 2)[0].Trim()
            
            # Build the attribute command for link
            $attributeCommandLink = "attrib "
            if ($attributesLink -match 'R') { $attributeCommandLink += "+R " }
            if ($attributesLink -match 'H') { $attributeCommandLink += "+H " }
            if ($attributesLink -match 'S') { $attributeCommandLink += "+S " }
            if ($attributesLink -match 'I') { $attributeCommandLink += "+I " }
            $attributeCommandLink += "/L ""$newJunctionPath"""
            
            # Build the attribute command for target
            $attributeCommandTarget = "attrib "
            if ($attributesTarget -match 'R') { $attributeCommandTarget += "+R " }
            $attributeCommandTarget += """$newTarget"""
            
            # Apply the same attributes to the new junction
            cmd /c $attributeCommandLink
            cmd /c $attributeCommandTarget
        }
    }

    Set-KnownFolderPath $d $newpath
    Get-KnownFolderPath $d ([ref]$path)

}

#install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
robocopy.exe /zb /mir C:\ProgramData\chocolatey d:\programdata\chocolatey
$olddir = "C:\ProgramData\chocolatey"
$newdir = "d:\programdata\chocolatey"
$path = [System.Environment]::GetEnvironmentVariable("Path",[System.EnvironmentVariableTarget]::Machine).replace($olddir,$newdir)
[System.Environment]::SetEnvironmentVariable("PATH",$path,[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("chocolateyinstall",$newdir,[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::GetEnvironmentVariable("PATH",[System.EnvironmentVariableTarget]::Machine)
[System.Environment]::GetEnvironmentVariable("chocolateyinstall",[System.EnvironmentVariableTarget]::Machine)

#cmd
mkdir d:\programs
choco upgrade chocolatey -y
refreshenv
rmdir /s /q c:\programdata\chocolatey
choco feature enable -n=useRememberedArgumentsForUpgrades
reg add HKLM\SOFTWARE\VideoLAN\VLC /v "InstallDir" /t REG_SZ /d "d:\programs\vlc"

mkdir "d:\programs\google"
mkdir "d:\programs\powershell"
mkdir "d:\programs\correto"
mkdir "d:\programs\vlc"
mkdir "d:\programs\git"

mkdir "d:\programs(x86)\google"
mkdir "d:\programs(x86)\winscp"

mklink /d /j "D:\Program Files" "d:\programs"
mklink /d /j "C:\Program Files\Google" "d:\programs\google"
mklink /d /j "C:\Program Files\Amazon Corretto" "d:\programs\correto"
mklink /d /j "C:\Program Files\PowerShell" "d:\programs\powershell"
mklink /d /j "C:\Program Files\git" "d:\programs\git"

mklink /d /j "D:\Program Files" "d:\programs(x86)"
mklink /d /j "C:\Program Files (x86)\Google" "d:\programs(x86)\google"
mklink /d /j "C:\Program Files (x86)\WinSCP" "d:\programs(x86)\winscp"

choco install dotnetfx powershell microsoft-edge corretto17jdk googlechrome winscp -y
choco install powershell-core -y --install-arguments='"ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 REGISTER_MANIFEST=1 ENABLE_PSREMOTING=1 USE_MU=1 ENABLE_MU=1"'
choco install firefox -y --params "'/InstallDir:"d:\programs\firefox" /nodesktopshortcut /removedistributiondir'"
choco install notepadplusplus.install -y --install-arguments '"/D=d:\programs\notepad++"'
choco install git.install -y --params="'/GitAndUnixToolsOnPath'"
choco install vscode.install -y --params "/NoDesktopIcon /NoQuickLaunchIcon" --install-arguments '/dir="d:\programs\vscode"'
choco install sumatrapdf.install -y --params "'/NoDesktop /WithFilter /WithPreview /Path:d:\programs\sumatrapdf'"
choco install 7zip.install -y --install-arguments '/D="d:\programs\7zip"'
choco install teamviewer  -y --install-arguments '/D="d:\programs\teamviewer"'
choco install vlc.install -y --install-arguments '/D="d:\programs\vlc"'
choco install "pycharm-community" -y  --params "/NoDesktopIcon /NoQuickLaunchIcon" --install-arguments '/dir="d:\programs\jetbrains\pycharm"'
choco install "intellijidea-community" -y  --params "/NoDesktopIcon /NoQuickLaunchIcon" --install-arguments '/dir="d:\programs\jetbrains\idea"'


git config --global user.name = "Forrest Moore"
git config --global user.email = "vaulden@gmail.com"

#pwsh
$pyver = (choco find python3 | Where-Object{$_ -match "python3\d+? "} | Sort-Object -Descending @{e={[int]($_.split(".")[1])}} | Select-Object -first 1).split(' ')[0]
choco install $pyver -y --params "/InstallDir:d:\python\$($pyver) /nolockdown"

# Set explorer settings for hidden, extensions, etc.
$key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

Set-ItemProperty $key Hidden 1
Set-ItemProperty $key HideFileExt 0
Set-ItemProperty $key ShowSuperHidden 1
Set-ItemProperty $key hidedriveswithnomedia 0
Set-ItemProperty $key hidemergeconflicts 0

Stop-Process -processname explorer
