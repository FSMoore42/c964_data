. .\FileSystem.ps1

class IsoManager {

    hidden [string]$_BaseDir
    hidden [string]$_OrigIsoFiles
    hidden [string]$_CustomFiles
    hidden [string]$_CustomSources
    hidden [string]$_LocalIsoPath
    hidden [string]$_RemoteIsoPath
    hidden [string]$_OscdimgPath = 'D:\Windows Kits\11\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg'
    hidden [string]$_OscdimgExe
    hidden [string]$_Etfsboot
    hidden [string]$_Efisys
    hidden [FileSystem]$_FileSystem

    IsoManager([string]$baseDir) {
        $this._FileSystem = [FileSystem]::new()
        $this._BaseDir = $baseDir
        $this.UpdatePaths()
        $this.UpdateOscdimgPaths()
    }

    [string] get_BaseDir() { return $this._BaseDir }
    [void] set_BaseDir([string]$value) { 
        $this.BaseDir = $value
        $this.UpdatePaths() 
    }
    [string] get_OrigIsoFiles() { return $this._OrigIsoFiles }
    [string] get_CustomFiles() { return $this._CustomFiles }
    [string] get_CustomSources() { return $this._CustomSources }
    [string] get_LocalIsoPath() { return $this._LocalIsoPath }
    [string] get_RemoteIsoPath() { return $this._RemoteIsoPath }
    [void] set_RemoteIsoPath([string]$value) { $this._RemoteIsoPath = $value }
    [string] get_OscdimgPath() { return $this._OscdimgPath }
    [void] set_OscdimgPath([string]$value) {
        $this._OscdimgPath = $value
        $this.UpdateOscdimgPaths()
    }
    [string] get_OscdimgExe() { return $this._OscdimgExe }    
    [string] get_Etfsboot() { return $this._Etfsboot }    
    [string] get_Efisys() { return $this._Efisys }    

    [void] UpdatePaths() {
        $this._OrigIsoFiles = $this._FileSystem.JoinPath($this._BaseDir, "winfiles\origisofiles")
        $this._CustomFiles = $this._FileSystem.JoinPath($this._BaseDir, "winfiles\customfiles")
        $this._CustomSources = $this._FileSystem.JoinPath($this._CustomFiles, "sources")
        $this._LocalIsoPath = $this._FileSystem.JoinPath($this._BaseDir, "winfiles\isos")
    }

    [void] UpdateOscdimgPaths() {
        $this._OscdimgExe = $this._FileSystem.JoinPath($this._OscdimgPath, "oscdimg.exe")
        $this._Etfsboot = $this._FileSystem.JoinPath($this._OscdimgPath, "etfsboot.com")
        $this._Efisys = $this._FileSystem.JoinPath($this._OscdimgPath, "efisys_noprompt.bin")
    }

    [void] GetLatestIso([string]$remoteIsoPath, [string]$isoVersion) {
        Write-Host "Begin: GetLatestIso"

        $this.RemoteIsoPath = $remoteIsoPath
        $localIsoFolder = $this._FileSystem.JoinPath($this.LocalIsoPath, $isoVersion)
        $remoteIso = $this._FileSystem.GetChildItems($this.RemoteIsoPath) | 
            Sort-Object -Descending CreationTime | Select-Object -First 1
        $localIso = $this._FileSystem.JoinPath($localIsoFolder, $remoteIso.Name)

        # Delete any old ISO files locally
        $oldLocalIsoFiles = $this._FileSystem.GetChildItems($localIsoFolder) | 
            Where-Object { $_.Name -like "*$isoVersion*.iso" -and $_.Name -ne $remoteIso.Name }
        foreach ($oldLocalIsoFile in $oldLocalIsoFiles) {
            $this._FileSystem.RemoveItem($oldLocalIsoFile.FullName)
        }

        # Copy remote ISO to local if not exists
        if (-not $this._FileSystem.TestPath($localIso)) {
            $this._FileSystem.CopyItem($remoteIso.FullName, $localIso)
        }

        Write-Host "End: GetLatestIso"
    }

    [void] ExtractIso([string]$localIso) {
        Write-Host "Begin: ExtractIso"

        # Extract ISO content to OrigIsoFiles
        $this._FileSystem.GetChildItems("$($(Mount-DiskImage -ImagePath $localIso -PassThru | Get-Volume).DriveLetter):\") |
            ForEach-Object { $this._FileSystem.CopyItem($_, $this.OrigIsoFiles, $true) }

        Dismount-DiskImage -ImagePath $localIso
        Write-Host "End: ExtractIso"
    }

    [void] CreateCustomIso([string]$customIsoName) {
        Write-Host "Begin: CreateCustomIso"
        $customIsoPath = $this._FileSystem.JoinPath($this.BaseDir, "winfiles\$customIsoName")
        $oscddata = '2#p0,e,b"{0}"#pef,e,b"{1}"' -f $this.Etfsboot, $this.Efisys

        $arglist = @("-m","-o","-u2","-udfver102","-bootdata:$oscddata",$this.CustomFiles,$customIsoPath)
        Start-Process "$($this.OscdimgExe)" -Wait -ArgumentList $arglist
        Write-Host "End: CreateCustomIso"
    }
}
