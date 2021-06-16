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
