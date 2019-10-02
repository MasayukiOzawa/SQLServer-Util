exec sp_executesql @stmt=N'begin try
declare @db_id int
declare @db_name sysname
declare @resource_type nvarchar(60)
declare @obj_or_hobt_id bigint
declare @cnt int
declare @obj_cnt int
declare @cmd nvarchar(max)
declare @top_tran table (
        tran_id bigint
,       sql_handle varbinary(68)
,       statement_start_offset int
,       statement_end_offset int
,       tran_name sysname collate database_default  null
,       session_id int
,       tran_type int
,       tran_start_time datetime
,       tran_state nvarchar(50) collate database_default 
,       transaction_isolation_level nvarchar(50) collate database_default 
,       db_span_count int
,       is_local tinyint
,       locks_count as (metadata_locks_count+database_locks_count+file_locks_count+table_locks_count+extent_locks_count+        page_locks_count+row_locks_count+others_locks_count)
,       metadata_locks_count int
,       database_locks_count int
,       file_locks_count int
,       table_locks_count int
,       extent_locks_count int
,       page_locks_count int
,       row_locks_count int
,       others_locks_count int
,       login_name sysname  collate database_default null
);
declare @db_tran table(
        tran_id bigint
,       db_name sysname collate database_default  null
,       db_id int
,       db_tran_state nvarchar(50) collate database_default 
,       db_tran_begin_time datetime
,       db_locks_count as (db_metadata_locks_count+db_database_locks_count+db_file_locks_count+db_table_locks_count+ db_extent_locks_count+db_page_locks_count+db_row_locks_count+db_others_locks_count)
,       db_metadata_locks_count int
,       db_database_locks_count int
,       db_file_locks_count int
,       db_table_locks_count int
,       db_extent_locks_count int
,       db_page_locks_count int
,       db_row_locks_count int
,       db_others_locks_count int
);
declare @tran_locks table (
        row_no int identity
,       tran_id bigint
,       obj_or_hobt_id bigint
,       db_id int
,       resource_type nvarchar(60) collate database_default 
,   resource_rank smallint
,       request_status nvarchar(60) collate database_default 
,       request_mode nvarchar(60) collate database_default 
,       count bigint
);
declare @obj_info table (
        db_id int
,       obj_or_hobt_id bigint
,       obj_id bigint
,       obj_name sysname collate database_default null
,       schema_name sysname collate database_default null
);

insert into @top_tran
select top 20 st.transaction_id 
,       r.sql_handle
,       r.statement_start_offset
,       r.statement_end_offset
,       at.name as trans_name
,       st.session_id
,       at.transaction_type as trans_type
,       at.transaction_begin_time as tran_start_time
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
                                else ''Unspecified'' 
                        end  
                else case at.dtc_isolation_level 
                                when 0xffffffff then ''Unspecified'' 
                                when 0x10 then ''Chaos'' 
                                when 0x100 then ''Read Uncommitted'' 
                                when 0x1000 then ''Read Committed'' 
                                when 0x10000 then ''Repeatable Read'' 
                                when 0x100000 then ''Serializable'' 
                                when 0x100000 then ''Isolated'' 
                        end 
        end as tran_isolation_level
,       ( select count(distinct database_id) from sys.dm_tran_database_transactions where transaction_id = st.transaction_id ) as db_span_count
,       st.is_local
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = st.transaction_id and resource_type = ''METADATA'' ) as ''Metadata Locks Count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = st.transaction_id and resource_type = ''DATABASE'' ) as ''Database Locks Count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = st.transaction_id and resource_type = ''FILE'' ) as ''File Locks Count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = st.transaction_id and resource_type = ''TABLE'' ) as ''Table Locks Count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = st.transaction_id and resource_type = ''EXTENT'' ) as ''Extent Locks Count''
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = st.transaction_id and resource_type = ''PAGE'' ) as ''Page Locks Count''
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = st.transaction_id and resource_type in (''RID'',''KEY'',''HOBT'') ) as ''Row Locks Count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = st.transaction_id and resource_type not in (''METADATA'',''DATABASE'',''FILE'',''TABLE'',''EXTENT'',''PAGE'',''RID'',''KEY'',''HOBT'') ) as ''Other Locks Count'' 
,       s.login_name   
from    sys.dm_tran_active_transactions at
inner join sys.dm_tran_session_transactions st    on (at.transaction_id = st.transaction_id) 
left outer join sys.dm_exec_sessions s on ( st.session_id = s.session_id ) 
left outer join sys.dm_exec_requests r on (r.transaction_id = st.transaction_id) 
where (st.is_user_transaction=1) 
order by [Metadata Locks Count] desc,[Database Locks Count] desc,[File Locks Count] desc,[Table Locks Count] desc,[Extent Locks Count] desc, [Page Locks Count] desc, [Row Locks Count] desc, [Other Locks Count] desc

