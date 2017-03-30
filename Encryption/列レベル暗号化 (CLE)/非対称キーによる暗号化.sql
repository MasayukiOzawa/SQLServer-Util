DROP TABLE IF EXISTS T1

IF EXISTS (SELECT * FROM sys.asymmetric_keys WHERE name = 'AsymKey')
	DROP ASYMMETRIC KEY AsymKey
GO

CREATE TABLE T1(
	id int IDENTITY(1, 1),
	ClearText nvarchar(100),
	EncryptData varbinary(max)
) 
GO

-- 非対称キーの作成
CREATE ASYMMETRIC KEY AsymKey
WITH ALGORITHM =RSA_2048  
ENCRYPTION BY PASSWORD = 'P@$$w0rd'
GO

--暗号化関数でデータを暗号化して INSERT
INSERT INTO T1 VALUES ( '平文のデータ', EncryptByAsymKey(AsymKey_ID('AsymKey'), N'暗号化データ') )
GO

-- 暗号化されていることの確認
SELECT * FROM T1

-- 復号化関数で暗号化を解除してデータを取得
SELECT 
	ID, 
	ClearText,
	CONVERT( nvarchar, DecryptByAsymKey(AsymKey_ID('AsymKey'), EncryptData, N'P@$$w0rd'))
FROM T1
GO
