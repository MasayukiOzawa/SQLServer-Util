--autoadmin_task_agent_metadata は SQL Server Agent の起動時に生成されている。
-- データ矛盾が発生し、The operation failed because of an internal error. Auto-admin data table is possibly corrupt. のエラーになった場合は、
-- SQL Server Agen サービスの再起動を実施して、管理データを再生成することを検討 (autoadmin_id = 0 のレコードは　Agent で管理されているレコード)

-- 機能の利用には、SQL Server Agent が必要であり、SSMS では通常表示されない is_system = 1 のジョブとして、管理ジョブの制御が行われている (DAC で確認可能)

use msdb
select 
	am.autoadmin_id,
	am.task_agent_guid,
	am.last_modified,
	md.db_id,
	md.db_guid,
	md.db_name,
	bc.ManagedBackupVersion,
	bc.IsEnabled,
	bc.IsAlwaysOn,
	bc.IsDropped,
	bc.RetentionPeriod,
	bc.SchedulingOption,
	bc.DayOfWeek,
	am.task_agent_data
from 
	dbo.autoadmin_task_agent_metadata as am
	LEFT JOIN  dbo.autoadmin_managed_databases AS md
		ON am.autoadmin_id = md.autoadmin_id
	LEFT JOIN dbo.autoadmin_backup_configurations AS bc
		ON bc.db_id = md.db_id
order by 
	md.autoadmin_id ASC,
	md.db_id ASC
