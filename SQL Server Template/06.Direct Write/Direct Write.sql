SELECT 
    p.index_id,
    p.rows,
    iau.allocation_unit_id,
    iau.total_pages,
    iau.used_pages,
    first_page,
    CAST(
    CONVERT(
        varbinary(2), 
        '0x' + 
        SUBSTRING(CONVERT(varchar(14), iau.first_page, 1), 13,2) + 
        SUBSTRING(CONVERT(varchar(14), iau.first_page, 1), 11,2),
        1
    ) AS int) AS file_id,
    CAST(
    CONVERT(
        varbinary(4), 
        '0x' + 
        SUBSTRING(CONVERT(varchar(14), iau.first_page, 1), 9,2) + 
        SUBSTRING(CONVERT(varchar(14), iau.first_page, 1), 7,2) +  
        SUBSTRING(CONVERT(varchar(14), iau.first_page, 1), 5,2) +  
        SUBSTRING(CONVERT(varchar(14), iau.first_page, 1), 3,2),
        1
    ) AS int) AS page_id,
    iau.root_page,
    iau.first_iam_page
FROM 
    sys.partitions AS p
    INNER JOIN sys.system_internals_allocation_units AS iau
        ON iau.container_id = p.hobt_id
WHERE 
    p.object_id = OBJECT_ID('DirectWrite')
GO

SELECT * FROM sys.dm_os_buffer_descriptors WHERE allocation_unit_id  = 72057594094944256
GO

DBCC TRACEON(3604)
DBCC PAGE('TESTDB', 1, 569472, 3)
GO


DBCC DROPCLEANBUFFERS

-- ALTER DATABASE TESTDB SET SINGLE_USER
DBCC TRACEON(2588) WITH NO_INFOMSGS
DBCC WRITEPAGE ('TESTDB', 1, 569472, 185, 2,0x3136, 0)
DBCC WRITEPAGE ('TESTDB', 1, 569472, 185, 2,0x3038, 0)
-- ALTER DATABASE TESTDB SET MULTI_USER

SELECT * FROM DirectWrite OUTER APPLY sys.fn_PhysLocCracker(%%physloc%%)

CHECKPOINT
SELECT * FROM sys.fn_dblog(NULL, NULL)

CHECKPOINT
DBCC DROPCLEANBUFFERS
SELECT * FROM DirectWrite OUTER APPLY sys.fn_PhysLocCracker(%%physloc%%)

-- bstat : 0x09 -> 0x0b 