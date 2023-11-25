Describe "FileSystem Tests" {
    BeforeAll {
        . "$PSScriptRoot\FileSystem.ps1"
        $fileSystem = [FileSystem]::new()
        $testPath = "C:\myscripts\testing"
        $testFile = "test.txt"
        $content = "Hello, World!"
        $newContent = "New Content"
        $childPath = "childFolder"
        $newName = "renamed.txt"
        
        if (-not (Test-Path -Path $testPath)) {
            New-Item -Path $testPath -ItemType Directory
        }
    }

    AfterAll {
        Remove-Item -Path $testPath -Recurse -Force
    }

    It "Copies a file" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            $destinationPath = Join-Path -Path $testPath -ChildPath "copy_$testFile"
            Set-Content -Path $filePath -Value $content

            $fileSystem.CopyItem($filePath, $destinationPath)
            $copied = Test-Path $destinationPath

            $copied | Should -Be $true
        } finally {
            Remove-Item $filePath, $destinationPath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Copies a file with force" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            $destinationPath = Join-Path -Path $testPath -ChildPath "copy_$testFile"
            Set-Content -Path $filePath -Value $content
            Set-Content -Path $destinationPath -Value $newContent

            $fileSystem.CopyItem($filePath, $destinationPath, $true, $false)
            $copiedContent = Get-Content $destinationPath

            $copiedContent | Should -Be $content
        } finally {
            Remove-Item $filePath, $destinationPath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Recursively copies a directory with force" {
        try {
            $dirPath = Join-Path -Path $testPath -ChildPath $childPath
            $destinationDirPath = Join-Path -Path $testPath -ChildPath "copy_$childPath"
            New-Item -Path $dirPath -ItemType Directory
            $childFilePath = Join-Path -Path $dirPath -ChildPath $testFile
            Set-Content -Path $childFilePath -Value $content

            $fileSystem.CopyItem($dirPath, $destinationDirPath, $true, $true)
            $copied = Test-Path $destinationDirPath

            $copied | Should -Be $true
        } finally {
            Remove-Item $dirPath, $destinationDirPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "Moves a file" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            $destinationPath = Join-Path -Path $testPath -ChildPath "move_$testFile"
            Set-Content -Path $filePath -Value $content

            $fileSystem.MoveItem($filePath, $destinationPath)
            $moved = Test-Path $destinationPath

            $moved | Should -Be $true
        } finally {
            Remove-Item $destinationPath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Moves a file with force" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            $destinationPath = Join-Path -Path $testPath -ChildPath "move_$testFile"
            Set-Content -Path $filePath -Value $content
            Set-Content -Path $destinationPath -Value $newContent

            $fileSystem.MoveItem($filePath, $destinationPath, $true)
            $movedContent = Get-Content $destinationPath

            $movedContent | Should -Be $content
        } finally {
            Remove-Item $destinationPath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Gets child items" {
        try {
            $dirPath = Join-Path -Path $testPath -ChildPath $childPath
            New-Item -Path $dirPath -ItemType Directory
            $childFilePath = Join-Path -Path $dirPath -ChildPath $testFile
            Set-Content -Path $childFilePath -Value $content

            $childItems = $fileSystem.GetChildItems($dirPath)
            $hasFile = $childItems.Name -contains $testFile

            $hasFile | Should -Be $true
        } finally {
            Remove-Item $dirPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "Recursively gets child items" {
        try {
            $dirPath = Join-Path -Path $testPath -ChildPath $childPath
            $subDirPath = Join-Path -Path $dirPath -ChildPath "subFolder"
            New-Item -Path $subDirPath -ItemType Directory -Force
            $childFilePath = Join-Path -Path $subDirPath -ChildPath $testFile
            Set-Content -Path $childFilePath -Value $content

            $childItems = $fileSystem.GetChildItems($testPath, $true)
            $hasFile = $childItems.FullName -contains $childFilePath

            $hasFile | Should -Be $true
        } finally {
            Remove-Item $dirPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "Removes an item" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            Set-Content -Path $filePath -Value $content

            $fileSystem.RemoveItem($filePath)
            $exists = Test-Path $filePath

            $exists | Should -Be $false
        } finally {
            Remove-Item $filePath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Recursively removes an item" {
        try {
            $dirPath = Join-Path -Path $testPath -ChildPath $childPath
            New-Item -Path $dirPath -ItemType Directory

            $fileSystem.RemoveItem($dirPath, $true, $false)
            $exists = Test-Path $dirPath

            $exists | Should -Be $false
        } finally {
            Remove-Item $dirPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "Forcibly removes an item" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            Set-Content -Path $filePath -Value $content
            Set-ItemProperty -Path $filePath -Name IsReadOnly -Value $true

            $fileSystem.RemoveItem($filePath, $true, $true)
            $exists = Test-Path $filePath

            $exists | Should -Be $false
        } finally {
            Remove-Item $filePath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Joins paths" {
        $joinedPath = $fileSystem.JoinPath($testPath, $testFile)
        $joinedPath | Should -BeExactly "$testPath\$testFile"
    }

    It "Tests if path exists" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            Set-Content -Path $filePath -Value $content

            $exists = $fileSystem.TestPath($filePath)
            $exists | Should -Be $true
        } finally {
            Remove-Item $filePath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Creates a new item" {
        try {
            $dirPath = Join-Path -Path $testPath -ChildPath $childPath

            $fileSystem.NewItem($dirPath, "Directory")
            $exists = Test-Path $dirPath

            $exists | Should -Be $true
        } finally {
            Remove-Item $dirPath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Forcibly creates a new item" {        
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            Set-Content -Path $filePath -Value $content            

            $fileSystem.NewItem($filePath, "File", $true)
            $exists = Test-Path $filePath

            $exists | Should -Be $true
        } finally {
            Remove-Item $filePath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Renames an item" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            $newFilePath = Join-Path -Path $testPath -ChildPath $newName
            Set-Content -Path $filePath -Value $content

            $fileSystem.RenameItem($filePath, $newName)
            $exists = Test-Path $newFilePath

            $exists | Should -Be $true
        } finally {
            Remove-Item $newFilePath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Forcibly renames an item" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            $newFilePath = Join-Path -Path $testPath -ChildPath $newName
            Set-Content -Path $filePath -Value $content            

            $fileSystem.RenameItem($filePath, $newName, $true)
            $exists = Test-Path $newFilePath

            $exists | Should -Be $true
        } finally {
            Remove-Item $newFilePath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Gets the content of a file" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile
            Set-Content -Path $filePath -Value $content

            $fileContent = $fileSystem.GetContent($filePath)
            $fileContent | Should -Be $content
        } finally {
            Remove-Item $filePath -Force -ErrorAction SilentlyContinue
        }
    }

    It "Sets the content of a file" {
        try {
            $filePath = Join-Path -Path $testPath -ChildPath $testFile

            $fileSystem.SetContent($filePath, $newContent)
            $fileContent = Get-Content $filePath

            $fileContent | Should -Be $newContent
        } finally {
            Remove-Item $filePath -Force -ErrorAction SilentlyContinue
        }
    }
}
