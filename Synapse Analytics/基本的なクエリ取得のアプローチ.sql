/*
https://docs.microsoft.com/ja-jp/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-manage-monitor
https://docs.microsoft.com/ja-jp/azure/synapse-analytics/sql-data-warehouse/cheat-sheet
https://docs.microsoft.com/ja-jp/azure/synapse-analytics/sql-data-warehouse/memory-concurrency-limits



https://sqlbitscontent.blob.core.windows.net/sessioncontent/5777/0384e476-bac7-4927-90d7-f15f165761e6.pdf
https://www.sqlsaturday.com/SessionDownload.aspx?suid=27543 
*/



-- 実行するクエリにラベルを付与してトレーサビリティを上げる
/* TPC_H Query 7 - Volume Shipping */
SELECT 
    SUPP_NATION,
    CUST_NATION,
    L_YEAR,
    SUM(VOLUME) AS REVENUE
FROM
(
    SELECT 
        N1.N_NAME AS SUPP_NATION,
        N2.N_NAME AS CUST_NATION,
        DATEPART(yy,L_SHIPDATE) AS L_YEAR,
        L_EXTENDEDPRICE * (1 - L_DISCOUNT) AS VOLUME
    FROM 
         SUPPLIER
         LEFT JOIN LINEITEM ON S_SUPPKEY = L_SUPPKEY
         LEFT JOIN ORDERS ON O_ORDERKEY = L_ORDERKEY
         LEFT JOIN CUSTOMER ON C_CUSTKEY = O_CUSTKEY
         LEFT JOIN NATION AS N1 ON S_NATIONKEY = N1.N_NATIONKEY
         LEFT JOIN NATION AS N2 ON C_NATIONKEY = N2.N_NATIONKEY
    WHERE((N1.N_NAME = 'FRANCE'
           AND N2.N_NAME = 'GERMANY')
          OR (N1.N_NAME = 'GERMANY'
              AND N2.N_NAME = 'FRANCE'))
         AND L_SHIPDATE BETWEEN '1995-01-01' AND '1996-12-31'
) AS SHIPPING
GROUP BY 
    SUPP_NATION,
    CUST_NATION,
    L_YEAR
ORDER BY 
    SUPP_NATION,
    CUST_NATION,
    L_YEAR
    OPTION (LABEL = 'TPC H Query 7')


-- 該当のラベルを持つクエリの Request ID を取得
SELECT  *FROM sys.dm_pdw_exec_requests WHERE [label] IN( 'Normal', 'High' ) and status in('Running', 'Suspended') ORDER BY submit_time DESC

-- 取得した Request Id を設定
DECLARE @request_id nvarchar(32)	= 'QID5407'

-- クエリプラン (ポータルで確認できる情報) を取得
-- これにより全体的なクエリプランの選択を確認できる
SELECT * FROM sys.dm_pdw_request_steps WHERE request_id = @request_id order by step_index ASC

--  各ステップの詳細なクエリの処理情報
SELECT * FROM sys.dm_pdw_sql_requests WHERE request_id = @request_id ORDER BY step_index ASC

-- DMS が使用されている場合 (データの移動) の動作状況
SELECT * FROM sys.dm_pdw_dms_workers WHERE request_id = @request_id order by step_index ASC, pdw_node_id ASC, distribution_id

-- 外部ファイルのロードを実行している場合の DMS の活動状況の取得
SELECT * FROM sys.dm_pdw_dms_external_work WHERE request_id = @request_id 

-- 実行中のクエリの特定のディストリビューターで実行されている SQL の詳細情報の取得 (引数は Distribution ID , Session ID)
DBCC PDW_SHOWEXECUTIONPLAN ( 1, 126 )
-- こちらでも同じ
select pdw_node_id, session_id,REPLACE(query_plan,'''','''''') from sys.dm_pdw_nodes_exec_query_statistics_xml order by session_id ASC
