SET NOCOUNT
ON
/*********************************************/
--  データベースファイルの使用状況の確認
/*********************************************/

CREATE TABLE [#TmpTbl]
(
   [Fileid] SMALLINT,
   [FileGroup] SMALLINT,
   [TotalExtents] BIGINT,
   [UsedExtents] BIGINT,
   [Name] nchar(128),
   [FileName] nchar(260)
)

EXEC sp_MSforeachdb '
INSERT INTO 
[#TmpTbl]
EXECUTE 
(''USE [?];DBCC SHOWFILESTATS WITH NO_INFOMSGS'')
'

-- FileGroup 情報の作成
CREATE TABLE #FileGroup
(
   [database_id] int,
   [database_name] sysname,
   [file_id] int,
   [data_space_id] int,
   [filegroup_name] nvarchar(255),
   [type_desc] nvarchar(60)

)

EXEC sp_MSforeachdb '
INSERT INTO
	#FileGroup
SELECT
	m.database_id,
	db_name(m.database_id),
	m.file_id,
	f.data_space_id,
	f.name,
	f.type_desc
FROM 
	sys.master_files m
	LEFT JOIN
	[?].sys.filegroups f
	on
	m.data_space_id = f.data_space_id
WHERE
	m.database_id = DB_ID(''?'')
'

SELECT 
	DB_NAME([sys].[master_files].[database_id]) AS [DB Name], 
	[sys].[master_files].[file_id],
	[sys].[master_files].[data_space_id] AS [FileGroup ID], 
	[#FileGroup].[filegroup_name],
	[#FileGroup].[type_desc],
	([sys].[master_files].[size] * 8192.0) / 1024.0 AS [File Size(KB)], 
	COALESCE([#TmpTbl].[TotalExtents], '') AS [TotalExtents],
	CASE
		WHEN [#TmpTbl].[TotalExtents] IS NULL THEN COALESCE(NULL, '')
		ELSE ([#TmpTbl].[TotalExtents] * 8192 * 8) / 1024
	END AS [TotalExtents (KB)],  
	COALESCE([#TmpTbl].[UsedExtents], '') AS [UsedExtents], 
	CASE
		WHEN [#TmpTbl].[UsedExtents] IS NULL THEN COALESCE(NULL, '')
		ELSE ([#TmpTbl].[UsedExtents] * 8192 * 8) / 1024
	END AS [UsedExtents(KB)], 
	[sys].[master_files].[max_size],  -- -1:制限なし, 0:容量固定, それ以外最大サイズ
	[sys].[master_files].[growth], 
	CASE [is_percent_growth]
		WHEN 0 THEN [growth] * 8.0 
		ELSE [growth]
	END AS [converted_growth],
	[sys].[master_files].[is_percent_growth],
	[sys].[master_files].[name], 
	[sys].[master_files].[physical_name]
FROM
	[sys].[master_files] WITH (NOLOCK)
	LEFT JOIN
	[#TmpTbl] WITH (NOLOCK)
	ON
	[#TmpTbl].[Fileid] = [sys].[master_files].[file_id]
	AND
	[#TmpTbl].[FileGroup] = [sys].[master_files].[data_space_id]
	AND
	[#TmpTbl].[Name] = [sys].[master_files].[name]
	AND
	[#TmpTbl].[FileName] = [sys].[master_files].[physical_name]
	LEFT JOIN
	[#FileGroup] WITH (NOLOCK)
	ON
	[sys].[master_files].[database_id] = [#FileGroup].[database_id]
	AND
	[sys].[master_files].[data_space_id] = [#FileGroup].[data_space_id]
	AND
	[sys].[master_files].[file_id] = [#FileGroup].[file_id]
ORDER BY 
	[sys].[master_files].[database_id] ASC,
	[sys].[master_files].[file_id] ASC, 
	[sys].[master_files].[data_space_id] ASC

DROP TABLE [#TmpTbl]
DROP TABLE [#FileGroup]

/*********************************************/
--  ログファイルの使用状況の確認
/*********************************************/
DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS

/*********************************************/
--  OS ボリュームの確認 (SQL Server 2008 以降)
/*********************************************/
SELECT 
	DB_NAME(f.database_id) db_name,
	type_desc,
	name,
	physical_name,
	state_desc,
	volume_mount_point,
	logical_volume_name,
	file_system_type,
	total_bytes,
	available_bytes
FROM sys.master_files AS f 
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id)
