# Enumerate.Tests.ps1
# Property 1: ?t?H???_??????S??
# Validates: Requirements 1.1, 1.2, 1.3
# Tag: Feature: unicode-normalize-rename, Property 1: ?t?H???_??????S??

$script:ScriptPath = (Resolve-Path "$PSScriptRoot/../../normalize-rename.ps1").Path

Describe "Enumerate - Property 1: ?t?H???_??????S??" -Tags "Feature: unicode-normalize-rename, Property 1: ?t?H???_??????S??" {

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

    It "Property 1: data-before ??????S?T?u?t?H???_?????????" {
        # **Validates: Requirements 1.1**

        # data-before ???????T?u?t?H???_???
        $dataBefore = Join-Path $script:TempRoot "data-before"
        New-Item -ItemType Directory -Path (Join-Path $dataBefore "folderA") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $dataBefore "folderB") -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $dataBefore "folderC") -Force | Out-Null

        # ?t?@?C???V?X?e?????????T?u?t?H???_?W??
        $expected = (Get-ChildItem -Path $dataBefore -Directory | Select-Object -ExpandProperty Name | Sort-Object)

        # ?X?N???v?g??T?u?v???Z?X???????s?i$PSScriptRoot ?? TempRoot ??w??????R?s?[?j
        $scriptCopy = Join-Path $script:TempRoot "normalize-rename.ps1"
        Copy-Item -Path $script:ScriptPath -Destination $scriptCopy

        $outFile = Join-Path $script:TempRoot "out.txt"
        $errFile = Join-Path $script:TempRoot "err.txt"
        $proc = Start-Process powershell -ArgumentList "-NoProfile", "-File", $scriptCopy `
            -WorkingDirectory $script:TempRoot `
            -PassThru -Wait `
            -RedirectStandardOutput $outFile `
            -RedirectStandardError $errFile `
            -NoNewWindow
        $proc.ExitCode | Should Be 0

        # data-after ????????t?H???_?W?????t?@?C???V?X?e?????W?????v???�??
        $dataAfter = Join-Path $script:TempRoot "data-after"
        $dataAfter | Should Exist
        $actual = (Get-ChildItem -Path $dataAfter -Directory | Select-Object -ExpandProperty Name | Sort-Object)

        ($actual -join "`n") | Should Be ($expected -join "`n")
    }
}

Describe "Enumerate - ?v?? 1.2: data-before ?s?????G???[?I??" {

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

    It "1.2: data-before ?????????????A?I???R?[?h 1 ??I??????" {
        # **Validates: Requirements 1.2**

        # data-before ????????
        $scriptCopy = Join-Path $script:TempRoot "normalize-rename.ps1"
        Copy-Item -Path $script:ScriptPath -Destination $scriptCopy

        $outFile = Join-Path $script:TempRoot "out.txt"
        $errFile = Join-Path $script:TempRoot "err.txt"
        $proc = Start-Process powershell -ArgumentList "-NoProfile", "-File", $scriptCopy `
            -WorkingDirectory $script:TempRoot `
            -PassThru -Wait `
            -RedirectStandardOutput $outFile `
            -RedirectStandardError $errFile `
            -NoNewWindow

        $proc.ExitCode | Should Be 1
    }
}

Describe "Enumerate - ?v?? 1.3: ??t?H???_???????I??" {

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

    It "1.3: data-before ???????A?I???R?[?h 0 ??I?????u???????t?H???_?????????????v??o?????" {
        # **Validates: Requirements 1.3**

        # ??? data-before ???
        $dataBefore = Join-Path $script:TempRoot "data-before"
        New-Item -ItemType Directory -Path $dataBefore -Force | Out-Null

        $scriptCopy = Join-Path $script:TempRoot "normalize-rename.ps1"
        Copy-Item -Path $script:ScriptPath -Destination $scriptCopy

        $outFile = Join-Path $script:TempRoot "out.txt"
        $errFile = Join-Path $script:TempRoot "err.txt"
        $proc = Start-Process powershell -ArgumentList "-NoProfile", "-File", $scriptCopy `
            -WorkingDirectory $script:TempRoot `
            -PassThru -Wait `
            -RedirectStandardOutput $outFile `
            -RedirectStandardError $errFile `
            -NoNewWindow

        $proc.ExitCode | Should Be 0

        $outputBytes = [System.IO.File]::ReadAllBytes($outFile)
        $output = [System.Text.Encoding]::GetEncoding(932).GetString($outputBytes)
        $output | Should Match "処理対象フォルダ"
    }
}