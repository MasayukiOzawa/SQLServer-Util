SELECT * FROM sys.dm_os_memory_broker_clerks WHERE clerk_name = 'Column store object pool'
SELECT SUM(pages_in_bytes) / POWER(1024,2) FROM sys.dm_os_memory_objects WHERE type LIKE '%COLUMNSTORE%'
SELECT * FROM sys.dm_os_memory_clerks WHERE type LIKE '%COLUMNSTORE%'
