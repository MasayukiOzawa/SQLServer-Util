select top 50
            (case when requests.status = 'Completed' then 100
            when progress.total_steps = 0 then 0
            else 100 * progress.completed_steps / progress.total_steps end) as progress_percent,
            requests.status, 
            requests.request_id, 
            sessions.login_name, 
            requests.start_time, 
            requests.end_time, 
            requests.total_elapsed_time, 
            requests.command,             
            errors.details,
            requests.session_id,
            (case when requests.resource_class is NULL then 'N/A'
            else requests.resource_class end) as resource_class,
            (case when resource_waits.concurrency_slots_used is NULL then 'N/A'
            else cast(resource_waits.concurrency_slots_used as varchar(10)) end) as concurrency_slots_used

            from sys.dm_pdw_exec_requests AS requests

            join sys.dm_pdw_exec_sessions AS sessions
                    on (requests.session_id = sessions.session_id)
            left join sys.dm_pdw_errors AS errors
	            on (requests.error_id = errors.error_id)
            left join sys.dm_pdw_resource_waits AS resource_waits
                on (requests.resource_class = resource_waits.resource_class)
            outer apply (
	            select count (steps.request_id) as total_steps,
		            sum (case when steps.status = 'Complete' then 1 else 0 end ) as completed_steps
	            from sys.dm_pdw_request_steps steps where steps.request_id = requests.request_id
            ) progress

            cross apply (
                    select count (*) as is_batch
                    from sys.dm_pdw_exec_requests inner_requests
                    where inner_requests.session_id = requests.session_id
                            and inner_requests.request_id != requests.request_id
                            and inner_requests.start_time >= requests.start_time
	                        and (inner_requests.end_time <= requests.end_time
                                    or (inner_requests.end_time is null and requests.end_time is null)
                            )
            ) batch

            where requests.start_time >= DATEADD(hour, -24, GETDATE())
                    and batch.is_batch = 0

            ORDER BY requests.total_elapsed_time DESC, requests.start_time DESC