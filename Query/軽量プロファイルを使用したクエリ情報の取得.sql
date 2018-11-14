/*
SELECT * FROM sys.database_scoped_configurations
ALTER DATABASE SCOPED CONFIGURATION SET LIGHTWEIGHT_QUERY_PROFILING=OFF
ALTER DATABASE SCOPED CONFIGURATION SET LIGHTWEIGHT_QUERY_PROFILING=ON
*/

SELECT 
	T.session_id,
	er.command,
	er.status,
	er.start_time,
    SUBSTRING(st.text, (qsx.statement_start_offset/2)+1,   
        ((CASE qsx.statement_end_offset  
          WHEN -1 THEN DATALENGTH(st.text)  
         ELSE qsx.statement_end_offset  
         END - qsx.statement_start_offset)/2) + 1) AS statement_text,
	st.text,
	er.last_wait_type,
	er.wait_resource,
	qsx.query_plan AS qsx_query_plan,
	qp.query_plan AS qp_query_plan
FROM
(
	SELECT DISTINCT 
		session_id
	FROM 
		sys.dm_exec_query_profiles
	WHERE 
		session_id <> @@SPID
) AS T
	LEFT JOIN sys.dm_exec_requests AS er ON er.session_id = T.session_id
	OUTER APPLY sys.dm_exec_query_statistics_xml(T.session_id) AS qsx
	OUTER APPLY sys.dm_exec_sql_text(qsx.sql_handle) AS st
	OUTER APPLY sys.dm_exec_query_plan(qsx.plan_handle) AS qp
GO


SELECT 
	qp.session_id,
	qp.request_id,
	er.command,
	er.status,
	er.start_time,
	qp.physical_operator_name,
	DB_NAME(qp.database_id) AS database_name,
	OBJECT_NAME(qp.object_id) AS object_name,
	ix.name AS index_name,
	OBJECT_NAME(page_info.object_id) AS object_name,
	ix.name,
	page_info.partition_id,
	page_info.alloc_unit_id,
	page_info.slot_count,
	page_info.free_bytes,
	qp.node_id,
	qp.thread_id,
	qp.estimate_row_count,
	qp.row_count,
	qp.rewind_count,
	qp.rebind_count,
	qp.end_of_scan_count,
	qp.first_active_time,
	qp.last_active_time,
	qp.open_time,
	qp.first_row_time,
	qp.last_row_time,
	qp.close_time,
	qp.elapsed_time_ms,
	qp.cpu_time_ms,
	qp.scan_count,
	qp.logical_read_count,
	qp.physical_read_count,
	qp.read_ahead_count,
	qp.actual_read_row_count,
	qp.estimated_read_row_count,
	qp.write_page_count,
	qp.lob_logical_read_count,
	qp.lob_physical_read_count,
	qp.lob_read_ahead_count,
	qp.segment_read_count,
	qp.segment_skip_count,
	page_info.database_id,
	page_info.page_id,
	page_info.page_type,
	page_info.page_type_desc,
	page_info.page_level
FROM 
	sys.dm_exec_query_profiles AS qp
	LEFT JOIN sys.indexes AS ix ON ix.object_id = qp.object_id AND ix.index_id = qp.index_id
	LEFT JOIN sys.dm_exec_requests AS er ON er.session_id = qp.session_id
	OUTER APPLY sys.fn_PageResCracker (er.page_resource) AS r  
	OUTER APPLY sys.dm_db_page_info(COALESCE(r.db_id, 0), r.file_id, r.page_id, DEFAULT) AS page_info
WHERE 
	qp.session_id <> @@SPID
ORDER BY
	qp.session_id ASC,
	qp.node_id ASC
GO
