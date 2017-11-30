SET NOCOUNT ON
DROP TABLE IF EXISTS BlobTable
CREATE TABLE BlobTable (Filename nvarchar(255), Data varbinary(max))
Truncate Table BlobTable
GO
  
DECLARE @blob varbinary(max)
  
SELECT @blob = (SELECT * FROM OPENROWSET(BULK N'C:\Scripts\Target.png', SINGLE_BLOB) as tmp)
INSERT INTO BlobTable VALUES('Target.png', @blob)
