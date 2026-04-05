# ErrorCases.Tests.ps1
# Integration tests for error/skip cases
# Validates: Requirements 4.3, 5.4, 6.3

. "$PSScriptRoot/../../normalize-rename.ps1"

# NFD folder/file name: "ka" (U+304B) + combining dakuten (U+3099) = NFD form of "ga"
# NFC equivalent: U+304C (precomposed "ga")
$script:NfdName = [char]0x304B + [char]0x3099
$script:NfcName = [string][char]0x304C

Describe "Rename-ToNfc - 4.3: Skip on folder name collision" {

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

    It "4.3: NFD folder skipped when NFC folder already exists, and Write-Error is called" {
        # **Validates: Requirements 4.3**

        # Create NFD-named folder (the one to rename)
        $nfdFolderPath = Join-Path $script:TempRoot $script:NfdName
        New-Item -ItemType Directory -Path $nfdFolderPath -Force | Out-Null

        # Pre-create NFC-named folder (collision target)
        $nfcFolderPath = Join-Path $script:TempRoot $script:NfcName
        New-Item -ItemType Directory -Path $nfcFolderPath -Force | Out-Null

        # Call Rename-ToNfc and capture errors via $Error
        $Error.Clear()
        Rename-ToNfc -itemPath $nfdFolderPath -ErrorAction SilentlyContinue

        # NFD folder should still exist (not renamed)
        $nfdFolderPath | Should Exist

        # NFC folder should still exist (unchanged)
        $nfcFolderPath | Should Exist

        # An error should have been written
        $Error.Count | Should BeGreaterThan 0
    }
}

Describe "Rename-ToNfc - 5.4: Skip on file name collision" {

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

    It "5.4: NFD file skipped when NFC file already exists, and Write-Error is called" {
        # **Validates: Requirements 5.4**

        # Create NFD-named file (the one to rename)
        $nfdFileName = $script:NfdName + ".txt"
        $nfdFilePath = Join-Path $script:TempRoot $nfdFileName
        Set-Content -Path $nfdFilePath -Value "nfd content" -Encoding UTF8

        # Pre-create NFC-named file (collision target)
        $nfcFileName = $script:NfcName + ".txt"
        $nfcFilePath = Join-Path $script:TempRoot $nfcFileName
        Set-Content -Path $nfcFilePath -Value "nfc content" -Encoding UTF8

        # Call Rename-ToNfc and capture errors via $Error
        $Error.Clear()
        Rename-ToNfc -itemPath $nfdFilePath -ErrorAction SilentlyContinue

        # NFD file should still exist (not renamed)
        $nfdFilePath | Should Exist

        # NFC file should still exist with original content
        $nfcFilePath | Should Exist
        (Get-Content -Raw -Path $nfcFilePath).Trim() | Should Be "nfc content"

        # An error should have been written
        $Error.Count | Should BeGreaterThan 0
    }
}

Describe "Rename-ToNfc - 6.3: Skip item without Combining_Mark" {

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

    It "6.3: Item without Combining_Mark is not renamed" {
        # **Validates: Requirements 6.3**

        # Create a plain ASCII folder (no combining marks)
        $plainName = "plain-folder"
        $plainPath = Join-Path $script:TempRoot $plainName
        New-Item -ItemType Directory -Path $plainPath -Force | Out-Null

        # Call Rename-ToNfc - should skip without error
        $Error.Clear()
        Rename-ToNfc -itemPath $plainPath -ErrorAction SilentlyContinue

        # Folder should still exist with original name (not renamed)
        $plainPath | Should Exist

        # No errors should have been written
        $Error.Count | Should Be 0
    }
}
