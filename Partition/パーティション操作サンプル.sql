/*******************************************************************/
-- 初期化

DROP TABLE IF EXISTS TEST
DROP TABLE IF EXISTS TEST_Archive
GO

IF EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'TEST_PS')
	DROP PARTITION SCHEME TEST_PS
IF EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'TEST_PF')
	DROP PARTITION FUNCTION TEST_PF
IF EXISTS (SELECT 1 FROM sys.partition_schemes WHERE name = 'TEST_Archive_PS')
	DROP PARTITION SCHEME TEST_Archive_PS
IF EXISTS (SELECT 1 FROM sys.partition_functions WHERE name = 'TEST_Archive_PF')
	DROP PARTITION FUNCTION TEST_Archive_PF
GO
 
CREATE PARTITION FUNCTION TEST_PF(date) AS RANGE RIGHT FOR VALUES('2016/1/1', '2017/1/1','2018/1/1','2019/1/1','2020/1/1') 
GO
CREATE PARTITION SCHEME TEST_PS AS PARTITION TEST_PF ALL TO ([PRIMARY])
GO
CREATE PARTITION FUNCTION TEST_Archive_PF(date) AS RANGE RIGHT FOR VALUES('2016/1/1', '2017/1/1','2018/1/1','2019/1/1','2020/1/1') 
GO
CREATE PARTITION SCHEME TEST_Archive_PS AS PARTITION TEST_Archive_PF ALL TO ([PRIMARY])
GO
/*******************************************************************/


/*******************************************************************/
-- パーティショニングされていないヒープテーブルの作成

CREATE TABLE TEST(
	C1 int  NOT NULL,
	C2 date NOT NULL, 
	C3 uniqueidentifier,
	C4 AS CASE WHEN C2 >= '2012/1/1' THEN 1 ELSE 2 END, -- 決定的でない計算列 (決定的でないため PERSISTED は指定できない)
	C5 AS Month(C2), -- 永続化されていない計算列 (決定的であればインデックス列としては使えるがパーティション分割列としては使えない)
	C6 AS Month(C2) PERSISTED -- 永続化されている計算列 (永続化されていればパーティション分割列として使える)
)
GO
-- 計算列が決定的かどうかの確認 (計算列を使ったからと言って、必ず非決定的となるわけではない)
SELECT COLUMNPROPERTY(OBJECT_ID('TEST'), N'C4', 'IsDeterministic')
SELECT COLUMNPROPERTY(OBJECT_ID('TEST'), N'C5', 'IsDeterministic')
SELECT COLUMNPROPERTY(OBJECT_ID('TEST'), N'C6', 'IsDeterministic')
/*******************************************************************/


/*******************************************************************/
-- ヒープテーブルのパーティショニング

CREATE TABLE TEST(
	C1 int  NOT NULL,
	C2 date NOT NULL, 
	C3 uniqueidentifier,
	C4 AS CASE WHEN C2 >= '2012/1/1' THEN 1 ELSE 2 END, -- 決定的でない計算列 (決定的でないため PERSISTED は指定できない)
	C5 AS Month(C2), -- 永続化されていない計算列 (決定的であればインデックス列としては使えるがパーティション分割列としては使えない)
	C6 AS Month(C2) PERSISTED -- 永続化されている計算列 (永続化されていればパーティション分割列として使える)
)ON TEST_PS(C2)
GO
/*******************************************************************/

/*******************************************************************/
-- クラスター化インデックスのパーティショニング
CREATE TABLE TEST(
	C1 int NOT NULL,
	C2 date NOT NULL, 
	C3 uniqueidentifier,
	C4 AS CASE WHEN C2 >= '2012/1/1' THEN 1 ELSE 2 END, -- 決定的でない計算列 (決定的でないため PERSISTED は指定できない)
	C5 AS Month(C2), -- 永続化されていない計算列 (決定的であればインデックス列としては使えるがパーティション分割列としては使えない)
	C6 AS Month(C2) PERSISTED -- 永続化されている計算列 (永続化されていればパーティション分割列として使える)
)
GO
CREATE CLUSTERED INDEX CIX_TEST ON TEST (C2) ON TEST_PS(C2)
/******************************************************************/


/******************************************************************/
-- ロックエスカレーションのモードの変更

ALTER TABLE TEST SET ( LOCK_ESCALATION = AUTO )
/******************************************************************/


/******************************************************************/
-- ベーステーブルに固定しないインデックスの作成

-- ベーステーブルに固定されていないインデックスが存在している場合、
-- パーティションのスイッチ / Truncate はできない
ALTER TABLE TEST ADD CONSTRAINT PK_TEST PRIMARY KEY NONCLUSTERED (C1) ON [PRIMARY]
GO
/******************************************************************/

/******************************************************************/
-- ベーステーブルに固定したインデックス

-- テーブルと同一のパーティション構成で作成される
CREATE INDEX NCIX_TEST_C3 ON TEST(C3) 

-- 計算列を使用してパーティショニングを実施する場合、決定的な式でない列をパーティション列として指定できない
-- https://technet.microsoft.com/ja-jp/library/ms191250(v=sql.105).aspx
DROP INDEX IF EXISTS NCIX_TEST_CALC ON TEST
CREATE INDEX NCIX_TEST_CALC ON TEST(C4) 

-- 決定的な列についてはインデックスが作成できる (PERSISITED でなくても決定的であれば作成できる、ただしパーティション列としては使用できない)
DROP INDEX IF EXISTS NCIX_TEST_CALC ON TEST
CREATE INDEX NCIX_TEST_CALC ON TEST(C5) 

