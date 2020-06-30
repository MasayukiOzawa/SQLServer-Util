SELECT
    OBJECT_NAME(dps.object_id) AS object_name,
    i.name AS index_name,
    dps.used_page_count * 8.0 / 1024 AS used_page_MB,
    dps.reserved_page_count * 8.0 / 1024 AS reserved_page_MB,
    dps.row_count
FROM
    sys.dm_db_partition_stats AS dps
    LEFT JOIN sys.indexes as i
        ON i.object_id = dps.object_id
            AND i.index_id = dps.index_id
WHERE
    OBJECT_NAME(dps.object_id) like 'dump[_]%'
ORDER BY
    dps.object_id,
    i.index_id