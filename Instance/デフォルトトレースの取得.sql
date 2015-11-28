 /*********************************************/
-- 自動拡張の発生状況
/*********************************************/
DECLARE @curr_tracefilename varchar(500) 
DECLARE @base_tracefilename varchar(500)
DECLARE @indx int

SELECT @curr_tracefilename = path FROM sys.traces WHERE is_default = 1
SET @curr_tracefilename = reverse(@curr_tracefilename)
SELECT @indx  = patindex('%\%', @curr_tracefilename)
SET @curr_tracefilename = reverse(@curr_tracefilename)
SET @base_tracefilename = left( @curr_tracefilename,len(@curr_tracefilename) - @indx) + '\log.trc'

SELECT 	
	EventClass,
	DatabaseName,
	FileName,
	StartTime,
	EndTime,
	Duration
FROM 
	fn_trace_gettable( @base_tracefilename, default ) 
WHERE 
	EventClass IN (92, 93)
OPTION (RECOMPILE)
GO

 /*********************************************/
--  メモリ割り当ての推移
/*********************************************/
DECLARE @curr_tracefilename varchar(500) 
DECLARE @base_tracefilename varchar(500)
DECLARE @indx int

SELECT @curr_tracefilename = path FROM sys.traces WHERE is_default = 1
SET @curr_tracefilename = reverse(@curr_tracefilename)
SELECT @indx  = patindex('%\%', @curr_tracefilename)
SET @curr_tracefilename = reverse(@curr_tracefilename)
SET @base_tracefilename = left( @curr_tracefilename,len(@curr_tracefilename) - @indx) + '\log.trc'

SELECT 	
	EventClass,
	StartTime,
	IntegerData
FROM 
	fn_trace_gettable( @base_tracefilename, default ) 
WHERE 
	EventClass IN (81)
OPTION (RECOMPILE)
