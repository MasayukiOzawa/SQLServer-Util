SELECT 
    er.session_id,
    er.start_time,
    er.STATUS,
    er.command,
    er.sql_handle,
    st.text AS batch_text,
    SUBSTRING(st.text, (er.statement_start_offset/2)+1,   
        ((CASE er.statement_end_offset  
          WHEN -1 THEN DATALENGTH(st.text)  
         ELSE er.statement_end_offset  
         END - er.statement_start_offset)/2) + 1) AS statement_text,
    er.statement_start_offset,
    er.statement_end_offset,
    er.plan_handle,
    er.database_id,
    er.user_id,
    er.blocking_session_id,
    er.wait_type,
    er.last_wait_type,
    er.wait_time,
    er.wait_resource,
    er.open_transaction_count,
    er.percent_complete,
    er.estimated_completion_time,
    er.cpu_time,
    er.total_elapsed_time,
    er.scheduler_id,
    er.reads,
    er.writes,
    er.logical_reads,
    er.transaction_isolation_level,
    er.row_count,
    er.prev_error,
    er.granted_query_memory,
    er.executing_managed_code,
    er.query_hash,
    er.query_plan_hash,
    er.statement_sql_handle,
    er.statement_context_id,
    er.dop,
    er.parallel_worker_count,
    er.external_script_request_id,
    er.page_resource,
    er.page_server_reads,
    es.login_time,
    es.host_name,
    es.program_name,
    es.host_process_id,
    es.client_version,
    es.client_interface_name,
    es.login_name,
    es.status,
    es.cpu_time,
    es.memory_usage,
    es.total_scheduled_time,
    es.total_elapsed_time,
    es.endpoint_id,
    es.last_request_start_time,
    es.last_request_end_time,
    es.reads,
    es.writes,
    es.logical_reads,
    es.is_user_process,
    es.transaction_isolation_level,
    es.row_count,
    es.last_successful_logon,
    es.open_transaction_count,
    es.page_server_reads,
    ec.session_id,
    ec.connect_time,
    ec.num_reads,
    ec.num_writes,
    ec.last_read,
    ec.last_write,
    ec.most_recent_sql_handle
FROM 
     sys.dm_exec_requests AS er
     INNER JOIN sys.dm_exec_sessions AS es
     ON er.session_id = es.session_id
        AND es.is_user_process = 1
        AND last_wait_type <> 'XE_LIVE_TARGET_TVF'
        AND es.session_id <> @@SPID
     INNER JOIN sys.dm_exec_connections AS ec
     ON ec.session_id = er.session_id
     OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) AS st
ORDER BY
    er.session_id ASC