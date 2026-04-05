# 要件定義書

## はじめに

本機能は、`data-before` フォルダ内のフォルダおよびファイルを `data-after` フォルダへコピーし、フォルダ名・ファイル名に含まれる結合濁点（U+3099）または結合半濁点（U+309A）を Unicode 正規化（NFC）によって合成済み文字に変換するリネーム処理を PowerShell スクリプトとして実装する。

macOS や一部のシステムでは日本語ファイル名が NFD（結合文字形式）で保存されることがあり、Windows 環境との互換性問題を引き起こす。本スクリプトはその問題を解消するためのバッチ変換ツールである。

## 用語集

- **Script**: 本 PowerShell スクリプト全体
- **Source_Folder**: `data-before` ディレクトリ直下の各サブフォルダ
- **Destination_Root**: `data-after` ディレクトリ（コピー先のルート）
- **Combining_Mark**: Unicode の結合濁点（U+3099）または結合半濁点（U+309A）
- **NFC**: Unicode 正規化形式 C（Canonical Decomposition, followed by Canonical Composition）。結合文字列を合成済み文字に変換する形式
- **NFD**: Unicode 正規化形式 D（Canonical Decomposition）。合成済み文字を結合文字列に分解する形式

---

## 要件

### 要件 1: ソースフォルダの列挙

**ユーザーストーリー:** 開発者として、`data-before` フォルダ内の全サブフォルダを処理対象として取得したい。そうすることで、変換漏れなく全フォルダを処理できる。

#### 受け入れ基準

1. THE Script SHALL `data-before` ディレクトリ直下に存在する全サブフォルダを処理対象として列挙する。
2. IF `data-before` ディレクトリが存在しない場合、THEN THE Script SHALL エラーメッセージを出力してスクリプトを終了する。
3. IF `data-before` ディレクトリ直下にサブフォルダが存在しない場合、THEN THE Script SHALL 「処理対象フォルダが見つかりません」というメッセージを出力して正常終了する。

---

### 要件 2: フォルダのコピー

**ユーザーストーリー:** 開発者として、`data-before` 内の各フォルダを `data-after` へコピーしたい。そうすることで、元データを保持しつつ変換後データを別フォルダで管理できる。

#### 受け入れ基準

1. WHEN Source_Folder の処理を開始するとき、THE Script SHALL Source_Folder を配下のファイルごと `data-after` ディレクトリへ再帰的にコピーする。
2. IF `data-after` ディレクトリが存在しない場合、THEN THE Script SHALL `data-after` ディレクトリを自動的に作成する。
3. THE Script SHALL `data-before` ディレクトリ内の元フォルダおよびファイルを変更しない。

---

### 要件 3: Combining_Mark の検出

**ユーザーストーリー:** 開発者として、コピー後のフォルダ名に Combining_Mark が含まれるか判定したい。そうすることで、正規化が不要なフォルダをスキップして処理を効率化できる。

#### 受け入れ基準

1. WHEN `data-after` へのコピーが完了したとき、THE Script SHALL コピー先フォルダ名に Combining_Mark（U+3099 または U+309A）が含まれるか検査する。
2. IF コピー先フォルダ名に Combining_Mark が含まれない場合、THEN THE Script SHALL そのフォルダのリネーム処理をスキップして次の Source_Folder の処理へ進む。

---

### 要件 4: フォルダ名の NFC 正規化リネーム

**ユーザーストーリー:** 開発者として、Combining_Mark を含むフォルダ名を NFC 正規化した名前にリネームしたい。そうすることで、Windows 環境でも正しく認識されるフォルダ名に統一できる。

#### 受け入れ基準

1. WHEN コピー先フォルダ名に Combining_Mark が含まれるとき、THE Script SHALL フォルダ名を NFC 正規化した文字列に変換する。
2. WHEN NFC 正規化後の名前が元の名前と異なるとき、THE Script SHALL `data-after` 内のフォルダを正規化後の名前にリネームする。
3. IF `data-after` 内に同名の NFC 正規化済みフォルダが既に存在する場合、THEN THE Script SHALL エラーメッセージを出力してそのフォルダのリネームをスキップする。

---

### 要件 5: フォルダ内ファイルの NFC 正規化リネーム

**ユーザーストーリー:** 開発者として、フォルダ内の全ファイル名も NFC 正規化してリネームしたい。そうすることで、ファイル名の互換性問題も同時に解消できる。

#### 受け入れ基準

1. WHEN フォルダ名のリネームが完了したとき（またはフォルダ名に Combining_Mark が含まれない場合でも）、THE Script SHALL リネーム後フォルダ内の全ファイルを列挙する。
2. WHEN ファイル名に Combining_Mark が含まれるとき、THE Script SHALL ファイル名を NFC 正規化した文字列に変換してリネームする。
3. IF ファイル名に Combining_Mark が含まれない場合、THEN THE Script SHALL そのファイルのリネームをスキップする。
4. IF リネーム先に同名ファイルが既に存在する場合、THEN THE Script SHALL エラーメッセージを出力してそのファイルのリネームをスキップする。

---

### 要件 7: ファイルエンコーディング

**ユーザーストーリー:** 開発者として、すべての PowerShell ファイルを Shift-JIS エンコーディングで保存したい。そうすることで、Windows 環境での文字化けなく日本語コメントや文字列リテラルを扱える。

#### 受け入れ基準

1. THE Script SHALL `normalize-rename.ps1` を Shift-JIS（コードページ 932）エンコーディングで保存する。
2. THE Script SHALL `tests/` 配下のすべての PowerShell ファイル（`.ps1`）を Shift-JIS（コードページ 932）エンコーディングで保存する。

---

### 要件 6: 処理結果のログ出力

**ユーザーストーリー:** 開発者として、各フォルダ・ファイルの処理結果をコンソールで確認したい。そうすることで、変換が正しく行われたかをすぐに把握できる。

#### 受け入れ基準

1. WHEN フォルダのコピーが完了したとき、THE Script SHALL コピー元パスとコピー先パスをコンソールに出力する。
2. WHEN フォルダまたはファイルのリネームが完了したとき、THE Script SHALL リネーム前の名前とリネーム後の名前をコンソールに出力する。
3. WHEN フォルダまたはファイルのリネームをスキップしたとき、THE Script SHALL スキップした理由（Combining_Mark なし、または同名ファイル存在）をコンソールに出力する。
