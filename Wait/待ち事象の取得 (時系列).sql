/***************************************/
-- 待ち事象 (時系列 前回からの増分)
/***************************************/
SET NOCOUNT ON
GO

DECLARE @waittime nvarchar(8) 
SET @waittime = '00:00:10'

DECLARE @initilalize bit 
SET @initilalize = 0

IF OBJECT_ID('tempdb..#tmp_wait_stats_old') IS NULL
BEGIN
	SELECT *
	INTO #tmp_wait_stats_old
	FROM sys.dm_os_wait_stats
	
	CREATE CLUSTERED INDEX IX_tmp_wait_stats_old 
	ON #tmp_wait_stats_old (wait_type)
END
ELSE
BEGIN
	Truncate Table #tmp_wait_stats_old
END

IF OBJECT_ID('tempdb..#tmp_wait_stats') IS NULL
BEGIN
	SELECT
		GETDATE() AS DateTime, 
		1 as type,
		wait_type, 
		waiting_tasks_count, 
		wait_time_ms, 
		max_wait_time_ms, 
		signal_wait_time_ms
	INTO #tmp_wait_stats
	FROM sys.dm_os_wait_stats
	WHERE 1 = 0

	CREATE CLUSTERED INDEX IX_tmp_wait_stats
	ON #tmp_wait_stats (wait_type)
END
ELSE
BEGIN
	IF @initilalize = 1
		Truncate Table #tmp_wait_stats
END

WHILE (1 = 1)
BEGIN
	INSERT INTO 
		#tmp_wait_stats
	SELECT
		GETDATE() AS DateTime, 
		1 as type,
		wait_type, 
		waiting_tasks_count, 
		wait_time_ms, 
		max_wait_time_ms, 
		signal_wait_time_ms
	FROM sys.dm_os_wait_stats
	
	INSERT INTO 
		#tmp_wait_stats
	SELECT
		GETDATE() AS DateTime, 
		2 as type,
		T1.wait_type, 
		ISNULL(T1.waiting_tasks_count - T2.waiting_tasks_count, 0) AS waiting_tasks_count, 
		ISNULL(T1.wait_time_ms - T2.wait_time_ms, 0) AS wait_time_ms, 
		ISNULL(T1.max_wait_time_ms - T2.max_wait_time_ms, 0) AS max_wait_time_ms, 
		ISNULL(T1.signal_wait_time_ms - T2.signal_wait_time_ms, 0) AS signal_wait_time_ms
	FROM
		sys.dm_os_wait_stats T1
		LEFT JOIN
		#tmp_wait_stats_old T2
		ON
			T1.wait_type = T2.wait_type
	ORDER BY
		T1.wait_type ASC
	
	TRUNCATE TABLE #tmp_wait_stats_old
	
	INSERT INTO  #tmp_wait_stats_old
	SELECT * FROM sys.dm_os_wait_stats

	EXEC ('WAITFOR DELAY ''' + @waittime + '''')
END

SELECT * FROM  #tmp_wait_stats

