DROP TABLE IF EXISTS system_health_dump
GO
DECLARE @file_path sysname = 'D:\Work\system_health*.xel'

SELECT * INTO system_health_dump FROM sys.fn_xe_file_target_read_file (@file_path, NULL, NULL, NULL)
GO

DECLARE @pvt varchar(max) = (
    SELECT STUFF(C1,1, 2,'') + ']'
    FROM
    (
    SELECT 
        DISTINCT 
        '],[' + object_name
    FROM 
        system_health_dump
	ORDER BY 1
    FOR XML PATH('')
    ) AS T(C1)
)


DECLARE @sql nvarchar(max) = N'
SELECT
    *
FROM
(
    select
		DATE_BUCKET(mi, 5, DATEADD(hh,9, timestamp_utc)) AS timestamp_jst,
		file_name,
        object_name,
		COUNT(*) AS cnt
    from 
        system_health_dump
	GROUP BY
		DATE_BUCKET(mi, 5, DATEADD(hh,9, timestamp_utc)),file_name, object_name
) AS T
PIVOT(
    SUM(cnt)
    FOR object_name IN(' + @pvt + ')
) AS PVT
ORDER BY 1 
'

EXEC (@sql)