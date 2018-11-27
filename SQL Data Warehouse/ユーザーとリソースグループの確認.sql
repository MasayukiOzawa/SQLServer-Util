-- ユーザーとリソースグループの確認
-- https://docs.microsoft.com/ja-jp/azure/sql-data-warehouse/sql-data-warehouse-develop-concurrency#a-namequeued-query-detection-and-other-dmvsaキューに配置されたクエリの検出とその他の-dmv
SELECT     r.name AS role_principal_name
        ,m.name AS member_principal_name
FROM    sys.database_role_members rm
JOIN    sys.database_principals AS r            ON rm.role_principal_id        = r.principal_id
JOIN    sys.database_principals AS m            ON rm.member_principal_id    = m.principal_id
WHERE    r.name IN ('mediumrc','largerc', 'xlargerc');