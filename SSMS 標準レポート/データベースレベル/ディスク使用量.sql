exec sp_executesql @stmt=N'
                begin try
                if (select convert(int,value_in_use) from sys.configurations where name = ''default trace enabled'' ) = 1
                begin
                declare @curr_tracefilename varchar(500) ;
                declare @base_tracefilename varchar(500) ;
                declare @indx int ;

                select @curr_tracefilename = path from sys.traces where is_default = 1 ;
                set @curr_tracefilename = reverse(@curr_tracefilename);
                select @indx  = patindex(''%\%'', @curr_tracefilename) ;
                set @curr_tracefilename = reverse(@curr_tracefilename) ;
                set @base_tracefilename = left( @curr_tracefilename,len(@curr_tracefilename) - @indx) + ''\log.trc'' ;

                select  (dense_rank() over (order by StartTime desc))%2 as l1
                ,       convert(int, EventClass) as EventClass
                ,       DatabaseName
                ,       Filename
                ,       (Duration/1000) as Duration
                ,       StartTime
                ,       EndTime
                ,       (IntegerData*8.0/1024) as ChangeInSize
                from ::fn_trace_gettable( @base_tracefilename, default )
                left outer join sys.databases as d on (d.name = DB_NAME())
                where EventClass >=  92      and EventClass <=  95        and ServerName = @@servername   and DatabaseName = db_name()  and (d.create_date < EndTime)
                order by StartTime desc ;
                end     else
                select -1 as l1, 0 as EventClass, 0 DatabaseName, 0 as Filename, 0 as Duration, 0 as StartTime, 0 as EndTime,0 as ChangeInSize
                end try
                begin catch
                select -100 as l1
                ,       ERROR_NUMBER() as EventClass
                ,       ERROR_SEVERITY() DatabaseName
                ,       ERROR_STATE() as Filename
                ,       ERROR_MESSAGE() as Duration
                ,       1 as StartTime, 1 as EndTime,1 as ChangeInSize
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                declare @filestats_temp_table table(
                file_id int
                ,       file_group_id int
                ,       total_extents int
                ,       used_extents int
                ,       logical_file_name nvarchar(500) collate database_default
                ,       physical_file_name nvarchar(500) collate database_default
                );

                insert into @filestats_temp_table
                exec (''DBCC SHOWFILESTATS'');

                select  (row_number() over (order by t2.name))%2 as l1
                ,		t2.name as [file_group_name]
                ,       t1.logical_file_name
                ,       t1.physical_file_name
                ,       cast(case when (total_extents * 64) < 1024 then (total_extents * 64)
                when (total_extents * 64 / 1024.0) < 1024 then  (total_extents * 64 / 1024.0)
                else (total_extents * 64 / 1048576.0)
                end as decimal(10,2)) as space_reserved
                ,       case when (total_extents * 64) < 1024 then ''KB''
                when (total_extents * 64 / 1024.0) < 1024 then  ''MB''
                else ''GB''
                end as space_reserved_unit
                ,		cast(case when (used_extents * 64) < 1024 then (used_extents * 64)
                when (used_extents * 64 / 1024.0) < 1024 then  (used_extents * 64 / 1024.0)
                else (used_extents * 64 / 1048576.0)
                end as decimal(10,2)) as space_used
                ,		case when (used_extents * 64) < 1024 then ''KB''
                when (used_extents * 64 / 1024.0) < 1024 then  ''MB''
                else ''GB''
                end as space_used_unit
                from    @filestats_temp_table t1
                inner join sys.data_spaces t2 on ( t1.file_group_id = t2.data_space_id );
                end try
                begin catch
                select -100 as l1
                ,       ERROR_NUMBER() as file_group_name
                ,       ERROR_SEVERITY() as logical_file_name
                ,       ERROR_STATE() as physical_file_name
                ,       ERROR_MESSAGE() as space_reserved
                ,       1 as space_reserved_unit, 1 as space_used, 1 as space_used_unit
                end catch ;
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try                
				select 
				(row_number() over (order by ds.name))%2 as l1,
				ds.name as [file_group_name], 
				df.name as [logical_file_name], 
				df.physical_name as [physical_file_name],
				ISNULL(cast(case when (df.size*8) < 1024 then (df.size*8)
								 when (df.size*8/1024.0) < 1024 then (df.size*8/1024.0)
								 else (df.size*8/1048576.0)
						end as decimal(10,2)), 0) as [space_reserved],
						
				(case when df.size is NULL or (df.size*8)< 1024 then ''KB''
  					  when (df.size*8 / 1024.0) < 1024 then  ''MB''
					  else ''GB''
				end) as [space_reserved_unit],

				(select ISNULL(cast(case when sum (cf.file_size_used_in_bytes)/(1024.0) < 1024 then sum (cf.file_size_used_in_bytes)/(1024.0)
							when sum (cf.file_size_used_in_bytes)/(1024.0 * 1024.0) < 1024 then sum (cf.file_size_used_in_bytes)/(1024.0 * 1024.0)
							else sum (cf.file_size_used_in_bytes)/(1024.0 * 1024.0 * 1024.0)
						end as decimal(10,2)), 0) 
						from sys.dm_db_xtp_checkpoint_files cf where cf.container_guid = df.file_guid and cf.internal_storage_slot is not NULL)
						as [space_used],

				(select (case when sum (cf.file_size_used_in_bytes) is NULL or sum (cf.file_size_used_in_bytes)/(1024.0) < 1024 then ''KB''
							when sum (cf.file_size_used_in_bytes)/(1024.0 * 1024.0) < 1024 then ''MB''
							else ''GB''
						end)
						from sys.dm_db_xtp_checkpoint_files cf where cf.container_guid = df.file_guid and cf.internal_storage_slot is not NULL)
						 as [space_used_unit]

				from sys.database_files df inner join sys.data_spaces ds on ( df.data_space_id = ds.data_space_id )
				where ds.type = ''FX''
                end try
                begin catch
                select -100 as l1
                ,       ERROR_NUMBER() as file_group_name
                ,       ERROR_SEVERITY() as logical_file_name
                ,       ERROR_STATE() as physical_file_name
                ,       ERROR_MESSAGE() as space_reserved
                ,       1 as space_reserved_unit, 1 as space_used, 1 as space_used_unit
                end catch ;
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                declare @tran_log_space_usage table(
                database_name sysname
                ,       log_size_mb float
                ,       log_space_used float
                ,       status int
                );

                insert into @tran_log_space_usage
                exec(''DBCC SQLPERF ( LOGSPACE )'') ;

                select 1 as l1
                ,       1 as l2
                ,       log_size_mb as LogSizeMB
                ,       cast( convert(float,log_space_used) as decimal(10,1)) as SpaceUsage
                ,       ''Used'' as UsageType
                from @tran_log_space_usage
                where database_name = DB_NAME()
                UNION
                select 1 as l1
                ,       1 as l2
                ,       log_size_mb
                ,       cast(convert(float,(100-log_space_used)) as decimal(10,1)) as SpaceUsage
                ,       ''Unused'' as UsageType
                from @tran_log_space_usage
                where database_name = DB_NAME()
                ORDER BY UsageType DESC;
                end try
                begin catch
                select -100 as l1
                ,       ERROR_NUMBER() as l2
                ,       ERROR_SEVERITY() as LogSizeMB
                ,       ERROR_STATE() as SpaceUsage
                ,       ERROR_MESSAGE() as UsageType
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                declare @dbsize bigint
                declare @logsize bigint
                declare @database_size_mb float
                declare @unallocated_space_mb float
                declare @reserved_mb float
                declare @data_mb float
                declare @log_size_mb float
                declare @index_mb float
                declare @unused_mb float
                declare @reservedpages bigint
                declare @pages bigint
                declare @usedpages bigint

                select @dbsize = sum(convert(bigint,case when status & 64 = 0 then size else 0 end))
                ,@logsize = sum(convert(bigint,case when status & 64 != 0 then size else 0 end))
                from dbo.sysfiles

                select @reservedpages = sum(a.total_pages)
                ,@usedpages = sum(a.used_pages)
                ,@pages = sum(CASE
                WHEN it.internal_type IN (202,204) THEN 0
                WHEN a.type != 1 THEN a.used_pages
                WHEN p.index_id < 2 THEN a.data_pages
                ELSE 0
                END)
                from sys.partitions p
                join sys.allocation_units a on p.partition_id = a.container_id
                left join sys.internal_tables it on p.object_id = it.object_id

                select @database_size_mb = (convert(dec (19,2),@dbsize) + convert(dec(19,2),@logsize)) * 8192 / 1048576.0
                select @unallocated_space_mb =(case
                when @dbsize >= @reservedpages then (convert (dec (19,2),@dbsize) - convert (dec (19,2),@reservedpages)) * 8192 / 1048576.0
                else 0
                end)

                select  @reserved_mb = @reservedpages * 8192 / 1048576.0
                select  @data_mb = @pages * 8192 / 1048576.0
                select  @log_size_mb = convert(dec(19,2),@logsize) * 8192 / 1048576.0
                select  @index_mb = (@usedpages - @pages) * 8192 / 1048576.0
                select  @unused_mb = (@reservedpages - @usedpages) * 8192 / 1048576.0

                select
                @database_size_mb as ''database_size_mb''
                ,       @reserved_mb as ''reserved_mb''
                ,       @unallocated_space_mb as ''unallocated_space_mb''
                ,       (@reserved_mb + @unallocated_space_mb) as ''data_size''
                ,       @log_size_mb as ''transaction_log_size''
                ,       cast(@unallocated_space_mb*100.0/(@reserved_mb + @unallocated_space_mb) as decimal(10,2))as  ''unallocated''
                ,       cast(@reserved_mb*100/(@reserved_mb + @unallocated_space_mb) as decimal(10,2))as ''reserved''
                ,       cast(@data_mb*100/(@reserved_mb + @unallocated_space_mb) as decimal(10,2))as ''data''
                ,       cast(@index_mb*100/(@reserved_mb + @unallocated_space_mb) as decimal(10,2)) as ''index_1''
                ,       cast(@unused_mb*100/(@reserved_mb + @unallocated_space_mb) as decimal(10,2))as ''unused'';

                end try
                begin catch
                select
                1 as database_size_mb
                ,       ERROR_NUMBER() as reserved_mb
                ,       ERROR_SEVERITY() as unallocated_space_mb
                ,       ERROR_STATE() as data_size
                ,       1 as transaction_log_size
                ,       ERROR_MESSAGE() as unallocated
                ,       -100 as reserved
                ,       1 as data
                ,       1 as index_1
                ,       1 as unused
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                select ISNULL(cast(df.size*8/1024.0 as decimal(10,2)), 0) as [space_reserved_mb],
				(select ISNULL(cast(sum(cf.file_size_used_in_bytes)/(1024.0 * 1024.0) as decimal(10,2)), 0)
						from sys.dm_db_xtp_checkpoint_files cf where cf.container_guid = df.file_guid and cf.internal_storage_slot is not NULL)
						as [space_used_mb]
				from sys.database_files df inner join sys.data_spaces ds on ( df.data_space_id = ds.data_space_id )
				where ds.type = ''FX''
                end try
                begin catch
                select
                       -100 as space_reserved_mb
                ,      ERROR_MESSAGE() as space_used_mb
                end catch
              ',@params=N''
go
exec sp_executesql @stmt=N'
                begin try
                select getdate() as date
                end try
                begin catch
                select null as date
                end catch
              ',@params=N''
go
