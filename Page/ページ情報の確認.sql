SET NOCOUNT ON
GO
-- テスト用のテーブル作成
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

/********************************************************************************************************/
-- データからページ番号を取得する
-- ページ番号が正しくない場合、sys.dm_os_buffer_descriptors から情報を取得する
DBCC DROPCLEANBUFFERS
GO

SELECT * FROM T1 CROSS APPLY sys.fn_PhysLocCracker(%%physloc%%) WHERE C1 BETWEEN 1 AND  200000
SELECT * FROM T2 CROSS APPLY sys.fn_PhysLocCracker(%%physloc%%) WHERE C1 BETWEEN 1 AND  200000
GO
/********************************************************************************************************/


/********************************************************************************************************/
-- fn_PhysLocCracker から正しいページ番号を取得できなかった場合、キャッシュの情報から取得することも可能
SELECT   
	db_name(database_id) AS Database_name,  
	OBJECT_NAME(p.object_id) AS object_name,  
	p.partition_number,
	i.index_id,
	i.name,
	au.total_pages,
	au.data_pages,
	au.used_pages,
	p.rows,
	bd.page_id,
	p.partition_number,
	bd.page_type,
	p.data_compression_desc,
	au.type_desc,
	bd.page_level,
	bd.row_count
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
	LEFT JOIN
		sys.indexes i WITH (NOLOCK)
	ON
		p.object_id = i.object_id
		AND
		p.index_id = i.index_id
WHERE  
	database_id = DB_ID()  
	AND
	OBJECT_SCHEMA_NAME(p.object_id) <> 'sys'
	AND
	OBJECT_NAME(p.object_id) IN('T1', 'T2')
ORDER BY
	object_name,
	page_type,
	page_id,
	page_level
GO
/********************************************************************************************************/


/********************************************************************************************************/
-- DMV から割り当てページを確認
SELECT 
	DB_NAME(pa.database_id) AS database_name,
	OBJECT_NAME(pa.object_id) AS object_name,
	i.name,
	pa.partition_id,
	pa.allocated_page_file_id,
	pa.extent_page_id,
	pa.allocated_page_page_id,
	pa.allocation_unit_type_desc,
	pa.page_free_space_percent,
	pa.is_page_compressed,
	pa.allocated_page_iam_page_id,
	pa.rowset_id,
	pa.allocation_unit_id,
	pa.is_iam_page,
	pa.is_mixed_page_allocation,
	pa.next_page_file_id,
	pa.next_page_page_id,
	pa.previous_page_file_id,
	pa.previous_page_page_id

FROM 
	sys.dm_db_database_page_allocations(
		DB_ID(), 
		OBJECT_ID('T1'), 
		NULL, -- index_id
		NULL, -- partition_id
		'DETAILED' -- 'LIMITED'
	) pa
	INNER JOIN
	sys.indexes i
	ON
	i.object_id = pa.object_id
	AND
	i.index_id = pa.index_id
/********************************************************************************************************/

-- ページの実情報の確認
DBCC TRACEON(3604)
DBCC PAGE(N'TESTDB', 1, 360, 3) WITH TABLERESULTS
GO