insert into @db_tran
select dt.transaction_id
,       db_name(dt.database_id)
,       dt.database_id
,       case dt.database_transaction_state 
                        when 1 then ''Uninitialized''
                        when 3 then ''Initialized''
                        when 4 then ''Active''
                        when 5 then ''Prepared''
                        when 10 then ''Committed''
                        when 11 then ''Rolled Back''
                        when 12 then ''Commiting''
                        else  ''Unknown State'' 
        end as db_tran_state
,       dt.database_transaction_begin_time 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''METADATA'' ) as ''Metadata Locks Count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''DATABASE'' ) as ''Database Locks Count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''FILE'' ) as ''File Locks Count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''TABLE'' ) as ''Table Locks Count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''EXTENT'' ) as ''Extent Locks Count''
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type = ''PAGE'' ) as ''Page Locks Count''
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type in (''RID'',''KEY'',''HOBT'') ) as ''Row Locks Count'' 
,       ( select count(*) from sys.dm_tran_locks where request_owner_id = dt.transaction_id and dt.database_id  = resource_database_id and resource_type not in (''METADATA'',''DATABASE'',''FILE'',''TABLE'',''EXTENT'',''PAGE'',''RID'',''KEY'',''HOBT'') ) as ''Other Locks Count''
from    sys.dm_tran_database_transactions dt 
where dt.transaction_id in (select tran_id from @top_tran)
        
insert into @tran_locks
select request_owner_id 
,       resource_associated_entity_id 
,       resource_database_id
,       resource_type
,       case resource_type 
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
        end
,       request_status
,       convert( varchar,request_mode) as request_mode
,       count(*)
from sys.dm_tran_locks 
where  request_owner_id in (select tran_id from @top_tran)
group by request_owner_id , resource_associated_entity_id , request_status , resource_type,     resource_database_id,request_mode


select @cnt = count(*) from @tran_locks
while @cnt > 0
begin
        select @db_id = db_id
        ,       @obj_or_hobt_id = obj_or_hobt_id
        ,       @resource_type = resource_type
        from @tran_locks where row_no = @cnt
        
        set @db_name = db_name(@db_id)
        select @obj_cnt = count(*) from @obj_info 
        where db_id = @db_id and obj_or_hobt_id = @obj_or_hobt_id
        
        if (@obj_cnt = 0)
        begin
                if @resource_type in (''PAGE'',''RID'')
                        set @cmd = ''select ''+convert(nvarchar(10),@db_id)+'',''+convert(nvarchar(50),@obj_or_hobt_id)+
                        '',o.object_id,o.name,s.name from [''+@db_name+''].sys.partitions p join [''+@db_name+''].sys.objects o ''+
                        ''on (p.object_id = o.object_id) join [''+@db_name+''].sys.schemas s on (o.schema_id = s.schema_id) ''+
                        ''where p.hobt_id = ''+convert(nvarchar(50),@obj_or_hobt_id)
                else 
                        set @cmd = ''select ''+convert(nvarchar(10),@db_id)+'',''+convert(nvarchar(50),@obj_or_hobt_id)+
                        '',o.object_id,o.name,s.name from [''+@db_name+''].sys.objects o join [''+@db_name+
                        ''].sys.schemas s on (o.schema_id = s.schema_id) ''+
                        ''where o.object_id = ''+convert(nvarchar(50),@obj_or_hobt_id)
        
                insert into @obj_info
                EXEC(@cmd)
        end
        set @cnt = @cnt-1;
