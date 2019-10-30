SELECT
	Total_Physical_Memory_MB,
	Available_Physical_Memory_MB,
	Process_Committed_Memory_MB,
	Memory_Manager_Memory_MB,
	Process_Committed_Memory_MB - Memory_Manager_Memory_MB AS NonMemoryManager_MB,
	WorkerThread_count,
	WorkerThread_count * 2 AS WorkerThread_Memory_MB
FROM(
	SELECT
		(SELECT cntr_value / 1024 FROM sys.dm_os_performance_counters  WHERE counter_name = 'Total Server Memory (KB)') AS Memory_Manager_Memory_MB,
		(SELECT virtual_address_space_committed_kb / 1024 FROM sys.dm_os_process_memory) AS Process_Committed_Memory_MB,
		(SELECT SUM(current_workers_count) FROM sys.dm_os_schedulers where status = 'VISIBLE ONLINE') AS WorkerThread_count,
		(SELECT total_physical_memory_kb / 1024 FROM sys.dm_os_sys_memory) AS Total_Physical_Memory_MB,
		(SELECT available_physical_memory_kb / 1024 FROM sys.dm_os_sys_memory) AS Available_Physical_Memory_MB
) AS T

