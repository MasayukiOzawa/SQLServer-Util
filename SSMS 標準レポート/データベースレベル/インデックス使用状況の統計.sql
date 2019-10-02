exec sp_executesql @stmt=N'begin try  
			Select
					(dense_rank() over (order by s.name,t.name))%2 as l1
			,       (dense_rank() over (order by s.name,t.name,i.name))%2 as l2
			,		s.name as [schema_name]
			,       t.name as [table_name]
			,       i.name as [index_name]
			,       i.type_desc
			,       case when iu.object_id is NULL then '''' else convert(varchar(20),iu.object_id) end as object_id
			,       case when iu.index_id is NULL then '''' else convert(varchar(20),iu.index_id) end as index_id
			,       case when iu.user_seeks is NULL then '''' else convert(varchar(20),iu.user_seeks) end as seek_user
			,       case when iu.user_scans is NULL then '''' else convert(varchar(20),iu.user_scans) end as scan_user
			,       case when iu.user_updates is NULL then '''' else convert(varchar(20),iu.user_updates) end as update_user
			,       case when iu.last_user_seek is NULL then '''' else iu.last_user_seek end as time_seek_user
			,       case when iu.last_user_scan is NULL then '''' else iu.last_user_scan end as time_scan_user
			,       case when iu.last_user_lookup is NULL then '''' else iu.last_user_lookup end as time_lookup_user
			,       case when iu.last_user_update is NULL then '''' else iu.last_user_update end as time_update_user
			,       case when iu.system_seeks is NULL then '''' else convert(varchar(20),iu.system_seeks) end as seek_system
			,       case when iu.system_scans is NULL then '''' else convert(varchar(20),iu.system_scans) end scan_system
			,       case when iu.system_updates is NULL then '''' else convert(varchar(20),iu.system_updates) end as update_system
			,       case when iu.last_system_seek is NULL then '''' else iu.last_system_seek end as time_seek_system
			,       case when iu.last_system_scan is NULL then '''' else iu.last_system_scan end as time_scan_system
			,       case when iu.last_system_lookup is NULL then '''' else iu.last_system_lookup end as time_lookup_system
			,       case when iu.last_system_update is NULL then '''' else iu.last_system_update end as time_update_system
			from sys.dm_db_index_usage_stats iu
			inner join sys.indexes i on  ((iu.index_id = i.index_id) and (iu.object_id = i.object_id))
			inner join sys.tables t on ( i.object_id = t.object_id )
			inner join sys.schemas s on (s.schema_id = t.schema_id)
			where iu.database_id = db_id() and i.type <> 0
			order by s.name,t.name,i.name
		end try
		begin catch
			select
					-100 as l1
			,		0 as l2
			,       ERROR_SEVERITY() as table_name
			,       ERROR_STATE() as index_name
			,       ERROR_MESSAGE() as type_desc
			,		ERROR_NUMBER() as object_id
			,		0 as index_id
			,		0 as seek_user
			,		0 as scan_user
			,		0 as update_user
			,		0 as time_seek_user
			,		0 as time_scan_user
			,		0 as time_lookup_user
			,		0 as time_update_user
			,		0 as seek_system
			,		0 as scan_system
			,		0 as update_system
			,		0 as time_seek_system
			,		0 as time_scan_system
			,		0 as time_lookup_system
			,		0 as time_update_system
		end catch',@params=N''
