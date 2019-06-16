SET NOCOUNT ON;

DECLARE @v1_date datetime, @v1_value bigint;
DECLARE @v2_date datetime, @v2_value bigint;

SELECT
	@v1_date = GETDATE(), 
	@v1_value = cntr_value 
FROM 
	sys.dm_os_performance_counters WITH(NOLOCK)
WHERE 
	counter_name = 'Batch Requests/sec'
OPTION(RECOMPILE, MAXDOP 1);

WAITFOR DELAY '00:00:03';

SELECT
	@v2_date = GETDATE(), 
	@v2_value = cntr_value 
FROM 
	sys.dm_os_performance_counters  WITH(NOLOCK)
WHERE 
	counter_name = 'Batch Requests/sec'
OPTION(RECOMPILE, MAXDOP 1);

SELECT 
	GETDATE() AS counter_date, 
	CAST((@v2_value - @v1_value) / (DATEDIFF (ms, @v1_date,@v2_date) / 1000.0) AS bigint) AS 'Batch Requests/sec',
	(SELECT
		cntr_value
	FROM
		sys.dm_os_performance_counters WITH(NOLOCK)
	WHERE
		counter_name = 'User Connections'
		AND
		object_name LIKE '%:General Statistics%') AS [User Connections/sec],
	(SELECT
		cntr_value
	FROM
		sys.dm_os_performance_counters
	WHERE 
		counter_name = 'Processes blocked') AS [Processes blocked]
OPTION(RECOMPILE, MAXDOP 1);