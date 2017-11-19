SELECT
	[cacheobjtype] + ':' +  [objtype] AS [Type], 
	SUM(CONVERT(bigint, [size_in_bytes])) / 1024.0 AS [size_in_bytes (KB)]
FROM 
	[sys].[dm_exec_cached_plans] WITH (NOLOCK)
GROUP BY
	[cacheobjtype],
	[objtype]
OPTION (RECOMPILE)

