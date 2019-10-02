exec sp_executesql @stmt=N'begin try 
select (dense_rank() over(order by (case when at.transaction_type = 4 then case at.dtc_state when 1 then ''Active'' when 2 then ''Prepared'' when 3 then ''Committed'' when 4 then ''Aborted'' when 5 then ''Recovered'' end else case at.transaction_state when 0 then ''Invalid'' when 1 then ''Initialized'' when 2 then ''Active'' when 3 then ''Ended'' when 4 then ''Commit Started'' when 5 then ''Prepared'' when 6 then ''Committed'' when 7 then ''Rolling Back'' when 8 then ''Rolled Back'' end end)))%2 as l1
,       (dense_rank() over(order by (case when at.transaction_type = 4 then case at.dtc_state when 1 then ''Active'' when 2 then ''Prepared'' when 3 then ''Committed'' when 4 then ''Aborted'' when 5 then ''Recovered'' end else case at.transaction_state when 0 then ''Invalid'' when 1 then ''Initialized'' when 2 then ''Active'' when 3 then ''Ended'' when 4 then ''Commit Started'' when 5 then ''Prepared'' when 6 then ''Committed'' when 7 then ''Rolling Back'' when 8 then ''Rolled Back'' end end),st.session_id, s.host_name, s.program_name, s.login_name, s.login_time))%2 as l2
,       (dense_rank() over(order by (case when at.transaction_type = 4 then case at.dtc_state when 1 then ''Active'' when 2 then ''Prepared'' when 3 then ''Committed'' when 4 then ''Aborted'' when 5 then ''Recovered'' end else case at.transaction_state when 0 then ''Invalid'' when 1 then ''Initialized'' when 2 then ''Active'' when 3 then ''Ended'' when 4 then ''Commit Started'' when 5 then ''Prepared'' when 6 then ''Committed'' when 7 then ''Rolling Back'' when 8 then ''Rolled Back'' end end),st.session_id, s.host_name, s.program_name, s.login_name, s.login_time, dt.transaction_id))%2 as l3
,       (dense_rank() over(order by (case when at.transaction_type = 4 then case at.dtc_state when 1 then ''Active'' when 2 then ''Prepared'' when 3 then ''Committed'' when 4 then ''Aborted'' when 5 then ''Recovered'' end else case at.transaction_state when 0 then ''Invalid'' when 1 then ''Initialized'' when 2 then ''Active'' when 3 then ''Ended'' when 4 then ''Commit Started'' when 5 then ''Prepared'' when 6 then ''Committed'' when 7 then ''Rolling Back'' when 8 then ''Rolled Back'' end end),st.session_id, s.host_name, s.program_name, s.login_name, s.login_time, dt.transaction_id ,(case when obj.name is null then ''Other resources'' else obj.name end)))%2 as l4
,       (dense_rank() over(order by (case when at.transaction_type = 4 then case at.dtc_state when 1 then ''Active'' when 2 then ''Prepared'' when 3 then ''Committed'' when 4 then ''Aborted'' when 5 then ''Recovered'' end else case at.transaction_state when 0 then ''Invalid'' when 1 then ''Initialized'' when 2 then ''Active'' when 3 then ''Ended'' when 4 then ''Commit Started'' when 5 then ''Prepared'' when 6 then ''Committed'' when 7 then ''Rolling Back'' when 8 then ''Rolled Back'' end end),st.session_id, s.host_name, s.program_name, s.login_name, s.login_time, dt.transaction_id,(case when obj.name is null then ''Other resources'' else obj.name end),tl.resource_type))%2 as l5
,       dense_rank() over(partition by case when at.transaction_type =4 then case at.dtc_state when 1 then 2 when 2 then 5 when 3 then 6 when 4 then 9 when 5 then 10 else at.dtc_state*2 end else at.transaction_state end order by dt.transaction_id)as rank
,       st.session_id
,       s.host_name
,       s.program_name
,       s.login_name
,       s.login_time
,       s.host_process_id
,       dt.transaction_id as tran_id
,       at.name
,       at.transaction_begin_time as tran_start_time
,       case when at.transaction_type = 4 
                then case at.dtc_state 
                                when 1 then ''Active'' 
                                when 2 then ''Prepared'' 
                                when 3 then ''Committed'' 
                                when 4 then ''Aborted'' 
                                when 5 then ''Recovered'' 
                        end 
                else case at.transaction_state 
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
        end as state
,       case when at.transaction_type = 4 
                then case at.dtc_isolation_level 
                                when 0xffffffff then ''Unknown'' 
                                when 0x10 then ''Chaos'' 
                                when 0x100 then ''Read Uncommitted'' 
                                when 0x1000 then ''Read Committed'' 
                                when 0x10000 then ''Repeatable Read'' 
                                when 0x100000 then ''Serializable'' 
                                when 0x100000 then ''Isolated'' 
                        end 
                else case Convert(int,r.transaction_isolation_level)    
                                when 1 then ''Read Uncommitted''  
                                when 2 then ''Read Committed'' 
                                when 3 then ''Repeatable Read'' 
                                when 4 then ''Serializable'' 
                                when 5 then ''Snapshot'' 
                                else ''Unknown'' 
                        end 
        end as transaction_isolation_level 
