# Import the module containing the FileSystem class
. .E:\users\fmoore\documents\GitHub\repos\home\programming\powershell\classes\FileSystem.ps1

Describe "FileSystem" {
    BeforeAll {
        $fileSystem = [FileSystem]::new()
        $testPath = "e:\users\fmoore\documents\GitHub\testing"
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

    It "Sets content" {
        # Setup
        New-Item $testPath -ItemType File
        $content = "testContent"
        # Test
        $fileSystem.SetContent($testPath, $content)
        # Assert
        $fileSystem.GetContent($testPath) | Should -Be $content
        # Cleanup
        Remove-Item $testPath
    }

    # Continue with similar blocks for SetContent

    It "Throws an exception when the path does not exist" {
        # Setup
        $testPath = "testPath"
        # Test
        $exception = { $fileSystem.CopyItem($testPath, $testDestination) } | Should -Throw
        # Assert
        $exception.Exception.Message | Should -Be "The path 'testPath' does not exist."
    }

    # Continue with similar blocks for GetChildItems, RemoveItem, JoinPath, TestPath, NewItem, MoveItem, RenameItem, GetContent, and SetContent
}