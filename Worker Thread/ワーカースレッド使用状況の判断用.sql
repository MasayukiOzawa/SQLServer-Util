SELECT
	Total_Physical_Memory_MB,
	Available_Physical_Memory_MB,
	Process_Committed_Memory_MB,
	Memory_Manager_Memory_MB,
	Process_Committed_Memory_MB - Memory_Manager_Memory_MB AS NonMemoryManager_MB,
	Max_Worker_Threads,
	Max_Worker_Count, 
	Current_Worker_Thread_Count,
	Current_Worker_Thread_Count * 2 AS WorkerThread_Memory_MB -- x64 : 1 Worker 2MB
FROM(
	SELECT
		(SELECT cntr_value / 1024 FROM sys.dm_os_performance_counters  WHERE counter_name = 'Total Server Memory (KB)') AS Memory_Manager_Memory_MB,
		(SELECT virtual_address_space_committed_kb / 1024 FROM sys.dm_os_process_memory) AS Process_Committed_Memory_MB,
		(SELECT SUM(current_workers_count) FROM sys.dm_os_schedulers where status = 'VISIBLE ONLINE') AS Current_Worker_Thread_Count,
		(SELECT total_physical_memory_kb / 1024 FROM sys.dm_os_sys_memory) AS Total_Physical_Memory_MB,
		(SELECT available_physical_memory_kb / 1024 FROM sys.dm_os_sys_memory) AS Available_Physical_Memory_MB,
		(SELECT value_in_use FROM sys.configurations WHERE name = 'max worker threads') AS Max_Worker_Threads,
		(SELECT max_workers_count FROM sys.dm_os_sys_info) AS Max_Worker_Count
) AS T

