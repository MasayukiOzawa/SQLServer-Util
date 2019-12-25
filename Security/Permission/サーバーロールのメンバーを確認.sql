SELECT 
    rm.role_principal_id,
    sp_r.name,
    sp_rm.principal_id,
    sp_rm.name,
    spe.type,
    spe.permission_name,
    spe.state,
    spe.state_desc
FROM 
    sys.server_role_members AS rm
    LEFT JOIN
        sys.server_principals AS sp_r
        ON sp_r.principal_id = rm.role_principal_id
    LEFT JOIN
        sys.server_principals AS sp_rm
        ON sp_rm.principal_id = rm.member_principal_id
    LEFT JOIN
        sys.server_permissions AS spe
        ON spe.grantee_principal_id = rm.role_principal_id
ORDER BY 
    spe.state