SELECT 
	OBJECT_NAME(s.object_id) AS object_name,
	s.name, 
	s.stats_id, 
	isp.partition_number,
	STATS_DATE(s.object_id, s.stats_id) AS stats_date, 
	CAST(sp.last_updated AS datetime2(3)) AS last_updated,
	sp.modification_counter, 
	sp.steps,
	sp.rows, 
	sp.rows_sampled,
	CAST(sp.rows_sampled * 1.0 / sp.rows * 100 as numeric(5,2)) AS sample_percent,
	sp.persisted_sample_percent,
	s.is_incremental,
	isp.rows,
	isp.rows_sampled,
	CAST(isp.rows_sampled * 1.0 / isp.rows * 100 as numeric(5,2)) AS sample_percent,
	isp.steps,
	CAST(isp.last_updated AS datetime2(3)) AS last_updated,
	isp.modification_counter
FROM sys.stats  AS s
	OUTER APPLY sys.dm_db_stats_properties(s.object_id , s.stats_id) AS sp
	OUTER APPLY sys.dm_db_incremental_stats_properties(s.object_id , s.stats_id) AS isp
WHERE 
	OBJECT_SCHEMA_NAME(s.object_id) <> 'sys'
	AND s.auto_created = 0
	AND s.object_id = OBJECT_ID('LINEITEM')
GO

DBCC SHOW_STATISTICS('LINEITEM', 'PK_LINEITEM')
DBCC SHOW_STATISTICS('LINEITEM', 'PK_LINEITEM') WITH STATS_STREAM
GO

ALTER INDEX PK_LINEITEM ON LINEITEM REBUILD
ALTER INDEX PK_LINEITEM ON LINEITEM REBUILD PARTITION=4
ALTER INDEX PK_LINEITEM ON LINEITEM REBUILD WITH(STATISTICS_INCREMENTAL = ON)


UPDATE STATISTICS LINEITEM (PK_LINEITEM)
UPDATE STATISTICS LINEITEM (PK_LINEITEM) WITH FULLSCAN
UPDATE STATISTICS LINEITEM (PK_LINEITEM) WITH FULLSCAN, INCREMENTAL = ON
UPDATE STATISTICS LINEITEM (PK_LINEITEM) WITH FULLSCAN, PERSIST_SAMPLE_PERCENT = OFF
UPDATE STATISTICS LINEITEM (PK_LINEITEM) WITH FULLSCAN, PERSIST_SAMPLE_PERCENT = ON
UPDATE STATISTICS LINEITEM (PK_LINEITEM) WITH RESAMPLE ON PARTITIONS(2)
