-- 両 DMV ともに最大で 15 秒間隔で 128 スナップショットまで取得
SELECT 
    * 
FROM 
    sys.dm_resource_governor_workload_groups_history_ex AS gh_ex
WHERE
    group_id = (SELECT group_id FROM sys.dm_exec_sessions where session_id = @@SPID)
ORDER BY snapshot_time ASC
GO

SELECT
    *
FROM
    sys.dm_resource_governor_resource_pools_history_ex AS rp_ex
WHERE
    pool_id = (SELECT pool_id FROM sys.dm_resource_governor_workload_groups 
WHERE
    group_id = (SELECT group_id FROM sys.dm_exec_sessions where session_id = @@SPID))
ORDER BY snapshot_time ASC
GO

-- 15 秒間隔で直近 1 時間
SELECT * FROM sys.dm_db_resource_stats ORDER BY end_time ASC
GO

-- パフォーマンスモニター
SELECT 
    * 
FROM 
    sys.dm_os_performance_counters
GO
