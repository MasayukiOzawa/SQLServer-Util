DROP TABLE IF EXISTS xevent_format
GO

SELECT top 1000
    timestamp AT TIME ZONE 'Tokyo Standard Time' AS time_stamp,
    duration_ms,
    lock_mode,
    blocked_process.value('(//blocking-process/process/@lastbatchstarted)[1]', 'datetime2(3)') AS blocking_batch_start_time,
    blocked_process.value('(//blocking-process/process/@spid)[1]', 'int') AS blocking_spid,
    blocked_process.value('(//blocking-process/process/@waitresource)[1]', 'varchar(100)') AS blocking_wait_resource,
    blocked_process.value('(//blocking-process/process/@waittime)[1]', 'bigint') AS blocking_wait_time,
    blocked_process.value('(//blocking-process/process/@status)[1]', 'varchar(100)') AS blocking_wait_status,
    blocked_process.value('(//blocked-process/process/@lastbatchstarted)[1]', 'datetime2(3)') AS blocked_batch_start_time,
    blocked_process.value('(//blocked-process/process/@spid)[1]', 'int') AS blocked_spid,
    blocked_process.value('(//blocked-process/process/@waitresource)[1]', 'varchar(100)') AS blocked_wait_resource,
    blocked_process.value('(//blocked-process/process/@waittime)[1]', 'bigint') AS blocked_wait_time,
    blocked_process.value('(//blocked-process/process/@status)[1]', 'varchar(100)') AS blocked_wait_status
  ,blocked_process
-- INTO xevent_format
FROM(
SELECT
    timestamp,
    CAST(duration / 1000 AS int) AS duration_ms,
    -- object_id,
    CAST(lock_mode AS varchar(100)) AS lock_mode,
    CAST(blocked_process AS xml) AS blocked_process
from 
    [dbo].[xevent_20210101] 
) AS T
ORDER BY timestamp
GO

CREATE CLUSTERED COLUMNSTORE INDEX CCIX_xevent ON xevent_format
GO


