IF DB_ID('DemoDB') IS NULL
	CREATE DATABASE DemoDB
GO

USE DemoDB
GO

IF OBJECT_ID('AlwaysEncrypted') IS NOT NULL
	DROP TABLE AlwaysEncrypted

IF EXISTS(SELECT * FROM sys.column_encryption_keys WHERE name = 'CEK')
	DROP COLUMN ENCRYPTION KEY [CEK] 

IF EXISTS(SELECT * FROM sys.column_master_keys WHERE name = 'CMK')
	DROP COLUMN MASTER KEY [CMK]

