SELECT 
    *,
     CASE waiting_tasks_count 
        WHEN 0 THEN 0
        ELSE wait_time_ms / waiting_tasks_count
    END AS avg_wait_time_ms
FROM 
    sys.dm_os_wait_stats
ORDER BY
    avg_wait_time_ms DESC
GO

SELECT
    *,
    CASE waiting_requests_count
        WHEN 0 THEN 0
        ELSE wait_time_ms / waiting_requests_count
    END AS avg_wait_time_ms
FROM
    sys.dm_os_latch_stats
ORDER BY
    avg_wait_time_ms DESC
GO

SELECT
    *
FROM
    sys.dm_os_spinlock_stats
ORDER BY
    spins DESC
GO
