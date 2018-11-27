DECLARE @request_id sysname = 'QID2734'
SELECT
	rs.request_id,
	rs.step_index,
	rs.operation_type,
	rs.distribution_type,
	rs.location_type,
	dw.type,
	dw.dms_step_index,
	r.pdw_node_id,
	r.distribution_id,
	dw.distribution_id,
	rs.start_time,
	r.start_time,
	rs.end_time,
	r.end_time,
	dw.start_time,
	dw.end_time,
	dw.status,
	rs.status,
	r.pdw_node_id,
	dw.pdw_node_id,
	rs.total_elapsed_time,
	r.total_elapsed_time,
	dw.cpu_time,
	dw.query_time,
	rs.row_count,
	r.row_count,
	rs.command,
	r.command,
	dw.source_info,
	dw.destination_info,
	dw.command
FROM
	sys.dm_pdw_request_steps rs
	LEFT JOIN
		sys.dm_pdw_sql_requests r
	ON
		rs.request_id = r.request_id
		AND
		rs.step_index = r.step_index
	LEFT JOIN
		sys.dm_pdw_dms_workers dw
	ON
		rs.request_id = dw.request_id
		AND
		rs.step_index = dw.step_index
WHERE 
	rs.request_id = @request_id 
ORDER BY 
	rs.step_index ASC,
	dw.dms_step_index ASC,
	r.pdw_node_id ASC,
	dw.distribution_id ASC