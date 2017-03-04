-- CTP 2.4 までは、照合順序は Latin1_General_100_CI_AS_KS_WS / SQL_Latin1_General_CP1_CI_AS でインストールをしておく
IF DB_ID('DemoDB') IS NULL
	CREATE DATABASE DemoDB
GO
DBCC TRACEON(4631,-1)

USE DemoDB
GO

sp_configure 'hadoop connectivity', 4;
reconfigure

-- SQL Server / SQL Server PolyBase Engine のサービスを再起動

IF EXISTS(SELECT 1 FROM sys.external_tables WHERE name = 'AzureBlob')
BEGIN
	DROP EXTERNAL TABLE AzureBlob
END

IF EXISTS(SELECT 1 FROM sys.external_file_formats WHERE name = 'CSV')
BEGIN
	DROP EXTERNAL FILE FORMAT CSV 
END

IF EXISTS(SELECT 1 FROM sys.external_data_sources WHERE name = 'AzureData')
BEGIN
	DROP EXTERNAL DATA SOURCE AzureData
END


IF EXISTS (SELECT 1 FROM sys.database_credentials WHERE name = 'AzureBlob')
BEGIN
	DROP DATABASE SCOPED CREDENTIAL AzureBlob
END

IF EXISTS(SELECT 1 FROM sys.key_encryptions)
BEGIN
	DROP MASTER KEY
END


IF OBJECT_ID('BlobTmp') IS NOT NULL
BEGIN
	DROP TABLE BlobTmp
END
