SET NOCOUNT ON

-- ファイル I/O の取得
DROP TABLE IF EXISTS #T1
DROP TABLE IF EXISTS #T2

SELECT 
	GETDATE() AS counter_date,
	[database_files].[name], 
	[database_files].[type_desc],
	[database_files].[size] * 8.0 AS size_KB,  
	[database_files].[max_size] * 8.0 AS max_size_KB,  
	[database_files].[growth],
	CASE [is_percent_growth]
		WHEN 0 THEN [database_files].[growth] * 8.0 
		ELSE [growth]
	END AS [converted_growth],
	[database_files].[is_percent_growth],
	[fn_virtualfilestats].[NumberReads], 
	[fn_virtualfilestats].[IoStallReadMS], 
	[fn_virtualfilestats].[BytesRead],  
	[fn_virtualfilestats].[NumberWrites],  
	[fn_virtualfilestats].[IoStallWriteMS], 
	[fn_virtualfilestats].[BytesWritten],  
	[fn_virtualfilestats].[BytesOnDisk] 
INTO #T1
FROM 
	fn_virtualfilestats(DB_ID(), NULL) 
	LEFT JOIN
	sys.database_files
	ON
	database_files.file_id  = fn_virtualfilestats.FileId

WAITFOR DELAY '00:00:01'

SELECT 
	GETDATE() AS counter_date,
	[database_files].[name], 
	[database_files].[type_desc],
	[database_files].[size] * 8.0 AS size_KB,  
	[database_files].[max_size] * 8.0 AS max_size_KB,  
	[database_files].[growth],
	CASE [is_percent_growth]
		WHEN 0 THEN [database_files].[growth] * 8.0 
		ELSE [growth]
	END AS [converted_growth],
	[database_files].[is_percent_growth],
	[fn_virtualfilestats].[NumberReads], 
	[fn_virtualfilestats].[IoStallReadMS], 
	[fn_virtualfilestats].[BytesRead],  
	[fn_virtualfilestats].[NumberWrites],  
	[fn_virtualfilestats].[IoStallWriteMS], 
	[fn_virtualfilestats].[BytesWritten],  
	[fn_virtualfilestats].[BytesOnDisk] 
INTO #T2
FROM 
	fn_virtualfilestats(DB_ID(), NULL) 
	LEFT JOIN
	sys.database_files
	ON
	database_files.file_id  = fn_virtualfilestats.FileId

SELECT
	#T2.counter_date,
	#T2.name,
	#T2.NumberReads - #T1.NumberReads AS NumberReads,
	#T2.BytesRead - #T1.BytesRead AS BytesRead,
	#T2.IoStallReadMS - #T1.IoStallReadMS AS IoStallReadMS,
	#T2.NumberWrites - #T1.NumberWrites AS NumberWrites,
	#T2.BytesWritten - #T1.BytesWritten AS BytesWritten,
	#T2.IoStallWriteMS - #T1.IoStallWriteMS AS IoStallWriteMS
FROM
	#T1
	LEFT JOIN
	#T2
	ON
	#T1.name = #T2.name