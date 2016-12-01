SELECT
	 mg.session_id,
	 mg.request_id,
	 mg.scheduler_id,
	 mg.dop,
	 mg.request_time,
	 mg.grant_time,
	 mg.requested_memory_kb,
	 mg.granted_memory_kb,
	 mg.required_memory_kb,
	 mg.used_memory_kb,
	 mg.max_used_memory_kb,
	 mg.query_cost,
	 mg.timeout_sec,
	 mg.resource_semaphore_id,
	 mg.wait_time_ms,
	 -- 以下は、2008 以降
	 mg.group_id,
	 mg.pool_id,
	 mg.is_small,
	 mg.ideal_memory_kb,
	 -- 以下は 2012 以降
	 mg.used_memory_kb,
	 mg.reserved_worker_count,
	 -- 以下は 2016 以降
	 mg.max_used_worker_count,
	 mg.reserved_node_bitmap,
	 st.text,
	 qp.query_plan

FROM 
	sys.dm_exec_query_memory_grants mg
	CROSS APPLY
	sys.dm_exec_sql_text(sql_handle) st
	CROSS APPLY
	sys.dm_exec_query_plan(plan_handle) qp
OPTION (RECOMPILE)