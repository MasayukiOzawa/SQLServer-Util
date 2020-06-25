DECLARE @session_id int = 81

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
            session_wait_dump AS w
             CROSS APPLY OPENJSON(wait_info) WITH(wait_type nvarchar(120), waiting_tasks_count bigint, wait_time_ms bigint, max_wait_time_ms bigint, signal_wait_time_ms bigint) AS json_column
        WHERE 
            session_id = @session_id
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
        collect_date, json_column.wait_time_ms, json_column.wait_type
    FROM
        session_wait_dump AS w
            CROSS APPLY OPENJSON(wait_info) WITH(wait_type nvarchar(120), waiting_tasks_count bigint, wait_time_ms bigint, max_wait_time_ms bigint, signal_wait_time_ms bigint) AS json_column
    WHERE 
        session_id = ' + CAST(@session_id AS varchar(10)) + '
) AS T
PIVOT(
    MAX(wait_time_ms)
    FOR wait_type IN(' + @pvt + ')
) AS PVT
ORDER BY collect_date DESC
'
 
EXECUTE (@sql)

SELECT 
    collect_date, wait_type, last_wait_type, wait_time, dop,
    session_cpu_time, request_cpu_time, 
    total_scheduled_time, session_total_elapsed_time, request_total_elapsed_time,
    session_reads, request_reads, session_writes, request_writes, 
    session_logical_reads, request_logical_reads
FROM 
    session_wait_dump
WHERE 
    session_id = @session_id
ORDER BY 
    collect_date DESC