SET NOCOUNT ON;

SELECT
    GETDATE() counter_date,
    * 
INTO #T1
FROM 
    sys.dm_os_performance_counters WITH(NOLOCK)
WHERE
    object_name LIKE '%Access Methods%'
    AND
    counter_name IN('Full Scans/sec', 'Range Scans/sec', 'Probe Scans/sec', 'Index Searches/sec', 'Table Lock Escalations/sec', 'Page Splits/sec', 'Pages compressed/sec')
OPTION (RECOMPILE, MAXDOP 1);

WAITFOR DELAY '00:00:03';

SELECT
    GETDATE() counter_date,
    * 
INTO #T2
FROM 
    sys.dm_os_performance_counters WITH(NOLOCK)
WHERE
    object_name LIKE '%Access Methods%'
    AND
    counter_name IN('Full Scans/sec', 'Range Scans/sec', 'Probe Scans/sec', 'Index Searches/sec', 'Table Lock Escalations/sec', 'Page Splits/sec', 'Pages compressed/sec')
OPTION (RECOMPILE, MAXDOP 1);

SELECT
    #T2.counter_date,
    RTRIM(#T1.object_name) object_name,
    RTRIM(#T1.counter_name) counter_name,
    RTRIM(#T1.instance_name) instance_name,
    CAST((#T2.cntr_value - #T1.cntr_value) / (DATEDIFF (ms, #T1.counter_date,
    #T2.counter_date) / 1000.0) AS bigint) AS cntr_value
FROM #T1
    LEFT JOIN
    #T2
    ON
    #T1.object_name = #T2.object_name
    AND
    #T1.counter_name = #T2.counter_name
OPTION (RECOMPILE, MAXDOP 1);