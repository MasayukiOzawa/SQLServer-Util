SET NOCOUNT ON
GO
WHILE(0=0)
BEGIN

DROP TABLE IF EXISTS #tmp
SELECT 
    GETDATE() AS collect_date,
    T.*,
    qs.query_plan
INTO #tmp
FROM   
    (
    SELECT
        tl.request_session_id AS session_id,
        es.program_name,
        es.host_name,
        er.status,
        er.command,
        at.NAME AS transaction_name,
        tl.resource_type,
        tl.request_mode,
        COUNT(*) AS lock_count,
        OBJECT_NAME(p.object_id) AS object_name,
        CASE 
            WHEN OBJECT_NAME(p.object_id) LIKE 'change_tracking%' THEN
                   OBJECT_NAME(
                       RIGHT(
                           OBJECT_NAME(p.object_id),
                           CHARINDEX('_', REVERSE(OBJECT_NAME(p.object_id))) - 1
                         )
                     )
            ELSE '' END AS base_object,
        tl.resource_lock_partition,
        er.transaction_isolation_level,
        er.query_hash,
        er.query_plan_hash
    FROM   
        sys.dm_tran_locks AS tl
        LEFT OUTER JOIN sys.dm_exec_sessions AS es
            ON es.session_id = tl.request_session_id
        LEFT OUTER JOIN sys.dm_exec_requests AS er
            ON er.session_id = es.session_id
        LEFT OUTER JOIN sys.dm_tran_active_transactions AS at
            ON at.transaction_id = er.transaction_id
        LEFT OUTER JOIN sys.partitions AS p
            ON p.hobt_id = tl.resource_associated_entity_id
    WHERE  
        at.NAME = 'CtCleanupTblDelete'
    GROUP  BY
        er.status,
        er.command,
        tl.request_session_id,
        tl.resource_type,
        tl.request_mode,
        es.program_name,
        es.host_name,
        p.object_id,
        tl.resource_lock_partition,
        at.NAME,
        er.transaction_isolation_level,
        er.query_hash,
        er.query_plan_hash
    ) AS T
    OUTER APPLY sys.Dm_exec_query_statistics_xml(T.session_id) AS qs
ORDER  BY 
    lock_count DESC; 

-- 一般的なクリーンアップの情報の取得か、ロックが肥大化している場合の取得かによって取得の最大値を調整する
DECLARE @lock_count INT = 4999
-- DECLARE @lock_count INT = 5000
IF (SELECT MAX(lock_count) FROM #tmp) >= @lock_count
BEGIN
    DECLARE @msg NVARCHAR(1000)
    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss.fff') + ': Lock count is ' + CAST((SELECT MAX(lock_count) FROM #tmp) AS NVARCHAR(10)) + '.'
    RAISERROR(@msg, 0, 1) WITH NOWAIT
    INSERT INTO lock_info SELECT * FROM #tmp WHERE lock_count >= @lock_count
END
WAITFOR DELAY '00:00:00.100'
END