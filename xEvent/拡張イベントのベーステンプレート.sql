/********************************************************************************/
-- 拡張イベントでクエリ情報を取得する際のベーステンプレート
-- 手動開始によるライブモニターのみの設定のため、ターゲットや自動開始を適宜設定
/********************************************************************************/
-- ロック競合が発生したクエリ (blocked prosess threshold の設定が必要)
-- メモリ許可の待機が 1 秒以上発生したクエリ
-- ハッシュ結合時のメモリ不足が発生したクエリ
-- 統計が設定されていない列に対して実行されたクエリ
-- ソート時にメモリ不足が発生したクエリ
-- 実行に 10 秒以上かかったクエリ
-- デッドロックレポート/デッドロックチェーン
/********************************************************************************/
CREATE EVENT SESSION [Query_Trace] ON SERVER 
ADD EVENT sqlserver.blocked_process_report,
ADD EVENT sqlserver.execution_warning(SET collect_server_memory_grants=(1)
    ACTION(sqlserver.sql_text)),
ADD EVENT sqlserver.hash_warning(
    ACTION(sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text)),
ADD EVENT sqlserver.lock_deadlock_chain(SET collect_database_name=(1),collect_resource_description=(1)
    ACTION(sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text)),
ADD EVENT sqlserver.missing_column_statistics(SET collect_column_list=(1)
    ACTION(sqlserver.sql_text)),
ADD EVENT sqlserver.sort_warning(
    ACTION(sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text)),
ADD EVENT sqlserver.sql_batch_completed(SET collect_batch_text=(1)
    WHERE ([duration]>=(10000000))),
ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(sqlserver.sql_text))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


