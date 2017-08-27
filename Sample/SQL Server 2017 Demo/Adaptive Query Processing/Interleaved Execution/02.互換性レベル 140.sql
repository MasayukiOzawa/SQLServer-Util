-- 互換性レベル 140 の場合、MSTVF の予測行数がパラメーターに合わせて最適化されている
-- (MSTVF のテーブルスキャンで正しい基数推定が反映されるようになっている)
-- これにより、データ数に応じた適切な実行プランの選択が行われるようになる
USE [tpch]
GO

ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 140
GO
DBCC FREEPROCCACHE
GO
EXEC sp_executesql 
N'SELECT COUNT(*) FROM fn_MSTVF(@param1, @param2)',
N'@param1 date, @param2 date',
@param1 = '1997-12-05',
@param2 = '1997-12-06'
GO