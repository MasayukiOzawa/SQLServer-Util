-- CDC 有効化状態の確認
SELECT name, is_cdc_enabled FROM sys.databases
GO

-- CDC の有効化
EXEC sys.sp_cdc_enable_db
GO 

-- CDC のオブジェクトの確認
SELECT s.name,s.schema_id,o.name,o.type_desc
FROM sys.schemas AS s
    INNER JOIN sys.all_objects AS o
        ON o.schema_id = s.schema_id
WHERE s.name = 'cdc'
ORDER BY o.type_desc ASC, o.name ASC


-- CDC テーブルの情報
SELECT * FROM cdc.change_tables
SELECT * FROM cdc.lsn_time_mapping
SELECT * FROM cdc.cdc_jobs



-- CDC の無効化 (対象テーブルの設定)
EXEC sys.sp_cdc_disable_table  
@source_schema = N'dbo',  
@source_name   = N'orders',  
@capture_instance = N'dbo_orders'  
GO

-- CDC の有効化 (対象テーブルの設定)
EXEC sys.sp_cdc_enable_table  
@source_schema = N'dbo',  
@source_name   = N'orders',  
@role_name     = NULL ,
@supports_net_changes = 1  


-- CDC のジョブの設定
SELECT * FROM cdc.cdc_jobs

-- ジョブの変更 (SQL DB の場合、sp_cdc_stop_job / sp_cdc_start_job の明示的な再起動は不要)
EXEC sys.sp_cdc_change_job @job_type = 'cleanup', @retention='30'


-- 件数の取得

SELECT 
	OBJECT_NAME(ct.object_id) AS object_name, 
	OBJECT_NAME(ct.source_object_id) AS source_object_name,
	ct.capture_instance,
	ct.start_lsn, ct.end_lsn, ct.supports_net_changes,
	ct.create_date,
	row_count, used_page_count, reserved_page_count
FROM 
	cdc.change_tables AS ct
	LEFT JOIN sys.dm_db_partition_stats AS ps
		ON ps.object_id = ct.object_id AND ps.index_id <= 1
GO


SELECT OBJECT_NAME(object_id) AS name, row_count, used_page_count, reserved_page_count
FROM sys.dm_db_partition_stats 
WHERE (object_id IN (OBJECT_ID('cdc.lsn_time_mapping')) OR OBJECT_NAME(object_id) LIKE '%[_]CT')
AND index_id = 1
ORDER BY OBJECT_SCHEMA_NAME(object_id),  OBJECT_NAME(object_id)  ASC
GO



SELECT * FROM sys.dm_cdc_log_scan_sessions
SELECT * FROM sys.dm_cdc_errors

SELECT TOP 10  * FROM cdc.lsn_time_mapping
SELECT * FROM msdb.dbo.cdc_jobs
SELECT * FROM msdb.dbo.cdc_jobs_view

-- クリーンアップの設定変更
EXEC sys.sp_cdc_change_job @job_type = 'cleanup', @retention = 10

SELECT * FROM msdb.dbo.cdc_jobs WHERE job_type = 'cleanup'

