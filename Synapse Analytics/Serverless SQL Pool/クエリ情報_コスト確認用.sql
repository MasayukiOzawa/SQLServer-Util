-- 処理データ量の確認
-- https://learn.microsoft.com/ja-jp/azure/synapse-analytics/sql/data-processed#configure-cost-control-for-serverless-sql-pool-in-t-sql
-- https://learn.microsoft.com/ja-jp/azure/azure-monitor/essentials/metrics-supported#microsoftsynapseworkspaces
SELECT * FROM sys.dm_external_data_processed
SELECT * FROM sys.configurations WHERE name like 'Data processed %';

-- クエリの実行履歴
SELECT * FROM sys.dm_exec_requests_history WHERE start_time >= DATEADD(hh,-24,SYSUTCDATETIME()) ORDER BY start_time DESC


-- クエリの詳細情報
SELECT * FROM sys.dm_request_phases WHERE start_time >= DATEADD(hh,-24,SYSUTCDATETIME()) ORDER BY start_time DESC
SELECT * FROM sys.dm_request_phases_exec_task_stats ORDER BY id DESC
SELECT * FROM sys.dm_request_phases_task_group_stats ORDER BY id DESC