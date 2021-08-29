SET NOCOUNT ON
GO

DECLARE @db_id int = DB_ID()
DECLARE @page_id int = 1

DROP TABLE IF EXISTS #page_info

WHILE(@page_id <= 100)
BEGIN
    IF(@page_id = 1)
    BEGIN
        SELECT 
            database_id,
            file_id,
            page_id,
            page_header_version,
            page_type,
            page_type_desc,
            object_id,
            object_name(object_id) AS object_name
        INTO #page_info
        FROM 
            sys.dm_db_page_info(@db_id, 1, @page_id, 'DETAILED')
    END
    ELSE
    BEGIN
        INSERT INTO #page_info
        SELECT 
            database_id,
            file_id,
            page_id,
            page_header_version,
            page_type,
            page_type_desc,
            object_id,
            object_name(object_id) AS object_name
        FROM 
            sys.dm_db_page_info(@db_id, 1, @page_id, 'DETAILED')
    END
    SET @page_id += 1
END

SELECT DISTINCT page_type, page_type_desc FROM #page_info
WHERE page_type IS NOT NULL
