--  ERRORLOG の出力状況の確認 (最大 128 ファイルまで生成される)
DROP TABLE IF EXISTS #enumerrorlogs 
CREATE TABLE #enumerrorlogs ([Archvie #] int, [Date] datetime, [Lig File Size (Byte)] bigint)
INSERT INTO #enumerrorlogs EXEC  sp_enumerrorlogs
SELECT * FROM #enumerrorlogs ORDER BY [Archvie #]

-- ERRoRLOG の内容の確認
EXEC sp_readerrorlog @p1 = 0 -- 最新の ERRORLOG を確認
-- MI 向け Read ErrorLog
-- https://blogs.msdn.microsoft.com/sqlcat/2018/05/04/azure-sql-db-managed-instance-sp_readmierrorlog/