-- パーティションキーを省略して作成しているが、内部的にはパーティションキーが自動的に含まれている (データ挿入後に確認)
SELECT OBJECT_NAME(pa.object_id) AS object_name, i.name, i.type_desc ,pa.allocation_unit_type_desc,pa.is_iam_page, partition_id, allocated_page_file_id,allocated_page_page_id
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('TEST'), NULL, NULL, 'LIMITED') pa
LEFT JOIN sys.indexes AS i ON i.object_id = pa.object_id AND i.index_id = pa.index_id
WHERE pa.is_iam_page = 0
ORDER BY pa.index_id, pa.partition_id


DBCC TRACEON(3604)
DBCC PAGE(N'PartitionTest', 1, 1931, 3)
/******************************************************************/


/****************************************************/
-- 一意制約の作成 (クラスター化インデックス)

-- パーティションテーブルに対しての一意制約の作成のため、パーティションキーをインデックスキーに含める必要がある
-- パーティション列を含んでいないため、エラーとなる
ALTER TABLE TEST ADD CONSTRAINT PK_TEST PRIMARY KEY CLUSTERED (C1) ON TEST_PS(C2)

-- パーティションキーを設定している場合は正常終了
ALTER TABLE TEST ADD CONSTRAINT PK_TEST PRIMARY KEY CLUSTERED (C1, C2) ON TEST_PS(C2)
GO
/****************************************************/

/****************************************************/
-- 一意制約の作成 (非クラスター化インデックス)

-- パーティションテーブルに対しての一意制約の作成のため、パーティションキーをインデックスキーに含める必要がある
-- パーティション列を含んでいないため、エラーとなる
ALTER TABLE TEST ADD CONSTRAINT PK_TEST PRIMARY KEY NONCLUSTERED (C1)
GO

-- ユニークキーも同様にエラーとなる
ALTER TABLE TEST ADD CONSTRAINT UK_TEST UNIQUE(C1)

-- パーティションキーを設定している場合は正常終了
ALTER TABLE TEST ADD CONSTRAINT PK_TEST PRIMARY KEY NONCLUSTERED (C1, C2)
GO
/****************************************************/

/******************************************************************/
-- テストデータの挿入

SET NOCOUNT ON
GO
DECLARE @cnt int = 1
DECLARE @start date = '2015/1/1'
BEGIN TRAN
WHILE (@cnt <= 50000)
BEGIN
	INSERT INTO TEST(C1, C2, C3) VALUES(@cnt, DATEADD(d, @cnt, @start), NEWID())
	SET @cnt += 1
END
COMMIT TRAN
GO
/******************************************************************/

/******************************************************************/
-- パーティションの Truncate

TRUNCATE TABLE TEST WITH (PARTITIONS(1))
TRUNCATE TABLE TEST WITH (PARTITIONS(1,4))
TRUNCATE TABLE TEST WITH (PARTITIONS(1 TO 3))
GO
/******************************************************************/


/******************************************************************/
-- アーカイブテーブルの作成

-- 同一のパーティション構成を使用してしまうと、マージした際にアーカイブテーブルにも影響を与えるため、
-- スイッチ元と異なるパーティション構成を使用
CREATE TABLE TEST_Archive(
	C1 int NOT NULL,
	C2 date NOT NULL, 
	C3 uniqueidentifier,
	C4 AS CASE WHEN C2 >= '2012/1/1' THEN 1 ELSE 2 END,
	C5 AS Month(C2)
)
CREATE CLUSTERED INDEX CIX_TEST_Archive ON TEST_Archive (C2) ON TEST_Archive_PS(C2)

-- パーティションに固定化されたインデックスがある場合は、アーカイブ先でも設定しインデックスを含めてスイッチする
CREATE INDEX NCIX_TEST_Archive_C3 ON TEST_Archive(C3) 
/******************************************************************/


/******************************************************************/
-- パーティションのスイッチ

-- ベーステーブルでスイッチしたパーティションのデータが追加されないように制約を追加
BEGIN TRAN
ALTER TABLE TEST SWITCH PARTITION 1 TO TEST_Archive PARTITION 1
ALTER TABLE TEST ADD CONSTRAINT CHK_PARTITION CHECK(C2 >= '2016/1/1')
--ALTER TABLE TEST ADD CONSTRAINT CHK_PARTITION CHECK(C1 >= 1)
ALTER PARTITION FUNCTION TEST_PF() MERGE RANGE('2016-01-01')
COMMIT TRAN

-- パーティションのスイッチ (一意制約を無効)
BEGIN TRAN
ALTER INDEX PK_TEST ON TEST DISABLE
ALTER TABLE TEST SWITCH PARTITION 1 TO TEST_Archive PARTITION 1
ALTER TABLE TEST ADD CONSTRAINT CHK_PARTITION CHECK(C2 >= '2016/1/1')
ALTER PARTITION FUNCTION TEST_PF() MERGE RANGE('2016-01-01')
ALTER INDEX PK_TEST ON TEST REBUILD WITH (ONLINE = ON)
COMMIT TRAN
/******************************************************************/


/******************************************************************/
-- ベーステーブルに制約が設定している状態の確認

-- アーカイブしたデータを戻そうとするとエラー
ALTER TABLE TEST_Archive SWITCH PARTITION 1 TO TEST PARTITION 1 
-- エラー
-- アーカイブテーブルに格納されているデータに 2016/1/1 以前のデータが含まれていないという保証がないため
-- パーティションの切り替え先に制約が設定されている場合は、その制約に違反しないデータになっているという保証がベーステーブルにも必要
-- パーティション分割列が NULL 許容の場合、NULL 出ないという制約も必要となる
/******************************************************************/

