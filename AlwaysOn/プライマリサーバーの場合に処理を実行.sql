USE tpcc
SET NOCOUNT ON
GO

DECLARE @primary_server_name sysname

SET @primary_server_name = (
SELECT 
	primary_replica
FROM 
	sys.dm_hadr_availability_group_states
	LEFT JOIN
		sys.availability_groups
	ON
		sys.availability_groups.group_id =  sys.dm_hadr_availability_group_states.group_id
WHERE
		sys.availability_groups.name = 'AlwaysOnGroup')
IF (@primary_server_name = @@SERVERNAME)
BEGIN
	PRINT 'Index Maintenance Start'
	ALTER INDEX [orders_i1] ON [dbo].[orders] REBUILD
	PRINT 'Index Maintenance End'
END
