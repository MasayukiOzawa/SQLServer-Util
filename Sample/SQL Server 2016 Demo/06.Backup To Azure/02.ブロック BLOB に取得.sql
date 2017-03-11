CREATE CREDENTIAL [https://<ストレージアカウント名>.blob.core.windows.net/backup]
WITH IDENTITY='SHARED ACCESS SIGNATURE', -- IDENTITY は固定
SECRET = '<sv= ～の SAS トークン>'

BACKUP DATABASE BackupDemoDB 
TO URL = 'https://<ストレージアカウント名>.blob.core.windows.net/backup/test_01_blockblob.bak',  
   URL = 'https://<ストレージアカウント名>.blob.core.windows.net/backup/test_02_blockblob.bak'
WITH COMPRESSION, STATS = 5, INIT, FORMAT
