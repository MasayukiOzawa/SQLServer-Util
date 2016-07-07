/*************************************************/
/* エンドポイントの作成							 */
/*************************************************/
:Connect SQL-03
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

:Connect SQL-04
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
:Connect SQL-03
IF NOT EXISTS (select * from sys.syslogins where name LIKE '%SQLServiceUser')
BEGIN
	CREATE LOGIN [SQL-03\SQLServiceUser] FROM WINDOWS
END
GO
GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [SQL-03\SQLServiceUser]
GO

:Connect SQL-04
IF NOT EXISTS (select * from sys.syslogins where name LIKE '%SQLServiceUser')
BEGIN
	CREATE LOGIN [SQL-04\SQLServiceUser] FROM WINDOWS
END
GO
GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [SQL-04\SQLServiceUser]
GO


/****************************************************/
/* AlwaysOn 向け拡張イベントの有効化				*/
/****************************************************/
:Connect SQL-03
IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END
GO

:Connect SQL-03
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
:Connect SQL-03
USE [master]
GO

CREATE AVAILABILITY GROUP [AG02]
WITH (AUTOMATED_BACKUP_PREFERENCE = PRIMARY,
-- BASIC, -- Standard Edition の場合、BASIC を明示的につけなくても基本的な可用性グループになる
DB_FAILOVER = ON, -- ON or OFF
DTC_SUPPORT = NONE) -- PER_DB or NONE
FOR
REPLICA ON 
N'SQL-03' WITH (ENDPOINT_URL = N'TCP://SQL-03.cluster2.local:5022', SEEDING_MODE = AUTOMATIC, FAILOVER_MODE = AUTOMATIC, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO)),
N'SQL-04' WITH (ENDPOINT_URL = N'TCP://SQL-04.cluster2.local:5022', SEEDING_MODE = AUTOMATIC, FAILOVER_MODE = AUTOMATIC, AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, SECONDARY_ROLE(ALLOW_CONNECTIONS = NO));
GO

/****************************************************/
/* セカンダリを可用性グループに追加					*/
/****************************************************/
:Connect SQL-04
USE [master]
GO
ALTER AVAILABILITY GROUP [AG02] JOIN;
GO

/****************************************************/
/* リスナーの作成									*/
/****************************************************/
:Connect SQL-03
USE [master]
GO

ALTER AVAILABILITY GROUP [AG02]
ADD LISTENER N'LN-02' (
WITH DHCP
ON (N'10.0.0.0', N'255.0.0.0'), PORT=1433);
GO

/****************************************************/
/* Automatic Seeding 向けの権限の設定				*/
/****************************************************/
:Connect SQL-03
ALTER AVAILABILITY GROUP AG02 GRANT CREATE ANY DATABASE
GO

:Connect SQL-04
ALTER AVAILABILITY GROUP AG02 GRANT CREATE ANY DATABASE
GO

/****************************************************/
/* 分散可用性グループ (プライマリ)					*/
/****************************************************/
:Connect SQL-01
-- DROP AVAILABILITY GROUP [distributedag]
CREATE AVAILABILITY GROUP [distributedag]   
WITH (DISTRIBUTED) 
AVAILABILITY GROUP ON   
  'AG01' WITH 
( 
LISTENER_URL = 'tcp://LN-01.cluster1.local:5022',  
AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT, 
FAILOVER_MODE = MANUAL, 
SEEDING_MODE = AUTOMATIC 
), 
'AG02' WITH 
 ( 
 LISTENER_URL = 'tcp://LN-02.cluster2.local:5022', 
 AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT, 
 FAILOVER_MODE = MANUAL, 
 SEEDING_MODE = AUTOMATIC 
);  
GO 

/****************************************************/
/* 分散可用性グループ (セカンダリ)					*/
/****************************************************/
:CONNECT SQL-03
--DROP AVAILABILITY GROUP [distributedag]
ALTER AVAILABILITY GROUP [distributedag]
JOIN 
AVAILABILITY GROUP ON
'AG01' WITH 
( 
LISTENER_URL = 'tcp://LN-01.cluster1.local:5022',  
AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT, 
FAILOVER_MODE = MANUAL, 
SEEDING_MODE = AUTOMATIC 
), 
'AG02' WITH 
( 
LISTENER_URL = 'tcp://LN-02.cluster2.local:5022', 
AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT, 
FAILOVER_MODE = MANUAL, 
SEEDING_MODE = AUTOMATIC 
);  
GO 

