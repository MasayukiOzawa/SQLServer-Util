-- 初期化用
USE master
GO
IF EXISTS (SELECT * FROM sys.certificates WHERE name = 'MyServerCert')
	DROP CERTIFICATE MyServerCert
GO
IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)  
    DROP MASTER KEY
GO  

-- master データベースにマスターキーを作成
USE master
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<UseStrongPasswordHere>'
-- master データベースに、ユーザーデータベースに作成するデータベースマスターキーの暗号化用証明書を作成
CREATE CERTIFICATE MyServerCert WITH SUBJECT = 'My DEK Certificate';  
GO
-- 作成した証明書のバックアップを取得する (バックアップを取得していない場合、データベース暗号化キーに指定した際に警告が出力される)
BACKUP CERTIFICATE MyServerCert 
TO FILE='C:\temp\MyServerCert.cer'
WITH PRIVATE KEY(
FILE = 'C:\temp\MyServerCertt.pvk',
ENCRYPTION BY PASSWORD = 'P@$$W0rd'
)
GO


-- ユーザーデータベースにデータベース暗号化キーを作成
USE TEST
GO
IF EXISTS (SELECT * FROM sys.dm_database_encryption_keys WHERE database_id = DB_ID())
	DROP DATABASE ENCRYPTION KEY
GO

CREATE DATABASE ENCRYPTION KEY  
WITH ALGORITHM = AES_128  
ENCRYPTION BY SERVER CERTIFICATE MyServerCert
GO  


-- 暗号化に使用している証明書のバックアップが取得されていないとデータエース暗号化キーの作成時に警告が発生する
SELECT name,pvt_key_encryption_type_desc, issuer_name, subject, pvt_key_last_backup_date 
FROM master.sys.certificates


-- 透過的データ暗号化の有効化
ALTER DATABASE TEST SET ENCRYPTION ON

-- 透過的データ暗号化は、エディションによる機能差となるため、使用されているかどうかは DMV から確認できる
SELECT * FROM sys.dm_db_persisted_sku_features

-- 透過的データ暗号化の解除
ALTER DATABASE TEST SET ENCRYPTION OFF
