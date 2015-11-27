-- ブロッキングが発生しているセッションの取得
select session_id, wait_duration_ms, wait_type, blocking_session_id 
from sys.dm_os_waiting_tasks 
where blocking_session_id IS NOT NULL 
order by session_id

-- ブロッキングに関連するセッションのロック情報の取得
select request_session_id, resource_type,resource_subtype, DB_NAME(resource_database_id) AS dbname,  resource_description,
resource_lock_partition, request_mode,request_type,request_status, request_owner_type
from sys.dm_tran_locks
where request_session_id in 
(select session_id from sys.dm_os_waiting_tasks where blocking_session_id IS NOT NULL)
or
request_session_id in
(select blocking_session_id from sys.dm_os_waiting_tasks where blocking_session_id IS NOT NULL)
order by request_session_id

-- ブロッキングの発生の原因となっているクエリ情報の取得
select er.session_id, start_time, er.status, command,DB_NAME(er.database_id) as dbname
, blocking_session_id, wait_type,last_wait_type, wait_resource, er.lock_timeout, er.deadlock_priority,
es.login_time,es.host_name,es.program_name,es.login_name,es.status as session_status, es.row_count,
wait_time , er.total_elapsed_time, 
REPLACE(REPLACE(REPLACE(SUBSTRING(text, 
([statement_start_offset] / 2) + 1, 
((CASE [statement_end_offset]
WHEN -1 THEN DATALENGTH(text)
ELSE [statement_end_offset]
END - [statement_start_offset]) / 2) + 1),CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' ') AS [stmt_text],
text
from sys.dm_exec_requests as er
outer apply
sys.dm_exec_sql_text(sql_handle)
left join
sys.dm_exec_sessions as es
on
er.session_id = es.session_id
where er.session_id in (select session_id from sys.dm_os_waiting_tasks where blocking_session_id IS NOT NULL)
or
er.session_id in (select blocking_session_id from sys.dm_os_waiting_tasks where blocking_session_id IS NOT NULL)
