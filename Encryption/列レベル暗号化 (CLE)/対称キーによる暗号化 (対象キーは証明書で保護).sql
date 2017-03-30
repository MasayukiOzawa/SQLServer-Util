DROP TABLE IF EXISTS T1

IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'SymKey')
	DROP SYMMETRIC KEY SymKey
GO

IF EXISTS (SELECT * FROM sys.certificates where name = 'SymKey_Cert')
	DROP CERTIFICATE SymKey_Cert
GO

IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)  
    DROP MASTER KEY
GO  

-- 証明書を作成しているため、データベースにマスターキーの作成が必要
CREATE MASTER KEY ENCRYPTION BY   
PASSWORD = '23987hxJKL95QYV4369#ghf0%lekjg5k3fd117r$$#1946kcj$n44ncjhdlj'  

CREATE CERTIFICATE SymKey_Cert  
   WITH SUBJECT = 'Symmetric Key Encryption Certificate'  
GO  

CREATE TABLE T1(
	id int IDENTITY(1, 1),
	ClearText nvarchar(100),
	EncryptData varbinary(max)
) 
GO

-- 対称キーの作成
-- 対象キーの暗号化は証明書で実施
CREATE SYMMETRIC KEY SymKey
WITH ALGORITHM =AES_256  
ENCRYPTION BY CERTIFICATE SymKey_Cert
GO

-- 対象キーのオープン
OPEN SYMMETRIC KEY SymKey
DECRYPTION BY CERTIFICATE SymKey_Cert

--暗号化関数でデータを暗号化して INSERT
INSERT INTO T1 VALUES ( '平文のデータ', EncryptByKey(Key_GUID('SymKey'), N'暗号化データ') )
GO

-- 暗号化されていることの確認
SELECT * FROM T1


-- 復号化関数で暗号化を解除してデータを取得
SELECT 
	ID, 
	ClearText,
	CONVERT( nvarchar, DecryptByKey(EncryptData))
FROM T1
GO

-- 対象キーのクローズ
CLOSE SYMMETRIC KEY SymKey

-- 以下は他環境にリストアする場合の考慮

/********************************************/
-- 元の環境で実施
-- 暗号化で使用している証明書を、リストア先でインポートできるようにバックアップを取得
BACKUP CERTIFICATE SymKey_Cert
TO FILE= 'C:\temp\SymKey_Cert.cer'
WITH PRIVATE KEY
(
    FILE = 'C:\temp\SymKey_Cert_PrivateKey.pvk',
    ENCRYPTION BY PASSWORD = '$trongP@$$@gain'
)


-- サービスマスターキーのバックアップ 
SELECT * FROM master.sys.symmetric_keys
-- https://social.technet.microsoft.com/wiki/contents/articles/25483.cell-level-encryption-with-always-on-availability-groups.aspx
BACKUP SERVICE MASTER KEY
TO FILE = 'C:\temp\SMK.cer'
ENCRYPTION BY  PASSWORD = '$trongP@$$@gain'
GO

-- CLE を実行しているデータベースで実行
USE TEST
GO
BACKUP MASTER KEY TO FILE='C:\temp\DMK.cer'
ENCRYPTION BY Password = '$trongP@$$@gain'
GO
/********************************************/


/********************************************/
-- リストア先で暗号化に使用した証明書をリストア
-- 強制的に上書きリストアすることで、リストア先のサービスマスターキーで保護してアクセスできるようにしている
USE [TEST]
GO
RESTORE MASTER KEY   
    FROM FILE = 'C:\temp\DMK.cer'   
    DECRYPTION BY PASSWORD = '$trongP@$$@gain' 
    ENCRYPTION BY PASSWORD = '259087M#MyjkFkjhywiyedfgGDFD'
	FORCE 
GO  

-- バックアップ元のサービスマスターキーをリストアすることで、データベースマスターキーを読み取ることも可能
-- (複数の環境から暗号化したデータベースをリストアしている場合、サービスマスターキーをリストアすると、他の DB の暗号化が解除できなくなる)
-- ALTER SERVICE MASTER KEY REGENERATE　-- テスト用にサービスマスターキーを再生成し、マスターキーを変えたい場合
RESTORE SERVICE MASTER KEY
FROM FILE = 'C:\temp\SMK.cer'
DECRYPTION BY PASSWORD = '$trongP@$$@gain'
FORCE
GO
