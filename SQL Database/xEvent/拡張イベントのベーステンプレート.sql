/********************************************************************************/
-- 拡張イベントでクエリ情報を取得する際のベーステンプレート
/********************************************************************************/
-- blocked_process_report : ロック競合が発生したクエリ (blocked prosess threshold の設定が必要)
-- error_reported : SQL Server がトラップできたエラー (いくつかのイベントはフィルターしているが、エラー量が多い場合は調整が必要)
-- execution_warning : メモリ許可の待機が 1 秒以上発生したクエリ
-- hash_warning : ハッシュ結合時の tempdb が利用されたクエリ
-- lock_deadlock_chain / xml_deadlock_report : デッドロックレポート/デッドロックチェーン
-- missing_column_statistics : 統計情報の自動更新が無効されており統計が設定されていない列に対して実行されたクエリ
-- plan_affecting_convert : 暗黙の型変換により Seek Plan に影響を与える可能性があるクエリ
-- sort_warning : ソート時に tempdb が利用されたクエリ
-- 実行完了に 3 秒以上かかったクエリ (Statement / Batch / RPC)
-- 複数のイベントの損失を許可 (パフォーマンス優先)
/********************************************************************************/



-- 格納先のストレージアカウントの資格情報作成
/*
DROP DATABASE SCOPED CREDENTIAL [https://<ストレージアカウント名>.blob.core.windows.net/xevents]
DROP EVENT SESSION [Basic_Trace] ON DATABASE 
CREATE MASTER KEY
*/

CREATE DATABASE SCOPED CREDENTIAL [https://<ストレージアカウント名>.blob.core.windows.net/xevents]
WITH
IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = '<SAS Token (sv=xxxx)>'
GO

CREATE EVENT SESSION [Basic_Trace] ON DATABASE 
ADD EVENT sqlserver.blocked_process_report(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,query_plan_hash_signed,sqlserver.sql_text,sqlserver.username)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.error_reported(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)
    WHERE ([error_number]<>(3612) AND [error_number]<>(3613) AND [error_number]<>(3615) AND [error_number]<>(5701) AND [error_number]<>(5703) AND [error_number]<>(0) AND [error_number]<>(14205) AND [error_number]<>(14570) AND [error_number]<>(14705) AND [error_number]<>(14709) AND [error_number]<>(50000))),
ADD EVENT sqlserver.execution_warning(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.hash_warning(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.lock_deadlock_chain(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.missing_column_statistics(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.sort_warning(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.sp_statement_completed(SET collect_object_name=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.sql_statement_completed(SET collect_parameterized_plan_handle=(0),collect_statement=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)
    WHERE ([duration]>=(3000000))),
ADD EVENT sqlserver.plan_affecting_convert(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username)
    WHERE ([package0].[equal_uint64]([convert_issue],(2)) AND [sqlserver].[database_id]>=(5))),
ADD EVENT sqlserver.database_xml_deadlock_report(
    ACTION(sqlserver.client_app_name,sqlserver.client_hostname,sqlserver.database_id,sqlserver.database_name,sqlserver.query_hash,sqlserver.query_plan_hash,sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'https://<ストレージアカウント名>.blob.core.windows.net/xevents/Basic_Trace.xel',max_file_size=(100),max_rollover_files=(10))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON)
GO


-- 拡張イベントの開始
ALTER EVENT SESSION [Basic_Trace] ON DATABASE STATE = START
GO