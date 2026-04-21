SET NOCOUNT ON
GO

/*********************************************/
-- フルテキスト検索のインストール状況と設定
/*********************************************/
SELECT
	GETDATE() AS [date],
	@@SERVERNAME AS server_name,
	SERVERPROPERTY('IsFullTextInstalled') AS IsFullTextInstalled,
	DATABASEPROPERTYEX(DB_NAME(), 'IsFullTextEnabled') AS IsFullTextEnabled,
	SERVERPROPERTY('ProductVersion') AS ProductVersion,
	SERVERPROPERTY('Edition') AS Edition
OPTION (RECOMPILE)
GO


/*********************************************/
-- フルテキスト関連の構成値
/*********************************************/
SELECT
	name,
	value,
	value_in_use
FROM sys.configurations
WHERE name IN (
	'default full-text language',
	'ft crawl bandwidth (min)',
	'ft crawl bandwidth (max)',
	'ft notify bandwidth (min)',
	'ft notify bandwidth (max)',
	'max full-text crawl range',
	'full-text upgrade option',
	'transform noise words'
)
ORDER BY name
OPTION (RECOMPILE)
GO

/*********************************************/
-- SQL Server 2025 以降のフルテキストインデックスのバージョン
/*********************************************/
SELECT 
	* 
FROM 
	sys.database_scoped_configurations
WHERE
	NAME = 'FULLTEXT_INDEX_VERSION'