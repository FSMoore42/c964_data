class Controller {
    [bool] $RebuildOrig = $true
    [bool] $CleanPriorFiles = $true
    [bool] $RefreshCustom = $true
    [bool] $BuildBoot = $true
    [bool] $BuildInstall = $true
    [bool] $InstallDrivers = $true
    [bool] $BuildIso = $true
    [bool] $DelOldIso = $true
    [string] $IsoVersion
    [string] $BaseDir
    [bool] $CleanupImage = $false
    [IsoManager] $IsoManager

    Controller([string] $baseDir, [string] $isoVersion) {
        $this.BaseDir = $baseDir
        $this.IsoVersion = $isoVersion
        $this.IsoManager = [IsoManager]::new($baseDir)
    }

    [void] RebuildOriginal() {
        if ($this.RebuildOrig) {
            $this.IsoManager.GetLatestIso($remoteIsoPath, $isoVersion)  # Assume these variables are set
            # ... rest of the logic from the $rebuildorig block in the script ...
        }
    }

    [void] CleanPriorFiles() {
        if ($this.CleanPriorFiles) {
            # ... logic from the $cleanpriorfiles block in the script ...
        }
    }

    [void] RefreshCustom() {
        if ($this.RefreshCustom) {
            # ... logic from the $refreshcustom block in the script ...
        }
    }

    [void] BuildBoot() {
        if ($this.BuildBoot) {
            # ... logic from the $buildboot block in the script ...
        }
    }

    [void] BuildInstall() {
        if ($this.BuildInstall) {
            # ... logic from the $buildinstall block in the script ...
        }
    }

    [void] InstallDrivers() {
        if ($this.InstallDrivers) {
            # ... logic from the $installdrivers block in the script ...
        }
    }

    [void] BuildIso() {
        if ($this.BuildIso) {
            $this.IsoManager.CreateCustomIso($customIsoName)  # Assume $customIsoName is set
            # ... rest of the logic from the $buildiso block in the script ...
        }
    }

    [void] DeleteOldIso() {
        if ($this.DelOldIso) {
            # ... logic from the $deloldiso block in the script ...
        }
    }

    [void] Execute() {
        $this.RebuildOriginal()
        $this.CleanPriorFiles()
        $this.RefreshCustom()
        $this.BuildBoot()
        $this.BuildInstall()
        $this.InstallDrivers()
        $this.BuildIso()
        $this.DeleteOldIso()
    }
}
