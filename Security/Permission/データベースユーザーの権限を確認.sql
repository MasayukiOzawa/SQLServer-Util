WITH database_role_member AS(
SELECT
    dpr.principal_id,
    dpr.type_desc,
    dpr.name,
    (
        SELECT 
            STRING_AGG (dpm.name, ' | ')
        FROM 
            sys.database_role_members rm 
            INNER JOIN sys.database_principals AS dpm ON rm.member_principal_id = dpm.principal_id
        WHERE 
            rm.role_principal_id = dpr.principal_id
    ) AS role_member
FROM
    sys.database_principals AS dpr
WHERE
    dpr.type = 'R'
), role_permission AS(
SELECT 
    DB_NAME() AS database_name,
    rm.principal_id,
    rm.name,
    rm.type_desc,
    NULL AS authentication_type_desc,
    rm.role_member,
    dpe.state_desc,
    dpe.class_desc,
    dpe.permission_name,
    CASE
        WHEN dpe.class_desc = 'DATABASE' THEN DB_NAME(major_id)
        WHEN dpe.class_desc = 'SCHEMA' THEN SCHEMA_NAME(major_id)
        WHEN dpe.class_desc = 'OBJECT_OR_COLUMN' AND dpe.minor_id = 0 THEN OBJECT_SCHEMA_NAME(dpe.major_id) + '.' +  OBJECT_NAME(dpe.major_id)
        WHEN dpe.class_desc = 'OBJECT_OR_COLUMN' AND dpe.minor_id > 0 THEN OBJECT_SCHEMA_NAME(dpe.major_id) + '.' +  OBJECT_NAME(dpe.major_id) + '(' + (SELECT name FROM sys.columns WHERE object_id = dpe.major_id AND column_id = dpe.minor_id) + ')'
    END AS major_name,
    minor_id,
    -- (SELECT name FROM sys.database_principals WHERE principal_id = grantee_principal_id) AS grantee_principal_name,
    (SELECT name FROM sys.database_principals WHERE principal_id = grantor_principal_id) AS grantor_principal_name
FROM 
    database_role_member AS rm
    LEFT JOIN sys.database_permissions AS dpe
        ON dpe.grantee_principal_id = rm.principal_id
WHERE 
     role_member IS NOT NULL
),user_permission AS(
SELECT
    DB_NAME() AS database_name,
    dp.principal_id,
    dp.name,
    dp.type_desc,
    dp.authentication_type_desc,
    NULL AS role_member,
    dpe.state_desc,
    dpe.class_desc,
    dpe.permission_name,
    CASE
        WHEN dpe.class_desc = 'DATABASE' THEN DB_NAME(major_id)
        WHEN dpe.class_desc = 'SCHEMA' THEN SCHEMA_NAME(major_id)
        WHEN dpe.class_desc = 'OBJECT_OR_COLUMN' AND dpe.minor_id = 0 THEN OBJECT_SCHEMA_NAME(dpe.major_id) + '.' +  OBJECT_NAME(dpe.major_id)
        WHEN dpe.class_desc = 'OBJECT_OR_COLUMN' AND dpe.minor_id > 0 THEN OBJECT_SCHEMA_NAME(dpe.major_id) + '.' +  OBJECT_NAME(dpe.major_id) + '(' + (SELECT name FROM sys.columns WHERE object_id = dpe.major_id AND column_id = dpe.minor_id) + ')'
    END AS major_name,
    minor_id,
    --(SELECT name FROM sys.database_principals WHERE principal_id = grantee_principal_id) AS grantee_principal_name,
    (SELECT name FROM sys.database_principals WHERE principal_id = grantor_principal_id) AS grantor_principal_name
FROM
    sys.database_principals AS dp
    LEFT JOIN sys.database_permissions AS dpe
        ON dpe.grantee_principal_id = dp.principal_id
WHERE
    dp.type_desc IN('WINDOWS_USER', 'SQL_USER', 'EXTERNAL_USER', 'EXTERNAL_GROUP', 'DATABASE_ROLE')
)

SELECT * FROM role_permission
UNION ALL
SELECT * FROM user_permission
WHERE name NOT IN ('public', 'guest', 'sys','dbo', 'INFORMATION_SCHEMA')
ORDER BY principal_id ASC