end

select  (dense_rank() over (order by tt.metadata_locks_count desc
        ,       tt.database_locks_count desc
        ,       tt.file_locks_count desc
        ,       tt.table_locks_count desc
        ,       tt.extent_locks_count desc
        ,       tt.page_locks_count desc
        ,       tt.row_locks_count desc
        ,       tt.others_locks_count desc
        ,       tt.tran_id
        ))%2 as l1
,       (dense_rank() over (order by tt.metadata_locks_count desc
        ,       tt.database_locks_count desc
        ,       tt.file_locks_count desc
        ,       tt.table_locks_count desc
        ,       tt.extent_locks_count desc
        ,       tt.page_locks_count desc
        ,       tt.row_locks_count desc
        ,       tt.others_locks_count desc
        ,       tt.tran_id
        ,       dt.db_name
        ))%2 as l2
,       (dense_rank() over (order by tt.metadata_locks_count desc
        ,       tt.database_locks_count desc
        ,       tt.file_locks_count desc
        ,       tt.table_locks_count desc
        ,       tt.extent_locks_count desc
        ,       tt.page_locks_count desc
        ,       tt.row_locks_count desc
        ,       tt.others_locks_count desc
        ,       tt.tran_id
        ,       dt.db_name
        ,       oi.schema_name
        ,       oi.obj_name
        ))%2 as l3
,       (dense_rank() over (order by tt.metadata_locks_count desc
        ,       tt.database_locks_count desc
        ,       tt.file_locks_count desc        
        ,       tt.table_locks_count desc
        ,       tt.extent_locks_count desc
        ,       tt.page_locks_count desc
        ,       tt.row_locks_count desc
        ,       tt.others_locks_count desc
        ,       tt.tran_id
        ,       dt.db_name
        ,       oi.schema_name
        ,       oi.obj_name
        ,       tl.resource_rank
        ))%2 as l4
,       *
,       case when sql_handle IS NULL 
                then ''--'' 
                else ( select top 1 substring(text,statement_start_offset/2, (case when statement_end_offset = -1  then len(convert(nvarchar(MAX),text))*2  else statement_end_offset  end - statement_start_offset) /2  ) from sys.dm_exec_sql_text(sql_handle)) 
        end as text
from @top_tran tt
join @db_tran dt on (tt.tran_id = dt.tran_id)
join @tran_locks tl on (tt.tran_id = tl.tran_id and dt.db_id = tl.db_id)
join @obj_info oi on (tl.db_id = oi.db_id and tl.obj_or_hobt_id = oi.obj_or_hobt_id)
end try
begin catch
select -100 as l1
,       1 as l2,1 as l3,1 as l4,1 as tran_id,1 as sql_handle,1 as statement_start_offset,1 as statement_end_offset,1 as tran_name,1 as session_id,1 as tran_type,1 as tran_start_time,1 as tran_state,1 as tran_isolation_level,1 as db_span_count,1 as is_local,1 as locks_count,1 as metadata_locks_count,1 as database_locks_count,1 as file_locks_count,1 as table_locks_count,1 as extent_locks_count,1 as page_locks_count,1 as row_locks_count,1 as others_locks_count,1 as login_name,1 as tran_id_1,1 as db_name,1 as db_id,1 as db_tran_begin_time,1 as db_locks_count,1 as db_metadata_locks_count,1 as db_database_locks_count,1 as db_file_locks_count,1 as db_table_locks_count,1 as db_extent_locks_count,1 as db_page_locks_count,1 as db_row_locks_count,1 as db_others_locks_count,1 as row_no,1 as tran_id_2,1 as obj_or_hobt_id,1 as db_id_1,1 as resource_type,1 as resource_rank,1 as request_status,1 as request_mode,1 as count,1 as db_id_2,1 as obj_or_hobt_id_1
,       ERROR_NUMBER()  as obj_id
,       ERROR_SEVERITY() as obj_name
,       ERROR_STATE() as schema_name
,       ERROR_MESSAGE() as text
end catch',@params=N''