DECLARE @ErrorDumpDir nvarchar(1000)
DECLARE @DefaultData nvarchar(1000), @DefaultLog nvarchar(1000), @BackupDirectory nvarchar(1000)
DECLARE @FeatureList nvarchar(1000), @Collation nvarchar(1000), @SQLBinRoot nvarchar(1000), @SQLDataRoot nvarchar(1000), @SQLPath nvarchar(1000), @SqlProgramDir nvarchar(1000)
DECLARE @ErrorLogFile nvarchar(1000), @WorkingDirectory nvarchar(1000), @JobHistoryMaxRows int, @JobHistoryMaxRowsPerJob int
DECLARE @IpAddress1 nvarchar(1000), @IpAddress2 nvarchar(1000),@IpAddress3 nvarchar(1000),@IpAddress4 nvarchar(1000),@IpAddress5 nvarchar(1000),@IpAddress6 nvarchar(1000),@IpAddress7 nvarchar(1000),@IpAddress8 nvarchar(1000),@IpAddress9 nvarchar(1000), @TcpPort nvarchar(1000)
DECLARE @MSSQLServerImagePath nvarchar(1000), @MSSQLServerObjectName nvarchar(1000)
DECLARE @SQLServerAgentImagePath nvarchar(1000), @SQLServerAgentObjectName nvarchar(1000)

EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\CPE', @value_name  = N'ErrorDumpDir', @value = @ErrorDumpDir OUTPUT

EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer', @value_name  = N'DefaultData', @value = @DefaultData OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer', @value_name  = N'DefaultLog', @value = @DefaultLog OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer', @value_name  = N'BackupDirectory', @value = @BackupDirectory OUTPUT

EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\Setup', @value_name  = N'FeatureList', @value = @FeatureList OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\Setup', @value_name  = N'Collation', @value = @Collation OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\Setup', @value_name  = N'SQLBinRoot', @value = @SQLBinRoot OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\Setup', @value_name  = N'SQLDataRoot', @value = @SQLDataRoot OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\Setup', @value_name  = N'SQLPath', @value = @SQLPath OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\Setup', @value_name  = N'SqlProgramDir', @value = @SqlProgramDir OUTPUT

EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\SQLServerAgent', @value_name  = N'ErrorLogFile', @value = @ErrorLogFile OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\SQLServerAgent', @value_name  = N'WorkingDirectory', @value = @WorkingDirectory OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\SQLServerAgent', @value_name  = N'JobHistoryMaxRows', @value = @JobHistoryMaxRows OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\SQLServerAgent', @value_name  = N'JobHistoryMaxRowsPerJob', @value = @JobHistoryMaxRowsPerJob OUTPUT

EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IP1', @value_name  = N'IpAddress', @value = @IpAddress1 OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IP2', @value_name  = N'IpAddress', @value = @IpAddress2 OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IP3', @value_name  = N'IpAddress', @value = @IpAddress3 OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IP4', @value_name  = N'IpAddress', @value = @IpAddress4 OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IP5', @value_name  = N'IpAddress', @value = @IpAddress5 OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IP6', @value_name  = N'IpAddress', @value = @IpAddress6 OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IP7', @value_name  = N'IpAddress', @value = @IpAddress7 OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IP8', @value_name  = N'IpAddress', @value = @IpAddress8 OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IP9', @value_name  = N'IpAddress', @value = @IpAddress9 OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\IPAll', @value_name  = N'TcpPort', @value = @TcpPort OUTPUT

EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'SYSTEM\CurrentControlSet\Services\MSSQLServer', @value_name  = N'ImagePath', @value = @MSSQLServerImagePath OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'SYSTEM\CurrentControlSet\Services\MSSQLServer', @value_name  = N'ObjectName', @value = @MSSQLServerObjectName OUTPUT

EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'SYSTEM\CurrentControlSet\Services\SQLServerAgent',@value_name  = N'ImagePath', @value = @SQLServerAgentImagePath OUTPUT
EXECUTE master.dbo.xp_instance_regread @rootkey = N'HKEY_LOCAL_MACHINE', @key = N'SYSTEM\CurrentControlSet\Services\SQLServerAgent',@value_name  = N'ObjectName', @value = @SQLServerAgentObjectName OUTPUT

SELECT 1 AS no, 'ErrorDumpDir' AS name, @ErrorDumpDir AS value
UNION SELECT 2, 'DefaultFile', SERVERPROPERTY('instancedefaultdatapath')
UNION SELECT 3, 'DefaultLog', SERVERPROPERTY('instancedefaultlogpath')
UNION SELECT 4, 'DefaultFile(Registry)', @DefaultData
UNION SELECT 5, 'DefaultLog(Registry)', @DefaultLog
UNION SELECT 6, 'BackupDirectory', @BackupDirectory
UNION SELECT 7, 'FeatureList', @FeatureList
UNION SELECT 8, 'Collation', @Collation
UNION SELECT 9, 'SQLBinRoot', @SQLBinRoot
UNION SELECT 10, 'SQLDataRoot', @SQLDataRoot
UNION SELECT 11, 'SQLPath', @SQLPath
UNION SELECT 12, 'SqlProgramDir', @SqlProgramDir
UNION SELECT 13, 'ErrorLogFile', @ErrorLogFile
UNION SELECT 14, 'WorkingDirectory', @WorkingDirectory
UNION SELECT 15, 'JobHistoryMaxRows', @JobHistoryMaxRows
UNION SELECT 16, 'JobHistoryMaxRowsPerJob', @JobHistoryMaxRowsPerJob
UNION SELECT 17, 'IpAddress1', @IpAddress1
UNION SELECT 18, 'IpAddress2', @IpAddress2
UNION SELECT 19, 'IpAddress3', @IpAddress3
UNION SELECT 20, 'IpAddress4', @IpAddress4
UNION SELECT 21, 'IpAddress5', @IpAddress5
UNION SELECT 22, 'IpAddress6', @IpAddress6
UNION SELECT 23, 'IpAddress7', @IpAddress7
UNION SELECT 24, 'IpAddress8', @IpAddress8
UNION SELECT 25, 'IpAddress9', @IpAddress9
UNION SELECT 26, 'TcpPort', @TcpPort
UNION SELECT 27, 'MSSQLServerImagePath', @MSSQLServerImagePath
UNION SELECT 28, 'MSSQLServerObjectName', @MSSQLServerObjectName
UNION SELECT 29, 'SQLServerAgentImagePath', @SQLServerAgentImagePath
UNION SELECT 30, 'SQLServerAgentObjectName', @SQLServerAgentObjectName

SELECT servicename,startup_type_desc, service_account,filename FROM  sys.dm_server_services
