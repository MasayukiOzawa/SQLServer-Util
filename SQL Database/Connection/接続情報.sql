-- https://azure.microsoft.com/ja-jp/documentation/articles/sql-database-connectivity-issues/

SELECT * FROM sys.database_connection_stats
WHERE start_time BETWEEN DATEADD(dd, -1, GETDATE()) AND  GETDATE()


SELECT * FROM sys.event_log
WHERE start_time BETWEEN DATEADD(dd, -1, GETDATE()) AND  GETDATE()
