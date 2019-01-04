SELECT 
	*
FROM 
	distribution.dbo.MSsysservers_replservers WITH(NOLOCK)
OPTION (RECOMPILE, MAXDOP 1)