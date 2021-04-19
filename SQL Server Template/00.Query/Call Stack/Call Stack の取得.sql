/*
DBCC TRACEON(3656, 2592, -1)  

DBCC TRACEOFF(3656, 2592, -1)  

DBCC TRACESTATUS
GO
*/

DECLARE @file_name nvarchar(255) = N'D:\xevent\lockinfo*.xel'

SELECT
	xml_data.value('(/event/@timestamp)[1]', 'datetime2(3)') AS event_timestamp_utc,
	xml_data.value('(//action[@name="system_thread_id"])[1]', 'int') AS thread_id,
	xml_data.value('(/event/@name)[1]', 'varchar(255)') AS event_name,
	xml_data.value('(//action[@name="session_id"])[1]', 'int') AS session_id,
	xml_data.value('(//action[@name="client_app_name"])[1]', 'nvarchar(255)') AS client_app_name,
	xml_data.value('(//action[@name="sql_text"])[1]', 'nvarchar(max)') AS sql_text,
	xml_data.value('(//data[@name="wait_type"]/text)[1]', 'varchar(100)') AS wait_type,
	xml_data.value('(//data[@name="database_id"])[1]', 'int') AS database_id,
	xml_data.value('(//data[@name="database_name"])[1]', 'varchar(100)') AS database_name,
	xml_data.value('(//data[@name="object_id"])[1]', 'int') AS object_id,
	xml_data.value('(//data[@name="wait_resource"])[1]', 'varchar(100)') AS wait_resource,
	xml_data.value('(//data[@name="resource_description"])[1]', 'varchar(100)') AS resource_description,
	xml_data.value('(//data[@name="mode"]/text)[1]', 'varchar(100)') AS mode,
	xml_data.value('(//data[@name="duration"])[1]', 'int') AS duration,
	xml_data.query('//action[@name="callstack"]') AS call_stack,
	xml_data
FROM(
	SELECT
		CAST(event_data as xml) AS xml_Data
	FROM 
		sys.fn_xe_file_target_read_file(@file_name, NULL, NULL, NULL)
) AS T
-- WHERE 
    -- CAST(T.xml_data.query('//action[@name="callstack"]') AS nvarchar(max)) NOT LIKE '%SplitPage%'
    -- xml_data.value('(//data[@name="duration"])[1]', 'int') > 0
ORDER BY 
    event_timestamp_utc ASC,
    session_id ASC

GO

-- https://www.sqlskills.com/blogs/paul/determine-causes-particular-wait-type/

SELECT
    [event_session_address],
    [target_name],
    [execution_count],
    CAST ([target_data] AS XML)
FROM sys.dm_xe_session_targets [xst]
INNER JOIN sys.dm_xe_sessions [xs]
    ON [xst].[event_session_address] = [xs].[address]
WHERE [xs].[name] = N'InvestigateWaits';
GO
