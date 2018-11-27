-- DB 単位のストレージ利用状況 (1 時間間隔)
SELECT * FROM sys.resource_usage 
WHERE end_time >= DATEADD(HOUR, -6, GETUTCDATE())
ORDER BY end_time DESC

-- インスタンス単位のリソース利用状況 (15 秒単位)
SELECT * FROM sys.server_resource_stats
WHERE start_time >= DATEADD(HOUR, -6, GETUTCDATE())
ORDER BY start_time DESC
 
 -- DB 単位のリソース利用状況  (5 分間隔)
SELECT * FROM sys.resource_stats_raw
WHERE start_time >= DATEADD(HOUR, -6, GETUTCDATE())
ORDER BY start_time DESC