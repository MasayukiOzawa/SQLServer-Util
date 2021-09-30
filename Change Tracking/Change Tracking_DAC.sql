/* DAC のセッションで実行可能なクエリ */

USE changetracking
GO

-- システムテーブルの確認
SELECT
	*,
	'0x' + SUBSTRING(ts,7,2) + SUBSTRING(ts,5,2) + SUBSTRING(ts,3,2) AS warter_mark
FROM
(
SELECT TOP 10 
	*, 
	CONVERT(varchar(8), CONVERT(varbinary(3), commit_ts,1), 1) AS ts
FROM
	sys.syscommittab 
ORDER BY 
	commit_ts DESC
) AS T

-- ウォーターマークの確認
SELECT TOP 10 * FROM sys.syscommittab ORDER BY commit_time DESC

SELECT * FROM sys.change_tracking_tables

select * from sys.sysobjvalues 
cross apply sys.fn_PhysLocCracker(%%physloc%%)
where value = (
	SELECT min_valid_version FROM sys.change_tracking_tables 
	WHERE object_id = OBJECT_ID('CT_01')
)


select * from sys.sysobjvalues 
cross apply sys.fn_PhysLocCracker(%%physloc%%)
where valclass = 7 and objid in(1003,1004) or
valclass = 95

select * from sys.sysobjvalues
outer apply sys.fn_PhysLocCracker(%%physloc%%)
where value IN(1617786, 1613942, 2319385)


select * from sys.sysobjvalues WHERE objid = 581577110
-- Water Mark の強制更新
SELECT TOP 10000 * from [sys].[change_tracking_581577110] order by 1 ASC
GO

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
SELECT * from sys.[change_tracking_581577110] where sys_change_xdes_id = 2824542
SELECT * FROM sys.dm_tran_locks where request_session_id = @@spid
COMMIT TRAN

SELECT * from sys.[change_tracking_581577110]  WITH(NOLOCK)
DBCC TRACEON(3604)
DBCC PAGE('changetracking', 1, 128,1)
DBCC PAGE('changetracking', 1, 2336,1)
GO

-- オフセット+26 Bytes
DBCC WRITEPAGE('changetracking', 1, 128,6450, 3 , 0x69B040, 0)
DBCC WRITEPAGE('changetracking', 1, 128,6484, 3 , 0x69B040, 0)
DBCC WRITEPAGE('changetracking', 1, 2336,482, 3 , 0x23E520, 0)

SELECT * FROM sys.change_tracking_tables

-- 手動クリーンアップ用ストアドプロシージャの実行
-- change_tracking_[オブジェクト ID] を削除してから、sys.syscommittab を削除
EXEC dbo.sp_flush_CT_internal_table_on_demand @TableToClean = 'CT_01'
EXEC sys.sp_flush_commit_table_on_demand
CHECKPOINT
select * from sys.fn_dblog(NULL, NULL)

-- データ件数の確認
SELECT 
	object_name(p.object_id) as name, p.index_id, p.rows 
FROM 
	sys.partitions  AS p
	INNER JOIN sys.objects AS o
		ON o.object_id = p.object_id
WHERE 
	(p.object_id = object_id('sys.syscommittab') OR o.name LIKE 'change[_]tracking[_]%')
	AND p.index_id = 1

-- 統計情報の更新
UPDATE STATISTICS sys.[change_tracking_581577110]  WITH FULLSCAN

SELECT * FROM sys.syscommittab 

DBCC FREEPROCCACHE
/*
select * from sys.sysseobjvalues
select * from sys.sysmultiobjvalues
select * from sys.sysrowsetrefs
select * from sys.syscacheobjects
select object_name(object_id), * from sys.all_columns where name = 'objid'
select * from sys.change_tracking_tables
*/

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRAN
SELECT TOP 1000 * from [sys].[change_tracking_581577110] order by 1 ASC
SELECT * FROM sys.dm_tran_locks where request_session_id = @@spid
ROLLBACK TRAN
GO

exec sp_who2

DBCC TRACEOFF(1224, -1)
DBCC TRACEON(1224, -1)