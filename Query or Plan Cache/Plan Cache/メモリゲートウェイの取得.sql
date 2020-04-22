-- https://support.microsoft.com/ja-jp/help/3024815/large-query-compilation-waits-on-resource-semaphore-query-compile-in-s
-- -T6498
SELECT 
	MemGW.pool_id,
	RP.name,
	MemGW.name AS gateay_name,
	MemGW.max_count,
	MemGW.active_count,
	MemGW.waiter_count,
	MemGW.threshold_factor,
	MemGW.threshold,
	MemGW.is_active
FROM 
	sys.dm_exec_query_optimizer_memory_gateways AS MemGW
	LEFT JOIN
	sys.resource_governor_resource_pools AS RP
	ON
	MemGW.pool_id = RP.pool_id