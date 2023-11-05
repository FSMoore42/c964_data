# Import the module containing the FileSystem class
Import-Module ./FileSystem.ps1

Describe "FileSystem" {
    BeforeAll {
        $fileSystem = [FileSystem]::new()
        $testPath = "testPath"
        $testDestination = "testDestination"
        $testChildPath = "testChildPath"
        $testItemType = "testItemType"
        $testNewName = "testNewName"
    }

    It "Copies an item" {
        # Setup
        New-Item $testPath -ItemType File
        # Test
        $fileSystem.CopyItem($testPath, $testDestination)
        # Assert
        Test-Path $testDestination | Should -BeTrue
        # Cleanup
        Remove-Item $testPath
        Remove-Item $testDestination
    }

    It "Gets child items" {
        # Setup
        New-Item $testPath -ItemType Directory
        New-Item (Join-Path $testPath "childItem") -ItemType File
        # Test
        $childItems = $fileSystem.GetChildItems($testPath)
        # Assert
        $childItems.Count | Should -Be 1
        # Cleanup
        Remove-Item $testPath -Recurse
    }

    # Continue with similar blocks for RemoveItem, JoinPath, TestPath, NewItem, MoveItem, RenameItem, and GetContent
}