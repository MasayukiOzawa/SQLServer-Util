USE DemoDB
GO

DROP VIEW IF EXISTS vRLS

IF EXISTS(SELECT * FROM sys.security_policies WHERE NAME = 'vRLSFilter')
	DROP SECURITY POLICY rls.vRLSFilter

IF EXISTS(SELECT * FROM sys.objects WHERE NAME = 'fn_vRLSPredicate')
	DROP FUNCTION rls.fn_vRLSPredicate
GO


-- RLS 設定するビューを作成
CREATE VIEW vRLS
AS
SELECT * FROM RowLevelSecurity
GO

-- vRLS 用のフィルター関数を作成
-- ベーステーブルと同一のフィルター関数を使用することも可能だが、今回は View 用に作成
CREATE FUNCTION rls.fn_vRLSPredicate(@SalesRep as nvarchar(50))
RETURNS TABLE
    RETURN
    SELECT 1 AS fn_fn_vRLSPredicate_result 
    WHERE @SalesRep = USER_NAME() 
    OR
    USER_NAME() = N'マネージャー'
GO

-- ビューに RLS を設定
CREATE SECURITY POLICY rls.vRLSFilter
	ADD FILTER PREDICATE rls.fn_vRLSPredicate(SalesRep) 
	ON dbo.vRLS
WITH (STATE = ON, SCHEMABINDING=OFF)
GO


-- 権限の付与
GRANT SELECT,INSERT,UPDATE,DELETE ON vRLS TO ユーザーA
GRANT SELECT ON rls.fn_vRLSPredicate TO ユーザーA
GO

 
-- ベーステーブルの RLS のフィルターを無効化
ALTER  SECURITY POLICY rls.RowLevelSecurityFilter
WITH (STATE = OFF)
GO
 
-- ユーザーA で検索 
-- (ベーステーブルのフィルターを無効にしているため、すべての情報が見える)
EXECUTE AS USER = N'ユーザーA'
SELECT USER_NAME() AS username, * FROM RowLevelSecurity
REVERT

-- ユーザーA でビューを検索
-- ビューに設定した RLS が有効に動作
EXECUTE AS USER = N'ユーザーA'
SELECT USER_NAME() AS username, * FROM vRLS
REVERT
  
 