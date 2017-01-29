DECLARE @date varchar(8), @time varchar(8)
SELECT @date = CONVERT(varchar,GETDATE(), 112), @time = REPLACE(CONVERT(varchar,GETDATE(), 108),':','')

DECLARE @ReturnCode int

DECLARE @job sysname = N'TEST'

EXEC @ReturnCode = sp_start_job @job_name=@job

IF @ReturnCode = 0
BEGIN
	WHILE(0 = 0)
	BEGIN
		IF(SELECT COUNT(*) FROM sysjobhistory sh
		LEFT JOIN sysjobs sj ON sh.job_id = sj.job_id 
		WHERE sj.name = @job AND sh.step_id = 0 AND 
		sh.run_date >= @date and sh.run_time >= @time) > 0
		BEGIN
			IF(SELECT run_status FROM sysjobhistory sh
			LEFT JOIN sysjobs sj ON sh.job_id = sj.job_id 
			WHERE sj.name = @job AND sh.step_id = 0 AND 
			sh.run_date >= @date and sh.run_time >= @time) <> 1
			BEGIN
				RAISERROR('Job Execution Error', 15,1)
			END
			BREAK
		END
		ELSE
		BEGIN
			WAITFOR DELAY '00:00:05'
		END
	END
END
ELSE
BEGIN
	RAISERROR('Job Execution Error', 15,1)
END