use master
go

select name, type, pages_kb, pages_in_use_kb, entries_count, entries_in_use_count
from sys.dm_os_memory_cache_counters 
where type = 'CACHESTORE_COLUMNSTOREOBJECTPOOL'

select name, type, memory_node_id, pages_kb, page_size_in_bytes, virtual_memory_reserved_kb, virtual_memory_committed_kb
,shared_memory_reserved_kb, shared_memory_committed_kb
from sys.dm_os_memory_clerks 
where type = 'CACHESTORE_COLUMNSTOREOBJECTPOOL'
