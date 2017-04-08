SET NOCOUNT ON

-- データキャッシュヒット状況の確認
SELECT
	counter_date,
	([Buffer cache hit ratio] * 1.0) / ([Buffer cache hit ratio base] * 1.0) * 100 As [Buffer cache hit ratio],
	[Page life expectancy]
FROM
(
	SELECT 
		GETDATE() AS counter_date,
		counter_name,
		cntr_value
	FROM 
		sys.dm_os_performance_counters
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