SET NOCOUNT ON
GO
use [master]
GO

/*********************************************/
-- サーバーの設定情報の取得
/*********************************************/
sp_configure
GO

sp_configure 'show advanced options', 1
GO
RECONFIGURE
GO

sp_configure
GO

SELECT * FROM sys.configurations ORDER BY name
OPTION (RECOMPILE)
GO


/*********************************************/
-- サーバープロパティの取得
/*********************************************/
SELECT
	GETDATE() AS DATE,
	SERVERPROPERTY('BuildClrVersion') AS [BuildClrVersion],
	SERVERPROPERTY('Collation') AS [Collation],
	SERVERPROPERTY('CollationID') AS [CollationID],
	SERVERPROPERTY('ComparisonStyle') AS [ComparisonStyle],
	SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS],
	SERVERPROPERTY('Edition') AS [Edition],
	SERVERPROPERTY('EditionID') AS [EditionID],
	SERVERPROPERTY('EngineEdition') AS [EngineEdition],
	SERVERPROPERTY('HadrManagerStatus') AS [HadrManagerStatus], -- 2012 or later
	SERVERPROPERTY('InstanceDefaultDataPath') AS [InstanceDefaultDataPath],
	SERVERPROPERTY('InstanceDefaultLogPath') AS [InstanceDefaultLogPath],
	SERVERPROPERTY('InstanceName') AS [InstanceName],
	SERVERPROPERTY('IsClustered') AS [IsClustered],
	SERVERPROPERTY('IsHadrEnabled') AS [IsHadrEnabled],
	SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled],
	SERVERPROPERTY('IsAdvancedAnalyticsInstalled') AS [IsAdvancedAnalyticsInstalled],
	SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled],
	SERVERPROPERTY('IsHadrEnabled') AS [IsHadrEnabled],
	SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly],
	SERVERPROPERTY('IsLocalDB') AS [IsLocalDB],
	SERVERPROPERTY('IsPolybaseInstalled') AS [IsPolybaseInstalled],
	SERVERPROPERTY('IsSingleUser') AS [IsSingleUser],
	SERVERPROPERTY('IsXTPSupported') AS [IsXTPSupported],
	SERVERPROPERTY('LCID') AS [LCID],
	SERVERPROPERTY('LicenseType') AS [LicenseType],
	SERVERPROPERTY('MachineName') AS [MachineName],
	SERVERPROPERTY('NumLicenses') AS [NumLicenses],
	SERVERPROPERTY('ProcessID') AS [ProcessID],
	SERVERPROPERTY('ProductBuild') AS [ProductBuild],
	SERVERPROPERTY('ProductBuildType') AS [ProductBuildType],
	SERVERPROPERTY('ProductLevel') AS [ProductLevel],
	SERVERPROPERTY('ProductMajorVersion') AS [ProductMajorVersion],
	SERVERPROPERTY('ProductMinorVersion') AS [ProductMinorVersion],
	SERVERPROPERTY('ProductUpdateLevel') AS [ProductUpdateLevel],
	SERVERPROPERTY('ProductUpdateReference') AS [ProductUpdateReference],
	SERVERPROPERTY('ProductVersion') AS [ProductVersion],
	SERVERPROPERTY('ResourceLastUpdateDateTime') AS [ResourceLastUpdateDateTime],
	SERVERPROPERTY('ResourceVersion') AS [ResourceVersion],
	SERVERPROPERTY('ServerName') AS [ServerName],
	SERVERPROPERTY('SqlCharSet') AS [SqlCharSet],
	SERVERPROPERTY('SqlCharSetName') AS [SqlCharSetName],
	SERVERPROPERTY('SqlSortOrder') AS [SqlSortOrder],
	SERVERPROPERTY('SqlSortOrderName') AS [SqlSortOrderName],
	SERVERPROPERTY('FilestreamShareName') AS [FilestreamShareName],
	SERVERPROPERTY('FilestreamConfiguredLevel') AS [FilestreamConfiguredLevel],
	SERVERPROPERTY('FilestreamEffectiveLevel') AS [FilestreamEffectiveLevel]
OPTION (RECOMPILE)
GO

/*********************************************/
-- OS の情報
/*********************************************/
-- Windows OS の情報
SELECT * FROM sys.dm_os_windows_info
OPTION (RECOMPILE)

-- SQL Server 2017 以降の Linux 対応
SELECT * FROM  sys.dm_os_host_info
OPTION (RECOMPILE)
GO


/*********************************************/
-- リソース情報
-- OS のリソース情報の Memory Model から LPM の情報を取得可能
/*********************************************/
-- OS のリソース情報
SELECT GETDATE() AS DATE,* FROM sys.dm_os_sys_info
OPTION (RECOMPILE)

-- OS のメモリ情報
SELECT GETDATE() AS DATE, * FROM sys.dm_os_sys_memory
OPTION (RECOMPILE)

-- プロセスのメモリ情報
SELECT GETDATE() AS DATE, * FROM sys.dm_os_process_memory 
OPTION (RECOMPILE)
GO

/*********************************************/
-- NUMA 情報
/*********************************************/

-- NUMA ノード スケジューラー情報
SELECT GETDATE() AS DATE, * FROM sys.dm_os_nodes
OPTION (RECOMPILE)

-- NUMA ノード メモリ情報
SELECT GETDATE() AS DATE, * FROM sys.dm_os_memory_nodes
OPTION (RECOMPILE)
GO

/*********************************************/
-- サービス情報
-- ファイルの瞬時初期化の設定についても取得可能
/*********************************************/
SELECT GETDATE() AS DATE, * FROM sys.dm_server_services
OPTION (RECOMPILE)
GO

/*********************************************/
-- レジストリ情報
/*********************************************/
SELECT GETDATE() AS DATE, * FROM sys.dm_server_registry
OPTION (RECOMPILE)
GO