﻿USE DemoDB
GO

DROP TABLE IF EXISTS TRIGGER_TEST

CREATE TABLE [dbo].[TRIGGER_TEST](
	[TRG_Col1] int PRIMARY KEY NONCLUSTERED 
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY)
GO

CREATE TRIGGER TRG_TEST_AFTER
ON dbo.[TRIGGER_TEST]
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AFTER INSERT, UPDATE 
AS
BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'Japanese')
ROLLBACK TRAN
END


CREATE TRIGGER TRG_TEST_FOR
ON dbo.[TRIGGER_TEST]
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
FOR  INSERT, UPDATE 
AS
BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = N'Japanese')
ROLLBACK TRAN
END
