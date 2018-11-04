-- http://emkjp.github.io/WebTools/dot.html に session_id と bloking_session_id を渡して確認
SELECT 
r.session_id, r.blocking_session_id ,
r.wait_time, r.last_wait_type, r.wait_resource,
SUBSTRING(s.text, (r.statement_start_offset/2)+1,   
    ((CASE r.statement_end_offset  
      WHEN -1 THEN DATALENGTH(s.text)  
     ELSE r.statement_end_offset  
     END - r.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_requests AS r
CROSS APPLY
sys.dm_exec_sql_text(sql_handle) AS s
WHERE r.blocking_session_id > 0
GO

-- 親のブロッカーのクエリの取得
SET NOCOUNT ON
DECLARE @blocker_session_id int

DECLARE cur_blocker CURSOR LOCAL FORWARD_ONLY FOR 
	SELECT r.session_id 
	FROM sys.dm_exec_sessions AS r
	INNER JOIN
	(SELECT 
		r.session_id, r.blocking_session_id
		FROM sys.dm_exec_requests AS r
		WHERE r.blocking_session_id > 0
	) AS b
	ON
	b.blocking_session_id = r.session_id
	AND r.session_id NOT IN (
		SELECT session_id FROM
			(SELECT 
				r.session_id, r.blocking_session_id
				FROM sys.dm_exec_requests AS r
				WHERE r.blocking_session_id > 0
			) AS b2
	)
IF OBJECT_ID('tempdb..#inputbuffer_temp') IS NOT NULL
BEGIN
	DROP TABLE #inputbuffer_temp
END
CREATE TABLE #inputbuffer_temp (EventType nvarchar(30), Parameters smallint, EventInfo nvarchar(4000))

IF OBJECT_ID('tempdb..#inputbuffer') IS NOT NULL
BEGIN
	DROP TABLE #inputbuffer
END
CREATE TABLE #inputbuffer (session_id int, EventType nvarchar(30), Parameters smallint, EventInfo nvarchar(4000))

DECLARE @buf_sql nvarchar(max)

OPEN cur_blocker  

FETCH NEXT FROM cur_blocker   
INTO @blocker_session_id  

WHILE @@FETCH_STATUS = 0  
BEGIN 
	SET @buf_sql = N'DBCC INPUTBUFFER(' + CAST(@blocker_session_id AS varchar(10)) + N') WITH NO_INFOMSGS'
	INSERT INTO #inputbuffer_temp EXEC (@buf_sql)
	INSERT INTO #inputbuffer SELECT @blocker_session_id, * FROM #inputbuffer_temp
	TRUNCATE TABLE #inputbuffer_temp
	FETCH NEXT FROM cur_blocker   
	INTO @blocker_session_id  	
END

SELECT * FROM #inputbuffer