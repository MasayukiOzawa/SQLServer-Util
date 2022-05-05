(@P1 bigint)
WITH qstats
     AS (SELECT TOP 10000 
             query_hash,
             query_plan_hash,
             last_execution_time,
             plan_handle,
         (
             SELECT 
                 value
             FROM 
                 sys.dm_exec_plan_attributes(plan_handle)
             WHERE attribute = 'dbid'
         ) AS dbid,
         (
             SELECT 
                 value
             FROM 
                 sys.dm_exec_plan_attributes(plan_handle)
             WHERE attribute = 'user_id'
         ) AS user_id,
             execution_count,
             total_worker_time,
             total_physical_reads,
             total_logical_writes,
             total_logical_reads,
             total_clr_time,
             total_elapsed_time,
             total_rows,
             total_dop,
             total_grant_kb,
             total_used_grant_kb,
             total_ideal_grant_kb,
             total_reserved_threads,
             total_used_threads,
             total_columnstore_segment_reads,
             total_columnstore_segment_skips,
             total_spills
         FROM 
             sys.dm_exec_query_stats
         WHERE last_execution_time > DATEADD(second,-@P1,GETDATE())),
     qstats_aggr
     AS (SELECT 
             query_hash,
             query_plan_hash,
             CAST(S.dbid AS int) AS dbid,
             D.name AS database_name,
             U.name AS user_name,
             MAX(plan_handle) AS plan_handle,
             SUM(execution_count) AS execution_count,
             SUM(total_worker_time) AS total_worker_time,
             SUM(total_physical_reads) AS total_physical_reads,
             SUM(total_logical_writes) AS total_logical_writes,
             SUM(total_logical_reads) AS total_logical_reads,
             SUM(total_clr_time) AS total_clr_time,
             SUM(total_elapsed_time) AS total_elapsed_time,
             SUM(total_rows) AS total_rows,
             SUM(total_dop) AS total_dop,
             SUM(total_grant_kb) AS total_grant_kb,
             SUM(total_used_grant_kb) AS total_used_grant_kb,
             SUM(total_ideal_grant_kb) AS total_ideal_grant_kb,
             SUM(total_reserved_threads) AS total_reserved_threads,
             SUM(total_used_threads) AS total_used_threads,
             SUM(total_columnstore_segment_reads) AS total_columnstore_segment_reads,
             SUM(total_columnstore_segment_skips) AS total_columnstore_segment_skips,
             SUM(total_spills) AS total_spills
         FROM 
              qstats AS S
              LEFT JOIN sys.databases AS D
              ON S.dbid = D.database_id
              LEFT JOIN sys.sysusers AS U
              ON S.user_id = U.uid
         GROUP BY 
             query_hash,
             query_plan_hash,
             S.dbid,
             D.name,
             U.name)
     SELECT 
         text,
         *
     FROM 
          qstats_aggr
          CROSS APPLY sys.dm_exec_sql_text(plan_handle);