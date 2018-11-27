-- 拡張イベントの情報の取得 
SELECT
	name,
	target_name,
	target.value('(/EventFileTarget/File/@name)[1]', 'varchar(500)') AS xEventFile
FROM
(
SELECT
	name,
	target_name, 
	CAST(target_data AS XML) AS target
FROM 
	sys.dm_xe_database_session_targets st
	LEFT JOIN
	sys.dm_xe_database_sessions s
	ON
	s.address = st.event_session_address
WHERE
	target_name = 'event_file'
) AS T


-- https://docs.microsoft.com/ja-jp/azure/sql-database/sql-database-xevent-code-event-file

-- 直接クエリ版
DECLARE @xEventFile varchar(500) = 'https://<ストレージアカウント>.blob.core.windows.net/<コンテナー>/<トレースファイル>'

SELECT
	object_name,
	target.value('(/event/@timestamp)[1]', 'datetime2') AS timestamp,
	target.query('/event/data[@name="error_number"]').value('.', 'int') AS error_number,
	target.query('/event/data[@name="message"]').value('.', 'nvarchar(max)') AS error_number,
	target.query('/event/action[@name="sql_text"]').value('.', 'nvarchar(max)') AS error_number
FROM(
	SELECT
		*,
		CAST(event_data AS XML) AS target
	FROM
		sys.fn_xe_file_target_read_file
			(@xEventFile, null, null, null)
	WHERE
		object_name = 'error_reported'
		AND
		CAST(event_data AS XML).query('/event/data[@name="error_number"]').value('.', 'int')  NOT IN(102, 156, 207, 2528, 7955)
) AS T

-- 一時テーブル版
DECLARE @xEventFile varchar(500) = 'https://<ストレージアカウント>.blob.core.windows.net/<コンテナー>/<トレースファイル>'

DROP TABLE IF EXISTS #xmldata
CREATE TABLE #xmldata (C1 int IDENTITY PRIMARY KEY,object_name varchar(255), xml_data XML)

INSERT INTO #xmldata (object_name, xml_data)
SELECT
	object_name,
	CAST(event_data AS XML) AS target
FROM
	sys.fn_xe_file_target_read_file
		(@xEventFile, null, null, null)

CREATE PRIMARY XML INDEX idx_xml on #xmldata (xml_data)

SELECT
	object_name,
	xml_data.value('(/event/@timestamp)[1]', 'datetime2') AS timestamp,
	xml_data.query('/event/data[@name="error_number"]').value('.', 'int') AS error_number,
	xml_data.query('/event/data[@name="message"]').value('.', 'nvarchar(max)') AS error_number,
	xml_data.query('/event/action[@name="sql_text"]').value('.', 'nvarchar(max)') AS error_number
FROM
	#xmldata
WHERE
	object_name = 'error_reported'
	AND
	xml_data.query('/event/data[@name="error_number"]').value('.', 'int') NOT IN(102, 156, 207, 2528, 7955)

	
