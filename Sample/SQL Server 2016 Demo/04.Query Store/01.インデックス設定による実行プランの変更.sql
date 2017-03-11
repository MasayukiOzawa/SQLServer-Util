USE DemoDB
GO


-- テーブルスキャン
DECLARE @Col2 uniqueidentifier = (SELECT TOP 1 Col2 FROM QueryStore TABLESAMPLE (10 PERCENT))
SELECT * FROM QueryStore WHERE Col2 = @Col2
GO

-- インデックスの作成
CREATE NONCLUSTERED INDEX [NCIX_QueryStore_Col2] ON dbo.QueryStore (Col2) WITH(STATISTICS_NORECOMPUTE = ON)
GO

DECLARE @Col2 uniqueidentifier = (SELECT TOP 1 Col2 FROM QueryStore TABLESAMPLE (10 PERCENT))
SELECT * FROM QueryStore WHERE Col2 = @Col2


-- クエリ ID の確認
SELECT * FROM sys.query_store_query_text WHERE query_sql_text LIKE '%QueryStore%'
