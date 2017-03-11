-- オブジェクトの初期化
DROP SECURITY POLICY IF EXISTS Security.tenantPolicy
DROP FUNCTION IF EXISTS Security.tenantAccessPredicate
DROP TABLE IF EXISTS Sales
DROP USER IF EXISTS AppUser
DROP SCHEMA IF EXISTS Security
 

-- テーブルの作成とデータの投入
CREATE TABLE Sales (
 OrderId int,
 Qty int,
 Product varchar(10),
 TenantId int
)
  
INSERT INTO Sales VALUES
 (1, 53, 'Valve', 1),  (2, 71, 'Bracket', 2),  (3, 60, 'Wheel', 2)
go

-- ユーザーの作成
CREATE USER AppUser WITHOUT LOGIN
go
GRANT SELECT, INSERT, UPDATE, DELETE ON Sales TO AppUser
go
  

-- RLS で使用する関数の作成
CREATE SCHEMA Security
go
  
CREATE FUNCTION Security.tenantAccessPredicate(@TenantId int)
 RETURNS TABLE
 WITH SCHEMABINDING
AS
 RETURN SELECT 1 AS accessResult
 WHERE
 @TenantId = CONVERT(int, CONVERT(varbinary(4), CONTEXT_INFO()))
 OR
 CONVERT(int, CONVERT(varbinary(4), CONTEXT_INFO())) = 0
go


-- セキュリティポリシーの作成
DROP SECURITY POLICY IF EXISTS Security.tenantPolicy
CREATE SECURITY POLICY Security.tenantPolicy
 ADD FILTER PREDICATE Security.tenantAccessPredicate(TenantId) ON dbo.Sales
,ADD BLOCK PREDICATE Security.tenantAccessPredicate(TenantId) ON dbo.Sales AFTER UPDATE
,ADD BLOCK PREDICATE Security.tenantAccessPredicate(TenantId) ON dbo.Sales AFTER INSERT
go

-- 全データの確認
SELECT * FROM Sales

-- ユーザーの切り替え
SET CONTEXT_INFO 2
go

-- ユーザーが操作できるデータの確認  
SELECT * FROM Sales
go

-- 自分が検索できないデータの変更操作を実施
-- 検索できないデータへの更新もエラーとなる
INSERT INTO Sales VALUES (4, 1000, 'Wheel', 1)		-- BLOCK AFTER により自分が参照できないデータの作成は不可
UPDATE Sales SET TenantID = 0  WHERE OrderID = 2	-- BLOCK AFTER により操作できなデータへの変更は不可
DELETE FROM Sales WHERE TenantId = 1				-- FILTER によりデータ参照できないため操作不可


REVERT
go
 
-- 操作対象外のデータ操作に対しての結果は反映されていない
SET CONTEXT_INFO 0
SELECT * FROM Sales


-- BEFORE のブロック述語を設定
-- FILTER	: ルールに一致したにデータを参照することをフィルター
-- AFTER	: ルールに一致しないデータを作り出すことをブロック
-- BEFORE	: ルールに一致しないデータを操作することをブロック
DROP SECURITY POLICY IF EXISTS Security.tenantPolicy
CREATE SECURITY POLICY Security.tenantPolicy
ADD BLOCK PREDICATE Security.tenantAccessPredicate(TenantId) ON dbo.Sales BEFORE UPDATE
,ADD BLOCK PREDICATE Security.tenantAccessPredicate(TenantId) ON dbo.Sales BEFORE DELETE
go
  
-- 動作確認を実施
SET CONTEXT_INFO 2
go
  
SELECT * FROM Sales
go
  
INSERT INTO Sales VALUES (4, 1000, 'Wheel', 1)		-- AFTER INSERT がないので参照できないデータを追加可能
UPDATE Sales SET TenantID = 0  WHERE OrderID = 2	-- AFTER UPDATE がないので参照できないデータへの変更が可能
UPDATE Sales SET TenantID = 2 WHERE TenantID = 1	-- BEFORE UPDATE により参照できないデータに対しての変更は不可
DELETE FROM Sales WHERE TenantId = 1				-- BEFORE DELETE により参照できないデータの削除は不可 (FILTER が行われれている場合は、FILTER 側で制御された結果に対しての DELETE の判断)


REVERT
go

-- 操作対象外のデータ操作に対しての結果は反映されていない
SET CONTEXT_INFO 0
SELECT * FROM Sales



-- FILTER / BEFORE / AFTER のブロック述語を設定
DROP SECURITY POLICY IF EXISTS Security.tenantPolicy
CREATE SECURITY POLICY Security.tenantPolicy
 ADD FILTER PREDICATE Security.tenantAccessPredicate(TenantId) ON dbo.Sales
,ADD BLOCK PREDICATE Security.tenantAccessPredicate(TenantId) ON dbo.Sales AFTER UPDATE
,ADD BLOCK PREDICATE Security.tenantAccessPredicate(TenantId) ON dbo.Sales AFTER INSERT
,ADD BLOCK PREDICATE Security.tenantAccessPredicate(TenantId) ON dbo.Sales BEFORE UPDATE
,ADD BLOCK PREDICATE Security.tenantAccessPredicate(TenantId) ON dbo.Sales BEFORE DELETE
go

