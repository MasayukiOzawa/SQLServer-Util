-- https://support.microsoft.com/en-us/help/3026083/fix-sos-cachestore-spinlock-contention-on-ad-hoc-sql-server-plan-cache

SELECT 
	name, 
	type,
	table_level,
	buckets_count,
	buckets_in_use_count,
	misses_count
FROM 
	sys.dm_os_memory_cache_hash_tables
	WHERE name IN (
		'SQL Plans', 
		'Object Plans', 
		'Bound Trees',
		'Temporary Tables & Table Variables'
	)

