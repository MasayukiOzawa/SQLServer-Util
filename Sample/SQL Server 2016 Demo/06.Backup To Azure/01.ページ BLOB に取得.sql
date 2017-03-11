IF DB_ID('BackupDemoDB') IS NULL
	CREATE DATABASE BackupDemoDB
GO


CREATE CREDENTIAL [AzureStorageAccount] 
WITH IDENTITY = '<ストレージアカウント名>',
SECRET = '<ストレージアカウントキー>'
GO

BACKUP DATABASE BackupDemoDB 
TO URL = 'https://<ストレージアカウント名>.blob.core.windows.net/backup/BackupDemoDB_PAGEBLOB.bak'
WITH CREDENTIAL = 'AzureStorageAccount' ,COMPRESSION, STATS = 5, INIT ,FORMAT
