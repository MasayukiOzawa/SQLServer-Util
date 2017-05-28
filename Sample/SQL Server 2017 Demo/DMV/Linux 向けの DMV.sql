-- ]—ˆ‚Ìî•ñ‚Ìæ“¾•û–@
EXEC master.dbo.xp_msver

-- SQL Server 2017 ‚Ì OS î•ñ‚Ìæ“¾•û–@
SELECT * FROM sys.dm_os_host_info
 
-- Linux ŠÖ˜A‚Ìî•ñ
SELECT * FROM sys.dm_linux_proc_all_stat
SELECT * FROM sys.dm_linux_proc_cpuinfo
SELECT * FROM sys.dm_linux_proc_meminfo
SELECT * FROM sys.dm_linux_proc_sql_maps
SELECT * FROM sys.dm_linux_proc_sql_threads
