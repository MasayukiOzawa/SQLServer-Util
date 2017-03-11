USE DemoDB
GO
DBCC DROPCLEANBUFFERS
GO

-- セッション A で実行
BEGIN TRAN
SELECT * FROM LiveQueryStats  WITH(XLOCK) WHERE Col1 = 99984
ROLLBACK TRAN

-- セッション B で Live Query Stats を有効にして実行
SELECT COUNT(*) FROM LiveQueryStats
