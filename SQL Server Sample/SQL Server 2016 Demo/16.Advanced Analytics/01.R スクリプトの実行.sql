-- インスタンスインストール時にAdvanced Analytics Extensions をインストール
-- RRO-3.2.2-for-RRE-7.5.0-Windows.exe のインストール
-- Revolution-R-Enterprise-Node-SQL-7.5.0-Windows.exe のインストール

-- R スクリプト実行の有効化
EXEC sp_configure 'external scripts enabled', 1
RECONFIGURE
GO

-- "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\R_SERVICES\library\RevoScaleR\rxLibs\x64\RegisterRExt.exe" /install
-- SQL Server の再起動

USE [DemoDB]
GO

DROP TABLE IF EXISTS MyData 

 CREATE TABLE MyData ([Col1] int not null) ON [PRIMARY]
 INSERT INTO MyData   VALUES (1);
 INSERT INTO MyData   Values (10);
 INSERT INTO MyData   Values (100) ;
GO

execute sp_execute_external_script
  @language = N'R'
, @script = N' SQLOut <- SQLIn;'
, @input_data_1 = N' SELECT 12 as Col;'
, @input_data_1_name  = N'SQLIn'
, @output_data_1_name =  N'SQLOut'
WITH RESULT SETS (([NewColName] int NOT NULL));
