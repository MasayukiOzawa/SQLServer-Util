exec sp_executesql @stmt=N'begin try
declare @tran_tab table(
        row_id int identity
,       tran_id bigint
);

insert into @tran_tab 
select top 20 st.transaction_id 
from sys.dm_tran_active_transactions at  
inner join sys.dm_tran_session_transactions st on (at.transaction_id = st.transaction_id) 
order by at.transaction_begin_time

Select (tt.row_id)%2 as l1
,       (dense_rank() over( order by tt.row_id,d.name))%2 as l2
,       st.transaction_id 
,       d.name
,       dt.database_transaction_state as database_tran_state                    
,       case when sql_handle IS NULL 
                then ''--'' 
                else ( select top 1 substring(text,(statement_start_offset+2)/2, (case when statement_end_offset = -1   then (len(convert(nvarchar(MAX),text))*2)  else statement_end_offset  end - statement_start_offset) /2  ) from sys.dm_exec_sql_text(sql_handle)) 
        end as text
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
        end state
,       case when at.transaction_type <> 4 
                then case convert(int,r.transaction_isolation_level) 
                                when 1 then ''Read Uncommitted'' 
                                when 2 then ''Read Committed'' 
                                when 3 then ''Repeatable Read'' 
                                when 4 then ''Serializable'' 
                                when 5 then ''Snapshot'' 
                                else ''Unknown'' 
                         end  
                else case at.dtc_isolation_level 
                                when 0xffffffff then ''Unknown'' 
                                when 0x10 then ''Chaos'' 
                                when 0x100 then ''Read Uncommitted'' 
                                when 0x1000 then ''Read Committed'' 
                                when 0x10000 then ''Repeatable Read'' 
                                when 0x100000 then ''Serializable'' 
                                when 0x1000000 then ''Isolated'' 
                         end 
        end as transaction_isolation_level
,       ( Select count(*) from sys.dm_tran_locks where request_owner_id = st.transaction_id and dt.database_id  = resource_database_id ) as tran_locks_count
,       ( Select count(distinct database_id) from sys.dm_tran_database_transactions where transaction_id = st.transaction_id ) as db_span_count
,       st.is_local 
,       s.login_name
from @tran_tab tt 
inner join sys.dm_tran_active_transactions at on (at.transaction_id = tt.tran_id) 
left outer join sys.dm_tran_session_transactions st     on(st.transaction_id = tt.tran_id)
left outer join  sys.dm_tran_database_transactions dt on (st.transaction_id = dt.transaction_id) 
left outer join sys.dm_exec_sessions s on ( st.session_id = s.session_id ) 
left outer join sys.databases d on (d.database_id = dt.database_id)
left outer join sys.dm_exec_requests r on (r.transaction_id = dt.transaction_id) 
order by at.transaction_begin_time,d.name
end try
begin catch
select -100 as l1
,       1 as l2,1 as transaction_id,1 as name,1 as database_tran_state,1 as text,1 as session_id,1 as trans_name,1 as trans_type,1 as tran_start_time,1 as first_update_time,1 as state,1 as tran_isolation_level
,       ERROR_NUMBER() as tran_locks_count
,       ERROR_SEVERITY() as db_span_count
,       ERROR_STATE() as is_local
,       ERROR_MESSAGE() as login_name
end catch',@params=N''