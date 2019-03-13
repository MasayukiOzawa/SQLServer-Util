/*
relog .\DataCollector01.blg -cf cf.txt -f SQL -o "SQL:localhost!perflogs_01"


USE [Perfmon]
GO

DROP TABLE [dbo].[CounterData]
DROP TABLE [dbo].[CounterDetails]
DROP TABLE [dbo].[DisplayToID]


Truncate TABLE [dbo].[CounterData]
Truncate TABLE [dbo].[CounterDetails]
Truncate TABLE [dbo].[DisplayToID]
GO

ALTER TABLE [dbo].[CounterData] REBUILD
ALTER TABLE [dbo].[CounterDetails] REBUILD
ALTER TABLE [dbo].[DisplayToID] REBUILD
GO

*/

--DECLARE @Req varchar(1024) = 'Elapsed Time:Requests'
--DECLARE @Total varchar(1024) = 'Elapsed Time:Total(ms)'

DECLARE @Req varchar(1024) = 'CPU Time:Requests'
DECLARE @Total varchar(1024) = 'CPU Time:Total(ms)'

;WITH Perf AS(
SELECT
	DID.DisplayString,
	CD.CounterDateTime,
	CDE.ObjectName,
	CDE.CounterName,
	CDE.InstanceName,
	CD.CounterValue,
	LAG(CD.CounterValue,1,0) OVER(PARTITION BY ObjectName, CounterName,InstanceName ORDER BY CounterDateTime ASC) AS Lag_Value,
	CASE LAG(CD.CounterValue,1,0) OVER(PARTITION BY ObjectName, CounterName,InstanceName ORDER BY CounterDateTime ASC)
		WHEN 0 THEN 0
		ELSE
			CD.CounterValue -
				LAG(CD.CounterValue,1,0) OVER(PARTITION BY ObjectName, CounterName,InstanceName ORDER BY CounterDateTime ASC) 
	END AS Diff_Value,
	CDE.CounterType
FROM
	CounterData AS CD
	LEFT JOIN DisplayToID AS DID
	ON	CD.GUID = DID.GUID
	INNER JOIN CounterDetails AS CDE
	ON CDE.CounterID = CD.CounterID
)

SELECT
	*
FROM
(
	SELECT 
		T1.DisplayString,
		T1.CounterDateTime,
		T1.ObjectName,
		T1.CounterName,
		--T1.InstanceName,
		--T1.Diff_Value,
		--T2.InstanceName,
		--T2.Diff_Value,
		CASE T1.Diff_Value
			WHEN 0 THEN 0
			ELSE
				CAST(T2.Diff_Value / T1.Diff_Value AS bigint)
		END AS Avg_Value
	FROM
		Perf AS T1
		CROSS APPLY (
			SELECT
				P2.InstanceName,
				P2.CounterValue,
				P2.Diff_Value
			FROM
				Perf AS P2
			WHERE
				P2.InstanceName = @Total
				AND
				P2.CounterDateTime = T1.CounterDateTime
				AND
				P2.ObjectName = T1.ObjectName
				AND
				P2.CounterName = T1.CounterName
		) AS T2
	WHERE
		T1.InstanceName = @Req
		AND
		T1.CounterName IN (
			'Batches >=000100ms & <000200ms',
			'Batches >=000200ms & <000500ms',
			'Batches >=000500ms & <001000ms',
			'Batches >=001000ms & <002000ms',
			'Batches >=002000ms & <005000ms',
			'Batches >=005000ms & <010000ms',
			'Batches >=010000ms & <020000ms',
			'Batches >=020000ms & <050000ms',
			'Batches >=050000ms & <100000ms',
			'Batches >=100000ms'
		)
		AND
		T1.Diff_Value > 0
) AS BASE
PIVOT
(
	MAX(Avg_Value)
	FOR CounterName IN (			
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
) AS PVT
ORDER BY
	CounterDateTime ASC,
	ObjectName ASC
--OPTION(RECOMPILE, MAXDOP 0) -- 条件の変数化によりフィルタータイミングが後半になることを防ぐため、RECOMPILE による述語の調整