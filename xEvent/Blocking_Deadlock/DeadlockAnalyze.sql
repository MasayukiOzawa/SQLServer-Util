/*
DROP TABLE IF EXISTS [blocked_report_yyyymmdd];

SELECT
	DATEADD(hour, 9, CAST(event_data as XML).value('(//@timestamp)[1]', 'datetime2')) AS timestamp,
	CAST(event_data as XML).value('(/event/@name)[1]', 'varchar(100)') AS name,
	CAST(event_data as XML) AS event_data
INTO [blocked_report_yyyymmdd]
FROM 
	sys.fn_xe_file_target_read_file('D:\work_yyyymmdd1\blocked_report\*.xel', NULL, NULL, NULL)
ORDER BY 1
GO

<deadlock-list>
	<deadlock>
	</deadlock>
</deadlock-list>
*/

DECLARE @start_time datetime2(3) = '2022-01-01 00:00:00'
DECLARE @end_time  datetime2(3)  = '2023-01-01 00:00:00'

SELECT 
	T.timestamp,
	T.name,
	T.event_data.query('//victim-list') AS [victim-list],

	T2.node.value('(self::process/@lasttranstarted)[1]', 'datetime2(3)') AS lasttranstarted,
	T2.node.value('(self::process/@lastbatchcompleted)[1]', 'datetime2(3)') AS lastbatchcompleted,
	T2.node.value('(self::process/@lastattention)[1]', 'datetime2(3)') AS lastattention,

	T2.node.value('(self::process/@spid)[1]', 'int') AS [spid],
	T2.node.value('(self::process/@transactionname)[1]', 'varchar(100)') AS transactionname,
	T2.node.value('(self::process/@lockMode)[1]', 'varchar(100)') AS lockMode,

	T2.node.value('(self::process/@id)[1]', 'varchar(100)') AS [id],
	T2.node.value('(self::process/@schedulerid)[1]', 'int') AS schedulerid,
	T2.node.value('(self::process/@status)[1]', 'varchar(100)') AS status,
	T2.node.value('(self::process/@waittime)[1]', 'int') AS waittime,
	T2.node.value('(self::process/@logused)[1]', 'int') AS logused,
	T2.node.value('(self::process/@currentdbname)[1]', 'varchar(100)') AS currentdbname,
	T2.node.value('(self::process/@waitresource)[1]', 'varchar(100)') AS waitresource,
	T2.node.value('(self::process/@ownerId)[1]', 'bigint') AS ownerId,
	T2.node.value('(self::process/@isolationlevel)[1]', 'varchar(100)') AS isolationlevel,


	T2.node.value('(self::process/@clientapp)[1]', 'varchar(100)') AS clientapp,
	T2.node.value('(self::process/@hostname)[1]', 'varchar(100)') AS hostname,
	T2.node.value('(self::process/@loginname)[1]', 'varchar(100)') AS loginname,
	T2.node.value('(self::process/inputbuf)[1]', 'nvarchar(max)') AS inputbuf,
	T2.node.query('self::process/executionStack') AS executionStack,

	T.event_data,

	T2.node.query('.') AS node
FROM(
	SELECT 
		[timestamp],
		name,
		CAST(event_data as XML) AS event_data
	FROM  
		[blocked_report_yyyymmdd]
	WHERE
		name = 'xml_deadlock_report'
		AND timestamp >= @start_time AND timestamp < @end_time
) AS T
	CROSS APPLY T.event_data.nodes('//process') AS T2(node)
ORDER BY 
	timestamp, lasttranstarted