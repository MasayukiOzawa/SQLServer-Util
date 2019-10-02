exec sp_executesql @stmt=N'begin try 
			select (dense_rank() over (order by t4.name,t3.name))%2 as l1
			,       (dense_rank() over (order by t4.name,t3.name,t2.name))%2 as l2
			,       (dense_rank() over (order by t4.name,t3.name,t2.name,partition_number))%2 as l3
			,		t4.name as [schema_name]
			,       t3.name as table_name
			,       t2.name as index_name
			,		t1.object_id
			,		t1.index_id
			,		t1.partition_number
			,		t1.index_type_desc
			,		t1.index_depth
			,		t1.avg_fragmentation_in_percent
			,		t1.fragment_count
			,		t1.avg_fragment_size_in_pages
			,		t1.page_count
			from sys.dm_db_index_physical_stats(db_id(),NULL,NULL,NULL,''LIMITED'' ) t1
			inner join sys.objects t3 on (t1.object_id = t3.object_id)
			inner join sys.schemas t4 on (t3.schema_id = t4.schema_id)
			inner join sys.indexes t2 on (t1.object_id = t2.object_id and  t1.index_id = t2.index_id )
			where index_type_desc <> ''HEAP'' and index_type_desc <> ''HASH INDEX''
			order by t4.name,t3.name,t2.name,partition_number
			end try
			begin catch
			select -100 as l1
			,       ERROR_NUMBER() as l2
			,       ERROR_SEVERITY() as l3
			,		N'''' as [schema_name]
			,       ERROR_STATE() as table_name
			,       ERROR_MESSAGE()  as index_name
			,		1 as object_id
			,		1 as index_id
			,       1 as partition_number
			,		N'''' as index_type_desc
			,		1 as index_depth
			,		1 as avg_fragmentation_in_percent
			,		1 as fragment_count
			,		1 as avg_fragment_size_in_pages
			,		1 as page_count
			end catch',@params=N''