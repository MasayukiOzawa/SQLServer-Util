SET NOCOUNT ON;

SELECT
	counter_date,
	pdw_node_id,
	type,
	([Buffer cache hit ratio] * 1.0) / ([Buffer cache hit ratio base] * 1.0) * 100 As [Buffer cache hit ratio],
	[Page life expectancy]
FROM
(
	SELECT 
		GETDATE() AS counter_date,
		p.pdw_node_id,
		n.type,
		p.counter_name,
		p.cntr_value
	FROM 
		sys.dm_pdw_nodes_os_performance_counters p WITH(NOLOCK)
	LEFT JOIN
	sys.dm_pdw_nodes n WITH(NOLOCK)
	ON
	n.pdw_node_id = p.pdw_node_id
	WHERE
		object_name LIKE '%Buffer Manager%'
		AND
		counter_name IN ('Buffer cache hit ratio', 'Buffer cache hit ratio base', 'Page life expectancy')
) AS T
PIVOT
(
	MAX(cntr_value)
	FOR counter_name IN([Buffer cache hit ratio],[Buffer cache hit ratio base], [Page life expectancy])
)AS P
ORDER BY
	type DESC,
	pdw_node_id ASC
OPTION(RECOMPILE, MAXDOP 1);