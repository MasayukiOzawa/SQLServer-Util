exec sp_executesql @stmt=N'--object execution statistics
begin try
declare @cnt int;
declare @record_count int;
declare @dbid int;
declare @objectid int;
declare @cmd nvarchar(MAX);
declare @grand_total_worker_time float ; 
declare @grand_total_IO float ; 
declare @sql_handle_convert_table table(
        row_id int identity 
,       t_sql_handle varbinary(64)
,       t_display_option varchar(140) collate database_default
,       t_display_optionIO varchar(140) collate database_default
,       t_sql_handle_text varchar(140) collate database_default
,       t_SPRank int
,       t_dbid int
,       t_objectid int
,       t_SQLStatement varchar(max) collate database_default
,       t_execution_count int
,       t_plan_generation_num int
,       t_last_execution_time datetime
,       t_avg_worker_time float
,       t_total_worker_time float
,       t_last_worker_time float
,       t_min_worker_time float
,       t_max_worker_time float
,       t_avg_logical_reads float
,       t_total_logical_reads bigint
,       t_last_logical_reads bigint
,       t_min_logical_reads bigint
,       t_max_logical_reads bigint
,       t_avg_logical_writes float
,       t_total_logical_writes bigint
,       t_last_logical_writes bigint
,       t_min_logical_writes bigint
,       t_max_logical_writes bigint
,       t_avg_logical_IO float
,       t_total_logical_IO bigint
,       t_last_logical_IO bigint
,       t_min_logical_IO bigint
,       t_max_logical_IO bigint     
);
declare @objects table (
        obj_rank int
,       total_cpu bigint
,       total_logical_reads bigint
,       total_logical_writes bigint
,       total_logical_io bigint
,       avg_cpu bigint
,       avg_reads bigint
,       avg_writes bigint
,       avg_io bigint
,       cpu_rank int
,       total_cpu_rank int
,       logical_read_rank int
,       logical_write_rank int
,       logical_io_rank int
);
declare @object_name table (
        dbId int
,       objectId int
,       dbName sysname collate database_default null
,       objectName sysname collate database_default null
,       objectType nvarchar(5) collate database_default null
,       schemaName sysname collate database_default null
)

insert into @sql_handle_convert_table 
Select  sql_handle
,       sql_handle as chart_display_option 
,       sql_handle as chart_display_optionIO 
,       master.dbo.fn_varbintohexstr(sql_handle)
,       dense_rank() over (order by s2.dbid,s2.objectid) as SPRank 
,       s2.dbid
,       s2.objectid
,       (select top 1 substring(text,(s1.statement_start_offset+2)/2, (case when s1.statement_end_offset = -1  then len(convert(nvarchar(max),text))*2 else s1.statement_end_offset end - s1.statement_start_offset) /2  ) from sys.dm_exec_sql_text(s1.sql_handle)) as [SQL Statement]
,       execution_count
,       plan_generation_num
,       last_execution_time
,       ((total_worker_time+0.0)/execution_count)/1000 as [avg_worker_time]
,       total_worker_time/1000.0
,       last_worker_time/1000.0
,       min_worker_time/1000.0
,       max_worker_time/1000.0
,       ((total_logical_reads+0.0)/execution_count) as [avg_logical_reads]
,       total_logical_reads
,       last_logical_reads
,       min_logical_reads
,       max_logical_reads
,       ((total_logical_writes+0.0)/execution_count) as [avg_logical_writes]
,       total_logical_writes
,       last_logical_writes
,       min_logical_writes
,       max_logical_writes
,       ((total_logical_writes+0.0)/execution_count + (total_logical_reads+0.0)/execution_count) as [avg_logical_IO]
,       total_logical_writes + total_logical_reads
,       last_logical_writes +last_logical_reads
,       min_logical_writes +min_logical_reads
,       max_logical_writes + max_logical_reads  
from    sys.dm_exec_query_stats s1 
cross apply sys.dm_exec_sql_text(sql_handle) as  s2 
where   s2.objectid is not null and db_name(s2.dbid) is not null
order by  s1.sql_handle; 

select @grand_total_worker_time = sum(t_total_worker_time) ,
           @grand_total_IO = sum(t_total_logical_reads + t_total_logical_writes)  
from @sql_handle_convert_table; 

select @grand_total_worker_time = case when @grand_total_worker_time > 0 then @grand_total_worker_time else 1.0 end  ; 
select @grand_total_IO = case when @grand_total_IO > 0 then @grand_total_IO else 1.0 end  ; 

