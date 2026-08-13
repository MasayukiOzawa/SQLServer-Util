SET NOCOUNT ON;

DECLARE
    @No        int = 11,
    @MaxNo     int = 100,
    @TableName sysname,
    @Sql       nvarchar(max),
    @Rows      int,
    @SPID      int = @@SPID,
    @Msg       nvarchar(2047);

WHILE @No <= @MaxNo
BEGIN
    -- 011 ～ 100 形式
    SET @TableName = N'LINEITEM_' + RIGHT(N'000' + CONVERT(nvarchar(3), @No), 3);

    IF OBJECT_ID(N'dbo.' + @TableName, N'U') IS NULL
    BEGIN
        SET @Msg = CONCAT(N'スキップ（存在しない）: ', @TableName);
        RAISERROR(N'%s', 0, 1, @Msg) WITH NOWAIT;
    END
    ELSE
    BEGIN
        SET @Sql = N'
UPDATE ' + QUOTENAME(N'dbo') + N'.' + QUOTENAME(@TableName) + N'
SET [L_COMMENT] = CONVERT(varchar(36), NEWID())
WHERE [L_ORDERKEY] IN
(
    @SPID,
    @SPID + 1000,
    @SPID + 2000,
    @SPID + 3000
);

SET @Rows = @@ROWCOUNT;
';

        SET @Rows = 0;

        EXEC sys.sp_executesql
            @Sql,
            N'@SPID int, @Rows int OUTPUT',
            @SPID = @SPID,
            @Rows = @Rows OUTPUT;

        SET @Msg = CONCAT(@TableName, N' 更新行数 = ', @Rows);
        RAISERROR(N'%s', 0, 1, @Msg) WITH NOWAIT;
    END;

    SET @No += 1;
END;