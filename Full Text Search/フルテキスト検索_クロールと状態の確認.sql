SET NOCOUNT ON
GO

/*********************************************/
-- フルテキストのクロール状態
/*********************************************/
SELECT
	DB_NAME() AS database_name,
	SCHEMA_NAME(obj.schema_id) AS schema_name,
	obj.name AS object_name,
	crawl.crawl_type_desc,
	crawl.crawl_start_date,
	crawl.crawl_end_date,
	crawl.crawl_status,
	crawl.crawl_status_desc
FROM sys.fulltext_indexes AS ft
	INNER JOIN sys.objects AS obj
	ON ft.object_id = obj.object_id
	LEFT JOIN sys.fulltext_index_crawl_status AS crawl
	ON ft.object_id = crawl.object_id
ORDER BY
	schema_name,
	object_name
OPTION (RECOMPILE)
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
	ON stopword.language_id = lang.language_id
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
