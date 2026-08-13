/*
SELECT * FROM sys.change_tracking_tables;
GO
Truncate Table Lock_info
*/

SELECT TOP 5 object_name(object_id) AS object_name, row_count 
FROM sys.dm_db_partition_stats 
WHERE (object_name(object_id) = 'syscommittab' OR object_name(object_id) LIKE 'change_tracking_%') AND index_id = 1
ORDER BY row_count DESC, object_name DESC
GO

SELECT
	*,
	T.query_plan.value('(//@QueryHash)[1]', 'varchar(max)') AS query_hash,
	T.query_plan.value('(//@QueryPlanHash)[1]', 'varchar(max)') AS query_plan_hash
FROM
(
    SELECT TOP 1000 * FROM lock_Info 
    WHERE lock_count >= 4999
    ORDER BY  collect_date DESC, lock_count DESC
) AS T
GO

SELECT
	*,
	T.query_plan.value('(//@QueryHash)[1]', 'varchar(max)') AS query_hash,
	T.query_plan.value('(//@QueryPlanHash)[1]', 'varchar(max)') AS query_plan_hash
FROM
(
	SELECT TOP 1000 * FROM lock_Info 
	ORDER BY collect_date DESC
) AS T
GO

SELECT
	*,
	T.query_plan.value('(//@QueryHash)[1]', 'varchar(max)') AS query_hash,
	T.query_plan.value('(//@QueryPlanHash)[1]', 'varchar(max)') AS query_plan_hash
FROM
(
    SELECT TOP 1000 * FROM lock_Info 
    WHERE resource_type <> 'PAGE' AND lock_count > 4999
    ORDER BY lock_count DESC, collect_date DESC
) AS T
GO

SELECT
	*,
	T.query_plan.value('(//@QueryHash)[1]', 'varchar(max)') AS query_hash,
	T.query_plan.value('(//@QueryPlanHash)[1]', 'varchar(max)') AS query_plan_hash
FROM
(
    SELECT TOP 1000 * FROM lock_Info 
    WHERE resource_type <> 'PAGE' AND query_plan is not null
    ORDER BY collect_date DESC
) AS T
GO


SELECT OBJECT_NAME(object_id) AS object_name, object_id, row_count 
FROM sys.dm_db_partition_stats 
WHERE index_id = 1 AND (OBJECT_NAME(object_id) LIKE 'change[_]%' OR OBJECT_NAME(object_id) = 'syscommittab')
ORDER BY row_count DESC;
