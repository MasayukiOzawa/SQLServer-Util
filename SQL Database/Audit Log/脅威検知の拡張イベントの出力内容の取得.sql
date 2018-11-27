-- 拡張イベントの情報の取得 
DECLARE @xEventFile varchar(500) = 
'https://<ストレージアカウント>.blob.core.windows.net/sqldbauditlogs/<サーバー名>/<DB 名/SqlDbThreatDetection_Audit_NoRetention/2017-05-19/06_31_26_736_2.xel'


SELECT
	a.event_time,
	a.file_name,
	a.client_ip,
	a.application_name,
	a.action_id,
	a.class_type,
	a.session_server_principal_name,
	a.database_principal_name,
	a.server_instance_name,
	a.database_name,
	a.schema_name,
	a.object_name,
	a.statement,
	CAST(a.additional_information AS XML) AS additional_information,
	u.Application,
	u.IpAddress,
	u.[User],
	u.Statement
FROM
	sys.fn_get_audit_file (@xEventFile, null, null) AS a
	OUTER APPLY OPENJSON(
		CASE user_defined_information
		WHEN '' THEN NULL
		ELSE user_defined_information
		END
	) 
	WITH(
		Application sysname '$.Application',
		IpAddress nvarchar(20) '$.IpAddress',
		Statement nvarchar(max) '$.Statement',
		[User] sysname '$.User'
	)AS u
ORDER BY
	event_time DESC