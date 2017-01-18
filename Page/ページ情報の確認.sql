SET NOCOUNT ON
GO
DROP TABLE IF EXISTS T1
DROP TABLE IF EXISTS T2
GO

CREATE TABLE T1 (
C1 int  ,C2 uniqueidentifier, C3 nchar(100),
CONSTRAINT  PK_T1 PRIMARY KEY (C1)
)
WITH (DATA_COMPRESSION = PAGE)

CREATE TABLE T2 (
C1 int , C2 uniqueidentifier, C3 nchar(100),
CONSTRAINT  PK_T2 PRIMARY KEY (C1)
)
WITH (DATA_COMPRESSION = PAGE)
GO

DECLARE @id uniqueidentifier
DECLARE @cnt int = 1
DECLARE @char nchar(100) = REPLICATE('A', 100)

WHILE (@cnt <= 300000000)
BEGIN
	IF @@TRANCOUNT = 0 
	BEGIN 
		BEGIN TRAN
	END

	SET @id = NEWID()
	INSERT INTO T1 VALUES (@cnt, @id, @char)
	INSERT INTO T2 VALUES (@cnt, @id, @char)

	IF @@TRANCOUNT % 10000 = 0
	BEGIN
		COMMIT TRAN
		BEGIN TRAN
	END
	SET @cnt += 500
END

IF @@TRANCOUNT > 0 
BEGIN
	COMMIT TRAN
END
GO

ALTER TABLE T1 REBUILD
ALTER TABLE T2 REBUILD
GO

CHECKPOINT
GO

DBCC DROPCLEANBUFFERS
GO
SELECT * FROM T1 CROSS APPLY sys.fn_PhysLocCracker(%%physloc%%) 
SELECT * FROM T2 CROSS APPLY sys.fn_PhysLocCracker(%%physloc%%) 
GO

SELECT   
	db_name(database_id) AS Database_name,  
	OBJECT_NAME(p.object_id) AS object_name,  
	p.index_id,
	page_id,  
	p.partition_number,
	page_type,
	type_Desc,
	row_count,
	page_level,
	total_pages,
	data_pages
FROM  
	sys.dm_os_buffer_descriptors bd WITH (NOLOCK)  
	LEFT JOIN   
		sys.allocation_units au WITH (NOLOCK)  
	ON  
		bd.allocation_unit_id = au.allocation_unit_id  
	LEFT JOIN  
		sys.partitions p WITH (NOLOCK)  
	ON  
		p.hobt_id = au.container_id  
WHERE  
	database_id = DB_ID()  
	AND
	OBJECT_SCHEMA_NAME(p.object_id) <> 'sys'
	AND
	OBJECT_NAME(p.object_id) IN('T1', 'T2')
ORDER BY
	object_name,
	page_type,
	page_id
GO

DBCC TRACEON(3604)
DBCC PAGE(N'TESTDB', 1, 360, 3) WITH TABLERESULTS
GO
