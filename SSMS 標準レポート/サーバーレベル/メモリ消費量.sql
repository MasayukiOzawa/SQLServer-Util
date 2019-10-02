exec sp_executesql @stmt=N'
                begin try
                declare @enable int;
                select top 1 @enable = convert(int,value_in_use) from sys.configurations where name = ''default trace enabled''
                if @enable = 1 --default trace is enabled
                begin
                declare @curr_tracefilename varchar(500);
                declare @base_tracefilename varchar(500);
                declare @indx int ;
                declare @temp_trace table (
                StartTime datetime
                ,       EventSubClass int
                ,       IntegerData int
                );

                select @curr_tracefilename = path from sys.traces where is_default = 1 ;
                set @curr_tracefilename = reverse(@curr_tracefilename)
                select @indx  = PATINDEX(''%\%'', @curr_tracefilename)
                set @curr_tracefilename = reverse(@curr_tracefilename)
                set @base_tracefilename = LEFT( @curr_tracefilename, len(@curr_tracefilename) - @indx) + ''\log.trc'';

                insert into @temp_trace
                select StartTime
                ,       EventSubClass
                ,       IntegerData
                from ::fn_trace_gettable( @base_tracefilename, default )
                where EventClass = 81;

                update @temp_trace set IntegerData = -IntegerData where EventSubClass = 2;

                select   1 as row_no
                ,       StartTime
                ,       EventSubClass
                ,       IntegerData
                ,       case when IntegerData < 0
                then -IntegerData
                else IntegerData
                end "Absolute"
                from @temp_trace
                where (datediff(dd,StartTime,getdate()) < 7) order by StartTime ;
                end
                else
                begin
                select top 0 1 as row_no, 1 as StartTime , 1 as EventSubClass, 1 as IntegerData, 1 as Absolute
                end
                end try
                begin catch
                select  -100 as row_no
                ,       ERROR_NUMBER()  as StartTime
                ,       ERROR_SEVERITY() as EventSubClass
                ,       ERROR_STATE()  as   IntegerData
                ,       ERROR_MESSAGE() as Absolute
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                select  object_name
                ,       counter_name
                ,       convert(varchar(10),cntr_value) as cntr_value
                from sys.dm_os_performance_counters
                where ( (object_name like ''%Manager%'') and (counter_name = ''Memory Grants Pending'' or counter_name=''Memory Grants Outstanding'' ))
                end try
                begin catch
                select top 0 0 as object_name, 0 as counter_name, 0 as cntr_value
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                select  object_name
                ,       counter_name
                ,       convert(varchar(10) ,cntr_value) as cntr_value
                from sys.dm_os_performance_counters
                where object_name like ''%Manager%'' and (counter_name = ''Page life expectancy'' /*or counter_name = ''Stolen pages''*/ )
                end try
                begin catch
                select top 0 0 as object_name, 0 as counter_name, 0 as cntr_value
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                declare @table1 table(
                objecttype varchar (100) collate database_default
                ,       buffers bigint
                );

                insert @table1
                exec(''dbcc memorystatus with tableresults'')

                select 0 as row_no
                ,       objecttype
                ,       buffers as value
                ,       1 as state,      1 as msg
                from @table1
                where objecttype in (''Stolen'',''Free'',''Cached'',''Dirty'',''Kept'',''I/O'',''Latched'',''Other'' )
                end try
                begin catch
                select -100 as row_no
                ,       ERROR_NUMBER() as objecttype
                ,       ERROR_SEVERITY() as value
                ,       ERROR_STATE() as state
                ,       ERROR_MESSAGE() as msg
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                declare @total_alcted_v_res_awe_s_res bigint
                declare @tab table (
                row_no int identity
                ,       type nvarchar(128) collate database_default
                ,       allocated bigint
                ,       vertual_res bigint
                ,       virtual_com bigint
                ,       awe bigint
                ,       shared_res bigint
                ,       shared_com bigint
                ,       graph_type nvarchar(128)
                ,       grand_total bigint
                );

                select  @total_alcted_v_res_awe_s_res = sum(pages_kb + (CASE WHEN type <> ''MEMORYCLERK_SQLBUFFERPOOL'' THEN virtual_memory_committed_kb ELSE 0 END) + shared_memory_committed_kb)
                from sys.dm_os_memory_clerks

                insert into @tab
                select  type
                ,       sum(pages_kb) as allocated
                ,       sum(virtual_memory_reserved_kb) as vertual_res
                ,       sum(virtual_memory_committed_kb) as virtual_com
                ,       sum(awe_allocated_kb) as awe
                ,       sum(shared_memory_reserved_kb) as shared_res
                ,       sum(shared_memory_committed_kb) as shared_com
                ,       case  when  (((sum(pages_kb + (CASE WHEN type <> ''MEMORYCLERK_SQLBUFFERPOOL'' THEN virtual_memory_committed_kb ELSE 0 END) + shared_memory_committed_kb))/(@total_alcted_v_res_awe_s_res + 0.0)) >= 0.05) OR type = ''MEMORYCLERK_XTP''
                then type
                else ''Other''
                end as graph_type
                ,       (sum(pages_kb + (CASE WHEN type <> ''MEMORYCLERK_SQLBUFFERPOOL'' THEN virtual_memory_committed_kb ELSE 0 END) + shared_memory_committed_kb)) as grand_total
                from sys.dm_os_memory_clerks
                group by type
                order by (sum(pages_kb + (CASE WHEN type <> ''MEMORYCLERK_SQLBUFFERPOOL'' THEN virtual_memory_committed_kb ELSE 0 END) + shared_memory_committed_kb)) desc

                update @tab set graph_type = type where row_no <= 5
                select  * from @tab
                end try
                begin catch
                select -100 as row_no
                ,       ERROR_NUMBER() as type
                ,       ERROR_SEVERITY() as allocated
                ,       ERROR_STATE() as vertual_res
                ,       ERROR_MESSAGE() as awe
                ,       0 as shared_res, 0 as shared_com, 0 as graph_type, 0 as grand_total
                end catch
              ',@params=N''
go
