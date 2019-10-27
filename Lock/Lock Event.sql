CREATE EVENT SESSION [LockInfo] ON SERVER 
ADD EVENT sqlserver.lock_acquired(
    ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_id,sqlserver.sql_text,sqlserver.username)),
ADD EVENT sqlserver.lock_released(
    ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.database_name,sqlserver.is_system,sqlserver.nt_username,sqlserver.query_hash,sqlserver.query_hash_signed,sqlserver.query_plan_hash,sqlserver.query_plan_hash_signed,sqlserver.session_id,sqlserver.sql_text,sqlserver.username))
ADD TARGET package0.event_file(SET filename=N'LockInfo',max_file_size=(500),max_rollover_files=(20))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=NO_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO


