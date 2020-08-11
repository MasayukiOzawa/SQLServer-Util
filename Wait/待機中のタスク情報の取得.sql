SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT
    owt.session_id,
    owt.exec_context_id,
    es.status,
    es.login_time,
    es.last_request_start_time,
    es.last_request_end_time,
    es.host_name,
    es.program_name,
    es.login_name,
    owt.wait_duration_ms,
    owt.wait_type,
    owt.resource_description,
    owt.blocking_session_id,
    owt.blocking_exec_context_id,
    st.text,
    es_blocker.status,
    es_blocker.login_time,
    es_blocker.last_request_start_time,
    es_blocker.last_request_end_time,
    es_blocker.host_name,
    es_blocker.program_name,
    es_blocker.login_name,
    owt_blocker.wait_duration_ms,
    owt_blocker.wait_type,
    owt_blocker.resource_description,
    st_blocker.text
FROM
    sys.dm_os_waiting_tasks AS owt
    INNER JOIN sys.dm_exec_sessions AS es
        ON es.session_id = owt.session_id
    INNER JOIN sys.dm_exec_connections AS ec
        ON ec.session_id = owt.session_id
    OUTER APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) AS st
    LEFT JOIN sys.dm_os_waiting_tasks AS owt_blocker
        ON owt_blocker.session_id = owt.blocking_session_id
            AND owt_blocker.exec_context_id = owt.blocking_exec_context_id
    LEFT JOIN sys.dm_exec_sessions AS es_blocker
        ON es_blocker.session_id = owt.blocking_session_id
    LEFT JOIN sys.dm_exec_connections AS ec_blocker
        ON ec_blocker.session_id = es_blocker.session_id
    OUTER APPLY sys.dm_exec_sql_text(ec_blocker.most_recent_sql_handle) AS st_blocker
WHERE
    owt.session_id <> @@SPID
ORDER BY
    owt.session_id ASC,
    owt.exec_context_id ASC,
    owt_blocker.session_id ASC,
    owt_blocker.exec_context_id ASC
OPTION (MAXDOP 1)