USE [WideWorldImportersDW]
GO
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130
GO

EXEC sp_executesql
N'SELECT  [fo].[Order Key], [si].[Lead Time Days], [fo].[Quantity]
FROM    [Fact].[Order] AS [fo]
INNER JOIN [Dimension].[Stock Item] AS [si]
       ON [fo].[Stock Item Key] = [si].[Stock Item Key]
WHERE   [fo].[Quantity] =@param1',
N'@param1 int',
@param1 = 360
GO

EXEC sp_executesql
N'SELECT  [fo].[Order Key], [si].[Lead Time Days], [fo].[Quantity]
FROM    [Fact].[Order] AS [fo]
INNER JOIN [Dimension].[Stock Item] AS [si]
       ON [fo].[Stock Item Key] = [si].[Stock Item Key]
WHERE   [fo].[Quantity] =@param1',
N'@param1 int',
@param1 = 361
GO
