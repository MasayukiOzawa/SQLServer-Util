use tpch;
DECLARE @table_name varchar(255) = 'LINEITEM'
DECLARE @stats_id varchar(5) = 4
DECLARE @pvt varchar(max) = (
    SELECT STUFF(C1,1, 2,'') + ']'
    FROM
    (
    SELECT 
        DISTINCT 
        '],[' + REPLACE(REPLACE(CAST(range_high_key AS varchar(1000)), CHAR(10),''), CHAR(13), '')
    from 
        sys.dm_db_stats_histogram(object_id(@table_name), CAST(@stats_id AS int)) 
    FOR XML PATH('')
    ) AS T(C1)
)

DECLARE @sql nvarchar(max) = N'
SELECT
    *
FROM
(
    select 
        REPLACE(REPLACE(CAST(range_high_key AS varchar(1000)), CHAR(10),''''), CHAR(13), '''') AS range_high_key, 
        range_rows
    from 
        sys.dm_db_stats_histogram(object_id(''' + @table_name + '''),' +  @stats_id + ') 
) AS T
PIVOT(
    MAX(range_rows)
    FOR range_high_key IN(' + @pvt + ')
) AS PVT
'

EXECUTE (@sql)