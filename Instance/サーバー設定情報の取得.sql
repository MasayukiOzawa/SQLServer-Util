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

/*********************************************/
-- サーバープロパティの取得
/*********************************************/
SELECT
	GETDATE() AS DATE,
	SERVERPROPERTY('BuildClrVersion') AS [BuildClrVersion],
	SERVERPROPERTY('Collation') AS [Collation],
	SERVERPROPERTY('ComparisonStyle') AS [ComparisonStyle],
	SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS [ComputerNamePhysicalNetBIOS],
	SERVERPROPERTY('Edition') AS [Edition],
	SERVERPROPERTY('EditionID') AS [EditionID],
	SERVERPROPERTY('EngineEdition') AS [EngineEdition],
	SERVERPROPERTY('InstanceName') AS [InstanceName],
	SERVERPROPERTY('IsClustered') AS [IsClustered],
	SERVERPROPERTY('IsFullTextInstalled') AS [IsFullTextInstalled],
	SERVERPROPERTY('IsIntegratedSecurityOnly') AS [IsIntegratedSecurityOnly],
	SERVERPROPERTY('IsSingleUser') AS [IsSingleUser],
	SERVERPROPERTY('LCID') AS [LCID],
	SERVERPROPERTY('LicenseType') AS [LicenseType],
	SERVERPROPERTY('MachineName') AS [MachineName],
	SERVERPROPERTY('NumLicenses') AS [NumLicenses],
	SERVERPROPERTY('ProcessID') AS [ProcessID],
	SERVERPROPERTY('ProductVersion') AS [ProductVersion],
	SERVERPROPERTY('ProductLevel') AS [ProductLevel],
	SERVERPROPERTY('ResourceLastUpdateDateTime') AS [ResourceLastUpdateDateTime],
	SERVERPROPERTY('ResourceVersion') AS [ResourceVersion],
	SERVERPROPERTY('ServerName') AS [ServerName],
	SERVERPROPERTY('SqlCharSet') AS [SqlCharSet],
	SERVERPROPERTY('SqlCharSetName') AS [SqlCharSetName],
	SERVERPROPERTY('SqlSortOrder') AS [SqlSortOrder],
	SERVERPROPERTY('SqlSortOrderName') AS [SqlSortOrderName]
	

/*********************************************/
-- SYSINFO
/*********************************************/
select GETDATE() AS DATE,* from sys.dm_os_sys_info


