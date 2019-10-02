exec sp_executesql @stmt=N'begin try 
use msdb; 
declare @enable int;
select @enable = convert(int, value_in_use) from sys.configurations where name = ''default trace enabled'' 
if @enable = 1  
begin 
        declare @curr_tracefilename varchar(500);
        declare @base_tracefilename varchar(500);
        declare @status int; 
        declare @indx int;   
        declare @temp_trace table ( 
                Error int
        ,       StartTime datetime
        ,       HostName sysname collate database_default null
        ,       ApplicationName sysname collate database_default  null
        ,       LoginName sysname collate database_default null
        ,       Severity int
        ,       DatabaseName sysname collate database_default null
        ,       TextData nvarchar(max) collate database_default 
        ); 
        
        select @status=status, @curr_tracefilename=path from sys.traces where is_default = 1 ;
        set @curr_tracefilename = reverse(@curr_tracefilename) 
        select @indx  = patindex(''%\%'', @curr_tracefilename)  
        set @curr_tracefilename = reverse(@curr_tracefilename) 
        set @base_tracefilename = left( @curr_tracefilename,len(@curr_tracefilename) - @indx) + ''\log.trc''; 
        
        insert into @temp_trace 
        select Error
        ,       StartTime
        ,       HostName
        ,       ApplicationName
        ,       LoginName
        ,       Severity
        ,       DatabaseName
        ,       TextData  
        from ::fn_trace_gettable( @base_tracefilename, default ) 
        where substring(TextData, 20, 15) like ''%Backup%'' and TextData like ''%Error%'' and ServerName = @@servername ;  
        
        select (row_number() over(order by StartTime desc))%2 as l1
        ,       right( right( TextData, len(TextData) - patindex(''%BACKUP%'',TextData) ) , len(right( TextData, len(TextData) - patindex(''%BACKUP%'',TextData) )) - patindex(''%BACKUP%'',right( TextData, len(TextData) - patindex(''%BACKUP%'',TextData) )) - 10 ) as ErrorMessage
        ,       Error
        ,       Severity
        ,       StartTime
        ,       HostName
        ,       ApplicationName
        ,       LoginName
        ,       DatabaseName  
        from @temp_trace   
        where DatabaseName = ''"  & Parameters!DatabaseName.Value &  "''  
        order by StartTime desc 
end else 
begin 
        select top 0 1 as ErrorMessage, 1 as Error, 1 as Severity, 1 as StartTime,1 as HostName, 1 as ApplicationName,1 as LoginName, 1 as DatabaseName, 1 as l1 
end 
end try 
begin catch 
select ERROR_MESSAGE() as ErrorMessage
,       ERROR_NUMBER() as Error
,       ERROR_SEVERITY() as Severity
,       ERROR_STATE() as StartTime
,       1 as HostName, 1 as ApplicationName,1 as LoginName, 1 as DatabaseName
,       -100 as l1 
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try  
use msdb; 
Select distinct t1.name
,       (dense_rank() over (order by backup_start_date desc,t3.backup_set_id))%2 as l1
,       (dense_rank() over (order by backup_start_date desc,t3.backup_set_id,t6.physical_device_name))%2 as l2
,       t3.user_name
,       t3.backup_set_id
,       t3.name as backup_name
,       t3.description
,       (datediff( ss,  t3.backup_start_date, t3.backup_finish_date))/60.0 as duration
,       t3.backup_start_date
,       t3.backup_finish_date
,       t3.type as [type]
,       case when (t3.backup_size/1024.0) < 1024 then (t3.backup_size/1024.0) 
                when (t3.backup_size/1048576.0) < 1024 then (t3.backup_size/1048576.0) 
        else (t3.backup_size/1048576.0/1024.0) 
        end as backup_size 
,       case when (t3.backup_size/1024.0) < 1024 then ''KB'' 
                when (t3.backup_size/1048576.0) < 1024 then ''MB'' 
        else ''GB'' 
        end as backup_size_unit 
