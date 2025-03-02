USE tpch
GO
DECLARE @sql_base nvarchar(max) = 'SELECT TOP 1 *,''{0}'', ''{1}'', {2} FROM NATION'

DECLARE @sql nvarchar(max)
SET @sql = REPLACE(@sql_base, '{0}', REPLICATE('A', 1000))
SET @sql = REPLACE(@sql, '{1}', NEWID())
SET @sql = REPLACE(@sql, '{2}', @@spid)

EXECUTE (@sql)


