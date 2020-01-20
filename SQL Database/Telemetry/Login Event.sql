DROP TABLE IF EXISTS #login_event
GO

CREATE TABLE #login_event(
	timestamp_utc datetime2(3) NOT NULL,
	object_name nvarchar(120),
	module_guid uniqueidentifier,
	package_guid uniqueidentifier,
	event_data xml,
	database_name varchar(50) NOT NULL,
	file_name nvarchar(520),
	file_offset bigint NOT NULL
)
ALTER TABLE #login_event ADD CONSTRAINT PK_loginevent

PRIMARY KEY CLUSTERED (timestamp_utc, database_name, file_offset)
CREATE PRIMARY XML INDEX XML_event_data_login_event ON #login_event(event_data)
GO

INSERT INTO #login_event
SELECT
	timestamp_utc,
	object_name,
	module_guid,
	package_guid,
	CAST(event_data AS xml) AS event_data,
	COALESCE(
		CAST(event_data AS xml).value('(//data[@name="database_name"])[1]', 'varchar(255)')
		, 'N/A')
	AS database_name,
	file_name,
	file_offset
FROM
(
	SELECT DISTINCT * 
	FROM sys.fn_xe_telemetry_blob_target_read_file('el', null, null, null)  
) AS T
ORDER BY 
	timestamp_utc DESC
GO

SELECT 
	timestamp_utc,
	object_name,
	database_name,
	event_data.value('(//data[@name="is_success"])[1]', 'varchar(20)') AS is_success,
	event_data.value('(//data[@name="error"])[1]', 'int') AS error,
	event_data.value('(//data[@name="state"])[1]', 'int') AS state,
	m.text
FROM 
	#login_event AS e
	LEFT JOIN sys.messages AS m
	ON  event_data.value('(//data[@name="error"])[1]', 'int') = m.message_id
WHERE
	event_data.value('(//data[@name="is_success"])[1]', 'varchar(20)') = 'false'
ORDER BY
	timestamp_utc DESC