-- ADR (CTR) Technical Document
/*
https://www.microsoft.com/en-us/research/publication/constant-time-recovery-in-azure-sql-database/

https://docs.microsoft.com/ja-jp/sql/relational-databases/accelerated-database-recovery-concepts?view=sql-server-ver15
https://docs.microsoft.com/ja-jp/sql/database-engine/configure-windows/adr-cleaner-retry-timeout-configuration-option?view=sql-server-ver15


https://www.red-gate.com/simple-talk/homepage/how-does-accelerated-database-recovery-work/
https://drewkal.com/category/accelerated-database-recovery-adr/

https://blog.dbi-services.com/introducing-accelerated-database-recovery-with-sql-server-2019/
https://blog.dbi-services.com/sql-server-2019-accelerated-database-recovery-instantaneous-rollback-and-aggressive-log-truncation/

*/


-- テスト用データ作成
DROP TABLE IF EXISTS T1
CREATE TABLE T1(C1 int identity primary key, C2 varchar(36), C3 tinyint, C4 varchar(36), C5 varchar(36))
SET NOCOUNT ON
GO

DECLARE @cnt int = 0
WHILE(@cnt <= 254)
BEGIN
	INSERT INTO T1 (C2, C3) VALUES(NEWID(), @cnt)
	SET @cnt += 1
END
CHECKPOINT
ALTER INDEX ALL ON T1 REBUILD
GO

SELECT * FROM sys.system_internals_allocation_units 
WHERE container_id = (SELECT hobt_id FROM sys.partitions WHERE object_id = OBJECT_ID('T1') )


-- 他のセッションで以下のクエリを実行
BEGIN TRAN
UPDATE T1 SET C2 = NEWID() WHEre C1 = 255
GO

-- 通常のセッションで以下のクエリを 2 回実行
UPDATE T1 SET C2 =NEWID(), C4 = NEWID(), C5 = NEWID()  WHERE C1 = 1

-- 1 回目の UPDATE では inrow として格納されるが、2 回目の UPDATE では inrow から offrow に移動される
SELECT 	version_record_count, inrow_version_record_count,offrow_regular_version_record_count, offrow_long_term_version_record_count
FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('T1'), NULL, NULL, 'DETAILED')

-- PVS  の情報を確認
SELECT * FROM sys.dm_tran_persistent_version_store  -- sys.persistent_version_store 相当の情報を取得するための DMV (PVS は DB 単位に独立している)
SELECT * FROM sys.dm_tran_persistent_version_store_stats WHERE database_id = DB_ID()

-- DAC で、select * from sys.persistent_version_store  OUTER APPLY sys.fn_PhysLocCracker(%%physloc%%) を実行するか次のクエリで、PVS で使用されているページを把握
SELECT * FROM sys.system_internals_allocation_units 
WHERE container_id = (SELECT hobt_id FROM sys.partitions WHERE object_id = OBJECT_ID('sys.persistent_version_store') )

SELECT * FROM T1 OUTER APPLY sys.fn_PhysLocCracker(%%physloc%%) where c1 = 1

DBCC TRACEON(3604)
DBCC PAGE('ADR_TEST', 1, 1,3) -- PFS にバージョン情報が含まれるかが格納されている
DBCC PAGE('ADR_TEST', 1, 150,3)
DBCC PAGE('ADR_TEST', 1, 264,3)
DBCC PAGE('ADR_TEST', 1, 2480,3)
GO

-- Aborted Transaction の実行
-- 1 回目の Update は tinyint の範囲内なので成功
UPDATE T1 SET C3 = C3+1
-- 2 回目の Update で tinyint の上限を超えるため、aborted transactions として認識される
UPDATE T1 SET C3 = C3+1
-- Aborted Transactions の確認 (本情報が、Aborted Transactions Map (ATM) 相当の情報だと考えらえる
SELECT * FROM  sys.dm_tran_aborted_transactions
GO


--sLog : Secondary Log  Stream の情報確認
SELECT * FROM sys.fn_dblog(NULL, NULL)
SELECT * FROM sys.fn_dbslog(NULL, NULL)



