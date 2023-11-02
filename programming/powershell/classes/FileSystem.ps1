class FileSystem {
    [void] CopyItem([string]$source, [string]$destination) {
        Copy-Item $source $destination
    }
    
    [System.IO.FileInfo[]] GetChildItems([string]$path) {
        return Get-ChildItem $path
    }
    
    [void] RemoveItem([string]$path) {
        Remove-Item $path
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
    
    [void] MoveItem([string]$source, [string]$destination) {
        Move-Item $source $destination
    }
    
    [void] RenameItem([string]$path, [string]$newName) {
        Rename-Item $path $newName
    }
    
    [string] GetContent([string]$path) {
        return Get-Content $path
    }
    
    [void] SetContent([string]$path, [string]$content) {
        Set-Content $path $content
    }
}
