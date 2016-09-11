/*********************************************/ 
--  仮想ログファイル情報の取得 (2008 R2 まで) 
-- ～64MB 4 
-- 64MB ～ 1GB 8 
-- 1GB Over 16 
/*********************************************/ 
CREATE TABLE [#TmpVLF_1] 
( 
   [Fileid] INT, 
   [FileSize] INT, 
   [StartOffset] BIGINT, 
   [FSeqNo] INT, 
   [Status] INT, 
   [Parity] INT, 
   [CreateLSN] NUMERIC(25,0) 
) 
 
CREATE TABLE [#TmpVLF_2] 
( 
   [DatabaseName] sysname, 
   [Fileid] INT, 
   [FileSize] INT, 
   [StartOffset] BIGINT, 
   [FSeqNo] INT, 
   [Status] INT, 
   [Parity] INT, 
   [CreateLSN] NUMERIC(25,0) 
) 
DECLARE @vlf_dbname AS sysname 
DECLARE @sqlstmt AS nvarchar(500) 
 
DECLARE VLF_CURSOR CURSOR FAST_FORWARD FAST_FORWARD FOR 
SELECT [name] FROM [sys].[databases] WHERE state =0
 
OPEN VLF_CURSOR 
 
FETCH NEXT FROM VLF_CURSOR 
INTO @vlf_dbname 
 
WHILE @@FETCH_STATUS = 0 
BEGIN 
SET @sqlstmt = N'USE [' + @vlf_dbname + '];DBCC LOGINFO'  
 
TRUNCATE TABLE [#TmpVLF_1] 
 
INSERT INTO 
[#TmpVLF_1] 
EXECUTE 
(@sqlstmt) 
 
INSERT INTO 
[#TmpVLF_2] 
SELECT 
@vlf_dbname,* 
FROM 
[#TmpVLF_1] WITH (NOLOCK) 
 
FETCH NEXT FROM VLF_CURSOR 
INTO @vlf_dbname 
END 
 
CLOSE VLF_CURSOR 
DEALLOCATE VLF_CURSOR 
SELECT GETDATE() AS DATE,* FROM [#TmpVLF_2]  WITH (NOLOCK) ORDER BY [DatabaseName] ASC 
 
DROP TABLE [#TmpVLF_1] 
DROP TABLE [#TmpVLF_2] 

