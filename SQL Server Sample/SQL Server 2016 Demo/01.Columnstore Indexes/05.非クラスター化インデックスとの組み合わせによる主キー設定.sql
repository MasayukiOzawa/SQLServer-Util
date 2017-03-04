USE DemoDB
GO

IF OBJECT_ID('CCITable', 'U') IS NOT NULL
	DROP TABLE CCITable

CREATE TABLE CCITable( 
Col1 int PRIMARY KEY NONCLUSTERED, 
Col2 uniqueidentifier, 
Col3 uniqueidentifier, 
Col4 uniqueidentifier, 
Col5 uniqueidentifier 
) 
GO 
CREATE CLUSTERED COLUMNSTORE INDEX CCIX_CCITable ON CCITable 
