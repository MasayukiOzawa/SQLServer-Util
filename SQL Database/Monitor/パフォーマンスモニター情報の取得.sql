/*********************************************/
-- 論理データへのアクセス方法
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Access Methods%' 
AND counter_name IN ('Full Scans/sec', 'Table Lock Escalations/sec','Range Scans/sec' ,'Index Searches/sec')
WAITFOR DELAY '00:00:01'
GO 2

/*********************************************/
-- バッチ実行統計
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Batch Resp Statistics%' 
GO

/*********************************************/
-- メモリ使用状況
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Buffer Manager%' 
AND counter_name IN ('Buffer cache hit ratio', 'Buffer cache hit ratio base', 'Database pages', 'Target pages',  'Page life expectancy')
GO

SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Buffer Manager%' 
AND counter_name IN ('Page lookups/sec', 'Free list stalls/sec', 'Readahead pages/sec', 'Page reads/sec', 'Page writes/sec', 'Checkpoint pages/sec')
GO 2


/*********************************************/
-- データベース使用状況
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Databases%' 
AND counter_name IN ('Data File(s) Size (KB)', 'Log File(s) Size (KB)', 'Log File(s) Used Size (KB)', 'Percent Log Used')
AND instance_name NOT IN('msdb', 'model_masterdb', 'mode_userdb', 'model', 'mssqlsystemresource', '_Total', 'master')
GO


/*********************************************/
-- サーバー全体の利用状況
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%General Statistics%' 
AND counter_name IN ('Logins/sec', 'Logouts/sec')
WAITFOR DELAY '00:00:01'
GO 2

SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%General Statistics%' 
AND counter_name IN ('User Connections', 'Transactions', 'Processes blocked')


/*********************************************/
-- ロック発生状況
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Locks%' 
AND cntr_type = 272696576
WAITFOR DELAY '00:00:01'
GO 2


/*********************************************/
-- 全体的なサーバー メモリの使用状況
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Memory Manager%' 
GO

/*********************************************/
-- プランキャッシュの情報
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Plan Cache%' 
AND cntr_type = 65792
ORDER BY counter_name 

SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Plan Cache%' 
AND cntr_type <> 65792
GO


/*********************************************/
-- バッチ実行/コンパイル発生状況
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%SQL Statistics%' 
WAITFOR DELAY '00:00:01'
GO 2

/*********************************************/
-- ラッチ待ち発生状況
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Latches%' 
AND cntr_type = 272696576
WAITFOR DELAY '00:00:01'
GO 2


/*********************************************/
-- 待ち事象発生状況
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Wait Statistics%' 
GO

/*********************************************/
-- DB の複製
/*********************************************/
SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Availability Replica%' 
WAITFOR DELAY '00:00:01'
GO 2

SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Database Replica%' 
AND cntr_type = 272696576
AND instance_name <> '_Total'
WAITFOR DELAY '00:00:01'
GO 2

SELECT * FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%Database Replica%' 
AND cntr_type <> 272696576
AND instance_name <> '_Total'


/*********************************************/
-- Azure BLOB へのアクセス状況
/*********************************************/
SELECT *,RTRIM(counter_name) FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%HTTP Storage%' 
AND cntr_type = 272696576
AND instance_name <> '_Total'
WAITFOR DELAY '00:00:01'
GO 2


SELECT *,RTRIM(counter_name) FROM sys.dm_os_performance_counters 
WHERE object_name LIKE '%HTTP Storage%' 
AND cntr_type <> 272696576
AND instance_name <> '_Total'
