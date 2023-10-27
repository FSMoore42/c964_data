# todo: make script runable from cli
# todo: allow csv import, possibly auto create monitoring a folder
# todo: create gui
# todo: manage vcenter sessions within the script instead of requiring the user to connect first
# todo: set up common configurations instead of having to list everything. such as a sql server with the right drives, memory, and vcpus. probably sql, web server, app?
#


 
## start of example/format
##
# the $vms are a list of hashtables.
# the 2nd vm in the list below is the standard disk setup for sql.
#
# $vms = @(  
#     @{name="vem-backup-p01";  # name of the server
#     location="sav"; # datacenter, current options are "sav" and "osu"
#     os="windcgui"; # os version, current options are "windcugui"
#     memory=16; # gb of memory
#     cpus=2; # number of vcpus
#     autorename=$false; # currently not used
# harddisks are it's own list of list
#     hds=@(
#       @{size = 100;  #size of hard disk in gb
#         controller = "paravirtual"; #controller type, should be "paravirtual" whenever possible
#         format = "thin"; # format of the disk options are thin,thick,thickeagerzero. thin should be used unless absolutely necessary
#         label = "veeam"; # label for the disk
#         disktype = "gpt"; # type of partition options are mbr and gpt. default to gpt.
#         driveletter = "e"; # driver letter desired
#       }
#     )
#   },
#       @{name="vem-sql-p01";
#     location="sav"
#     os="windcgui";
#     memory=16;
#     cpus=4;
#     autorename=$false;
#     hds=@(
#       @{size = 250;
#         controller = "paravirtual";
#         format = "thin";
#         label = "backups";
#         disktype = "gpt";
#         driveletter = "b";
#       },@{size = 50;
#         controller = "paravirtual";
#         format = "thin";
#         label = "mdf";
#         disktype = "gpt";
#         driveletter = "f";
#       },
#       @{size = 50;
#         controller = "paravirtual";
#         format = "thin";
#         label = "ldf";
#         disktype = "gpt";
#         driveletter = "l";
#       },
#       @{size = 50;
#         controller = "paravirtual";
#         format = "thin";
#         label = "tempdb";
#         disktype = "gpt";
#         driveletter = "t";
#       }
#     )
#   }
# )
##
## end of example

# list that contains all vms to be created. see above for format and examples
$vms = @(  
    @{name="cu-email-p01";
     location="sav";
     os="windcgui";
     osver="2022";
     memory=4;
     cpus=2;
     autorename=$false;
     hds=@(
         @{size = 100;
          controller = "paravirtual";
          format = "thin";
          label = "exchange";
          disktype = "gpt";
          driveletter = "e";
         },
         @{size = 100;
            controller = "paravirtual";
            format = "thin";
            label = "exchangedata";
            disktype = "gpt";
            driveletter = "e";
           }
     )
   }
 )

