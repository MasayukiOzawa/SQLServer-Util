SELECT
    actual_state_desc, 
    current_storage_size_mb, 
    max_storage_size_mb 
FROM
    sys.database_query_store_options
 
SELECT
    OBJECT_NAME(object_id) AS object_name,
    row_count,
    reserved_page_count * 8 / 1024 AS reserved_page_MB,
    used_page_count * 8 / 1024 AS used_page_MB,
    SUM(reserved_page_count * 8 / 1024) OVER() AS total_reserved_MB
FROM
    sys.dm_db_partition_stats 
WHERE
    OBJECT_NAME(object_id) LIKE 'plan[_]%'
    AND OBJECT_SCHEMA_NAME(object_id) = 'sys'
    AND index_id = 1
    AND row_count > 0
ORDER BY
    object_id ASC
    
SELECT * FROM sys.dm_exec_requests 
WHERE command LIKE 'QUERY STORE%'