SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID(N'dbo.LINEITEM', N'U') IS NULL
BEGIN
    THROW 50000, N'dbo.LINEITEM が存在しません。', 1;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.change_tracking_databases
    WHERE database_id = DB_ID()
)
BEGIN
    THROW 50001, N'現在のデータベースで変更の追跡が有効化されていません。', 1;
END;

DROP TABLE IF EXISTS #LineItemSource;

-- 全評価用テーブルへ同じデータを投入するため、元データは一度だけ取得する。
SELECT TOP (10000)
    *
INTO #LineItemSource
FROM dbo.LINEITEM
ORDER BY
    L_ORDERKEY,
    L_LINENUMBER;

DECLARE
    @No             int = 11,
    @MaxNo          int = 100,
    @TableName      sysname,
    @ConstraintName sysname,
    @Sql            nvarchar(max),
    @Rows           int,
    @Msg            nvarchar(2047);

BEGIN TRY
    BEGIN TRANSACTION;

    WHILE @No <= @MaxNo
    BEGIN
        SET @TableName = N'LINEITEM_' + RIGHT(N'000' + CONVERT(nvarchar(3), @No), 3);
        SET @ConstraintName = N'PK_' + @TableName;

        SET @Sql = N'
DROP TABLE IF EXISTS ' + QUOTENAME(N'dbo') + N'.' + QUOTENAME(@TableName) + N';

SELECT *
INTO ' + QUOTENAME(N'dbo') + N'.' + QUOTENAME(@TableName) + N'
FROM #LineItemSource;

SET @Rows = @@ROWCOUNT;

ALTER TABLE ' + QUOTENAME(N'dbo') + N'.' + QUOTENAME(@TableName) + N'
ADD CONSTRAINT ' + QUOTENAME(@ConstraintName) + N'
PRIMARY KEY (L_ORDERKEY, L_LINENUMBER);

ALTER TABLE ' + QUOTENAME(N'dbo') + N'.' + QUOTENAME(@TableName) + N'
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = OFF);
';

        SET @Rows = 0;

        EXEC sys.sp_executesql
            @Sql,
            N'@Rows int OUTPUT',
            @Rows = @Rows OUTPUT;

        SET @Msg = CONCAT(@TableName, N' を作成しました。初期データ件数 = ', @Rows);
        RAISERROR(N'%s', 0, 1, @Msg) WITH NOWAIT;

        SET @No += 1;
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    THROW;
END CATCH;
