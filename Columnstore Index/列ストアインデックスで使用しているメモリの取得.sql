SELECT * FROM sys.dm_os_memory_broker_clerks WHERE clerk_name = 'Column store object pool'
SELECT SUM(pages_in_bytes) / POWER(1024,2) FROM sys.dm_os_memory_objects WHERE type LIKE '%COLUMNSTORE%'
SELECT * FROM sys.dm_os_memory_clerks WHERE type LIKE '%COLUMNSTORE%'


-- Clustered Columnstore Indexes – part 38 (“Memory Structures”) 
-- http://www.nikoport.com/2014/08/11/clustered-columnstore-indexes-part-38-memory-structures/

-- Clustered columnstore index and memory management
-- http://blog.dbi-services.com/clustered-columnstore-index-and-memory-management/

select name, type, pages_kb, pages_in_use_kb, entries_count, entries_in_use_count
from sys.dm_os_memory_cache_counters 
where type = 'CACHESTORE_COLUMNSTOREOBJECTPOOL'
GO

select name, type, memory_node_id, pages_kb, page_size_in_bytes, virtual_memory_reserved_kb, virtual_memory_committed_kb
,shared_memory_reserved_kb, shared_memory_committed_kb
from sys.dm_os_memory_clerks 
where type = 'CACHESTORE_COLUMNSTOREOBJECTPOOL'
GO

SELECT *
FROM sys.dm_os_memory_broker_clerks;


-- https://github.com/jdanton/CSMemoryUse/blob/master/ColumnstoreBuffers.sql
DECLARE @dbid INT;
DECLARE @offset INT;
DECLARE @bla VARCHAR(35);
DECLARE @hobtid BIGINT;

SELECT @dbid = db_id()

SELECT @offset = (
		CASE 
			WHEN @dbid <= 9
				THEN 38
			WHEN @dbid >= 10
				THEN 39
			END
		);

SELECT @bla = CONCAT (
		'%db_id='''
		,@dbid
		,'''%'
		);

--print @bla;
--print @offset;
SELECT @hobtid = cast(substring(entry_data, @offset, 17) AS BIGINT)
FROM sys.dm_os_memory_cache_entries
WHERE type = 'CACHESTORE_COLUMNSTOREOBJECTPOOL'
	AND entry_data LIKE (@bla)

--print @hobtid
SELECT @bla = CONCAT (
		'%hobt_id ='''
		,@hobtid
		,'''%'
		);

--print @bla;
WITH cs_cache
AS (
	SELECT a.type
		,@hobtid AS hobt_id
		,pages_kb
	FROM sys.dm_os_memory_cache_entries a
	WHERE type = 'CACHESTORE_COLUMNSTOREOBJECTPOOL'
		AND entry_data LIKE (@bla)
	)

SELECT x.NAME AS ObjectName
	,sum(cs_cache.pages_kb) / 1024 AS BufferMB
FROM cs_cache
INNER JOIN (
	SELECT css.hobt_id
		,NAME
	FROM sys.column_store_segments css
	INNER JOIN sys.partitions p ON css.partition_id = p.partition_id
	INNER JOIN sys.objects o ON p.object_id = o.object_id
	GROUP BY css.hobt_id
		,o.NAME
	) AS x ON x.hobt_id = cs_cache.hobt_id
GROUP BY x.NAME
GO
