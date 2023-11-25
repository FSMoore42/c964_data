class ISOManager {
    [FileSystem]$fileSystem
    [string]$BaseFolder
    [string]$OSVer
    [string]$RemoteIsoBase
    [string]$DriversFolder  
    [string]$OfflineFolder
    [string]$WinPeFolder
    [string]$WinSetupFolder
    [string]$OSOfflineFolder
    [string]$PatchesFolder
    [string]$OSPatchesFolder
    [string]$ScriptsFolder
    [string]$WinInstallFolder
    [string]$WinFilesFolder
    [string]$CustomFilesFolder
    [string]$OSCustomFilesFolder
    [string]$IsosFolder
    [string]$LocalOSIsosFolder
    [string]$LocalIsoFullPath
    [string]$OrigIsoFilesFolder
    [string]$WimFilesFolder
    [string]$RemoteOSIsosFolder    
    [string]$MountedIsoDriveLetter

    ISOManager([string]$baseFolder, [string]$remoteIsoBase, [string]$osVer) {
        $this.fileSystem = [FileSystem]::new()
        $this.BaseFolder = $baseFolder
        $this.RemoteIsoBase = $remoteIsoBase
        $this.OSVer = $osVer

        $this.DriversFolder = $this.fileSystem.JoinPath($this.BaseFolder, "drivers")
        $this.OfflineFolder = $this.fileSystem.JoinPath($this.BaseFolder, "offline")
        $this.WinPeFolder = $this.fileSystem.JoinPath($this.OfflineFolder, "win_pe")
        $this.WinSetupFolder = $this.fileSystem.JoinPath($this.OfflineFolder, "win_setup")
        $this.OSOfflineFolder = $this.fileSystem.JoinPath($this.OfflineFolder, $this.OSVer)
        $this.PatchesFolder = $this.fileSystem.JoinPath($this.BaseFolder, "patches")
        $this.OSPatchesFolder = $this.fileSystem.JoinPath($this.PatchesFolder, $this.OSVer)
        $this.ScriptsFolder = $this.fileSystem.JoinPath($this.BaseFolder, "scripts")
        $this.WinInstallFolder = $this.fileSystem.JoinPath($this.ScriptsFolder, "wininstall")
        $this.WinFilesFolder = $this.fileSystem.JoinPath($this.BaseFolder, "winfiles")
        $this.CustomFilesFolder = $this.fileSystem.JoinPath($this.WinFilesFolder, "customfiles")
        $this.OSCustomFilesFolder = $this.fileSystem.JoinPath($this.CustomFilesFolder, $this.OSVer)
        $this.IsosFolder = $this.fileSystem.JoinPath($this.WinFilesFolder, "isos")
        $this.LocalOSIsosFolder = $this.fileSystem.JoinPath($this.IsosFolder, $this.OSVer)
        $this.OrigIsoFilesFolder = $this.fileSystem.JoinPath($this.WinFilesFolder, "origisofiles")
        $this.OrigIsoFilesFolder = $this.fileSystem.JoinPath($this.OrigIsoFilesFolder, $this.OSVer)
        $this.WimFilesFolder = $this.fileSystem.JoinPath($this.WinFilesFolder, "wimfiles\$this.OSVer")
        $this.RemoteOSIsosFolder = $this.fileSystem.JoinPath($this.RemoteIsoBase, $this.OSVer)
    }

    [void] UpdateLocalISO() {
        # Fetch the latest ISO file from the remote OS ISO path
        $latestRemoteISO = $this.fileSystem.GetChildItems($this.RemoteOSIsosFolder) | Where-Object { $_.Extension -eq ".iso" } | Sort-Object CreationTime -Descending | Select-Object -First 1
    
        if ($latestRemoteISO -ne $null) {
            # Update the LocalIsoFullPath with the latest ISO path
            $this.LocalIsoFullPath = $this.fileSystem.JoinPath($this.LocalOSIsosFolder, $latestRemoteISO.Name)
    
            # Find and remove other ISOs in the local path that are not the latest
            $otherLocalISOs = $this.fileSystem.GetChildItems($this.LocalOSIsosFolder) | Where-Object { $_.Name -like "*$($this.OSVer)*.iso" -and $_.Name -ne $latestRemoteISO.Name }
            foreach ($iso in $otherLocalISOs) {
                $this.fileSystem.RemoveItem($iso.FullName)
                Write-Host "Removed outdated ISO: $($iso.Name)"
            }
    
            # Check if the latest ISO already exists locally, if not, copy it
            if (-not $this.fileSystem.TestPath($this.LocalIsoFullPath)) {
                # Ensure the local ISO directory exists
                if (-not $this.fileSystem.TestPath($this.LocalOSIsosFolder)) {
                    $this.fileSystem.NewItem($this.LocalOSIsosFolder, "Directory")
                }
    
                # Copy the latest ISO from remote to local
                $this.fileSystem.CopyItem($latestRemoteISO.FullName, $this.LocalIsoFullPath)
                Write-Host "Copied latest ISO: $($latestRemoteISO.Name) to $($this.LocalIsoFullPath)"
            } else {
                Write-Host "Latest ISO already exists at $($this.LocalIsoFullPath)"
            }
        } else {
            Write-Host "No ISO found in $($this.RemoteOSIsosFolder)"
        }
    }

    [void] MountIso() {
        # Ensure the path to the local ISO is available
        if ($this.LocalIsoFullPath -and (Test-Path $this.LocalIsoFullPath)) {
            # Mount the ISO and capture the resulting drive letter
            $mountedDrive = Mount-DiskImage -ImagePath $this.LocalIsoFullPath -PassThru | Get-Volume
    
            # Store the drive letter in the class property
            $this.MountedIsoDriveLetter = $mountedDrive.DriveLetter
    
            Write-Host "ISO mounted at drive letter: $($this.MountedIsoDriveLetter)"
        } else {
            Write-Host "Local ISO path is not set or the file does not exist."
        }
    }

    [void] RefreshOriginalIsoFiles() {
        if ([string]::IsNullOrWhiteSpace($this.MountedIsoDriveLetter)) {
            Write-Host "No ISO is currently mounted. Please mount an ISO before refreshing files."
            return
        }
    
        $sourcePath = $this.fileSystem.JoinPath($this.MountedIsoDriveLetter + ":\", "")
        $destinationPath = $this.OrigIsoFilesFolder
    
        if ($this.fileSystem.TestPath($destinationPath)) {
            $this.fileSystem.GetChildItems($destinationPath) | ForEach-Object {
                $this.fileSystem.RemoveItem($_.FullName, $true)
            }
        } else {
            $this.fileSystem.NewItem($destinationPath, "Directory")
        }
    
        try {
            $this.fileSystem.CopyItem($sourcePath, $destinationPath, $true)
            Write-Host "Refreshed original ISO files from mounted ISO to $destinationPath"
        } catch {
            Write-Host "An error occurred while refreshing original ISO files: $_"
        }
    }
}
