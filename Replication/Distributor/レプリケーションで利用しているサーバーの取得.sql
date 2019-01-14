SELECT 
	*
FROM 
	distribution.dbo.MSsysservers_replservers WITH(NOLOCK)
OPTION (RECOMPILE, MAXDOP 1)


-- レプリケーションの削除に失敗して、情報の不整合が発生した場合の対応
-- https://sqlaj.wordpress.com/2012/03/23/cannot-drop-server-repl_distributor-because-it-is-used-as-a-distributor/
SELECT 
	* 
FROM
	master.dbo.sysservers 
WHERE 
	pub <> 0 or sub <> 0 or dist <> 0