#TODO: 
# Set it to run powreshell script remotely after it is up and running
# Create 2 ISOs, one for auto build, the other for manual
# Break this into functions and or classes


$rebuildorig = $false # Should it mount the ISO and bring over a fresh copy of the ISO files.
$cleanpriorfiles = $true # Should it get rid of the custom files and wims
$refreshcustom = $true #Should it refresh the custom files from the original
$buildboot = $true # Should it build the boot wim.
$buildinstall = $true # Should it build the install wim
$installdrivers = $true # Should it install drivers
$installpatches = $true # Should it install drivers
$buildiso = $true # Should it create the ISO
$deloldiso = $true # Should it delete old ISOs from local and remote repository?
$osver = "10" #windows version
$istest = $true # if testing, only modify dc-g image and remove the rest
$cleanupimage = $false # determines whether or not to run cleanup-image the image


$remoteisopath = "\\deneir\public\programs\os\windows\$osver"
$basedir = "e:\winiso"
$scriptpath= $(join-path -path $basedir -childpath "scripts")
$offlinedir = $(join-path -path $basedir -childpath "offline")
$drvpath = $(join-path -path $basedir -childpath "drivers")
$winfiles = $(join-path -path $basedir -childpath "winfiles")
$localisopath = $(join-path -path $(join-path -path $winfiles -childpath "isos") -ChildPath $osver)
$wimpath = $(join-path -path $winfiles -childpath "wimfiles")
$customfiles = $(join-path -path $winfiles -childpath "customfiles")
$customsources = $(join-path -path $customfiles -childpath "sources")
$customboot = $(join-path -path $customsources -childpath "boot.wim")
$custominstall = $(join-path -path $customsources -childpath "install.wim")
$origisofiles = $(join-path -path $winfiles -childpath "origisofiles")
$patchpath = $(join-path -path $basedir -childpath "patches\$($osver)")

$bootwim = $(join-path -path $wimpath -childpath "boot.wim")
$installwim = $(join-path -path $wimpath -childpath "install.wim")
$f6drivers = $(join-path -path $drvpath -childpath "f6")
$tools    = 'D:\Windows Kits\11\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg'
$oscdimg  = "$tools\oscdimg.exe"
$etfsboot = "$tools\etfsboot.com"
$efisys   = "$tools\efisys_noprompt.bin"
$oscddata = '2#p0,e,b"{0}"#pef,e,b"{1}"' -f $etfsboot, $efisys
#$customiso = "$winfiles\home-win$($osver)_$(get-date -f yyyyMMdd-HHMMss).iso"
$customiso = "$winfiles\home-win$($osver).iso"

$customwimfilespath = $(join-path -path $scriptpath -childpath "wininstall")
# $customisofilespathsrc = $(join-path -path $wininstallpath -childpath "isofiles")
# $customwimfilespathsrc = $(join-path -path $wininstallpath -childpath "wimfiles")

$wimtofolder = @{
	## Correlates the Windows image with the proper folders.
	"windows server 2016 standard" = "win2016_std_core"
	"windows server 2016 standard (desktop experience)" = "win2016_std_gui"
	"windows server 2016 datacenter" = "win2016_dc_core"
	"windows server 2016 datacenter (desktop experience)" = "win2016_dc_gui"
	"windows server 2019 standard" = "win2019_std_core"
	"windows server 2019 standard (desktop experience)" = "win2019_std_gui"
	"windows server 2019 datacenter" = "win2019_dc_core"
	"windows server 2019 datacenter (desktop experience)" = "win2019_dc_gui"
	"microsoft windows pe (x64)" = "win_pe"
	"microsoft windows setup (x64)" = "win_setup"
	"microsoft windows pe (amd64)" = "win_pe"
	"microsoft windows setup (amd64)" = "win_setup"
	"Windows Server 2022 Standard" = "win2022_std_core"
	"Windows Server 2022 Standard (Desktop Experience)" = "win2022_std_gui"
	"Windows Server 2022 Datacenter" = "win2022_dc_core"
	"Windows Server 2022 Datacenter (Desktop Experience)" = "win2022_dc_gui"
	"Windows 11 Enterprise" = "win11"
	"Windows 10 Enterprise" = "win10"
}

$imgtokeep = @{
	"2016" = "windows server 2016 datacenter (desktop experience)"
	"2019" = "windows server 2019 datacenter (desktop experience)"
	"2022" = "Windows Server 2022 Datacenter (Desktop Experience)"
	"11" = "Windows 11 Enterprise"
	"10" = "Windows 10 Enterprise"
}

if ($rebuildorig) {
	#delete all files under $origisofiles
	remove-item -recurse "$origisofiles\*" -force
	#discover the newest iso at the $remoteisopath
	$remoteiso = $(Get-ChildItem $remoteisopath | Sort-Object -descending creationtime | Select-Object -first 1)
	#Assign the same iso name using the localisopath
	$localiso = $(join-path -path $localisopath -childpath $remoteiso.name)

	#check if any ISO files exist in the $localisopath that have a different name and delete them
	$localisofiles = $(Get-ChildItem $localisopath | Where-Object{$_.name -like "*$osver*.iso" -and $_.name -ne $remoteiso.name})

	if ($localisofiles) {
		foreach ($localisofile in $localisofiles) {
			remove-item $localisofile.fullname
		}
	}

	#check to see if if the $localiso still exists, if not then copy it from $remoteisopath to $localisopath
	if (-not(test-path $localiso)) {
		copy-item $remoteiso.fullname $localiso
	}
	
	#copy the files from inside the iso to the existing location pointed to by $origisofiles
	#$localiso | Mount-DiskImage -PassThru | Get-Volume | Get-Partition | Get-Volume | Get-ChildItem | Copy-Item -Destination $origisofiles -Recurse -Force
	Get-ChildItem "$($($localiso | Mount-DiskImage -PassThru | Get-Volume).DriveLetter):\" | Copy-Item -Destination $origisofiles -Recurse -Force
	$localiso | Dismount-DiskImage
	
}

