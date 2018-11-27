-- https://docs.microsoft.com/ja-jp/azure/sql-data-warehouse/sql-data-warehouse-load-from-azure-blob-storage-with-polybase

-- データインポート状況の確認
SELECT * FROM sys.dm_pdw_exec_requests WHERE end_time IS NULL

-- 送信バイト数の確認
SELECT
	r.start_time,
	r.end_time,
    r.command,
    s.request_id,
    r.status,
	r.[label],
    input_name, 
    sum(s.bytes_processed)/1024/1024 as gb_processed
FROM
    sys.dm_pdw_exec_requests r
    inner join sys.dm_pdw_dms_external_work s
        on r.request_id = s.request_id
WHERE
	r.end_time IS NULL
GROUP BY
	r.start_time,
	r.end_time,
    r.command,
    s.request_id,
	s.input_name,
    r.status,
	r.[label]
ORDER BY
    gb_processed desc;


SELECT
	r.start_time,
	r.end_time,
    r.command,
    s.request_id,
    r.status,
	r.[label],
    count(distinct input_name) as nbr_files, 
    sum(s.bytes_processed)/1024/1024 as gb_processed
FROM
    sys.dm_pdw_exec_requests r
    inner join sys.dm_pdw_dms_external_work s
        on r.request_id = s.request_id
WHERE
	r.end_time IS NULL
GROUP BY
	r.start_time,
	r.end_time,
    r.command,
    s.request_id,
    r.status,
	r.[label]
ORDER BY
    nbr_files desc,
    gb_processed desc;
