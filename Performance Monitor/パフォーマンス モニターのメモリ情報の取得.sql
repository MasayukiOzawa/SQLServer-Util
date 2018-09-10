SET NOCOUNT ON
GO

/********************************************/
-- パフォーマンスモニタからメモリ情報を取得
/********************************************/

DECLARE @InstanceName AS sysname
DECLARE @MSSQLVersion AS sysname
SELECT @MSSQLVersion  = CONVERT(sysname, SERVERPROPERTY ('ProductVersion'))

SET @InstanceName = 'SQLServer'

SELECT
	GETDATE() AS DATE, 
	RTRIM([object_name]) AS [object_name], 
	RTRIM([counter_name]) AS [counter_name], 
	RTRIM([instance_name]) AS [instance_name],
	[cntr_value], 
	CASE 
		WHEN cntr_type = 65792 AND 
			counter_name IN ('Database pages', 'Target pages', 'Cache Pages') 
			THEN [cntr_value] * 8 / 1024
		WHEN counter_name IN ('Connection Memory (KB)', 'Database Cache Memory (KB)', 
			'Free Memory (KB)', 'Granted Workspace Memory (KB)', 'Lock Memory (KB)',
			'Optimizer Memory (KB)', 'Reserved Server Memory (KB)', 'SQL Cache Memory (KB)',
			'Stolen Server Memory (KB)','Log Pool Memory (KB)','Target Server Memory (KB)','Total Server Memory (KB)')
			THEN [cntr_value] * 8 / 1024
		ELSE NULL
	END AS contr_size_mb,
	[cntr_type]
FROM
	[sys].[dm_os_performance_counters]
WHERE
	([object_name] = @InstanceName + ':Memory Manager')
	OR
	([object_name] = @InstanceName + ':Buffer Manager')
	OR
	([object_name] = @InstanceName + ':Plan Cache')
