SELECT @@SPID, APP_NAME()
GO
--DBCC FREEPROCCACHE

DECLARE @val int = 1
-- TPCH-H のテーブルを JOIN して処理負荷の高い状態発生させる
EXEC sp_executesql N'
SELECT 
	COUNT_BIG(*) 
FROM 
	tpch.dbo.LINEITEM AS L WITH(NOLOCK)
	LEFT JOIN tpch.dbo.PART AS P WITH(NOLOCK) ON P.P_PARTKEY = L.L_PARTKEY
	LEFT JOIN tpch.dbo.PARTSUPP AS PS WITH(NOLOCK) ON PS.PS_PARTKEY = P.P_PARTKEY
	LEFT JOIN tpch.dbo.ORDERS AS O WITH(NOLOCK) ON O.O_ORDERKEY = L.L_ORDERKEY
	LEFT JOIN tpch.dbo.SUPPLIER AS S WITH(NOLOCK) ON S.S_SUPPKEY = PS.PS_SUPPKEY
	LEFT JOIN tpch.dbo.CUSTOMER AS C WITH(NOLOCK) ON C.C_CUSTKEY = O.O_CUSTKEY
	LEFT JOIN tpch.dbo.NATION AS N WITH(NOLOCK) ON N.N_NATIONKEY = C_NATIONKEY
	LEFT JOIN tpch.dbo.REGION AS R WITH(NOLOCK) ON R.R_REGIONKEY = N.N_REGIONKEY
WHERE 
	1=@val
GROUP BY L_COMMENT
', N'@val int', @val = @val
GO
-- 4,337,928
/*
MAX 29 GB の場合 (Target Server Memory の 75% 程度が Max となる)
REQUEST_MAX_MEMORY_GRANT_PERCENT = 5
- RequiredMemory     :     82,184
- RequestedMemory    :  1,497,136
- GrantedMemory      :  1,497,136
- MaxUsedMemory      :  1,293,312
- MaxQueryMemory     :  1,497,136

REQUEST_MAX_MEMORY_GRANT_PERCENT = 10
- RequiredMemory     :     82,184
- RequestedMemory    :  2,994,272
- GrantedMemory      :  2,994,272
- MaxUsedMemory      :  2,491,392
- MaxQueryMemory     :  2,994,272

REQUEST_MAX_MEMORY_GRANT_PERCENT = 25 (Default)
- RequiredMemory     :     82,184
- RequestedMemory    :  7,485,696
- GrantedMemory      :  7,485,696
- MaxUsedMemory      :  6,234,112
- MaxQueryMemory     :  7,485,696


REQUEST_MAX_MEMORY_GRANT_PERCENT = 50
- RequiredMemory     :     82,184
- RequestedMemory    : 14,971,392
- GrantedMemory      : 14,971,392
- MaxUsedMemory      : 12,279,808
- MaxQueryMemory     : 14,971,392


REQUEST_MAX_MEMORY_GRANT_PERCENT = 100
- RequiredMemory     :     82,184
- RequestedMemory    : 27,259,400
- GrantedMemory      : 27,259,400
- MaxUsedMemory      : 22,364,160
- MaxQueryMemory     : 29,942,784
*/


