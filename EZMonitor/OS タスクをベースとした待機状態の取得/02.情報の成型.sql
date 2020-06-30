SELECT
    *
FROM
    dump_os_task
WHERE
    waiting_task_wait_type <> 'WAITFOR'
    AND collect_date >= DATEADD(hh,-1, GETDATE())
    AND program_name <> 'Microsoft SQL Server Management Studio'
ORDER BY
    session_id ASC,
    collect_date ASC,
    exec_context_id ASC