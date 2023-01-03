SELECT DISTINCT
	object_name COLLATE Japanese_CI_AS AS object_name, 
	counter_name COLLATE Japanese_CI_AS AS counter_name
	--, instance_name  COLLATE Japanese_CI_AS AS instance_name
FROM 
	sys.dm_os_performance_counters
EXCEPT
SELECT DISTINCT
	object_name COLLATE Japanese_CI_AS AS object_name, 
	counter_name COLLATE Japanese_CI_AS AS counter_name
	--,instance_name  COLLATE Japanese_CI_AS AS instance_name
FROM 
	[REMOTESERVER].master.sys.dm_os_performance_counters
ORDER BY
	object_name, counter_name
	--, instance_name