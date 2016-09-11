/*************************************************/
/* エンドポイントの作成							 */
/*************************************************/
:Connect SQL-01
IF NOT EXISTS (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint')
BEGIN
	CREATE ENDPOINT [Hadr_endpoint] AS TCP (LISTENER_PORT = 5022)
	FOR DATA_MIRRORING (ROLE = ALL, ENCRYPTION = REQUIRED ALGORITHM AES)
END
IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END
GO

:Connect SQL-02
IF NOT EXISTS (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint')
BEGIN
	CREATE ENDPOINT [Hadr_endpoint] AS TCP (LISTENER_PORT = 5022)
	FOR DATA_MIRRORING (ROLE = ALL, ENCRYPTION = REQUIRED ALGORITHM AES)
END
IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END
GO
IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END
GO


/**************************************************************************/
/* エンドポイントに対して SQL Server のサービスアカウントの接続権限を設定 */
/**************************************************************************/
:Connect SQL-01
IF NOT EXISTS (select * from sys.syslogins where name LIKE '%SQLServiceUser')
BEGIN
	CREATE LOGIN [SQL-01\SQLServiceUser] FROM WINDOWS
END
GO
GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [SQL-01\SQLServiceUser]
GO

:Connect SQL-02
IF NOT EXISTS (select * from sys.syslogins where name LIKE '%SQLServiceUser')
BEGIN
	CREATE LOGIN [SQL-02\SQLServiceUser] FROM WINDOWS
END
GO
GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [SQL-02\SQLServiceUser]
GO


/****************************************************/
/* AlwaysOn 向け拡張イベントの有効化				*/
/****************************************************/
:Connect SQL-01
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END
GO

:Connect SQL-02
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END
GO

/****************************************************/
/* 可用性グループの作成								*/
/****************************************************/
:Connect SQL-01
USE [master]
GO

CREATE AVAILABILITY GROUP [AG01]
WITH (AUTOMATED_BACKUP_PREFERENCE = PRIMARY,
-- BASIC, -- Standard Edition の場合、BASIC を明示的につけなくても基本的な可用性グループになる
DB_FAILOVER = ON, -- ON or OFF
DTC_SUPPORT = NONE) -- PER_DB or NONE
FOR
REPLICA ON 
N'SQL-01' WITH (ENDPOINT_URL = N'TCP://SQL-01.cluster1.local:5022', SEEDING_MODE = AUTOMATIC, FAILOVER_MODE = AUTOMATIC, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)),
N'SQL-02' WITH (ENDPOINT_URL = N'TCP://SQL-02.cluster1.local:5022', SEEDING_MODE = AUTOMATIC, FAILOVER_MODE = AUTOMATIC, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO));
GO

/****************************************************/
/* セカンダリを可用性グループに追加					*/
/****************************************************/
:Connect SQL-02
USE [master]
GO
ALTER AVAILABILITY GROUP [AG01] JOIN;
GO

/****************************************************/
/* リスナーの作成									*/
/****************************************************/
:Connect SQL-01
USE [master]
GO

ALTER AVAILABILITY GROUP [AG01]
ADD LISTENER N'LN-01' (
WITH DHCP
ON (N'10.0.0.0', N'255.0.0.0'), PORT=1433);
GO

/****************************************************/
/* Automatic Seeding 向けの権限の設定				*/
/****************************************************/
:Connect SQL-01
ALTER AVAILABILITY GROUP AG01 GRANT CREATE ANY DATABASE
GO

:Connect SQL-02
ALTER AVAILABILITY GROUP AG01 GRANT CREATE ANY DATABASE
GO

/****************************************************/
/* 可用性グループに DB を追加						*/
/****************************************************/
:Connect SQL-01
USE [master]
GO
ALTER AVAILABILITY GROUP [AG01] ADD DATABASE [AGDB01];
GO


/****************************************************/
/* Automatic Seeding のマニュアル実行用再設定		*/
/****************************************************/
:Connect SQL-01
USE [master]
GO
ALTER AVAILABILITY GROUP [AG01] MODIFY REPLICA ON N'SQL-02' WITH (SEEDING_MODE= AUTOMATIC)
GO

/****************************************************/
/* Automatic Seeding の状態確認						*/
/****************************************************/
:Connect SQL-01
USE [master]
GO
select * from sys.dm_hadr_automatic_seeding order by start_time desc
select * from sys.dm_hadr_physical_seeding_stats

/****************************************************/
/* 手動同期用 DB のバックアップ / リストア			*/
/****************************************************/
:Connect SQL-01
BACKUP DATABASE [AGDB01] TO  
DISK = N'AGDB01.bak' WITH FORMAT, INIT, COMPRESSION
GO
BACKUP LOG [AGDB01] TO  
DISK = N'AGDB01.bak' WITH NOFORMAT, NOINIT, COMPRESSION
GO

:Connect SQL-02
USE [master]
RESTORE DATABASE [AGDB01] FROM  DISK = N'AGDB01.bak' WITH  FILE = 1,  NORECOVERY,  NOUNLOAD,  STATS = 5
GO
RESTORE LOG [AGDB01] FROM  DISK = N'AGDB01.bak' WITH  FILE = 2,  NORECOVERY,  NOUNLOAD,  STATS = 5
GO


