SET NOCOUNT ON
GO

/*********************************************/
-- フルテキスト停止リストと停止語
/*********************************************/
SELECT
	stoplist.stoplist_id,
	stoplist.name AS stoplist_name,
	stopword.language_id,
	lang.name AS language_name,
	stopword.stopword
FROM sys.fulltext_stoplists AS stoplist
	LEFT JOIN sys.fulltext_stopwords AS stopword
	ON stoplist.stoplist_id = stopword.stoplist_id
	LEFT JOIN sys.fulltext_languages AS lang
	ON stopword.language_id = lang.lcid
ORDER BY
	stoplist.name,
	stopword.language_id,
	stopword.stopword
OPTION (RECOMPILE)
GO

/*********************************************/
-- フルテキストインデックスの人口状態
/*********************************************/
SELECT
	DB_NAME(database_id) AS database_name,
	OBJECT_SCHEMA_NAME(table_id) AS schema_name,
	OBJECT_NAME(table_id) AS object_name,
	*
FROM sys.dm_fts_index_population
WHERE database_id = DB_ID()
ORDER BY
	schema_name,
	object_name
OPTION (RECOMPILE)
GO

/*********************************************/
-- フルテキストの未処理バッチ
/*********************************************/
SELECT
	DB_NAME(database_id) AS database_name,
	OBJECT_SCHEMA_NAME(table_id) AS schema_name,
	OBJECT_NAME(table_id) AS object_name,
	*
FROM sys.dm_fts_outstanding_batches
WHERE database_id = DB_ID()
ORDER BY
	schema_name,
	object_name
OPTION (RECOMPILE)
GO
