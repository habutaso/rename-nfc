# 実装計画: unicode-normalize-rename

## Overview

PowerShell スクリプト `normalize-rename.ps1` を実装する。ユーティリティ関数から順に実装し、最後にメインスクリプト本体で統合する。Pester を使ったユニットテスト・統合テストも合わせて作成する。

## Tasks

- [x] 1. プロジェクト構造とテスト基盤のセットアップ
  - `normalize-rename.ps1` の空ファイルを作成する
  - `tests/unit/helpers/Generators.ps1` にランダム入力生成ヘルパー関数を実装する
    - `New-RandomStringWithCombiningMarks`: U+3099/U+309A を含むランダム文字列を生成
    - `New-RandomStringWithoutCombiningMarks`: Combining_Mark を含まないランダム文字列を生成
  - _Requirements: 3.1, 4.1, 5.2_

- [x] 2. `Test-HasCombiningMark` 関数の実装とテスト
  - [x] 2.1 `Test-HasCombiningMark` 関数を `normalize-rename.ps1` に実装する
    - U+3099 または U+309A を含む場合に `$true`、含まない場合に `$false` を返す
    - 正規表現 `[\u3099\u309A]` を使用する
    - _Requirements: 3.1, 3.2_
  - [x] 2.2 `Test-HasCombiningMark` のプロパティテストを `tests/unit/Test-HasCombiningMark.Tests.ps1` に実装する
    - **Property 4: Combining_Mark 検出の正確性**
    - **Validates: Requirements 3.1, 3.2**
    - Combining_Mark を含む入力で `$true`、含まない入力で `$false` を返すことを 100 イテレーションで検証する

- [x] 3. `Get-NfcName` 関数の実装とテスト
  - [x] 3.1 `Get-NfcName` 関数を `normalize-rename.ps1` に実装する
    - `.NET` の `String.Normalize([System.Text.NormalizationForm]::FormC)` を使用する
    - _Requirements: 4.1, 4.2, 5.2_
  - [x] 3.2 `Get-NfcName` のプロパティテストを `tests/unit/Get-NfcName.Tests.ps1` に実装する
    - **Property 5: NFC 変換の正確性と冪等性**
    - **Validates: Requirements 4.1, 4.2, 5.2, 5.3**
    - 変換後に U+3099/U+309A が含まれないこと、および `Get-NfcName(Get-NfcName(x)) = Get-NfcName(x)` が成立することを 100 イテレーションで検証する

- [x] 4. Checkpoint - ユニットテストがすべてパスすることを確認する
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. `Copy-SourceFolder` 関数の実装とテスト
  - [x] 5.1 `Copy-SourceFolder` 関数を `normalize-rename.ps1` に実装する
    - `data-after` が存在しない場合は `New-Item -ItemType Directory` で自動作成する
    - `Copy-Item -Recurse` で Source_Folder を再帰コピーする
    - コピー元パスとコピー先パスをコンソールに出力する（要件 6.1）
    - コピー先フォルダのフルパスを返す
    - _Requirements: 2.1, 2.2, 6.1_
  - [x] 5.2 コピーの完全性・元データ不変性の統合テストを `tests/integration/Copy.Tests.ps1` に実装する
    - **Property 2: コピーの完全性**
    - **Validates: Requirements 2.1, 5.1**
    - **Property 3: 元データの不変性**
    - **Validates: Requirements 2.3**
    - 一時ディレクトリを使い、コピー後のファイルツリーが `data-before` と一致すること、および `data-before` が変化しないことを検証する

- [x] 6. `Rename-ToNfc` 関数の実装とテスト
  - [x] 6.1 `Rename-ToNfc` 関数を `normalize-rename.ps1` に実装する
    - `Test-HasCombiningMark` で Combining_Mark がなければスキップしてログ出力する（要件 3.2, 6.3）
    - `Get-NfcName` で NFC 名を生成し、同名アイテムが既に存在する場合はエラーログを出力してスキップする（要件 4.3, 5.4）
    - `Rename-Item` を `try/catch` で囲み、例外時はエラーログを出力して処理継続する
    - リネーム成功時はリネーム前後の名前をコンソールに出力する（要件 6.2）
    - _Requirements: 4.1, 4.2, 4.3, 5.2, 5.3, 5.4, 6.2, 6.3_
  - [x] 6.2 エラーケースの統合テストを `tests/integration/ErrorCases.Tests.ps1` に実装する
    - 同名衝突時にスキップされること（要件 4.3, 5.4）
    - スキップ理由がログに出力されること（要件 6.3）
    - _Requirements: 4.3, 5.4, 6.3_

- [x] 7. メインスクリプト本体の実装とテスト
  - [x] 7.1 メインスクリプト本体を `normalize-rename.ps1` に実装する
    - `data-before` の存在チェック（存在しない場合はエラー出力して `exit 1`）（要件 1.2）
    - `data-before` 直下のサブフォルダ列挙（要件 1.1）
    - サブフォルダが存在しない場合はメッセージ出力して `exit 0`（要件 1.3）
    - 各 Source_Folder に対して `Copy-SourceFolder` → フォルダの `Rename-ToNfc` → 配下ファイルの `Rename-ToNfc` を順に呼び出す（要件 2.1, 4.1, 5.1）
    - _Requirements: 1.1, 1.2, 1.3, 2.1, 4.1, 5.1_
  - [x] 7.2 フォルダ列挙の統合テストを `tests/integration/Enumerate.Tests.ps1` に実装する
    - **Property 1: フォルダ列挙の完全性**
    - **Validates: Requirements 1.1**
    - `data-before` 不在時のエラー終了（要件 1.2）
    - 空フォルダ時の正常終了（要件 1.3）
  - [x] 7.3 ログ出力の統合テストを `tests/integration/Logging.Tests.ps1` に実装する
    - **Property 6: 処理ログの完全性**
    - **Validates: Requirements 6.1, 6.2**
    - コピー時・リネーム時・スキップ時のコンソール出力を検証する

- [x] 8. すべての .ps1 ファイルを Shift-JIS エンコーディングで保存し直す
  - [x] 8.1 `normalize-rename.ps1` を Shift-JIS（コードページ 932）エンコーディングで読み込み、同エンコーディングで上書き保存する
    - `[System.IO.File]::ReadAllText` と `[System.Text.Encoding]::GetEncoding(932)` を使用する
    - _Requirements: 7.1_
  - [x] 8.2 `tests/` 配下のすべての `.ps1` ファイルを Shift-JIS（コードページ 932）エンコーディングで読み込み、同エンコーディングで上書き保存する
    - `Get-ChildItem -Path ./tests -Recurse -Filter *.ps1` で対象ファイルを列挙する
    - 各ファイルを `[System.IO.File]::ReadAllText` で読み込み、`[System.IO.File]::WriteAllText` で Shift-JIS として保存する
    - _Requirements: 7.2_

- [x] 9. Final Checkpoint - 全テストがパスすることを確認する
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- `*` が付いたサブタスクはオプションであり、MVP として省略可能
- 各タスクは要件番号でトレーサビリティを確保している
- プロパティテストは最低 100 イテレーション実行する
- テスト実行コマンド: `Invoke-Pester -Path ./tests -Output Detailed`
