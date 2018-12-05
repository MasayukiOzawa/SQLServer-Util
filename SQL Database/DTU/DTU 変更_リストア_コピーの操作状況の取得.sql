-- DTU 変更 / リストア / データベースコピーの操作状態を取得
SELECT 
	start_time,
	last_modify_time,
	resource_type_desc,
	major_resource_id,
	minor_resource_id,
	operation,
	state_desc,
	percent_complete,
	error_desc
FROM
	sys.dm_operation_status  
WHERE 
	state <> 2