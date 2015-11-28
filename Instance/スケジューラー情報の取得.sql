SET NOCOUNT ON 
GO 
 
/*********************************************/ 
-- スケジューラー (UMS) 情報の取得 
/*********************************************/ 
SELECT 
	GETDATE() AS DATE,  
	[parent_node_id],  
	[scheduler_id],  
	[cpu_id],  
	[status],  
	[is_online],  
	[is_idle],  
	[preemptive_switches_count],  
	[context_switches_count],  
	[idle_switches_count],  
	[current_tasks_count],  
	[runnable_tasks_count],  
	[current_workers_count],  
	[active_workers_count],  
	[work_queue_count],  
	[pending_disk_io_count],  
	[load_factor],  
	[yield_count],  
	[last_timer_activity],  
	[failed_to_create_worker] 
FROM 
	[sys].[dm_os_schedulers] 
OPTION (RECOMPILE)