go
exec sp_executesql @stmt=N'begin try  
			Select (dense_rank() over (order by s.name,t.name))%2 as l1
			,       (dense_rank() over (order by s.name,t.name,i.name))%2 as l2
			,		s.name as [schema_name]
			,       t.name as [table_name]
			,       i.name as [index_name]
			,       i.type_desc
			,       case when iop.object_id is NULL then '''' else convert(varchar(20),iop.object_id) end as object_id
			,       case when iop.index_id is NULL then '''' else convert(varchar(20),iop.index_id) end as index_id
			,       case when iop.partition_number is NULL then '''' else convert(varchar(20),iop.partition_number) end as partition_number
			,       case when iop.leaf_insert_count is NULL then '''' else convert(varchar(20),iop.leaf_insert_count) end as leaf_inserts
			,       case when iop.leaf_delete_count is NULL then '''' else convert(varchar(20),iop.leaf_delete_count) end as leaf_deletes
			,       case when iop.leaf_update_count is NULL then '''' else convert(varchar(20),iop.leaf_update_count) end as leaf_updates
			,       case when iop.leaf_ghost_count is NULL then '''' else convert(varchar(20),iop.leaf_ghost_count) end as leaf_ghosts
			,       case when iop.nonleaf_insert_count is NULL then '''' else convert(varchar(20),iop.nonleaf_insert_count) end as nonleaf_inserts
			,       case when iop.nonleaf_delete_count is NULL then '''' else convert(varchar(20),iop.nonleaf_delete_count) end as nonleaf_deletes
			,       case when iop.nonleaf_update_count is NULL then '''' else convert(varchar(20),iop.nonleaf_update_count) end as nonleaf_updates
			,       case when iop.leaf_allocation_count is NULL then '''' else convert(varchar(20),iop.leaf_allocation_count) end leaf_allocations
			,       case when iop.nonleaf_allocation_count is NULL then '''' else convert(varchar(20),iop.nonleaf_allocation_count) end nonleaf_allocations
			,       case when iop.leaf_page_merge_count is NULL then '''' else convert(varchar(20),iop.leaf_page_merge_count) end leaf_page_merges
			,       case when iop.nonleaf_page_merge_count is NULL then '''' else convert(varchar(20),iop.nonleaf_page_merge_count) end nonleaf_page_merges
			,       case when iop.range_scan_count is NULL then '''' else convert(varchar(20),iop.range_scan_count) end as range_scan
			,       case when iop.singleton_lookup_count is NULL then '''' else convert(varchar(20),iop.singleton_lookup_count) end as singleton_lookups
			,       case when iop.forwarded_fetch_count is NULL then '''' else convert(varchar(20),iop.forwarded_fetch_count) end as forwarded_fetches
			,       case when iop.lob_fetch_in_pages is NULL then '''' else convert(varchar(20),iop.lob_fetch_in_pages) end as lob_fetches
			,       case when iop.lob_fetch_in_bytes is NULL then '''' else convert(varchar(20),iop.lob_fetch_in_bytes ) end as lob_bytes_fetched
			,       case when iop.row_lock_count is NULL then '''' else convert(varchar(20),iop.row_lock_count) end as row_locks
			,       case when iop.row_lock_wait_count is NULL then '''' else convert(varchar(20),iop.row_lock_wait_count) end as row_lock_waits
			,       case when iop.row_lock_wait_in_ms is NULL then '''' else convert(varchar(20),iop.row_lock_wait_in_ms) end as row_lock_wait_ms
			,       case when iop.page_lock_count is NULL then '''' else convert(varchar(20),iop.page_lock_count) end as page_locks
			,       case when iop.page_lock_wait_count is NULL then '''' else convert(varchar(20),iop.page_lock_wait_count) end as page_lock_waits
			,       case when iop.page_lock_wait_in_ms is NULL then '''' else convert(varchar(20),iop.page_lock_wait_in_ms) end as page_lock_wait_ms
			,       case when iop.index_lock_promotion_attempt_count is NULL then '''' else convert(varchar(20),iop.index_lock_promotion_attempt_count ) end as index_lock_promotion_attempts
			,       case when iop.index_lock_promotion_count is NULL then '''' else convert(varchar(20),iop.index_lock_promotion_count) end as index_lock_promotions
			,       case when iop.page_latch_wait_count is NULL then '''' else convert(varchar(20),iop.page_latch_wait_count) end as page_latch_waits
			,       case when iop.page_latch_wait_in_ms is NULL then '''' else convert(varchar(20),iop.page_latch_wait_in_ms) end as page_latch_wait_ms
			from sys.dm_db_index_operational_stats(db_id(),null,null,null) iop
			inner join sys.indexes i on ((iop.index_id = i.index_id) and (iop.object_id = i.object_id))
			inner join sys.tables t  on ( i.object_id = t.object_id )
			inner join sys.schemas s on ( t.schema_id = s.schema_id )
			where i.type <> 0
			order by s.name, t.name, i.name, iop.partition_number
		end try
		begin catch
			select
					-100 as l1
			,		0 as l2
			,		N'''' as [schema_name]
			,       ERROR_SEVERITY() as table_name
			,       ERROR_STATE() as index_name
			,       ERROR_MESSAGE() as type_desc
			,		ERROR_NUMBER()  as object_id
			,		0 as index_id
			,		0 as partition_number
			,		0 as leaf_inserts
			,		0 as leaf_deletes
			,		0 as leaf_updates
			,		0 as leaf_ghosts
			,		0 as nonleaf_inserts
			,		0 as nonleaf_deletes
			,		0 as nonleaf_updates
			,		0 as leaf_allocations
			,		0 as leaf_page_merges
			,		0 as nonleaf_page_merges
			,		0 as range_scans
			,		0 as singleton_lookups
			,		0 as forwarded_fetches
			,		0 as lob_fatches
			,		0 as lob_bytes_fetches
			,		0 as slob_fatches
			,		0 as slob_bytes_fetched
			,		0 as row_locks
			,		0 as row_lock_waits
			,		0 as row_lock_wait_ms
			,		0 as page_locks
			,		0 as page_lock_waits
			,		0 as page_lock_wait_ms
			,		0 as index_lock_promotion_attempts
			,		0 as index_lock_promotions
			,		0 as page_latch_waits
			,		0 as page_latch_wait_ms
		end catch',@params=N''
go
