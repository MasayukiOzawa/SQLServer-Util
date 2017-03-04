USE DemoDB
GO

IF OBJECT_ID('CCITable', 'U') IS NOT NULL
	DROP TABLE CCITable

-- SQL Server 2014 での記述方法
CREATE TABLE CCITable( 
Col1 int, 
Col2 uniqueidentifier, 
Col3 uniqueidentifier, 
Col4 uniqueidentifier, 
Col5 uniqueidentifier 
) 
GO 
CREATE CLUSTERED COLUMNSTORE INDEX CCIX_CCITable ON CCITable 



IF OBJECT_ID('CCITable', 'U') IS NOT NULL
	DROP TABLE CCITable


-- インラインで列ストアインデックスを作成 
CREATE TABLE CCITable( 
Col1 int, 
Col2 uniqueidentifier, 
Col3 uniqueidentifier, 
Col4 uniqueidentifier, 
Col5 uniqueidentifier, 
INDEX CCIX_CCITable CLUSTERED COLUMNSTORE 
) 
