DECLARE @TableName nvarchar(max) = N'LINEITEM'
DECLARE @outputPath nvarchar(max) = 'E:\work\bcp'

DECLARE @baseQueryTemplate nvarchar(max) = N'SELECT * FROM [{0}] WHERE {1} ORDER BY {2}'
DECLARE @bcpTemplate nvarchar(max) = N'bcp "{0}" queryout "{1}\{2}.{3}.bcp" -c -C "65001" -T -d {4}'
DECLARE @maxDataTemplate nvarchar(max) = N'SELECT MAX({0}) AS max_data FROM [{1}]'

DECLARE @splitCount int = 100000000

DECLARE @FirstKeyColumn nvarchar(max) = (
    SELECT TOP 1
        '[' + c.name + ']'
    FROM 
        sys.key_constraints AS kc
        INNER JOIN sys.indexes AS i ON i.name = kc.name
        INNER JOIN sys.index_columns AS ic on ic.object_id = i.object_id AND ic.index_id = i.index_id
        INNER JOIN sys.columns AS c on c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE
        OBJECT_NAME(kc.parent_object_id) = @tableName
    ORDER BY 
        ic.key_ordinal ASC
)

DECLARE @OrderSetting nvarchar(max) = (
    SELECT
        STUFF(OrderSetting,LEN(OrderSetting),1,'')
    FROM
    (
        SELECT 
            '[' + c.name + '] ASC, '
        FROM 
            sys.key_constraints AS kc
            INNER JOIN sys.indexes AS i ON i.name = kc.name
            INNER JOIN sys.index_columns AS ic on ic.object_id = i.object_id AND ic.index_id = i.index_id
            INNER JOIN sys.columns AS c on c.object_id = ic.object_id AND c.column_id = ic.column_id
        WHERE
            OBJECT_NAME(kc.parent_object_id) = @tableName
        ORDER BY 
            ic.key_ordinal ASC
        FOR XML PATH('')
    ) AS T(OrderSetting)
)

DECLARE @dateCountQuery nvarchar(max) = REPLACE(@maxDataTemplate, '{0}', @FirstKeyColumn)
SET @dateCountQuery = REPLACE(@dateCountQuery, '{1}', @TableName)
DECLARE @maxResults TABLE(max_data bigint)
INSERT INTO @maxResults EXECUTE(@dateCountQuery)
DECLARE @dataCount bigint = (SELECT  TOP 1 max_data FROM @maxResults)


DECLARE @baseQuery nvarchar(max) = REPLACE(@baseQueryTemplate, '{0}', @TableName)
SET @baseQuery = REPLACE(@baseQuery, '{2}', @OrderSetting)


DECLARE @bcp nvarchar(max) = REPLACE(@bcpTemplate, '{1}', @outputPath)
SET @bcp = REPLACE(@bcp, '{2}', @TableName)
SET @bcp = REPLACE(@bcp, '{4}', DB_NAME())

PRINT 'FirstKeyColumn : ' + @FirstKeyColumn
PRINT 'OrderSetting : ' + @OrderSetting
PRINT 'dataCount : ' + CAST(@dataCount AS nvarchar(100))

DECLARE @tbl TABLE (query nvarchar(max))

DECLARE @loopCount int = 1
DECLARE @targetCount int = 0

WHILE(@targetCount <= @dataCount)
BEGIN
    DECLARE @sql nvarchar(max) = ''
    IF(@loopCount = 1)
    BEGIN
        SET @sql =  REPLACE(@baseQuery, '{1}', @FirstKeyColumn + ' < ' +  CAST(@targetCount + @splitCount AS nvarchar(100)))
    END
    ELSE
    BEGIN
        SET @sql =  REPLACE(@baseQuery, '{1}', @FirstKeyColumn + ' >= ' +  CAST(@targetCount AS nvarchar(100)) + ' AND ' +  @FirstKeyColumn + ' < ' +  CAST(@targetCount + @splitCount AS nvarchar(100)))
    END
    INSERT INTO @tbl VALUES(REPLACE(REPLACE(@bcp, '{0}', @sql), '{3}', @loopCount))

    SET @loopCount += 1
    SET @targetCount += @splitCount
END

SELECT * FROM @tbl