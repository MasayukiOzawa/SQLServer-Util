SET NOCOUNT ON
GO

/*********************************************/
-- フルテキストカタログの一覧
/*********************************************/
SELECT
	DB_NAME() AS database_name,
	fulltext_catalog_id,
	name AS catalog_name,
	path,
	is_default,
	is_accent_sensitivity_on,
	is_importing
FROM sys.fulltext_catalogs
ORDER BY
	name
OPTION (RECOMPILE)
GO

/*********************************************/
-- フルテキストインデックスの一覧
/*********************************************/
SELECT
	DB_NAME() AS database_name,
	SCHEMA_NAME(obj.schema_id) AS schema_name,
	obj.name AS object_name,
	idx.name AS unique_index_name,
	ft.is_enabled,
	ft.change_tracking_state_desc,
	ft.has_crawl_completed,
	ft.crawl_type_desc,
	ft.crawl_start_date,
	ft.crawl_end_date,
	catalog.name AS catalog_name,
	stoplist.name AS stoplist_name
FROM sys.fulltext_indexes AS ft
	INNER JOIN sys.objects AS obj
	ON ft.object_id = obj.object_id
	INNER JOIN sys.indexes AS idx
	ON ft.object_id = idx.object_id
	AND ft.unique_index_id = idx.index_id
	LEFT JOIN sys.fulltext_catalogs AS catalog
	ON ft.fulltext_catalog_id = catalog.fulltext_catalog_id
	LEFT JOIN sys.fulltext_stoplists AS stoplist
	ON ft.stoplist_id = stoplist.stoplist_id
ORDER BY
	schema_name,
	object_name
OPTION (RECOMPILE)
GO

/*********************************************/
-- フルテキストインデックスの列情報
/*********************************************/
SELECT
	DB_NAME() AS database_name,
	SCHEMA_NAME(obj.schema_id) AS schema_name,
	obj.name AS object_name,
	col.name AS column_name,
	fic.language_id,
	lang.name AS language_name
FROM sys.fulltext_index_columns AS fic
	INNER JOIN sys.objects AS obj
	ON fic.object_id = obj.object_id
	INNER JOIN sys.columns AS col
	ON fic.object_id = col.object_id
	AND fic.column_id = col.column_id
	LEFT JOIN sys.columns AS type_col
	ON fic.object_id = type_col.object_id
	AND fic.type_column_id = type_col.column_id
	LEFT JOIN sys.fulltext_languages AS lang
	ON fic.language_id = lang.lcid
ORDER BY
	schema_name,
	object_name,
	column_name
OPTION (RECOMPILE)
GO

/*********************************************/
-- フルテキストインデックスのフラグメント情報
/*********************************************/
SELECT
	DB_NAME() AS database_name,
	SCHEMA_NAME(obj.schema_id) AS schema_name,
	obj.name AS object_name,
	OBJECT_NAME(frag.fragment_object_id) AS fragment_object_name,
	frag.fragment_id,
	frag.status,
	frag.data_size,
	frag.row_count
FROM sys.fulltext_index_fragments AS frag
	INNER JOIN sys.objects AS obj
	ON frag.table_id = obj.object_id
ORDER BY
	schema_name,
	object_name,
	frag.fragment_id
OPTION (RECOMPILE)
GO
