# Wikiコンテンツ更新

このPRは、SQLServer-Utilリポジトリの自動生成されたインデックスに基づいて、Wikiコンテンツを提供します。

## Wikiページの作成/更新

### ホームページ
既存のホームページの内容を以下に置き換えてください：

```markdown
# SQLServer-Util

## 概要

SQLServer-Utilは、SQL Serverの監視、管理、およびトラブルシューティングのための包括的なツールキットです。このリポジトリは、SQL Serverデータベース管理者、開発者、DevOpsエンジニアに、パフォーマンスのボトルネックを特定し、問題をトラブルシューティングし、一般的な管理タスクを自動化するためのスクリプトとユーティリティを提供します。

このリポジトリには、リアルタイム監視用のPowerShellスクリプト、動的管理ビュー（DMV）からシステム情報を取得するためのSQLクエリ、パフォーマンスカウンターのリファレンスドキュメント、およびAzureでのSQL Server管理インスタンスを管理するためのツールが含まれています。ブロッキングチェーンの監視、アクティブセッションの分析、メモリ使用率の追跡、インデックスパフォーマンスの測定、CI/CDパイプラインを通じたデータベースのデプロイなどを効果的に行うことができます。

このツールキットはモジュール式に設計されており、管理者は特定の要件に基づいて個々のコンポーネントを必要に応じて使用できます。パフォーマンスの問題を調査する場合でも、監視をセットアップする場合でも、デプロイメントを自動化する場合でも、SQLServer-Utilは必要なツールとリファレンスを提供します。

## Wikiページ

* [プロジェクト構成](Project-Organization) - リポジトリの構造と主要コンポーネントの詳細
* [用語集](Glossary) - コードベース固有の用語の定義
* [ツール](Tools) - 外部ツールとリソース
```

### プロジェクト構成ページ
「プロジェクト構成」というタイトルの新しいページを作成し、以下の内容を追加してください：

```markdown
# プロジェクト構成

このリポジトリは機能領域ごとに整理されており、各ディレクトリはSQL Server管理と監視の特定の側面に焦点を当てています：

## コアシステムとサービス

1. **ブロッキングチェーン監視**
   - `Lock/BlockingChain.ps1`：SQL Serverインスタンス内のブロッキングチェーンを識別して報告するPowerShellスクリプト
   - システムビューに対する再帰的クエリを使用して、ブロッキング関係の視覚的な表現を構築
   - SQLテキストやリソース情報を含むブロッキングセッションの詳細をJSON形式で出力

2. **SQL Database管理インスタンスツール**
   - `SQL Database Managed Instance/Set-MIPortForward.ps1`：Azure SQL管理インスタンスへのポート転送を設定
   - Windows `netsh`コマンドを使用してポート転送ルールを作成
   - 正しいエンドポイント情報を決定するためにMIのシステムビューをクエリ

3. **DMVクエリコレクション**
   - `Query/`、`Lock/`、`Wait/`、`Index/`などのディレクトリに整理された様々な`.sql`ファイル
   - SQL Server操作の異なる側面についてシステムビューとDMVから情報を取得
   - 個々のSQLスクリプトの実行を通じたメインエントリポイント

4. **リアルタイムセッション監視**
   - `Tools/EZMonitor/SessionMonitor.ps1`：SQL Serverセッションをリアルタイムで監視
   - クエリ、リソース使用率、待機統計に関する情報を表示
   - セッションデータのインタラクティブな表示にPowerShellのOut-GridViewを使用

5. **パフォーマンスカウンターリファレンス**
   - `Performance Monitor/README.md`：パフォーマンスカウンターの包括的なドキュメント
   - OS、SQL Server、AlwaysOnカテゴリに整理
   - 推奨しきい値と解釈ガイダンスを含む

6. **DBCCとトレースフラグリファレンス**
   - `DBCC/Trace Flag.sql`：SQL Serverの動作を変更するためのトレースフラグのドキュメント
   - `DBCC/DBCC Command.sql`：管理とトラブルシューティングに使用されるDBCCコマンドのリファレンス
   - 使用例と互換性情報を含む

7. **データベースCI/CDパイプライン**
   - `CI_CD/Azure DevOps/Build_DBProject.yml`：データベースプロジェクト用のAzure DevOpsパイプライン
   - DACPACを使用したデータベースプロジェクトのビルドとデプロイ
   - コンテナ化されたエージェントを介したDatadog監視との統合

## 主要ファイルとディレクトリ

- `Lock/`：ロックとブロッキングに関連するスクリプトを含む（高優先度の`BlockingChain.ps1`を含む）
- `SQL Database Managed Instance/`：Azure SQL管理インスタンスを操作するためのツール
- `Performance Monitor/`：監視用のパフォーマンスカウンターのドキュメント
- `DBCC/`：DBCCコマンドとトレースフラグのリファレンス
- `Query/`：実行中のクエリに関する情報を取得するためのスクリプト
- `Wait/`：待機統計を分析するためのスクリプト
- `Index/`：インデックスの使用状況と保守を監視するためのスクリプト
- `Memory/`：メモリ使用状況を分析するためのスクリプト
- `Tools/EZMonitor/`：リアルタイム監視ツール
- `CI_CD/`：CI/CDパイプライン設定
- `Datadog/`：Datadog監視統合
- `Database Project/`：スキーマ定義を含むサンプルデータベースプロジェクト
- `PowerShell/`：様々なSQL Server操作用のPowerShellスクリプト
- `README.md`：リポジトリの概要を提供するメインドキュメントファイル

## 主要機能とクラス

1. **BlockingChain.ps1**
   - ブロッキングチェーンを識別するために再帰的CTEを使用
   - 主な機能：他のセッションをブロックしているセッションを検出して報告
   - ブロッキング階層情報をJSONで出力

2. **Set-MIPortForward.ps1**
   - 主な機能：Azure SQL管理インスタンスへのポート転送を設定
   - `netsh interface portproxy`コマンドを使用
   - エンドポイント情報を取得するためにSQL MIシステムビューをクエリ

3. **SessionMonitor.ps1**
   - 主な機能：アクティブなSQLセッションを継続的に監視
   - セッション情報を収集するためにDMVを使用
   - PowerShell Grid Viewで結果を表示

4. **Install-SQLServer.ps1**
   - SQL Serverインストール用のPowerShell DSC設定
   - `xSQLServer` DSCモジュールを使用
   - LCMとSQLServerの設定ブロックを定義

5. **SQLクエリスクリプト**
   - システム情報を取得するための様々なSQLスクリプト
   - ほとんどのスクリプトは、包括的な情報を提供するために複数のシステムビューを結合するパターンに従う
   - スクリプトは機能領域（ロック、待機、クエリなど）ごとに整理
```

