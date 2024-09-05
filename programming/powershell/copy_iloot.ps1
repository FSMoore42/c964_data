$repo_dir = "e:\users\fmoore\documents\GitHub\repos\home\programming\lua\iLoot"
$addon_dir = "D:\Programs(x86)\World of Warcraft\_classic_\Interface\AddOns\iLoot"

#Copy-Item -Path $repo_dir -Destination $iloot_dir -Force -Recurse
robocopy /e /z "$repo_dir" "$addon_dir"
