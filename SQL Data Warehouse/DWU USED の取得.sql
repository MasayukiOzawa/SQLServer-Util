/*******************************************************************************************/
-- 2017/9/15 時点SQL DW の場合、集約した情報が取得されるまで 15～30 分程度のタイムラグがある
-- 1 DWU = 7.5 DTU となっているため、加工している
-- https://docs.microsoft.com/ja-jp/azure/sql-data-warehouse/sql-data-warehouse-get-started-create-support-ticket
/*******************************************************************************************/

-- 同一時間帯の情報を集約
SELECT
	CONVERT(datetime2(0), DATEADD(hh, 9, FORMAT(start_time, 'yyyy/MM/dd HH:mm'))) AS start_time_ja,
	CONVERT(datetime2(0), FORMAT(start_time, 'yyyy/MM/dd HH:mm')) AS start_time_utc,
	AVG(dwu_size) AS dwu_size,
	SUM(max_dwu_used) AS total_dwu_used,
	MAX(max_dwu_used) AS max_dwu_used,
	MAX(max_dist_storage_in_megabytes) AS max_dist_storage_in_megabytes,
	CONVERT(bigint, AVG(avg_dist_storage_in_megabytes)) AS avg_dist_storage_in_megabytes,
	CONVERT(bigint, SUM(total_storage_in_megabytes)) AS total_storage_in_megabytes,
	CONVERT(bigint, AVG(avg_cpu_percent)) AS avg_cpu_percent,
	CONVERT(bigint, MAX(avg_cpu_percent)) AS max_cpu_percent,
	CONVERT(bigint, AVG(avg_data_io_percent)) AS avg_data_io_percent,
	CONVERT(bigint, MAX(avg_data_io_percent)) AS max_data_io_percent,
	CONVERT(bigint, AVG(avg_log_write_percent)) AS avg_log_write_percent,
	CONVERT(bigint, MAX(avg_log_write_percent)) AS max_log_write_percent,
	MAX(max_worker_percent) AS max_worker_percent,
	MAX(max_session_percent) AS max_session_percent,
	AVG(compute_node_count) AS compute_node_count,
	SUM(data_count) AS data_count
FROM
(
SELECT 
	CONVERT(datetime2(1), start_time) AS start_time,
	MAX(storage_in_megabytes) AS max_dist_storage_in_megabytes,
	AVG(storage_in_megabytes) AS avg_dist_storage_in_megabytes,
	SUM(storage_in_megabytes) AS total_storage_in_megabytes,
	AVG(avg_cpu_percent) AS avg_cpu_percent,
	AVG(avg_data_io_percent) AS avg_data_io_percent,
	AVG(avg_log_write_percent) AS avg_log_write_percent,
	MAX(max_worker_percent) AS max_worker_percent,
	MAX(max_session_percent) AS max_session_percent,
	(SELECT MAX(v) FROM 
	 (VALUES 
	  (CONVERT(bigint, AVG(avg_cpu_percent))), 
	  (CONVERT(bigint, AVG(avg_data_io_percent))), 
	  (CONVERT(bigint, AVG(avg_log_write_percent)))
	 ) AS T(v)
	) AS max_dwu_used,
	CAST(AVG(dtu_limit) / 7.5 AS int) AS dwu_size, 
	CAST(AVG(dtu_limit) / 7.5 / 100 AS int) AS compute_node_count,
	COUNT(*) AS data_count
FROM 
	sys.resource_stats
WHERE
	sku = 'DW'
	AND
	database_name LIKE 'Distribution[_]%'
GROUP BY
	CONVERT(datetime2(1), start_time)
) AS T
GROUP BY
	FORMAT(start_time, 'yyyy/MM/dd HH:mm')
ORDER BY 
	FORMAT(start_time, 'yyyy/MM/dd HH:mm') ASC
GO

-- 60 件の情報となっていないものを出力
SELECT 
	* 
FROM(
SELECT 
	DATEADD(hh, 9, start_time) AS start_time_ja,
	start_time AS start_time_utc,
	CAST(AVG(dtu_limit) / 7.5 AS int) AS dwu_size,
	(SELECT MAX(v) FROM 
	 (VALUES 
	  (CONVERT(bigint, AVG(avg_cpu_percent))), 
	  (CONVERT(bigint, AVG(avg_data_io_percent))), 
	  (CONVERT(bigint, AVG(avg_log_write_percent)))
	 ) AS T(v)
	) AS max_dwu_used,
	MAX(storage_in_megabytes) AS max_dist_storage_in_megabytes,
	CONVERT(bigint, AVG(storage_in_megabytes)) AS avg_dist_storage_in_megabytes,
	SUM(storage_in_megabytes) AS total_storage_in_megabytes,
	CONVERT(bigint, AVG(avg_cpu_percent)) AS avg_cpu_percent,
	CONVERT(bigint, AVG(avg_data_io_percent)) AS avg_data_io_percent,
	CONVERT(bigint, AVG(avg_log_write_percent)) AS avg_log_write_percent,
	MAX(max_worker_percent) AS max_worker_percent,
	MAX(max_session_percent) AS max_session_percent,
	CAST(AVG(dtu_limit) / 7.5 / 100 AS int) AS compute_node_count,
	COUNT(*) AS data_count
FROM 
	sys.resource_stats
WHERE
	sku = 'DW'
	AND
	database_name LIKE 'Distribution[_]%'
GROUP BY
	start_time
) AS T
WHERE
	data_count <> 60 / compute_node_count
ORDER BY 
	start_time_ja ASC
GO

-- 集約していない状態の情報
SELECT
	start_time_ja,
	start_time_utc,
	database_name,
	sku,
	storage_in_megabytes,
	avg_cpu_percent,
	avg_data_io_percent,
	avg_log_write_percent,
	max_worker_percent,
	max_session_percent,
	dtu_limit,
	dwu_size,
	xtp_storage_percent
FROM
(
	SELECT
		DATEADD(hh, 9, start_time) AS start_time_ja,
		start_time AS start_time_utc,
		database_name,
		sku,
		storage_in_megabytes,
		avg_cpu_percent,
		avg_data_io_percent,
		avg_log_write_percent,
		max_worker_percent,
		max_session_percent,
		dtu_limit,
		CAST(dtu_limit / 7.5 AS int) AS dwu_size, 
		xtp_storage_percent,
		CASE CHARINDEX('_', database_name)
		WHEN 0 THEN
			0
		ELSE
				SUBSTRING(database_name, 
						  CHARINDEX('_', database_name) + 1, 
						  (LEN(database_name) - CHARINDEX(database_name, '_'))
			)
		END AS sort_order
	FROM
		sys.resource_stats
	WHERE
		sku = 'DW'
) T
ORDER BY
	start_time_ja ASC,a
	sort_order ASC