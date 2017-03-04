USE DemoDB
GO

IF OBJECT_ID('dbo.sample_memoryoptimizedtable','U') IS NOT NULL
    DROP TABLE dbo.sample_memoryoptimizedtable
GO

CREATE TABLE dbo.sample_memoryoptimizedtable
(
	c1 int NOT NULL, 
	c2 float NOT NULL,
	c3 decimal(10,2) NOT NULL INDEX index_sample_memoryoptimizedtable_c3 NONCLUSTERED (c3), 
	c4 int
   CONSTRAINT PK_sample_memoryoptimizedtable PRIMARY KEY NONCLUSTERED (c1),
   INDEX hash_index_sample_memoryoptimizedtable_c2 HASH (c2) WITH (BUCKET_COUNT = 131072)
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO

ALTER TABLE sample_memoryoptimizedtable ALTER COLUMN c4 bigint
ALTER TABLE sample_memoryoptimizedtable ADD c5 int

ALTER TABLE sample_memoryoptimizedtable ALTER INDEX hash_index_sample_memoryoptimizedtable_c2 REBUILD WITH (BUCKET_COUNT = 200000)
ALTER TABLE sample_memoryoptimizedtable  ADD INDEX nonclustered_c2 (c2, c3)
