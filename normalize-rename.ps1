# normalize-rename.ps1
# Unicode NFC normalization rename script
# Copies folders from data-before to data-after and renames items with combining marks (U+3099/U+309A) to NFC form

function Get-NfcName {
    param(
        [string]$name
    )
    return $name.Normalize([System.Text.NormalizationForm]::FormC)
}

function Test-HasCombiningMark {
    param(
        [string]$name
    )
    return [bool]($name -match '[\u3099\u309A]')
}

function Rename-ToNfc {
    param(
        [string]$itemPath
    )
    $name = Split-Path $itemPath -Leaf
    if (-not (Test-HasCombiningMark $name)) {
        Write-Host "スキップ（Combining_Mark なし）: $name"
        return
    }
    $nfcName = Get-NfcName $name
    $parentDir = Split-Path $itemPath -Parent
    $nfcPath = Join-Path $parentDir $nfcName
    if (Test-Path $nfcPath) {
        Write-Error "スキップ（同名アイテムが既に存在します）: $nfcPath"
        return
    }
    try {
        Rename-Item -Path $itemPath -NewName $nfcName
        Write-Host "リネーム: $name -> $nfcName"
    } catch {
        Write-Error "リネーム失敗: $itemPath - $_"
    }
}

function Copy-SourceFolder {
    param(
        [string]$sourcePath,
        [string]$destRoot
    )
    if (-not (Test-Path $destRoot)) {
        New-Item -ItemType Directory -Path $destRoot | Out-Null
    }
    $destPath = Join-Path $destRoot (Split-Path $sourcePath -Leaf)
    Copy-Item -Recurse -Path $sourcePath -Destination $destPath
    Write-Host "コピー元: $sourcePath"
    Write-Host "コピー先: $destPath"
    return $destPath
}

# --- メインスクリプト本体 ---

$sourceRoot = Join-Path $PSScriptRoot "data-before"
$destRoot   = Join-Path $PSScriptRoot "data-after"

# 要件 1.2: data-before が存在しない場合はエラー出力して終了
if (-not (Test-Path $sourceRoot)) {
    Write-Error "data-before ディレクトリが見つかりません: $sourceRoot"
    exit 1
}

# 要件 1.1: data-before 直下のサブフォルダを列挙
$sourceFolders = Get-ChildItem -Path $sourceRoot -Directory

# 要件 1.3: サブフォルダが存在しない場合はメッセージ出力して正常終了
if ($sourceFolders.Count -eq 0) {
    Write-Host "処理対象フォルダが見つかりません"
    exit 0
}

# 要件 2.1, 4.1, 5.1: 各 Source_Folder を処理
foreach ($folder in $sourceFolders) {
    # フォルダを data-after へコピー
    $copiedFolderPath = Copy-SourceFolder -sourcePath $folder.FullName -destRoot $destRoot

    # コピー先フォルダ自体を NFC リネーム
    Rename-ToNfc -itemPath $copiedFolderPath

    # リネーム後のフォルダパスを算出
    $folderName        = Split-Path $copiedFolderPath -Leaf
    $nfcFolderName     = Get-NfcName $folderName
    $renamedFolderPath = Join-Path $destRoot $nfcFolderName

    # フォルダ内の各ファイルを NFC リネーム
    Get-ChildItem -Path $renamedFolderPath -File | ForEach-Object {
        Rename-ToNfc -itemPath $_.FullName
    }
}
