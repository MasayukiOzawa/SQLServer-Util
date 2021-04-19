
select --TOP 500
    owt.session_id,
    owt.wait_duration_ms,
    (SELECT ms_ticks FROM sys.dm_os_sys_info) -owo.wait_started_ms_ticks AS wait_start_ms,
    owt.wait_type,
    owt.resource_description,
    owt.resource_address,
    er.blocking_session_id,
    er.wait_time,
    er.last_wait_type,
    er.wait_resource,
    er2.status,
    er2.command,
    er2.wait_time,
    er2.wait_type,
    er2.wait_resource,
    owt.blocking_task_address,
    owt.waiting_task_address,
    owo.task_address,
    owo.thread_address
from 
    sys.dm_os_waiting_tasks AS owt
    INNER JOIN sys.dm_exec_requests AS er
        ON er.session_id  = owt.session_id
    INNER JOIN sys.dm_os_workers AS owo
        ON owo.task_address = owt.waiting_task_address
    INNER JOIN sys.dm_exec_sessions AS es
        On es.session_id = owt.session_id
        AND es.program_name = 'OStress'
    LEFT JOIN sys.dm_exec_requests AS er2
        ON er2.session_id = er.blocking_session_id
where 
/*
    owt.wait_type LIKE 'PAGELATCH%'
    OR owt.wait_type LIKE 'LATCH%' 
    OR owt.wait_type LIKE 'LCK%' 
*/
    owt.wait_type NOT LIKE 'WRITELOG%'
order by
    owt.wait_duration_ms DESC,
    owt.resource_address ASC
/*
ACCESS_METHODS_HOBT_VIRTUAL_ROOT (000001FEA15E64F8)
ACCESS_METHODS_HOBT_VIRTUAL_ROOT (000001FEA15E64F8)
*/
/*
SELECT * FROM sys.dm_os_buffer_descriptors AS bd
outer apply sys.dm_db_page_info(bd.database_id, bd.file_id, bd.page_id, 'LIMITED') AS pi
WHERE bd.database_id = DB_ID() and pi.page_type_desc <> 'DATA_PAGE'

DBCC DROPCLEANBUFFERS
CHECKPOINT
*/
/*
SELECT index_id, partition_number, index_depth, index_level, avg_fragmentation_in_percent,avg_page_space_used_in_percent 
FROM sys.dm_db_index_physical_stats(DB_ID(), 
_ID('pagelatch_test'), 1, NULL, 'DETAILED')
*/
/*

truncate Table pagelatch_test
CHECKPOINT

DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR)
DBCC SQLPERF('sys.dm_os_latch_stats', CLEAR)

SELECT * FROM sys.dm_os_wait_stats WHERE wait_type LIKE 'PAGELATCH%' OR wait_type = 'WRITELOG'
SELECT * FROM sys.dm_os_latch_stats WHERE latch_class LIKE 'BUFFER'

SELECT * FROM sys.dm_os_wait_stats WHERE wait_type LIKE 'LATCH%'
SELECT * FROM sys.dm_os_latch_stats WHERE latch_class = 'ACCESS_METHODS_HOBT_VIRTUAL_ROOT'
*/

/*
DBCC TRACEON(3604)
DBCC PAGE(10,1,139,3)

DBCC PAGE(10,1,163284,3)
*/

/*
0x00000186313E02D8
*/


