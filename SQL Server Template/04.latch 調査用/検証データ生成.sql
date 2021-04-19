USE [TESTDB]
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_LatchTest]
AS
   -- UPDATE pagelatch_test  SET C2 = NEWID() WHERE C1 = @@spid
    -- INSERT INTO pagelatch_test VALUES(NEWID(), NEWID(), NULL)
   INSERT INTO pagelatch_test (C2, C3) VALUES(NEWID(), NULL)
   -- INSERT INTO pagelatch_test DEFAULT VALUES
GO

CREATE PARTITION FUNCTION [pf_hash16] (tinyint) AS RANGE RIGHT 
FOR VALUES (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
GO
CREATE PARTITION SCHEME [ps_hash16] AS PARTITION [pf_hash16] ALL TO ( [PRIMARY] )
GO

DROP TABLE IF EXISTS  pagelatch_test
GO


CREATE TABLE pagelatch_test(
    C1 int IDENTITY NOT NULL, 
    C2 varchar(36) NOT NULL, 
    C3 char(100), 
    C4 tinyint NOT NULL DEFAULT  CAST(RAND() * 100 AS tinyint) % 4)
GO

ALTER TABLE pagelatch_test 
ADD CONSTRAINT PK_pagelatch_test PRIMARY KEY CLUSTERED(C1 ASC) 
ON [PRIMARY]

CREATE INDEX NCIX_page_latch_test ON pagelatch_test(C2)

TRUNCATE TABLE pagelatch_test
GO

ALTER TABLE pagelatch_test
DROP CONSTRAINT PK_pagelatch_test

CREATE CLUSTERED INDEX NCIX_pagelatch_test ON pagelatch_test(C2)
GO

ALTER TABLE pagelatch_test 
ADD CONSTRAINT PK_pagelatch_test PRIMARY KEY NONCLUSTERED(C1 ASC) 
ON [PRIMARY]




SELECT COUNT(*) FROM pagelatch_test

CREATE TABLE pagelatch_test(C1 uniqueidentifier NOT NULL DEFAULT NEWID(), C2 varchar(36), C3 char(100), C4 tinyint NOT NULL DEFAULT  CAST(RAND() * 100 AS tinyint) % 4)
GO


CREATE TABLE pagelatch_test(C1 uniqueidentifier NOT NULL DEFAULT NEWSEQUENTIALID(), C2 varchar(36), C3 char(100),C4 tinyint NOT NULL DEFAULT  CAST(RAND() * 100 AS tinyint) % 4)
GO




ALTER TABLE pagelatch_test ADD CONSTRAINT PK_pagelatch_test PRIMARY KEY CLUSTERED(C1 ASC, C4) 
ON ps_hash16(C4)


ALTER TABLE [dbo].pagelatch_test
ADD [HashValue] AS (CONVERT([tinyint], abs(binary_checksum(c1)%(16)),(0))) PERSISTED NOT NULL


ALTER TABLE pagelatch_test 
ADD CONSTRAINT PK_pagelatch_test PRIMARY KEY CLUSTERED(C1 ASC, [HashValue]) 
ON ps_hash16(HashValue)

ALTER TABLE pagelatch_test DROP CONSTRAINT PK_pagelatch_test


SELECT COUNT(*) FROM pagelatch_test

SELECT * FROM sys.partitions WHERE object_id = OBJECt_ID('pagelatch_test')

*/