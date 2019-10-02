exec sp_executesql @stmt=N'begin try 
select
row_number() over (order by a1.used_page_count desc, a1.index_id) as row_number
,		(dense_rank() over (order by a5.name, a2.name))%2 as l1
,		a1.object_id
,		a5.name as [schema]
,       a2.name
,       a1.index_id
,       a3.name as index_name
,       a3.type_desc
,       a1.partition_number
,       a1.used_page_count * 8 as total_used_pages
,       a1.reserved_page_count * 8 as total_reserved_pages
,       a1.row_count
from sys.dm_db_partition_stats a1
inner join sys.all_objects a2  on ( a1.object_id = a2.object_id ) AND a1.object_id NOT IN (SELECT object_id FROM sys.tables WHERE is_memory_optimized = 1)
inner join sys.schemas a5 on (a5.schema_id = a2.schema_id)
left outer join  sys.indexes a3  on ( (a1.object_id = a3.object_id) and (a1.index_id = a3.index_id) )
where (select max(distinct partition_number)
from sys.dm_db_partition_stats a4
where (a4.object_id = a1.object_id)) >= 1
and a2.type <> N''S''
and  a2.type <> N''IT''
order by a5.name asc, a2.name asc, a1.index_id, a1.used_page_count desc, a1.partition_number
end try
begin catch
select
        100 as row_number
,       0 as l1
,       -100 as object_id
,       N'''' as [schema]
,       ERROR_NUMBER() as name
,       ERROR_SEVERITY() as index_id
,       N'''' as index_name
,       ERROR_STATE() as type_desc
,       ERROR_MESSAGE() as partition_number
,       1 as total_used_pages
,       1 as total_reserved_pages
,       1 as rows
end catch',@params=N''