,       at.transaction_type as tran_type
,       (select count(*) from sys.dm_tran_locks tlock where  (tlock.request_owner_id = dt.transaction_id and tlock.resource_database_id = db_id()) ) as ''total''
,       tl.resource_type
,       case when obj.name is null then ''Other resources'' else obj.name end as resource_name
,       convert( varchar,tl.request_mode) as request_mode
,       (select count(*) from sys.dm_tran_locks tlock left outer join sys.partitions pt1 on ( pt1.hobt_id = tlock.resource_associated_entity_id ) left outer join sys.objects obj1 on ( obj1.object_id in (pt1.object_id, tlock.resource_associated_entity_id) )  where ( 1 = (case when obj.object_id is null then 1 else case when obj1.object_id = obj.object_id then 1 else 0 end end ) ) and (tlock.resource_type = tl.resource_type) and (tlock.request_mode = tl.request_mode) and (tlock.request_owner_id = dt.transaction_id) and tlock.resource_database_id = db_id() and (tlock.request_status = ''GRANT'') ) as ''Granted'' 
,       (select count(*) from sys.dm_tran_locks tlock left outer join sys.partitions pt1 on ( pt1.hobt_id = tlock.resource_associated_entity_id ) left outer join sys.objects obj1 on ( obj1.object_id in (pt1.object_id, tlock.resource_associated_entity_id) )  where ( 1 = (case when obj.object_id is null then 1 else case when obj1.object_id = obj.object_id then 1 else 0 end end ) ) and (tlock.resource_type = tl.resource_type) and (tlock.request_mode = tl.request_mode) and (tlock.request_owner_id = dt.transaction_id) and tlock.resource_database_id = db_id() and (tlock.request_status = ''WAIT'') ) as ''Waiting''
,       (select count(*) from sys.dm_tran_database_transactions where transaction_id = dt.transaction_id) as db_span_count
,       st.is_local 
from    sys.dm_tran_database_transactions dt 
left outer join sys.dm_tran_locks tl on ( (tl.request_owner_id = dt.transaction_id) and ( tl.resource_database_id = DB_ID() ) ) 
inner join sys.dm_tran_active_transactions at  on (at.transaction_id = dt.transaction_id)   
inner join sys.dm_tran_session_transactions st  on (st.transaction_id = dt.transaction_id) 
left outer join sys.dm_exec_sessions s on ( st.session_id = s.session_id ) 
left outer join sys.dm_exec_requests r on (r.transaction_id = dt.transaction_id)  
left outer join sys.partitions pt on ( pt.hobt_id = case when tl.resource_type in (''RID'', ''KEY'', ''PAGE'', ''EXTENT'') then (tl.resource_associated_entity_id) else null end  )     
left outer join sys.objects obj on ( obj.object_id = ( case when tl.resource_type in (''TABLE'') then tl.resource_associated_entity_id when tl.resource_type in (''RID'', ''KEY'', ''PAGE'', ''EXTENT'') then pt.object_id else null end ) ) 
where (dt.database_id = DB_ID()) and (st.is_user_transaction=1) 
group by        st.session_id, s.host_name, s.program_name, s.login_name, s.login_time, s.host_process_id, dt.transaction_id,at.name, at.transaction_begin_time, at.transaction_state, at.dtc_state, r.transaction_isolation_level, at.dtc_isolation_level, at.transaction_type, obj.object_id, obj.name, tl.resource_type, tl.request_mode, st.is_local order by  st.session_id, dt.transaction_id,at.name, r.transaction_isolation_level, at.transaction_type, obj.object_id, obj.name, tl.resource_type, tl.request_mode 
end try 
begin catch 
select 1 as rank, 1 as session_id, 1 as host_name, 1 as program_name, 1 as login_name, 1 as login_time, 1 as host_process_id, 1 as tran_id, 1 as name, 1 as tran_start_time, 1 as state, 1 as transaction_isolation_level, 1 as tran_type, 1 as total, 1 as resource_type
,       ERROR_NUMBER()  as resource_name
,       ERROR_SEVERITY() as request_mode
,       ERROR_STATE() as Granted
,       ERROR_MESSAGE() as Waiting
,       1 as db_span_count, 1 as is_local
,       -100 as l1
,       1 as l2, 1 as l3, 1 as l4, 1 as l5  
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try 
select case when counter_name = ''Transaction ownership waits'' then instance_name else counter_name end as name 
,       cntr_value 
from sys.dm_os_performance_counters p  
where  p.counter_name = ''Transaction ownership waits''  
end try 
begin catch 
select 1 as name, -100 as cntr_value 
end catch',@params=N''
go
