-- 値をそのまま利用可能な項目
SELECT 
	*
FROM 
	sys.dm_os_performance_counters WITH(NOLOCK)
WHERE
	object_name LIKE '%:Replication%'
	AND
	cntr_type = 65792
OPTION (RECOMPILE, MAXDOP 1)
GO

-- 2 点で値を取得し、その差分を取得間隔で割る項目
SELECT 
	*
FROM 
	sys.dm_os_performance_counters  WITH(NOLOCK)
WHERE
	object_name LIKE '%:Replication%'
	AND
	cntr_type = 272696576
OPTION (RECOMPILE, MAXDOP 1)
GO
