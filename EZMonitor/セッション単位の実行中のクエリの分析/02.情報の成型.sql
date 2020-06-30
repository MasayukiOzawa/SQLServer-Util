SELECT 
    collect_date, session_id,program_name,blocking_session_id,
    wait_type, last_wait_type, wait_resource, wait_time, 
    dop, session_cpu_time, request_cpu_time, 
    total_scheduled_time, session_total_elapsed_time, request_total_elapsed_time,
    session_reads, request_reads, session_writes, request_writes, 
    session_logical_reads, request_logical_reads, wait_info
FROM 
    dump_session_wait
WHERE
    wait_type <> 'WAITFOR'
    AND collect_date >= DATEADD(hh,-1, GETDATE())
    AND program_name <> 'Microsoft SQL Server Management Studio'
ORDER BY 
     session_id ASC, collect_date ASC

GO

DECLARE @pvt varchar(max) = (
    SELECT STUFF(C1,1, 2,'') + ']'
    FROM
    (
    SELECT
        DISTINCT
        '],[' + REPLACE(REPLACE(CAST(wait_type AS varchar(1000)), CHAR(10),''), CHAR(13), '')
    FROM(
        SELECT
            json_column.wait_type
        FROM
            dump_session_wait AS w
             CROSS APPLY OPENJSON(wait_info) WITH(wait_type nvarchar(120), waiting_tasks_count bigint, wait_time_ms bigint, max_wait_time_ms bigint, signal_wait_time_ms bigint) AS json_column
        WHERE
            w.wait_type <> 'WAITFOR'
            AND collect_date >= DATEADD(hh,-1, GETDATE())
    ) AS T
    FOR XML PATH('')
    ) AS T(C1)
)
 
DECLARE @sql nvarchar(max) = N'
SELECT
    *
FROM
(
    SELECT
        collect_date, session_id, program_name, json_column.wait_time_ms, json_column.wait_type
    FROM
        dump_session_wait AS w
        CROSS APPLY OPENJSON(wait_info) WITH(wait_type nvarchar(120), waiting_tasks_count bigint, wait_time_ms bigint, max_wait_time_ms bigint, signal_wait_time_ms bigint) AS json_column
    WHERE
        w.wait_type <> ''WAITFOR''
        AND collect_date >= DATEADD(hh,-1, GETDATE())
        AND program_name <> ''Microsoft SQL Server Management Studio''
) AS T
PIVOT(
    MAX(wait_time_ms)
    FOR wait_type IN(' + @pvt + ')
) AS PVT
ORDER BY session_id ASC, collect_date ASC
'
 
EXECUTE (@sql)