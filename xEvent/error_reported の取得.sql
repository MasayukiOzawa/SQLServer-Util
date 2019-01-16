DECLARE @file nvarchar(max) = N'system_health*.xel'

SELECT
	DATEADD(hour,9 , xmldata.value('(/event/@timestamp)[1]', 'datetime')) AS timestamp,
	object_name,
	xmldata.value('(/event/data[@name="error_number"])[1]', 'int') AS error_number,
	xmldata.value('(/event/data[@name="severity"])[1]', 'int') AS severity,
	xmldata.value('(/event/data[@name="state"])[1]', 'int') AS state,
	xmldata.value('(/event/data[@name="category"]/text)[1]', 'sysname') AS category,
	xmldata.value('(/event/data[@name="destination"]/text)[1]', 'sysname') AS destination,
	xmldata.value('(/event/data[@name="message"])[1]', 'nvarchar(max)') AS message,
	xmldata
FROM(
	SELECT
		object_name,
		CAST(event_data AS XML) AS xmldata
	FROM
		sys.fn_xe_file_target_read_file(@file, NULL, NULL, NULL)
	WHERE
		object_name IN('error_reported')
) AS x
ORDER BY timestamp DESC
GO
