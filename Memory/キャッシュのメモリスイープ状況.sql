SELECT 
	name, 
	type, 
	clock_hand,
	clock_status ,
	SUM(rounds_count) AS rounds_count,
	SUM(removed_all_rounds_count) AS removed_all_rounds_count,
	SUM(updated_last_round_count) AS updated_last_round_count,
	SUM(removed_last_round_count) AS removed_last_round_count,
	SUM(last_tick_time) AS last_tick_time,
	SUM(round_start_time) AS round_start_time,
	SUM(last_round_start_time) AS last_round_start_time
FROM 
	sys.dm_os_memory_cache_clock_hands 
WHERE
	type <> 'USERSTORE_TOKENPERM'
GROUP BY
	name, type, clock_hand,clock_status
ORDER BY 
	removed_all_rounds_count desc, type, name, clock_hand,clock_status

GO

-- PIVOT を使用した時系列データの取得
DECLARE @baseSql nvarchar(max) = '
SELECT
	GETDATE() AS collect_date,
	*
FROM(
	SELECT 
		name, 
		SUM(removed_all_rounds_count) AS removed_all_rounds_count
	FROM 
		sys.dm_os_memory_cache_clock_hands 
	WHERE
		type IN(''USERSTORE_DBMETADATA'',''CACHESTORE_OBJCP'', ''CACHESTORE_SQLCP'')
		AND clock_hand = ''HAND_EXTERNAL''
	GROUP BY
		name, type, clock_hand,clock_status
) AS T
PIVOT(
	MAX(removed_all_rounds_count)
	FOR name IN ({0})
) AS P
'

DECLARE @pivotColumn nvarchar(max) = (
SELECT
	SUBSTRING(name, 1, LEN(name) -1) AS name
FROM
(
	SELECT 
		'[' + name + '],'
	FROM 
		sys.dm_os_memory_cache_clock_hands 
	WHERE
		type IN('USERSTORE_DBMETADATA','CACHESTORE_OBJCP', 'CACHESTORE_SQLCP')
		AND clock_hand = 'HAND_EXTERNAL'
	FOR XML PATH('')
) AS T(name)
)
DECLARE @sql nvarchar(max) = (SELECT REPLACE(@baseSql, '{0}', @pivotColumn))
PRINT @sql
EXECUTE(@sql)