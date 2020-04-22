SELECT 
	OBJECT_NAME(mc.object_id) AS object_name,
	si.name,
	mc.memory_consumer_desc,
	mc.memory_consumer_type_desc,
	SUM(mc.allocated_bytes) TotalAllocatedBytes,
	SUM(mc.used_bytes) TotalUsedBytes,
	SUM(mc.allocation_count) TotalAllocationCount
FROM 
	sys.dm_db_xtp_memory_consumers mc
	LEFT JOIN
	sys.indexes si
	ON
	si.object_id = mc.object_id
	AND
	si.index_id = mc.index_id
WHERE
	mc.object_id >0
GROUP BY
	OBJECT_NAME(mc.object_id),
	si.name,
	mc.memory_consumer_desc,
	mc.memory_consumer_type_desc
OPTION (RECOMPILE)