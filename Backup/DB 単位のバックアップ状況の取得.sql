USE [master]
GO

SET NOCOUNT ON
GO

SELECT
	name,
	create_date,
	recovery_model,
	recovery_model_desc,
	D AS full_backup_finish_date,
	I AS diff_backup_finish_date,
	L AS log_backup_finish_date
FROM
(
SELECT
	d.database_id,
	d.name,
	d.create_date,
	d.recovery_model,
	d.recovery_model_desc,
	backup_tbl.type,
	backup_tbl.backup_finish_date
FROM 
	sys.databases AS d
	LEFT JOIN
	(SELECT 
		database_name, 
		type, 
		MAX(backup_finish_date) AS backup_finish_date
		FROM
		msdb.dbo.backupset 
		GROUP BY 
		database_name, 
		type
	) AS backup_tbl
	ON
		d.name = backup_tbl.database_name
) AS T
PIVOT
(
	MAX(backup_finish_date)
	FOR type IN(D, I, L)
)AS PVT
ORDER BY 
	database_id ASC