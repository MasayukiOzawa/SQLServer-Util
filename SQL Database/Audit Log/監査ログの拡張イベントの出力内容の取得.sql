DECLARE @xEventFile varchar(500) = 
'https://<ストレージアカウント>.blob.core.windows.net/sqldbauditlogs/<サーバー名>/<DB 名>/SqlDbAuditing_ServerAudit_NoRetention/2017-05-04/00_00_18_227_1.xel'


SELECT
	event_time,
	file_name,
	client_ip,
	application_name,
	action_id,
	class_type,
	session_server_principal_name,
	database_principal_name,
	server_instance_name,
	database_name,
	schema_name,
	object_name,
	statement,
	CAST(additional_information AS XML) AS additional_information
FROM
	sys.fn_get_audit_file (@xEventFile, null, null)
ORDER BY
	event_time DESC
