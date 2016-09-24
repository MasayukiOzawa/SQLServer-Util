# SQLServerUtil
[![Build status](https://ci.appveyor.com/api/projects/status/mxr4mrm2jf4nnntr?svg=true)](https://ci.appveyor.com/project/MasayukiOzawa/sqlserverutil)

SQL Server の各種システムビュー/動的管理ビューから情報を取得するためのクエリ群です。

本リポジトリでは、以下の情報を取得するための各種クエリ/ツールを公開しています。

|ディレクトリ|内容|
|:--------|:---|
|AlwaysOn|可用性グループの各種情報を取得|
|Backup|バックアップの取得状態を取得|
|Buffer Cache|バッファキャッシュの使用状況を取得|
|DISKSPD|ディスク性能測定ツールの DiskSpd のサンプルツール|
|Database|データベースの情報を取得|
|Encryption|暗号化用のサンプルツール|
|Index|インデックスの使用状況 / 状態を取得|
|Instance|インスタンスの情報を所得|
|Lock|ロック / ブロッキングの情報を取得|
|Management Tools|SQL Server の各種管理を実施するためのサンプルツール|
|Performance Monitor|SQL Server に関係するパフォーマンスモニターのカウンター|
|Plan Cache|プランキャッシュの使用状況を取得|
|PowerShell|SQL Server のクエリ実行を PowerShell で実施するためのサンプルツール|
|Query|実行中のクエリの情報を取得|
|Session|セッション情報を取得|
|tempdb|tempdb の使用状況を取得|
|Wait|待ち事象の情報を取得|
|xEvent|拡張イベントの取得と解析|

情報の取得を行う場合は、以下のツールも参考になります。

*情報取得*

* [SQL Server Performance Dashboards](https://sqldashboards.codeplex.com/)
* [MSSQLTIGERDemos](https://github.com/amitmsft/MSSQLTIGERDemos/)
* [SQL Live Monitor](https://sqlmonitor.codeplex.com/)
* [SQL Nexus Tool](https://sqlnexus.codeplex.com/)
* [Pssdiag and Sqldiag Manager](http://diagmanager.codeplex.com/)

*情報取得クエリ*

* [SQL Server First Responder Kit](https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit)
* [DatabaseStack](https://github.com/unruledboy/DatabaseStack)
* [SQL Server KIT](https://github.com/ktaranov/sqlserver-kit)