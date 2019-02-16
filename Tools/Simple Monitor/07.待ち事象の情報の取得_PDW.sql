SET NOCOUNT ON

SELECT
	GETDATE() as counter_date,
	pdw_node_id,
	type,
	counter_name,
	[Average wait time (ms)],
	[Waits in progress],
	[Waits started per second],
	[Cumulative wait time (ms) per second]
FROM
	(
	SELECT
		RTRIM(p.instance_name) AS instance_name,
		RTRIM(p.counter_name) AS counter_name,
		p.pdw_node_id,
		n.type,
		p.cntr_value
	FROM 
		sys.dm_pdw_nodes_os_performance_counters p
		LEFT JOIN
		sys.dm_pdw_nodes n
		ON
		n.pdw_node_id = p.pdw_node_id
	WHERE 
		object_name like '%Wait Statistics%'
	) AS T
PIVOT
(
	SUM(cntr_value)
	FOR instance_name 
	IN( 
		[Average wait time (ms)],
		[Waits in progress],
		[Waits started per second],
		[Cumulative wait time (ms) per second]
	)
) AS PVT
ORDER BY 
	type DESC,
	pdw_node_id ASC,
	counter_name ASC