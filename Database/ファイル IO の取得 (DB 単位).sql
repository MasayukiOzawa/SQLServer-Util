SET NOCOUNT ON
GO

USE [master]
GO
/*********************************************/
-- ファイル IO の取得
-- sys.dm_io_virtual_file_stats でも可能
/*********************************************/
SELECT
	DB_NAME([sys].[master_files].[database_id]) AS [DatabaseName], 
	type_desc,
	SUM([fn_virtualfilestats].[NumberReads]) AS [NumberReads],
	SUM([fn_virtualfilestats].[IoStallReadMS]) AS [IoStallReadMS],
	SUM([fn_virtualfilestats].[BytesRead]) AS [BytesRead], 
	SUM([fn_virtualfilestats].[NumberWrites]) AS [NumberWrites], 
	SUM([fn_virtualfilestats].[IoStallWriteMS]) AS [IoStallWriteMS],
	SUM([fn_virtualfilestats].[BytesWritten]) AS [BytesWritten], 
	SUM([fn_virtualfilestats].[BytesOnDisk]) AS [BytesOnDisk]
FROM
	fn_virtualfilestats(NULL, NULL)
	LEFT JOIN
	[sys].[master_files]  WITH (NOLOCK)
	ON
		fn_virtualfilestats.DbId = [sys].[master_files].[database_id]
		AND
		fn_virtualfilestats.FileId = [sys].[master_files].[file_id]
GROUP BY
	database_id,
	type_desc,
	type
ORDER BY
	database_id,
	type
OPTION (RECOMPILE)

