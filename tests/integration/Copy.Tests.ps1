# Copy.Tests.ps1
# Property 2: ?R?s?[????S??
# Property 3: ???f?[?^??s???
# Validates: Requirements 2.1, 2.3, 5.1
# Tag: Feature: unicode-normalize-rename, Property 2: ?R?s?[????S??
# Tag: Feature: unicode-normalize-rename, Property 3: ???f?[?^??s???

. "$PSScriptRoot/../../normalize-rename.ps1"

Describe "Copy-SourceFolder - Property 2: ?R?s?[????S??" -Tags "Feature: unicode-normalize-rename, Property 2: ?R?s?[????S??" {

    $script:TempRoot = $null
    $script:SrcFolder = $null
    $script:DestRoot  = $null

    BeforeEach {
        $guid = [System.Guid]::NewGuid().ToString()
        $script:TempRoot  = Join-Path ([System.IO.Path]::GetTempPath()) $guid
        $script:SrcFolder = Join-Path $script:TempRoot "source"
        $script:DestRoot  = Join-Path $script:TempRoot "dest"

        New-Item -ItemType Directory -Path (Join-Path $script:SrcFolder "sub") -Force | Out-Null
        Set-Content -Path (Join-Path $script:SrcFolder "file1.txt") -Value "hello" -Encoding UTF8
        Set-Content -Path (Join-Path $script:SrcFolder "sub\file2.txt") -Value "world" -Encoding UTF8
    }

    AfterEach {
        if ($script:TempRoot -and (Test-Path $script:TempRoot)) {
            Remove-Item -Recurse -Force -Path $script:TempRoot
        }
    }

    It "Property 2: ?R?s?[????S?? - ?R?s?[???t?@?C???c???[???R?s?[?????v????" {
        # **Validates: Requirements 2.1, 5.1**

        Copy-SourceFolder -sourcePath $script:SrcFolder -destRoot $script:DestRoot

        $srcLeaf  = Split-Path $script:SrcFolder -Leaf
        $destCopy = Join-Path $script:DestRoot $srcLeaf

        $destCopy | Should Exist

        $srcFiles = Get-ChildItem -Recurse -File -Path $script:SrcFolder
        foreach ($srcFile in $srcFiles) {
            $relPath  = $srcFile.FullName.Substring($script:SrcFolder.Length).TrimStart('\', '/')
            $destFile = Join-Path $destCopy $relPath

            $destFile | Should Exist

            $srcContent  = Get-Content -Raw -Path $srcFile.FullName
            $destContent = Get-Content -Raw -Path $destFile
            $destContent | Should Be $srcContent
        }

        $srcDirs = Get-ChildItem -Recurse -Directory -Path $script:SrcFolder
        foreach ($srcDir in $srcDirs) {
            $relPath = $srcDir.FullName.Substring($script:SrcFolder.Length).TrimStart('\', '/')
            $destDir = Join-Path $destCopy $relPath
            $destDir | Should Exist
        }
    }
}

Describe "Copy-SourceFolder - Property 3: ???f?[?^??s???" -Tags "Feature: unicode-normalize-rename, Property 3: ???f?[?^??s???" {

    $script:TempRoot = $null
    $script:SrcFolder = $null
    $script:DestRoot  = $null

    BeforeEach {
        $guid = [System.Guid]::NewGuid().ToString()
        $script:TempRoot  = Join-Path ([System.IO.Path]::GetTempPath()) $guid
        $script:SrcFolder = Join-Path $script:TempRoot "source"
        $script:DestRoot  = Join-Path $script:TempRoot "dest"

        New-Item -ItemType Directory -Path (Join-Path $script:SrcFolder "sub") -Force | Out-Null
        Set-Content -Path (Join-Path $script:SrcFolder "file1.txt") -Value "hello" -Encoding UTF8
        Set-Content -Path (Join-Path $script:SrcFolder "sub\file2.txt") -Value "world" -Encoding UTF8
    }

    AfterEach {
        if ($script:TempRoot -and (Test-Path $script:TempRoot)) {
            Remove-Item -Recurse -Force -Path $script:TempRoot
        }
    }

    It "Property 3: ???f?[?^??s??? - ?R?s?[???R?s?[???t?H???_??É÷??????" {
        # **Validates: Requirements 2.3**

        $beforeNames    = (Get-ChildItem -Recurse -Path $script:SrcFolder | Select-Object -ExpandProperty FullName | Sort-Object)
        $beforeContents = @{}
        Get-ChildItem -Recurse -File -Path $script:SrcFolder | ForEach-Object {
            $beforeContents[$_.FullName] = Get-Content -Raw -Path $_.FullName
        }

        Copy-SourceFolder -sourcePath $script:SrcFolder -destRoot $script:DestRoot

        $afterNames = (Get-ChildItem -Recurse -Path $script:SrcFolder | Select-Object -ExpandProperty FullName | Sort-Object)

        ($afterNames -join "`n") | Should Be ($beforeNames -join "`n")

        Get-ChildItem -Recurse -File -Path $script:SrcFolder | ForEach-Object {
            $afterContent = Get-Content -Raw -Path $_.FullName
            $afterContent | Should Be $beforeContents[$_.FullName]
        }
    }
}