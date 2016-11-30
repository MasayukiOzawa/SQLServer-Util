SET NOCOUNT ON
GO

USE [master]
GO
/*********************************************/
-- ファイル IO の取得
-- sys.dm_io_virtual_file_stats でも可能
/*********************************************/
SELECT
	GETDATE() AS [DateTime],
	DB_NAME([sys].[master_files].[database_id]) AS [DatabaseName], 
	[sys].[master_files].[name], 
	[sys].[master_files].[physical_name], 
	[fn_virtualfilestats].[NumberReads],
	[fn_virtualfilestats].[IoStallReadMS],
	[fn_virtualfilestats].[BytesRead], 
	[fn_virtualfilestats].[NumberWrites], 
	[fn_virtualfilestats].[IoStallWriteMS],
	[fn_virtualfilestats].[BytesWritten], 
	[fn_virtualfilestats].[BytesOnDisk]
FROM
	fn_virtualfilestats(NULL, NULL)
	LEFT JOIN
	[sys].[master_files]  WITH (NOLOCK)
	ON
		fn_virtualfilestats.DbId = [sys].[master_files].[database_id]
		AND
		fn_virtualfilestats.FileId = [sys].[master_files].[file_id]
OPTION (RECOMPILE)



/*********************************************/
-- sys.dm_io_virtual_file_stats
/*********************************************/
SELECT
	GETDATE() AS [DateTime],
	DB_NAME(mf.database_id) AS DatabaseName, 
	mf.name, 
	mf.physical_name, 
	fs.num_of_reads,
	fs.io_stall_read_ms,
	fs.num_of_bytes_read, 
	fs.num_of_writes, 
	fs.io_stall_write_ms,
	fs.num_of_bytes_written, 
	fs.size_on_disk_bytes
FROM
	sys.dm_io_virtual_file_stats(NULL, NULL) fs
	LEFT JOIN
	sys.master_files mf  WITH (NOLOCK)
	ON
	fs.database_id = mf.database_id
	AND
	fs.file_id = mf.file_id
OPTION (RECOMPILE)		


/*********************************************/
-- IO リクエストの待ちの発生状況の取得
/*********************************************/
SELECT * FROM sys.dm_io_pending_io_requests
OPTION (RECOMPILE)


