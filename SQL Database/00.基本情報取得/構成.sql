SELECT
    SERVERPROPERTY('Collation') AS Collation,
    CAST(DATABASEPROPERTYEX(DB_NAME(), 'MaxSizeInBytes') AS bigint) / POWER(1024,3) AS MaxSizeInGBytes,
    DATABASEPROPERTYEX(DB_NAME(), 'Edition') AS Edition,
    DATABASEPROPERTYEX(DB_NAME(), 'ServiceObjective') AS ServiceObjective
GO

SELECT * FROM sys.databases
GO

SELECT * FROM sys.database_scoped_configurations
GO

SELECT * FROM sys.dm_user_db_resource_governance
GO