function build-vms {
 param(
     $vms <#,
     [string]$vcenter, #name of vcenter, not used
     [string]$session, #can contain your vcenter session (not really used
#>
 )




 foreach ($vm in $vms) { 
     # uses the "location" to determine which datastore or cluster to place it in
     $dscluster = @{sav  = "prod_nfs_new_builds";
                    osu = "dr_nfs_drs";
                   }
     # uses the os and osver fields to select the proper template
     $vmtemplate = @{windcgui_2019 = "tpl-19-dc-g";
         windccore_2019 = "tpl-19-dc-c";
         winstdgui_2019 = "tpl-19-std-gui";
         windstdore_2019 = "tpl-19-std-c";
         windcgui_2022 = "tpl-22-dc-g";
         windccore_2022 = "tpl-22-dc-c";
         winstdgui_2022 = "tpl-22-std-gui";
         windstdore_2022 = "tpl-22-std-c";
         suse = "opensuse";
         }
     

     # uses os and osver to find the proper vmware os config
     $osspec = @{windcgui_2019 = "oss-19-dc";
         winstdgui_2019 = "oss-19-dc";
         windccore_2019 = "oss-19-std";
         winstdcore_2019 = "oss-19-std";
         windcgui_2022 = "oss-22-dc";
         winstdgui_2022 = "oss-22-dc";
         windccore_2022 = "oss-22-std";
         winstdcore_2022 = "oss-22-std";
         suse_15 = "opensuse";
     }
     
     # uses the location to determine what host/host cluster to place it in
     $vmcluster = @{sav = "prod-drs-01";
                    osu = "dresxi01.domain1.unm";
                  }
     
     #uses location to determine what network to connect to
     $portgroup = @{
         "sav" = "dpg-prod-servers-119";
         "osu" = "dvosunadr-107";
     }
     
     # uses the os property to determine which type of os for later use
     $ostype = @{windcgui = "windows gui";
                 winstdgui = "windows gui";
                 windccore = "windows core";
                 winstdcore = "windows core";
                 suse = "linux";
               }
     
     $curvmtemplate = $vmtemplate["$($vm.os)_$($vm.osver)"] #get the vm template to use
     $curosspec =  $osspec["$($vm.os)_$($vm.osver)"] #get the name of the os config file
     $curdscluster = $dscluster[$vm.location] #determine storage location
     $curvmcluster = $vmcluster[$vm.location] # determine vm location
     $curostype = $ostype[$vm.os] # determine os type
     $vmname = $vm.name # get the name for the vm     
     #$i = 0 commented out on 20230403, should no longer be needed
     $dpg = get-vdportgroup $portgroup[$vm.location] # determine port group (network) to add the vm to
     #$dpg = $portgroup[$vm.location]
     
     
     # the disk format is used to apply the proper format to the vm
     $storageformat = @{
                        thin = "thin";
                        thick = "thick";
                        eager = "eagerzeroedthick"
                      }
         #write out the new-vm command just to see it and catch errors if possible
         write-host "new-vm -name $vmname -template $curvmtemplate -oscustomizationspec $curosspec -datastore $curdscluster -resourcepool $curvmcluster -location "testing-$($vm.location)" -ea stop"
         
         #create the vm
         new-vm -name $vmname -template $curvmtemplate -oscustomizationspec $curosspec -datastore $curdscluster -resourcepool $curvmcluster -location "testing-$($vm.location)" -ea stop
         #new-vm -name $vmname -template $curvmtemplate -oscustomizationspec $curosspec -datastore $curdscluster -resourcepool $curvmcluster -location "testing-$($vm.location)" -networkname $dpg -ea stop
         #write-host set-vm -vm $vmname -memorygb $vm.memory -numcpu $vm.cpus -confirm:$false
         write-host "modifying $($vmname)..."
         # modify the vm with the proepr number of vcpus and memory gb
         set-vm -vm $vmname -memorygb $vm.memory -numcpu $vm.cpus -confirm:$false -ea stop
         get-vm $vmname | get-networkadapter | Where-Object{$_.networkname -ne $dpg} | set-networkadapter -networkname $dpg
         
         if ($curostype -eq "windows gui") {
             #only for windows with a gui
             # start the vm
             start-vm $vmname | open-vmconsolewindow
             
             #prep the "timers" 
             $inad = $nul # initialize to not in ad
             $maxwait = 60 # default time increment is 1 min
             $sleeptime = 1 # how long to Start-Sleep in between messages
             $thiswait = ($maxwait*20/$sleeptime) # total time to wait, the 20 is arbitrary
             # the below loop continues until the to
             write-host "`n"
             while ($inad -eq $nul -and $thiswait -ge 0) {
                 write-host "`rwaiting for ad : $('{0:d4}' -f $thiswait)" -nonewline
                 Start-Sleep $sleeptime
                 try {
                     $inad = $(get-adcomputer $vmname)
                 } catch {
                 }
                 #write-host '$(get-adcomputer $vmname)'
                 $thiswait = $thiswait - 1
             }
             write-host "`n"
             $thiswait = ($maxwait*5/$sleeptime) # total time to wait
             
             <##if ($thiswait -ge 0) { # this is not needed with most recent changes, i twill always be >= 0 #>
             # get current status of vmtools
             $priorstate = (get-vm $vmname | get-view | Select-Object -expandproperty guest).guestoperationsready
             #write-host "prior state: $priorstate"
             $thiswait = ($maxwait*5/$sleeptime)
             #while ( $i -le $thiswait) {
             # wait for 5 minutes, and assume it will not reboot
             while ($thiswait -ge 0) {
                 
                 write-host "`rwaiting for reset, currently $('{0}' -f $priorstate) - $('{0:d4}' -f $thiswait)" -nonewline
                 Start-Sleep $sleeptime
                 # get new state of vm tools
                 $curstate = (get-vm $vmname | get-view | Select-Object -expandproperty guest).guestoperationsready
                 #write-host "current state $curstate"
                 if ($priorstate -eq $curstate) {
                     #no change, still the same state as before, drop $thiswait
                     $thiswait = $thiswait - 1
                 } else {
                     # the vmtools state changed, verifying that if that means it went down, or came up.
                     #write-host "different"
                     if ($curstate) {
                         # if it's currently up, then the reboot is done
                         $thiswait = -1
                     } else {
                         # if it's currently down, then it is doing the reboot. set prior state to the current state indicating down. reset timer.
                         $priorstate = $curstate
                         $thiswait = ($maxwait*5/$sleeptime)
                     }
                 }
             }
             write-host "`n"
             write-host "adding to wsus group"
             # add vm to group a non-sql group
             add-adgroupmember -identity "gp_server_wsus_a" -members $(get-adcomputer $vmname)
             write-host "moving computer to ou"
             # move computer to the new ou
             get-adcomputer $vmname | move-adobject -targetpath 'ou=new,ou=virtual,ou=servers,ou=computers,ou=usnmfcu,dc=domain1,dc=unm' -server 'dc-sav.domain1.unm'
             write-host "wait for ou change"
             #wait for the move to take place
             while ((get-adcomputer $vmname).distinguishedname -ne "cn=$($vmname),ou=new,ou=virtual,ou=servers,ou=computers,ou=usnmfcu,dc=domain1,dc=unm") {
                 write-host "ou not changed yet" -nonewline
                 Start-Sleep $sleeptime
             }
             write-host "`n"
             write-host "ou changed, restarting"
             $priorstate = (get-vm $vmname | get-view | Select-Object -expandproperty guest).guestoperationsready
             #write-host "prior state: $priorstate"                    
             restart-vmguest $vmname
                                 <##if ($thiswait -ge 0) { # this is note needed with most recent changes, i twill always be >= 0 #>
             # get current status of vmtools
             $priorstate = (get-vm $vmname | get-view | Select-Object -expandproperty guest).guestoperationsready
             #write-host "prior state: $priorstate"
             $thiswait = ($maxwait*5/$sleeptime)
             #while ( $i -le $thiswait) {
             # wait for 5 minutes, and assume it will not reboot
             while ($thiswait -ge 0) {
                 
                 write-host "`rwaiting for reset, currently $('{0}' -f $priorstate) - $('{0:d4}' -f $thiswait)" -nonewline
                 Start-Sleep $sleeptime
                 # get new state of vm tools
                 $curstate = (get-vm $vmname | get-view | Select-Object -expandproperty guest).guestoperationsready
                 #write-host "current state $curstate"
                 if ($priorstate -eq $curstate) {
                     #no change, still the same state as before, drop $thiswait
                     $thiswait = $thiswait - 1
                 } else {
                     # the vmtools state changed, verifying that if that means it went down, or came up.
                     if ($curstate) {
                         # if it's currently up, then the reboot is done
                         $thiswait = -1
                     } else {
                         # if it's currently down, then it is doing the reboot. set prior state to the current state indicating down. reset timer.
                         $priorstate = $curstate
                         $thiswait = ($maxwait*5/$sleeptime)
                     }
                 }
             }

         }
         #sleep 300
         if ( $curostype -eq "windows gui" ) {
             # if it is a windows box, create a cim session
             write-host "creating cim session"
             $cim = new-cimsession $vmname -ea silentlycontinue
             while ($null -eq $cim) {
                 write-host "`rwaiting to try cim session again." -nonewline
                 Start-Sleep 1
                 write-host "`rwaiting to try cim session again.." -nonewline
                 Start-Sleep 1
                 write-host "`rwaiting to try cim session again..." -nonewline
                 $cim = new-cimsession $vmname -ea silentlycontinue
             }
             write-host '`n'
         }
         foreach ($hd in $vm.hds) {
             # loop through eahc hd
             write-host "begin hd"
             <#
             $tmpscsicontroller = $hd.controller; # get the controller
             $curscsicontroller = get-scsicontroller -vm $vmname | Where-Object{ $hd.type -match "$($tmpscsicontroller)" } -erroraction silentlycontinue | Select-Object -first 1;
             #>
             $curscsicontroller = get-scsicontroller -vm $vmname | Where-Object{ $hd.type -match "$($hd.controller)" } -erroraction silentlycontinue | Select-Object -first 1;
             #$curscsicontroller;
             if ( $curscsicontroller -eq $nul ) { $curscsicontroller = get-scsicontroller -vm $vmname | Select-Object -first 1 };
             write-host "create vm hd";
             #creat the hd
             new-harddisk -vm $vmname -controller $curscsicontroller -capacitygb $hd.size -storageformat $($storageformat);
             write-host "hd created";
             #sleep 300
             
             if ( $curostype -eq "windows gui" ) {
                 #connect to windows initialize the disk, partition it and format it according to the information provided
                 
                 write-host "intialize as $($hd.disktype) and format ntfs: $($hd.driveletter)/$($hd.label)"
                 get-disk -cimsession $cim | Where-Object partitionstyle -eq 'raw' | initialize-disk -partitionstyle $hd.disktype -passthru | new-partition -driveletter $hd.driveletter `
                 -usemaximumsize | format-volume -filesystem ntfs -newfilesystemlabel $hd.label -confirm:$false                                                                                                      
             };
         };
         # start vm if it is not already up will generally only happen when it is not a windows machine.
         get-vm $vmname | Where-Object{$_.powerstate -eq "poweredoff"} | start-vm                
 }
}

function nuke_pc_vm {
# this allows you to delete the vm, it then removes it from ad and deletes any dns entries it finds.
param ($vmname)

$domainname = "domain1.unm"
$dnsserver = "dc-sav.domain1.unm"
$vcenter = "bridge.domain1.unm"

connect-viserver $vcenter
get-vm $vmname | Where-Object{$_.powerstate -eq "poweredon"} | stop-vm -confirm:$false
get-vm $vmname | Where-Object{$_.powerstate -eq "poweredoff"} | remove-vm -deletepermanently
get-adcomputer $vmname | remove-adcomputer -confirm:$false
get-dnsserverresourcerecord -computername $dnsserver -zonename $domainname | Where-Object{$_.hostname -eq "$vmname"} | remove-dnsserverresourcerecord -computername $dnsserver -zonename $domainname -force

}

#build-vms -vms $vms



#http://www.lucd.info/2015/03/17/powercli-and-powershell-workflows/
