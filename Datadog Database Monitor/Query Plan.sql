exec sp_executesql N'select cast(query_plan as nvarchar(max)) as query_plan
from sys.dm_exec_query_plan(CONVERT(varbinary(max), @P1, 1))
',N'@P1 nchar(90)',N'0x06000500bc49b914808cc483d102000001000000000000000000000000000000000000000000000000000000'