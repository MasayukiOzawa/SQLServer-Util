USE [master]
GO
DROP DATABASE IF EXISTS DMVTEST
CREATE DATABASE DMVTEST
GO
ALTER DATABASE DMVTEST SET READ_COMMITTED_SNAPSHOT ON WITH NO_WAIT
GO

BACKUP DATABASE DMVTEST TO DISK=N'NUL'

-- modified_extent_page_count により、DB 単位で完全バックアップ以降に変更された Extent を取得できる
SELECT * FROM DMVTEST.sys.dm_db_file_space_usage

-- ログの統計を取得
SELECT 
	name,
	ls.*
FROM 
	sys.databases
	CROSS APPLY
	sys.dm_db_log_stats(database_id) AS ls

-- VLF の情報を取得
SELECT
	name, 
	li.*
FROM
	sys.databases
	CROSS APPLY 
	sys.dm_db_log_info(database_id) li

-- DB 単位のバージョンストアの使用状況の取得
SELECT * FROM sys.dm_tran_version_store_space_usage 

-- CPU ソケットの情報が追加
SELECT * FROM sys.dm_os_sys_info
