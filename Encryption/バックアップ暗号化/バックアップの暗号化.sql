-- バックアップ暗号化の証明書は master データベース上に存在している必要がある
USE master  
GO  
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<master key p@$$w0rd>';  
GO  
CREATE CERTIFICATE MyTestDBBackupEncryptCert  
   WITH SUBJECT = 'MyTestDB Backup Encryption Certificate';  
GO
  
BACKUP DATABASE [TEST] TO  
DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLENTERPRISE\MSSQL\Backup\TEST.bak' 
WITH FORMAT, INIT,  NAME = N'TEST-完全 データベース バックアップ', SKIP, NOREWIND, NOUNLOAD, 
ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = [MyTestDBBackupEncryptCert]),  STATS = 10
GO

-- 暗号化に使用している証明書のバックアップが取得されていないとバックアップ時に警告が発生する
SELECT name,pvt_key_encryption_type_desc, issuer_name, subject, pvt_key_last_backup_date 
FROM sys.certificates

BACKUP CERTIFICATE MyTestDBBackupEncryptCert 
TO FILE='C:\temp\MyTestDBBackupEncryptCert.cer'
WITH PRIVATE KEY(
FILE = 'C:\temp\MyTestDBBackupEncryptCert.pvk',
ENCRYPTION BY PASSWORD = 'P@$$W0rd'
)
GO

-- 暗号化に使用した証明書のインポート
DROP CERTIFICATE MyTestDBBackupEncryptCert -- テスト用に証明書を削除
GO

-- 証明書拇印で判断しているため、インポート時の名称は異なるものでも問題ない
CREATE CERTIFICATE MyTestDBBackupEncryptCert_2 
FROM FILE = 'C:\temp\MyTestDBBackupEncryptCert.cer'
WITH PRIVATE KEY( 
FILE = 'C:\temp\MyTestDBBackupEncryptCert.pvk',
DECRYPTION BY PASSWORD = 'P@$$W0rd'
)

-- 暗号化に使用した証明書と同一の拇印の証明書を使用して暗号化が解除されリストアが行われる
USE [master]
GO
ALTER DATABASE [TEST] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

RESTORE DATABASE [TEST] 
FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLENTERPRISE\MSSQL\Backup\TEST.bak' 
WITH  FILE = 1,  NOUNLOAD,  REPLACE,  STATS = 5
GO

-- EncryptorThumbprint でバックアップの暗号化有無が判断できる
RESTORE HEADERONLY   
FROM DISK =  N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLENTERPRISE\MSSQL\Backup\TEST.bak' 
WITH NOUNLOAD
GO