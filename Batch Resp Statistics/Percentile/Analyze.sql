SELECT
	*
FROM
(
SELECT
	collect_date,
	counter_name,
	CASE
		WHEN cntr_value_total = 0 THEN 0
		ELSE cntr_value_accumulation * 1.0 / cntr_value_total 
	END AS ptl
FROM
	(
		select
			*,
			SUM(cntr_value_lag) OVER(PARTITION BY collect_date ORDER BY counter_name ASC) cntr_value_accumulation,
			SUM(cntr_value_lag) OVER(PARTITION BY collect_date) cntr_value_total
		from
		(
				select 
					collect_date,
					counter_name, 
					cntr_value,
					cntr_value - LAG(cntr_value,1,cntr_value) OVER (PARTITION BY counter_name ORDER BY collect_date ASC) AS cntr_value_lag

				from 
					batch_rec 
		) AS T1
	) AS T2
) AS T3
PIVOT(
	MAX(ptl)
	FOR counter_name IN([Batches >=000000ms & <000001ms], [Batches >=000001ms & <000002ms], [Batches >=000002ms & <000005ms], [Batches >=000005ms & <000010ms], [Batches >=000010ms & <000020ms], [Batches >=000020ms & <000050ms], [Batches >=000050ms & <000100ms], [Batches >=000100ms & <000200ms], [Batches >=000200ms & <000500ms], [Batches >=000500ms & <001000ms], [Batches >=001000ms & <002000ms], [Batches >=002000ms & <005000ms], [Batches >=005000ms & <010000ms], [Batches >=010000ms & <020000ms], [Batches >=020000ms & <050000ms], [Batches >=050000ms & <100000ms], [Batches >=100000ms])
) AS PVT
order by 
	collect_date ASC
