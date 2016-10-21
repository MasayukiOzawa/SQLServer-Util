-- 自動シード処理のステータスの確認
SELECT TOP 5 
	start_time,
	completion_time,
	current_state,
	failure_state_desc
FROM 
	sys.dm_hadr_automatic_seeding 
ORDER BY 
	start_time DESC

-- 自動シード処理の転送状況の確認
SELECT TOP 5 
	start_time_utc,
	end_time_utc,
	local_database_name,
	internal_state_desc,
	transfer_rate_bytes_per_second,
	transferred_size_bytes,
	database_size_bytes
FROM 
	sys.dm_hadr_physical_seeding_stats 
ORDER BY 
	start_time_utc DESC

