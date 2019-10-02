exec sp_executesql @stmt=N'begin try  
declare @enable int; 
select top 1 @enable = convert(int,value_in_use) from sys.configurations where name = ''default trace enabled''  
if @enable = 1 
begin 
        declare @d1 datetime; 
        declare @diff int; 
        declare @curr_tracefilename varchar(500);  
        declare @base_tracefilename varchar(500);  
        declare @indx int ; 
        declare @temp_trace table (
                obj_name nvarchar(256)
        ,       obj_id int
        ,       database_name nvarchar(256)
        ,       start_time datetime
        ,       event_class int
        ,       event_subclass int
        ,       object_type int
        ,       server_name nvarchar(256)
        ,       login_name nvarchar(256)
        ,       user_name nvarchar(256)
        ,       application_name nvarchar(256)
        ,       ddl_operation nvarchar(40) 
        );
        
        select @curr_tracefilename = path from sys.traces where is_default = 1 ;  
        set @curr_tracefilename = reverse(@curr_tracefilename) 
        select @indx  = PATINDEX(''%\%'', @curr_tracefilename) 
        set @curr_tracefilename = reverse(@curr_tracefilename) 
        set @base_tracefilename = LEFT( @curr_tracefilename,len(@curr_tracefilename) - @indx) + ''\log.trc''; 
        
        insert into @temp_trace 
        select ObjectName
        ,       ObjectID
        ,       DatabaseName
        ,       StartTime
        ,       EventClass
        ,       EventSubClass
        ,       ObjectType
        ,       ServerName
        ,       LoginName
        ,       NTUserName
        ,       ApplicationName
        ,       ''temp'' 
        from ::fn_trace_gettable( @base_tracefilename, default )  
        where EventClass in (46,47,164) and EventSubclass = 0  and DatabaseID = db_id() ; 

        update @temp_trace set ddl_operation = ''CREATE'' where event_class = 46;
        update @temp_trace set ddl_operation = ''DROP'' where event_class = 47;
        update @temp_trace set ddl_operation = ''ALTER'' where event_class = 164; 

        select @d1 = min(start_time) from @temp_trace 
        set @diff= datediff(hh,@d1,getdate())
        set @diff=@diff/24; 
        
        select  @diff as difference
        ,       @d1 as date
        ,       object_type as obj_type_desc 
        ,       (dense_rank() over (order by obj_name,object_type ) )%2 as l1 
        ,       (dense_rank() over (order by obj_name,object_type,start_time ))%2 as l2
        ,       *
        from @temp_trace where object_type not in (21587) -- don''t bother with auto-statistics as it generates too much noise
        order by start_time desc;
end else 
begin 
        Select top 0 1 as difference,   1 as date, 1 as obj_type_desc,  1 as l1, 1 as l2,       1 as obj_name,  1 as obj_id, 1 as database_name,        1 as start_time, 1 as event_class, 1 as event_subclass, 1 as object_type, 1 as server_name, 1 as login_name, 1 as user_name, 1 as application_name, 1 as ddl_operation  
end  
end try  
begin catch  
select -100 as difference
,       ERROR_NUMBER() as date
,       ERROR_SEVERITY() as obj_type_desc
,       1 as l1, 1 as l2
,       ERROR_STATE() as obj_name
,       1 as obj_id
,       ERROR_MESSAGE() as database_name
,       1 as start_time, 1 as event_class, 1 as event_subclass, 1 as object_type, 1 as server_name, 1 as login_name, 1 as user_name, 1 as application_name, 1 as ddl_operation  
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try  
declare @enable int; 
select top 1 @enable = convert(int,value_in_use) from sys.configurations where name = ''default trace enabled'';  
if @enable = 0 
begin 
        select  (row_number() over (order by create_date desc))%2 as l1
        ,       o.name as object_name
        ,       o.type_desc
        ,       o.create_date
        ,       s.name as schema_name   
        from sys.all_objects o 
        left outer join sys.schemas s  on (o.schema_id = s.schema_id)   
        where create_date >  ( getdate() -7) order by create_date desc
end else 
        select 1 as l1,1 as object_name, 1 as type_desc,1 as  create_date, 1 as schema_name
        order by create_date desc  
end try 
begin catch 
select -100 as l1
,       ERROR_NUMBER()  as object_name
,       ERROR_SEVERITY() as type_desc
,       ERROR_STATE() as create_date
,       ERROR_MESSAGE() as schema_name  
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try  
declare @enable int; 
select top 1 @enable = convert(int,value_in_use) from sys.configurations where name = ''default trace enabled'';  
if @enable = 0 
begin 
        select (row_number() over (order by modify_date desc))%2 as l1
        ,       o.name as object_name
        ,       o.type_desc
        ,       o.modify_date
        ,       s.name as schema_name  
        from sys.all_objects o 
        left outer join sys.schemas s   on (o.schema_id = s.schema_id) 
        where modify_date >  ( getdate() -7)
        order by modify_date desc 
end else 
begin 
        select 1 as l1,1 as object_name,1 as type_desc,1 as modify_date, 1 as schema_name;
end  
end try 
begin catch 
select -100 as l1
,       ERROR_NUMBER()  as object_name
,       ERROR_SEVERITY() as type_desc
,       ERROR_STATE() as modify_date
,       ERROR_MESSAGE() as schema_name  
end catch',@params=N''
go
