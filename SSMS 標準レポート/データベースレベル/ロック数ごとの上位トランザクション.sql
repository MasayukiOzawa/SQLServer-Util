exec sp_executesql @stmt=N'begin try  
declare @top_tran table (
        row_no int identity
,       login_name sysname collate database_default null
,       tran_id bigint
,       sql_handle varbinary(68)
,       statement_start_offset int
,       statement_end_offset int
,       session_id int
,       tran_name sysname collate database_default  null
,       tran_type nvarchar(60) collate database_default 
,       tran_start_time datetime
,       db_tran_begin_time datetime
,       tran_state nvarchar(60) collate database_default 
,       transaction_isolation_level nvarchar(60) collate database_default 
,       db_span_count int
,       is_local tinyint
,       locks_count as (metadata_locks_count +  database_locks_count +  file_locks_count +      table_locks_count +     extent_locks_count +    page_locks_count +      row_locks_count +       others_locks_count )
,       metadata_locks_count int
,       database_locks_count int
,       file_locks_count int
,       table_locks_count int
,       extent_locks_count int
,       page_locks_count int
,       row_locks_count int
,       others_locks_count int  
);      

insert into @top_tran   
select top 20 s.login_name
,       st.transaction_id 
,       sql_handle
,       statement_start_offset
,       statement_end_offset
,       st.session_id
,       at.name as trans_name
,       at.transaction_type as tranc_type
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
        end as Status
,       case convert(int,r.transaction_isolation_level) 
                when 1 then ''Read Uncommitted'' 
                when 2 then ''Read Committed'' 
                when 3 then ''Repeatable Read'' 
                when 4 then ''Serializable'' 
                when 5 then ''Snapshot'' 
                else ''Unknown'' 
        end as transaction_isolation_level
,       ( select count(distinct database_id) from sys.dm_tran_database_transactions where transaction_id = st.transaction_id ) as db_span_count
,       st.is_local
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''METADATA'' ) as ''metadata_locks_count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''DATABASE'' ) as ''database_locks_count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''FILE'' ) as ''file_locks_count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type in (''TABLE'',''HOBT'') ) as ''table_locks_count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''EXTENT'' ) as ''extent_locks_count''
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''PAGE'' ) as ''page_locks_count''
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type in (''RID'',''KEY'') ) as ''row_locks_count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type not in (''METADATA'',''DATABASE'',''FILE'',''TABLE'',''EXTENT'',''PAGE'',''RID'',''KEY'',''HOBT'') ) as ''other_locks_count'' 
from sys.dm_tran_active_transactions at 
inner join sys.dm_tran_session_transactions st  on (at.transaction_id = st.transaction_id) 
left outer join  sys.dm_tran_database_transactions dt on (st.transaction_id = dt.transaction_id) 
left outer join sys.dm_exec_sessions s on ( st.session_id = s.session_id ) 
left outer join sys.dm_exec_requests r on (r.transaction_id = dt.transaction_id)  
where (dt.database_id = db_id()) and st.is_user_transaction = 1 
order by [metadata_locks_count] desc,[database_locks_count] desc,[file_locks_count] desc,[table_locks_count] desc,[extent_locks_count] desc, [page_locks_count] desc, [row_locks_count] desc, [other_locks_count] desc          

select tt.*
,       case when tt.sql_handle is null 
                then ''--'' 
                else ( select top 1 substring(text,(tt.statement_start_offset+2)/2,     (case when tt.statement_end_offset = -1  then (len(convert(nvarchar(MAX),text))*2)  else tt.statement_end_offset  end - tt.statement_start_offset) /2  ) from sys.dm_exec_sql_text(tt.sql_handle)) 
        end as text
,       tl.resource_type
,       case tl.resource_type 
                when ''METADATA''  then 1 
                when ''DATABASE'' then 2 
                when ''FILE'' then 3 
                when ''TABLE'' then 4 
                when ''HOBT'' then 5 
                when ''EXTENT'' then 6 
                when ''PAGE'' then 7 
                when ''KEY'' then 8 
                when ''RID'' then 9 
                when ''ALLOCATION_UNIT'' then 10 
                when ''APPLICATION'' then 11 
        end as resource_rank
,       tl.request_status
,       convert( varchar,tl.request_mode)as request_mode
,       sch.name as schema_name
,       case when o.name is null 
                then ''Other resources'' 
                else o.name 
        end as obj_name
,       o.object_id as obj_id
,       (dense_rank() over (order by tt.row_no,sch.name , o.name,(case tl.resource_type when ''METADATA''  then 1 when ''DATABASE'' then 2 when ''FILE'' then 3 when ''TABLE'' then 4 when ''HOBT'' then 5 when ''EXTENT'' then 6 when ''PAGE'' then 7 when ''KEY'' then 8 when ''RID'' then 9 when ''ALLOCATION_UNIT'' then 10 when ''APPLICATION'' then 11 end) ))%2 as l3
,       (dense_rank() over (order by tt.row_no,sch.name , o.name ))%2 as l2 
,       (row_no)%2 as l1             
from @top_tran tt       
left outer join sys.dm_tran_locks tl on (tl.request_owner_id = tt.tran_id and tl.resource_database_id = db_id()) 
left outer join sys.partitions p on (tl.resource_type in (''PAGE'',''KEY'',''RID'',''HOBT'') and p.hobt_id = tl.resource_associated_entity_id) 
left outer join sys.objects o on ((tl.resource_type in (''PAGE'',''KEY'',''RID'',''HOBT'') and o.object_id = p.object_id) or (tl.resource_type not in (''PAGE'',''KEY'',''RID'',''HOBT'') and o.object_id = tl.resource_associated_entity_id)) 
left outer join sys.schemas sch on (o.schema_id = sch.schema_id) 
end try 
begin catch 
select  1 as row_no ,   1 as login_name ,       1 as tran_id ,  1 as sql_handle ,       1 as statement_start_offset ,   1 as statement_end_offset ,     1 as session_id ,       1 as tran_name ,        1 as tran_type ,        1 as tran_start_time ,  1 as db_tran_begin_time ,       1 as status ,   1 as tran_isolation_level ,     1 as db_span_count ,    1 as is_local , 1 as locks_count ,      1 as metadata_locks_count ,     1 as database_locks_count ,     1 as file_locks_count , 1 as table_locks_count ,        1 as extent_locks_count ,       1 as page_locks_count , 1 as row_locks_count ,    1 as others_locks_count,      1 as text,      1 as resource_type,     1 as resource_rank,     1 as request_status,    1 as request_mode,      1 as schema_name
,       ERROR_MESSAGE() as obj_name
,       ERROR_STATE() as obj_id
,       ERROR_SEVERITY() as l3
,       ERROR_NUMBER() as l2
,       -100 as l1 
end catch',@params=N''