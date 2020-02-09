DECLARE @round_start_time bigint = (SELECT MAX(round_start_time) FROM sys.dm_os_memory_cache_clock_hands)
 
SELECT
	rb.ring_buffer_address,
	rb.ring_buffer_type,
	rb.timestamp,
	DATEADD(ms, (rb.timestamp - @round_start_time), GETDATE()) AS record_time,
	CAST(rb.record AS xml) AS record,
	CAST(rb.record AS xml).value('(/Record/@id)[1]','int') AS id,
	CAST(rb.record AS xml).value('(//Error)[1]','int') AS Error,
	CAST(rb.record AS xml).value('(//Severity)[1]','int') AS Severity,
	CAST(rb.record AS xml).value('(//State)[1]','int') AS State,
	m.text
FROM
	sys.dm_os_ring_buffers AS rb
	LEFT JOIN sys.messages AS m
		ON m.message_id = CAST(rb.record AS xml).value('(//Error)[1]','int')
WHERE
	ring_buffer_type = 'RING_BUFFER_EXCEPTION'

ORDER BY timestamp DESC

