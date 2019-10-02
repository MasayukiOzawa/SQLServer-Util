exec sp_executesql @stmt=N'begin try
select top 10 rank() over(order by (total_worker_time+0.0)/execution_count desc,sql_handle,statement_start_offset ) as row_no
,       (rank() over(order by (total_worker_time+0.0)/execution_count desc,sql_handle,statement_start_offset ))%2 as l1
,       creation_time
,       last_execution_time 
,       (total_worker_time+0.0)/1000 as total_worker_time
,       (total_worker_time+0.0)/(execution_count*1000) as [AvgCPUTime]
,       total_logical_reads as [LogicalReads]
,       total_logical_writes as [LogicalWrites]
,       execution_count
,       total_logical_reads+total_logical_writes as [AggIO]
,       (total_logical_reads+total_logical_writes)/(execution_count+0.0) as [AvgIO]
,       case when sql_handle IS NULL
                then '' ''
                else ( substring(st.text,(qs.statement_start_offset+2)/2,       (case when qs.statement_end_offset = -1         then len(convert(nvarchar(MAX),st.text))*2      else qs.statement_end_offset    end - qs.statement_start_offset) /2  ) )
        end as query_text 
,       db_name(st.dbid) as db_name
,       st.objectid as object_id
from sys.dm_exec_query_stats  qs
cross apply sys.dm_exec_sql_text(sql_handle) st
where total_worker_time  > 0 
order by [AvgCPUTime] desc
end try
begin catch
select -100 as row_no
,       1 as l1, 1 as create_time,1 as last_execution_time,1 as total_worker_time,1 as AvgCPUTime,1 as LogicalReads,1 as LogicalWrites
,       ERROR_NUMBER() as execution_count
,       ERROR_SEVERITY() as AggIO
,       ERROR_STATE() as AvgIO
,       ERROR_MESSAGE() as query_text
,       0 as db_name
,       0 as object_name
end catch',@params=N''