-- https://support.microsoft.com/en-us/help/3026083/fix-sos-cachestore-spinlock-contention-on-ad-hoc-sql-server-plan-cache
-- 上限に達しそうな場合は、 -T174 の利用を検討

SELECT 
	name, 
	type,
	table_level,
	buckets_count,
	buckets_in_use_count,
	CAST(buckets_in_use_count * 1.0 / buckets_count * 100 AS numeric(5,2)) AS bucket_usage_percent,
	misses_count
FROM 
	sys.dm_os_memory_cache_hash_tables
	WHERE name IN (
		'SQL Plans', 
		'Object Plans', 
		'Bound Trees',
		'Temporary Tables & Table Variables'
	)

