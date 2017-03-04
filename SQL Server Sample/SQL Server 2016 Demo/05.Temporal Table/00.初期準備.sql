IF DB_ID('DemoDB') IS NULL
	CREATE DATABASE DemoDB
GO

USE DemoDB
GO

-- テスト用テーブルの作成
IF OBJECT_ID('TemporalTable') IS NOT NULL
BEGIN
    ALTER TABLE TemporalTable SET (SYSTEM_VERSIONING = OFF)
	DROP TABLE TemporalTable
END
GO

-- テスト用テーブルの作成
IF OBJECT_ID('TemporalTableHistory') IS NOT NULL
	DROP TABLE TemporalTableHistory
GO

-- 履歴用テーブルの作成
CREATE TABLE TemporalTableHistory(
Col1 int NOT NULL,
Col2 uniqueidentifier,
Col3 uniqueidentifier,
Col4 nvarchar(10),
SysStartTime datetime2 NOT NULL, 
SysEndTime datetime2 NOT NULL
)
GO

-- ベーステーブルの作成
CREATE TABLE TemporalTable(
Col1 int IDENTITY PRIMARY KEY CLUSTERED,
Col2 uniqueidentifier,
Col3 uniqueidentifier,
Col4 nvarchar(10),
SysStartTime datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL , 
SysEndTime datetime2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL ,
PERIOD FOR SYSTEM_TIME (SysStartTime,SysEndTime) 
) 
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.TemporalTableHistory))
GO
