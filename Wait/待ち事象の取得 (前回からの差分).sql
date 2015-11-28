SET NOCOUNT ON
GO

/**************************************************************************/
-- 1.SSMS のテキスト結果のクエリ実行結果の出力形式をカンマ区切りにする
-- 2.新しいクエリを開く
-- 3.以下のクエリの実行結果をファイルに出力
/**************************************************************************/
SELECT GETDATE() time, * 
FROM sys.dm_os_wait_stats 
ORDER BY wait_type ASC
OPTION (RECOMPILE)
WAITFOR DELAY '00:00:10'
GO 100000


/**************************************************************************/
-- テキストをインポートし以下のクエリを実行
-- ヘッダ情報が出力されている場合は、最初のヘッダ以外を削除してインポート
/**************************************************************************/
SELECT 
w1.*
, w1.waiting_tasks_count  - w2.waiting_tasks_count AS waiting_tasks_count_delta
, w1.wait_time_ms  - w2.wait_time_ms AS wait_time_ms_delta
, w1.signal_wait_time_ms - w2.signal_wait_time_ms AS signal_wait_time_ms_delta
FROM 
waitstats w1
OUTER APPLY(
SELECT TOP 1 * 
FROM waitstats
WHERE wait_type = w1.wait_type AND datetime < w1.datetime
ORDER BY DateTime DESC
) AS w2(DateTime, wait_type, waiting_tasks_count, wait_time_ms, max_wait_time_ms, signal_wait_time_ms )
ORDER BY
w1.DateTime
OPTION (RECOMPILE)
GO
