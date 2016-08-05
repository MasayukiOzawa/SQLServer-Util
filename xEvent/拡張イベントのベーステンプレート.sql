/********************************************************************************/
-- 拡張イベントでクエリ情報を取得する際のベーステンプレート
/********************************************************************************/
-- ロック競合が発生したクエリ (blocked prosess threshold の設定が必要)
-- SQL Server がトラップできたエラー (いくつかのイベントはフィルターしているが、エラー量が多い場合は調整が必要)
-- メモリ許可の待機が 1 秒以上発生したクエリ
-- ハッシュ結合時のメモリ不足が発生したクエリ
-- 統計が設定されていない列に対して実行されたクエリ
-- ソート時にメモリ不足が発生したクエリ
-- 実行完了に 3 秒以上かかったクエリ (Statement / Batch / RPC)リ
-- デッドロックレポート/デッドロックチェーン
/********************************************************************************/
CREATE EVENT SESSION [Basic_Trace] ON SERVER 
ADD EVENT sqlserver.blocked_process_report(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([error_number]<>(5701) AND [error_number]<>(5703) AND [error_number]<>(0))),
ADD EVENT sqlserver.execution_warning(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.hash_warning(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.lock_deadlock_chain(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.missing_column_statistics(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.sort_warning(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.sql_statement_completed(SET collect_parameterized_plan_handle=(0),collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.plan_affecting_convert(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
    WHERE ([package0].[equal_uint64]([convert_issue],(2)) AND [sqlserver].[database_id]>=(5))),
ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'Basic_Trace',max_file_size=(100),max_rollover_files=(10))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO


-- 拡張イベントの開始
ALTER EVENT SESSION [Basic_Trace] ON SERVER STATE = START
GO
