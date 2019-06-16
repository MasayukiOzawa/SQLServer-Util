SET NOCOUNT ON;

SELECT
	GETDATE() counter_date,
	*
INTO #T1
FROM 
	sys.dm_pdw_nodes_os_performance_counters WITH(NOLOCK)
WHERE
	object_name LIKE '%Buffer Manager%'
	AND
	counter_name IN('Page lookups/sec', 'Readahead pages/sec', 'Readahead time/sec', 'Page reads/sec', 'Page writes/sec', 'Checkpoint pages/sec', 'Background writer pages/sec')
OPTION(RECOMPILE, MAXDOP 1);

WAITFOR DELAY '00:00:03';

SELECT
	GETDATE() counter_date,
	*
INTO #T2
FROM 
	sys.dm_pdw_nodes_os_performance_counters WITH(NOLOCK)
WHERE
	object_name LIKE '%Buffer Manager%'
	AND
	counter_name IN('Page lookups/sec', 'Readahead pages/sec', 'Readahead time/sec', 'Page reads/sec', 'Page writes/sec', 'Checkpoint pages/sec', 'Background writer pages/sec')
OPTION(RECOMPILE, MAXDOP 1);

SELECT 
    #T2.counter_date,
	#T2.pdw_node_id,
	n.type,
	RTRIM(#T1.object_name) object_name,
	RTRIM(#T1.counter_name) counter_name,
	RTRIM(#T1.instance_name) instance_name,
	CAST((#T2.cntr_value - #T1.cntr_value) / (DATEDIFF (ms, #T1.counter_date,#T2.counter_date) / 1000.0) AS bigint) AS cntr_value,
	CAST((#T2.cntr_value - #T1.cntr_value) / (DATEDIFF (ms, #T1.counter_date,#T2.counter_date) / 1000.0) AS bigint) * 8 / 1024.0 AS cntr_value_MB
FROM #T1
	LEFT JOIN
	#T2
	ON
	#T1.object_name = #T2.object_name
	AND
	#T1.counter_name = #T2.counter_name
	AND
	#T1.pdw_node_id = #T2.pdw_node_id
	LEFT JOIN
	sys.dm_pdw_nodes n
	ON
	n.pdw_node_id = #T2.pdw_node_id
ORDER BY
	type DESC,
	pdw_node_id ASC;