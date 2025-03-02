USE [master]
GO

-- リソースガバナーの有効化
ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO

/*

-- 分類子関数のクリア
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL);
GO

-- リソースガバナーの無効化
ALTER RESOURCE GOVERNOR DISABLE;
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO

*/

-- リソースプールの作成
CREATE RESOURCE POOL MemoryLimitPool
WITH  
(  
     MAX_MEMORY_PERCENT  = 100
) 
GO  


-- ワークロードグループの作成
CREATE WORKLOAD GROUP MemoryLimitGroup
WITH  
(  
	 REQUEST_MAX_MEMORY_GRANT_PERCENT = 25	--25 はデフォルトの値

)USING MemoryLimitPool
GO  


-- 分類子関数の作成
/*
使用できる関数は以下に記載されている。
https://learn.microsoft.com/ja-jp/previous-versions/sql/sql-server-2008-r2/bb933865(v=sql.105)?redirectedfrom=MSDN
https://learn.microsoft.com/en-us/answers/questions/259223/resource-governor-how-to-write-a-classifier-functi
*/
CREATE OR ALTER FUNCTION fnApplicationNameClassifier()  
RETURNS sysname  
WITH SCHEMABINDING  
AS  
BEGIN  
	IF APP_NAME() IN(
		'Microsoft SQL Server Management Studio - クエリ',
		'azdata'
	)
	BEGIN
		RETURN 'MemoryLimitGroup'
	END

    RETURN NULL
END;  
GO


-- リソースガバナーに分類子関数を割り当て
ALTER RESOURCE GOVERNOR 
WITH (CLASSIFIER_FUNCTION = dbo.fnApplicationNameClassifier);  
GO

-- リソースガバナーの設定の反映
ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO

/*
DROP WORKLOAD GROUP SSMSGroup
ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO

メッセージ 10904、レベル 16、状態 2、行 61
Resource Governor の構成に失敗しました。
削除中または別のリソース プールに移動中のワークロード グループにアクティブなセッションがあります。
処理されるワークグループ内のすべてのアクティブなセッションを切断してから再試行してください。


CREATE RESOURCE POOL MemoryLimitPool
WITH  
(  
     MAX_MEMORY_PERCENT  = 100
) 
GO  


*/

-- リソースガバナーの設定状況の確認
-- https://learn.microsoft.com/ja-jp/sql/relational-databases/resource-governor/create-and-test-a-classifier-user-defined-function?view=sql-server-ver16#to-verify-the-resource-pools-workload-groups-and-the-classifier-user-defined-function
USE [master]
GO

SELECT * FROM sys.resource_governor_configuration;  
GO  

SELECT   
      object_schema_name(classifier_function_id) AS [schema_name],  
      object_name(classifier_function_id) AS [function_name]  
FROM sys.dm_resource_governor_configuration;  

-- 分類子関数の実行状況の確認
-- 上記のようなシンプルなクエリであれば、1 ミリ秒未満のオーバーヘッドとなる。
SELECT * FROM sys.dm_exec_function_stats WHERE object_id = (SELECT classifier_function_id FROM sys.resource_governor_configuration)



SELECT es.session_id, es.program_name, es.program_name, wg.name
FROM sys.dm_exec_sessions AS es
INNER JOIN sys.resource_governor_workload_groups AS wg
	ON wg.group_id = es.group_id
WHERE
	program_name IS NOT NULL AND es.session_id = 137
ORDER BY
	es.program_name ASC, es.group_id ASC


-- 分類子関数の変更
CREATE OR ALTER FUNCTION fnApplicationNameClassifier_02()  
RETURNS sysname  
WITH SCHEMABINDING  
AS  
BEGIN  
	IF APP_NAME() IN(
		'Microsoft SQL Server Management Studio - クエリ',
		'azdata', 
		'Pwsh'
	)
	BEGIN
		RETURN 'MemoryLimitGroup'
	END

    RETURN NULL
END;  
GO

-- リソースガバナーの分類子関数の変更
ALTER RESOURCE GOVERNOR 
WITH (CLASSIFIER_FUNCTION = dbo.fnApplicationNameClassifier_02);  
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO



--テーブルを使用した制御
use master
GO
DROP TABLE IF EXISTS workload_management
GO

CREATE TABLE workload_management
(
	application_name sysname NOT NULL,
	target_group sysname,
	CONSTRAINT PK_workload_management PRIMARY KEY(application_name)
)
GO

INSERT INTO workload_management 
VALUES
	('Microsoft SQL Server Management Studio - クエリ', 'MemoryLimitGroup'),
	('azdata', 'MemoryLimitGroup'),
	('Pwsh', 'MemoryLimitGroup')
GO


CREATE OR ALTER FUNCTION fnApplicationNameClassifier_03()  
RETURNS sysname  
WITH SCHEMABINDING  
AS  
BEGIN

	DECLARE @targetGroup sysname
	SELECT @targetGroup = target_group FROM dbo.workload_management WHERE application_name = APP_NAME()

	IF @targetGroup IS NOT NULL
	BEGIN
		RETURN @targetGroup
	END

    RETURN NULL
END;  
GO


Update workload_management SET target_group ='NormalGroup' WHERE application_name='Pwsh'
GO

-- リソースガバナーの分類子関数の変更
ALTER RESOURCE GOVERNOR 
WITH (CLASSIFIER_FUNCTION = dbo.fnApplicationNameClassifier_03);  
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO


CREATE OR ALTER FUNCTION fnApplicationNameClassifier_04()  
RETURNS sysname  
WITH SCHEMABINDING  
AS  
BEGIN
	RETURN
	(
		SELECT TOP 1
			target_group 
		FROM (
			VALUES
				(N'Microsoft SQL Server Management Studio - クエリ', N'MemoryLimitGroup'),
				(N'azdata', N'MemoryLimitGroup'),
				(N'Pwsh', N'MemoryLimitGroup')
		) AS workload_management(application_name, target_group)
		WHERE application_name = APP_NAME()
	)
END;  
GO

ALTER RESOURCE GOVERNOR 
WITH (CLASSIFIER_FUNCTION = dbo.fnApplicationNameClassifier_04);  
GO

ALTER RESOURCE GOVERNOR RECONFIGURE;  
GO


