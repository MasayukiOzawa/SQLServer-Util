SET NOCOUNT ON
GO

/********************************************/
-- パフォーマンスモニタからメモリ情報を取得
/********************************************/

DECLARE @InstanceName AS sysname
DECLARE @MSSQLVersion AS sysname
SELECT @MSSQLVersion  = CONVERT(sysname, SERVERPROPERTY ('ProductVersion'))

IF (PATINDEX('9.00%', @MSSQLVersion) > 0)
BEGIN
	SET @InstanceName = 'SQLServer'
END
ELSE
BEGIN
	SET @InstanceName = 'MSSQL$' + CONVERT(sysname,SERVERPROPERTY('InstanceName'))
END

SELECT
	GETDATE() AS DATE, 
	[object_name], 
	[counter_name], 
	[instance_name], 
	[cntr_value], 
	[cntr_value] * 8.0 AS [Cntr value * 8]
FROM
	[sys].[dm_os_performance_counters]
WHERE
	([object_name] = @InstanceName + ':Memory Manager')
	OR
	([object_name] = @InstanceName + ':Buffer Manager')
	OR
	([object_name] = @InstanceName + ':Plan Cache')

