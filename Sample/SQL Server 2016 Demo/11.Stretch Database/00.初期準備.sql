IF DB_ID('DemoDB') IS NULL
	CREATE DATABASE DemoDB
GO


USE DemoDB
GO

-- Stretch Database の有効化
EXEC sp_configure 'remote data archive' , '1'
RECONFIGURE
GO

-- デモ用に一時無効化
ALTER DATABASE DemoDB SET REMOTE_DATA_ARCHIVE = OFF


-- DBCC TRACEON (4631, -1)

-- SQL Database への資格情報の追加
IF EXISTS (SELECT * FROM sys.credentials WHERE name = '<サーバー名>.database.windows.net')
	/*
	CTP 2.3 まで
	DROP CREDENTIAL [<サーバー名>.database.windows.net]
	CREATE CREDENTIAL [<サーバー名>.database.windows.net] WITH IDENTITY='ログイン', SECRET='パスワード'
	*/

	-- CTP 2.4 以降 (CTP 3.0 では、トレースフラグの有効化は不要)
	-- DBCC TRACEON (4631, -1)
	
	CREATE MASTER KEY ENCRYPTION BY PASSWORD='<パスワード>';

	DROP DATABASE SCOPED CREDENTIAL [<サーバー名>.database.windows.net]
	CREATE DATABASE SCOPED CREDENTIAL [<サーバー名>.database.windows.net] WITH IDENTITY='ログイン', SECRET='パスワード'
GO

IF OBJECT_ID('StretchTable') IS NOT NULL
	DROP TABLE StretchTable
GO
CREATE TABLE StretchTable 
(
Col1 int IDENTITY(1,1)  PRIMARY KEY,
Col2 uniqueidentifier
)
