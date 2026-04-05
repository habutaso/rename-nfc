# Logging.Tests.ps1
# Property 6: Log completeness
# Validates: Requirements 6.1, 6.2, 6.3
# Tag: Feature: unicode-normalize-rename, Property 6: Log completeness

. "$PSScriptRoot/../../normalize-rename.ps1"

# NFD name: U+304B (ka) + U+3099 (combining dakuten) = NFD "ga"
# NFC name: U+304C (precomposed "ga")
$script:NfdName = [char]0x304B + [char]0x3099
$script:NfcName = [string][char]0x304C

Describe "Logging - Property 6: Copy log (Requirement 6.1)" -Tags "Feature: unicode-normalize-rename, Property 6: Log completeness" {

    $script:TempRoot  = $null
    $script:SrcFolder = $null
    $script:DestRoot  = $null

    BeforeEach {
        $guid = [System.Guid]::NewGuid().ToString()
        $script:TempRoot  = Join-Path ([System.IO.Path]::GetTempPath()) $guid
        $script:SrcFolder = Join-Path $script:TempRoot "source"
        $script:DestRoot  = Join-Path $script:TempRoot "dest"
        New-Item -ItemType Directory -Path $script:SrcFolder -Force | Out-Null
        Set-Content -Path (Join-Path $script:SrcFolder "file.txt") -Value "data" -Encoding UTF8
    }

    AfterEach {
        if ($script:TempRoot -and (Test-Path $script:TempRoot)) {
            Remove-Item -Recurse -Force -Path $script:TempRoot
        }
    }

    It "Property 6 (6.1): Copy-SourceFolder outputs source and destination paths via Write-Host" {
        # **Validates: Requirements 6.1**

        $output = (& { Copy-SourceFolder -sourcePath $script:SrcFolder -destRoot $script:DestRoot } *>&1) -join "`n"

        # Source path must appear in output
        $output | Should Match ([regex]::Escape($script:SrcFolder))

        # Destination path must appear in output
        $expectedDest = Join-Path $script:DestRoot (Split-Path $script:SrcFolder -Leaf)
        $output | Should Match ([regex]::Escape($expectedDest))
    }
}

Describe "Logging - Property 6: Rename log (Requirement 6.2)" -Tags "Feature: unicode-normalize-rename, Property 6: Log completeness" {

    $script:TempRoot = $null

    BeforeEach {
        $guid = [System.Guid]::NewGuid().ToString()
        $script:TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) $guid
        New-Item -ItemType Directory -Path $script:TempRoot -Force | Out-Null
    }

    AfterEach {
        if ($script:TempRoot -and (Test-Path $script:TempRoot)) {
            Remove-Item -Recurse -Force -Path $script:TempRoot
        }
    }

    It "Property 6 (6.2): Rename-ToNfc outputs before and after names via Write-Host on folder rename" {
        # **Validates: Requirements 6.2**

        # Create NFD-named folder
        $nfdFolderPath = Join-Path $script:TempRoot $script:NfdName
        New-Item -ItemType Directory -Path $nfdFolderPath -Force | Out-Null

        $output = (& { Rename-ToNfc -itemPath $nfdFolderPath } *>&1) -join "`n"

        # Output must contain the NFD name (before)
        $output | Should Match ([regex]::Escape($script:NfdName))

        # Output must contain the NFC name (after)
        $output | Should Match ([regex]::Escape($script:NfcName))
    }

    It "Property 6 (6.2): Rename-ToNfc outputs before and after names via Write-Host on file rename" {
        # **Validates: Requirements 6.2**

        # Create NFD-named file
        $nfdFileName = $script:NfdName + ".txt"
        $nfdFilePath = Join-Path $script:TempRoot $nfdFileName
        Set-Content -Path $nfdFilePath -Value "content" -Encoding UTF8

        $output = (& { Rename-ToNfc -itemPath $nfdFilePath } *>&1) -join "`n"

        # Output must contain the NFD file name (before)
        $output | Should Match ([regex]::Escape($nfdFileName))

        # Output must contain the NFC file name (after)
        $nfcFileName = $script:NfcName + ".txt"
        $output | Should Match ([regex]::Escape($nfcFileName))
    }
}

Describe "Logging - Property 6: Skip log (Requirement 6.3)" -Tags "Feature: unicode-normalize-rename, Property 6: Log completeness" {

    $script:TempRoot = $null

    BeforeEach {
        $guid = [System.Guid]::NewGuid().ToString()
        $script:TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) $guid
        New-Item -ItemType Directory -Path $script:TempRoot -Force | Out-Null
    }

    AfterEach {
        if ($script:TempRoot -and (Test-Path $script:TempRoot)) {
            Remove-Item -Recurse -Force -Path $script:TempRoot
        }
    }

    It "Property 6 (6.3): Rename-ToNfc outputs skip reason when item has no Combining_Mark" {
        # **Validates: Requirements 6.3**

        # Create a plain folder with no combining marks
        $plainName = "plain-folder"
        $plainPath = Join-Path $script:TempRoot $plainName
        New-Item -ItemType Directory -Path $plainPath -Force | Out-Null

        $output = (& { Rename-ToNfc -itemPath $plainPath } *>&1) -join "`n"

        # Output must mention the item name
        $output | Should Match ([regex]::Escape($plainName))

        # Output must contain skip indicator (ASCII match for "Combining_Mark")
        $output | Should Match "Combining_Mark"
    }
}
