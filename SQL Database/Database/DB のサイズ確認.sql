-- 動的管理ビューを使用した Azure SQL Database の監視
-- https://docs.microsoft.com/ja-jp/azure/sql-database/sql-database-monitoring-with-dmvs
SELECT SUM(reserved_page_count)*8.0/1024
FROM sys.dm_db_partition_stats;
GO
