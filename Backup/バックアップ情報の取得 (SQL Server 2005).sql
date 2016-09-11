SET NOCOUNT ON
GO

/*********************************************/
-- バックアップ情報の取得 (SQL Server 2005)
/*********************************************/
SELECT
   GETDATE() AS DATE,
    [bs].[database_name], 
    [bs].[backup_set_id],
    [bs].[name], 
    [bf].[logical_device_name],
    [bf].[device_type],
    [bs].[software_major_version], 
    [bs].[software_minor_version], 
    [bs].[software_build_version], 
    [bs].[database_creation_date], 
    [bs].[backup_start_date], 
    [bs].[backup_finish_date],
    [bs].[backup_size],
    [bs].[type]
FROM
    [msdb]..[backupset] bs
    LEFT JOIN
    [msdb]..[backupmediafamily] bf
    ON
    bf.media_set_id = bs.media_set_id
ORDER BY
    [database_name] ASC
OPTION (RECOMPILE)
