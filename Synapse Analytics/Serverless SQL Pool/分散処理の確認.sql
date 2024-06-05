DECLARE @dist_request_id uniqueidentifier = '<Distributed request ID>'

DROP TABLE IF EXISTS #tmp
DROP TABLE IF EXISTS #tmp2
DROP TABLE IF EXISTS #tmp3

SELECT * INTO #tmp FROM sys.dm_request_phases 
SELECT * FROM #tmp WHERE dist_request_id = @dist_request_id ORDER BY id ASC

SELECT * INTO #tmp2 FROM sys.dm_request_phases_exec_task_stats 
SELECT * FROM #tmp2 WHERE dist_request_id = @dist_request_id ORDER BY id ASC

SELECT * INTO #tmp3 FROM sys.dm_request_phases_task_group_stats
SELECT * FROM #tmp3 WHERE dist_request_id = @dist_request_id ORDER BY id ASC
