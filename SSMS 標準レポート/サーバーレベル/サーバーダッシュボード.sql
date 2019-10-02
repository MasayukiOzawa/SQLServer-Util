exec sp_executesql @stmt=N'begin try
          select total_worker_time
          ,       case when db_name(dbid ) is null then ''Adhoc Queries'' else  db_name(dbid) end as db_name
          ,       dbid
          ,       1 as state
          ,       1 as msg
          from sys.dm_exec_query_stats s1
          cross apply sys.dm_exec_sql_text(sql_handle) as  s2
          end try
          begin catch
          select -100 as total_worker_time
          ,       ERROR_NUMBER() as db_name
          ,       ERROR_SEVERITY() as dbid
          ,       ERROR_STATE() as state
          ,       ERROR_MESSAGE() as msg
          end catch
        ',@params=N''
go
exec sp_executesql @stmt=N'begin try
select total_logical_reads + total_logical_writes as  total_io
,       case when db_name(dbid) is null then ''Adhoc Queries'' else  db_name(dbid) end as db_name
,       1 as severity
,       1 as state
,       1 as msg  
from sys.dm_exec_query_stats s1 
cross apply sys.dm_exec_sql_text(sql_handle) as  s2
end try
begin catch
select -100 as total_io
,       ERROR_NUMBER() as db_name
,       ERROR_SEVERITY() as severity
,       ERROR_STATE() as state
,       ERROR_MESSAGE() as msg
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try
declare @jobcount bigint;
declare @processorcount int;
use msdb;
select @jobcount = count(distinct job_id) from sysjobs;

use master;
Select  @processorcount = count(*) from sys.dm_os_schedulers where is_online = 1 and scheduler_id < 255

select 0 as error_no
,       convert(nvarchar,login_time) as value_col1
,       0 as error_state
,       convert(sysname, serverproperty(''collation'')) as value_col2
,       1 as pos 
from sys.sysprocesses where spid=1
union
select 0 as error_no
,       @@servername as value_col1
,       0 as error_state
,       case when convert(sysname, serverproperty(''IsClustered'')) = ''0'' then ''No'' else ''Yes'' end as value_col2
,       2 as pos
union 
select 0 as error_no
,       convert(sysname, serverproperty(''ProductVersion'')) as value_col1
,       0 as error_state
,       case when convert(sysname,serverproperty(''IsFullTextInstalled'')) = ''0'' then ''No'' else ''Yes'' end as value_col2
,       3 as pos
union
select 0 as error_no
,       convert(sysname, serverproperty(''edition'')) as value_col1
,       0 as error_state
,       case when convert(sysname,serverproperty(''IsIntegratedSecurityOnly'')) = ''0'' then ''No'' else ''Yes'' end  as value_col2
,       4 as pos
union
select 0 as error_no
,       convert(sysname, serverproperty(''ProcessID'')) as value_col1 
,       0 as error_state
,       case when value = 1 then ''Yes'' else ''No'' end as value_col2
,       5 as pos 
from sys.sysconfigures where config = 1548
union 
select 0 as error_no
,       convert (nvarchar(20),@jobcount) as value_col1
,       0 as error_state
,       convert (nvarchar(20),@processorcount) as value_col2 
,       6 as pos
order by pos
end try
begin catch
select ERROR_NUMBER() as error_no
,       ERROR_SEVERITY() as value_col1
,       ERROR_STATE() as error_state
,       ERROR_MESSAGE() as value_col2 
,       -100 as pos
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try
declare @configurations_option_table table (
        name nvarchar(128)
,       run_value bigint
,       default_value bigint 
);
declare @sp_configure_table table (
        name nvarchar(128)
,       minimum bigint
,       maximum bigint
,       config_value bigint
,       run_value bigint 
);
declare @tracestatus table(
        TraceFlag nvarchar(40)
,       Status tinyint
,       Global tinyint
,       Session tinyint
);

insert into @sp_configure_table 
select name
,       convert(bigint,minimum)
,       convert(bigint,maximum)
,       convert(bigint,value)
,       convert(bigint,value_in_use) 
from sys.configurations  

