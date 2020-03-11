DECLARE @target_fragment int = 0
DECLARE index_info CURSOR LOCAL FAST_FORWARD
FOR
    select 
        OBJECT_SCHEMA_NAME(i.object_id) AS schema_name,
        object_name(i.object_id) AS object_name,
        i.name
    from sys.indexes as i
        outer apply sys.dm_db_index_physical_stats(db_id(), i.object_id, i.index_id,0, 'LIMITED') AS ps
    where 
        OBJECT_SCHEMA_NAME(i.object_id) <> 'sys' 
        and i.is_disabled = 0
        and ps.avg_fragmentation_in_percent >= @target_fragment
    order by 
        ps.avg_fragmentation_in_percent desc

DECLARE @schema_name sysname, @object_name sysname, @index_name sysname
DECLARE @base_sql nvarchar(max) = N'ALTER INDEX [{0}] ON [{1}].[{2}] REBUILD WITH(ONLINE=ON, RESUMABLE=ON)'
DECLARE @sql nvarchar(max)


OPEN index_info
FETCH NEXT FROM index_info
INTO @schema_name, @object_name, @index_name

WHILE @@FETCH_STATUS = 0
BEGIN

    SET @sql = REPLACE(REPLACE(REPLACE(@base_sql, '{0}', @index_name), '{1}', @schema_name), '{2}', @object_name)
    RAISERROR(@sql, 0, 0) WITH NOWAIT
    EXECUTE(@sql)
    FETCH NEXT FROM index_info
    INTO @schema_name, @object_name, @index_name
END
CLOSE index_info
DEALLOCATE index_info

