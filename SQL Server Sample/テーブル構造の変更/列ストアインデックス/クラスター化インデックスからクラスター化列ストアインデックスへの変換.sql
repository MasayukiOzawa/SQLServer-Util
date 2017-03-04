IF OBJECT_ID('ORDERS_CI','U') IS NOT NULL
    DROP TABLE ORDERS_CI
GO

IF EXISTS (SELECT * FROM sys.partition_schemes WHERE name = 'ORDERS_CI_PS')
	DROP PARTITION SCHEME [ORDERS_CI_PS]
GO

IF EXISTS (SELECT * FROM sys.partition_functions WHERE name = 'ORDERS_CI_PF')
	DROP PARTITION FUNCTION [ORDERS_CI_PF]
GO

CREATE TABLE [dbo].[ORDERS_CI](
	[O_ORDERKEY] [int] NOT NULL,
	[O_CUSTKEY] [int] NOT NULL,
	[O_ORDERSTATUS] [char](1) NOT NULL,
	[O_TOTALPRICE] [decimal](15, 2) NOT NULL,
	[O_ORDERDATE] [date] NOT NULL,
	[O_ORDERPRIORITY] [nchar](15) NOT NULL,
	[O_CLERK] [char](15) NOT NULL,
	[O_SHIPPRIORITY] [int] NOT NULL,
	[O_COMMENT] [varchar](79) NOT NULL,
	CONSTRAINT [PK_ORDERS_CI] PRIMARY KEY CLUSTERED ([O_ORDERKEY] ASC)
)

CREATE PARTITION FUNCTION [ORDERS_CI_PF](date) AS RANGE RIGHT FOR VALUES ('2000/1/1','2001/1/1','2002/1/1','2003/1/1','2004/1/1')
GO  
CREATE PARTITION SCHEME [ORDERS_CI_PS] AS PARTITION [ORDERS_CI_PF] ALL TO ([PRIMARY])
GO

-- 主キー制約 (クラスター化インデックスを削除)
ALTER TABLE [dbo].[ORDERS_CI] DROP CONSTRAINT [PK_ORDERS_CI]
GO

-- 非クラスター化インデックスを主キーとして設定 (クラスター化列ストアインデックスを作成するため)
ALTER TABLE [dbo].[ORDERS_CI] ADD  CONSTRAINT [PK_ORDERS_CI] PRIMARY KEY NONCLUSTERED 
([O_ORDERKEY] ASC, [O_ORDERDATE] ASC)
WITH (DATA_COMPRESSION =PAGE)
ON [ORDERS_CI_PS]([O_ORDERDATE]) 
GO


-- 以下のクエリではエラーが発生する
CREATE CLUSTERED COLUMNSTORE INDEX CIX_ORDERS_CI ON ORDERS_CI 
ON [ORDERS_CI_PS]([O_ORDERDATE])

-- http://www.nikoport.com/2013/08/01/clustered-columnstore-indexes-part-14-partitioning/


-- 一度クラスター化インデックスでパーティショニングを実施し、その後に列ストアインデックスを再作成で作成する。
CREATE CLUSTERED INDEX CIX_ORDERS_CI ON ORDERS_CI (O_ORDERDATE)
ON [ORDERS_CI_PS]([O_ORDERDATE])

CREATE CLUSTERED COLUMNSTORE INDEX CIX_ORDERS_CI ON ORDERS_CI 
WITH (DROP_EXISTING = ON)
ON [ORDERS_CI_PS]([O_ORDERDATE])


-- データ格納状況の確認
SELECT
    OBJECT_NAME(sp.object_id)
    , si.name
    , sp.partition_number
    , sp.rows
    , sp.data_compression_desc
    , si.type_desc
FROM
    sys.partitions sp
    LEFT JOIN
        sys.indexes as si
        ON
        si.object_id = sp.object_id
        AND
        si.index_id = sp.index_id
WHERE
    sp.object_id IN (OBJECT_ID(N'dbo.ORDERS_CI'))
GO

