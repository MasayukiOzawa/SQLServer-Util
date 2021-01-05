WITH server_role_member AS(
SELECT
    spr.principal_id,
    spr.type_desc,
    spr.name,
    (
        SELECT 
            STRING_AGG (spm.name, ' | ')
        FROM 
            sys.server_role_members rm
            INNER JOIN sys.server_principals AS spm ON rm.member_principal_id = spm.principal_id
        WHERE 
            rm.role_principal_id = spr.principal_id
    ) AS role_member
FROM
    sys.server_principals AS spr
WHERE
    spr.type = 'R'
), role_permission AS(
SELECT 
    rm.principal_id,
    rm.type_desc,
    rm.name,
    rm.role_member,
    spe.state_desc,
    spe.class_desc,
    spe.permission_name,
    CASE
        WHEN spe.class_desc = 'DATABASE' THEN DB_NAME(major_id)
        WHEN spe.class_desc = 'SCHEMA' THEN SCHEMA_NAME(major_id)
        WHEN spe.class_desc = 'OBJECT_OR_COLUMN' AND spe.minor_id = 0 THEN OBJECT_SCHEMA_NAME(spe.major_id) + '.' +  OBJECT_NAME(spe.major_id)
        WHEN spe.class_desc = 'OBJECT_OR_COLUMN' AND spe.minor_id > 0 THEN OBJECT_SCHEMA_NAME(spe.major_id) + '.' +  OBJECT_NAME(spe.major_id) + '(' + (SELECT name FROM sys.columns WHERE object_id = spe.major_id AND column_id = spe.minor_id) + ')'
    END AS major_name
FROM 
    server_role_member AS rm
    LEFT JOIN sys.server_permissions AS spe
        ON spe.grantee_principal_id = rm.principal_id
WHERE 
     role_member IS NOT NULL
),login_permission AS(
SELECT
    sp.principal_id,
    sp.name,
    sp.type_desc,
    NULL AS role_member,
    spe.state_desc,
    spe.class_desc,
    spe.permission_name,
    CASE
        WHEN spe.class_desc = 'DATABASE' THEN DB_NAME(major_id)
        WHEN spe.class_desc = 'SCHEMA' THEN SCHEMA_NAME(major_id)
        WHEN spe.class_desc = 'OBJECT_OR_COLUMN' AND spe.minor_id = 0 THEN OBJECT_SCHEMA_NAME(spe.major_id) + '.' +  OBJECT_NAME(spe.major_id)
        WHEN spe.class_desc = 'OBJECT_OR_COLUMN' AND spe.minor_id > 0 THEN OBJECT_SCHEMA_NAME(spe.major_id) + '.' +  OBJECT_NAME(spe.major_id) + '(' + (SELECT name FROM sys.columns WHERE object_id = spe.major_id AND column_id = spe.minor_id) + ')'
    END AS major_name
FROM
    sys.server_principals AS sp
    LEFT JOIN sys.server_permissions AS spe
        ON spe.grantee_principal_id = sp.principal_id
WHERE
    sp.type_desc IN('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP', 'EXTERNAL_LOGIN', 'EXTERNAL_GROUP')
)
SELECT * FROM role_permission
UNION ALL
SELECT * FROM login_permission
ORDER BY principal_id ASC