-- EXEC sp_helpdistpublisher
SELECT 
	name,
	distribution_db,
	working_directory,
	security_mode,
	login,
	active,
	trusted,
	thirdparty_flag,
	publisher_type
	-- , storage_connection_string
FROM 
	msdb.dbo.MSdistpublishers WITH(NOLOCK)
OPTION (RECOMPILE, MAXDOP 1)