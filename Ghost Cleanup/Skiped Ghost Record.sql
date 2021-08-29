-- https://docs.microsoft.com/ja-jp/sql/relational-databases/ghost-record-cleanup-process-guide?view=sql-server-ver15

-- Row Versioning On 
USE [master]
GO
ALTER DATABASE tpch SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE tpch SET ALLOW_SNAPSHOT_ISOLATION ON
GO


-- Session #1 :
USE tpch
DROP TABLE IF EXISTS DummyLock
GO

CREATE TABLE DummyLock(C1 int)
GO
BEGIN TRAN
INSERT INTO DummyLock VALUES(1)

/*
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SELECT COUNT_BIG(*) FROM LINEITEM WITH(XLOCK) 
CROSS JOIN LINEITEM AS L2
CROSS JOIN LINEITEM AS L3
OPTION (MAXDOP 1)
*/

-- Session #2
USE tpch
DROP TABLE IF EXISTS GhostCleanUpTest
CREATE TABLE GhostCleanUpTest
(
    C1 int identity PRIMARY KEY CLUSTERED,
    C2 bit,
    C3 varchar(100),
    C4 varchar(1000),
    INDEX NCIX_GhostCleanUpTest (C2)
)
GO

set nocount on
declare @cnt int  = 1

begin tran
while(@cnt != 10000)
begin
    insert into GhostCleanUpTest VALUES(
        CASE
            WHEN @cnt % 2 = 0  THEN 0
            ELSE 1
        END,
        NEWID(),
        NEWID()
    )
    SET @cnt += 1
end
commit tran
 
select * from sys.dm_db_index_usage_stats where object_id = OBJECT_ID('GhostCleanUpTest')
select * from sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('GhostCleanUpTest'), NULL, NULL)
select * from sys.dm_db_partition_stats where object_id = OBJECT_ID('GhostCleanUpTest')
select * from sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('GhostCleanUpTest'), NULL, NULL, 'DETAILED')
 
delete from GhostCleanUpTest
WAITFOR DELAY '00:00:10'
 
select * from sys.dm_db_index_usage_stats where object_id = OBJECT_ID('GhostCleanUpTest')
select * from sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('GhostCleanUpTest'), NULL, NULL)
select * from sys.dm_db_partition_stats where object_id = OBJECT_ID('GhostCleanUpTest')
select * from sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('GhostCleanUpTest'), NULL, NULL, 'DETAILED')

-- Session #3
SELECT COUNT(*) FROM GhostCleanUpTest

-- Check
SELECT * FROM sys.dm_tran_current_transaction

SELECT * FROM sys.dm_tran_active_snapshot_database_transactions
SELECT * FROM sys.dm_tran_active_transactions
SELECT * FROM sys.dm_tran_version_store WHERE database_id= DB_ID('tpch')

