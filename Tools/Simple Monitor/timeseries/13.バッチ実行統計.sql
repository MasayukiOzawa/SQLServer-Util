SET NOCOUNT ON;

SELECT
    counter_date,
    object_name,
    counter_name,
    [CPU Time:Total(ms)],
    [CPU Time:Requests],
    [Elapsed Time:Total(ms)],
    [Elapsed Time:Requests]
INTO #T1
FROM
(
SELECT
    GETDATE() counter_date,
    *
FROM
    sys.dm_os_performance_counters WITH(NOLOCK)
WHERE
    object_name LIKE '%Batch Resp Statistics%'
)AS T
PIVOT(
    MAX(cntr_value)
    FOR instance_name
    IN([CPU Time:Total(ms)], [CPU Time:Requests], [Elapsed Time:Total(ms)], [Elapsed Time:Requests])
) AS PV
OPTION(RECOMPILE, MAXDOP 1);

WAITFOR DELAY '00:00:03';

SELECT
    counter_date,
    object_name,
    counter_name,
    [CPU Time:Total(ms)],
    [CPU Time:Requests],
    [Elapsed Time:Total(ms)],
    [Elapsed Time:Requests]
INTO #T2
FROM
(
SELECT
    GETDATE() counter_date,
    *
FROM
    sys.dm_os_performance_counters WITH(NOLOCK)
WHERE
    object_name LIKE '%Batch Resp Statistics%'
)AS T
PIVOT(
    MAX(cntr_value)
    FOR instance_name
    IN([CPU Time:Total(ms)], [CPU Time:Requests], [Elapsed Time:Total(ms)], [Elapsed Time:Requests])
) AS PV
OPTION(RECOMPILE, MAXDOP 1);

SELECT 
    #T2.counter_date,
	RTRIM(#T1.object_name) object_name,
	RTRIM(#T1.counter_name) counter_name,
	CAST((#T2.[CPU Time:Total(ms)] - #T1.[CPU Time:Total(ms)]) / (DATEDIFF (ms, #T1.counter_date,#T2.counter_date) / 1000.0) AS bigint) AS [CPU Time:Total(ms)],
    CAST((#T2.[CPU Time:Requests] - #T1.[CPU Time:Requests]) / (DATEDIFF (ms, #T1.counter_date,#T2.counter_date) / 1000.0) AS bigint) AS [CPU Time:Requests],
    CAST((#T2.[Elapsed Time:Total(ms)] - #T1.[Elapsed Time:Total(ms)]) / (DATEDIFF (ms, #T1.counter_date,#T2.counter_date) / 1000.0) AS bigint) AS [Elapsed Time:Total(ms)],
    CAST((#T2.[Elapsed Time:Requests] - #T1.[Elapsed Time:Requests]) / (DATEDIFF (ms, #T1.counter_date,#T2.counter_date) / 1000.0) AS bigint) AS [Elapsed Time:Requests]
FROM #T1
	LEFT JOIN
	#T2
	ON
	#T1.object_name = #T2.object_name
	AND
	#T1.counter_name = #T2.counter_name
OPTION(RECOMPILE, MAXDOP 1);