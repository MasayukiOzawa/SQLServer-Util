SELECT
	*
FROM
(
	SELECT
		server_name,
		db_name,
		DATEADD(HOUR,9, collect_date) AS [time],
		object_name,
		name,
		FORMAT(reserved_page_count * 8.0 / 1024.0, '#,##0.#0') AS reserved_page_size_mb,
		FORMAT(
			COALESCE(
				user_scans - 
				LAG(user_scans) OVER (PARTITION BY object_name, name ORDER BY collect_date ASC)
			, 0) 
		, '#,##0') 
		AS user_scan_diff,
		FORMAT(
			COALESCE(
				page_io_latch_wait_count - 
				LAG(page_io_latch_wait_count) OVER (PARTITION BY object_name, name ORDER BY collect_date ASC)
			, 0) 
		, '#,##0') AS page_io_latch_wait_count_diff,
		FORMAT(
			COALESCE(
				page_io_latch_wait_in_ms - 
				LAG(page_io_latch_wait_in_ms) OVER (PARTITION BY object_name, name ORDER BY collect_date ASC)
			, 0)
		, '#,##0') AS page_io_latch_wait_in_ms_diff
	FROM
		[00_indexstats]
) AS T
WHERE
	user_scan_diff > 0
ORDER BY
	reserved_page_size_mb DESC,
	[time] DESC