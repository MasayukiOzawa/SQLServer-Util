SELECT
	*
FROM
(
	SELECT
		server_name,
		db_name,
		DATEADD(HOUR, 9, collect_date) AS [time],
		counter_name,
		FORMAT(
			COALESCE((cntr_value - LAG(cntr_value) OVER(PARTITION BY server_name, object_name, counter_name,instance_name ORDER BY collect_date ASC)) * 1.0 / 
				DATEDIFF(SECOND,
					DATEADD(HOUR, 9, LAG(collect_date) OVER(PARTITION BY server_name, object_name, counter_name,instance_name ORDER BY collect_date ASC)),
					DATEADD(HOUR, 9, collect_date)
				), 0) 
		, '#,##0.#0') AS cntr_value_diff
	FROM
		[01_BatchResp]
	WHERE
		object_name LIKE '%Batch Resp Statistics%'
		AND
		instance_name = 'Elapsed Time:Requests'
	UNION
	SELECT 
		server_name,
		db_name,
		DATEADD(HOUR, 9, collect_date) AS [time],
		counter_name,
		FORMAT(
			COALESCE((cntr_value - LAG(cntr_value) OVER(PARTITION BY server_name, object_name, counter_name,instance_name ORDER BY collect_date ASC)) * 1.0 / 
				DATEDIFF(SECOND,
					DATEADD(HOUR, 9, LAG(collect_date) OVER(PARTITION BY server_name, object_name, counter_name,instance_name ORDER BY collect_date ASC)),
					DATEADD(HOUR, 9, collect_date)
				), 0)
		, '#,##0.#0') AS cntr_value_diff
FROM 
	[01_BatchResp]
WHERE
	counter_name = 'Batch Requests/sec'
) AS T 
PIVOT
	(MAX(cntr_value_diff) FOR counter_name IN(
		[Batch Requests/sec],
		[Batches >=000000ms & <000001ms],
		[Batches >=000001ms & <000002ms],
		[Batches >=000002ms & <000005ms],
		[Batches >=000005ms & <000010ms],
		[Batches >=000010ms & <000020ms],
		[Batches >=000020ms & <000050ms],
		[Batches >=000050ms & <000100ms],
		[Batches >=000100ms & <000200ms],
		[Batches >=000200ms & <000500ms],
		[Batches >=000500ms & <001000ms],
		[Batches >=001000ms & <002000ms],
		[Batches >=002000ms & <005000ms],
		[Batches >=005000ms & <010000ms],
		[Batches >=010000ms & <020000ms],
		[Batches >=020000ms & <050000ms],
		[Batches >=050000ms & <100000ms],
		[Batches >=100000ms])
	)
AS P
ORDER BY [time] ASC