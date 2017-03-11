IF DB_ID('DemoDB') IS NULL
	CREATE DATABASE DemoDB
GO


USE DemoDB
GO

-- クエリーストアの有効化
ALTER DATABASE [DemoDB] SET QUERY_STORE = ON
GO

ALTER DATABASE DemoDB 
SET QUERY_STORE 
(DATA_FLUSH_INTERVAL_SECONDS = 300, INTERVAL_LENGTH_MINUTES = 15)
GO




-- クエリーストアのデータ初期化
ALTER DATABASE DemoDB SET QUERY_STORE CLEAR ALL


-- テスト用テーブルの作成
IF OBJECT_ID('QueryStore') IS NOT NULL
    DROP TABLE QueryStore

 CREATE TABLE dbo.QueryStore
    (
    Col1 int NOT NULL IDENTITY (1, 1),
    Col2 uniqueidentifier NULL,
    Col3 uniqueidentifier NULL
    )  ON [PRIMARY]
GO

SET NOCOUNT ON
GO

-- テスト用データの投入
DECLARE @cnt int = 1
BEGIN TRAN
WHILE (@cnt <= 100000)
BEGIN
    INSERT INTO QueryStore (Col2, Col3) VALUES(NEWID(), NEWID())
    SET @cnt += 1
 
    IF (@@TRANCOUNT % 40000 = 0)
    BEGIN
        COMMIT TRAN
        BEGIN TRAN
    END
END
IF @@TRANCOUNT > 0
    COMMIT TRAN
