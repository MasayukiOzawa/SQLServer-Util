-- 互換性レベル 130 は予測行数は固定行数が使用されている
USE [tpch]
GO

ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130
GO

DBCC FREEPROCCACHE
GO
EXEC sp_executesql 
N'SELECT COUNT(*) FROM fn_MSTVF(@param1, @param2)',
N'@param1 date, @param2 date',
@param1 = '1997-12-05',
@param2 = '1997-12-06'
GO
