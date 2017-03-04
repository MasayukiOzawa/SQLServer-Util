USE [DemoDB]
GO

-- CTP 2.3 までのブロック述語が使えない場合の制約による制御
-- CTP 2.3 以降では、ブロック述語により制御可能なため、この方法を使う必要はない

-- RLS の述語関数を使用した制約用の関数を作成
CREATE FUNCTION rls.fn_RLSAccessPredicateScalar(@SalesRep nvarchar(50))
RETURNS bit
AS BEGIN
IF EXISTS(SELECT 1 FROM rls.fn_RowLevelSecurityPredicate(@SalesRep))
    RETURN 1
RETURN 0
END
GO
 
-- 制約の追加
ALTER TABLE RowLevelSecurity
WITH NOCHECK 
ADD CONSTRAINT chk_RowLevelSecurity
CHECK(rls.fn_RLSAccessPredicateScalar(SalesRep) = 1)
GO

-- ユーザーB でユーザーA のデータを INSERT
EXECUTE AS USER = N'ユーザーB'
INSERT INTO RowLevelSecurity VALUES (7,N'ユーザーA', N'製品A',100)
INSERT INTO RowLevelSecurity VALUES (7,N'ユーザーB', N'製品A',100)
SELECT USER_NAME() AS username, * FROM RowLevelSecurity
REVERT
