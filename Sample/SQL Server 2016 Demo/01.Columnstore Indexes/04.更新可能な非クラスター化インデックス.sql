USE DemoDB
GO


IF OBJECT_ID('CCITable', 'U') IS NOT NULL
	DROP TABLE CCITable

CREATE TABLE CCITable( 
Col1 int, 
Col2 uniqueidentifier, 
Col3 uniqueidentifier, 
Col4 uniqueidentifier, 
Col5 uniqueidentifier, 
INDEX NCCIX_CCITable NONCLUSTERED COLUMNSTORE (Col1) 
) 
GO 
INSERT INTO CCITable VALUES(1, NEWID(), NEWID(), NEWID() ,NEWID()) 

/*
-- SQL Server 2012 / 2014 で作成する場合の記述方法

IF OBJECT_ID('CCITable', 'U') IS NOT NULL
	DROP TABLE CCITable

CREATE TABLE CCITable( 
Col1 int, 
Col2 uniqueidentifier, 
Col3 uniqueidentifier, 
Col4 uniqueidentifier, 
Col5 uniqueidentifier 
) 
GO 
CREATE NONCLUSTERED COLUMNSTORE INDEX CCIX_CCITable ON CCITable (Col1) 
INSERT INTO CCITable VALUES(1, NEWID(), NEWID(), NEWID() ,NEWID()) 
*/
