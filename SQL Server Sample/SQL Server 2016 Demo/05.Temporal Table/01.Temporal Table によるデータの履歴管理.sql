USE DemoDB
GO

-- テストデータの確認
INSERT INTO TemporalTable (Col2, Col3, Col4) 
VALUES(NEWID(), NEWID(), N'AAAAAA'), 
(NEWID(), NEWID(), N'AAAAAA'), 
(NEWID(), NEWID(), N'AAAAAA'), 
(NEWID(), NEWID(), N'AAAAAA')

WAITFOR DELAY '00:00:01'

BEGIN TRAN
INSERT INTO TemporalTable (Col2, Col3, Col4) VALUES (NEWID(), NEWID(), N'AAAAAA')
INSERT INTO TemporalTable (Col2, Col3, Col4) VALUES (NEWID(), NEWID(), N'AAAAAA')
COMMIT TRAN

WAITFOR DELAY '00:00:01'

BEGIN TRAN
INSERT INTO TemporalTable (Col2, Col3, Col4) VALUES (NEWID(), NEWID(), N'AAAAAA')
INSERT INTO TemporalTable (Col2, Col3, Col4) VALUES (NEWID(), NEWID(), N'AAAAAA')
COMMIT TRAN

WAITFOR DELAY '00:00:01'

-- データの確認
SELECT * FROM TemporalTable

-- データの変更
UPDATE [dbo].[TemporalTable] SET Col4 = 'BBBBBB' WHERE Col1 BETWEEN 3 AND 5

-- データの確認
SELECT * FROM TemporalTable

-- 履歴を含めてデータを検索
DECLARE @StartTime datetime2 = (SELECT SysStartTime FROM TemporalTable WHERE Col1 = (SELECT MAX(Col1) FROM TemporalTable))

SELECT * FROM TemporalTable
FOR SYSTEM_TIME BETWEEN '2015-06-22' AND @StartTime
ORDER BY Col1

-- 全期間のデータを検索
SELECT * FROM TemporalTable
FOR SYSTEM_TIME ALL

SELECT *,SysStartTime,SysEndTime FROM TemporalTable
FOR SYSTEM_TIME ALL
