-- 自動拡張発生時のデータファイルの均等拡張
-- SQL Server 2016 以降は tempdb はデフォルトで有効, 2016 は、ユーザーデータベースはトレースフラグではなくデータベースオプションで設定する(トレースラグでは設定しても動作しない)
DBCC TRACEON(1117, -1)

-- 混合エクステントによる割り当ての停止
-- SQL Server 2016 以降は tempdb はデフォルトで有効, 2016 は、ユーザーデータベースはトレースフラグではなくデータベースオプションで設定する(トレースラグでは設定しても動作しない)
DBCC TRACEON(1118, -1)

-- デッドロックの情報取得
DBCC TRACEON(1204, -1)
DBCC TRACEON(1222, -1) -- SQL Server 2005 以降で追加されたフラグ

-- ロックエスカレーションの設定変更
-- メモリ / ロック数に基づいてのロックエスカレーションの無効化
DBCC TRACEON(1211, -1)
-- ロック数に基づいてのロックエスカレーションの無効化
DBCC TRACEON(1224, -1)

-- CardinalityEstimationModelVersion = 70 の基数見積もり (推定) の利用
-- SQL Server 2016 以降はデータベースオプションでも設定可能
DBCC TRACEON(9481, -1)

-- パラメータースニッフィングの無効化
-- SQL Server 2016 以降はデータベースオプションでも設定可能
DBCC TRACEON(4136, -1)

-- クエリオプティマイザーの修正プログラムの有効化
-- 互換性レベル 130 ではデフォルトで有効化
DBCC TRACEON(4199, -1)

-- 圧縮したデータベースバックアップ取得時の事前の領域割り当ての防止
DBCC TRACEON(3042, -1)

-- バックアップ時の ERROR LOG への完了メッセージの出力停止
DBCC TRACEON(3226, -1)

-- NUMA ノードあたり 8 コアの CPU がある環境での CMemThread の削減
-- SQL Server 2014 までの環境で使用, SQL Server 2016 では自動 Soft-NUMA が有効になるため、この機構で削減される
DBCC TRACEON(8048, -1)

-- AlwaysOn のログストリーミング転送の圧縮を無効
-- SQL Server 2012 / 2014 では、デフォルトで有効
DBCC TRACEON(1462, -1)

-- AlwaysOn のログストリーミング転送の圧縮を有効
-- SQL Server 2016 では、デフォルトで無効
DBCC TRACEON(9592, -1)

-- Direct Seeding 使用時のデータストリームの圧縮
DBCC TRACEON(9567, -1)

-- sys.dm_os_memory_node_access_stats で NUMA ノード間のメモリアクセスの情報を取得可能とする
DBCC TRACEON(842, -1)
