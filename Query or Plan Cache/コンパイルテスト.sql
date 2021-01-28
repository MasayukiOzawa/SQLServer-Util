SET STATISTICS TIME OFF;
DBCC FREEPROCCACHE;
DROP TABLE IF EXISTS CompileTest
GO

-- テスト用のテーブルの作成
DECLARE @columnCount int = 1
DECLARE @columnCountLimit int = 400
DECLARE @columnList nvarchar(max) = ''
DECLARE @createTable nvarchar(max) = N'CREATE TABLE CompileTest ({0})'

WHILE(@columnCount <= @columnCountLimit)
BEGIN
    SET @columnList = @columnList + N'C' + CAST(@columnCount AS nvarchar(3)) + N' int,'
    SET @columnCount += 1
END
SET @columnList = STUFF(@columnList,LEN(@columnList), 1,'')
SET @createTable  = REPLACE(@createTable ,'{0}', @columnList)

EXEC(@createTable)

-- データ挿入用のクエリの作成
DECLARE @valueList nvarchar(max) = ''

SET @columnCount = 1
DECLARE @rowCount int = 1
DECLARE @insertRows nvarchar(max) = N'INSERT INTO CompileTest VALUES'

WHILE(@columnCount <= @columnCountLimit)
BEGIN
    SET @valueList = @valueList + CAST(@columnCount AS nvarchar(3)) + N','
    SET @columnCount+=1
END
SET @valueList = STUFF(@valueList,LEN(@valueList), 1,'')

WHILE(@rowCount <= 1000)
BEGIN
    IF @rowCount = 1
    BEGIN
        SET @insertRows = @insertRows + N'(' + @valueList + ')'
    END
    ELSE
    BEGIN
        SET @insertRows = @insertRows + CHAR(13) + CHAR(10) + N',(' + @valueList + ')'
    END
    SET @rowCount += 1
END

SET STATISTICS TIME ON;
EXEC(@insertRows)