set @cnt = 1;  
select @record_count = count(*) from @sql_handle_convert_table  ; 
while (@cnt <= @record_count)  
begin  
        select @dbid = t_dbid
        ,       @objectid = t_objectid 
        from @sql_handle_convert_table where row_id = @cnt; 
        if not exists (select 1 from @object_name where objectId = @objectid and  dbId = @dbid )
        begin
                        set @cmd = ''select ''+convert(nvarchar(10),@dbid)+'',''+convert(nvarchar(100),@objectid)+'',''''''+db_name(@dbid)+'''''',obj.name,obj.type, case when sch.name is null then '''''''' else sch.name end 
                        from [''+db_name(@dbid)+''].sys.objects obj left outer join [''+db_name(@dbid)+''].sys.schemas sch on(obj.schema_id = sch.schema_id) 
                        where obj.object_id = ''+convert(nvarchar(100),@objectid)+ '';''
                insert into @object_name
                exec(@cmd)
    end
        set @cnt = @cnt + 1 ; 
end ; 

insert into @objects  
select t_SPRank
,       sum(t_total_worker_time)
,       sum(t_total_logical_reads)
,       sum(t_total_logical_writes)
,       sum(t_total_logical_IO)
,       sum(t_avg_worker_time) as avg_cpu
,       sum(t_avg_logical_reads)
,       sum(t_avg_logical_writes)
,       sum(t_avg_logical_IO)
,       rank() over(order by sum(t_avg_worker_time) desc)
,       rank() over(order by sum(t_total_worker_time) desc)
,       rank() over(order by sum(t_avg_logical_reads) desc)
,       rank() over(order by sum(t_avg_logical_writes) desc)
,       rank() over(order by sum(t_total_logical_IO) desc) 
from @sql_handle_convert_table 
group by t_SPRank ; 

update @sql_handle_convert_table set t_display_option = ''show_total'' 
where t_SPRank in (select obj_rank from @objects where (total_cpu+0.0)/@grand_total_worker_time < 0.05) ; 

update @sql_handle_convert_table set t_display_option = t_sql_handle_text 
where t_SPRank in (select obj_rank from @objects where total_cpu_rank <= 5) ; 

update @sql_handle_convert_table set t_display_option = ''show_total'' 
where t_SPRank in (select obj_rank from @objects where (total_cpu+0.0)/@grand_total_worker_time < 0.005); 

update @sql_handle_convert_table set t_display_optionIO = ''show_total'' 
where t_SPRank in (select obj_rank from @objects where (total_logical_io+0.0)/@grand_total_IO < 0.05); 

update @sql_handle_convert_table set t_display_optionIO = t_sql_handle_text 
where t_SPRank in (select obj_rank from @objects where logical_io_rank <= 5) ; 

update @sql_handle_convert_table set t_display_optionIO = ''show_total''  
where t_SPRank in (select obj_rank from @objects where (total_logical_io+0.0)/@grand_total_IO < 0.005); 

select  (s.t_SPRank)%2 as l1
,       (dense_rank() over(order by s.t_SPRank,s.row_id))%2 as l2
,       s.*
,       ob.cpu_rank as t_CPURank
,       ob.logical_read_rank as t_logical_ReadRank
,       ob.logical_write_rank as t_logical_WriteRank
,       objname.objectName as t_obj_name
,       objname.objectType  as [t_obj_type]
,       objname.schemaName as schema_name
,       objname.dbName as t_db_name
from @sql_handle_convert_table  s 
join @objects ob on (s.t_SPRank = ob.obj_rank)
join @object_name as objname on (objname.dbId = s.t_dbid and objname.objectId = s.t_objectid )
end try 
begin catch 
select -100 as l1
,       ERROR_NUMBER()  as l2
,       ERROR_SEVERITY() as row_id
,       ERROR_STATE() as t_sql_handle
,       ERROR_MESSAGE() as t_display_option
,       1 as t_display_optionIO,        1 as t_sql_handle_text ,        1 as t_SPRank , 1 as t_dbid ,   1 as t_objectid ,       1 as t_SQLStatement ,   1 as t_execution_count ,        1 as t_plan_generation_num ,    1 as t_last_execution_time ,            1 as t_avg_worker_time ,        1 as t_total_worker_time ,      1 as t_last_worker_time ,       1 as t_min_worker_time ,        1 as t_max_worker_time ,        1 as t_avg_logical_reads ,      1 as t_total_logical_reads ,    1 as t_last_logical_reads ,     1 as t_min_logical_reads ,      1 as t_max_logical_reads ,      1 as t_avg_logical_writes ,     1 as t_total_logical_writes ,   1 as t_last_logical_writes ,    1 as t_min_logical_writes ,     1 as t_max_logical_writes ,     1 as t_avg_logical_IO , 1 as t_total_logical_IO ,       1 as t_last_logical_IO ,        1 as t_min_logical_IO , 1 as t_max_logical_IO ,    1 as t_CPURank,      1 as t_logical_ReadRank,        1 as t_logical_WriteRank,       1 as t_obj_name,        1 as t_obj_type,        1 as schama_name,       1 as t_db_name 
end catch',@params=N''