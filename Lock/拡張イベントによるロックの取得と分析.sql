/*
CREATE EVENT SESSION [Lock Info] ON SERVER 
ADD EVENT sqlserver.lock_acquired(SET collect_database_name=(1),collect_resource_description=(1)
    ACTION(sqlserver.client_app_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ([package0].[equal_uint64]([sqlserver].[session_id],(59)))),
ADD EVENT sqlserver.lock_released(SET collect_database_name=(1),collect_resource_description=(1)
    ACTION(sqlserver.client_app_name,sqlserver.session_id,sqlserver.sql_text)
    WHERE ([package0].[equal_uint64]([sqlserver].[session_id],(59))))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=NO_EVENT_LOSS,MAX_DISPATCH_LATENCY=5 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=ON,STARTUP_STATE=OFF)
GO

DROP TABLE IF EXISTS xEvents
GO
*/

SELECT
    timestamp,
    name, 
    resource_type, 
    mode,
    CASE
        WHEN resource_type = 'OBJECT' THEN object_name(resource_0, database_id)
        WHEN resource_type = 'DATABASE' THEN DB_NAME(resource_0)
        WHEN resource_type = 'METADATA' THEN resource_description
        WHEN resource_type = 'KEY' THEN object_name(resource_0,database_id) + ' : '+ resource_description
        ELSE CAST(resource_0 AS varchar(10))
    END AS lock_resource,
    resource_0,
    resource_1,
    resource_2,
    resource_description,
    [attach_activity_id.guid],
    [attach_activity_id.seq],
    client_app_name,
    sql_text
FROM 
    xEvents 
ORDER BY
    timestamp ASC