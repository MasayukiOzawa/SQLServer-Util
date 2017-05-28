SET NOCOUNT ON
GO

DROP TABLE IF EXISTS PerfTable
GO

CREATE TABLE PerfTable(
	[Counter Date] datetime2 ,
	[Server Name] sysname ,
	[CPU Usage %] numeric(5,2) ,
	[Buffer Cache Hit %] numeric(5,2) ,
	[Plan Cache Hit %] numeric(5,2) ,
	[Page life expectancy] bigint ,
	[Database Cache Memory (MB)] float ,
	[Plan Chache Memory (MB)] float ,
	[Free Memory (MB)] float ,
	[Total Server Memory (MB)] float ,
	[Target Server Memory (MB)] float ,
	[Granted Workspace Memory (MB)] float ,
	[Memory Grants Outstanding] bigint ,
	[Memory Grants Pending] bigint ,
	[Batch Requests/sec] bigint ,
	[Page lookups (MB)/sec] float ,
	[Readahead pages (MB)/sec] float ,
	[Page reads (MB)/sec] float ,
	[Page writes (MB)/sec] float ,
	[Checkpoint pages (MB)/sec] float ,
	[Background writer pages (MB)/sec] float ,
	[Log Flushes/sec] bigint ,
	[Log MBytes Flushed/sec] float ,
	[Log Flush Waits/sec] bigint ,
	[Log Flush Wait Time] bigint ,
	[SQL Compilations/sec] bigint ,
	[SQL Re-Compilations/sec] bigint
)
GO

INSERT INTO PerfTable EXEC usp_livemonitor 
WAITFOR DELAY '00:00:05'
GO 1000