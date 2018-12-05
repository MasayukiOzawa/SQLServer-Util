exec sp_executesql N'SELECT ((CONVERT(BIGINT, DATEDIFF(day, 0, [end_time])) * 24 * 3600 + DATEDIFF(second, DATEADD(day, DATEDIFF(day, 0, [end_time]), 0), [end_time])) / @timeGrain) * @timeGrain as start_time_interval
               , AVG(cpu_percent) as avg_cpu_percent
               , AVG(storage_limit) as reserved_storage_mb
               , AVG(storage_used) as storage_space_used_mb
               , AVG(vcore_count) as virtual_core_count
               , MIN(cpu_percent) as avg_cpu_percent_min
               , MIN(storage_limit) as reserved_storage_mb_min
               , MIN(storage_used) as storage_space_used_mb_min
               , MIN(vcore_count) as virtual_core_count_min
               , MAX(cpu_percent) as avg_cpu_percent_max
               , MAX(storage_limit) as reserved_storage_mb_max
               , MAX(storage_used) as storage_space_used_mb_max
               , MAX(vcore_count) as virtual_core_count_max
               , COUNT(cpu_percent) as count
            FROM
                -- raw data points of 15 seconds
                (SELECT
                    end_time
                   , ISNULL(avg_cpu_percent, 0) as cpu_percent
                   , ISNULL(reserved_storage_mb, 0) as storage_limit
                   , ISNULL(storage_space_used_mb , 0) as storage_used
                   , ISNULL(virtual_core_count , 0) as vcore_count
                FROM sys.server_resource_stats 
                WHERE [end_time] >= @startTime AND [end_time] <= @endTime
                ) t
            GROUP BY ((CONVERT(BIGINT, DATEDIFF(day, 0, [end_time])) * 24 * 3600 + DATEDIFF(second, DATEADD(day, DATEDIFF(day, 0, [end_time]), 0), [end_time])) / @timeGrain) * @timeGrain;',N'@startTime datetime,@endTime datetime,@timeGrain int',@startTime='2018-06-11 00:35:00',@endTime='2018-06-11 00:50:08.500',@timeGrain=300
GO

exec sp_executesql N'SELECT ((CONVERT(BIGINT, DATEDIFF(day, 0, [end_time])) * 24 * 3600 + DATEDIFF(second, DATEADD(day, DATEDIFF(day, 0, [end_time]), 0), [end_time])) / @timeGrain) * @timeGrain as start_time_interval
               , AVG(cpu_percent) as avg_cpu_percent
               , AVG(storage_limit) as reserved_storage_mb
               , AVG(storage_used) as storage_space_used_mb
               , AVG(vcore_count) as virtual_core_count
               , MIN(cpu_percent) as avg_cpu_percent_min
               , MIN(storage_limit) as reserved_storage_mb_min
               , MIN(storage_used) as storage_space_used_mb_min
               , MIN(vcore_count) as virtual_core_count_min
               , MAX(cpu_percent) as avg_cpu_percent_max
               , MAX(storage_limit) as reserved_storage_mb_max
               , MAX(storage_used) as storage_space_used_mb_max
               , MAX(vcore_count) as virtual_core_count_max
               , COUNT(cpu_percent) as count
            FROM
                -- raw data points of 15 seconds
                (SELECT
                    end_time
                   , ISNULL(avg_cpu_percent, 0) as cpu_percent
                   , ISNULL(reserved_storage_mb, 0) as storage_limit
                   , ISNULL(storage_space_used_mb , 0) as storage_used
                   , ISNULL(virtual_core_count , 0) as vcore_count
                FROM sys.server_resource_stats 
                WHERE [end_time] >= @startTime AND [end_time] <= @endTime
                ) t
            GROUP BY ((CONVERT(BIGINT, DATEDIFF(day, 0, [end_time])) * 24 * 3600 + DATEDIFF(second, DATEADD(day, DATEDIFF(day, 0, [end_time]), 0), [end_time])) / @timeGrain) * @timeGrain;',N'@startTime datetime,@endTime datetime,@timeGrain int',@startTime='2018-06-10 00:50:00',@endTime='2018-06-11 00:50:08.403',@timeGrain=300
GO