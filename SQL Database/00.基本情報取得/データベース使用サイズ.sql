SELECT 
    df.file_id,
    df.type_desc,
    df.data_space_id,
    df.name,
    df.physical_name,
    df.[state],
    df.state_desc,
    df.size * 8 / 1024 AS size_MB,
    FILEPROPERTY(df.name,'SpaceUsed') * 8 / 1024 AS space_used_MB,
    df.max_size * 8 / 1024 AS max_size_MB
FROM 
    sys.database_files AS df;
