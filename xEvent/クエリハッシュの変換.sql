-- xEvent to DMV
DECLARE @query_hash decimal(20,0) = 9974222887417559106
 
DECLARE @msb BIGINT = 0x8000000000000000 -- @msb = -9223372036854775808
 
SELECT
    CASE WHEN @query_hash < CONVERT(DECIMAL(20,0), @msb)*-1
    THEN CONVERT(BINARY(8), CONVERT(BIGINT, @query_hash))
    ELSE CONVERT(BINARY(8), CONVERT(BIGINT, @query_hash - CONVERT(DECIMAL(20,0), @msb) * -1) | @msb)
    END AS dmv_query_hash
GO
 
-- DMV to xEvent
DECLARE @query_hash BINARY(8) = 0x8A6B8EDED3183842
DECLARE @msb BIGINT = 0x8000000000000000
 
SELECT
    CASE WHEN @query_hash < 0x8000000000000000
    THEN CONVERT(bigint, @query_hash)
    ELSE (((CONVERT(bigint, @query_hash) * -1) | @msb) * -1) + (CONVERT(DECIMAL(20,0), @msb) * -1)
    END AS xEvent_query_hash
GO