### 用語集ページ
「用語集」というタイトルの新しいページを作成し、以下の内容を追加してください：

```markdown
# コードベース固有の用語集

1. **BlockingChain**：ツリー構造でSQLブロッキング関係を識別するスクリプト。[`Lock/BlockingChain.ps1`]

2. **blocked_path**：ブロックされたプロセスのパスを示す文字列（例：「1 <- 2 <- 3」）。[`Lock/BlockingChain.ps1`]

3. **Set-MIPortForward**：SQL管理インスタンスへのポート転送を設定するPowerShellスクリプト。[`SQL Database Managed Instance/Set-MIPortForward.ps1`]

4. **netsh portproxy**：ポート転送ルールを作成するために使用されるWindowsネットワークコマンド。[`SQL Database Managed Instance/Set-MIPortForward.ps1`]

5. **SQLServerUtil**：システムビューから情報を取得するためのリポジトリのユーティリティコレクション。[`README.md`]

6. **DMV（動的管理ビュー）**：内部サーバー状態情報を提供するSQL Serverビュー。[様々な.sqlファイル]

7. **SessionMonitor**：アクティブセッションに関するリアルタイム情報を表示するPowerShellスクリプト。[`Tools/EZMonitor/SessionMonitor.ps1`]

8. **EZMonitor**：SQL Serverアクティビティの簡易監視ツールのコレクション。[`Tools/EZMonitor/`]

9. **トレースフラグ**：DBCC TRACEONを介して設定される、SQL Serverの動作を変更する設定。[`DBCC/Trace Flag.sql`]

10. **DBCCコマンド**：メンテナンスと診断タスクのためのデータベースコンソールコマンド。[`DBCC/DBCC Command.sql`]

11. **SQLメモリモデル**：SQL Serverで使用されるメモリ管理アーキテクチャ。[`Memory/System Memory.sql`]

12. **ページ寿命予測（PLE）**：ページがバッファプールに滞在する秒数。値が低いとメモリ圧力を示す。[`Performance Monitor/README.md`]

13. **DACPAC**：データベーススキーマをデプロイするためのデータ層アプリケーションパッケージ。[`CI_CD/Azure DevOps/Build_DBProject.yml`]

14. **ProjectDB**：スキーマ定義とデプロイメント設定を含むサンプルデータベースプロジェクト。[`Database Project/ProjectDB/`]

15. **xSQLServer**：SQL Server管理用のリソースを含むPowerShell DSCモジュール。[`PowerShell/DSC/Install-SQLServer.ps1`]

16. **Datadogエージェント**：SQLメトリクスを収集するためにAzure Container Instanceとしてデプロイされる監視エージェント。[`Datadog/Azure Container Instance/`]

17. **ブロッキングセッションID**：他のセッションをブロックしているセッションのSPID。[様々な.sqlファイル]

18. **sys.dm_exec_requests**：SQL Serverで実行中の各リクエストに関する情報を返すDMV。[様々な.sqlファイル]

19. **sys.dm_os_waiting_tasks**：待機中のタスクに関する情報を返すDMV。[様々な.sqlファイル]

20. **sys.dm_exec_sql_text**：SQLハンドルに関連付けられたSQLテキストを返すDMV。[様々な.sqlファイル]

21. **バッファキャッシュヒット率**：メモリ内で見つかったページの割合。重要なパフォーマンスカウンター。[`Performance Monitor/README.md`]

22. **待機統計**：SQL Serverセッションが何を待っているかに関するデータ。パフォーマンストラブルシューティングの鍵。[`Wait/`]

23. **DBCC MEMORYSTATUS**：メモリ情報用のDMVに置き換えられたコマンド。[`Memory/DBCC MEMORYSTATUS 相当の DMV.sql`]

24. **インデックス使用統計**：データベース内でインデックスがどのように使用されているかに関するデータ。[`Index/`]

25. **AlwaysOnカウンター**：可用性グループに固有のパフォーマンスカウンター。[`Performance Monitor/README.md`]
```

## Wikiの更新方法

1. [SQLServer-Util Wiki](https://github.com/MasayukiOzawa/SQLServer-Util/wiki)にアクセスします
2. ホームページを更新し、「プロジェクト構成」と「用語集」ページを上記の内容で作成します
3. 既存の「ツール」ページは保持します