insert into @configurations_option_table values(''Ad Hoc Distributed Queries'',0,0)
insert into @configurations_option_table values(''affinity I/O mask'',0,0)
insert into @configurations_option_table values(''affinity mask'',0,0)
insert into @configurations_option_table values(''Agent XPs'',0,0)
insert into @configurations_option_table values(''allow updates'',0,0)
insert into @configurations_option_table values(''awe enabled'',0,0)
insert into @configurations_option_table values(''blocked process threshold'',0,0)
insert into @configurations_option_table values(''c2 audit mode'',0,0)
insert into @configurations_option_table values(''clr enabled'',0,0)
insert into @configurations_option_table values(''cost threshold for parallelism'',5,5)
insert into @configurations_option_table values(''cross db ownership chaining'',0,0)
insert into @configurations_option_table values(''cursor threshold'',-1,-1)
insert into @configurations_option_table values(''Database Mail XPs'',0,0)
insert into @configurations_option_table values(''default full-text language'',1033,1033)
insert into @configurations_option_table values(''default language'',0,0)
insert into @configurations_option_table values(''default trace enabled'',1,1)
insert into @configurations_option_table values(''disallow results from triggers'',0,0)
insert into @configurations_option_table values(''fill factor (%)'',0,0)
insert into @configurations_option_table values(''ft crawl bandwidth (max)'',100,100)
insert into @configurations_option_table values(''ft crawl bandwidth (min)'',0,0)
insert into @configurations_option_table values(''ft notify bandwidth (max)'',100,100)
insert into @configurations_option_table values(''ft notify bandwidth (min)'',0,0)
insert into @configurations_option_table values(''index create memory (KB)'',0,0)
insert into @configurations_option_table values(''in-doubt xact resolution'',0,0)
insert into @configurations_option_table values(''lightweight pooling'',0,0)
insert into @configurations_option_table values(''locks'',0,0)
insert into @configurations_option_table values(''max degree of parallelism'',0,0)
insert into @configurations_option_table values(''max full-text crawl range'',4,4)
insert into @configurations_option_table values(''max server memory (MB)'',2147483647,2147483647)
insert into @configurations_option_table values(''max text repl size (B)'',65536,65536)
insert into @configurations_option_table values(''max worker threads'',0,0)
insert into @configurations_option_table values(''media retention'',0,0)
insert into @configurations_option_table values(''min memory per query (KB)'',1024,1024)
insert into @configurations_option_table values(''min server memory (MB)'',0,0)
insert into @configurations_option_table values(''nested triggers'',1,1)
insert into @configurations_option_table values(''network packet size (B)'',4096,4096)
insert into @configurations_option_table values(''Ole Automation Procedures'',0,0)
insert into @configurations_option_table values(''open objects'',0,0)
insert into @configurations_option_table values(''PH timeout (s)'',60,60)
insert into @configurations_option_table values(''precompute rank'',0,0)
insert into @configurations_option_table values(''priority boost'',0,0)
insert into @configurations_option_table values(''query governor cost limit'',0,0)
insert into @configurations_option_table values(''query wait (s)'',-1,-1)
insert into @configurations_option_table values(''recovery interval (min)'',0,0)
insert into @configurations_option_table values(''remote access'',1,1)
insert into @configurations_option_table values(''remote admin connections'',0,0)
insert into @configurations_option_table values(''remote login timeout (s)'',20,20)
insert into @configurations_option_table values(''remote proc trans'',0,0)
insert into @configurations_option_table values(''remote query timeout (s)'',600,600)
insert into @configurations_option_table values(''Replication XPs'',0,0)
insert into @configurations_option_table values(''RPC parameter data validation'',0,0)
insert into @configurations_option_table values(''scan for startup procs'',0,0)
insert into @configurations_option_table values(''server trigger recursion'',1,1)
insert into @configurations_option_table values(''set working set size'',0,0)
insert into @configurations_option_table values(''show advanced options'',0,0)
insert into @configurations_option_table values(''SMO and DMO XPs'',1,1)
insert into @configurations_option_table values(''SQL Mail XPs'',0,0)
insert into @configurations_option_table values(''transform noise words'',0,0)
insert into @configurations_option_table values(''two digit year cutoff'',2049,2049)
insert into @configurations_option_table values(''user connections'',0,0)
insert into @configurations_option_table values(''user options'',0,0)
insert into @configurations_option_table values(''Web Assistant Procedures'',0,0)
insert into @configurations_option_table values(''xp_cmdshell'',0,0)

insert into @tracestatus exec(''dbcc tracestatus'')
update @tracestatus set TraceFlag = ''Traceflag (''+TraceFlag+'')''



select 1 as l1
,       st.name as name 
,       convert(nvarchar(15),st.run_value) as run_value
,       convert(nvarchar(15),ct.default_value) as default_value
,       1 as msg  
from @configurations_option_table ct 
inner join  @sp_configure_table st on (ct.name = st.name  and ct.default_value != st.run_value)
union
select 1 as l1
,       TraceFlag as name
,       convert(nvarchar(15), Status) as run_value
,       ''0'' as default_value
,       1 as msg  
from @tracestatus where Global=1 order by name
end try
begin catch
select -100 as l1
,       ERROR_NUMBER() as name
,       ERROR_SEVERITY() as run_value
,       ERROR_STATE() as default_value
,       ERROR_MESSAGE() as msg
end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try
select 1 as l1
,       convert(nvarchar,count(distinct(s.session_id))) as col
,               0 as severity
,       1 as state, 1 as msg  
from sys.dm_exec_sessions s 
where s.is_user_process = 1 and s.status = ''running''
union
select 2 as l1
,       convert(nvarchar,count(at.transaction_id)) as col
,               0 as severity
,       1 as state, 1 as msg  
from sys.dm_tran_active_transactions at 
where at.transaction_state = 2 or ( at.transaction_type = 4 and at.dtc_state = 1)
union
select 3 as l1
,       convert(nvarchar,count(*)) as col
,               0 as severity
,       1 as state, 1 as msg  
from sys.databases where state = 0
union
select 4 as l1
,       convert(nvarchar,cntr_value) as col
,               0 as severity
,       1 as state, 1 as msg  
from sys.dm_os_performance_counters 
where counter_name like ''%Total Server Memory (KB)%''
UNION
select 5 as l1
,       convert(nvarchar,count(*)) as col
,              0 as severity
,       1 as state
,       1 as msg  
from sys.dm_exec_sessions 
where is_user_process = 1 and status = ''sleeping''
union
select 6 as l1
,       convert(nvarchar,count(distinct(request_owner_id))) as col
,               0 as severity
,       1 as state
,       1 as msg  
from sys.dm_tran_locks 
where request_status = ''WAIT'' 
union
select 7 as l1
,       convert(nvarchar,count(distinct s.login_name)) as col
,               0 as severity   
,       1 as state, 1 as msg  
from sys.dm_exec_sessions s
where s.is_user_process = 1
union
select 8 as l1
,       convert(nvarchar,count(id)) as col
,               0 as severity
,       1 as state, 1 as msg  
from sys.traces where status = 1
end try
begin catch
select -100 as l1
,       ERROR_NUMBER()  as col
,       ERROR_SEVERITY() as severity
,       ERROR_STATE() as state
,       ERROR_MESSAGE() as msg
end catch',@params=N''
go
