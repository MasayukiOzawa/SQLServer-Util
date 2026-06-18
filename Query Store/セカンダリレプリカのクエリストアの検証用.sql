-- Replica Group ID 毎のクエリストアの格納状況の確認
SELECT   
    replica_group_id,
    COUNT(*) AS cnt
FROM     
    sys.query_store_runtime_stats
GROUP BY 
    replica_group_id
ORDER BY 
    replica_group_id ASC;
GO

-- 評価用クエリのクエリストアの格納状況を確認
SELECT 
    *
FROM 
    sys.database_query_store_internal_state;
GO

SELECT
    rs.replica_group_id,
    rs.count_executions,
    q.query_id,
    p.plan_id,
    qt.query_text_id,
    p.engine_version,
    p.query_plan_hash,
    q.query_hash,
    rs.runtime_stats_id,
    rs.runtime_stats_interval_id,
    rs.last_execution_time,
    qt.query_sql_text,
    CAST(p.query_plan AS xml)
FROM    
    sys.query_store_query_text AS qt
    LEFT OUTER JOIN sys.query_store_query AS q
        ON q.query_text_id = qt.query_text_id
    LEFT OUTER JOIN sys.query_store_plan AS p
        ON p.query_id = q.query_id
    LEFT OUTER JOIN sys.query_store_runtime_stats AS rs
        ON rs.plan_id = p.plan_id
WHERE    
    qt.query_sql_text LIKE '%MSSQL%'
    AND qt.query_sql_text NOT LIKE '%sys.%'
    AND rs.last_execution_time >= DATEADD(MINUTE, -20, SYSUTCDATETIME())
ORDER BY 
    rs.last_execution_time DESC;

/*
SELECT * FROM sys.query_store_replicas

-- クエリストアのデータのフラッシュ
-- プライマリレプリカだけでなく、セカンダリレプリカでも実行することができ、セカンダリレプリカのクエリストアもフラッシュできる。
EXEC sp_query_store_flush_db
GO

-- セカンダリのクエリストアの設定用サンプル
sp_query_store_set_hints 
    @query_id = 9, 
    @query_hints = N'OPTION(USE HINT(''QUERY_OPTIMIZER_COMPATIBILITY_LEVEL_150''))',
    @replica_group_id = 3;

-- レプリカ ID が存在しているテーブルの確認
SELECT   object_id,
         OBJECT_NAME(object_id) AS object_name,
         name
FROM     sys.all_columns
WHERE    name = 'replica_group_id'
ORDER BY object_name ASC;

*/



-- 各サーバーに対して検証用のクエリを実行
-- 登録済みサーバーを利用して、複数サーバーに実行することで効率よく確認できる。
SET NOCOUNT ON;
PRINT @@SERVERNAME + ':' + CAST(DATABASEPROPERTYEX(DB_NAME(),'UpdateAbility') AS nvarchar(100))
GO
DECLARE @srvname sysname = @@SERVERNAME
DECLARE @sql nvarchar(max)
SET @sql = N'SELECT ''' + @srvname + ''' AS serverName, * FROM NATION'
EXECUTE(@sql);
GO 500

/*
-- セカンダリレプリカにのみ存在しているクエリストアレコードの確認
SELECT * FROM sys.query_store_query WHERE query_id < 0
SELECT * FROM sys.query_store_runtime_stats WHERE runtime_stats_id < 0
SELECT * FROM sys.query_store_plan WHERE plan_id < 0
GO
*/