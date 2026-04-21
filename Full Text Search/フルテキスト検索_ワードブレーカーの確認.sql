SET NOCOUNT ON
GO

/*********************************************/
-- 使用可能なフルテキスト言語
/*********************************************/
SELECT
	*
FROM 
	sys.fulltext_languages
WHERE
	lcid IN (1033, 1041) -- English, Japanese
ORDER BY
	name
OPTION (RECOMPILE)
GO

/*********************************************/
-- ワードブレーカーの結果確認
-- @input を確認したい文字列に変更
/*********************************************/
DECLARE @input nvarchar(4000) = N'フルテキスト検索のワードブレーク確認';
DECLARE @language_id int = 1041; -- Japanese
DECLARE @stoplist_id int = 0; -- 0 = system stoplist
DECLARE @accent_sensitivity bit = 0;

SELECT
	@input AS input_text,
	*
FROM sys.dm_fts_parser(@input, @language_id, @stoplist_id, @accent_sensitivity)
ORDER BY
	occurrence,
	display_term
OPTION (RECOMPILE)
GO


-- ストップワードの確認
SELECT 
	* 
FROM 
	sys.fulltext_system_stopwords 
WHERE 
	language_id = 1041
GO

EXEC sp_help_fulltext_system_components 'all';
EXEC sp_help_fulltext_catalog_components
GO
