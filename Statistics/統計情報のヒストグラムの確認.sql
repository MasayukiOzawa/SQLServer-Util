SET NOCOUNT ON
GO

DECLARE @stats TABLE(
	RANGE_HI_KEY sql_variant,
	RANGE_ROWS real,
	EQ_ROWS real,
	DISTINCT_RANGE_ROWS	bigint,
	AVG_RANGE_ROWS real
)
DECLARE @results TABLE(
	object_name sysname,
	stats_name sysname,
	RANGE_HI_KEY sql_variant,
	RANGE_ROWS real,
	EQ_ROWS real,
	DISTINCT_RANGE_ROWS	bigint,
	AVG_RANGE_ROWS real
)
DECLARE @object_name sysname, @stats_name sysname

DECLARE stats_cursor CURSOR FOR
SELECT 
	OBJECT_SCHEMA_NAME(s.object_id) + '.' + OBJECT_NAME(s.object_id), s.name 
FROM 
	sys.stats AS s
	INNER JOIN
	sys.all_objects o
	ON
	s.object_id = o.object_id
	AND
	o.is_ms_shipped = 0
WHERE
	OBJECTPROPERTY(s.object_id, 'IsSystemTable') =0

OPEN stats_cursor

FETCH NEXT FROM stats_cursor
INTO @object_name, @stats_name

WHILE @@FETCH_STATUS = 0
BEGIN

	INSERT INTO @stats EXEC ('DBCC SHOW_STATISTICS(''' + @object_name + ''', ''' + @stats_name + ''') WITH HISTOGRAM, NO_INFOMSGS')
	INSERT INTO @results SELECT @object_name, @stats_name,* FROM @stats
	DELETE FROM @stats
	FETCH NEXT FROM stats_cursor
	INTO @object_name, @stats_name
END

CLOSE stats_cursor
DEALLOCATE stats_cursor

SELECT * FROM @results


-- SQL Server 2016 SP1 CU2 以降の統計情報のヒストグラム確認
SELECT 
	OBJECT_SCHEMA_NAME(s.object_id) AS schema_name,
	object_name(s.object_id) AS object_name, 
	s.name, 
	sh.step_number,
	sh.range_high_key,
	sh.range_rows,
	sh.equal_rows,
	sh.distinct_range_rows,
	sh.average_range_rows,
	s.auto_created,
	s.user_created,
	s.no_recompute,
	s.has_filter,
	s.filter_definition,
	s.is_temporary,
	s.is_incremental,
	STATS_DATE(s.object_id, s.stats_id) AS stats_date
FROM
	sys.stats s
	cross apply
	sys.dm_db_stats_histogram(object_id, stats_id) AS sh
WHERE
	OBJECTPROPERTY(s.object_id, 'IsSystemTable') =0
ORDER BY
	object_name(s.object_id),
	name,
	step_number,
	range_high_key