if ($cleanpriorfiles) {
	# Clean up old files
	remove-item -recurse "$customfiles\*" -force
	remove-item -recurse "$wimpath\*" -force
}


#Refresh the files to be used for the ISO from the original ISO files.
if ($refreshcustom) {
	copy-item "$origisofiles\*" $customfiles -recurse -force
}

# Move wim files to the proper location to be extracted and modified. Reuqires removing the Read Only flag.





## Save the old location and go to the script directory.
push-location
set-location $scriptdir



if ($buildboot) {
	write-host "Begin: Boot Image"

	move-item $customboot $wimpath -force -passthru | set-itemproperty -name isreadonly -value $false
	foreach ($winfo in 	$(get-windowsimage -imagepath $bootwim)) {
		write-host "Begin: "$winfo.imagename
		$locwimpath = $(join-path -path $offlinedir -childpath $wimtofolder[$winfo.imagename])
			if (-not(test-path $locwimpath)) {new-item -path $offlinedir -name $wimtofolder[$winfo.imagename] -itemtype "directory"
		}
		mount-windowsimage -path $locwimpath -imagepath $bootwim -name $winfo.imagename
		write-host "Begin: Drivers"
		add-windowsdriver -path $locwimpath -driver $f6drivers -recurse
		write-host "End: Drivers"
		dismount-windowsimage -path $locwimpath -save
		write-host "End: "$winfo.imagename
	}
	move-item $bootwim $customsources -force -passthru | set-itemproperty -name isreadonly -value $true
	write-host "End: Boot Image"
}

if ($buildinstall) {
	move-item $custominstall $wimpath -force -passthru | set-itemproperty -name isreadonly -value $false	
	if ($istest) {		
		
		foreach ($img in $(get-windowsimage -imagepath $installwim)) {
			if ($img.ImageName -ne $imgtokeep[$osver]) {
				remove-windowsimage -imagepath $installwim -name $($img.imagename)
			}
		}
	}

	write-host "Begin: Install Image"
	$imagelist = $(get-windowsimage -imagepath $installwim)
	write-host "Before anything: "(Get-ChildItem $installwim).length
	$dodrivers = $installdrivers
	$dopatches = $installpatches
	foreach ($patchf in $(Get-ChildItem $patchpath | Where-Object{Get-ChildItem $_.fullname})) {
		write-host "Begin: Patch Type $($patchf.name)"
		write-host "Start "($patchf.name)": "(Get-ChildItem $installwim).length
		$curpatchpath = "$($patchf.fullname)"
		foreach ($winfo in $imagelist) {
			write-host "Begin: "$winfo.imagename
			$locwimpath = $(join-path -path $offlinedir -childpath $wimtofolder[$winfo.imagename])
			if (-not(test-path $locwimpath)) {
				new-item -path $locwimpath -itemtype "directory"
			}
			mount-windowsimage -path $locwimpath -imagepath $installwim -name $winfo.imagename
			if ($dodrivers) {
				write-host "Begin: Drivers"
				add-windowsdriver -path $locwimpath -driver $drvpath -recurse
				write-host "End: Drivers"				
				$dodrivers = $false
			}

			if ($dopatches) {
				write-host "Begin: Patches"
				add-windowspackage -path $locwimpath -packagepath $curpatchpath
				write-host "End: Patches"
			}
			
			foreach ($d in Get-ChildItem -Recurse -Directory $customwimfilespath) {
				$newd = $d.fullname.tolower().replace($customwimfilespath.tolower(),$locwimpath.tolower())			
				if (-not(test-path $newd)) {
					New-Item -itemtype directory -path $newd
				}
			}

			Get-ChildItem -file -Recurse $customwimfilespath -PipelineVariable f | 
			ForEach-Object{copy-item $f.fullname $f.fullname.tolower().replace($customwimfilespath.tolower(),$locwimpath.tolower())}
			
			dismount-windowsimage -path $locwimpath -save
		}
			
		write-host "End: "$winfo.imagename
		write-host "End "($patchf)": "(Get-ChildItem $installwim).length
		write-host "End: Patch Type $patchf"
	}

	if ($cleanupimage) {
		foreach ($winfo in $imagelist) {
			write-host "Begin: Cleanup"
			write-host "Before resetbase of "($patchf)": "(Get-ChildItem $installwim).length
			mount-windowsimage -path $locwimpath -imagepath $installwim -name $winfo.imagename
			dism /image:$locwimpath /cleanup-image /startcomponentcleanup /resetbase
			dismount-windowsimage -path $locwimpath -save
			write-host "After resetbase of "($patchf)": "(Get-ChildItem $installwim).length
			write-host "End: Cleanup"
		}
	}
	move-item $installwim $customsources -force -passthru | set-itemproperty -name isreadonly -value $true
	write-host "End: Install Image"

}

if ($buildiso) {
	if ($deloldiso) {
		Get-ChildItem "$winfiles\*$osver*.iso" | remove-item
	}
	if ((test-path $bootwim) -and -not (test-path $customboot)) {
		move-item $bootwim $customsources -force -passthru | set-itemproperty -name isreadonly -value $true
	}
	
	if ((test-path $installwim) -and -not (test-path $custominstall)) {
		move-item $installwim $customsources -force -passthru | set-itemproperty -name isreadonly -value $true
	}

	$arglist = @("-m","-o","-u2","-udfver102","-bootdata:$oscddata",$customfiles,$customiso)
	start-process "$oscdimg" -wait -argumentlist $arglist
}

pop-location
