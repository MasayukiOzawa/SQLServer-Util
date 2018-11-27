CREATE EVENT SESSION [QueryTrace] ON DATABASE 
ADD EVENT sqlserver.rpc_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.rpc_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.sp_statement_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.sql_batch_starting(SET collect_batch_text=(1)
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text)),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.session_id,sqlserver.sql_text))
ADD TARGET package0.ring_buffer(SET max_memory=(10240))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


