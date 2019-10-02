exec sp_executesql @stmt=N'begin try  
select top 20 (row_number() over (order by at.transaction_begin_time))%2 as l1
,       s.login_name
,       st.transaction_id 
,       case when sql_handle IS NULL 
        then ''--'' 
        else ( select top 1 substring(text,(statement_start_offset+2)/2, (case when statement_end_offset = -1   then (len(convert(nvarchar(MAX),text))*2)  else statement_end_offset  end - statement_start_offset) /2  ) from sys.dm_exec_sql_text(sql_handle)) end as text
,       st.session_id
,       at.name as trans_name
,       at.transaction_type as trans_type
,       at.transaction_begin_time as tran_start_time
,       dt.database_transaction_begin_time as first_update_time
,       case when at.transaction_type <> 4 
                then case at.transaction_state 
                                when 0 then ''Invalid'' 
                                when 1 then ''Initialized'' 
                                when 2 then ''Active'' 
                                when 3 then ''Ended'' 
                                when 4 then ''Commit Started'' 
                                when 5 then ''Prepared'' 
                                when 6 then ''Committed'' 
                                when 7 then ''Rolling Back'' 
                                when 8 then ''Rolled Back'' 
                        end 
                else case at.dtc_state 
                                when 1 then ''Active'' 
                                when 2 then ''Prepared'' 
                                when 3 then ''Committed'' 
                                when 4 then ''Aborted'' 
                                when 5 then ''Recovered'' 
                        end 
        end as state
,       case convert(int,r.transaction_isolation_level) 
                when 1 then ''Read Uncommitted'' 
                when 2 then ''Read Committed'' 
                when 3 then ''Repeatable Read'' 
                when 4 then ''Serializable'' 
                when 5 then ''Snapshot'' 
                else ''Unknown'' 
        end as transaction_isolation_level
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = st.transaction_id  and dt.database_id  = resource_database_id ) as tran_locks_count
,       ( select count(distinct database_id) from sys.dm_tran_database_transactions where transaction_id = st.transaction_id ) as db_span_count
,       st.is_local 
from sys.dm_tran_active_transactions at 
inner join sys.dm_tran_session_transactions st  on (at.transaction_id = st.transaction_id) 
left outer join  sys.dm_tran_database_transactions dt on (st.transaction_id = dt.transaction_id) 
left outer join sys.dm_exec_sessions s on ( st.session_id = s.session_id ) 
left outer join sys.dm_exec_requests r on (r.transaction_id = dt.transaction_id)  
where (1 = case when dt.database_id is null then 1 else (case when dt.database_id = DB_ID() then 1 else 0 end) end)  
order by at.transaction_begin_time  
end try 
begin catch 
select -100 as l1
,       ERROR_MESSAGE() as login_name
,       1 as transaction_id, 1 as text,1 as session_id,1 as trans_name,1 as trans_type,1 as tran_start_time,1 as first_update_time,1 as name,1 as database_tran_state,1 as trans_type,1 as tran_start_time,1 as first_update_time,1 as Status,1 as tran_isolation_level
,       ERROR_NUMBER() as tran_locks_count
,       ERROR_SEVERITY() as db_span_count
,       ERROR_STATE() as is_local 
end catch',@params=N''