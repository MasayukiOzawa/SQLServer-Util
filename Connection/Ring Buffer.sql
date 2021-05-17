DECLARE @sqlserver_start_time_ms_ticks bigint
DECLARE @sqlserver_start_time datetime2(3)
SELECT 
    @sqlserver_start_time_ms_ticks = sqlserver_start_time_ms_ticks,
    @sqlserver_start_time = sqlserver_start_time
FROM 
    sys.dm_os_sys_info


SELECT
    T2.*,
    CASE
        WHEN T2.SniConsumerError IS NULL THEN NULL
        ELSE m.text
    END AS text

FROM
(
    SELECT
        time_stamp_jst,
        record.value('(//RecordTime)[1]', 'varchar(100)') AS RecordTime,
        record.value('(//RecordType)[1]', 'varchar(100)') AS record_type,
        record.value('(//RecordSource)[1]', 'varchar(100)') AS RecordSource,
        record.value('(//Spid)[1]', 'int') AS Spid,
        record.value('(//OSError)[1]', 'int') AS OSError,
        record.value('(//SniConsumerError)[1]', 'int') AS SniConsumerError,
        record.value('(//State)[1]', 'int') AS State,
        record.value('(//RemoteHost)[1]', 'varchar(100)') AS RemoteHost,
        record.value('(//RemotePort)[1]', 'int') AS RemotePort,
        record.value('(//LocalHost)[1]', 'varchar(100)') AS LocalHost,
        record.value('(//LocalPort)[1]', 'int') AS LocalPort,
        record
    FROM
    (
        SELECT
            dateadd(hour,9,dateadd(ms, (timestamp - @sqlserver_start_time_ms_ticks), @sqlserver_start_time)) AS time_stamp_jst,
            cast(record AS xml) AS record
        FROM sys.dm_os_ring_buffers 
        WHERE ring_buffer_type ='RING_BUFFER_CONNECTIVITY'
    ) AS T
) AS T2
LEFT JOIN sys.messages AS m
    ON m.message_id = T2.SniConsumerError
ORDER BY
    time_stamp_jst DESC