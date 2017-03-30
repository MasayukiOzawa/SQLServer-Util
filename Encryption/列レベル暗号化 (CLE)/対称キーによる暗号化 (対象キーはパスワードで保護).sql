DROP TABLE IF EXISTS T1

IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'SymKey')
	DROP SYMMETRIC KEY SymKey
GO

CREATE TABLE T1(
	id int IDENTITY(1, 1),
	ClearText nvarchar(100),
	EncryptData varbinary(max)
) 
GO

-- 対称キーの作成
-- 暗号化はパスワードで実施しているため、マスターキーの作成は不要
CREATE SYMMETRIC KEY SymKey
WITH ALGORITHM =AES_256  
ENCRYPTION BY PASSWORD = 'P@$$w0rd'
GO

-- 対象キーのオープン
OPEN SYMMETRIC KEY SymKey
DECRYPTION BY PASSWORD = 'P@$$w0rd'

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