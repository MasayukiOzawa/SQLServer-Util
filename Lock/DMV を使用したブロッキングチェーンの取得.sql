with sessionList AS(
    select
        es.session_id,
        er.blocking_session_id,
        wt.blocking_session_id AS task_blocking_session_id,
        es.host_name,
        es.program_name,
        er.command,
        es.status,
        er.status AS er_status,
        er.wait_type,
        er.wait_time,
        er.last_wait_type,
        er.wait_resource,
        wt.resource_description,
        er.open_transaction_count,
        es.login_name,
        es.last_request_start_time,
        es.last_request_end_time,
        es.reads,
        es.writes,
        es.logical_reads,
        es.lock_timeout,
        CASE es.transaction_isolation_level
            when 0 then 'Unspecified'
            when 1 then 'ReadUncommitted'
            when 2 then 'ReadCommitted'
            when 3 then 'RepeatableRead'
            when 4 then 'Serializable'
            when 5 then 'Snapshot'
            else cast(es.transaction_isolation_level AS varchar(2))
        END as transaction_isolation_level
    from 
        sys.dm_exec_sessions as es
        left join sys.dm_exec_requests as er
            on er.session_id = es.session_id
        left join sys.dm_os_waiting_tasks as wt
            on wt.session_id = es.session_id
    where
        es.is_user_process = 1
        AND es.session_id <> @@SPID
),

blockingList AS(
    SELECT
        1 AS level,
        session_id,
        blocking_session_id,
        task_blocking_session_id,
        cast('' AS varchar(255)) as blocking_info,
        cast('' as varchar(255)) as blocking_chain,
        host_name,
        program_name,
        command,
        status,
        er_status,
        wait_type,
        wait_time,
        last_wait_type,
        wait_resource,
        resource_description,
        open_transaction_count,
        login_name,
        last_request_start_time,
        last_request_end_time,
        reads,
        writes,
        logical_reads,
        lock_timeout,
        transaction_isolation_level
    FROM 
        sessionList
    WHERE
        blocking_session_id = 0 OR blocking_session_id IS NULL
    UNION ALL
    SELECT
        level + 1 AS level,
        s.session_id,
        s.blocking_session_id,
        s.task_blocking_session_id,
        CAST(cast(s.task_blocking_session_id AS varchar(5)) + '->' +  CAST(s.session_id as varchar(5)) AS varchar(255)) AS blocking_info,
        CASE
            WHEN blocking_chain = '' THEN CAST(cast(s.task_blocking_session_id AS varchar(5)) + '->' +  CAST(s.session_id as varchar(5)) AS varchar(255))
            WHEN s.blocking_session_id <> s.task_blocking_session_id THEN 
                CAST(
                    REPLACE(
                        blocking_chain + '->' + CAST(s.session_id AS varchar(5)),
                        '->' + CAST(s.blocking_session_id AS varchar(5)) + '->' + CAST(s.session_id AS varchar(5)),
                        '->' + CAST(s.task_blocking_session_id AS varchar(5)) + '->' + CAST(s.session_id AS varchar(5))
                    ) 
                AS varchar(255))
            ELSE CAST(CAST(b.blocking_chain  AS varchar(100)) + '->' + CAST(s.session_id  AS varchar(5)) AS varchar(255))
        END,
        s.host_name,
        s.program_name,
        s.command,
        s.status,
        s.er_status,
        s.wait_type,
        s.wait_time,
        s.last_wait_type,
        s.wait_resource,
        s.resource_description,
        s.open_transaction_count,
        s.login_name,
        s.last_request_start_time,
        s.last_request_end_time,
        s.reads,
        s.writes,
        s.logical_reads,
        s.lock_timeout,
        s.transaction_isolation_level
    FROM
        sessionList AS s
        INNER JOIN blockingList as b
        ON s.blocking_session_id = b.session_id
)
SELECT 
    a.*,
    st.text
FROM 
    blockingList AS a
    LEFT JOIN sys.dm_exec_connections AS es
        ON es.session_id = a.session_id
    OUTER APPLY sys.dm_exec_sql_text(es.most_recent_sql_handle) AS st
WHERE
    EXISTS(SELECT 1 FROM blockingList AS b WHERE b.blocking_session_id = a.session_id)
    OR a.blocking_session_id > 0
ORDER BY a.level, a.session_id
OPTION (MAXRECURSION 100)
