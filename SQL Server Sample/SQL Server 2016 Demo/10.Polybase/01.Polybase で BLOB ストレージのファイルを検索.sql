USE [DemoDB]

CREATE MASTER KEY ENCRYPTION BY PASSWORD='MyP@ssword123';

-- CTP 2.4 まではトレースフラグを有効にする
-- DBCC TRACEON(4631,-1)
 

 -- CTP 2.2 以降の作成方法
CREATE DATABASE SCOPED CREDENTIAL AzureBlob  -- 任意の設定
WITH 
IDENTITY = 'AzureBLOB', -- 任意の設定
SECRET='<ストレージアカウントのキー>';
GO

/*
CTP 2.1 の場合
CREATE CREDENTIAL AzureBlob  -- 任意の設定
ON DATABASE WITH
IDENTITY = 'AzureBLOB', -- 任意の設定
SECRET='<ストレージアカウントのキー>';
GO
*/

CREATE EXTERNAL DATA SOURCE AzureData
WITH (
    TYPE = HADOOP,
    LOCATION = 'wasbs://<コンテナー>@<ストレージアカウント>.blob.core.windows.net/',
    CREDENTIAL = AzureBlob
);

GO

CREATE EXTERNAL FILE FORMAT CSV 
WITH ( 
    FORMAT_TYPE = DELIMITEDTEXT, 
    FORMAT_OPTIONS ( 
        FIELD_TERMINATOR = ','
    ) 
);
GO


-- ファイルは UTF-8 で保存しておく
-- 照合順序のデフォルトが Japanese ではないので、マルチバイト文字の取扱いは注意する
CREATE EXTERNAL TABLE AzureBlob 
( 
Col1 int,
Col2 nvarchar(100)
) 
WITH
( 
    LOCATION = '/Data.tbl', 
    DATA_SOURCE = AzureData, 
    FILE_FORMAT = CSV
)

SELECT * FROM AzureBlob
SELECT * FROM AzureBlob WHERE Col1 BETWEEN 3 AND 5
INSERT INTO AzureBlob VALUES(9, 'TEST')
 
SELECT * INTO BlobTmp FROM AzureBLOB
SELECT * FROM BlobTmp


-- CREATE EXTERNAL TABLE AS SELECT  
CREATE EXTERNAL TABLE CTAS 
( 
Col1 int,
Col2 nvarchar(100)
) 
WITH
( 
    LOCATION = '/CTAS.tbl', 
    DATA_SOURCE = AzureData, 
    FILE_FORMAT = CSV
)

INSERT INTO CTAS
SELECT * FROM AzureBLOB

SELECT * FROM CTAS
