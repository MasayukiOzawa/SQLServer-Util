SELECT 
	name, 
	type, 
	clock_hand,
	clock_status ,
	SUM(rounds_count) AS rounds_count,
	SUM(removed_all_rounds_count) AS removed_all_rounds_count,
	SUM(updated_last_round_count) AS updated_last_round_count,
	SUM(removed_last_round_count) AS removed_last_round_count,
	SUM(last_tick_time) AS last_tick_time,
	SUM(round_start_time) AS round_start_time,
	SUM(last_round_start_time) AS last_round_start_time
FROM 
	sys.dm_os_memory_cache_clock_hands 
WHERE
	type <> 'USERSTORE_TOKENPERM'
GROUP BY
	name, type, clock_hand,clock_status
ORDER BY 
	removed_all_rounds_count desc, type, name, clock_hand,clock_status
GO

