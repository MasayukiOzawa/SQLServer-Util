USE DemoDB
GO

-- テーブルの作成とデータ投入    
CREATE TABLE RowLevelSecurity(
[OrderID] int primary key clustered,
[SalesRep] nvarchar(50),
[Product] nvarchar(200),
[Qty] int)
GO
 
INSERT INTO RowLevelSecurity VALUES
(1,N'ユーザーA', N'製品A',100)
,(2,N'ユーザーA', N'製品B',90)
,(3,N'ユーザーB', N'製品C',120)
,(4,N'ユーザーA', N'製品D',130)
,(5,N'ユーザーB', N'製品E',150)
GO
 
-- ユーザーの作成
CREATE USER ユーザーA WITHOUT LOGIN
CREATE USER ユーザーB WITHOUT LOGIN
CREATE USER マネージャー WITHOUT LOGIN
GO

CREATE SCHEMA rls
GO

CREATE FUNCTION rls.fn_RowLevelSecurityPredicate(@SalesRep as nvarchar(50))
RETURNS TABLE
-- CTP 3.0 では SCHEMABINDING は不要にすることができる
-- WITH SCHEMABINDING
    RETURN
    SELECT 1 AS fn_RowLevelSecurityPredicate_result 
    WHERE @SalesRep = USER_NAME() 
    OR
    USER_NAME() = N'マネージャー'
GO
 
-- 権限の付与
GRANT SELECT,INSERT,UPDATE,DELETE ON RowLevelSecurity TO ユーザーA
GRANT SELECT,INSERT,UPDATE,DELETE ON RowLevelSecurity TO ユーザーB
GRANT SELECT,INSERT,UPDATE,DELETE ON RowLevelSecurity TO マネージャー
GRANT SELECT ON rls.fn_RowLevelSecurityPredicate TO ユーザーA
GRANT SELECT ON rls.fn_RowLevelSecurityPredicate TO ユーザーB
GRANT SELECT ON rls.fn_RowLevelSecurityPredicate TO マネージャー
GRANT SHOWPLAN TO ユーザーA
GRANT SHOWPLAN TO ユーザーB
GRANT SHOWPLAN TO マネージャー
GO

 
-- CTP 3.0 では SCHEMABINDING=OFF が指定可能
CREATE SECURITY POLICY rls.RowLevelSecurityFilter
ADD FILTER PREDICATE rls.fn_RowLevelSecurityPredicate(SalesRep) 
ON dbo.RowLevelSecurity
WITH (STATE = ON, SCHEMABINDING=OFF)
GO
 


 -- 行レベルセキュリティを設定後にデータの確認
SELECT * FROM RowLevelSecurity
 
-- ユーザーA で検索
EXECUTE AS USER = N'ユーザーA'
SELECT USER_NAME() AS username, * FROM RowLevelSecurity
REVERT
  
 
-- ユーザーB で検索
EXECUTE AS USER = N'ユーザーB'
SELECT USER_NAME() AS username, * FROM RowLevelSecurity
REVERT
  
-- マネージャーで検索
EXECUTE AS USER = N'マネージャー'
SELECT USER_NAME() AS username, * FROM RowLevelSecurity
REVERT
