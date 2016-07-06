-- 削除対象の日付を設定
DECLARE @dt date = (SELECT DATEADD(dd, -31, GETDATE()))

-- バックアップ履歴レコードの削除
EXEC msdb.dbo.sp_delete_backuphistory @dt

-- ジョブ実行履歴レコードの削除
EXEC msdb.dbo.sp_purge_jobhistory  @oldest_date= @dt

-- メンテナンスプラン履歴レコードの削除
EXECUTE msdb..sp_maintplan_delete_log null,null, @dt
