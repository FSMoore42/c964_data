class FileSystem {
    [void] CopyItem([string]$source, [string]$destination) {
        Copy-Item $source $destination
    }

    [void] CopyItem([string]$source, [string]$destination, [bool]$force, [bool]$recurse ) {
        Copy-Item $source $destination -Force:$force -Recurse:$recurse
    }

    [void] MoveItem([string]$source, [string]$destination) {
        Move-Item $source $destination
    }

    [void] MoveItem([string]$source, [string]$destination, [bool]$force) {
        Move-Item $source $destination  -Force:$force
    }
    
    [System.IO.FileSystemInfo[]] GetChildItems([string]$path) {
        return Get-ChildItem $path
    }

    [System.IO.FileSystemInfo[]] GetChildItems([string]$path, [bool]$recurse) {
        return Get-ChildItem $path -Recurse:$recurse
    }

    [void] RemoveItem([string]$path) {
        Remove-Item $path
    }

    [void] RemoveItem([string]$path, [bool]$force, [bool]$recurse) {
        Remove-Item $path  -Force:$force -Recurse:$recurse
    }

    [string] JoinPath([string]$path, [string]$childPath) {
        return Join-Path -Path $path -ChildPath $childPath
    }

    [bool] TestPath([string]$path) {
        return Test-Path $path
    }

    [void] NewItem([string]$path, [string]$itemType) {
        New-Item -Path $path -ItemType $itemType
    }

    [void] NewItem([string]$path, [string]$itemType, [bool]$force) {
        New-Item -Path $path -ItemType $itemType -Force:$force
    }

    [void] RenameItem([string]$path, [string]$newName) {
        Rename-Item $path $newName
    }

    [void] RenameItem([string]$path, [string]$newName, [bool]$force) {
        Rename-Item $path $newName -Force:$force
    }

    [string] GetContent([string]$path) {
        return Get-Content $path
    }
    
    [void] SetContent([string]$path, [string]$content) {
        Set-Content $path $content
    }
}
