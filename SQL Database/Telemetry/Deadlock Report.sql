SELECT 
	timestamp_utc,
	cast(event_data as xml).value('(/event/@name)[1]', 'varchar(50)') AS name,
	cast(event_data as xml).value('(//data[@name="database_name"])[1]', 'varchar(50)') AS database_name,
	cast(event_data as xml).query('descendant-or-self::*/data[@name="xml_report"]') AS xml_report
FROM 
	sys.fn_xe_telemetry_blob_target_read_file('dl', null, null, null)  