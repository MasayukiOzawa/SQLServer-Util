CREATE CREDENTIAL [https://<ストレージアカウント名>.blob.core.windows.net/managed-backup]
WITH IDENTITY='SHARED ACCESS SIGNATURE', -- IDENTITY は固定
SECRET = '<sv= ～の SAS トークン>'

Use msdb
GO
EXEC msdb.managed_backup.sp_backup_config_basic 
 @enable_backup = 1, 
 @database_name = 'BackupDemoDB',
 @container_url = 'https://<ストレージアカウント名>.blob.core.windows.net/managed-backup', 
 @retention_days = 30
GO


USE msdb
GO
EXEC managed_backup.sp_backup_config_schedule 
     @database_name =  'BackupDemoDB'
    ,@scheduling_option = 'Custom'
    ,@full_backup_freq_type = 'Weekly'
    ,@days_of_week = 'Monday'
    ,@backup_begin_time =  '17:30'
    ,@backup_duration = '02:00'
    ,@log_backup_freq = '00:05'
GO

EXEC managed_backup.sp_backup_on_demand @database_name = 'BackupDemoDB', @type= 'Database'
EXEC managed_backup.sp_backup_on_demand @database_name = 'BackupDemoDB', @type= 'Log'

Use msdb
GO
EXEC msdb.managed_backup.sp_backup_config_basic 
 @enable_backup = 0, 
 @database_name = BackupDemoDB
GO