,       t3.first_lsn
,       t3.last_lsn
,       case when t3.differential_base_lsn is null then ''Not Applicable'' 
        else convert( varchar(100),t3.differential_base_lsn) 
        end as [differential_base_lsn]
,       t6.physical_device_name
,       t6.device_type as [device_type]
,       t3.recovery_model  
from sys.databases t1 
inner join backupset t3 on (t3.database_name = t1.name )  
left outer join backupmediaset t5 on ( t3.media_set_id = t5.media_set_id ) 
left outer join backupmediafamily t6 on ( t6.media_set_id = t5.media_set_id ) 
where (t1.name = @DatabaseName) 
order by backup_start_date desc,t3.backup_set_id,t6.physical_device_name;  
end try 
begin catch  
select 1 as user_name, 1 as backup_set_id, 1 as backup_name, 1 as description, 1 as duration, 1 as backup_start_date, 1 as backup_finish_date,1 as type, 1 as backup_size, 1 as backup_size_unit
,       ERROR_SEVERITY() as first_lsn
,       ERROR_STATE() as last_lsn
,       1 as differential_base_lsn
,       ERROR_MESSAGE() as physical_device_name
,       1 as device_type, 1 as recovery_model
,       -100 as l1
,       ERROR_NUMBER() as l2 
end catch',@params=N'@DatabaseName NVarChar(max)',@DatabaseName=N'TEST'
go
exec sp_executesql @stmt=N'begin try 
use msdb; 
select  (dense_rank() over(order by restore_date desc,  t1.restore_history_id))%2 as l1 
,       (dense_rank() over(order by restore_date desc,  t1.restore_history_id,t2.destination_phys_name))%2 as l2 
,       t1.restore_date
,       t1.destination_database_name
,       t1.user_name
,       t1.restore_type as restore_type
,       t1.replace as [replace]
,       t1.recovery as [recovery]
,       t3.name as backup_name
,       t3.description
,       t3.type as [type]
,       t3.backup_finish_date
,       t3.first_lsn
,       t3.last_lsn
,       t3.differential_base_lsn
,       t2.destination_phys_name 
from restorehistory t1 
left outer join restorefile t2 on ( t1.restore_history_id = t2.restore_history_id ) 
left outer join backupset t3 on ( t1.backup_set_id = t3.backup_set_id ) 
where t1.destination_database_name = @DatabaseName
order by restore_date desc,  t1.restore_history_id,t2.destination_phys_name 
end try 
begin catch 
select 1 as  restore_date, 1 as destination_database_name, 1 as user_name, 1 as restore_type, 1 as replace, 1 as recovery, 1 as backup_name, 1 as description , 1 as type , 1 as backup_finish_date 
,       ERROR_NUMBER() as first_lsn
,       ERROR_SEVERITY() as last_lsn
,       ERROR_STATE() as differential_base_lsn
,       ERROR_MESSAGE()  as destination_phys_name
,       -100 as l1 
end catch',@params=N'@DatabaseName NVarChar(max)',@DatabaseName=N'TEST'
go
exec sp_executesql @stmt=N'begin try 
use msdb; 
select (row_number() over (order by t1.type))%2 as l1
,       1 as l2 
,       1 as l3 
,       t1.type as [type]
,       (avg(datediff(ss,backup_start_date, backup_finish_date)))/60.0 as AverageBackupDuration 
from backupset t1 
inner join sys.databases t3 on ( t1.database_name = t3.name ) 
where t3.name = @DatabaseName
group by t1.type 
order by t1.type 
end try 
begin catch 
select ERROR_MESSAGE() as type
,       ERROR_STATE()  as AverageBackupDuration 
,       -100 as l1
,       ERROR_NUMBER() as l2
,       ERROR_SEVERITY() as l3 
end catch',@params=N'@DatabaseName NVarChar(max)',@DatabaseName=N'TEST'
go
