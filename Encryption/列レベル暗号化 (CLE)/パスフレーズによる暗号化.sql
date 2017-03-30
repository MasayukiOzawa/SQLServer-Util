DROP TABLE IF EXISTS T1

CREATE TABLE T1(
	id int IDENTITY(1, 1),
	ClearText nvarchar(100),
	EncryptData varbinary(max)
) 
GO

--暗号化関数でデータを暗号化して INSERT
INSERT INTO T1 VALUES ( '平文のデータ', EncryptByPassPhrase('P@$$w0rd', N'暗号化データ') )
GO

-- 暗号化されていることの確認
SELECT * FROM T1

-- 復号化関数で暗号化を解除してデータを取得
SELECT 
	ID, 
	ClearText,
	CONVERT( nvarchar, DecryptByPassPhrase( N'P@$$w0rd', EncryptData))
FROM T1
GO
