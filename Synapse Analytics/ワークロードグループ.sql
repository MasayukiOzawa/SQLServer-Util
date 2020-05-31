/*
https://docs.microsoft.com/ja-jp/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-workload-management
https://docs.microsoft.com/ja-jp/azure/synapse-analytics/sql-data-warehouse/analyze-your-workload
https://docs.microsoft.com/ja-jp/sql/t-sql/statements/create-workload-group-transact-sql
*/


SELECT * FROM sys.workload_management_workload_classifiers where classifier_id > 12
SELECT * FROM sys.workload_management_workload_classifier_details WHERE classifier_id > 12
SELECT * FROM sys.workload_management_workload_groups
SELECT * FROM sys.dm_workload_management_workload_groups_stats

SELECT * FROM sys.dm_pdw_nodes_resource_governor_workload_groups WHERE group_id BETWEEN 256 AND 2000000000


select * from sys.all_objects where name like '%workload%'


ALTER WORKLOAD GROUP WorkloadGroup01
WITH
( 
MIN_PERCENTAGE_RESOURCE = 0,
CAP_PERCENTAGE_RESOURCE = 100,
REQUEST_MAX_RESOURCE_GRANT_PERCENT = 1,
REQUEST_MIN_RESOURCE_GRANT_PERCENT = 1 
-- REQUEST_MAX_RESOURCE_GRANT_PERCENT = value ,
-- IMPORTANCE = NORMAL, 
-- QUERY_EXECUTION_TIMEOUT_SEC = value
)

EXEC sp_addrolemember 'Role01', 'Login01'
