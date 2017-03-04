USE DemoDB
GO

-- データベースレベルで有効化
ALTER DATABASE DemoDB 
SET REMOTE_DATA_ARCHIVE = ON(SERVER= N'<サーバー名>.database.windows.net',  CREDENTIAL = [<サーバー名>.database.windows.net])
GO


/*
CTP 2.3 まで
ALTER DATABASE DemoDB 
SET REMOTE_DATA_ARCHIVE = ON(SERVER= N'<サーバー名>.database.windows.net')
GO
*/
 
-- 有効化
/*
CTP 2.3 まで
ALTER TABLE StretchTable ENABLE REMOTE_DATA_ARCHIVE WITH (MIGRATION_STATE = ON)

CTP 2.4 まで
ALTER TABLE StretchTable SET(REMOTE_DATA_ARCHIVE = ON (MIGRATION_STATE = ON))
GO
*/

-- CTP 3.0
ALTER TABLE StretchTable SET(REMOTE_DATA_ARCHIVE = ON (MIGRATION_STATE = OUTBOUND))
GO

-- データの投入
SET NOCOUNT ON
INSERT INTO StretchTable (Col2)  VALUES(NEWID())
GO 100


-- 投入直後に件数を検索
SELECT row_count FROM sys.dm_db_partition_stats WHERE object_id = OBJECT_ID('StretchTable')

-- 時間をおいて検索
SELECT row_count FROM sys.dm_db_partition_stats WHERE object_id = OBJECT_ID('StretchTable')


EXEC sp_spaceused 'StretchTable', @mode='ALL'
EXEC sp_spaceused 'StretchTable', @mode='LOCAL_ONLY'
EXEC sp_spaceused 'StretchTable', @mode='REMOTE_ONLY'


-- データと実行プランの確認
SELECT * FROM StretchTable
GO


-- データの変更と削除
DELETE FROM StretchTable WHERE Col1 = 10
GO
UPDATE StretchTable SET Col2 = NEWID() WHERE Col1 = 10

-- インデックスの操作
CREATE NONCLUSTERED INDEX NCIX_StretchTable ON StretchTable(Col1)
ALTER INDEX NCIX_StretchTable ON StretchTable REBUILD
DROP INDEX NCIX_StretchTable ON StretchTable

-- テーブル定義が変更できるかの確認
ALTER TABLE StretchTable ADD Col3 int


-- 一意制約の設定されているテーブルに対して設定できるかの確認
DROP TABLE IF EXISTS StretchTable2
CREATE TABLE StretchTable2 (Col1 int PRIMARY KEY)

ALTER TABLE StretchTable2 SET(REMOTE_DATA_ARCHIVE = ON (MIGRATION_STATE = OUTBOUND))
GO

