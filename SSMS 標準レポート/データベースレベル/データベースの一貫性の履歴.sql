exec sp_executesql @stmt=N'begin try 
if (select convert(int,value_in_use) from sys.configurations where name = ''default trace enabled'' ) = 1 
begin 
declare @curr_tracefilename varchar(500); 
declare @base_tracefilename varchar(500); 
declare @indx int ; 
declare @temp_trace table (     
command nvarchar(MAX) collate database_default
,       LoginName varchar(MAX) collate database_default
,       StartTime datetime
,       errors int
,       repaired int
,       time nvarchar(10) collate database_default
); 

select @curr_tracefilename = path from sys.traces where is_default = 1 ; 
set @curr_tracefilename = reverse(@curr_tracefilename); 
select @indx  = PATINDEX(''%\%'', @curr_tracefilename) ;  
set @curr_tracefilename = reverse(@curr_tracefilename); 
set @base_tracefilename = left( @curr_tracefilename,len(@curr_tracefilename) - @indx) + ''\log.trc'' ; 

insert into @temp_trace 
select  substring(convert(nvarchar(MAX),TextData),36, patindex(''%executed%'',TextData)-36) as command
,       LoginName
,       StartTime
,       convert(int,substring(convert(nvarchar(MAX),TextData),patindex(''%found%'',TextData)+6,patindex(''%errors %'',TextData)-patindex(''%found%'',TextData)-6)) as errors
,       convert(int,substring(convert(nvarchar(MAX),TextData),patindex(''%repaired%'',TextData)+9,patindex(''%errors.%'',TextData)-patindex(''%repaired%'',TextData)-9)) repaired
,       substring(convert(nvarchar(MAX),TextData),patindex(''%time:%'',TextData)+6,patindex(''%hours%'',TextData)-patindex(''%time:%'',TextData)-6)+'':''+substring(convert(nvarchar(MAX),TextData),patindex(''%hours%'',TextData)+6,patindex(''%minutes%'',TextData)-patindex(''%hours%'',TextData)-6)+'':''+substring(convert(nvarchar(MAX),TextData),patindex(''%minutes%'',TextData)+8,patindex(''%seconds.%'',TextData)-patindex(''%minutes%'',TextData)-8) as time 
from ::fn_trace_gettable( @base_tracefilename, default ) 
where EventClass = 22 and substring(TextData,36,12) = ''DBCC CHECKDB'' and DatabaseName = @DatabaseName;        

select (row_number() over (order by StartTime desc))%2 as l1
,       command
,       LoginName
,       StartTime
,       errors
,       repaired
,       time  
from @temp_trace 
order by StartTime desc ;       
end     else    
select -1 as l1, 0 as command, 0 as LoginName, 0 as StartTime, 0 as errors, 0 as repaired, 0 as time 
end try 
begin catch 
select -100 as l1
,       ERROR_NUMBER() as command
,       ERROR_SEVERITY() as LoginName
,       ERROR_STATE() as StartTime
,       ERROR_MESSAGE() as errors
,       0 as repaired, 0 as time  
end catch',@params=N'@DatabaseName NVarChar(max)',@DatabaseName=N'TEST'